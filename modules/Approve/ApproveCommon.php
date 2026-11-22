<?php
/**************************************************************************
**edit:duan
**date:2022-09-08
**reason:新旧审批流程通用的方法
**************************************************************************/
define('D_A_S_APPROVALOF','审批中');//审批中

define('D_A_S_APPROVED','已批准');//已批准
define('D_A_S_REJECTED','已拒绝');//已拒绝
define('D_A_S_DISMISSED','已驳回');//已驳回
define('D_A_S_CHECKED','已审核');
define('WHERE_SYSTEM_APPROVE',D_A_S_APPROVED);
define("APPROVE_APPROVED",2);//已批准
class ApproveCommon{
    private static $_instance;//单例返回类实例
    public static function getInstance($module) {
        /**
         * 单例返回当前类的实例
         */
        if(!(self::$_instance[$module] instanceof self)){//是否为当前类的实例
                self::$_instance[$module] = new self($module);
            }
            return self::$_instance[$module];
    }
    public $module;
    public $approvecondition_arr = [];
    public  function __construct($module='')
    {
        $this->module=$module;
    }
    //防止被克隆
    private function __clone(){}
    //获取单据审批状态及下一个步骤审批人 
    function approveStatus($record){
        
        static $global_approvestatus;
        if($global_approvestatus[$record])
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
                  ld_approve.isnewapprove FROM ld_approvelog
                  left JOIN ld_approve ON ld_approve.id = ld_approvelog.approveid
                WHERE ld_approvelog.crmid = ?  
                ORDER BY ld_approvelog.seqtime DESC,ld_approvelog.stepseq desc, ld_approvelog.id desc
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
            $isnewlog = $adb->query_result($result,0,'isnewapprove');
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
    
    public function getAllApprovesByUserid($tabid,$userid){
        crm_load_class_file('cls_ApproveInfo','modules/Approve');
        $ApproveInfoObj=new cls_ApproveInfo($this);
        return $ApproveInfoObj->getAllApprovesByUserid($tabid,$userid);
    }
    
	/**
	 * 获取有审批的模块
	 * @author Tujt 2015-04-10
	 */
	public static function getApproveModuleInfo() {
	    $cachekey = 'getapprovemoduleinfo';
		$approvemod = Cache($cachekey);
		if(!$approvemod){
			global $adb;
			$approvemod = array();
			$query = 'SELECT setype FROM ld_systems_deploy WHERE setype IS NOT NULL 
						AND deploy_value=0 AND setype != \'\' ORDER BY id;';
			$result = $adb->pquery($query,array());
            
			$rows = $adb->num_rows($result);
			if($rows > 0){
				for($i=0;$i<$rows;++ $i){
				    $setype = $adb->query_result($result,$i,'setype');
					$approvemod[$setype] = $setype;
				}
				Cache($cachekey,$approvemod);
			}
		}
       
		if(!empty($approvemod)) return $approvemod;
		return false;
	}

	public function isModuleApproveActive($module){
	    $all_approvemod = self::getApproveModuleInfo();
	    if(in_array($module,$all_approvemod)){
	        return 'yes';
        }else{
	        return  'no';
        }
    }
    
	/*
     * editor:gyq_05
     * reason:获取审批步骤详情
     * */
	function getStepInfo($stepid){
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
	 * 通过ID自动审批单据
	 * @param Integer $record ID值
	 * @param Integer $approvedtype 审批通过或返回负责人
	 * @param String $description 备注
	 * @author Tujt 2015-05-11
	 */
	public function SaveRecordApproveLog($record,$approvedtype,$description = '') {
	    global $adb,$current_user,$approvestepinfo_arr;
        //$approvestepinfo_arr:某个审批流程下所有的审批步骤信息
		//1、通过ID获取对应的模块名
		$query = 'select crmid,setype from ld_crmentity where crmid in ('.$record.'); ';
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
        $successcount=0;
        
		$fldmodarr = array();$fld_module = '';$mes = '';
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
				$crmid = $adb->query_result($result,$i,'crmid');
				$setype = $adb->query_result($result,$i,'setype');
				$fldmodarr[$crmid] = $setype;
			}
		}
        $focus=CRMEntity::getInstance($setype);
        $tablename=$focus->table_name;
        $table_index=$focus->table_index;

        $query="select crmid,approveresult,approveid,nextstepid,
            nextstepapproveby,nextstep_countersigner,$tablename.currentapprover
            ,logconcurrentid,isnewlog from ld_approvelog inner join (
        select max(id) as maxid from ld_approvelog  WHERE crmid IN (".$record.") 
        and ifnull(nextstepapproveby,0)!='-1'
        group by ld_approvelog.crmid ) as tmp on tmp.maxid=ld_approvelog.id
        inner join $tablename on $tablename.$table_index=ld_approvelog.crmid";
           //dump($query);

		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		$approvelog = array();
        
		$old_record_arr = array();//使用旧审批流程的单据
        $new_record_arr = array();//使用新审批流程的单据
        if($rows >0){
            for($i=0;$i<$rows;$i++){
                $crmid = $adb->query_result($result,$i,'crmid');
                $approveid = $adb->query_result($result,$i,'approveid');
                $approveinfo = $this->getApproveInfo($approveid);
                if($approveinfo['isnewapprove']=='yes'){
                    $new_record_arr[] = $crmid;
                }else{
                    $old_record_arr[] = $crmid;
                }
            }
        }
        //新审批流程批量审批
        if(sizeof($new_record_arr)>0){
            $record_str = implode(',',$new_record_arr);
            $approveobj = Approve::getInstance($this->module,'yes');
            $mes .= $approveobj->SaveRecordApproveLog($record_str, $approvedtype, $description,$result);
        }
        //旧审批流程批量审批
        if(sizeof($old_record_arr)>0){
            
            $record_str = implode(',',$old_record_arr);
            $approveobj = Approve::getInstance($this->module,'no');
            $mes .= $approveobj->SaveRecordApproveLog($record_str, $approvedtype, $description,$result);
        }

        if($_REQUEST['approvebatchnum'])
        {
            $errorcount=$_REQUEST['approvebatchnum']-$_SESSION[$current_user->id . '_Approve_batchapproved']['correct'];
            $mes = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">共选择 '.$_REQUEST['approvebatchnum'].' 条记录，成功提交 '.$_SESSION[$current_user->id . '_Approve_batchapproved']['correct'].' 条，失败 '.$errorcount.' 条。</div></div>';
            $mes .= '<div class="pop_prc_content" style="height: 180px;"> '.$_SESSION[$current_user->id . '_Approve_batchapproved']['edit_err'].'</div>';
        }

		return $mes;
	}

	
    //$approveid:审批流程id,$record_str:以逗号分隔的单据id字符串
    //如果$getPermitArr不等于yes，判断所选单据是否属于审批流程的适用范围，返回判断结果
    //如果$getPermitArr等于yes，表示获取所有符合条件的单据，返回所有符合条件单据数组，用于批量提交判断
    public function getApplicationByCondition($approveid,$record_str='',$getpermit_arr='no'){
        global $current_user,$adb;
        crm_load_class_file('cls_ApproveStep','modules/Approve');
        $approvestepobj=new cls_ApproveStep($this->module,$approveid,0);
        $queryobj=$approvestepobj->getQueryobj(-1);
        $premit_record_arr = array();
        $advft_criteria_info = $this->getApproveInfo($approveid);
        
        //如果未设置查询条件则不判断适用范围
        if(empty($advft_criteria_info['advft_criteria'])||empty($advft_criteria_info['advft_criteria_groups'])){
            if($getpermit_arr == 'no'){
                return 'yes';
            }else{
                return array();
            }
        }
        $focus = CRMEntity::getInstance($this->module);
        $advft_criteria_info['searchtype'] = 'advance';
        //生成条件查询sql
        $queryobj->addUserSearchConditions($advft_criteria_info);
        $query=$queryobj->getQuery("",1);
        
        //判断所选的单据是否符合筛选条件
        if(!empty($record_str)&&$getpermit_arr=='no'){
            if($record_str != 'all'){
                $record_str = trim($record_str, ',');
                $query.=" and ".$queryobj->moduleobj->table_name.'.'.$queryobj->moduleobj->table_index." in ($record_str)";
            }
            $result = $adb->pquery($query);
            $num_rows = $adb->num_rows($result);
            if($num_rows >0){
                return 'yes';
            }else{
                //没有符合条件的单据
                return 'no';
            }
        }else{
            //获取所有符合审批流程适用范围的单据
            $result = $adb->pquery($query);
            $num_rows = $adb->num_rows($result);
            $permit_record_arr = array();
            if($num_rows>0){
                for($i=0;$i<$num_rows;$i++){
                    $tmp_record = $adb->query_result($result,$i,$queryobj->moduleobj->table_index);
                    $permit_record_arr[] = $tmp_record;
                }
            }else{
                //表示没有符合条件的单据
                $permit_record_arr[] = -1;
            }
            return $permit_record_arr;
        }
    }
    //获取审批流程信息
    public function getApproveInfo($approveid){
        global $adb;
        //将当前模块所有审批流程的筛选条件存下来，避免重复读取
        if(is_array($this->approvecondition_arr)&&isset($this->approvecondition_arr[$approveid])){
            return $this->approvecondition_arr[$approveid];
        }else{
            //获取当前模块所有审批流程的信息
            $sql = "select id,dataadv,dataadvgroup,isnewapprove from ld_approve where tabid = ?";
            $tabid = getTabid($this->module);
            if($tabid == 16)$tabid = 9;//日程管理特殊处理
            $result = $adb->pquery($sql,array($tabid));
            $num_rows = $adb->num_rows($result);
            
            for($i=0;$i<$num_rows;$i++){
                $tmp_approveid = $adb->query_result($result,$i,'id');
                $dataadv = html_entity_decode($adb->query_result($result,$i,'dataadv')??'');//高级查询条件组
                $dataadvgroup = html_entity_decode($adb->query_result($result,$i,'dataadvgroup')??'');//高级查询组间关系
                $isnewapprove = $adb->query_result($result,$i,'isnewapprove');//判断是否为新审批流程
                $tmp_approveinfo = array('advft_criteria'=>$dataadv,
                                         'advft_criteria_groups'=>$dataadvgroup,
                                         'isnewapprove'=>$isnewapprove);
                $this->approvecondition_arr[$tmp_approveid]=$tmp_approveinfo;
            }
            return $this->approvecondition_arr[$approveid];
        }
    }
    //根据审批流程获取对应的审批对象
    public function getApproveobjByApproveid($approveid){
        $module = $this->module;
        $ApproveInfo = $this->getApproveInfo($approveid);
       
        $isnewapprove = $ApproveInfo['isnewapprove'];
        $approveobj = Approve::getInstance($module,$isnewapprove);
        return $approveobj;
    }
    //根据审批流程id获取对应的模块名
    public function setModuleByApproveid($approveid){
        global $adb;
        if(!empty($this->module)){
        }else{
            $sql = "select tabid from ld_approve where id = ?";
            $result = $adb->pquery($sql,array($approveid));
            if($adb->num_rows($result)>0){
                $tabid = $adb->query_result($result,0,'tabid');
                $module = getTabname($tabid);
                $this->module = $module;
            }
        }
    }
    //判断审批流程是否在使用中
    function approveUsed($approveid,$module){
		//return -1;
        global $adb;
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
					AND b.approveresult=1 LIMIT 1";
             $result=$adb->query($query,array());
             $num_rows=$adb->num_rows($result);
             if($num_rows>0)
                $approveresult=1;
                    
        }
       
        return $approveresult;
    }
    //获取审批单据可以用的审批流程
    function submitApprove($tabid){
        global $adb,$current_user,$weixin_user;
        return $this->getAllApprovesByUserid($tabid,$current_user->id);
    }
    //获取并发步骤审批状态信息
    public function getConcurrentApproveStatus($record){
        
        static $global_approvestatus;
        if($global_approvestatus[$record])
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
                  ld_approve.isnewapprove FROM ld_approvelog
                  left JOIN ld_approve ON ld_approve.id = ld_approvelog.approveid
                WHERE ld_approvelog.crmid = ?  
                ORDER BY ld_approvelog.seqtime DESC,ld_approvelog.stepseq desc, ld_approvelog.id desc
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
            $isnewlog = $adb->query_result($result,0,'isnewapprove');
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
                WHERE ld_approvelog.crmid =?  and ld_approvelog.logconcurrentid=?
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

    //判断模块是否启用快速提交
    function Blocksquicksubmit($module){
        crm_load_class_file('cls_ApproveCache','modules/Approve');
        return cls_ApproveCache::Blocksquicksubmit($module);
    }
    //单据选择一条默认的审批流程快速提交
    public function quick_submit($record){
        global $current_user,$weixin_user;
        $module = $this->module;
        if($this->isModuleApproveActive($module) == 'yes' && $this->Blocksquicksubmit($module)){
            $tabid = getTabid($module);
            $weixin_user->action = 'default_on_new';

            $approveinfos=$this->getAllApprovesByUserid($tabid,$current_user->id);

            $choose_approveid = 0;
            foreach($approveinfos as $approveindex=>$approveinfo){
                $approveid = $approveinfo['approveid'];
                //判断所选单据是否符合条件
                if(!empty($record)&&$this->getApplicationByCondition($approveid,$record)=='no'){
                    continue;
                }
                if($choose_approveid == 0 || $approveinfo['isdefaultapprove'] == 'yes'){
                    $choose_approveid = $approveid;
                }
            }
            if($choose_approveid>0){

                $approveobj = $this->getApproveobjByApproveid($choose_approveid);

                $stepinfo= $approveobj->ApproveSubmit($module,$record,$choose_approveid);

            }
        }
    }
}
?>