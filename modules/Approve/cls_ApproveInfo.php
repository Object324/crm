<?php
//zxm 20221128 approve.php中的代码优化  获取审批的信息
class cls_ApproveInfo{
    public $module;
    public $approveobj;
    public $approvemodule_field_notempty_arr = [];
    public $approvecondition_arr = [];
    public function __construct($approveobj)
    {
        $this->approveobj=$approveobj;
    }
    //判断审批流程是否在使用中
    public function approveUsed($approveid,$blockid){
        //return -1;
        global $adb;
        $module=getTabname($blockid);
        $focus=CRMEntity::getInstance($module);
        $tablename=$focus->table_name;
        $table_index=$focus->table_index;
        /*$query="SELECT
					b.approveresult
				FROM (SELECT max(id) AS maxlogid FROM ld_approvelog GROUP BY crmid) a
				LEFT JOIN ld_approvelog b ON a.maxlogid=b.id
                inner join $tablename on $tablename.$table_index=b.crmid
				WHERE b.approveid=$approveid
					AND b.approveresult=1 LIMIT 1"; */
        //38119: （pc端）如果一个审批的流程的所有的’审批中‘单据的最后一步是“跳过”，则该审批流程能删除
        $query="SELECT
					$tablename.approvestatus
				FROM (SELECT max(id) AS maxlogid FROM ld_approvelog GROUP BY crmid) a
				LEFT JOIN ld_approvelog b ON a.maxlogid=b.id
               inner join $tablename on $tablename.$table_index=b.crmid
				WHERE b.approveid=$approveid
                        and IFNULL($tablename.approvestatus,'".D_A_S_UNAPPROVED."')='".D_A_S_APPROVALOF."'
                        and $tablename.deleted=0
					 LIMIT 1" ;


        $result=$adb->query($query,array());
        $num_rows=$adb->num_rows($result);
        $approveresult=-1;
        if($num_rows>0){
            //$approveresult=$adb->query_result($result,$num_rows-1,'approveresult');
            $approveresult=1;
        }
        else
        {
            $query="SELECT
					b.approveresult
				FROM (SELECT max(id) AS maxlogid FROM ld_approvelog GROUP BY crmid) a
				LEFT JOIN ld_approvelog b ON a.maxlogid=b.id
                inner join $tablename on $tablename.$table_index=b.crmid
				WHERE b.approveid=$approveid
					AND b.approveresult=1 and b.isfinished='no' LIMIT 1";
            $result=$adb->query($query,array());
            $num_rows=$adb->num_rows($result);
            if($num_rows>0)
                $approveresult=1;

        }

        return $approveresult;
    }
    /**
     * 获取单据的最近审批信息，主要用于审批同步的判断
     * $record:单据id
     * $module:单据所在模块name
     */
    public function getlastapproveinfo($record,$module)
    {
        global $adb;
        $focus=CRMEntity::getInstance($module);
        $maintablename=$focus->table_name;
        $maintable_index=$focus->table_index;
        $smowneridcolumnname=$focus->getSmownerColumName();
        if (empty($smowneridcolumnname)) return [];
        $sql="select countersigner,augmentsinger,ld_approvelog.createdtime, ld_approvelog.id , approveid,stepid,nextstepid,nextstepapproveby,approveresult,approved_by ,$smowneridcolumnname as smowner,$maintablename.deleted
        FROM ld_approvelog inner join $maintablename on $maintablename.$maintable_index=ld_approvelog.crmid
        WHERE ld_approvelog.crmid = ?  and  ld_approvelog.id > 0 and (ld_approvelog.approved_by>0 ) ORDER BY ld_approvelog.id desc,ld_approvelog.createdtime DESC limit 1";

        $result=$adb->pquery($sql,array($record));
        $rows=$adb->num_rows($result);
        $approveinfo=array("stepid"=>0);
        if($rows>0)
        {
            $approveinfo=array("stepid"=>$adb->query_result($result,0,'stepid'),
                'approved_by'=>$adb->query_result($result,0,'approved_by'),
                'nextstepid'=>$adb->query_result($result,0,'nextstepid'),
                'approveresult'=>$adb->query_result($result,0,'approveresult'),
                'approveid'=>$adb->query_result($result,0,'approveid'),
                'countersigner'=>$adb->query_result($result,0,'countersigner'),
                'augmentsinger'=>$adb->query_result($result,0,'augmentsinger'),
                'nextstepapproveby'=>$adb->query_result($result,0,'nextstepapproveby'),
                'deleted'=>$adb->query_result($result,0,'deleted'),
            );
        }
        return $approveinfo;
    }
    public function approveStatus($record){
        static $global_approvestatus;
        if(is_array($global_approvestatus)&&array_key_exists($record,$global_approvestatus))
        {
            return $global_approvestatus[$record];
        }
       
        //0024686: 已经提交审批的单据，提示信息改进。 勾选多条记录时，返回的$approveinfo一样,没有区分$recordid
        global $adb,$current_user;
        $query = 'SELECT
                  approveresult,nextstepapproveby,
                  approveid,nextstepid,
				  stepid,ld_approvelog.countersigner,
                  nextstep_countersigner,augmentsinger,
                  logconcurrentid,ld_approvelog.id,ld_approvelog.approveresult,
                  ld_approvelog.isnewlog FROM ld_approvelog
                  left JOIN ld_approve ON ld_approve.id = ld_approvelog.approveid
                WHERE ld_approvelog.crmid = ?  
                ORDER BY ld_approvelog.seqtime DESC, ld_approvelog.id desc
                LIMIT 1';//editor:gyq date:20170216
        //10:代表审批为不满足条件，直接跳过
        $result = $adb->pquery($query,array($record));
        $islaststepconcurrentid='yes';
        if($adb->num_rows($result)){
            $logconcurrentid=$adb->query_result($result,0,'logconcurrentid');
            $nextstep_countersigner=$adb->query_result($result,0,'nextstep_countersigner');
            $nextstepid=$adb->query_result($result,0,'nextstepid');
            $stepid=$adb->query_result($result,0,'stepid');
            $approveid=$adb->query_result($result,0,'approveid');
            $countersigner=$adb->query_result($result,0,'countersigner');
            $approveresult=$adb->query_result($result,0,'approveresult');
            $isnewlog = $adb->query_result($result,0,'isnewlog');
            $old=$logconcurrentid;

            if($logconcurrentid>0)
            {
                $islaststepconcurrentid='no';
                //并发步骤
                $query="SELECT
                  ld_approvelog.approveresult,ld_approvelog.nextstepapproveby,
                  ld_approvelog.approveid,nextstepid,
				  ld_approvelog.stepid,ld_approvelog.countersigner,
                  nextstep_countersigner,ld_approvelog.augmentsinger,
                  logconcurrentid,ld_approvelog.id,ld_approvelog.approveresult FROM ld_approvelog
                  left JOIN ld_approve ON ld_approve.id = ld_approvelog.approveid
                  inner join ld_approvestep on ld_approvestep.id=ld_approvelog.stepid
                WHERE ld_approvelog.crmid =?  and ld_approvelog.logconcurrentid=? and ld_approvelog.isfinished='no'
                and FIND_IN_SET(?,nextstepapproveby) 
                                ORDER BY ld_approvelog.seqtime desc,ld_approvelog.stepseq asc,ld_approvelog.createdtime desc,ld_approvelog.id asc
                                LIMIT 1 ";
                $result=$adb->pquery($query,array($record,$logconcurrentid,$current_user->id));

                $logconcurrentid=$adb->query_result($result,0,'logconcurrentid');
                $nextstep_countersigner=$adb->query_result($result,0,'nextstep_countersigner');
                $nextstepid=$adb->query_result($result,0,'nextstepid');
                $stepid=$adb->query_result($result,0,'stepid');
                $approveid=$adb->query_result($result,0,'approveid');
                $countersigner=$adb->query_result($result,0,'countersigner');
                $approveresult=$adb->query_result($result,0,'approveresult');
            }

            $approveinfo=array('approvestatus'=>$adb->query_result($result,0,'approveresult'),
                'nextstepapproveby'=>$adb->query_result($result,0,'nextstepapproveby'),
                'approveid'=>$adb->query_result($result,0,'approveid'),
                'nextstepid'=>$nextstepid,
                'stepid'=>$stepid,
                'countersigner'=>$countersigner,//当前步骤是否为会签
                'nextstep_countersigner'=>$nextstep_countersigner,//下一步审批步骤是否为会签
                'augmentsinger'=>$adb->query_result($result,0,'augmentsinger'),//加签
                'logconcurrentid'=>$adb->query_result($result,0,'logconcurrentid'),
                'approvelogid'=>$adb->query_result($result,0,'id'),
                'approveresult'=>$approveresult,
                'billlogconcurrentid'=>$old,
                'isnewlog'=>$isnewlog
            );
        }
        else{
            $approveinfo=array();
        }
        $global_approvestatus[$record]=$approveinfo;
        return $approveinfo;
    }
    /*
     * editor:gyq_05
     * reason:获取审批步骤详情
     * */
    public function getStepInfo($stepid){
        global $adb;
        $query="select name,approveid,approvevalue,approvetype,countersigner,augmentsinger,module_field,approveremarkrequire,approvetype,emptyapproverdeal,concurrentid from ld_approvestep where id=?";
        $result = $adb->pquery($query,array($stepid));
        $rows = $adb->num_rows($result);
        if($rows > 0){
            for($i=0;$i<$rows;++ $i){
                $data['name'] = $adb->query_result($result,$i,'name');
                $data['approveid'] = $adb->query_result($result,$i,'approveid');
                $data['approvevalue'] = $adb->query_result($result,$i,'approvevalue');
                $data['countersigner'] = $adb->query_result($result,$i,'countersigner');
                $data['augmentsinger'] = $adb->query_result($result,$i,'augmentsinger');
                $data['module_field'] = $adb->query_result($result,$i,'module_field');
                $data['approveremarkrequire'] = $adb->query_result($result,$i,'approveremarkrequire');
                $data['approvetype'] = $adb->query_result($result,$i,'approvetype');
                $data['emptyapproverdeal'] = $adb->query_result($result,$i,'emptyapproverdeal');
                $data['concurrentid'] = $adb->query_result($result,$i,'concurrentid');
            }
        }
        return $data;
    }


    /**
     * edit:kevin
     * date:2013-09-24
     * reason:我的审批中心
     */
    function getApproveLogQuery($approveresult,$searchquery=''){
        global $current_user;
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        $approvemod = cls_ApproveCache::getApproveModuleInfo();//获取审批模块
        $accountmod = cls_ApproveCache::getAccountModule();//获取有客户的模块
        if(empty($approvemod)) return false;//模块为空，则返回

        $tabname = array();
        foreach($approvemod as $setype){
            $tabid = getTabid($setype);
            if(!isset($accountmod[$tabid])) continue;//必须有客户字段
            $entityarray = getEntitynameInfo($tabid);
            if(!isset($entityarray['tablename'])) continue;
            $tabname[$entityarray['tablename']] = 1;
        }
        $tabname['ld_activity'] = 1;//#0013075: 审批中心--日程管理模块单据信息未显示客户名称 tujt 2014-12-23
        $tabname['ld_potential'] = 1;//#0014101: 审批中心--序时簿,关于待审批单据显示问题 tujt 2015-03-25
        $sqlunion='';
        //显示供应商名称
        $vendormodarr = array('PurchaseOrder'=>1,'PurchaseInvoice'=>1);
        $setypeelsearr = array('ContactRecords'=>1,'Calendar'=>1);
        foreach($approvemod as $setype){
            if(isPermitted($setype,'index','') == 'no'){
                continue;
            }
            $focus = CRMEntity::getInstance($setype);
            $tablename = $focus->table_name;
            $tableid = $focus->table_index;
            if($focus->table_code){
                $tablecode = $focus->table_code;
            }else if(isset($setypeelsearr[$setype])){
                $tablecode = '\'--\'';
            }else{
                $tablecode = $setype.'_no';
            }
            $list_link_field = $focus->list_link_field;
            $list_link_obj=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$list_link_field);
            if(empty($list_link_obj)){
                continue;
            }
            $list_link_tabname=$list_link_obj->getTableName();
            $smownercolumname=$focus->getSmownerColumName();
            $smowner_field=$focus->fieldobj->getFieldInfoobjBykey("columnname",$smownercolumname);
            if(!empty($smowner_field)){
                $smownertablename=$smowner_field->getTableName();
            }
            if(isset($tabname[$tablename])){
                /**
                 * edit:chj
                 * date:2014-6-10
                 * reason:0009251: 审批中心若发票号码不为空则显示为“发票号码”，如果发票号码为空则显示为“单据编号”
                 */
                if($tablename == 'ld_invoice')
                    $sqlunion.=" select distinct $smownertablename.$smownercolumname as smownerid, $list_link_tabname.$list_link_field as subject, 
                         $tablename.$tableid as crmid,case when ld_invoicecf.invoice_num = '' then $tablename.$tablecode else ld_invoicecf.invoice_num end as num,'".getTranstab($setype)."' as modulename,ld_account.accountid,accountname,'".$setype."' as fld_module from $tablename inner join ld_invoicecf on ld_invoicecf.invoiceid = ld_invoice.invoiceid inner join ld_approvelog  on ld_approvelog.crmid=".$tablename.'.'.$tableid.' left join ld_account on ld_account.accountid='.$tablename.'.accountid where ld_invoice.deleted = 0 and ld_invoice.invoiceid > 0 union ';
                else
                {
                    $sqlunion.=" select  distinct $smownertablename.$smownercolumname as smownerid, $list_link_tabname.$list_link_field as subject,  $tablename.$tableid as crmid,$tablecode as num,'".getTranstab($setype)."' as modulename,ld_account.accountid,accountname,'".$setype."' as fld_module 
                    from $tablename inner join ld_approvelog  on ld_approvelog.crmid=".$tablename.'.'.$tableid.' left join ld_account on ld_account.accountid='.$tablename.'.accountid ';

                    if($list_link_tabname!=$tablename)
                    {
                        $list_link_tableIndex=$focus->tab_name_index[$list_link_tabname];
                        $sqlunion.=" left join $list_link_tabname  on $list_link_tabname.$list_link_tableIndex=$tablename.$tableid ";
                    }
                    $sqlunion.= ' where '.$tablename.'.deleted = 0 and '.$tablename.'.'.$tableid.' > 0 union ';
                }
            }else{
                //采购订单、采购发票，显示供应商名称
                if(isset($vendormodarr[$setype]))
                {
                    $sqlunion.=" select distinct $smownertablename.$smownercolumname as smownerid, $list_link_tabname.$list_link_field as subject,  $tablename.$tableid as crmid,$tablecode as num,'".getTranstab($setype)."' as modulename ,ld_vendor.Vendorid as accountid,ld_vendor.vendorname as accountname,'".$setype."' as fld_module from $tablename inner join ld_approvelog  on ld_approvelog.crmid=".$tablename.'.'.$tableid.' 
					LEFT JOIN ld_vendor on ld_vendor.Vendorid = '.$tablename.'.vendorid ';
                    if($list_link_tabname!=$tablename)
                    {
                        $list_link_tableIndex=$focus->tab_name_index[$list_link_tabname];
                        $sqlunion.=" left join $list_link_tabname  on $list_link_tabname.$list_link_tableIndex=$tablename.$tableid ";
                    }
                    $sqlunion.=' where '.$tablename.'.deleted = 0 and '.$tablename.'.'.$tableid.' > 0 union ';
                }
                else
                    $sqlunion.=" select distinct $smownertablename.$smownercolumname as smownerid,  $list_link_tabname.$list_link_field as subject,  $tablename.$tableid as crmid,$tablecode as num,'".getTranstab($setype)."' as modulename ,'' as accountid,'' as accountname,'".$setype."' as fld_module from $tablename inner join ld_approvelog  on ld_approvelog.crmid=".$tablename.'.'.$tableid.' 
					where '.$tablename.'.deleted = 0 and '.$tablename.'.'.$tableid.' > 0 union ';
            }
        }
        $sqlunion = trim($sqlunion,'union ');
        $approvemodsql = '"'.join('","',$approvemod).'"';
        $setwhere = ' setype in ('.$approvemodsql.') ';


        $query = 'select ld_approvelog.stepid,t1.fld_module as module,accountid,accountname,
					ld_approvelog.crmid,ld_approvelog.approveid,t1.subject,t1.num,t1.modulename,
					ld_approve.name as approvename,ld_approvestep.name as nextstepname,la.name as stepname,
					ld_approvelog.nextstepapproveby,ld_approvelog.createdtime,
					ld_approvelog.nextstepid,ld_approvelog.approveresult,t5.last_name as smownername,
					ld_approvelog.approved_by,t4.last_name as approveby,user_sponsor.last_name as sponsorname, t.idd from ld_approvelog ';
        if(1 == $approveresult){//未审批
            $joinstring = 'inner';$jointab = 't';
            $where = 'where approveresult=1 and find_in_set(\''.$current_user->id.'\',nextstepapproveby) ';
            $order_by = 'order by ld_approvelog.createdtime desc ';
        }else{//已审批
            //0017484: 审批中心>已处理：当多个审批步骤为同一个用户，结果：已处理界面，显示的一直都是第一步的审批结果。 原先是：原先的left join ， group by之后无法查询到最新的一条审批单据
            $joinstring = 'inner ';$jointab = 'ld_approvelog';
            //17271: 审批中心，已处理的审批信息里面，没有显示审批不通过的信息 approveresult=4
            $where = 'where (approveresult=1 or approveresult=2 or approveresult=3 or approveresult=4) and 
						ld_approvelog.approved_by=\''.$current_user->id.'\'  and stepid > 0 ';
            $order_by = 'group by ld_approvelog.crmid order by ld_approvelog.createdtime desc ';

            $page_where = ' and ld_approvelog.approved_by=\''.$current_user->id.'\'';
        }
        //19475: 审批中心>已处理页签：已审批的单据没有显示在序列表中
        //	group by ld_approvelog.crmid,approveby
        $groupby=" group by ld_approvelog.crmid,approveby";
        if($approveresult==1)
        {
            $groupby=" group by ld_approvelog.crmid";
        }
        $query .= $joinstring.' join (
						select max(ld_approvelog.id) as idd,ld_approvelog.crmid,
						setype,approveid,ld_users.last_name 
						from  (
							select id,crmid,approveid,approved_by from ld_approvelog order by id desc
						) as ld_approvelog 
							inner join ld_crmentity 
								on ld_crmentity.crmid=ld_approvelog.crmid 
							left JOIN ld_users 
								on ld_users.id=ld_approvelog.approved_by 
						where ld_approvelog.id > 0 '.$page_where.' and ('.$setwhere.') '.
            $groupby.' ) as t on ld_approvelog.id=t.idd ';
        $query .= $joinstring.' join ('.$sqlunion.') as t1 on t1.crmid = '.$jointab.'.crmid ';

        $query .= 'left join ld_approvestep on ld_approvestep.id=ld_approvelog.nextstepid 
  
					left join ld_approvestep as la on la.id=ld_approvelog.stepid 
					left join ld_approve on ld_approve.id=ld_approvelog.approveid ';

        $query.=' left join ld_users as t4 on t4.id=ld_approvelog.approved_by ';//审批人

        $query.=' left join (select ld_approvelog.approved_by,ld_approvelog.crmid from ld_approvelog inner join 
                    (
                    select min(id) as sponsorid from ld_approvelog group by crmid)
                    as tmp_approvesponsor on tmp_approvesponsor.sponsorid=ld_approvelog.id)
                    as tmp_approvesponsor on tmp_approvesponsor.crmid=ld_approvelog.crmid
                    left join ld_users as user_sponsor on user_sponsor.id=tmp_approvesponsor.approved_by';//发起人

        $query.='  left join ld_users  as t5 on t5.id=t1.smownerid ';//负责人
        $query .= $where;

        if(!empty($searchquery)) $query .= ' and ('.$searchquery.') ';
        $query .= $order_by;
        return $query;
    }

    /**
     * 获取审批流程是否允许编辑、以及是否允许反审批单据单据
     * @author Liver 2017-02-07
     */
    public function getApproveAllowediting($record){
        global $adb,$current_user;
        $ApproveControl=array();
        $sql='select  ld_approve.allowantiapproval,nextstepapproveby,nextstepid,logconcurrentid from ld_approvelog
        inner JOIN ld_approve on ld_approvelog.approveid=ld_approve.id
        where crmid= ? order by ld_approvelog.id desc ,ld_approvelog.createdtime desc LIMIT 1;';
        $result=$adb->pquery($sql,array($record));
        if($adb->num_rows($result) > 0){
            $nextstepid=$adb->query_result($result,0,'nextstepid');
            $nextstepapproveby=$adb->query_result($result,0,'nextstepapproveby');
            $logconcurrentid=$adb->query_result($result,0,'logconcurrentid');
            $allowediting=0;
            if(!empty($nextstepid)&&!empty($nextstepapproveby))
            {
                //zkt 20231124 BUG0076116  实施立项申请，设置李国宾在审批允许编辑单据，但是审批时没有编辑按钮 —— 并发审批需要获取当前用户所在的审批步骤
                if(!empty($logconcurrentid)){
                    $tmpsql='select  ld_approve.allowantiapproval,nextstepapproveby,nextstepid,logconcurrentid from ld_approvelog
					inner JOIN ld_approve on ld_approvelog.approveid=ld_approve.id
					where crmid= ? and logconcurrentid = ? and isfinished = "no" and find_in_set(?,nextstepapproveby)  order by ld_approvelog.id desc ,ld_approvelog.createdtime desc LIMIT 1;';
                    $tmpresult=$adb->pquery($tmpsql,array($record,$logconcurrentid,$current_user->id));
                    if($adb->num_rows($tmpresult) > 0) {
                        $nextstepid = $adb->query_result($tmpresult, 0, 'nextstepid');
                        $nextstepapproveby = $adb->query_result($tmpresult, 0, 'nextstepapproveby');
                    }
                }
                $sql='select alloweditbill from ld_approvestep where id=?';
                $stepresult=$adb->pquery($sql,array($nextstepid));
                $alloweditingbill=$adb->query_result($stepresult,0,0);
                $nextstepapprovebys=explode(",",$nextstepapproveby);
                // echo $alloweditingbill;
                //  exit();
                if($alloweditingbill=='yes'&&in_array($current_user->id,$nextstepapprovebys))
                {
                    $allowediting=1;
                }

            }
            $ApproveControl=array('allowediting'=>$allowediting,
                'allowantiapproval'=>$adb->query_result($result,0,'allowantiapproval')
            );
            return $ApproveControl;

        }
        return  $ApproveControl=array(
            'allowediting'=>0,
            'allowantiapproval'=>1
        );
    }
    //判断当前是否处于审批中，并且当前用户是否是当前步骤的审批人
    public function getCurApproveForModulefield($record){
        global $current_user;
        if(is_array($this->approvemodule_field_notempty_arr)&&array_key_exists($record,$this->approvemodule_field_notempty_arr))
        {
            return $this->approvemodule_field_notempty_arr[$record];

        }

        $module=getTabname($record);
        $approveinfo=$this->approveStatus($record);//获取单据的最后一条审批历史记录
        $module_field_array =[];//edit:can 2020-12-03 043563: （https://61mis.com/kfbcrm [^]）客户问题（邬丹华），审批步骤中的“是否允许编辑单据”参数设置为否时，审批人（项目立项：PROJ12 ）仍可以编辑单据（需要补丁）
        if(empty($approveinfo)){
            return $module_field_array;
        }
        $stepid=$approveinfo['nextstepid'];
        $nextstepapproveby=$approveinfo['nextstepapproveby'];
        $approvestepinfo=$this->getStepInfo($stepid);//审批步骤信息

        if((!empty($_REQUEST['cur_module_step']) && $_REQUEST['cur_module_step'] > 0) || $_REQUEST['isApproveMandatoryField'] == 'yes'){
            /*
            $module_field = $approvestepinfo['module_field'];
            if(!empty($module_field))//edit:can 2020-12-03 043563: （https://61mis.com/kfbcrm [^]）客户问题（邬丹华），审批步骤中的“是否允许编辑单据”参数设置为否时，审批人（项目立项：PROJ12 ）仍可以编辑单据（需要补丁）
                $module_field_array = explode(',',$module_field);
            */
            $approvestatus = 1;
            $approveMandatoryFieldData = ldcrm_json_decode($_REQUEST['approveMandatoryFieldData']);
            if(!empty($approveMandatoryFieldData) && !empty($approveMandatoryFieldData['approvestatus'])){
                $approvestatus = $approveMandatoryFieldData['approvestatus'];
            }
            crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
            $mandafieldobj = cls_ApproveMandatoryField::getInstance($this->approveobj->module);
            //duan 20240124 因为没办法判断目前需要是读通过还是不通过的必填字段,先只读取通过的字段
            $mandatoryfield_arr = $mandafieldobj->getMandatoryFieldByApprovesult($stepid,$approvestatus);
            $module_field_array = $mandatoryfield_arr;
            /*
            foreach ($mandatoryfield_arr as $tmp_arr){
                $module_field_array[] = $tmp_arr['mandatoryfield'];
            }
            */
        }

        if(!empty($nextstepapproveby)){
            $stepapproveby = explode(',',$nextstepapproveby);
            foreach($stepapproveby as $userid){
                if($userid == $current_user->id){
                    if(!empty($module_field))//edit:can 2020-12-03 043563: （https://61mis.com/kfbcrm [^]）客户问题（邬丹华），审批步骤中的“是否允许编辑单据”参数设置为否时，审批人（项目立项：PROJ12 ）仍可以编辑单据（需要补丁）
                        $module_field_array = explode(',',$module_field);
                    break;
                }
            }
        }
        $this->approvemodule_field_notempty_arr[$record]=$module_field_array;
        return $module_field_array;
    }
    //当审批人为空需要转交时，获取转交的用户id
    public function getTransferUsers($emptyapproverdeal){
        global $adb;
        $nextstepapproveby = '';
        if(empty($emptyapproverdeal)){//默认参数为转交管理员
            $emptyapproverdeal = 'transfertomanager';
        }
        if($emptyapproverdeal == 'autopass'){//审批人为空，自动通过,放到自动跳过里处理
        }else if($emptyapproverdeal == 'transfertomanager'){//审批人为空，自动转交管理员
            //获取所有管理员id
            $tmp_sql = "SELECT GROUP_CONCAT(id) as uservalue from ld_users where is_admin = 'on' and status = 'Active' GROUP BY is_admin ORDER BY id;";
            $tmp_result = $adb->pquery($tmp_sql,array());
            if($adb->num_rows($tmp_result)){
                $nextstepapproveby = $adb->query_result($tmp_result,0,'uservalue');
            }else{
                $nextstepapproveby = 1;
            }
        }else{//审批人为空，自动转交制定用户
            $userid_arr = explode(',',trim($emptyapproverdeal,','));
            if(sizeof($userid_arr)<=0 || $userid_arr[0] == ''){
                $choosedusers = 0;//异常值处理
            }else{
                $choosedusers = implode(',',$userid_arr);
            }
            //获取未离职的选中的成员id
            $tmp_sql = "SELECT GROUP_CONCAT(id) as uservalue from ld_users where status = 'Active' and id in ($choosedusers) ORDER BY id;";
            $tmp_result = $adb->pquery($tmp_sql,array());
            if($adb->num_rows($tmp_result)>0){
                $nextstepapproveby = $adb->query_result($tmp_result,0,'uservalue');
            }else{
                $nextstepapproveby = 1;//如果出现指定成员离职等情况，归到超级管理员名下
            }
        }
        return $nextstepapproveby;
    }
    /**
     * 审批不同返回上一步的获取，反审批 回撤到上一步
     * */
    public function getBackStepLogIndex($result)
    {   
        global $adb;
        $num_rows=$adb->num_rows($result);

        if($num_rows > 0){
            $backstep_count=0;//回撤的次数
            $tmprowindex=0;
            $pre_stepid = 0;
            $pre_nextstepid = 0;
            $pre_approveresult = [];
            $tmp_logconcurrentid = 0;
            //duan 20230920 如果反审批选中的审批日志，还是反审批的日志，就继续循环
            $tmp_index = 0;
            do{
                $id = $adb->query_result($result,$tmp_index,'id');
                $stepid = $adb->query_result($result,$tmp_index,'stepid');
                $nextstepid = $adb->query_result($result,$tmp_index,'nextstepid');
                $approveresult = $adb->query_result($result,$tmp_index,'approveresult');
                $logconcurrentid = $adb->query_result($result,$tmp_index,'logconcurrentid');
                if($stepid=='-1')
                {
                    $tmprowindex=$tmp_index;
                    break;
                }
                if($stepid==-2||$approveresult==5)
                {
                    $tmprowindex+=2;
                }else if($logconcurrentid > 0){
                    $approveresult = explode(',',$approveresult);
                    $stepid = explode(',',$stepid);

                    if(in_array(12,$approveresult) && !in_array($pre_nextstepid,$stepid)){//反审批并发步骤相比普通的反审批，会多插入并发步骤的若干行，因为group_by了，所以只有一行，加上这一行
                        $tmprowindex ++;
                    }

                    if(in_array($pre_stepid,$stepid) && !in_array(5,$pre_approveresult)){//判断是否是这一并发步骤所推进过去的
                        $tmprowindex ++;
                        $pre_stepid = 0;
                    }
                }else{
                    $pre_stepid = $stepid;//记住 步骤推进行 stepid
                    
                }
                $tmp_index ++;
                if($tmprowindex>=$num_rows)
                {
                    break;
                }
                $pre_nextstepid = $nextstepid;
                $pre_approveresult = $approveresult;
                $tmp_logconcurrentid = $logconcurrentid;

            }while($tmp_index <= $tmprowindex);
        }

        if($tmprowindex>=$num_rows)
        {
            $tmprowindex=$num_rows-1;
        }
        
        return $tmprowindex;
    }
    /**
     * edit:kevin
     * date:2013-09-09
     * reason:当前用户是否有编辑,提交,审批
     */
    function blocksButton($smownerid,$record,$module=""){
        global $current_user,$adb,$currentModule;
        if(empty($module))
            $module = getSalesEntityType($record);
        $static_setype=$module;
        if($module=='ServiceCharge')
        {
            //21350: 服务收费管理>明细：提交审批，审批后，查看该服务收费管理，结果：又显示了【提交审批】按钮
            $static_setype='Accounts';
        }
        $deployarray=getSys_Approvedeploy($static_setype);
        $deploy_value = $deployarray['deploy_value'];
        if($deploy_value!=0)
        {
            //如果模块没有开启审批参数
            $isedit = 0;
            $issubmit=0;
            $isapprove=0;
            $isdelete=0;
            $approvestatus='';
            return array($isedit,$issubmit,$isapprove,$isdelete,$approvestatus);
        }
        $approveinfo=$this->approveStatus($record);
        $ApproveAllowediting=$this->getApproveAllowediting($record);//Liver 20170208获取审批流程是否允许编辑、反审批,1允许，0不允许
        $approvestatus=$approveinfo['approvestatus'];

        //提交，审批按钮值为1显示，编辑，删除按钮值为0显示
        $issubmit=0;
        $isapprove=0;
        $isedit=0;
        $isdelete=0;
        //不允许编辑的审批结果
        $noedit_approvestatus_arr = array(1,5,10,6,12,14,15,16,17,18);
        if((in_array($approvestatus,$noedit_approvestatus_arr)) && !empty($approveinfo)){
            $isedit=1;
            if($approvestatus!=3)
                $isdelete=1;
        }
        /**
         * 判断审批状态不为已批准、审批中、已拒绝，则显示提交审批按钮
         * @reason 0014154: 业务判断逻辑改进：提交审批和审批状态判断逻辑
         * @author Tujt 2015-03-28
         */
        if($module=='ServiceCharge')
        {
            //21350: 服务收费管理>明细：提交审批，审批后，查看该服务收费管理，结果：又显示了【提交审批】按钮
            $static_setype='Accounts';
        }
        $focus=CRMEntity::getInstance($static_setype);
        if(empty($focus->column_fields['approvestatus']))
        {
            //如果是批量处理的操作，请在调用该函数之前重新给$focus->column_fields['approvestatus'])赋值
            $sql="select approvestatus from ".$focus->table_name.' where '.$focus->table_index."=?";
            $result=$adb->pquery($sql,array($record));
            if($adb->num_rows($result)>0)
                $focus->column_fields['approvestatus']=$adb->query_result($result,0,'approvestatus');
        }
        $this->approveobj->recordApprovestatus[$record]=    $focus->column_fields['approvestatus'];
        $statusarray = array(
            constant('D_A_S_APPROVED')=>'1',//已批准
            constant('D_A_S_APPROVALOF')=>'1',//审批中
            constant('D_A_S_REJECTED')=>'1'//已拒绝
        );
        $approvestatusarr = array(
            '1'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '2'=>constant('D_A_S_APPROVED'),//'已批准',
            '3'=>constant('D_A_S_REJECTED'),//'已拒绝',
            '4'=>constant('D_A_S_DISMISSED'),//'已驳回'
            '5'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '6'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '14'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '15'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '16'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '17'=>constant('D_A_S_APPROVALOF'),//'审批中',
            '18'=>constant('D_A_S_APPROVALOF'),//'审批中',
        );
        ////没有审批历史
        if(empty($approveinfo)){
            if(isset($focus->column_fields['approvestatus']) &&
                !empty($focus->column_fields['approvestatus'])){
                $approvestatus = $focus->column_fields['approvestatus'];
                if($statusarray[$approvestatus]){
                    $isdelete = 1;//没有删除权限
                }else{
                    $issubmit = 1;
                }
            }
        }else{

            if(isset($approveinfo['approvestatus'])){
                if(!isset($approvestatusarr[$approveinfo['approvestatus']])){

                    $issubmit = 1;
                }
            }else{//依然保留之前的提交审批判断
                $submitarr = array('0'=>'1','4'=>'1');
                if(empty($approveinfo) || isset($submitarr[$approvestatus])){
                    $issubmit = 1;
                }
            }
        }

        $nextstepid=$approveinfo['nextstepid'];
        $iseditstatus = 0;

        if(!empty($approveinfo)){
            $nextstepapproveby=$approveinfo['nextstepapproveby'];
            $nextstepid=$approveinfo['nextstepid'];
            if($approveinfo['approvestatus']==10)
            {
                $issubmit=0;//说明提交审批过
            }
            /**
             * 如果$nextstepid为空，则不允许审批、编辑
             * @reason 0013097: 已审批通过的合同订单/销售机会仍可以编辑保存
             * @author Tujt 2014-12-23
             */
            if(empty($nextstepid)){
                if(4 == $approvestatus) {//已驳回
                    $isapprove = 0;//不允许审批
                    $isedit = 0;//允许编辑
                    $issubmit = 1;//可以提交审批
                }elseif(13 == $approvestatus){//已批准/已拒绝的单据编辑后审批状态为“未提交"，approveresult为13
                    //ls 2021-11-26 【1002260】审批流程定制，审批结束重复提交审批时功能优化（保存时提示并更改审批状态）
                    $isapprove=0;//不允许审批
                    $isedit = 0;//允许编辑
                    $issubmit = 1;//允许提交审批
                }else{//审批通过
                    $isapprove=0;
                    $isedit=1;
                    $issubmit=0;
                }
            }else{
                if(substr($nextstepapproveby, 0, 1 )=='H')
                    $approveby = getUserIdRole($nextstepapproveby);
                else
                    $approveby=explode(',',$nextstepapproveby);
                $curapproveformodulefield=$this->getCurApproveForModulefield($record);//判断当前是否处于审批中，并且当前用户是否是当前步骤的审批人
                foreach($approveby as $userid){
                    if($userid==$current_user->id){
                        $isapprove=1;
                        $issubmit=0;
                        //当前审批人审批时进入编辑界面，审批流程中设置的有审批人必填字段，则允许编辑

                        if($ApproveAllowediting['allowediting']==1 || !empty($curapproveformodulefield)) $isedit=0;//$ApproveAllowediting['allowediting']==1表示审批流程允许编辑单据
                        break;
                    }
                }
            }
        }
        if($approvestatus==2 || $approvestatus==3||$focus->column_fields['approvestatus']==$approvestatusarr['2'])
        {

            //审批完成的单据
            $profile = Profile::getInstance();
            $profileinfo=$profile->getProfileAction_Used($current_user->profileid);
            if($profileinfo[$tabid]['EditView']!=0)
            {
                $isedit=1;

            }
            $sql='select finishedallowedit,finishedfield_allocatetype,finishedfield_allocateid from ld_approve
            inner join (select approveid from ld_approvelog  where crmid =? order by createdtime desc ,id desc limit 1) 
            as tmp on tmp.approveid=ld_approve.id ';
            $result=$adb->pquery($sql,array($record));
            if($adb->num_rows($result)>0)
            {
                $finishedallowedit=$adb->query_result($result,0,'finishedallowedit');
                $finishedfield_allocatetype=$adb->query_result($result,0,'finishedfield_allocatetype');
                $finishedfield_allocateid=trim(trim((string)$adb->query_result($result,0,'finishedfield_allocateid')),',');
                if($finishedallowedit=='yes')
                {
                    if($finishedfield_allocatetype=='all')
                        $isedit=0;
                    else if(!empty($finishedfield_allocateid))
                    {
                        if($finishedfield_allocatetype=='group')
                            $sql=' select * from ld_users2group where userid=? and  groupid in( '.$finishedfield_allocateid.') ';
                        else if($finishedfield_allocatetype=='user')//duan 49889:审批结束后可编辑单据按成员适用范围没生效
                            $sql='select 1 from ld_users where id=? and id in ( '.$finishedfield_allocateid.') ';
                        else if($finishedfield_allocatetype=='role')
                            $sql='select 1 from ld_users where id=? and profileid in ( '.$finishedfield_allocateid.') ';
                        $result =$adb->pquery($sql,array($current_user->id));
                        if($adb->num_rows($result)>0)
                            $isedit=0;
                        else
                            $isedit=1;

                    }

                }
            }

            //ls 2021-11-17 【1002212】审批流程定制增加允许重复提交审批（徐昱轩）(已批准、已拒绝的单据显示“提交审批”按钮)
            crm_load_class_file('cls_ApproveCache','modules/Approve');
            if (cls_ApproveCache::recordAgainSubmit($module)) {
                $issubmit = 1;
            }
        }
        return array($isedit,$issubmit,$isapprove,$isdelete,$approvestatus);
    }
    public function getAllApprovesByUserid($tabid,$userid){
        global $adb,$current_user,$weixin_user;
        $checksql='SELECT groupid FROM ld_users2group  WHERE userid in(?)';
        $checkresult=$adb->pquery($checksql,array($userid));
        $groupid=array();
        for($i=0;$i<$adb->num_rows($checkresult);$i++)
        {
            $groupid[]=$adb->query_result($checkresult,$i,'groupid');
        }
        $sql='select profileid from ld_users where id=? ';
        $result=$adb->pquery($sql,array($userid));

        $profileid=$adb->query_result($result,0,0);

        if($tabid == 16) $tabid= 9;
        $groupids=implode(",",$groupid); //求出当前用户所在的部门ID。
        //editor:gyq_132 reason:审批流程默认值改进,增加default_on_new  2019/7/22 18:40 ID1000479
        $sql ="SELECT  distinct id,`name`,default_on_new,default_on_submit,showsubmitremark,submitremarkrequire,showurgent,enableexpediting,finishedallowedit,allowagainsubmit,isnewapprove,sequence
         FROM
            (
          select 
                ld_approve.tabid,
                ld_approve.id,
                ld_approve.`name`,
                ld_approve.createdtime,               
                ld_approve.default_on_new ,              
                ld_approve.default_on_submit,
                ld_approve.showsubmitremark,
                ld_approve.submitremarkrequire,
                ld_approve.showurgent,
                ld_approve.enableexpediting,
                ld_approve.finishedallowedit,               
                ld_approve.allowagainsubmit,
                ld_approve.isnewapprove,
                ld_approve.sequence
      	  from ld_approve where approveallocatetype=0 AND ld_approve.status=0

      	  UNION
          select  
              ld_approve.tabid,
              ld_approve.id,
              ld_approve.`name` ,
              ld_approve.createdtime,
            ld_approve.default_on_new ,              
            ld_approve.default_on_submit,
            ld_approve.showsubmitremark,
            ld_approve.submitremarkrequire,
            ld_approve.showurgent,
            ld_approve.enableexpediting,
            ld_approve.finishedallowedit,
            ld_approve.allowagainsubmit,
            ld_approve.isnewapprove,
            ld_approve.sequence
    	  from ld_approve2user
   		  inner JOIN ld_users on ld_users.id=ld_approve2user.userid

          inner JOIN ld_approve 
       		    on ld_approve.id=ld_approve2user.approveid  
           where approveallocatetype=2  and ld_approve2user.userid=$userid AND ld_approve.status=0
           GROUP BY  ld_approve2user.approveid
           union   select  
                          ld_approve.tabid,
                      	  ld_approve.id,
                          ld_approve.`name`,
                          ld_approve.createdtime,
                        ld_approve.default_on_new ,              
                        ld_approve.default_on_submit,
                        ld_approve.showsubmitremark,
                        ld_approve.submitremarkrequire,                                   
                        ld_approve.showurgent,
                        ld_approve.enableexpediting,
                        ld_approve.finishedallowedit,                                    
                        ld_approve.allowagainsubmit,
                        ld_approve.isnewapprove,
                        ld_approve.sequence
              		   from ld_approve2user 
              		   inner JOIN ld_profile on ld_profile.profileid=ld_approve2user.userid inner JOIN ld_approve 
          		       on ld_approve.id=ld_approve2user.approveid 
                       where approveallocatetype=3 and ld_profile.profileid =$profileid  AND ld_approve.status=0
                       GROUP BY  ld_approve2user.approveid ";
        if(sizeof($groupid)>0)
        {
            $sql.="UNION
                       select  
                          ld_approve.tabid,
                      	  ld_approve.id,
                          ld_approve.`name`,
                          ld_approve.createdtime,
                        ld_approve.default_on_new ,              
                        ld_approve.default_on_submit,
                        ld_approve.showsubmitremark,
                        ld_approve.submitremarkrequire,                                  
                        ld_approve.showurgent,
                        ld_approve.enableexpediting,
                        ld_approve.finishedallowedit,                                  
                        ld_approve.allowagainsubmit,
                        ld_approve.isnewapprove, 
                        ld_approve.sequence                                 
              		   from ld_approve2user 
              		   inner JOIN ld_groups on ld_groups.groupid=ld_approve2user.userid inner JOIN ld_approve 
          		       on ld_approve.id=ld_approve2user.approveid 
                       where approveallocatetype=1 and ld_groups.groupid in($groupids)  AND ld_approve.status=0
                       GROUP BY  ld_approve2user.approveid
                    )  AS alldata where tabid=?
                    order by alldata.createdtime ";
        }
        else
        {
            $sql.=" ) as alldata  where tabid=? order by  alldata.sequence,alldata.createdtime  ";
        }

        /*
         * editor:gyq_05
         * reason:修改SQL剔除无审批步骤的流程
         * date  : 2016 3 1
         * */
        $sql = 'SELECT sta.id,sta.name,sta.default_on_new,sta.default_on_submit,sta.showsubmitremark,sta.submitremarkrequire,sta.showurgent,sta.enableexpediting,sta.finishedallowedit,sta.allowagainsubmit,sta.isnewapprove from ( '.$sql.' ) as sta INNER JOIN ld_approvestep on ld_approvestep.approveid = sta.id GROUP BY sta.id ORDER BY sta.sequence';

        $result=$adb->pquery($sql,array($tabid));
        $num_rows = $adb->num_rows($result);
        $approveid_arr = array();

        $approve=array();
        if($num_rows > 0){
            //if($weixin_user->action=='default_on_new' || $weixin_user->action=='default_on_submit'){
            $pc_selected_cell = array();
            $pc_selected_i = 0;
            for($i=0;$i<$num_rows;$i++){
                $default_on = $adb->query_result($result,$i,$weixin_user->action);
                $approveid = $adb->query_result($result,$i,'id');
                $approveid_arr[$i] = $approveid;
                $select = '';

                if($default_on=='yes' ){
                    $select = 'selected';
                }

                $submitremark = array(
                    'display'=>$adb->query_result($result,$i,'showsubmitremark'),//提交意见字段是否显示
                    'require'=>$adb->query_result($result,$i,'submitremarkrequire')//提交意见是否必填
                );
                $cell_approve = array(
                    'approveid'=>$approveid,
                    'approvename'=>$adb->query_result($result,$i,'name'),
                    'selected'=>$select,
                    'submitremark'=>$submitremark,//提交意见显示格式
                    'showurgent'=>$adb->query_result($result,$i,'showurgent'), //提交审批是否显示需要加急审批
                    'enableexpediting'=>$adb->query_result($result,$i,'enableexpediting'), //“是否启用催审功能”
                    'finishedallowedit'=>$adb->query_result($result,$i,'finishedallowedit'), //审批结束是否允许编辑单据
                    'allowagainsubmit'=>$adb->query_result($result,$i,'allowagainsubmit'), //审批结束编辑单据保存，自动提交审批时默认审批流程
                    'isnewapprove'=>$adb->query_result($result,$i,'isnewapprove'),
                    'isdefaultapprove'=>$default_on,
                );
                if($weixin_user->action=='default_on_submit'&&!$weixin_user->environment_weixin && $default_on=='yes'){
                    $pc_selected_cell = $cell_approve;
                    $pc_selected_i = $i;
                }
                $approve[$i]=$cell_approve;
            }
            //将选中的流程排到第一位，方便PC端显示
            if(!empty($pc_selected_cell)){
                unset($approve[$pc_selected_i]);
                array_unshift($approve,$pc_selected_cell);
            }
            /* }else{
                 for($i=0;$i<$num_rows;$i++){
                     $approve[]=array
                     (
                         'approveid'=>$adb->query_result($result,$i,'id'),
                         'approvename'=>$adb->query_result($result,$i,'name'),
                         'showsubmitremark'=>$adb->query_result($result,$i,'showsubmitremark'),
                         'submitremarkrequire'=>$adb->query_result($result,$i,'submitremarkrequire')
                     );
                 }
             }*/
        }



        if(!empty($approve)) return $approve;
        return '';
    }
    //获取审批流程信息
    public function getApproveInfo($approveid){
        global $adb;
        if(!empty($this->module)){
            $module = $this->module;
        }else{
            $sql = "select tabid from ld_approve where id = ?";
            $result = $adb->pquery($sql,array($approveid));
            if($adb->num_rows($result)>0){
                $tabid = $adb->query_result($result,0,'tabid');
                $module = getTabname($tabid);
                $this->module = $module;
            }else{
                return array();
            }
        }
        //将当前模块所有审批流程的筛选条件存下来，避免重复读取
        if(is_array($this->approvecondition_arr)&&isset($this->approvecondition_arr[$approveid])){
            return $this->approvecondition_arr[$approveid];
        }else{
            //获取当前模块所有审批流程的信息
            $sql = "select id,dataadv,dataadvgroup,isnewapprove,editresetapprove,finishedallowedit from ld_approve where tabid = ?";
            $tabid = getTabid($module);
            if($tabid == 16)$tabid = 9;
            $result = $adb->pquery($sql,array($tabid));
            $num_rows = $adb->num_rows($result);
            for($i=0;$i<$num_rows;$i++){
                $tmp_approveid = $adb->query_result($result,$i,'id');
                $tmp_dataadv = $adb->query_result($result,$i,'dataadv');
                $dataadvgroup = $adb->query_result($result,$i,'dataadvgroup');
                $tmp_dataadv = $tmp_dataadv ?? '';
                $dataadvgroup = $dataadvgroup ?? '';
                $dataadv = html_entity_decode($tmp_dataadv);//高级查询条件组
                $dataadvgroup = html_entity_decode($dataadvgroup);//高级查询组间关系
                $editresetapprove = $adb->query_result($result,$i,'editresetapprove');
                $finishedallowedit = $adb->query_result($result,$i,'finishedallowedit');
                $isnewapprove = $adb->query_result($result,$i,'isnewapprove');//判断是否为新审批流程
                $tmp_approveinfo = array('advft_criteria'=>$dataadv,
                    'advft_criteria_groups'=>$dataadvgroup,
                    'isnewapprove'=>$isnewapprove,
                    'editresetapprove'=>$editresetapprove,
                    'finishedallowedit'=>$finishedallowedit);
                $this->approvecondition_arr[$tmp_approveid]=$tmp_approveinfo;
            }
            return $this->approvecondition_arr[$approveid];
        }
    }
    /**
     * 判断当前步骤是否加签yes:已加签
     * $approvelogid:审批日志表主键值（可以为空)
     * $nextstepid:当前审批步骤ID(审批日志的表最后一条记录的nextstepID字段的值)
     * */
    public function getIsaugmentsinger($approveresult,$approvelogid,$crmid,$nextstepid,$stepid)
    {
        global $adb;
        //chj 2021/8/31 中孚：加签后，下一步本来是或签的，现在变成会签了
        if($approveresult==6 && $nextstepid == $stepid)
        {
            return 'yes';//加签
        }
        if($stepid == -2||$stepid == -1||$approveresult==5){
            return 'no';
        }
        if(!empty($approvelogid))
        {

        }
        else{
            $sql='select * from ld_approvelog where crmid=?  order by id desc  limit 1';
            $result=$adb->pquery($sql,array($crmid));
            $approvelogid=$adb->query_result($result,0,'id');
        }
        $sql='select approveresult,stepid,approveid from ld_approvelog where crmid=? and id<? order by id desc ';
        $result= $adb->pquery($sql,array($crmid,$approvelogid));

        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++){
            $tmp_stepid=$adb->query_result($result,$i,'stepid');
            $tmp_approveresult=$adb->query_result($result,$i,'approveresult');
            //找到提交审批步骤则不继续判断
            if($tmp_stepid == -1){
                return 'no';
            }
            if($tmp_stepid!=$nextstepid || $tmp_approveresult==4)	//chj 提交审批第一步加签后，加签人驳回返回负责人，这个时候再次提交审批后，第一步审批人无法进行加签了 ($tmp_approveresult==4)
            {

                return 'no';
            }
            else if($tmp_approveresult==6||$tmp_approveresult=="6"){
                return 'yes';
            }
        }
        return 'no';
    }
    //判断设置的审批人必填字段是否已填写
    public function getModuleRecordStatus($module_field,$record,$module,$environment){
        global $adb,$current_user;
        $status = 'yes';
        if(!empty($module_field) && !empty($record)){
            $focus = CRMEntity::getInstance($module);
            $focus->id = $record;
            $focus->retrieve_entity_info($record, $module);
            if($module=='Accounts')
            {
                crm_load_class_file('Detail_Edit_View','include/utils');
                Detail_Edit_View::getAccountPrimaryContactInfo($focus);
            }

            $fieldobj=Field::getInstance($module,$adb);
            $moduleFields=$fieldobj->getModuleFields();
            $module_fields_array = explode(',',$module_field);
            
            //审批必填 布局规则
            global $global_block_columnvalue;
            $blocks= getBlocks($module,"detail_view",'',$focus->column_fields);
           
            foreach($blocks as $blockname => $fieldarray){
                foreach($fieldarray as $b_fields){
                    foreach($b_fields as $fieldinfo){
                        $fldname = $fieldinfo['fldname'];
                        $value = $fieldinfo['value'];
                        $rawvalue = $fieldinfo['rawvalue'];
                        $all_module_field[$fldname] = array('value'=>$value,'rawvalue'=>$rawvalue);
                    }
                }
            }

            //非管理员  控制只读字段不在模块的新增和编辑时显示
            if($current_user->is_admin=='off'){
                $profileobj=Profile::getInstance();
                $profilefields= $profileobj->getProfileInfos($current_user->profileid);
                $profilefields=$profilefields['field'];
            }
            $fldtypearr = Field::getFieldUitypeType($adb);

            //主表字段布局规则
            $fieldruleobj=cls_fieldrule::getInstance($module);
             
            $fieldruleobj->setColumnValues($global_block_columnvalue);
            $fieldrulecolsproperty= $fieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项

            //布局规则重新设置界面显示
            $hidecolumns=$fieldrulecolsproperty['hidecolumns'];//隐藏的字段
           
            $hidecolslen=sizeof($hidecolumns);
            foreach($moduleFields as $fieldname => $fieldinfo){
                $fieldid = $fieldinfo->getFieldid();
                $typeofdata = $fieldinfo->getTypeOfData();
                $columnname=$fieldinfo->getColumnName();
                $uitype=$fieldinfo->getUIType();
                if($fieldinfo->getFieldDataType()=='mobile')
                {
                    if(fieldValueUitype::IsShowMobileTextBox($_REQUEST['record'],$module)=='no')
                    {
                        continue;
                    }
                }
                //只读权限的字段在新增、编辑时，不显示
                if( !empty($profilefields) && $profilefields[$fieldid]['readonly']==1){
                    continue;
                }
                //布局规则
                if(!empty($hidecolumns) && in_array($columnname,$hidecolumns)){
                    continue;
                }
                //移动端无法编辑富文本框，先去掉
                if($environment == 'mobile' && in_array($uitype,[230,231])){
                    continue;
                }

                if(in_array($fieldname,$module_fields_array)){
                    $typeofdatas = explode('~',$typeofdata);
                    //edit:can 20210726 0047119: （http://maarscrm.xicp.vip:38060/crm [^]）客户问题（邬丹华），工程管理->项目交底（单据号：MAARS23-450）提交审批使用（DDD）审批流程审批时，没有提示审批人必填字段提示信息
                    if(isset($fldtypearr[$uitype]) && constant('REFERENCE_FIELD') == $fldtypearr[$uitype]['fieldtype'] ||$uitype==79||$uitype==153){
                        if($all_module_field[$fieldname]['rawvalue'] <= 0){
                            $status = 'no';

                            break;
                        }
                    }
                    if($uitype==202)
                    {
                        $rawvalue=$all_module_field[$fieldname]['rawvalue'];
                        if(empty($rawvalue))
                        {
                            //edit:can 20210726 047000: （https://81mis.com/kfbcrm/ [^]）合同编号：SO157，“合同订单”的审批流程名称“最新测试使用”，步骤名称：“第一步”设置了审批必填字段“选择源单”，但审批人审批时没有填写“选择源单”字段也能审批成功。
                            $status = 'no';

                            break;
                        }
                    }
                    if($all_module_field[$fieldname]['value'] == '' && $all_module_field[$fieldname]['rawvalue'] == ''){
                        $status = 'no';
                        //echo $fieldname;echo '<br><br>';
                        break;
                    }
                }
            }
        }
        //die;
        return $status;
    }
    //判断当前步骤是否是第一步审批。判断是否显示：不通过，返回负责人 选项
    public function getApprovePreStepApproveBy($record){
        global $adb;
        $query = 'select nextstepid,approveid from ld_approvelog where crmid = ?  and approved_by>0 ORDER BY createdtime desc,id desc limit 1';
        $result = $adb->pquery($query,array($record));
        $num_rows = $adb->num_rows($result);
        $last = 0;
        if($num_rows){
            $nextstepid = $adb->query_result($result,0,'nextstepid');
            $approveid = $adb->query_result($result,0,'approveid');
            $query = 'select 1 from ld_approvestep INNER JOIN ld_approvelog  on ld_approvelog.stepid=ld_approvestep.id
                 where ld_approvestep.sequence < (select sequence from ld_approvestep where id = ? and approveid = ?)
                 and ld_approvelog.crmid=? and  ld_approvelog.approveid=? and approved_by>0';
            $result = $adb->pquery($query,array($nextstepid,$approveid,$record,$approveid));
            $last = $adb->num_rows($result);
        }
        return $last;
    }
    /**
     * 获取审批流程下的所有审批步骤信息，按照sequence asc
     * edit:can 2020-12-10
     * */
    public function getAllStepInfoByApproveid($approveid)
    {
        global $approvestepinfo_arr;
        global $adb;
        if(is_array($approvestepinfo_arr)&&array_key_exists($approveid,$approvestepinfo_arr))
        {
            return $approvestepinfo_arr[$approveid];
        }
        $sql='select * from ld_approvestep where approveid=? order by sequence asc  ';
        $tmpresult=$adb->pquery($sql,array($approveid));
        $tmprows=$adb->num_rows($tmpresult);
        for($tmpi=0;$tmpi<$tmprows;$tmpi++)
        {
            $approvestepinfo_arr[$approveid][]=array('sequence'=>$adb->query_result($tmpresult,$tmpi,'sequence')
                ,'stepid'=>$adb->query_result($tmpresult,$tmpi,'id')
                ,'concurrentid'=>$adb->query_result($tmpresult,$tmpi,'concurrentid')
                ,'approvetype'=>$adb->query_result($tmpresult,$tmpi,'approvetype')
                ,'approvevalue'=>$adb->query_result($tmpresult,$tmpi,'approvevalue')
                ,'countersigner'=>$adb->query_result($tmpresult,$tmpi,'countersigner')
                ,'augmentsinger'=>$adb->query_result($tmpresult,$tmpi,'augmentsinger')
                ,'name'=>$adb->query_result($tmpresult,$tmpi,'name')
                ,'emptyapproverdeal'=>$adb->query_result($tmpresult,$tmpi,'emptyapproverdeal')
                ,'approvalauthority'=>ldcrm_json_decode(html_entity_decode($adb->query_result($tmpresult,$tmpi,'approvalauthority')))
            );
        }
        return $approvestepinfo_arr[$approveid];
    }
    function getApproveByInfo($approvetype,$approvevalue,$focus){
        global $adb,$current_user;
        $userids = '';
        $column_fields=$focus->column_fields;
        switch($approvetype){
            case '0':
                $approve_userid=$approvevalue;
                break;
            case '1'://指定角色
                $approve_userid=$approvevalue;
                break;
            case '2'://获取本部门指定职位员工
                $smownercolumnname= $focus->getSmownerColumName();
                $approve_userid=$column_fields[$focus->fieldobj->getFieldInfoBykeyValue("columnname",$smownercolumnname,'fieldname')];
                if(empty($approve_userid))//edit:can 20210617 046373: （81mis.com/kfbcrm）新建单据提交审批问题；模块-联系人，新建联系人时默认显示快速创建字段，这时默认的审批流中审批人为空
                    $approve_userid=$current_user->id;
                break;
            case '3'://获取直属上级部门指定职位
                $smownercolumnname= $focus->getSmownerColumName();
                $approve_userid=$column_fields[$focus->fieldobj->getFieldInfoBykeyValue("columnname",$smownercolumnname,'fieldname')];
                if(empty($approve_userid))//edit:can 20210617 046373: （81mis.com/kfbcrm）新建单据提交审批问题；模块-联系人，新建联系人时默认显示快速创建字段，这时默认的审批流中审批人为空
                    $approve_userid=$current_user->id;
                break;
            case '4'://指定部门的职位
                break;
            case '5'://单据创建人
                $smcreatorcolname=$focus->getCreateColumnName();
                $approve_userid=$column_fields[$focus->fieldobj->getFieldInfoBykeyValue("columnname",$smcreatorcolname,'fieldname')];
                /*
                // 0050701: (http://tuvaustria.gnway.cc/crm/ [^]) 合同订单审批流阶点设定的是“单据创建人”，编辑单据时，当单据创建人和当前用户不是同一个人时，审批人显示错误。
                if (empty($approve_userid) && !empty($column_fields[$focus->table_code])) {
                    $sql='select '.$smcreatorcolname. ' from '.$focus->table_name.' where '.$focus->table_code.'=?';
                    $result=$adb->pquery($sql,array($column_fields[$focus->table_code]));
                    $approve_userid=$adb->query_result($result,0,0);
                }
                */
                //duan 20230315 新建界面获取创建人时，如果出现并发操作，导致编号重复时，获取审批人错误的问题
                if(empty($approve_userid) && !empty($focus->id)){
                    $sql='select '.$smcreatorcolname. ' from '.$focus->table_name.' where '.$focus->table_index.'=?';
                    $result=$adb->pquery($sql,array($focus->id));
                    $approve_userid=$adb->query_result($result,0,0);
                }

                if(empty($approve_userid))//edit:can 20210617 046373: （81mis.com/kfbcrm）新建单据提交审批问题；模块-联系人，新建联系人时默认显示快速创建字段，这时默认的审批流中审批人为空
                    $approve_userid=$current_user->id;
                break;
            case '6'://单据负责人
                $smownercolumnname= $focus->getSmownerColumName();
                $approve_userid=$column_fields[$focus->fieldobj->getFieldInfoBykeyValue("columnname",$smownercolumnname,'fieldname')];
                if(empty($approve_userid))//edit:can 20210617 046373: （81mis.com/kfbcrm）新建单据提交审批问题；模块-联系人，新建联系人时默认显示快速创建字段，这时默认的审批流中审批人为空
                    $approve_userid=$current_user->id;
                break;

        }
        /*
        *edit: chj
        *date: 2020/9/24
        *reason: 单据负责人下面增加列示，当前模块启用的 uitype IN (153,154) 选择用户字段
        */
        if($approvetype > 6){
            //edit:can 20220628 服务工单模块，单据号FWGD-0016，第一步审批找不到审批人，详见单据的审批日志~
            $profieldarr=$focus->fieldobj->FieldInfoListByKeyValue('fieldid',$approvetype);
            $approve_userid=$column_fields[$profieldarr['columnname']];
        }
        return $this->approveobj->getApproveuserinfoByid($approvetype,$approvevalue,$approve_userid);
    }
    /**
     * edit:kevin
     * date:2013-09-10
     * reason:获取审核人ids
     */
    function getApproveBy($approvetype,$approvevalue,$crmid,$emptyapproverdeal=''){
        global $adb,$current_user;
        $userids = '';
        switch($approvetype){
            case '0':
                break;
            case '1'://指定角色
                break;
            case '2'://获取本部门指定职位员工
                $entitytype=getSalesEntityType($crmid);
                $approvemodule_focus=CRMEntity::getInstance($entitytype);
                $sql='select smownerid from '.$approvemodule_focus->table_name.' where '.$approvemodule_focus->table_index.'='.$crmid;
                $smowner_result=$adb->pquery($sql,array());
                if($adb->num_rows($smowner_result)>0)
                {
                    $approve_userid=$adb->query_result($smowner_result,0,0);
                }
                break;
            case '3'://获取直属上级部门指定职位
                $entitytype=getSalesEntityType($crmid);
                $approvemodule_focus=CRMEntity::getInstance($entitytype);
                //17741: 关于"直属上级部门用户职位级别"的问题
                $sql='select smownerid from '.$approvemodule_focus->table_name.' where '.$approvemodule_focus->table_index.'='.$crmid;
                $smowner_result=$adb->pquery($sql,array());
                if($adb->num_rows($smowner_result)>0)
                {
                    $approve_userid=$adb->query_result($smowner_result,0,0);
                }
                break;
            case '4'://指定部门的职位
                break;
            case '5'://单据创建人
                if(empty($this->module))
                {
                    $this->module=getSalesEntityType($crmid);
                }

                $focus=CRMEntity::getInstance($this->module);
                $smcreatorcolname=$focus->getCreateColumnName();
                $sql='select '.$smcreatorcolname. ' from '.$focus->table_name.' where '.$focus->table_index.'=?';
                $result=$adb->pquery($sql,array($crmid));
                $approve_userid=$adb->query_result($result,0,0);
                break;
            case '6'://单据负责人
                if(empty($this->module))
                {
                    $this->module=getSalesEntityType($crmid);
                }
                $focus=CRMEntity::getInstance($this->module);
                $smownercolumnname=$focus->getSmownerColumName();
                $sql='select '.$smownercolumnname. ' from '.$focus->table_name.' where '.$focus->table_index.'=?';
                $result=$adb->pquery($sql,array($crmid));

                $approve_userid=$adb->query_result($result,0,0);
                break;

        }
        /*
        *edit: chj
        *date: 2020/9/24
        *reason: 单据负责人下面增加列示，当前模块启用的 uitype IN (153,154) 选择用户字段
        */
        if($approvetype > 6){
            if(empty($this->module))
            {
                $this->module=getSalesEntityType($crmid);
            }
            $focus=CRMEntity::getInstance($this->module);
            $fieldobj=Field::getInstance($this->module,$adb);
            $profieldarr=$fieldobj->FieldInfoListByKeyValue('fieldid',$approvetype);
            $sql='select '.$profieldarr['columnname']. ' from '.$profieldarr['tablename'].' where '.$focus->table_index.'=?';
            $result=$adb->pquery($sql,array($crmid));
            if($adb->num_rows($result)>0)
                $approve_userid=$adb->query_result($result,0,0);
        }
        return $this->getApproveuserinfoByid($approvetype,$approvevalue,$approve_userid,$emptyapproverdeal);
    }
    function  getApproveuserinfoByid($approvetype,$approvevalue,$approve_userid,$emptyapproverdeal=''){
        global $adb,$current_user;
        $userids = '';

        switch($approvetype){
            case '0':
                $userids=$approvevalue;
                break;
            case '1'://指定角色

                $profile = new Profile();
                $approvevalue=trim($approvevalue,',');
                $profileids=explode(",",$approvevalue);
                foreach($profileids as $profileid)
                {
                    $roleUserArr = $profile->getProfileOfUsers($profileid);
                    if(!empty($roleUserArr))
                        $userids.= join(',', array_keys($roleUserArr)).',';
                }
                $userids=explode(",",trim($userids,','));
                $userids=array_unique($userids);
                $userids=implode(",",$userids);
                break;
            case '2'://获取本部门指定职位员工
                $query = 'SELECT GROUP_CONCAT(DISTINCT ld_users.id) AS userid 
			FROM ld_users
					INNER JOIN ld_users2group 
							ON ld_users2group.`userid` = ld_users.`id`
					INNER JOIN (
							SELECT groupid FROM ld_users2group WHERE userid = ?
					) AS groupuser ON groupuser.groupid = ld_users2group.groupid
					INNER JOIN ld_groups ON ld_groups.`groupid` = ld_users2group.groupid
					INNER JOIN ld_user_group_set on ld_groups.`groupid` = ld_user_group_set.groupid 
						and ld_user_group_set.userid = ld_users.id and ld_user_group_set.type = \'userlevel\'
			WHERE ld_users.`deleted` = 0 AND ld_users.status = \'Active\' 
					and ld_user_group_set.content = ?;';//去除了AND ld_users.id != ?0017509: 服务合同：部门经理提交审批后，下一步处理人显示空白。

                //17741: 关于"直属上级部门用户职位级别"的问题
                $result = $adb->pquery($query,array($approve_userid,$approvevalue));
                //echo $result->sql;echo '<br><br>';die;
                $rows = $adb->num_rows($result);
                if(1 == $rows){
                    $userids = $adb->query_result($result,0,'userid');
                }
                break;
            case '3'://获取直属上级部门指定职位
                $query = 'SELECT GROUP_CONCAT(DISTINCT ld_users.id) AS userid 
                            FROM ld_users
                                INNER JOIN ld_users2group 
                                    ON ld_users2group.`userid` = ld_users.`id`
                                INNER JOIN (
                                    SELECT DISTINCT parentid AS groupid FROM ld_users2group 
                                        INNER JOIN ld_groups 
                                            ON ld_groups.`groupid` = ld_users2group.groupid
                                    WHERE userid = ?
                                ) AS groupuser ON groupuser.groupid = ld_users2group.groupid
                                INNER JOIN ld_groups ON ld_groups.`groupid` = ld_users2group.groupid
                                INNER JOIN ld_user_group_set on ld_groups.`groupid` = ld_user_group_set.groupid 
						            and ld_user_group_set.userid = ld_users.id and ld_user_group_set.type = \'userlevel\'
                            WHERE ld_users.`deleted` = 0 AND ld_users.status = \'Active\' 
                                AND ld_user_group_set.content = ?;';

                $result = $adb->pquery($query,array($approve_userid,$approvevalue));
                $rows = $adb->num_rows($result);
                if(1 == $rows){
                    $userids = $adb->query_result($result,0,'userid');
                }
                break;
            case '4'://指定部门的职位
                $query = 'SELECT GROUP_CONCAT(DISTINCT ld_users.id) AS userid 
							FROM ld_users 
								INNER JOIN ld_users2group 
									ON ld_users2group.`userid` = ld_users.`id` 
								INNER JOIN ld_groups 
									ON ld_groups.`groupid` = ld_users2group.`groupid`
                                INNER JOIN ld_user_group_set on ld_groups.`groupid` = ld_user_group_set.groupid 
                                and ld_user_group_set.userid = ld_users.id and ld_user_group_set.type = \'userlevel\'
							WHERE ld_groups.`groupid` = ? AND ld_user_group_set.content = ?;';
                $approvearray = explode('::', $approvevalue);
                $result = $adb->pquery($query,array($approvearray[0],$approvearray[1]));
                $rows = $adb->num_rows($result);
                if(1 == $rows){
                    $userids = $adb->query_result($result,0,'userid');
                }
                break;
            case '5'://单据创建人

                $userids=$approve_userid;
                break;
            case '6'://单据负责人
                $userids=$approve_userid;
                break;

        }
        /*
        *edit: chj
        *date: 2020/9/24
        *reason: 单据负责人下面增加列示，当前模块启用的 uitype IN (153,154) 选择用户字段
        */
        if($approvetype > 6){
            $userids=$approve_userid;
        }

        $approveby = '';
        if(!empty($userids)) 
            $userids = trim($userids,',');
        if(!empty($userids) && $this->approveobj->isNeedApprovalClient == 'yes'){//审批委托处理
            $query = "select distinct case when ifnull(approvestatus,1)=0 and ifnull(approveby,0)!=0 then approveby else id end as userid from ld_users where id in ($userids) and (status='active' or approvestatus=0) order by userid";
            $result = $adb->pquery($query,array());
            $num_rows = $adb->num_rows($result);
            for($i=0;$i<$num_rows;$i++){
                $userid = $adb->query_result($result,$i,'userid');
                if(!empty($userid))
                    $approveby .= $userid.",";
            }
            //异常处理， 下一步审批人开启了审批委托，但是没有选择审批委托人
            if(empty($approveby))
                $approveby = $userids;
            else
                $approveby = trim($approveby,',');

        }else{
            $approveby = $userids;
        }

        //ls 2022-02-25 0050133: 合同订单》提交审批，审批流程“合同123”，步骤流程2的审批人已停用，但还是显示了且没有提示审批人空(如果审批人被停用，提交审批时在getApproveBy()之后有判断，但是从二级审批开始就没有判断了)
        if (!empty($approveby)) {
            $sql = "SELECT group_concat(id order by id asc) as stepuserids FROM ld_users WHERE `status` = 'Active' and id IN ($approveby)";
            $tmp_result=$adb->pquery($sql);
            if($adb->num_rows($tmp_result) > 0){
                $approveby= $adb->query_result($tmp_result, 0, 'stepuserids');
            }
        }

        //duan 2022-8-23 单据审批时如果下一步审批人为空，则根据‘审批人为空时处理方式’参数替换审批人信息
        if(empty($approveby) && !empty($emptyapproverdeal) && $this->approveobj->get_allow_emptyapprover(0,$approvetype) == 'yes'){
            $approveby = $this->approveobj->getTransferUsers($emptyapproverdeal);
        }
        return $approveby;


    }


    //duan 20240611 判断编辑保存后是否需要重置审批状态
    public function SaveResetApprovestatus($module){
        global $adb;
        $focus = CRMEntity::getInstance($module);
        //edit:can 20220610 客户问题（宜昌金石），微信小程序，新建收款单（收款单编号：GR6439）选择审批流程保存后，没有提交审批成功
        $record = $focus->id;
        $lastapproveinfo = $this->approveobj->getlastapproveinfo($record,$module);
        $approveinfo = $this->approveobj->getApproveInfo($lastapproveinfo['approveid']);

        if ($focus->mode == 'edit'  && $approveinfo['finishedallowedit'] == 'yes' && $approveinfo['editresetapprove'] != 'no') {
            //判断当前模块是否开启审批
            $approvemod = $this->approveobj->getApproveModuleInfo();
            if ((!array_key_exists('approvestatus', $focus->column_fields) || empty($focus->column_fields['approvestatus'])) && isset($approvemod[$module])) {
                //审批状态字段隐藏
                $sql = "select approvestatus from " . $focus->table_name . " where " . $focus->table_index . "=?";
                $result = $adb->pquery($sql, array($focus->id));
                $focus->column_fields['approvestatus'] = $adb->query_result($result, 0, 0);
            }

            $status = $this->approveobj->getApproveStatus($focus->column_fields['approvestatus']);
            if ($status == 2 || $status == 3) {
                //已批准/拒绝的单据编辑保存提示信息 1、已批准/拒绝的单据允许再次提交审批  2、审批结束，状态为2、3，且处于编辑页面说明finishedallowedit为yes，即“审批结束，允许编辑单据”，无需再次判断  3、第一次编辑提示，第二次不提示
                //审批状态approveresult为2、3时提示，其他时候不提示（审批结束后编辑保存更新单据审批状态为未提交，ld_approvelog增加一条审批日志）
                return true;
            }
        }
        return false;
    }

    public function getCancelApprovedBtn($module,$record,$fields,$approved) {
        global $current_user,$adb;
        $ApproveAllowediting=$this->getApproveAllowediting($record);//Liver 20170208获取审批流程是否允许编辑、反审批,1允许，0不允许
        //ls 2021-11-19 0048879: 已批准/拒绝的单据允许再次提交审批，当勾选该参数时，已审批单据的反审批选项消失(此时提交审批和反审批都应该显示)
        //if(1 == $approved[1]) return 0;//提交审批时，不显示反审批按钮
        if(isset($fields['approvestatus'])){
            $approvestatus = $fields['approvestatus'];
        }else{
            $approve_focus = CRMEntity::getInstance($module);
            $query = 'select approvestatus from ' . $approve_focus->table_name . ' where ' . $approve_focus->table_index . ' = ? limit 1';
            $result = $adb->pquery($query,array($record));
            $num_rows = $adb->num_rows($result);
            if($num_rows>0){
                $approvestatus = $adb->query_result($result,0,'approvestatus');
            }
        }

        if($approvestatus==constant('D_A_S_APPROVED'))
        {
            //edit:can 20230112 销售订单模块，同步到CRM的销售订单，如果在CRM反审批之后，再次从ERP同步过来这个单据，第二次同步的单据没有反审批按钮了。可查看销售订单：XSDD000202
            //单据已批准，只有反审批历史
            $query = 'SELECT stepid,approveresult FROM ld_approvelog WHERE crmid = ? and approved_by>0    and approveresult in(1,2)  limit 1';
            $result = $adb->pquery($query,array($record));

            if($adb->num_rows($result)<=0)
            {
                return '1';
            }
        }

        //ls 2021-11-26 【1002260】审批流程定制，审批结束重复提交审批时功能优化（保存时提示并更改审批状态）
        if (0 == $this->approveobj->getApproveStatus($approvestatus)) return 0;//主表审批状态为未提交时，不显示反审批按钮


        /**
         * 判断是否为刚提交审批状态
         * @reason 0013447: 审批：单据提交后，还没有审批，这时候应该不显示【反审批】
         * @author Tujt 2015-01-21
         */
        $query = 'SELECT stepid,approveresult FROM ld_approvelog WHERE crmid = ? and approved_by>0   order by seqtime desc,id desc limit 3 ';
        $result = $adb->pquery($query,array($record));
        //	$count = $adb->query_result($result,0,'count');
        $approveresult = $adb->query_result($result,0,'approveresult');

        //回撤到原始状态  : 操作反审批到初始状态后，还可以再操作反审批
        if($approveresult == 4){
            return 0;//提交审批时，不显示反审批按钮
        }
        $rows=$adb->num_rows($result);

        if(2 > $rows) return 0;//没有审批过一次，不显示反审批按钮
        $stepid=$adb->query_result($result,0,'stepid');

        if($stepid=='-1')
        {
            //26254: 审批：一条单据审批通过反审批返回初始状态，提交审批后显示了反审批按钮
            return 0;
        }
        if(is_admin($current_user)) return 1;//管理员显示反审批按钮
        //判断有反审批权限时显示按钮
        if($this->CheckCancelApproveProfile($this->approveobj->module,$current_user) == 'yes') return 1;//有反审批权限的用户显示反审批按钮

        if($ApproveAllowediting['allowantiapproval']!=1) return 0;//当前流程不允许反审批情况下，不显示反审批按钮

        if(!empty($module)){
            $approve_focus = CRMEntity::getInstance($module);
            // $query = 'select approveby from ' . $approve_focus->table_name . ' where ' . $approve_focus->table_index . ' = ' . $record . ' limit 1';
            $query = 'SELECT approved_by,logconcurrentid FROM ld_approvelog WHERE crmid = ? and approved_by > 0 order by createdtime desc limit 1';
            $result = $adb->pquery($query,array($record));

            $num_rows = $adb->num_rows($result);

            if($num_rows >= 1){
                $approveby = $adb->query_result($result,0,'approved_by');
                $logconcurrentid = $adb->query_result($result,0,'logconcurrentid');
                if($logconcurrentid > 0){//并发步骤，如果当前用户是当前并发中已经审批完成的人之一，就可以反审批，直接反审整个并发步骤
                    $query = 'SELECT GROUP_CONCAT(DISTINCT approved_by) AS approved_by,logconcurrentid FROM ld_approvelog WHERE crmid = ? and approved_by > 0 group by logconcurrentid order by createdtime desc  limit 1';
                    $result = $adb->pquery($query,array($record));
                    $approveby = $adb->query_result($result,0,'approved_by');
                    $approveby = explode(',',$approveby);
                    if(in_array($current_user->id,$approveby)) return 1;//单据的审批人为自己，可以反审批
                }
            }
        }else{
            $approveby = $fields['approveby'];
        }

        if($current_user->id == $approveby) return 1;//单据的审批人为自己，可以反审批

        return 0;
    }
    //判断用户是否具有反审批权限
    public function CheckCancelApproveProfile($module,$current_user){
        $scopetlabel = 'CancelApproveProfile';
        $tabid= getTabid($module);
        crm_load_class_file('cls_related_scope','include/utils');
        $relatd_scope_list = cls_related_scope::get_related_scope_withtype($module,$scopetlabel,$tabid);
        $check_result = cls_related_scope::checkuser_inscope($relatd_scope_list,$current_user);
        return $check_result;
    }

}