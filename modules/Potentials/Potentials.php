<?php



// ld_potential is used to store customer information.
class Potentials extends CRMEntity {
    
	public $relatedinfoset_arr = [];// 分配相关信息的设置
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['Potentials']='Potentials';
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    
	var $log;
	var $db;

	var $module_name="Potentials";
	var $table_name = "ld_potential";
	var $table_index= 'potentialid';
    var $table_code='potential_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_potential','ld_potentialscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_potential'=>'potentialid','ld_potentialscf'=>'potentialid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_potentialscf', 'potentialid');

	var $column_fields = Array();

	var $sortby_fields = Array('potentialname','amount','closingdate','smownerid','accountname','potential_no','sales_stage','smcreatorid','createdtime','approvestatus','allocated_time','potentialtype','leadsource','possibility','campaignid');
    //reason:打印关联模块
	var $smoldOwnerID="";//修改前负责人ID
    var $relatedtab=array('potentials'=>'','users'=>'','company'=>'','accounts'=>'','contacts'=>'');

	var $list_fields_name = Array(
			'Potential'=>'potentialname',
			'Account Name'=>'accountid',
			'Sales Stage'=>'sales_stage',
			'Amount'=>'amount',
			'Expected Close Date'=>'closingdate',
			'Assigned To'=>'assigned_user_id');

	var $list_link_field= 'potential_no';

	var $search_fields = Array(
			'Potential'=>Array('potential'=>'potentialname'),
			'Account Name'=>Array('potential'=>'accountid'),
			'Expected Close Date'=>Array('potential'=>'closedate')
			);

	var $search_fields_name = Array(
			'Potential'=>'potentialname',
			'Account Name'=>'accountid',
			'Expected Close Date'=>'closingdate'
			);

	var $required_fields =  array();

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
    //edit:can 20211011 48217: 销售机会->页面设置：potentialname 字段是程序特殊控制不允许设置必填项的
	var $mandatory_fields = Array( 'createdtime', 'modifiedtime', 'related_to');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'potentialname';
     /*
    date：20131219
    reason:序时簿显示改动 ,设置按照“最新更新时间”倒序排序
    edit by andy
    */
	var $default_sort_order = 'DESC';

	// For Alphabetical search
	var $def_basicsearch_col = 'potentialname';
	static $mass_before_focus=array();
	
    var $Detail_table="ld_potentialsdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_potentialsdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
	//var $groupTable = Array('lingdang_potentialgrouprelation','potentialid');
	function __construct() {
		//$this->log = LoggerManager::getLogger('potential');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj= Field::getInstance('Potentials',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
             /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Potentials');
        $this->list_link_field=$entityname['fieldname'];
        $deployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否
        if($deployarray['deploy_value']==0)
        {
            crm_load_class_file('ProductToolFields','include/ProductDetails');
         $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
        }
	}
	/*
    edit by LD Can 
    date:20130326
    reason:得到修改前客户负责人信息
    other:客户负责人修改提醒导致增加的函数
    */
    function setSmOldOwnerID()
    {
        global $adb;
         /*
        edit:Can
        date:20130407
        reason:03655: 不合理：新增客户后会生成提醒，提醒自己：有新的客户分配给您
        */
        if(!isset($this->id)||$this->id<=0)
        {
            $this->smoldOwnerID=-1;
            return ;
        }
        $sql_rmd = 'select smownerid from '.$this->table_name.' where '.$this->table_index.' = ? limit 1;';
        $result = $adb->pquery($sql_rmd,array($this->id));
        $assOLD = $adb->query_result($result,0,'smownerid');
        $this->smoldOwnerID = $assOLD;
        
    }
	function save_module($module)
	{
	    global $adb,$current_user;

        //duan 销售线索增加升级到客户和销售机会
		if(isset($_REQUEST['upgradetomodule'])&&$_REQUEST['upgradetomodule']==$module){
  		    $fromid = $_REQUEST['fromid'];
            $accountid = $this->column_fields['account_id'];
            //判断新建界面选中的客户单据与升级的客户单据是否为同一个
            if($accountid==$fromid){
                //更新客户单据的‘是否来自销售线索’字段
                $sql = "update ld_account set kis_no = ?,upgrade_source=? where accountid = ?";
                $adb->pquery($sql,array('upgradeto_potentials','upgradeto_potentials',$accountid));
                //更新销售机会单据的‘是否来自销售线索’字段
                $sql = "update ld_potential set kis_no = ?,upgrade_source=? where potentialid = ?";
                $adb->pquery($sql,array('upgradeto_potentials','upgradeto_potentials',$this->id));
                //更新"升级到客户和销售机会"状态--zxm 20230731 推进的时候不仅改status值 还需要改推进阶段的值
                if(isset($_REQUEST['upgradestatus'])){
                    $upgradestatus = $_REQUEST['upgradestatus'];
                }else{
                    $upgradestatus = '升级到客户和销售机会';
                }

                $sql = "update ld_leads set status=?,advance_stage=? where upgradeaccountid =?";
                $adb->pquery($sql,array($upgradestatus,$upgradestatus,$accountid));
                //判断是否需要同步跟进记录
                $sql = "SELECT contactdate,content,smownerid from ld_contactrecords where accountid = ? ORDER BY contactdate DESC limit 1";
                $result = $adb->pquery($sql,array($accountid));
                $num_rows = $adb->num_rows($result);
                if($num_rows >0){
                    //更新相关跟进记录信息
                    $sql = "update ld_contactrecords set potentialid = ? where deleted = 0 and accountid = ?";
                    $adb->pquery($sql,array($this->id,$accountid));
                    //更新销售机会单据的最新进展、最新联系日期、最新联系人、未联系天数
                    $lastcontactdate = $adb->query_result($result,0,'contactdate');
                    $lastcontent = $adb->query_result($result,0,'content');
                    $lastcontactuser = $adb->query_result($result,0,'smownerid');
                    $lastcontactdate_short = date('Y-m-d',strtotime($lastcontactdate));
                    $datetime_now = date('Y-m-d');
                    $nolinkdays = intval((strtotime($datetime_now)-strtotime($lastcontactdate_short))/(3600*24));
                    $sql = "update ld_potential set lastcontent=?,lastcontactdate=?,lastcontactuser=?,nolinkdays=? where potentialid = ?";
                    $adb->pquery($sql,array($lastcontent,$lastcontactdate_short,$lastcontactuser,$nolinkdays,$this->id));
                    
                }
            }
		}

        if($_REQUEST['upgradefrommodule']!=''&&$_REQUEST['upgradefromid']>0)
        {
            //@edit:liushuai,2020-08-02,reason:【ID1001055】/销售线索增加审批功能(只有审批通过后才能继续升级流程，将从销售线索升级过来的客户做个标识from_leads)
            $adb->pquery('update ld_account set kis_no = ?,upgrade_source=? where accountid = ?',array('from_leads','from_leads',$this->id));

            //销售线索升级
            $upgradefocus=CRMEntity::getInstance($_REQUEST['upgradefrommodule']);
            $upgradetablename=$upgradefocus->table_name;
            $upgradetableindex=$upgradefocus->tab_name_index[$upgradetablename];//leadsid
            $upgradetablescf=$upgradefocus->customFieldTable[0];
            $upgradetablescfindex=$upgradefocus->customFieldTable[1];

            //@edit:liushuai,2020-12-04,reason:【ID1000275】/销售线索关联的跟进记录单据，在销售线索升级为客户单据后，升级后的销售线索（即：客户单据）仍与跟进记录存在关联关系（在删除销售线索前更新）
            if ($_REQUEST['upgradefrommodule'] == 'Leads') {
                $result = $adb->pquery("select smcreatorid,lastcontent,lastcontactdate from {$upgradetablename}  where  {$upgradetableindex} = ?",array($_REQUEST['upgradefromid']));
                if($adb->num_rows($result) >= 1){
                    $smcreatorid = $adb->query_result($result,0,'smcreatorid'); //创建人
                    $lastcontent = $adb->query_result($result,0,'lastcontent'); //最新进展
//                  $lastcontactdate = $adb->query_result($result,0,'lastcontactdate'); //最新联系日期
                    //销售线索映射字段优化，创建人可通过映射字段另外指定
                    crm_load_class_file('cls_MappingFields','modules/Leads');
                    $cls_MappingFields = new cls_MappingFields($_REQUEST['upgradefrommodule']);
                    $mappingfields_info = $cls_MappingFields->getMappingFields('Potentials');
                    $columnname = 'smcreatorid';
                    $upgradefieldinfo= $mappingfields_info[$columnname];
                    $mapped_columnname = $upgradefieldinfo['mapped_columnname'];
                    if(!empty($mapped_columnname)&&$mapped_columnname!=$columnname){
                        if($mapped_columnname == 'curuser'){
                            $smcreatorid = $current_user->id;
                        }else{
                            $fieldinfo=$upgradefocus->fieldobj->getFieldInfoobjBykey("columnname",$mapped_columnname);
                            if(!empty($fieldinfo)){
                                $tablename=$fieldinfo->getTableName();
                                $sql = "select $mapped_columnname from $tablename where  $upgradetableindex = ?";
                                $result = $adb->pquery($sql,array($_REQUEST['upgradefromid']));
                                $userid = $adb->query_result($result,0,$mapped_columnname);
                                if($userid>0){
                                    $smcreatorid = $userid;
                                }
                            }
                        }
                    }
                    //duan 20230213 如果创建人字段被改成可编辑的（特殊开发），从请求中获取字段值
                    if(isset($_REQUEST['creator']) && $_REQUEST['creator'] != ''){
                        $smcreatorid = $_REQUEST['creator'];
                    }
                }
            }

            $sql=" update $upgradetablename set status=?,advance_stage=?,upgradeaccountid=?,latestpushtime=NOW() where $upgradetableindex=?";
            $this->setRefreshListModules(array($_REQUEST['upgradefrommodule']));
            $adb->pquery($sql,array($_REQUEST['upgradestatus'],$_REQUEST['upgradestatus'],$this->id,$_REQUEST['upgradefromid']));
            //$tab_name_index

        }
        /*
		 * editor: gyq_02
		 * reason: 销售机会新增或者编辑保存时反写客户最新销售机会
		 * date  : 2016.1.20
		 */
		foreach($this->before_field_info  as $fieldinfo)
		{
			//获取保存前客户或销售机会ID
			$columnname=$fieldinfo->getColumnName();//
			$relateid=$fieldinfo->getColumn_Value();
			$accountids = [];
			if($columnname=='accountid'&&!empty($relateid))
			{
				$accountids[$relateid]=$relateid;
			}
			/*
			* edit:chj
			* date:2020-07-10
			* reason:41949: （https://61mis.com/kfbcrm/ [^]）单据查看详情界面，推进的阶段布局规则设置了必填字段，进入编辑界面输入数据保存后，单据详情界面没有立即更新（销售机会模块测试）
			*/
			if($columnname == 'sales_stage' && !empty($_REQUEST['sales_stage'])){
				$val = $fieldinfo->getColumn_Value();
				if($val != $_REQUEST['sales_stage']){
					$update = 'update ld_potential set lastsales_stage="'.$val.'" where potentialid = '.$this->id;
					$adb->pquery($update,array());
				}
			}
		}
		if(!empty($this->column_fields['account_id']))
			$accountids[$this->column_fields['account_id']] = $this->column_fields['account_id'];
 
		if(is_array($accountids)&&sizeof($accountids)>0) {

			$this->updateRelatedTableInfo('ld_account',$accountids);

		}
        //chj: 编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
        if($this->currency_status === true)
        {
            $update_query = "update ld_potential set currency_id=?, conversion_rate=?,currency_symbol=? where potentialid=?";
    		$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
    		$adb->pquery($update_query, $update_params);
        }
		/*if(isset($_REQUEST['account_id'])){
			$account=CRMEntity::getInstance('Accounts');
			$account->updateAccountInfo($module,$_REQUEST['account_id']);  
		}*/
        //九维 思孚 汉天 单据新增保存更新对应通话记录表  editor:gyq_85 reason:汉天呼叫中心优化 2018/10/31 18:02 
        if(isset($_REQUEST['jiuweiaccount'])&&isset($_REQUEST['callcenter_switch'])){
            crm_load_class_file('cls_UpdatePhoneRecord','CallCenter/lib');
            $obj=new cls_UpdatePhoneRecord($_REQUEST['jiuweiaccount'],$_REQUEST['callcenter_switch'],$this->id,$module);
            $obj->updatePhoneRecord();
        }

//        @edit:liushuai,2021-05-26,reason:【ID1001533】呼叫中心接口设置，增加接口类型“灵当语音盒”
        //灵当语音盒
        if (isset($_REQUEST['calltalkid']) && $_REQUEST['calltalkid'] != '') {
            $calltalkid = $_REQUEST['calltalkid'];

            $callbutlerGetSql = "select id from ld_callbutler where talkid = ? and userid = ? ";
            $callbutlerGetResult = $adb->pquery($callbutlerGetSql, array($calltalkid, $current_user->id));
            if ($adb->num_rows($callbutlerGetResult)) {
                //存在
                $callButlerID = $adb->query_result($callbutlerGetResult, 0, 'id');

                $sqlUpdate = "update ld_callbutler set potentialid = ?,accountid = ?, contactid = ?, description = ? where id = ? ";
                $updateResult = $adb->pquery($sqlUpdate, array($this->id, $_REQUEST['account_id'], $_REQUEST['contact_id'], "", $callButlerID));

            } else {
                //不存在
                $sqlInsert = "insert into ld_callbutler 
                    (talkid,calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,potentialid,description) 
                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    ";

                $insertresult = $adb->pquery($sqlInsert, array($calltalkid, '', '', '', null, null, '', '', $current_user->id,
                    $_REQUEST['account_id'], $_REQUEST['contact_id'], 0, 0, 0, 0, 0, $this->id, ''));
            }
        }

        $deployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否
        if($deployarray['deploy_value']==0)
        {
               	if($_REQUEST['action'] != 'PotentialsAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
        				&& $_REQUEST['action'] != 'MassEditSave' )
        		{
        		     
                     
        			//销售机会明细保存
                    crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
                    saveInventoryProductDetails($this, $this->module_name);
                    
                  
        		}
                $versioninfo = getVersionInfo();
                //中孚特殊需求:未设置产品分录时，允许编辑预计合同金额
                if($versioninfo['trade'] == 'zhongfu'){
                    if(isset($_REQUEST['rowcnt']) && $_REQUEST['rowcnt'] > 0){
                        $sql='update ld_potential set amount=total where potentialid=?';
                        $adb->pquery($sql,array($this->id));
                    }
                }else{
                    $sql='update ld_potential set amount=total where potentialid=?';
                    $adb->pquery($sql,array($this->id));
                }
          }
          else
          {
                $sql='update ld_potential set total=amount,subtotal=amount where potentialid=?';
                $adb->pquery($sql,array($this->id));
                
          }
		
		$tabid = getTabid($module);
		// $sel_sql = "SELECT fieldid, 
		// 			CASE 
		// 				WHEN fieldname = 'cf_1308' THEN 'cf_1308'
		// 				WHEN fieldname = 'cf_1317' THEN 'cf_1317'
		// 			END AS result_fieldname
		// 			FROM ld_field where tabid = ? and (fieldname = ? or fieldname = ?) ORDER BY fieldid LIMIT 1";
		// $sel_result = $adb->pquery($sel_sql, array($tabid, 'cf_1308', 'cf_1317'));
		// $budget_fieldname = $adb->query_result($sel_result, 0, 'result_fieldname');

		// $budget_sql = "SELECT * FROM ld_potentialscf where potentialid= ?";;
		// $budget_result = $adb->pquery($budget_sql, array($this->id));
		// $budget_sqlvalue = $adb->query_result($budget_result, 0, $budget_fieldname);
		// $tmp_possibility = $_REQUEST['possibility'];
		// if (substr($tmp_possibility, -1) === '%') {
			// $tmp_possibility = rtrim($tmp_possibility, '%'); // 去掉百分号
		// }
		// $budget_value = $_REQUEST['amount']*$tmp_possibility/100;
		// dump($budget_sqlvalue);

		// if($_REQUEST[$budget_fieldname] != $budget_value && $_REQUEST[$budget_fieldname] != $budget_sqlvalue){

		// }else{
			// $sql="UPDATE ld_potentialscf 
			// inner join ld_potential on ld_potential.potentialid=ld_potentialscf.potentialid
			// set ".$budget_fieldname."=
			// CASE 
			// 	WHEN ld_potentialscf.possibility REGEXP '^[0-9]+$' THEN ld_potential.amount * ld_potentialscf.possibility/100
			// 	WHEN ld_potentialscf.possibility REGEXP '^[0-9]+%$' THEN ld_potential.amount * REPLACE(ld_potentialscf.possibility, '%', '') / 100
			// 	ELSE ld_potentialscf.".$budget_fieldname."
			// END
			// where ld_potential.potentialid= ".$this->id;
			// $adb->pquery($sql,array());
		// }
       
       
		  
        $update_query = "update ld_potential set triggercount=triggercount+1 where potentialid=?";
		$update_params = array($this->id);
		$adb->pquery($update_query, $update_params);
	   
       	//in ajax save we should not call this function, because this will delete all the existing product values
	
         
		/*
        edit:Can
        date:20130407
        reason:03655: 不合理：新增客户后会生成提醒，提醒自己：有新的客户分配给您
        */
        if($this->smoldOwnerID==-1)
        {
            return ;
        }
	}
	//	0020719: (www.71mis/ldcrm)客户>明细界面：相关信息-销售机会，新建销售机会后，客户明细界面的“最新销售机会”字段，没有回写销售机会的值
	//因为没有写脚本，所以导致升级包和外网的已更新的crm该功能无法使用。因为要打sp1补丁包，放进代码脚本比较麻烦，影响到手机，所有在这里先在代码中控制，日后在删除
	/*function insertDb(){
		global $adb;
		$adb->pquery("call AddColumn('ld_account','potentialid','int','11',0)",array());
		$adb->pquery("update ld_field set columnname = 'potentialid',fieldname='potential_id',uitype='76' where tabid = 6 and columnname ='lastpotential' and fieldname = 'lastpotential'",array());
		unsetCacheDirectory('fields');
	}*/
    
    /**
     * 分配负责人，修改创建人
     * $type:操作类型:allocate,changecreator
     * */
    function massChangeUser_after($module,$ids,$type)
    {
        global $current_user,$adb;
		if(empty($ids)||$ids=='')
		{
            return ;
		}
		
		crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');

		if(is_array($ids))
		{
            $ids=implode(',',$ids);
		}
		$sql='select tablename,tabid from ld_field where uitype=76 and presence in(0,2) group by tabid';
		//$_REQUEST['caterorid']
        if(strtolower($type)=='allocate')
        {
            $system_deploy=getSys_deploy(26);
            $relatedinfoset = $this->relatedinfoset_arr;// 2024-7-12 xxy XUQIU20240521-04 模块分配和共享的时候，可以出现弹窗去选择分配哪些模块的单据
			$sharerelatedinfo = 'no';
			$shareoldsmowner = '';
			$relmodule_scope = '';
			$relmodule_selectedtabid_str = '';
			$record_oldsmowner = '';
			if(!empty($relatedinfoset)){
				$sharerelatedinfo = $relatedinfoset['sharerelatedinfo'];
				$shareoldsmowner = $relatedinfoset['shareoldsmowner'];
				$relmodule_scope = $relatedinfoset['relmodule_scope'];
				$relmodule_selectedtabid_str = $relatedinfoset['relmodule_selectedtabid_str'];
				$record_oldsmowner = $relatedinfoset['oldsmowner'];
			}else{
				$relatedinfoset['sharerelatedinfo'] = 'no';
			}
			$other_sql = ''; 
			if($relmodule_scope == 'part'){// 所选择的模块
				if(!empty($relmodule_selectedtabid_str)){
                    $other_sql .= " and ld_tab.tabid in (". $relmodule_selectedtabid_str .")";
                }else{
                    $other_sql .= " and ld_tab.tabid is null";
                }
			}
			$this->relatedinfoset_arr['modulelist'] = getRelatedModulesWithAllocateShare($module,'Allocate',$other_sql);
			
			$ids=explode(',',$ids);
			foreach($ids as $recordid)
			{
				
                if($system_deploy['deploy_value']!='none' && $sharerelatedinfo == 'yes')//销售机会分配时，是否同时分配相关信息。none:否，all:全部模块，part:自选模块
                {
					$this->UpdateRelatedListModuleSmownerid($module,$recordid,$_REQUEST['caterorid']);
                   /* $result=$adb->pquery($sql,array());
                    for($i=0;$i<$adb->num_rows($result);$i++)
                    {
                        $modulename=getTabname($adb->query_result($result,$i,'tabid'));
                        $relate_focus=CRMEntity::getInstance($modulename);
                        $smownercolumnname=$relate_focus->getSmownerColumName();
                        $tablename=$adb->query_result($result,$i,'tablename');//不考虑特殊情况,负责人字段和销售计划字段都在主表中
                        $sql="update $tablename set $smownercolumnname=?  where potentialid=?";
                        $adb->pquery($sql,array($_REQUEST['caterorid'],$recordid));
                      
                    }*/
                }
                $opdate=date('Y-m-d');
				// 同时分配相关信息，将原销售负责人"设置为共享人" / "从共享人中移除"
				if(!empty($shareoldsmowner)){
					crm_load_class_file('cls_share','include/Functions/Share');
					$objShare = new cls_share();
					$objShare->obj_current_user = $current_user;
					if($shareoldsmowner == 'setshare'){// 设置为共享人
						$objShare->share_type = 'add';
					}
					else if($shareoldsmowner == 'removeshare'){// 从共享人中移除
						$objShare->share_type = 'cancel_share';
					}
					$objShare->set_need_add_remind('no');
					$objShare->do_share_type($record_oldsmowner, $recordid, '');
					$objShare->ReverseWriteTeam_memberID($module,$recordid);//edit：can 20210419 反写模块的团队成员的值
				}
			}
			if(!empty($relatedinfoset['type'])){
				setUsersettingByLabel($module,$current_user->id,$relatedinfoset['type'],ldcrm_json_encode($relatedinfoset));
			}
        }
    }
	/**
	 * 模块变更负责人，同时变更关联信息模块单据的负责人,同时增加销售负责人变更历史
	 * @param @module 当前模块 @record 单据ID @$assigned_user_id 变更后的负责人ID
	 * @return 
	 * @author Chj
	 */
	function UpdateRelatedListModuleSmownerid($module,$recordid,$assigned_user_id){
		global $adb;
		$focus = CRMEntity::getInstance($module);
		$module_tablename = $focus->table_name;//当前模块的主表名
		$module_tableindex = $focus->table_index;//当前模块的主表的ID
		$focus->getModuleStatic('ModTracker');//字段修改日志
		$relatedinfoset = $this->relatedinfoset_arr;// 2024-7-12 xxy XUQIU20240521-04 模块分配和共享的时候，可以出现弹窗去选择分配哪些模块的单据
		$reldata_scope = '';
		$record_oldsmowner = '';
		if(!empty($relatedinfoset)){
			$reldata_scope = $relatedinfoset['reldata_scope'];
			$record_oldsmowner = $relatedinfoset['oldsmowner'];
		}
		//获取模块相关信息关联模块
		$module_tabid = getTabid($module);

		$modulelist = $this->relatedinfoset_arr['modulelist'];

		if(!empty($modulelist)){
			foreach($modulelist as $related_tabid => $related_moduleinfo){
				// $related_tabid = $related_moduleinfo['tabid'];
				if($related_tabid == $module_tabid)continue;
				$relatedModuleName = $related_moduleinfo['name'];
				//zkt 20230524 BUG0066639  （http://222.173.113.110:10190/crm）8499版本，项目信息表（Potentials）将表单批量分配给某个成员时，点击分配，界面没有反应，不显示分配结果 增加'ReportAnalysis'模块判断
				if(!empty($relatedModuleName) && $relatedModuleName != 'Singin' && $relatedModuleName != 'Customreport' && $relatedModuleName != 'ReportAnalysis'){
					$related_module_obj = CRMEntity::getInstance($relatedModuleName);
					$field_obj=Field::getInstance($relatedModuleName,$adb);
					$columname=$related_module_obj->getSmownerColumName();
				
					//获取LD_field负责人的fieldname
					$fieldname = $field_obj->getFieldInfoBykeyValue('columnname',$columname,'fieldname');
					$relatedEntityname = getEntitynameByModulename($relatedModuleName);
					$related_tablename = $relatedEntityname['tablename'];
					$related_tableindex = $relatedEntityname['entityidfield'];
					$relatedmodule_customtable = $related_module_obj->customFieldTable[0];// 关联模块的自定义表
					$relatedmodule_customtable_index = $related_module_obj->customFieldTable[1];
					$potential_columnname = $field_obj->getFieldInfoBykeyValue('uitype',76,'columnname');// 关联模块的对应关联字段的columnname
					if(!empty($relatedEntityname['entityidfield'])){
						//销售机会相关模块： 联系人、客户
						if($module == 'Potentials'){
							if($relatedModuleName == 'Contacts'){
								$query = 'select contactid from ld_contpotentialrel where potentialid = ?';
							}else if($relatedModuleName == 'Accounts'){
								$query = 'select accountid from ld_accountpotentialrel where potentialid = ?';
							}else if($relatedModuleName == 'Attachment'){
								$query = 'select attachmentsid from ld_attachmentsforbills where record = ? ';
							}else if($relatedModuleName == 'Documents'){
								$query = 'select notesid from ld_senotesrel where crmid = ? ';
							}else if($relatedModuleName == 'Products'){
								$query = 'select productid from ld_seproductsrel where crmid = ?';
							}else{
								$query = "SELECT $related_tablename.$related_tableindex from $related_tablename ";
								if($potential_columnname != $module_tableindex){
									$query .= " LEFT JOIN $relatedmodule_customtable ON $relatedmodule_customtable.$relatedmodule_customtable_index = $related_tablename.$related_tableindex";
								}
								if(!empty($potential_columnname)){
									$query .= " where $potential_columnname = ? ";
								}else{
									$query .= " where $module_tableindex = ? ";
								}
							}
						}else{
							if($relatedModuleName == 'Products'){
								$query = 'select productid from ld_seproductsrel where crmid = ?';
							}else if($relatedModuleName == 'Documents'){
								$query = 'select notesid from ld_senotesrel where crmid = ?';
							}else{
								$query = "SELECT $related_tablename.$related_tableindex from $related_tablename ";
								if($potential_columnname != $module_tableindex){
									$query .= " LEFT JOIN $relatedmodule_customtable ON $relatedmodule_customtable.$relatedmodule_customtable_index = $related_tablename.$related_tableindex";
								}
								if(!empty($potential_columnname)){
									$query .= " where $potential_columnname = ? ";
								}else{
									$query .= " where $module_tableindex = ? ";
								}
							}
						}
						//echo $relatedModuleName;echo '<br><br>';
						$related_result = $adb->pquery($query,array($recordid));
						//echo $related_result->sql;echo '<br><br>';
						$related_num_rows = $adb->num_rows($related_result);
						if($related_num_rows > 0){
							for($j = 0; $j<$related_num_rows; $j++){
								$rec_id = $adb->query_result($related_result,$j,0);
								//echo $rec_id;echo '<br><br>';
								//获取单据变更前的负责人ID
								$getSmownerId = 'select smownerid from '.$related_tablename.' where '.$related_tableindex.' = ? limit 1';
								$SmownerResult = $adb->pquery($getSmownerId,array($rec_id));
								//echo $SmownerResult->sql;echo '<br><br>';
								$old_smownerid = $adb->query_result($SmownerResult,0,0);
								if($reldata_scope == 'samesmowner' && !empty($record_oldsmowner)){// 旧负责人
									if($record_oldsmowner != $old_smownerid){// 相关信息，仅变更与客户同销售负责人的数据
										continue;
									}
								}
								if($old_smownerid != $assigned_user_id){
									$adb->pquery("update $related_tablename set smownerid = $assigned_user_id where $related_tableindex = " . $rec_id);
									$focus->modstatic->saveFieldLogOne($relatedModuleName,$fieldname,$rec_id,$old_smownerid, $assigned_user_id);
									//系统操作日志-分配
									cls_OperationLogs::saveLogs($relatedModuleName,'Allocate',$rec_id,'',staticModTracker::$lastinsertid);
								}
							}
						}
					}
				}
				
			}
		}
	}
	/*
	 * editor : gyq_02
	 * function : 更新对应客户最新进度和最新联系日期，销售机会最新联系日期
	 * date   : 2016  1  22
	 * explain :
	 *      $id    ： accountid，存有更改前后客户ID或类似ID数组
	 *      $table : 待更新的数据表名，例如ld_account
	 * */
	function updateRelatedTableInfo($table,$id)
	{
		global $adb;
		//$this->insertDb();
		if(sizeof($id) > 0)
		{

			foreach($id as $accountid) {

				if(empty($accountid))
				{
					continue;
				}
				$condition = " accountid=$accountid ";

				$sql = "SELECT potentialid FROM ld_potential
                    WHERE deleted=0 and " . $condition . " ORDER BY createdtime desc LIMIT 1;";

				$result = $adb->pquery($sql);

				if ($adb->num_rows($result) > 0) {
					$potentialid = $adb->query_result($result, 0, 'potentialid');

					$sql = "update $table set  ";

					$update_params = array();

					if ($potentialid > 0 && $table == 'ld_account') {

						$sql .= ' potentialid=? ';

						$update_params[] = $potentialid;

					}

					if (is_array($update_params) && sizeof($update_params) > 0) {
						$sql .= ' where accountid=? ;';

						$update_params[] = $accountid;

						$adb->pquery($sql, $update_params);
					}

				} else {

					$sql = "update $table set potentialid=? where accountid=? ";

					$adb->pquery($sql, array(null, $accountid));

				}
			}
		}
		Potentials::$mass_before_focus=array();
	}
    function restore($module, $potentialid)
    {
            global $adb;
            parent::restore($module,$potentialid);
            if(array_key_exists('account_id',$this->column_fields))
            {
                $sql='select accountid from ld_potential where potentialid=?';
                $result=$adb->pquery($sql,array($potentialid));
                if($adb->num_rows($result)>0)
                {
                    $accountid=$adb->query_result($result,0,0);
                }
                
            }
            if($accountid>0)
            {
                $this->updateRelatedTableInfo('ld_account',array($accountid));
            
            }
    }
	/**
	 * editor  : gyq_02
	 * date    : 2016 1 26
	 * explain : 批量编辑保存后处理
	 *          $ids : 被批量选择的记录ID数组，例如联系记录
	 *          $mass_before_focus ： 保存前序时簿记录信息
	 * */
	function massEdit_save_after($module,$ids)
	{

		$accountids = array();
		foreach( $ids as $contactrecord )
		{
			$ids_before= Potentials::$mass_before_focus[$contactrecord];
			$accountids[$ids_before['account_id']]=$ids_before['account_id'];
		}
		if(sizeof($ids)>0){

			if($_REQUEST['account_id_mass_edit_check']!=''){
				$accountids[$_REQUEST['account_id_mass_edit_check']]=$_REQUEST['account_id_mass_edit_check'] ;
			}
			if(sizeof($accountids) > 0)
				$this->updateRelatedTableInfo('ld_account',$accountids);
		}
	}

	/*
     * editor : gyq_02
     * explain : 批量操作保存前，以记录ID在$mass_before_focus中存储修改前信息
     * */
	function massEdit_save_before($module,$contactrecord)
	{
		Potentials::$mass_before_focus[$contactrecord[0]]=$this->column_fields;
	}

	/*
     * editor : gyq_02
     * explain : 批量删除后处理
     * */
	function massDelete_after($module,$ids)
	{
		$accountids = array();
		global $adb;
		$contactrecordids=implode(",",$ids);
		$sql='select accountid  from ld_potential  where potentialid in( ' .$contactrecordids.' )';
		$result=$adb->pquery($sql,array());
		for( $i=0; $i<$adb->num_rows($result);$i++ )
		{
			$accountid=$adb->query_result($result,$i,'accountid');
			if(!empty($accountid))
				$accountids[$accountid]=$accountid;
		}
		if(sizeof($accountids)>0) {
			$this->updateRelatedTableInfo('ld_account', $accountids);
		}
	}

		
	/** Function to create list query
	* @param reference variable - where condition is passed when the query is executed
	* Returns Query.
	*/
	function create_list_query($order_by, $where)
	{
		global $current_user;
		require('user_privileges/user_privileges_'.$current_user->id.'.php');
        	$tab_id = getTabid("Potentials");
	
		$account_required = preg_match("/accounts\.name/", $where);

		if($account_required)
		{
			$query = "SELECT ld_potential.potentialid,  ld_potential.potentialname, ld_potential.dateclosed FROM ld_potential, ld_account ";
			$where_auto = "account.accountid = ld_potential.accountid AND ld_crmentity.deleted=0 ";
		}
		else
		{
			$query = 'SELECT ld_potential.potentialid, ld_potential.potentialname, ld_crmentity.smcreatorid, ld_potential.closingdate FROM ld_potential inner join ld_crmentity on ld_crmentity.crmid=ld_potential.potentialid LEFT JOIN ld_groups on ld_groups.groupid = ld_crmentity.smownerid left join ld_users on ld_users.id = ld_crmentity.smownerid ';
			$where_auto = ' AND ld_crmentity.deleted=0';
		}

		$query .= $this->getNonAdminAccessControlQuery('Potentials',$current_user);
		if($where != "")
			$query .= " where $where ".$where_auto;
		else
			$query .= " where ".$where_auto;
		if($order_by != "")
			$query .= " ORDER BY $order_by";
		return $query;
	}


    
    
    function save($module_name, $fileid = '')
    {
        $this->setSmOldOwnerID();
        return parent::save($module_name);
    }

    

	/**
	 * Move the related records of the specified list of id's to the given record.
	 * @param String This module name
	 * @param Array List of Entity Id's from which related records need to be transfered
	 * @param Integer Id of the the Record to which the related records are to be moved
	 */
	function transferRelatedRecords($module, $transferEntityIds, $entityId) {
		global $adb;
		$rel_table_arr = Array("Activities"=>"ld_seactivityrel","Contacts"=>"ld_contpotentialrel","Products"=>"ld_seproductsrel",
						"Attachments"=>"ld_seattachmentsrel","Quotes"=>"ld_quotes","SalesOrder"=>"ld_salesorder",
						"Documents"=>"ld_senotesrel","Accounts"=>"ld_accountpotentialrel");

		$tbl_field_arr = Array("ld_seactivityrel"=>"activityid","ld_contpotentialrel"=>"contactid","ld_seproductsrel"=>"productid",
						"ld_seattachmentsrel"=>"attachmentsid","ld_quotes"=>"quoteid","ld_salesorder"=>"salesorderid",
						"ld_senotesrel"=>"notesid","ld_accountpotentialrel"=>"accountid");

		$entity_tbl_field_arr = Array("ld_seactivityrel"=>"crmid","ld_contpotentialrel"=>"potentialid","ld_seproductsrel"=>"crmid",
						"ld_seattachmentsrel"=>"crmid","ld_quotes"=>"potentialid","ld_salesorder"=>"potentialid",
						"ld_senotesrel"=>"crmid","ld_accountpotentialrel"=>"potentialid");

		foreach($transferEntityIds as $transferId) {
			foreach($rel_table_arr as $rel_module=>$rel_table) {
				$id_field = $tbl_field_arr[$rel_table];
				$entity_id_field = $entity_tbl_field_arr[$rel_table];
				// IN clause to avoid duplicate entries
				$sel_result =  $adb->pquery("select $id_field from $rel_table where $entity_id_field=? " .
						" and $id_field not in (select $id_field from $rel_table where $entity_id_field=?)",
						array($transferId,$entityId));
				$res_cnt = $adb->num_rows($sel_result);
				if($res_cnt > 0) {
					for($i=0;$i<$res_cnt;$i++) {
						$id_field_value = $adb->query_result($sel_result,$i,$id_field);
						$adb->pquery("update $rel_table set $entity_id_field=? where $entity_id_field=? and $id_field=?",
							array($entityId,$transferId,$id_field_value));
					}
				}
			}
		}
	}



	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
			"Calendar" => array("ld_seactivityrel"=>array("crmid","activityid"),"ld_potential"=>"potentialid"),
			"Products" => array("ld_seproductsrel"=>array("crmid","productid"),"ld_potential"=>"potentialid"),
			"Quotes" => array("ld_quotes"=>array("potentialid","quoteid"),"ld_potential"=>"potentialid"),
			"SalesOrder" => array("ld_salesorder"=>array("potentialid","salesorderid"),"ld_potential"=>"potentialid"),
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_potential"=>"potentialid"),
			"Accounts" => array("ld_potential"=>array("potentialid","accountid")),
		);
		return $rel_tables[$secmodule];
	}

	// Function to unlink all the dependent entities of the given Entity by Id
	function unlinkDependencies($module, $id) {
		
	

		parent::unlinkDependencies($module, $id);
	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	   	
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts') {
            $sql = 'DELETE FROM ld_accountpotentialrel WHERE potentialid=? AND accountid=?';
			$this->db->pquery($sql, array($id, $return_id));
            $this->trash($this->module_name, $id);
			$this->trash($this->module_name, $id);
		} elseif($return_module == 'Campaigns') {
			$sql = 'UPDATE ld_potential SET campaignid = ? WHERE potentialid = ?';
			$this->db->pquery($sql, array(null, $id));
		} elseif($return_module == 'Products') {
			$sql = 'DELETE FROM ld_seproductsrel WHERE crmid=? AND productid=?';
			$this->db->pquery($sql, array($id, $return_id));
		} elseif($return_module == 'Contacts') {
			$sql = 'DELETE FROM ld_contpotentialrel WHERE potentialid=? AND contactid=?';
			$this->db->pquery($sql, array($id, $return_id));
            $this->trash($this->module_name, $id);
		

		} else {
			$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
			$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
			$this->db->pquery($sql, $params);
		}
	}

	function save_related_module($module, $crmid, $with_module, $with_crmids) {
		$adb = PearDatabase::getInstance();
        
		if(!is_array($with_crmids)) $with_crmids = Array($with_crmids);
		foreach($with_crmids as $with_crmid) {
			if($with_module == 'Contacts') { //When we select contact from potential related list
				$sql = "insert into ld_contpotentialrel values (?,?)";
				$adb->pquery($sql, array($with_crmid, $crmid));

			} elseif($with_module == 'Products') {//when we select product from potential related list
				$sql = "insert into ld_seproductsrel values (?,?,?)";
				$adb->pquery($sql, array($crmid, $with_crmid,'Potentials'));

			} 
            elseif($with_module == 'Accounts') 
            {
				$checkSql = "select count(1) as count from ld_accountpotentialrel WHERE potentialid = $crmid AND accountid = $with_crmid ";
                $checkResult = $adb->pquery($checkSql,array());
                if($adb->query_result($checkResult,0,"count") == 0)
                {
                    $adb->pquery("insert into ld_accountpotentialrel values($with_crmid,$crmid)", array());
                }
			}  
            else {
				parent::save_related_module($module, $crmid, $with_module, $with_crmid);
			}
		}
        
	}
    /**
     * edit:andrew
     * reason:销售计划回款预测
     * */
 function get_receivablesforecast($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global $adb;
		global $currentModule,$current_user;
		global $list_max_entries_per_page_new_more;
        crm_load_function_file('fetchUserRole','include/utils','UserInfoUtil');
        //获取字段

        $sql = 'SELECT currency_symbol,receivablesforecastid,ld_receivablesforecast.smcreatorid,ld_users.last_name as user_name,F1.last_name as user_name1,potentialsid,amount,total,
        receivablesforecastdate,ld_receivablesforecast.modifiedtime,ld_receivablesforecast.createdtime FROM ld_receivablesforecast LEFT JOIN ld_users ON id=ld_receivablesforecast.smcreatorid
        LEFT JOIN ld_users AS F1 ON F1.id=ld_receivablesforecast.modifiedby WHERE potentialsid = '.$id.' ORDER BY ld_receivablesforecast.createdtime ';
      //  echo $sql;die();
		$count_result = $adb->query( mkCountQuery( $sql));
		$noofrows = $adb->query_result($count_result,0,'count');
		global $related_left_type;
		if($related_left_type == 3){//获取相关信息条数
			$related_entries = array();
			$related_entries['relcount'] = $noofrows;
			return $related_entries;
		}
		if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
			$start = vtlib_purify($_REQUEST['start']);
			if($start == 'last'){
				if($noofrows > 0){
					$start = ceil($noofrows/$list_max_entries_per_page_new_more);
				}
			}
			if(!is_numeric($start)) $start = 1;
			elseif($start < 1) $start = 1;
			$start = ceil($start);
		}else{
			$start = 1;
		} 
            
          
            $SQLs="select ld_potential.amount-sum(ifnull(ld_receivablesforecast.amount,0)) as yuceyue,ld_potential.amount
                    from  ld_potential LEFT JOIN ld_receivablesforecast
                    on ld_potential.potentialid=ld_receivablesforecast.potentialsid 
                    WHERE ld_potential.potentialid=".$_REQUEST['record']."
                    GROUP BY ld_receivablesforecast.potentialsid";
           $receivablesforecastresult=$adb->pquery($SQLs,array());  
         //  echo   $adb->num_rows($receivablesforecastresult)."-".$adb->query_result($receivablesforecastresult,0,'yuceyue');
                  $noreceivablesforecastamount = $adb->query_result($receivablesforecastresult,0,'yuceyue');
                $amount = $adb->query_result($receivablesforecastresult,0,'amount');
                    if($noreceivablesforecastamount == 0)
                    {
                        $typeids=0;
                    }
                    else if($noreceivablesforecastamount < 0)
                    {
                        $typeids=0;
                    }elseif($amount<=0){
                        $typeids=0;
                    }
                    else
                    {
                        $typeids=1;
                    }   
                
               
        $button .= '<a href="javascript:;"
        onclick="NewReceivablesforecast(this,\'Createreceivablesforecast\','.$id.','.$typeids.',1);" id="createPaymentid"><b class="icon-homeimg icon-plus"></b><span>'
                .getFixedLabel('CREATE').'</span></a>';
		

        
		global $related_left_start;
		$related_left_start = $start;
		$limstart=($start-1)*$list_max_entries_per_page_new_more;
		$sql .= ' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';
        
        $header = array(
			'<span title='.getFixedLabel('ExpectedDate').'>'.getFixedLabel('ExpectedDate').'</span>',
			'<span title='.getFixedLabel('ExpectedAmount').'>'.getFixedLabel('ExpectedAmount').'</span>',
			'<span title='.getFixedLabel('Person_in_charge').'>'.getFixedLabel('Person_in_charge').'</span>',
			'<span title='.getFixedLabel('Createtime1').'>'.getFixedLabel('Createtime1').'</span>',
			'<span title='.getFixedLabel('LBL_CHANGED_BY').'>'.getFixedLabel('LBL_CHANGED_BY').'</span>',
			'<span title='.getFixedLabel('MODIFIEDTIME').'>'.getFixedLabel('MODIFIEDTIME').'</span>',
			'<span title='.getFixedLabel('OPERATING').'>'.getFixedLabel('OPERATING').'</span>'
		);
        $result = $adb->pquery($sql,array());
        $num_rows=$adb->num_rows($result);

        if($num_rows>0)
        {
            for($i=0;$i<$num_rows;$i++)
            {
                $listview_entrie = array();
                $urole = fetchUserRole($current_user->id);
                $crole = fetchUserRole($adb->query_result($result,$i,'smcreatorid'));
                $sqlrole = "SELECT 1 FROM ld_role WHERE roleid='$crole' AND parentrole LIKE '%$urole%'";
                $results = $adb->pquery($sqlrole,array());
                $num_rowss=$adb->num_rows($results);
 
                $dids[$i] = $adb->query_result($result,$i,'receivablesforecastid');
                $listview_entrie[]= '<span title='.$adb->query_result($result,$i,'receivablesforecastdate').'>' . $adb->query_result($result,$i,'receivablesforecastdate') . '</span>';
                $listview_entrie[]=  '<span title='.$adb->query_result($result,$i,'currency_symbol').'>' . $adb->query_result($result,$i,'currency_symbol').$adb->query_result($result,$i,'amount') . '</span>';
                $listview_entrie[]=  '<span title='.$adb->query_result($result,$i,'user_name').'>' . $adb->query_result($result,$i,'user_name') . '</span>';
                $listview_entrie[]=  '<span title='.$adb->query_result($result,$i,'createdtime').'>' . $adb->query_result($result,$i,'createdtime') . '</span>';
                $listview_entrie[]=  '<span title='.$adb->query_result($result,$i,'user_name1').'>' . $adb->query_result($result,$i,'user_name1') . '</span>';
                $listview_entrie[]=  '<span title='.$adb->query_result($result,$i,'modifiedtime').'>' . $adb->query_result($result,$i,'modifiedtime') . '</span>';

                if($num_rows>0||$current_user->is_admin=='on'||$current_user->id==$adb->query_result($result,$i,'smcreatorid')){
                $listview_entrie[]= "<a href=\"javascript:editre(this,$dids[$i])\" 
                class='Anu3_a'>".getFixedLabel('EDIT')."</a>
                <a href=\"javascript:deletere($dids[$i],$id)\"  
                class='Anu3_a'>".getFixedLabel('DELETE')."</a>";
                }

                $listview_entries[] = $listview_entrie;
            }
        }
        
		$navigationOutput = Array();$url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
		$navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'Potentials',$id);
        
        $return_value = array('header'=>$header,'entries'=>$listview_entries,'navigation'=>$navigationOutput);
		$return_value['CUSTOM_BUTTON'] = $button;
		return $return_value;
	}
   
    public function AddReminds($RemindsContent,$datetime,$userid,$recordid)
    {
       return  parent::AddReminds($RemindsContent,$datetime,$userid,$recordid);
    }
	public function addComboxIntoDataBase($table_name='')
	{             
		if(!array_key_exists("sales_stage",$this->column_fields))
		{
			 return ;
		}
		global $adb,$current_user;
		if($table_name == 'ld_potential')
		{
			 $dbquery = 'select sales_stage from ld_potential where potentialid = ?';
			$sales_stage = $adb->query_result($adb->pquery($dbquery, array($this->id)), 0, 'sales_stage');
			if ($sales_stage != $_REQUEST['sales_stage'] && $_REQUEST['sales_stage'] != '' && $sales_stage != $this->column_fields['sales_stage'] && $this->column_fields['sales_stage'] != '') 
			{
				crm_load_class_file('DateTimeField','include/fields');
				$date_var = date("Y-m-d H:i:s");
				$closingDateField = new DateTimeField($this->column_fields['closingdate']);
				$closingdate = ($_REQUEST['ajxaction'] == 'DETAILVIEW') ? $this->column_fields['closingdate'] : $closingDateField->getDBInsertDateValue();
				$sql = "insert into ld_potstagehistory values(?,?,?,?,?,?,?,?,?,?)";
				$params = array('', $this->id, $this->column_fields['amount'], decode_html($sales_stage), $this->column_fields['probability'], 0, $adb->formatDate($closingdate, true), $adb->formatDate($date_var, true),$this->column_fields['sales_stage'],$current_user->id);
				$adb->pquery($sql, $params);
			}
		}
	   
	}
	/*
	*edit: 段 中孚特殊控制
	*date: 2021/06/08
	*reason: 根据用户id得出所在部门的'事业部/大区总经理'
	*/
    public function getUserForGroupId($userid=''){
        global $adb;
        $sql = "SELECT ld_users.id from ld_users INNER JOIN ld_profile on ld_users.profileid = ld_profile.profileid 
                where ld_profile.profilename = '事业部/大区总经理'
                and ld_users.groupid = (select groupid from ld_users where ld_users.id =?)";
        $params = array($userid);
        $result = $adb->pquery($sql,$params);
        $manegeid = $adb->query_result($result,0,'id');
        return $manegeid;
    }
	/*
	*edit: chj
	*date: 2020/11/19
	*reason: 判断销售机会序时簿是否显示客户漏斗
	*/
	public function getCustomerFunnelForPresence($focus){
		if(isset($focus->column_fields['sales_stage']) && isset($focus->column_fields['oldcustomer_marketing'])){
			return 'yes';
		}
		return 'no';
	}
	  //销售机会创建汇款预测判断
	  public function Createreceivablesforecast($record){
		global $adb;
		    if(empty($_REQUEST['record']))
            {
                return '';
            }
			$sqlpotential='SELECT
				if(currency_id > 1,amount/conversion_rate,amount)  as amount
			FROM
				ld_potential
			WHERE
				potentialid = ?';

			$potentialresult=$adb->pquery($sqlpotential,array($record));
			$amount=$adb->query_result($potentialresult,0,"amount");

			$sql="SELECT
				if(currency_id>1,ifnull(amount, 0)*conversion_rate,ifnull(amount, 0)) as amount,
				potentialsid,
				periodtime
			FROM
				ld_receivablesforecast 
			where potentialsid = ".$_REQUEST['record'].' group by periodtime order by periodtime asc';

			$receivablesforecastresult=$adb->pquery($sql,array());
			if($adb->num_rows($receivablesforecastresult)>0)
			{
				for($i=0;$i<$adb->num_rows($receivablesforecastresult);$i++)
				{   
					$receivablesforecastamount+=$adb->query_result($receivablesforecastresult,$i,0);
				}
				$noreceivablesforecastamount=$amount-$receivablesforecastamount;    
			}else{
				$noreceivablesforecastamount=$amount;
			}

			if($amount<=0){
				return 2;
			}
			elseif($adb->num_rows($receivablesforecastresult)<=0&&$amount>0)
			{
				return 1;
				
			}
			else
			{
				if($noreceivablesforecastamount == 0)
				{
					return 0;
				}
				else if($noreceivablesforecastamount < 0)
				{
					return 0;
				}
				else
				{
					return 1;
				}   
			}
		}
		//editor:gyq_76 reason:呼叫中心来电弹屏增加创建销售机会 2018/8/21 17:31
    public function get_CallButler($id, $cur_tab_id, $rel_tab_id, $actions=false) {
        global $adb;
        global $currentModule;
        global $list_max_entries_per_page_new_more;
        $root_dir_index= dirname(dirname(dirname(__FILE__)));
        require_once($root_dir_index.'/CallCenter/lib/jiuWei.php');
        $jiuObj = jiuWei::autoLoad();
        if($jiuObj->deploy_switch == 5 || $jiuObj->deploy_switch == 6 || $jiuObj->deploy_switch == 4){
            return $jiuObj->showCallRecords($id, $cur_tab_id, $rel_tab_id, $actions,'Potentials');
        }
        crm_load_class_file('fieldValueUitype','include/fields/');
        $sql = 'select T3.last_name,T1.begintime,T1.calltype,T1.phone,T1.`status`,T1.time,T1.soundrecordingfile   
        from ld_callbutler as T1 
        left join ld_troubletickets as T2 on  T1.ticketid = T2.ticketid 
        left join ld_users as T3 on T1.userid = T3.id
        where T1.ticketid > 0 and T1.ticketid = '.$id;

        $count_result = $adb->query( mkCountQuery( $sql));
        $noofrows = $adb->query_result($count_result,0,'count');
        global $related_left_type;
        if($related_left_type == 3){//获取相关信息条数
            $related_entries = array();
            $related_entries['relcount'] = $noofrows;
            return $related_entries;
        }
        if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
            $start = vtlib_purify($_REQUEST['start']);
            if($start == 'last'){
                if($noofrows > 0){
                    $start = ceil($noofrows/$list_max_entries_per_page_new_more);
                }
            }
            if(!is_numeric($start)) $start = 1;
            elseif($start < 1) $start = 1;
            $start = ceil($start);
        }else{
            $start = 1;
        }
        global $related_left_start;
        $related_left_start = $start;
        $limstart=($start-1)*$list_max_entries_per_page_new_more;
        $sql .= ' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';
        //用户、时间、类型、电话号码、状态、时长、操作
        //$header = array(getFixedLabel('USERS'),getFixedLabel('TIMES'),getFixedLabel('SERVICECONTRACTSTYPE'),getFixedLabel('PhoneNumber'),getFixedLabel('STATUS'),getFixedLabel('DURATION'),getFixedLabel('OPERATING'));
        $header = array(getFixedLabel('USERS'),getFixedLabel('TIMES'),getFixedLabel('SERVICECONTRACTSTYPE'),getFixedLabel('PhoneNumber'),getFixedLabel('DURATION'),getFixedLabel('OPERATING'));
        $result = $adb->pquery($sql,array());
        $num_rows=$adb->num_rows($result);
        if($num_rows>0)
        {
            for($i=0;$i<$num_rows;$i++)
            {
                $listview_entrie = array();
                $soundrecordingfile = $adb->query_result($result,$i,'soundrecordingfile');
                $soundrecordingfilenew = str_replace("\\","/",$soundrecordingfile);

                $listview_entrie[]= $adb->query_result($result,$i,'last_name');
                $listview_entrie[]= $adb->query_result($result,$i,'begintime');
                $listview_entrie[]= $adb->query_result($result,$i,'calltype');
                $listview_entrie[]= fieldValueUitype::setReportMobileStyle($adb->query_result($result,$i,'phone'));
                //$listview_entrie[]= $adb->query_result($result,$i,'status');
                $time = $adb->query_result($result,$i,'time');
                $listview_entrie[]= $time;

                if(empty($time)){
                    $listview_entrie[]= "";
                }else{
                    $listview_entrie[]= "<a class='Anu3_a' onclick='play_click(this,\"".$soundrecordingfilenew."\")' href='###'>".getFixedLabel('PLAYER')."</a>";
                }
                $listview_entries[] = $listview_entrie;
            }
        }
        $navigationOutput = Array();$url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
        $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
        $navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
        $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'CommunicationLog',$id);
        //print_r($listview_entries);
        $return_value = array('header'=>$header,'entries'=>$listview_entries,'navigation'=>$navigationOutput);
        return $return_value;
    }
  function getSelectOption()
{

    $fieldmodules=$this->fieldobj->getModuleFields();

    foreach($fieldmodules as $fieldname=>$fieldinfo)
    {

        if($fieldinfo->getduplicatefield()=='0')
        {
            $selectoption[$fieldinfo->getTableName().'|'.$fieldinfo->getColumnName()] = $fieldinfo->getFieldLabelKey();

        }
    }

    return $selectoption;
}
}
Potentials::require_file();
?>