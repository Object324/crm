<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}

 ********************************************************************************/
 error_reporting(E_ALL^E_NOTICE^E_WARNING);

class Accounts extends CRMEntity {

    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['Accounts']='Accounts';
            

            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
            }

    }
    private $inventoryArray;
    private $publicaccountstatus;//启用公海参数
	private $administrator;//公海超级管理员
    private $adminaccount;//公海管理员
    private $usersaccount;//公海用户
	private $public_account_pool; //所有公海池信息

    //crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListviewUtils');
    public $account_childIds=array();//下级客户id
    public $relatedinfoset_arr = [];// 分配相关信息的设置
    public $accounts_list;
	var $log;
	var $db;
    var $module_name='Accounts';
	var $table_name = "ld_account";
	var $table_index= 'accountid';//主表主键
    var $table_code='account_no';//表编号字段(审批中心)
	//'ld_accountbillads','ld_accountshipads',
	var $tab_name = Array('ld_crmentity','ld_account','ld_accountscf');
    //定义各个表主键
	//'ld_accountbillads'=>'accountaddressid','ld_accountshipads'=>'accountaddressid',
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_account'=>'accountid','ld_accountscf'=>'accountid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_accountscf', 'accountid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    var $IsCustomModule = true;//客户查重
	var $column_fields = Array();

	var $sortby_fields = Array('accountname','bill_city','website','phone','smownerid');
    var $smoldOwnerID="";//修改前负责人ID
	  //管理模块
    var $relatedtab=array('accounts'=>'','users'=>'','company'=>'');

	var $list_link_field= 'accountname';
	var $search_fields = Array(
			'Account Name'=>Array('ld_account'=>'accountname'),
			'Billing City'=>Array('ld_account'=>'bill_city'),
			'Assigned To'=>Array('ld_crmentity'=>'smownerid'),
			);

	var $search_fields_name = Array(
			'Account Name'=>'accountname',
			'Billing City'=>'bill_city',
			'Assigned To'=>'assigned_user_id',
			);
	// This is the list of lingdang_fields that are required
	var $required_fields =  array();

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
    //比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'accountname');

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('accountname','account_type','industry','annualrevenue','phone','email1','rating','website','fax');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'accountname';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
    //拼音查询字段
	var $def_basicsearch_col = 'accountname';
    var $noEditFieldDefaultValue=array();//所有非编辑字段
    var $moduleName='Accounts';
    /**
     * 公海管理员参数
     * yes:启用,no:不启用
     * edit:can
     * date:20130716
     * */
   function  setaccountstatus($status)
   {
    $this->publicaccountstatus=$status;
   }
   function getaccountstatus()
   {
     return $this->publicaccountstatus;
   }
   //公海超级管理员
   function  setaccount_administrator($administrator)
   {
    $this->administrator=$administrator;
   }
   function getaccount_administrator()
   {
     return $this->administrator;
   }
   //所有公海池
   function  setpublicaccountpool($public_account_pool)
   {
		$this->public_account_pool=$public_account_pool;
   }
   function getpublicaccountpool()
   {
     return $this->public_account_pool;
   }
   /**
    * 公海管理员用户
    * edit:can
    * date:20130716
    * */
   function setadminaccount($adminaccount)
   {
      $this->adminaccount=$adminaccount;
   }
   function getadminaccount()
   {
    return $this->adminaccount;
   }
   function setuseraccount($useraccount)
   {
        $this->usersaccount=$useraccount;

   }
   function getuseraccount()
   {
    return $this->usersaccount;
   }
	function __construct() {
        /* gyq */

		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('Accounts',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $cachedModuleFields=$this->fieldobj->getFieldArray('columnname');

    /*    foreach($cachedModuleFields as $fieldinfo)
         {
             if (isset($fieldinfo['columnname'])) {
                 $this->sortby_fields[]=$fieldinfo['columnname'];
             }

		}*/

         /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Accounts');
        $this->list_link_field=$entityname['fieldname'];

	}
     /**
     * edit:cyb
     * date:2015-10-27
     * reason：获取客户模块下查重按钮里边查重字段下拉框取值。
     * */
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
  
	//更新客户定位地址、经纬度
	function updateAccountAddress($accountid){
        //duan 20220816 考虑到根据地址获取经纬度存在不精确的问题(泰康制药问题))
        //增加优化，如果通过移动端的定位功能获取到经纬度，则不需要重新计算经纬度（在详细地址不修改的情况下）
        global $weixin_user,$adb;
        if(!empty($weixin_user)&&$_REQUEST['locationaddress_lat']!=''&&$_REQUEST['locationaddress_lng']!=''){
            $tablename = $this->table_name;
            $tableindex = $this->table_index;
            $address = $_REQUEST['locationaddress'];
            $latitude = $_REQUEST['locationaddress_lat'];
            $longtitude = $_REQUEST['locationaddress_lng'];
            $update_address_sql = "update $tablename set location_address =?, longtitude = ?, latitude = ? where $tableindex = ?";
            $adb->pquery($update_address_sql,array($address,$longtitude,$latitude,$accountid));
            return ;
        }
        //31591: 客户新增保存后，获取地址经纬度判断服务器是否能上网
        if(file_exists(globalStatic::$root_directory.'modules/Accounts/accountaddress.txt'))
        {
            $filehandler=file_get_contents(globalStatic::$root_directory.'modules/Accounts/accountaddress.txt');
            $handlerinfos=explode("\r\n",(string)$filehandler);
          
            $date=$handlerinfos[0];
            $tmpcheck=$handlerinfos[1];
            if($date!=date("Y-m-d"))
            {
                file_put_contents(globalStatic::$root_directory.'modules/Accounts/accountaddress.txt',date("Y-m-d"));
                //$check = @fopen('http://www.baidu.com',"r");  
                $check = @fopen('https://apis.map.qq.com',"r"); 
                if($check){  
                    file_put_contents(globalStatic::$root_directory.'modules/Accounts/accountaddress.txt',"\r\n".'yes',FILE_APPEND); 
                }else{  
                    file_put_contents(globalStatic::$root_directory.'modules/Accounts/accountaddress.txt',"\r\n".'no',FILE_APPEND);
                    return ; 
                } 
            }
            
            if($tmpcheck=='no')
            {
                return ;
            }
        }
        else
        {
            file_put_contents(globalStatic::$root_directory.'modules/Accounts/accountaddress.txt',date("Y-m-d"));
            
             //$check = @fopen('https://www.baidu.com/',"r");  
             $check = @fopen('https://apis.map.qq.com',"r"); 
            if($check){  
             file_put_contents(globalStatic::$root_directory.'modules/Accounts/accountaddress.txt',"\r\n".'yes',FILE_APPEND); 
            }else{  
             file_put_contents(globalStatic::$root_directory.'modules/Accounts/accountaddress.txt',"\r\n".'no',FILE_APPEND);
             return ; 
            }    
        }
        $this->updateAccountAddressWithoutCheckNet($accountid);
	}
    
    function updateAccountAddressWithoutCheckNet($accountid){
        global $adb;
        $query = "select CONCAT(
					IFNULL(IF(LOCATE(ld_account.bill_state,ld_account.bill_street)>0 or LOCATE(ld_account.bill_state,ld_account.bill_city)>0 ,'',ld_account.bill_state),''),
					IFNULL(IF(LOCATE(ld_account.bill_city,ld_account.bill_street)>0,'',ld_account.bill_city),''),
					IFNULL(IF(LOCATE(ld_account.bill_area,ld_account.bill_street)>0,'',ld_account.bill_area),''),
					IFNULL(ld_account.bill_street,'')) as address,accountid,locationaddress from ld_account";
		if(!empty($accountid)){
			$query .= " where accountid = $accountid";
		}
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		for($i=0; $i<$num_rows; $i++){
			$address = $adb->query_result($result,$i,0);
			$accountid = $adb->query_result($result,$i,1);
            //天眼查回填时可能出现地址字段信息为空的情况，改为直接使用定位地址获取经纬度
            $locationaddress = $adb->query_result($result,$i,'locationaddress');
            if(empty($address) && !empty($locationaddress)){
                $address = $locationaddress;    
            }
			if(!empty($address)){
			     //客户表中保存的坐标由百度经纬度改为腾讯经纬度  date:20180525 xxs
				//$accountAddress=file_get_contents("http://api.map.baidu.com/geocoder/v2/?address=".urlencode($address)."&output=json&ak=Hgvb6X18khZw223dBW1hFHuT");
				//$accountAddress=file_get_contents("https://apis.map.qq.com/ws/geocoder/v1/?address=".$address."&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X");
                $accountAddressInfos=getCoordinateByTecentApi($address);
				if(array_key_exists('result',$accountAddressInfos)){
					$longtitude = $accountAddressInfos['result']['location']['lng'];
					$latitude = $accountAddressInfos['result']['location']['lat'];
					$adb->pquery('update ld_account set location_address =?, longtitude = ?, latitude = ? where accountid = ?',array($address,$longtitude,$latitude,$accountid));
				}else{
				    //0033639: 企业微信>灵当CRM>拜访签到>添加拜访客户：结果地址没有改变。
                    $adb->pquery('update ld_account set location_address =?, longtitude = ?, latitude = ? where accountid = ?',array($address,'','',$accountid));
				}
            }else{
			     $adb->pquery('update ld_account set location_address =?, longtitude = ?, latitude = ? where accountid = ?',array($address,'','',$accountid));
			}
		}
    }
    
    /**
     * 分配负责人，修改创建人
     * $type:操作类型:allocate,changecreator
     * */
    function massChangeUser_after($module,$ids,$type)
    {  
        global $current_user,$adb;
        if(empty($ids)||$ids==''||$module == 'ServiceCharge')
        {
            return ;
        }
        if(is_array($ids))
        {
            $ids=implode(',',$ids);
        }
        $relatedinfoset = $this->relatedinfoset_arr;// 2024-7-12 xxy XUQIU20240521-04 模块分配和共享的时候，可以出现弹窗去选择分配哪些模块的单据
        $sharerelatedinfo = 'no';
        $shareoldsmowner = '';
        $relmodule_scope = '';
        $relmodule_selectedtabid_str = '';
        $reldata_scope = '';
        $smowner_sql = '';
        if(!empty($relatedinfoset)){
            $sharerelatedinfo = $relatedinfoset['sharerelatedinfo'];
            $shareoldsmowner = $relatedinfoset['shareoldsmowner'];
            $relmodule_scope = $relatedinfoset['relmodule_scope'];
            $relmodule_selectedtabid_str = $relatedinfoset['relmodule_selectedtabid_str'];
            $reldata_scope = $relatedinfoset['reldata_scope'];
            $oldsmowner = $relatedinfoset['oldsmowner'];
        }else{
            $relatedinfoset['sharerelatedinfo'] = 'no';
        }
        $system_deploy=getSys_deploy(61);
        $sql_field = "SELECT tablename,ld_field.tabid,ld_field.columnname from ld_field LEFT JOIN ld_tab ON ld_tab.tabid = ld_field.tabid
                        where ld_field.uitype=73 and ld_field.presence in(0,2) and ld_tab.presence = 0";
        if($system_deploy['deploy_value']!='none' && $sharerelatedinfo == 'yes')//客户分配时，是否同时分配相关信息 none:否，all:全部模块，part:自选模块
        {
            if($relmodule_scope == 'part'){
                if(!empty($relmodule_selectedtabid_str)){
                    $sql_field .= " and ld_tab.tabid in (". $relmodule_selectedtabid_str .")";
                }else{
                    $sql_field .= " and ld_tab.tabid is null";
                }
            }
            $sql_field .= ' group by ld_field.tabid';
            $result=$adb->pquery($sql_field,array());
            $rows=$adb->num_rows($result);
            
        }
        
        crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
        
        if(strtolower($type)=='allocate')
        {
           
            
            $ids=explode(',',$ids);
            $ids=array_unique($ids);
            require_once  globalStatic::$root_directory.'modules/Users/Group.class.php';
            $group_focus = new Group();
            foreach($ids as $recordid)
            {
                if($system_deploy['deploy_value']!='none' && $sharerelatedinfo == 'yes')//客户分配时，是否同时分配相关信息 none:否，all:全部模块，part:自选模块
                {
                    $sql='select smownerid from ld_account where accountid=? ';
                    $tmpresult=$adb->pquery($sql,array($recordid));
                    $_REQUEST['caterorid']=$adb->query_result($tmpresult,0,'smownerid');

                    // $result=$adb->pquery($sql_field,array());
                    for($i=0;$i<$rows;$i++)
                    {
                        $modulename = getTabname($adb->query_result($result,$i,'tabid'));
                        $account_columnname = $adb->query_result($result,$i,'columnname');// 关联模块的对应关联字段的columnname
                        
                        if($modulename=='' ||!vtlib_isModuleActive($modulename) )
                        {
                            continue;
                        }
                        $relate_focus=CRMEntity::getInstance($modulename);
                        $smownercolumnname=$relate_focus->getSmownerColumName();
                        $fieldinfo=$relate_focus->fieldobj->getFieldInfoobjBykey('columnname',$smownercolumnname);
                        if(!isset($fieldinfo)||$fieldinfo->getFieldName()=='')
                        {
                            continue;
                        }
                        if($reldata_scope == 'samesmowner' && !empty($oldsmowner)){// 旧负责人
                            $smowner_sql = " and $smownercolumnname = $oldsmowner ";// 相关信息，仅变更与客户同销售负责人的数据
                        }

                        $relatedmodule_customtable = $relate_focus->customFieldTable[0];// 关联模块的自定义表
                        $relatedmodule_customtable_index = $relate_focus->customFieldTable[1];
                        $sql = "SELECT $smownercolumnname as smownerid, $relate_focus->table_name.$relate_focus->table_index as crmid FROM $relate_focus->table_name";
                        if($account_columnname != 'accountid'){
                            $sql .= " LEFT JOIN $relatedmodule_customtable ON $relatedmodule_customtable.$relatedmodule_customtable_index = $relate_focus->table_name.$relate_focus->table_index ";
                        }
                        $sql .= " where deleted=0 and $account_columnname = ? ";
                        $sql .= $smowner_sql;

                        $related_result=$adb->pquery($sql,array($recordid));
                        $related_rows=$adb->num_rows($related_result);
                    
                        $fieldname=$fieldinfo->getFieldName();
                        $tablename=$adb->query_result($result,$i,'tablename');//不考虑特殊情况,负责人字段和客户字段都在主表中
                        
                        if($related_rows>0)
                        {
                            
                            $sql="UPDATE $tablename  ";
                            if($account_columnname != 'accountid'){
                                $sql .= " LEFT JOIN $relatedmodule_customtable ON $relatedmodule_customtable.$relatedmodule_customtable_index = $relate_focus->table_name.$relate_focus->table_index ";
                            }
                            $sql .= " set $smownercolumnname =  ?  where $account_columnname = ? and deleted=0";// 相关信息，仅变更与客户同销售负责人的数据
                            $sql .= $smowner_sql;
                            $adb->pquery($sql,array($_REQUEST['caterorid'],$recordid));

                            // file_put_contents(globalStatic::$root_directory.'modules/Accounts/bc.txt',$sql.$_REQUEST['caterorid'].$recordid."\n",FILE_APPEND);
                            
                            $depInfo = $group_focus->getUserGroup($_REQUEST['caterorid']);//变更后的负责人
                            ksort($depInfo);
                            $depname=implode(",",$depInfo);
                               
                            $depId = implode(',',array_keys($depInfo));//部门id

                            foreach($relate_focus->fieldobj->getModuleFields() as $tmp_fieldname => $tmp_fieldinfo)
                            {
                                if($tmp_fieldinfo->getUIType() == 1600)
                                {
                                    $tmp_effect_fieldid = $tmp_fieldinfo->getFieldId();
                                    $result_related_field = $adb->pquery('select * from ld_related_field where effect_fieldid = ?', array($tmp_effect_fieldid));
                                    if ($adb->num_rows($result_related_field) >= 1) {
                                        //检查设置的触发字段类型（负责人、创建人、单选用户类型不处理）
                                        $tmp_trigger_fieldid = $adb->query_result($result_related_field,0,'trigger_fieldid');
                                        $sql_field2 = "select uitype,columnname from ld_field where fieldid = ? and ld_field.presence in (0,2)";
                                        $result_field = $adb->pquery($sql_field2, array($tmp_trigger_fieldid));
                                        $relatetable_name=$relate_focus->table_name;
                                        $relatetable_index=$relate_focus->table_index;
                                        if ($adb->num_rows($result_field) >= 1 && $adb->query_result($result_field,0,'columnname') == $smownercolumnname) {//触发字段为负责人
                                            if($tmp_fieldinfo->isRelatedModuleField())
                                            {

                                                $sql = 'update ' . $tmp_fieldinfo->getTableName() ;
                                                if($tmp_fieldinfo->getTableName()!=$relatetable_name)
                                                    $sql.=' left  join '.$relatetable_name.'  on '.$relatetable_name.'.'.$relatetable_index.'='.$tmp_fieldinfo->getTableName().'.'.$relatetable_index;
                                                    
                                                $sql.=' set ' . $tmp_fieldinfo->getColumnName() . ' = ? where accountid=? and deleted=0 ';
                                            
                                                $adb->pquery($sql, array($depId, $recordid));
                                                
                                            }
                                            
                                        }

                                    }

                                }
                            }
                                
                        }
                        for($j=0;$j<$related_rows;$j++)
                        {
                            $smownerid=$adb->query_result($related_result,$j,'smownerid');
                            $idvalue=$adb->query_result($related_result,$j,'crmid');
                            $relate_focus->getModuleStatic('ModTracker');//修改日志
                            if ($smownerid != $_REQUEST['caterorid']) {
                                $relate_focus->modstatic->saveFieldLogOne($modulename,$fieldname,$idvalue,$smownerid,$_REQUEST['caterorid']);//修改负责人日志
                                //系统操作日志-分配
                                cls_OperationLogs::saveLogs($modulename,'Allocate',$idvalue,'',staticModTracker::$lastinsertid);
                            }
                        }
                        
                    }

                }
                $opdate=date('Y-m-d');
				//chj 2022/7/20 普通客户和公海客户回收规则相关功能优化（杨奇寰） 
                if( isset($_REQUEST['allocatetype']) &&($_REQUEST['allocatetype']==2 ||$_REQUEST['allocatetype']==3))
                {
                    //公海分配和领取才修改日期
                    //edit:can 20220913 公海已分配客户的保护结束日期计算异常：分配日期不应该参与计算，这导致了保护结束日期没有显示真实的回收日期
                   
    				$query = "select publicaccount from ld_account where accountid = ?";
    				//ls 20221130 BUG0059352 分配客户是否分配相关单据 默认开启,批量分配只有第一条分配成功（$result变量名称重复）
    				$result_publicaccount = $adb->pquery($query,array($recordid));
    				if($adb->num_rows($result_publicaccount) >= 1){
    				    require_once(globalStatic::$root_directory.'include/utils/CacheInfo.php');
    					$publicaccount = $adb->query_result($result_publicaccount,0,0);
    					if($publicaccount <= 0){
    						
    					}else{
    						$days=getAccount_set_ProtectedDays("",$recordid);
    						if(!empty($days)){
    							$protectdate=date("Y-m-d",strtotime("$opdate +$days day"));
    						}
    						$sql = 'update '.$this->table_name.' set lastdistributer = ? ,allocatedate=?,protectdate=?,protectstartdate=now() where '.$this->table_index.' = ? ';
    						$adb->pquery($sql,array($current_user->id,$opdate,$protectdate,$recordid));
    					}
                      //  dump($sql);
    					
    				}
                }
                else{
                        require_once(globalStatic::$root_directory.'include/utils/CacheInfo.php');
                        $query = "select publicaccount from ld_account where accountid = ?";
                        $result_publicaccount = $adb->pquery($query,array($recordid));
                        $publicaccount = $adb->query_result($result_publicaccount,0,0);
                      
           	            if($publicaccount <= 0){
    						$days=getAccount_set_normal_ProtectedDays_new("",$recordid);
                          
    						if(!empty($days)){
    							$protectdate=date("Y-m-d",strtotime("$opdate +$days day"));
    						}
                            //如果普通客户
                            $sql = 'update '.$this->table_name.' set lastdistributer = ? ,distributiondate=?,protectdate=?,protectstartdate=now() where '.$this->table_index.' = ? ';
					    	$adb->pquery($sql,array($current_user->id,$opdate,$protectdate,$recordid));
    					}
                        else{
                            //如果是公海客户，
                             $sql = 'update '.$this->table_name.' set lastdistributer = ? ,distributiondate=?, allocatedate=? where '.$this->table_index.' = ? ';
					    	$adb->pquery($sql,array($current_user->id,$opdate,$opdate,$recordid));
                        }
                    	
						
                }
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
                    $objShare->do_share_type($oldsmowner, $recordid, '');
                    $objShare->ReverseWriteTeam_memberID($module,$recordid);//edit：can 20210419 反写模块的团队成员的值 
                }
                //分配后重算保护结束日期
                $this->updateAccountInfo($this->moduleName,$recordid);
            }
            if(!empty($relatedinfoset['type'])){
                setUsersettingByLabel($module,$current_user->id,$relatedinfoset['type'],ldcrm_json_encode($relatedinfoset));
            }
           
        }
    }
	/*
    date：20130326
    reason:负责人更改增加提醒，修改分配人分配时间
    edit by ＬＤ　Ｃａｎ
    */
	function save_module($module) {
        global $adb,$current_user,$weixin_user;
        global  $image_from_module;//edit:can ,判断客户保存照片时，不要保存为联系人的照片
        
        
        if($_REQUEST['upgradefrommodule']!=''&&$_REQUEST['upgradefromid']>0)
        {
            //@edit:liushuai,2020-08-02,reason:【ID1001055】/销售线索增加审批功能(只有审批通过后才能继续升级流程，将从销售线索升级过来的客户做个标识from_leads)
            $adb->pquery('update ld_account set upgrade_source = ?,kis_no = ? where accountid = ?',array('from_leads','from_leads',$this->id));

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
//                    $lastcontactdate = $adb->query_result($result,0,'lastcontactdate'); //最新联系日期
                    //销售线索映射字段优化，创建人可通过映射字段另外指定
                    crm_load_class_file('cls_MappingFields','modules/Leads');
                    $cls_MappingFields = new cls_MappingFields($_REQUEST['upgradefrommodule']);
                    $mappingfields_info = $cls_MappingFields->getMappingFields('Accounts');
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
                    
                    $firstcontactuser = $nextcontactdate = $lastcontactuser = $lastcontactdate = $contactid = '';
                    $first_contactrecords_result = $adb->pquery("SELECT smownerid FROM ld_contactrecords WHERE deleted = 0 AND leads_id = ? 
							ORDER BY contactdate ASC,createdtime ASC limit 1",array($_REQUEST['upgradefromid']));
                    if($adb->num_rows($first_contactrecords_result) >= 1) {
                        $firstcontactuser = $adb->query_result($first_contactrecords_result,0,'smownerid'); //首次联系用户
                    }

                    $last_contactrecords_result = $adb->pquery("SELECT smownerid,contactdate FROM ld_contactrecords WHERE deleted = 0 AND leads_id = ? 
							ORDER BY contactdate DESC,createdtime DESC limit 1",array($_REQUEST['upgradefromid']));
                    if($adb->num_rows($last_contactrecords_result) >= 1) {
                        $lastcontactuser = $adb->query_result($last_contactrecords_result,0,'smownerid'); //最新联系用户
                        $lastcontactdate = $adb->query_result($last_contactrecords_result,0,'contactdate'); //最新联系日期
                    }

                    $next_contactrecords_result = $adb->pquery("SELECT nextcontactdate FROM ld_contactrecords WHERE deleted = 0 AND leads_id = ? AND nextcontactdate <> ''
							ORDER BY contactdate DESC,createdtime DESC limit 1",array($_REQUEST['upgradefromid']));
                    if($adb->num_rows($next_contactrecords_result) >= 1) {
                        $nextcontactdate = $adb->query_result($next_contactrecords_result,0,'nextcontactdate'); //下次回访日期  取有值的最后一条记录
                    }
                    $adb->pquery('update ld_account set smcreatorid = ?,lastcontent = ?,lastcontactdate = ?,firt_concatuser = ?,lastcontactuser = ? where accountid = ?',array($smcreatorid, $lastcontent, $lastcontactdate, $firstcontactuser, $lastcontactuser, $this->id)); //销售线索过来的客户单据需要保持创建人一致



                    if (!empty($nextcontactdate)) {
                        $adb->pquery("update ld_account set nextcontactdate = ? where accountid = ? and (nextcontactdate = '' or nextcontactdate is null)",array($nextcontactdate, $this->id));
                    }
                    $adb->pquery("update ld_contactrecords set accountid = ? where deleted = 0 and leads_id = ?",array($this->id, $_REQUEST['upgradefromid']));//销售线索的跟进记录关联升级后的客户单据

                    //客户的联系人同时更新到 跟进记录的联系人
                    $contactdetails_result = $adb->pquery("SELECT ld_contactdetails.contactid FROM ld_account INNER JOIN ld_contactdetails ON ld_contactdetails.accountid = ld_account.accountid WHERE ld_account.accountid = ? limit 1",array($this->id));
                    if($adb->num_rows($contactdetails_result) >= 1) {
                        $contactid = $adb->query_result($contactdetails_result,0,'contactid'); //联系人
                    }
                    $adb->pquery("update ld_contactrecords set contactid = ? where deleted = 0 and leads_id = ?",array($contactid, $_REQUEST['upgradefromid']));
                
                    //duan 20221107 销售线索升级到客户后，将相关的签到记录一并更新上去
                    $sql = "update ld_singin set entityname = ?,record =?,accountid=?,tabid=? where record =? ";
                    $adb->pquery($sql,array($this->column_fields[$this->list_link_field],$this->id,$this->id,getTabid('Accounts'),$_REQUEST['upgradefromid']));
					
                    // 2024-11-21 xxy 增加字段是否存在判断
                    $potential_focus = CRMEntity::getInstance('Potentials');
                    crm_load_class_file('cls_module_uitype', 'include/fields');
                    $related_uitype_arr = cls_module_uitype::getModuleUitype('Potentials','Leads');
                    if(!empty($related_uitype_arr) && !empty($related_uitype_arr['uitype'])){
                        $related_columnname = $potential_focus->fieldobj->getFieldInfoBykeyValue('uitype',$related_uitype_arr['uitype'],'columnname');
                        if(!empty($related_columnname)){
                            //luyx 20231128 销售线索升级到客户后，更新线索对应的销售机会的客户
					        $adb->pquery("UPDATE ld_potential SET accountid=? WHERE IFNULL(accountid,0)=0 AND $related_columnname = ? ",array($this->id, $_REQUEST['upgradefromid']));
                        }
                    }					
                }
            }

            //Edit by luyx 2022-08-09: 线索升级后不删除
            
            //$adb->pquery("delete from ld_approvelog where crmid = ?", array($_REQUEST['upgradefromid']));
            //$adb->pquery("delete from ld_crmentity where crmid = ?", array($_REQUEST['upgradefromid']));

            //$sql=" delete from $upgradetablescf where $upgradetablescfindex=?";
            //$adb->pquery($sql,array($_REQUEST['upgradefromid']));
            //--zxm 20230731 推进的时候不仅改status值 还需要改推进阶段的值
            //wym 240321 XUQIU20240204-09 销售线索可编辑追踪字段
            $sql=" update $upgradetablename set status=?,advance_stage=?,upgradeaccountid=?,latestpushtime=NOW() where $upgradetableindex=?";
            $this->setRefreshListModules(array($_REQUEST['upgradefrommodule']));
            $adb->pquery($sql,array($_REQUEST['upgradestatus'],$_REQUEST['upgradestatus'],$this->id,$_REQUEST['upgradefromid']));
            //$tab_name_index
            
        }
        $image_from_module='Accounts';

        /**
         * 更新操作
         * edit:diony
         * time:2014-07-23
         * reason:新增客户时判断，是新增公海客户，还是新增普通客户
         */

        //Edit by luyx 2023-03-13: 记录半角客户名称
        $adb->pquery('update ld_account set accountname_halfangle=func_changeToHalfAngle(accountname) where accountid = ?',array($this->id));


        if($this->mode != 'edit'){
		  
			//chj 2022/3/24 复制公海客户，导致没有公海池的问题
			if(!empty($_REQUEST['isDuplicate']) && ($_REQUEST['isDuplicate'] == true || $_REQUEST['isDuplicate'] == 'true')){
				$query = "select pool_id,publicaccount from ld_account where accountid = ?";
				$result = $adb->pquery($query,array($_REQUEST['record']));
				if($adb->num_rows($result) >= 1){
					$_REQUEST['publicaccount'] = $adb->query_result($result,0,'publicaccount');
					$_REQUEST['pool_id'] = $adb->query_result($result,0,'pool_id');
				}
			}
			
         
			if($_REQUEST['publicaccount'])
			{
				$publicaccount = $_REQUEST['publicaccount'];
				//公海池
				if(!empty($_REQUEST['pool_id'])){
					$update_query = "update ld_account set pool_id=? where accountid=?";
					$adb->pquery($update_query, array($_REQUEST['pool_id'],$this->id));
				}
				$opdate=date('Y-m-d');
				//chj 2021/1/20 44376: （http://112.25.149.14:888/crm [^] ）（苏州磐力风机制造有限公司）升级到8.3.7版本之后，在客户模块新建的公海已分配客户的公海保护结束日期显示错误。
				$days=getAccount_set_ProtectedDays("",$this->id);
				$protectdate=date("Y-m-d",strtotime("$opdate +$days day"));
                if($days=='')
                {
                    $protectdate=null;
                }
				if($publicaccount == 2){
					$update_query = "update ld_account set publicaccount=?,lastdistributedate=?,allocatedate=?,protectdate=?,protectstartdate=now() where accountid=?";
					$adb->pquery($update_query, array($publicaccount,$opdate,$opdate,$protectdate,$this->id));	
				}else{
					$update_query = "update ld_account set publicaccount=?,allocatedate=? where accountid=?";
					$adb->pquery($update_query, array($publicaccount,'',$this->id));
				}
			   
			}else{
				$opdate=date('Y-m-d');
				$days=getAccount_set_normal_ProtectedDays_new("",$this->id);
				if(!empty($days)){
					$protectdate=date("Y-m-d",strtotime("$opdate +$days day"));
				}
				$update_query = "update ld_account set allocatedate=?,protectdate=?,protectstartdate=now() where accountid=?";
				$adb->pquery($update_query, array('',$protectdate,$this->id));
			}
            if($publicaccount>1 && !empty($_REQUEST['pool_id']))
            {
                //公海已分配客户
                $sql='select max(days) from ld_account_set_rule 
                where exists(select 1 from ld_account_set where status=0)  and type="complete" and pool_id = ? and status="active"  ';
                $result=$adb->pquery($sql,array($_REQUEST['pool_id']));
                if($adb->num_rows($result))
                {
                    $tmpdays=$adb->query_result($result,0,0);
                    
                }
            }
           /* else if(empty($publicaccount))
            {
                $sql='select max(days) from ld_account_set_rule 
                where exists(select 1 from ld_account_set where status=0)  and type="normal" and status="active"  ';
                $result=$adb->pquery($sql,array());
                if($adb->num_rows($result))
                {
                    $tmpdays=$adb->query_result($result,0,0);
                    
                }
            }*/
            if(!empty($tmpdays))
            {
                $sql='update ld_account set protectdate=date_add(curdate(),interval '.$tmpdays." day) where accountid=?";
                $adb->pquery($sql,array($this->id));
                
            }
		}
        if(isset($_REQUEST['bill_state'])||isset($_REQUEST['bill_city'])
                ||isset($_REQUEST['bill_street'])||isset($_REQUEST['bill_area'])||isset($_REQUEST["bill_street_mass_edit_check"])
                ||isset($_REQUEST["bill_city_mass_edit_check"]) || ($_REQUEST['ajxaction'] == 'DETAILVIEW' && in_array($_REQUEST['fldName'],array('bill_state','bill_city','bill_street','bill_area')))){
	               $this->updateAccountAddress($this->id);
		}

		//同步、更新客户信息到帮我吧
		$this->SyncAccountToBangwoba($this->id,$this->mode);

        /*
        edit:can
        data:20131011
        reason:客户的联系人录入改进
        */
        $version_info = getVersionInfo();
        if(isset($_REQUEST['contactid']))
        {
            $filename_file_num=$_REQUEST['filename-file_num'];
            $_REQUEST['filename-file_num']=0;//edit:can 20210202 044544: kehu001 PC端上传附件，ld_attachments 表保存了2次记录
            $sql="select  blockid from ld_blocks  where tabid= 6 and blocklabel='LBL_ACCOUNT_PRIMARYCONTACT' and visible=0 ";
            $result=$adb->pquery($sql,array());
            if($adb->num_rows($result)>0 || isset($_REQUEST['WXPCCreationInfo']))
            {
                if($_REQUEST['contactid']>0&&$_REQUEST['lastname']=="")
                {
                     $sqlcontact="update ld_contactdetails set reference=0 where contactid=?";
                     $adb->pquery($sqlcontact,array($_REQUEST['contactid']));
                }
                else
                {
                    crm_load_class_file('Contacts','modules/Contacts');
                    $contactfocus=new Contacts();

                    //联系人保存时，不判断验证规则和字段权限
                    $contactfocus->CheckValidata = 'no';
                    $contactfocus->CheckFieldProfile = 'no';
                    //客户保存首要联系人 不要删除图片，附件
                    $_REQUEST['apiDeleteAttach']='no';
                    if($_REQUEST['contactid']<=0)
                    {
                        $contactfocus->mode="create";

                        $contactfocus->column_fields['assigned_user_id']=TextRemoveXSS($_REQUEST['assigned_user_id']);
                        $contactfocus->column_fields['account_id']=$this->id;
                        $contactfocus->column_fields['reference']=1;
                        $contactfocus->column_fields['mailingstreet'] =TextRemoveXSS( $_REQUEST['bill_street']);
                        $contactfocus->column_fields['bill_country'] =TextRemoveXSS( $_REQUEST['bill_country']);
                        $contactfocus->column_fields['bill_state'] =TextRemoveXSS( $_REQUEST['bill_state']);
                        $contactfocus->column_fields['bill_city'] =TextRemoveXSS( $_REQUEST['bill_city']);
                        $mailingstreefieldinfo=$contactfocus->fieldobj->getFieldInfoobjBykey("columnname",'mailingstreet');
                        
                      if($mailingstreefieldinfo&&$mailingstreefieldinfo->getFieldName()!='')
                        $contactfocus->column_fields[$mailingstreefieldinfo->getFieldName()]=$_REQUEST[$mailingstreefieldinfo->getFieldName()];
                            
                        $contactfocus->column_fields['wx']=$_REQUEST['wx'];
						//@edit:luyx,2021-09-11,reason:增加联系人生日、农历生日
						$contactfocus->column_fields['birthday']=$_REQUEST['birthday'];
						$contactfocus->column_fields['birthday_lunar']=$_REQUEST['birthday_lunar'];
						$contactfocus->column_fields['birthday_type']=$_REQUEST['birthday_type'];
						
						//@edit:luyx,2021-05-30,reason:武秀宇东贸
						$contactfocus->column_fields['lxr_idnum']=$_REQUEST['lxr_idnum'];
						$contactfocus->column_fields['lxr_carnum']=$_REQUEST['lxr_carnum'];
						$contactfocus->column_fields['lxr_type']=$_REQUEST['lxr_type'];
						//@edit:chj,2021/9/13,reason:武秀宇东贸  联系人角色
						if($version_info['account'] == 'dongmao'){
							$contactfocus->column_fields['cf_4446']=$_REQUEST['cf_4446'];
							$contactfocus->column_fields['cf_4616']=$_REQUEST['cf_4616'];
							$contactfocus->column_fields['cf_4617']=$_REQUEST['cf_4617'];
						}
                        //永定城账套联系人模块改为使用servicecharge_id
                        if($version_info['trade'] == 'yongdingcheng'){
                            $contactfocus->column_fields['servicecharge_id']=$this->id;
                        }
                        //@edit:liushuai,2021-06-24,reason:【ID1000293】企业微信PC端，进入外部联系人聊天窗口界面后，聊天工具栏增加默认显示“当前客户查看详情界面”(新增客户保存)
                        if (isset($_REQUEST['WXPCCreationInfo']) && $_REQUEST['WXPCCreationInfo'] != '') {
                            $WXPCCreationInfo = ldcrm_json_decode(urldecode($_REQUEST['WXPCCreationInfo']));
                            if (!empty($WXPCCreationInfo)) {
                                $adb->pquery('update ld_contactdetails set weixin_external_userid=?,description=? where contactid=?',array($WXPCCreationInfo['weixin_external_userid'], $WXPCCreationInfo['description'], $contactfocus->id));
                            }
                        }
                        $referencefieldinfo=$contactfocus->fieldobj->getFieldInfoobjBykey("columnname",'reference');
                        if(!$referencefieldinfo||$referencefieldinfo->getFieldName()=='')
                        {
                            $updatesql='update ld_contactdetails set `reference`=1 where contactid=? ';
                            $adb->pquery($updatesql,array($contactfocus->id));
                            
                        }
                    }
                    else if($_REQUEST['contactid']>0)
                    {
//                        @edit:liushuai,2021-03-30,reason:0045218: （http://121.4.132.164/crm/ [^]）（上海义文机电有限公司）修改联系人的信息时，首要联系人字段自动变成了‘是’。客户是没有开启首要联系人这个功能的。并且取消勾选之后保存没有生效（Contacts.php已注释）
                        $sqlcontact='select 1 from ld_account left join ld_contactdetails on ld_account.accountid=ld_contactdetails.accountid
                where ld_account.accountid=? and ld_contactdetails.reference=1';
                        $resultcontact=$adb->pquery($sqlcontact,array($this->id));
                        if($adb->num_rows($resultcontact)<=0)
                        {
                            $adb->pquery('update ld_contactdetails set reference=1 where contactid=?',array($_REQUEST['contactid']));
                        }

                       $contactfocus->retrieve_entity_info($_REQUEST['contactid'],'Contacts');
                       $contactfocus->mode="edit";
                       
                        
                       $contactfocus->column_fields['account_id']=$this->id;
                       $contactfocus->column_fields['reference']=1;
                       
                       $contactfocus->column_fields['assigned_user_id']=$_REQUEST['assigned_user_id'];
					   
                       //@edit:chj,2021/9/13,reason:武秀宇东贸  联系人角色
						if($version_info['account'] == 'dongmao'){
							$contactfocus->column_fields['cf_4446']=$_REQUEST['cf_4446'];
							$contactfocus->column_fields['cf_4616']=$_REQUEST['cf_4616'];
							$contactfocus->column_fields['cf_4617']=$_REQUEST['cf_4617'];
						}
                        //永定城账套联系人模块改为使用servicecharge_id
                        if($version_info['trade'] == 'yongdingcheng'){
                            $contactfocus->column_fields['servicecharge_id']=$this->id;
                        }
                      // if(isset($_REQUEST['bill_street']))
                      //  $contactfocus->column_fields['mailingstreet']=$_REQUEST['bill_street'];
                      // else
                      $mailingstreefieldinfo=$contactfocus->fieldobj->getFieldInfoobjBykey("columnname",'mailingstreet');
                        
                      if($mailingstreefieldinfo&&$mailingstreefieldinfo->getFieldName()!='')
                            $contactfocus->column_fields[$mailingstreefieldinfo->getFieldName()]=$_REQUEST[$mailingstreefieldinfo->getFieldName()];
                        
						$contactfocus->column_fields['salutationtype']=$_REQUEST['salutationtype'];
						$contactfocus->column_fields['wx']=$_REQUEST['wx'];
						$contactfocus->column_fields['birthday']=$_REQUEST['birthday'];
						$contactfocus->column_fields['birthday_lunar']=$_REQUEST['birthday_lunar'];
						$contactfocus->column_fields['birthday_type']=$_REQUEST['birthday_type'];

						$contactfocus->column_fields['lxr_idnum']=$_REQUEST['lxr_idnum'];
						$contactfocus->column_fields['lxr_carnum']=$_REQUEST['lxr_carnum'];
						$contactfocus->column_fields['lxr_type']=$_REQUEST['lxr_type'];
						$contactfocus->column_fields['department']=$_REQUEST['department'];

						$contactfocus->id=$_REQUEST['contactid'];
                        
						
                    }
                    
                    
                    //读取所有的映射字段，并进行赋值
                    $attachfield_arr = array();
                    $sql="SELECT accountfield.fieldname,accountfield.columnname,accountfield.uitype,
                        contactfield.fieldname as orgin_fieldname,contactfield.columnname as orgin_columnname
                        from ld_field as accountfield 
                        INNER JOIN ld_field as contactfield on (accountfield.columnname = contactfield.columnname and accountfield.columnname != 'filename') 
				            or (accountfield.columnname= 'filename_mapping' and contactfield.columnname= 'filename')
                        where accountfield.tabid = ? and contactfield.tabid = ? 
                        AND accountfield.tablename in(?,?,?,?) and accountfield.presence in(0,2)";
                    $result=$adb->pquery($sql,array(getTabid($this->module_name),getTabid('Contacts'),'ld_contactdetails','ld_contactscf','ld_contactaddress','ld_attachments'));

                    $fileuitype_arr = array(1109,69,28);
                    $fileinfo_arr =getFileRequestKey();
                    $fieldname_transarr = array();
                    $anyValue = false;
		
                    for($i=0;$i<$adb->num_rows($result);$i++)
                    {
                        $fieldname=$adb->query_result($result,$i,'fieldname');
                        $columnname=$adb->query_result($result,$i,'columnname');
                        $uitype=$adb->query_result($result,$i,'uitype');
                        $orgin_fieldname = $adb->query_result($result,$i,'orgin_fieldname');
                        $orgin_columnname = $adb->query_result($result,$i,'orgin_columnname');

                        //BUG0074790 lius 20231102 客户模块--（索与电子科技（上海）有限公司）单据详情下的首要联系人区块，联系人电话和联系人手机清空后保存，依旧显示历史保存的值，无法清空
                        if(isset($_REQUEST[$fieldname]))
                        {
                            if($_REQUEST[$fieldname] != '')$anyValue = true;
                            $contactfocus->column_fields[$orgin_fieldname]=TextRemoveXSS($_REQUEST[$fieldname]);
                        }
                        
                        //因为在设置字段时，有可能只设置了部分附件字段，所以针对选中的附件字段单独保存,通过后缀'_mapping'判断是否为联系人模块字段
                        if(in_array($uitype,$fileuitype_arr)){
                            if($uitype==1109||$uitype==28){
                                $attachfield_arr['filetoattachment'][] = $orgin_columnname;    
                            }
                            if($uitype==69){
                                $attachfield_arr['imageattachment'][] = $orgin_columnname;    
                            }
                            $fieldname_transarr[$fieldname] = $orgin_fieldname;
                            $fieldtocolumn[$fieldname] = $columnname;
                        }
                    }
                    //如果客户模块所有的联系人字段都没有值，或者未启用，则不保存联系人信息
                    if($anyValue){
                        
                        // 不走公共代码来保存附件
                        $contactfocus->set_Is_needcommonsave_attachments('no');

                        $contactfocus->save("Contacts");
                        
                        //附件字段单独保存
                        if(sizeof($attachfield_arr)>0){
                            $before_request = $_REQUEST;
                            foreach($fieldname_transarr as $fieldname => $orgin_fieldname){
                                //转化请求中的附件字段信息
                                $columnname = $fieldtocolumn[$fieldname];
                                if(!empty($weixin_user->environment)){
                                    $tmp_file_num = $_REQUEST['wx_fieldInfo'][$columnname][$columnname.'-file_num'];
                                }else{
                                    $tmp_file_num = $_REQUEST[$fieldname.'-file_num'];
                                }
                                if($tmp_file_num > 0){
                                    //移动端使用的是$columnname 传递附件信息 
                                    if(!empty($weixin_user->environment)){
                                        $_REQUEST[$orgin_fieldname.'-file_num'] = $file_num = $_REQUEST['wx_fieldInfo'][$columnname][$columnname.'-file_num'];
                                    }else{
                                        $_REQUEST[$orgin_fieldname.'-file_num'] = $file_num = $_REQUEST[$fieldname.'-file_num'];
                                    }
                                    for($j=1;$j<220;$j++){
                                        //移动端使用的是$columnname 传递附件信息
                                        if(!empty($weixin_user->environment)){
                                            if(!isset($_REQUEST['wx_fieldInfo'][$columnname][$columnname.'-file_name_'.$j])){
                                                break;
                                            }
                                        }else{
                                            if(!isset($_REQUEST[$fieldname.'-file_name_'.$j])){
                                                break;
                                            }
                                        }
                                        
                                        //移动端使用的是$columnname 传递附件信息
                                        if(!empty($weixin_user->environment)){
                                            foreach($fileinfo_arr as $tmp_fileinfo){
                                                $_REQUEST[$orgin_fieldname.$tmp_fileinfo.$j] = $_REQUEST['wx_fieldInfo'][$columnname][$columnname.$tmp_fileinfo.$j];
                                            }
                                        }else{
                                            foreach($fileinfo_arr as $tmp_fileinfo){
                                                $_REQUEST[$orgin_fieldname.$tmp_fileinfo.$j] = $_REQUEST[$fieldname.$tmp_fileinfo.$j];
                                            }
                                        }
                                    }
                                }
                            }
                            
                            $contactfocus->addFileToAttachmentSavenoJudge($contactfocus->id,"Contacts",$attachfield_arr);
                            
                            $_REQUEST = $before_request;
                            //联系人保存附件后，清空$_REQUEST中的信息，避免客户再次保存附件
                            foreach($fieldname_transarr as $fieldname => $orgin_fieldname){
                                if(isset($_REQUEST[$fieldname.'-file_num'])){
                                    unset($_REQUEST[$fieldname.'-file_num']);
                                    for($j=1;$j<220;$j++){
                                        if(!isset($_REQUEST[$fieldname.'-file_name_'.$j])){
                                            break;
                                        }
                                        foreach($fileinfo_arr as $tmp_fileinfo){
                                            unset($_REQUEST[$fieldname.$tmp_fileinfo.$j]);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    $_REQUEST['apiDeleteAttach']='';
                }
            }
            //edit:can 20210202 044544: kehu001 PC端上传附件，ld_attachments 表保存了2次记录
            $_REQUEST['filename-file_num']=$filename_file_num;
        }
      
        $module='Accounts';

        if($_REQUEST['Create']=='true' || $_REQUEST['Create']=='yes')
        {
            $this->setFieldDefaultValue($this->id,$module);
        }

		//东贸 发送服务认证通知
        // 商贸批发小程序
		if($version_info['account'] == 'dongmao'&&$version_info['trade'] == 'dongmao'){
			$query = "select form10_type from ld_customform10 where customform10id = ?";
			$result = $adb->pquery($query,array($this->column_fields['customform10_id']));
			$form10_type = $adb->query_result($result,0,0);
			if($form10_type == '下游客户' && $this->column_fields['cf_4909'] == '已认证'){
				$query = "select 1 from ld_weixin_msg where modulename = ? and record = ?";
				$result = $adb->pquery($query,array('ServiceCharge',$this->id));
				$num_rows = $adb->num_rows($result);
				if(empty($num_rows)){
					$query = "select unionid,wechatuserid from ld_wechatuser where accountid = ? and deleted = 0";
					$result = $adb->pquery($query,array($this->id));
					$unionid = $adb->query_result($result,0,0);
					$query = "select open_id,wechatuserid from ld_wechatuser where unionid = ? and deleted = 0 and userfromvalue = 'offiaccount_dmgjsc'";
					$result = $adb->pquery($query,array($unionid));
					$open_id = $adb->query_result($result,0,'open_id');
					$wechatuserid = $adb->query_result($result,0,'wechatuserid');
					if($wechatuserid > 0){
						require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DongmaoMessage.php');
						require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DMmessageDefault.php');
						$dongmaoObj = new cls_DongmaoMessage();
						$dmMsgData = cls_DMmessageDefault::$DMmessageData['Authentication'];
						$dmMsgPage = cls_DMmessageDefault::$DMmessageJump['Authentication'];
						// 兰总:oslAm0mRG-6xUXoeBJ7Xx23Tw7HI;王总:oslAm0ptw4yIccjwf1Ba920DXQ8E;邱小光:oslAm0pdy-Da_vZxBvL9oY90IpYI
						// 兰总:177594;王总:178611;邱小光:121653
						// $open_id = 'oslAm0mRG-6xUXoeBJ7Xx23Tw7HI';
						// $wechatuserid = 177594;
						$data = array(
							'title' => $dmMsgData['title'],	
							'accountname' => $this->column_fields['accountname'],
							'thing' => $dmMsgData['thing'],
							'time' => date('Y-m-d H:i:s'),
							'remark' => $dmMsgData['remark']
						);
						$dongmaoObj->send('Authentication',$open_id,$dmMsgPage['page'],$data,$wechatuserid,'ServiceCharge',$this->id,$dmMsgPage['pageType'],$this->id);
					}
				}
			}
		}
       // $this->insertIntoAttachment($this->id,$module);
        

        //判断是否有录音文件，并插入或者修改录音文件信息
        $callButlerRemarks = "";
        if(isset($_REQUEST['callButlerRemarks']) && $_REQUEST['callButlerRemarks'] != '')
        {
            $callButlerRemarks = $_REQUEST['callButlerRemarks'];
        }
        if(isset($_REQUEST['callbutlername']) && $_REQUEST['callbutlername'] != '')
        {
             crm_load_class_file('cls_PhoneEncrypt','include');
             $obj=new cls_PhoneEncrypt();
             $callbutlername = $_REQUEST['callbutlername'];
             $one_callfiles=explode('\\',(string)$callbutlername);
             $two_callfilename=$one_callfiles[sizeof($one_callfiles)-1];
             $callfilenames=explode('_',(string)$two_callfilename);
             $callphone=$callfilenames[0];
             $restore_phone= $obj->Restore_Phone_token($callphone);
             for($i=0;$i<sizeof($one_callfiles)-1;$i++)
                 {
                    $filenames.=$one_callfiles[$i].'\\';
                 }
             $one_filenames=$filenames.$restore_phone.'_'.$callfilenames[1];
                
             $callbutlernameNew = str_replace("\\","\\\\",$one_filenames);    
             $callbutlernameNew = str_replace("\\","\\\\",$callbutlernameNew);

            $callbutlerGetSql = "select id from ld_callbutler where soundrecordingfile like '$callbutlernameNew' ";
            $callbutlerGetResult=$adb->pquery($callbutlerGetSql);
            if($adb->num_rows($callbutlerGetResult))
            {
                //存在
                $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');


                $sqlUpdate = "update ld_callbutler set userid=?, phone=?, accountid = ?,description = ? where id = ? ";
                $updateResult=$adb->pquery($sqlUpdate,array($current_user->id, $restore_phone,$this->id,$callButlerRemarks,$callButlerID));


            }
            else
            {
                //不存在
                $sqlInsert = "insert into ld_callbutler
                (calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                 accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,description)
                values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                ";
                $callbutlername = str_replace("\\\\","\\",$one_filenames);
                $insertresult=$adb->pquery($sqlInsert,array('',$restore_phone,'接通',null,null,'',$callbutlername,$current_user->id,
                $this->id,0,0,0,0,0,0,$callButlerRemarks));
            }
        }

        //九维 思孚 汉天 单据新增保存更新对应通话记录表
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

                $sqlUpdate = "update ld_callbutler set accountid = ?,description = ? where id = ? ";
                $updateResult = $adb->pquery($sqlUpdate, array($this->id, "", $callButlerID));

            } else {
                //不存在
                $sqlInsert = "insert into ld_callbutler 
                    (talkid,calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,potentialid,description) 
                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    ";

                $insertresult = $adb->pquery($sqlInsert, array($calltalkid, '', '', '', null, null, '', '', $current_user->id,
                    $this->id, 0, 0, 0, 0, 0, 0, 0, ''));
            }
        }

        //Liver 20170414 bug0027884: 销售机会查看明细界面：相关信息-客户，新建客户后，并没有关联到销售机会中
       	if($_REQUEST['tablerelmodule']&&$_REQUEST['tablerelmodule']=='Potentials')
            {
			$relid =  $_REQUEST['tablerelid'];
            $this->insertintonotesrel($relid,$this->id);
        }
		/** 赛克
		* edit: chj
		* date:2020/9/9
		* reason: 判责单首次填写需要在工单新建里填
		*/
		$version_info = getVersionInfo();
		if($version_info['account'] == 'saic'){
			$_REQUEST['from_create_account'] = 'yes';
			$cols_name = array('cf_3017'=>'question','cf_3019'=>'faq_answer','cf_3021'=>'cf_2794','cf_3023'=>'cf_3023','cf_2796'=>'cf_2796','cf_3028'=>'cf_2797','cf_2798'=>'cf_2798','cf_3032'=>'cf_2799','cf_2800'=>'cf_2800',
				'cf_2801'=>'cf_2801','cf_2802'=>'cf_2802','cf_2803'=>'cf_2803','cf_3042'=>'cf_3042','cf_3045'=>'cf_3045');
			if(empty($_REQUEST['faq_id'])){
				$is_create = 'no';
				foreach($cols_name as $fieldname => $faq_fieldname){
					if(!empty($_REQUEST[$fieldname])){
						$is_create = 'yes';
						break;
					}
				}
				if($is_create == 'yes'){
					require_once(globalstatic::$root_directory.'/modules/Faq/Faq.php');
					$module_focus = new Faq();
					$module_focus->column_fields['assigned_user_id'] = $this->column_fields['assigned_user_id'];
					$module_focus->column_fields['account_id'] = $this->id;
					foreach($cols_name as $fieldname => $faq_fieldname){
						$module_focus->column_fields[$faq_fieldname] = $_REQUEST[$fieldname];
					}
					$module_focus->save('Faq');
				}
			}else{
				require_once(globalstatic::$root_directory.'/modules/Faq/Faq.php');
				$module_focus = new Faq();
				$module_focus->mode = 'edit';
				$module_focus->id = $_REQUEST['faq_id'];
				$module_focus->retrieve_entity_info($_REQUEST['faq_id'], 'Faq');
				$module_focus->column_fields['assigned_user_id'] = $this->column_fields['assigned_user_id'];
				$module_focus->column_fields['account_id'] = $this->id;
				foreach($cols_name as $fieldname => $faq_fieldname){
					$module_focus->column_fields[$faq_fieldname] = $_REQUEST[$fieldname];
				}
				$module_focus->save('Faq');
			}
			if($module_focus->id > 0){
				$query = "select faq_no,last_name,ld_faq.smownerid from ld_faq LEFT JOIN ld_users on ld_users.id = ld_faq.smownerid where ld_faq.id = ? and ld_faq.deleted = 0";
				$result = $adb->pquery($query,array($module_focus->id));
				$this->column_fields['faq_id'] = $module_focus->id;
				$this->column_fields['faq_no'] = $adb->query_result($result,0,'faq_no');
				$last_name = $adb->query_result($result,0,'last_name');
				$smownerid = $adb->query_result($result,0,'smownerid');
				$query = 'update ld_account LEFT JOIN ld_accountscf on ld_accountscf.accountid = ld_account.accountid set faq_id = ?,cf_3013 = ? where ld_account.accountid = ?';
				$adb->pquery($query,array($module_focus->id,$smownerid,$this->id));
				$this->column_fields['faq_smower_last_name'] = $last_name;
				$this->column_fields['faq_smower_id'] = $smownerid;
				
			}
		}
        //因为存在编辑字段后导致条件变化的可能性，所以每次保存的时候重算一下保护结束日期
        $this->updateAccountInfo($this->moduleName,$this->id);
        /*
        edit:Can
        date:20130407
        reason:03655: 不合理：新增客户后会生成提醒，提醒自己：有新的客户分配给您
        */
        if($this->smoldOwnerID==-1)
        {
            return ;
        }
        //$sql_rmd="select smownerid from ld_crmentity where crmid='".$this->id."'";
        //$resul = $adb->pquery($sql_rmd);

        //$assOLD=$adb->query_result($resul,0);
        $assOLD=$this->column_fields['assigned_user_id'];
    
        if($assOLD!=$this->smoldOwnerID)
        {
            // editor:gyq 20180810 0034749: （1.6登录）客户模块：勾选不同销售负责人的单据进行合并，重新选择销售负责人字段值作为主要记录，合并时报错
               $this->AddReminds(null,null,null,null);
              
                /*
                    edit by diony 2013-06-27
                    date :2013-06-27
                    reason:最新分配人以前是保存用户名，现在保存ID
                    */
                $datanow =date("Y-m-d");
                $update_query = "update ld_account set lastdistributedate=?,lastdistributer=? where accountid=?";
	            $update_params = array($datanow,  $current_user->id, $this->id);
                $adb->pquery($update_query, $update_params);
        }


	}
	
	//同步、更新客户信息到帮我吧
	function SyncAccountToBangwoba($accountid,$mode){
		global $adb;
        static $bangwo_presences;
        if(is_array($bangwo_presences))
        {
           $activate=$bangwo_presences['activate'];
           if($activate=='yes')
           {
                $num_rows=1;
           }
        }
        else
        {
            $bangwo_presences=array();
            $bangwo_presences['activate']='no';
    		$query = 'select is_customer,presence from ld_bangwo8';
    		$result = $adb->pquery($query,array());
    		$num_rows = $adb->num_rows($result);
            
            if($num_rows>=1)
            {
                $is_customer = $adb->query_result($result,0,'is_customer');
	           $presence = $adb->query_result($result,0,'presence');
                if($is_customer == 0 && $presence == 0)
                {
                    $bangwo_presences['activate']='yes';
                }
                else
                {
                    $num_rows=0;
                }
            }
            
        }
		if($num_rows >= 1){
			
			//启用并且同步客户
			
				crm_load_class_file('cls_Bangwoba', 'modules/Users');
				$cls_Bangwoba = new cls_Bangwoba();
				if($mode == 'edit'){
					$cls_Bangwoba->setAccountToBangwoba($accountid,'edit');
				}else{
					$cls_Bangwoba->setAccountToBangwoba($accountid,'create');
				}
			
		}
	}
    function insertintonotesrel($relid,$id){
        global $adb;
        $adb->pquery("insert into ld_accountpotentialrel values(?,?)", array($id,$relid));                                     
    }
    function AddReminds($RemindsContent,$datetime,$recieverid,$record)
    {
       
        global $adb;
          if(empty($RemindsContent)){
            $RemindsContent='有新客户分配给您，敬请关注！';
          }
          crm_load_class_file('Reminds','modules/Reminds');
         $focus_rel =new Reminds();
   	     $focus_rel->column_fields['date_time'] = date('Y-m-d H:i');
         $focus_rel->column_fields['related_to']=$this->id;
         $focus_rel->column_fields['reltab']=$this->module_name;
               //明细界面修改（include/js/dtlviewajax.js);
         if(isset($_REQUEST["ajxaction"])&&$_REQUEST["ajxaction"] == "DETAILVIEW")
         {
                     $focus_rel->column_fields['recieverid']=utf8RawUrlDecode($_REQUEST["fieldValue"]);
         }
         else
         {
            //服务收费管理客户分配也调用该方法
                    $focus_rel->column_fields['recieverid']=$recieverid;
         }

        $focus_rel->column_fields['status_rmd']='未读';
        $focus_rel->column_fields['content']=$RemindsContent;
        $focus_rel->mode="create";//edit by lD Can 修改负责人，提醒总是增加
        $focus_rel->save('Reminds');
        return $focus_rel->id;
    }

    #验证手机是否合法
    private function CheckTelephone($mobilephone)
    {
        return preg_match("/^1[0-9]{1}[0-9]{9}$/",$mobilephone);
    }
    
    #随机获取批次号
    private function GetBatchNo()
     {
        global $adb;

        $strBatchNo = "";
        $strDigit = "000001";
        $strZero = "";
        $digit = 0;
        $i=0;
        $strBatchNoSql = "select BatchNo from ld_smssend where date(CreateTime) = curdate() order by taskid desc limit 0,1";
        $resultBatchNo =$adb->pquery($strBatchNoSql);
        $strBatchNo='000001';
        if($adb->num_rows($resultBatchNo)>0)
        {
            $strBatchNo = $adb->query_result($resultBatchNo,'BatchNo');//批次号
            $strDigit = substr($strBatchNo,12, strlen($strBatchNo) - 6);

            $digit = intval($strDigit) + 1;
            if(strlen($digit)<6)
            {
                $Count =  6-strlen($digit);
                for($i=0;$i<$Count;$i++)
                {
                    $strZero .= "0";
                }
            }
            $strDigit = $digit;
        }
        if ($strZero!="")
        {
            $strBatchNo = date("ymd").$strZero.$strDigit;
        }
        else
        {
            $strBatchNo = date("ymd").$strDigit;
        }

        //print_r($strBatchNo);
        //exit();
        /*判断是否存在批次号，如果存在再次生成新的批次号*/
        $strCheck = substr($strBatchNo,6, strlen($strBatchNo) - 6);
        $checkBatchNo = 'SELECT count(1) as count FROM ld_smssend where BatchNo = '.$strCheck;
        $checkBatchNoresult =$adb->pquery($checkBatchNo);
        //$BatchNoCount = $adb->query_result($checkBatchNoresult,0,'count');
        $num_rows=$adb->num_rows($checkBatchNoresult);
        if(!$num_rows)
        {
            GetBatchNo();
        }
        /*随机生成6位字符串*/
        $chars='0123456789abcdefghijklmnopqrstuvwxyz';
        mt_srand((double)microtime()*1000000*getmypid());
        $strRand="";
        while(strlen($strRand)<6)
        {
            $strRand.=substr($chars,(mt_rand()%strlen($chars)),1);
        }
        $strBatchNo = $strRand.$strBatchNo;
        return $strBatchNo;
     }
    /*
    edit by LD Can
    reason:提醒，分配人等由于需要判断负责人是否修改，所以增加了该函数
    date:20130326
    */
  function save($module_name, $fileid = '')
    {
        $this->setSmOldOwnerID();
        return parent::save($module_name);
    }
    /**
     * 
     * crm系统同步帮我系统帮我吧接口
     * */
    function  crm_operation_bangwo_ba($ids,$action)
    {
        require_once(globalstatic::$root_directory."crmapi/bangwo8_operate.php");
        return  apiBangwo8Sync($ids,$action);
    
    }
   
    /**
     * 获取相关信息id
     * */
    public function getRelateIds($relateFun_name,$id)
    {
        $isShow = empty(getUsersettingByLabel($this->moduleName,1,'SuperiorAccountSee'))?'no':getUsersettingByLabel($this->moduleName,1,'SuperiorAccountSee');
        if($isShow=='no'){
            //为空表示用户未设置,默认客户相关信息不显示下级信息
            return parent::getRelateIds($relateFun_name,$id);
        }
        switch($relateFun_name)
        {
             case 'get_ServiceContracts':
                 if(getEduType('Edu') == true)
                     return parent::getRelateIds($relateFun_name,$id);
                 else
                     if(sizeof($this->account_childIds)<=0)
                     {
                         $this->setAccountChildIds($id);
                     }
                     return $this->account_childIds;
            case 'get_opportunities':
            case 'get_quotes':
           
            case 'get_ProjectMilestone':
            case 'get_salesorder':
                if(sizeof($this->account_childIds)<=0)
                {
                    $this->setAccountChildIds($id);
                }
                return $this->account_childIds;
            default:
            return  parent::getRelateIds($relateFun_name,$id);
        }
    }




	/**
	 * @project PROT93 邮件管理改进
	 * @author Tujt 2014-09-23
	 */
	public function get_emails($id, $cur_tab_id, $rel_tab_id, $actions=false) {
	    global $adb;
		global $currentModule,$current_user;
		global $list_max_entries_per_page_new_more;
		//1、获取字段
        $query = 'SELECT GROUP_CONCAT(CONCAT(tablename,".",columnname)) AS columnname
						FROM ld_field WHERE uitype = 13 AND (tabid = 6 AND tablename != "ld_contactdetails" OR tabid = 4) AND presence IN (0,2) LIMIT 1;';
		$result = $adb->pquery($query,array());
		$emailfield = $adb->query_result($result,0,'columnname');
		//2、取email值
        if(!empty($emailfield)){
            $query = 'select '.$emailfield.' from ld_account
					left join ld_accountscf
						on ld_accountscf.accountid = ld_account.accountid
					left join ld_contactdetails
						on ld_contactdetails.accountid = ld_account.accountid
						and ld_contactdetails.deleted = 0
					left join ld_contactscf
						on ld_contactscf.contactid=ld_contactdetails.contactid
					where ld_account.deleted = 0 and ld_account.accountid = ? ';
            $result = $adb->pquery($query,array($id));
            $rows = $adb->num_rows($result);
        }else{
            $rows = 0;
        }

		$emailarr = array();
		if($rows > 0){
			$fieldarr = explode(',',(string)$emailfield);
			for($i=0;$i<$rows;$i++){
                foreach($fieldarr as $flds){
                    $fld = explode('.',$flds);
                    if(isset($fld[1])){
                        $val = $adb->query_result($result,$i,$fld[1]);
						if(!empty($val))
							$emailarr[$val] = $val;
                    }
                }
            }
		}
		//手机、主题、接收人、发送时间、发件人，
	
        $email_field_obj=Field::getInstance('Emails',$adb);
		$arrpaymentLabel = $email_field_obj->getFieldLables();
        $header = array($arrpaymentLabel['from_email'],$arrpaymentLabel['subject'],$arrpaymentLabel['date_start'],getFixedLabel('TOMAIL'),getFixedLabel('STATUS'),getFixedLabel('OPERATING'));

		$button = '';
		$button .= '<input type="hidden" name="email_directing_module"><input type="hidden" name="record">';
		if($actions) {
			if(is_string($actions)) $actions = explode(',', strtoupper($actions));
			if(in_array('ADD', $actions) && isPermitted('Emails',3, '') == 'yes') {
				$button .= '<a title="'.getFixedLabel('Send_mail').'" href="javascript:void(0);"
				onclick="sendmail(\''.$currentModule.'\','.$id.');">
				<span>'.getFixedLabel('Send_mail').'</span></a>';
                $button .= '<a title="'.getFixedLabel('Receive_mail').'" href="javascript:void(0);"
				onclick="receivemail();">
				<span>'.getFixedLabel('Receive_mail').'</span></a>';
			}
		}

		//3、获取email对应的往来邮件记录
		$where = '';
		if(!empty($emailarr)){
			$lt ='<';
			$gt ='>';
            $tmp_where = '';
			foreach($emailarr as $email){
				//$where .= ' ((to_email like "%'.$lt.$email.$gt.'%" or to_email like '."'%\"{$email}\"%'".') or (cc_email like "%'.$lt.$email.$gt.'%" or cc_email like '."'%\"{$email}\"%'".') or (bcc_email like "%'.$lt.$email.$gt.'%" or bcc_email like '."'%\"{$email}\"%'".')) or';
				// 需求是接收人为当前客户邮箱，所以暂未考虑抄送密送
				$where .= '(ld_emaildetails.to_email like "%'.$lt.$email.$gt.'%" or ld_emaildetails.to_email like '."'%{$email}%'".') or';
                $tmp_where .= '(ld_mailmanager_mailrecord.mto like "%'.$lt.$email.$gt.'%" or ld_mailmanager_mailrecord.mto like '."'%{$email}%'".') or';//系统发送的邮件
                $tmp_where .= '(ld_mailmanager_mailrecord.mfrom like "%'.$lt.$email.$gt.'%" or ld_mailmanager_mailrecord.mfrom like '."'%{$email}%'".') or';//系统收取的邮件
                $tmp_where .= '(ld_mailmanager_mailrecord.mcc like "%'.$lt.$email.$gt.'%" or ld_mailmanager_mailrecord.mcc like '."'%{$email}%'".') or';//抄送的邮件
            }
		}else{//没有邮箱信息，返回空
			$return_value = array('header'=>$header,'entries'=>array(),'navigation'=>array(),'CUSTOM_BUTTON'=>$button);
			return $return_value;
		}
		$where = trim($where,'or');
		$query = 'SELECT ld_emaildetails.from_email,ld_activity.subject,ld_activity.createdtime,
						ld_emaildetails.to_email,ld_emaildetails.emailid,\'1\' as seen,\'emaildetails\' AS email_from
					FROM ld_activity
				 LEFT JOIN ld_emaildetails
					ON ld_emaildetails.`emailid` = ld_activity.`activityid` ';
		if($current_user->accountallview != 1 && $current_user->is_admin != 'on'){
			$this->table_name = 'ld_activity';
			$sql = $this->getNonAdminAccessControlQuery('Emails',$current_user);
			$this->table_name = 'ld_account';
			if(!empty($sql)){
				$query .= $sql;
			}
		}
		$query .= 'WHERE ld_activity.`deleted` = 0 and ld_activity.activitytype = "Emails" ';
		$query .= 'and ('.$where.') ';
        $tmp_where = trim($tmp_where,'or');
        $query.='union all select mfrom,msubject,mdate as createdtime,mto,mailrecordid,seen,\'mailmanager\' as email_from from ld_mailmanager_mailrecord ';
        $query.=" where deleted=0  and  ( ".$tmp_where.')';

		//4、计算总数
        $noofrows=$adb->num_rows($adb->pquery($query,array()));
        
	
		global $related_left_type;
		if($related_left_type == 3){//获取相关信息条数
			$related_entries = array();
			$related_entries['relcount'] = $noofrows;
			return $related_entries;
		}
		if($noofrows <= 0){
			$return_value = array('header'=>$header,'entries'=>array(),'navigation'=>array(),'CUSTOM_BUTTON'=>$button);
			return $return_value;
		}
		//5、分页
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
		$query =" select * from ($query ) as tmp order by createdtime desc ". ' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';
		//6、取值
		$result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows>0){
            $mail_sql = "select GROUP_CONCAT(mail_username) as mailaccounts  from ld_mail_accounts where user_id =? order by createdtime desc";
            $mail_result = $adb->pquery($mail_sql,array($current_user->id));
            $mailaccounts = $adb->query_result($mail_result,0,'mailaccounts');

			$json = new Zend_Json();
            for($i=0;$i<$num_rows;$i++){
                $listview_entrie = array();
                $from_email = $adb->query_result($result,$i,'from_email');
                $listview_entrie[] = $from_email;
                $listview_entrie[] = $adb->query_result($result,$i,'subject');
                $listview_entrie[] = $adb->query_result($result,$i,'createdtime');
				$to_email = $adb->query_result($result,$i,'to_email');
                if (is_array($to_email)) {
                    $to_email = $json->decode($to_email);

                    $to_email = vt_suppressHTMLTags(@implode(',', $to_email));
                } else {
                    $to_email = vt_suppressHTMLTags($to_email);
                }
				$listview_entrie[] = $to_email;

                $seen = $adb->query_result($result,$i,'seen');
                $listview_entrie[] = $seen == '1'?getFixedLabel('LBL_READEN'):getFixedLabel('LBL_UNREADEN');

                $emailid = $adb->query_result($result,$i,'emailid');
                $email_from = $adb->query_result($result,$i,'email_from');
                if ($email_from == 'mailmanager') {
                    //$from_email joe@163.com、Joe <joe@qq.com>   $emailarr 可能为多个,格式为joe@qq.com
                    $havereply = false;//特殊情况：邮箱管理的账号作为发件人时。发件人为关联邮件的且不为邮箱服务器的或者收件人为邮箱服务器的。
                    if (stripos($mailaccounts,$from_email) === false || stripos($mailaccounts,$to_email) !== false) {
                        $havereply = true;
                    }

                    if ($havereply) {
                        $reply = '<a class="Anu3_a" href="###" onclick="view_EmailContent(ld(this),\''.$emailid.'\',\''.$email_from.'\')" record="'.$emailid.'" module="'.$currentModule.'">'.getFixedLabel('VIEW').'</a>';
                        $reply .= '<a class="Anu3_a" href="###" onclick="reply_EMail_popup(ld(this),\''.$emailid.'\')" module="'.$currentModule.'">'.getFixedLabel('Reply').'</a>';
                    }else{
                        $reply = '<a class="Anu3_a" href="###" onclick="view_EmailContent(ld(this),\''.$emailid.'\',\''.$email_from.'\')" record="'.$emailid.'" module="'.$currentModule.'">'.getFixedLabel('VIEW').'</a>';
                    }
                }else{
                    $reply = '';
                }
                $listview_entrie[] = $reply;
                $listview_entries[] = $listview_entrie;
            }
        }
		//7、获取分页组件
		$navigationOutput = Array();$url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
		$navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'Emails',$id);
        $return_value = array('header'=>$header,'entries'=>$listview_entries,'navigation'=>$navigationOutput,'CUSTOM_BUTTON'=>$button,'noofrows'=>$noofrows);
		return $return_value;
	}
	
    
    




	/**
     * 查重合并功能
	 * Move the related records of the specified list of id's to the given record.
	 * @param String This module name
	 * @param Array List of Entity Id's from which related records need to be transfered
	 * @param Integer Id of the the Record to which the related records are to be moved
	 */
	function transferRelatedRecords($module, $transferEntityIds, $entityId) {
		global $adb;
	parent::transferRelatedRecords($module, $transferEntityIds, $entityId);
		$rel_table_arr = Array("Activities"=>"ld_seactivityrel",
					"Documents"=>"ld_senotesrel","Campaigns"=>'ld_campaignaccountrel', "Attachments"=>"ld_seattachmentsrel","HelpDesk"=>"ld_troubletickets",
					"Products"=>"ld_seproductsrel");

		$tbl_field_arr = Array("ld_seactivityrel"=>"activityid",
					"ld_senotesrel"=>"notesid",'ld_campaignaccountrel'=>'campaignid', "ld_seattachmentsrel"=>"attachmentsid","ld_troubletickets"=>"ticketid",
					"ld_seproductsrel"=>"productid");

		$entity_tbl_field_arr = Array("ld_seactivityrel"=>"crmid",
					"ld_senotesrel"=>"crmid",'ld_campaignaccountrel'=>'accountid' ,"ld_seattachmentsrel"=>"crmid","ld_troubletickets"=>"accountid",
					"ld_seproductsrel"=>"crmid");



		foreach($transferEntityIds as $transferId) {
		    $sql="update ld_seattachmentsrel set crmid=".$entityId.' where crmid='.$transferId;
            $adb->pquery($sql);
            
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

        //20240726 hzx XUQIU1001729 经销商用PRM成员管理设置  客户查重后更新prm部门的关联id
        $update_sql = 'update ld_groups set related_crmid = ? where group_type = "prm" and related_crmid in ('.implode(',',$transferEntityIds).');';
		$adb->pquery($update_sql,array($entityId));
	}

	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables =  array (
			"Contacts" => array("ld_contactdetails"=>array("accountid","contactid"),"ld_account"=>"accountid"),
			"Potentials" => array("ld_potential"=>array("accountid","potentialid"),"ld_account"=>"accountid"),
			"Quotes" => array("ld_quotes"=>array("accountid","quoteid"),"ld_account"=>"accountid"),
			"SalesOrder" => array("ld_salesorder"=>array("accountid","salesorderid"),"ld_account"=>"accountid"),
			"Invoice" => array("ld_invoice"=>array("accountid","invoiceid"),"ld_account"=>"accountid"),
			"Calendar" => array("ld_seactivityrel"=>array("crmid","activityid"),"ld_account"=>"accountid"),
			"HelpDesk" => array("ld_troubletickets"=>array("parent_id","ticketid"),"ld_account"=>"accountid"),
			"Products" => array("ld_seproductsrel"=>array("crmid","productid"),"ld_account"=>"accountid"),
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_account"=>"accountid"),
			"Campaigns" => array("ld_campaignaccountrel"=>array("accountid","campaignid"),"ld_account"=>"accountid"),
		);
		return $rel_tables[$secmodule];
	}


	
    /**
     * edit:can
     * reason:8300: 岂蔼居需求：客户更多信息需要查看下级客户的销售机会、报价单、合同订单信息
     * 获取当前客户的下级客户id(包含当前客户id)
     * */
     public function setAccountChildIds($id)
     {
    	//$accounts_list = Array();
		//$encountered_accounts = array($id);
	//	$this->accounts_list = $this->__getParentAccounts($id, $accounts_list, $encountered_accounts);
        $account_child=array();

	//	$this->accounts_list = $this->__getChildAccounts($id, $account_child, $accounts_list[$id]['depth']);
       $this->accounts_list = $this->__getChildIds($id, $account_child, 1);
        foreach($account_child as $account_id => $account_info)
        {
 	         $this->account_childIds[$account_id]=$account_id;
        }
         $this->account_childIds[$id]=$id;
        //print_r($this->account_listIds);
     }
     function get_AccountHierarchy($id)
     {
        return $this->getAccountHierarchy($id);
        
     }
	/**
	* Function to get Account hierarchy of the given Account
	* @param  integer   $id      - accountid
	* returns Account hierarchy in array format
	*/
	function getAccountHierarchy($id) {
		global  $adb, $current_user;


		$tabname = getParentTab();
		$listview_header = Array();
		$listview_entries = array();
      
        $account_field_obj =Field::getInstance('Accounts',$adb);
        $arrFieldlabel = $account_field_obj->getFieldLables();
        $hierarchHeader=array('accountname'=>'accountname','account_no'=>'account_no','assigned_user_id'=>'assigned_user_id');
		foreach ($hierarchHeader as $fieldname=>$colname) {
			//if(getFieldVisibilityPermission('Accounts', $current_user->id, $colname) == '0') {
				$listview_header[] = $arrFieldlabel[$fieldname];
			//}
		}

		$accounts_list = Array();
        
		// Get the accounts hierarchy from the top most account in the hierarch of the current account, including the current account
		$encountered_accounts = array($id);
		$accounts_list = $this->__getParentAccounts($id, $accounts_list, $encountered_accounts);
       
		// Get the accounts hierarchy (list of child accounts) based on the current account
		$accounts_list = $this->__getChildAccounts($id, $accounts_list, $accounts_list[$id]['depth']);

		// Create array of all the accounts in the hierarchy

		foreach($accounts_list as $account_id => $account_info) {
			$account_info_data = array();
            $hasRecordViewAccess=true;//019690: 服务收费>明细>关联创建：普通用户，点击查看上下级用户，不显示上级客户编号和销售负责人。
			//$hasRecordViewAccess = (is_admin($current_user)) || (isPermitted('Accounts', 'DetailView', $account_id) == 'yes');
			foreach ($hierarchHeader as $fieldname=>$colname) {
				// Permission to view account is restricted, avoid showing field values (except account name)
				if(!$hasRecordViewAccess && $colname != 'accountname') {
					$account_info_data[] = '';
				} else {
					$data = $account_info[$colname];
					if ($colname == 'accountname') {
						if ($account_id != $id) {
							if($hasRecordViewAccess) {
								$data = '<a onclick="ListLinkClick(ld(this),event)" href="javascript:;" module="'.$this->module_name.'" record="'.$account_id.'">'.$data.'</a>';
							} else {
								$data = '<i>'.$data.'</i>';
							}
						} else {
							$data = '<b>'.$data.'</b>';
						}
						// - to show the hierarchy of the Accounts
						$account_depth = str_repeat(" .. ", $account_info['depth'] * 2);
						$data = $account_depth . $data;
					} else if ($colname == 'website') {
						$data = '<a href="http://'. $data .'" target="_blank">'.$data.'</a>';
					}
                  
					$account_info_data[] = $data;
				}
			}
            if($id==$account_id)
            {
                //36584: （1.6）客户明细界面>相关>查看上下级关系：当上下级只有自己时，查看上下级关系右侧的数字不显示且置灰无法点击。
                continue;
            }
			$listview_entries[$account_id] = $account_info_data;
		}

		$account_hierarchy = array('header'=>$listview_header,'entries'=>$listview_entries);

		return $account_hierarchy;
	}

	/**
	* Function to Recursively get all the upper accounts of a given Account
	* @param  integer   $id      		- accountid
	* @param  array   $parent_accounts   - Array of all the parent accounts
	* returns All the parent accounts of the given accountid in array format
	*/
	function __getParentAccounts($id, &$parent_accounts, &$encountered_accounts) {
		global $adb;
		$query = 'SELECT parentid FROM ld_account WHERE ld_account.deleted = 0 and ld_account.accountid = ? limit 1;';
		$params = array($id);
		$res = $adb->pquery($query, $params);
		$rows = $adb->num_rows($res);
		if($rows > 0){
			$parentid = $adb->query_result($res, 0, 'parentid');
			if(!empty($parentid) && $parentid > 0 && (empty($encountered_accounts) or !in_array($parentid,$encountered_accounts))){
				$parentid = $adb->query_result($res, 0, 'parentid');
				$encountered_accounts[] = $parentid;
				$this->__getParentAccounts($parentid,$parent_accounts,$encountered_accounts);
			}
		}
        
                $query = "SELECT ld_account.*, " .
				" ld_users.last_name as user_name " .
				" FROM ld_account"  .
				" LEFT JOIN ld_users" .
				" ON ld_users.id = ld_account.smownerid" .
				" WHERE ld_account.deleted = 0 and ld_account.accountid = ?";
		$params = array($id);
		$res = $adb->pquery($query, $params);

		$parent_account_info = array();
		$depth = 0;
		$immediate_parentid = $adb->query_result($res, 0, 'parentid');
		if (isset($parent_accounts[$immediate_parentid])) {
			$depth = $parent_accounts[$immediate_parentid]['depth'] + 1;
		}
        $hierarchHeader=array('accountname'=>'accountname','account_no'=>'account_no','assigned_user_id'=>'assigned_user_id');
		$parent_account_info['depth'] = $depth;
        foreach($hierarchHeader as $fieldname=>$columnname) {
			if ($columnname == 'assigned_user_id') {
				$parent_account_info[$columnname] = $adb->query_result($res, 0, 'user_name');
			} else {
				$parent_account_info[$columnname] = $adb->query_result($res, 0, $columnname);
			}
		}
		$parent_account_info['parentid'] = $parentid;
		
		$parent_accounts[$id] = $parent_account_info;
		$parent_accounts = $this->__getChildAccounts_1($id, $parent_accounts, $depth);
		return $parent_accounts;
	}

    function __getChildIds($id,&$child_accounts,$depth)
    {
        global $adb;


		$query = "SELECT ld_account.accountid " .
				" FROM ld_account" .
				" INNER JOIN ld_crmentity " .
				" ON ld_crmentity.crmid = ld_account.accountid" .

				" WHERE ld_account.deleted = 0 and parentid = ?";
		$params = array($id);
		$res = $adb->pquery($query, $params);

		$num_rows = $adb->num_rows($res);

		if ($num_rows > 0) {
			$depth = $depth + 1;
			for($i=0;$i<$num_rows;$i++) {
				$child_acc_id = $adb->query_result($res, $i, 'accountid');
				if(array_key_exists($child_acc_id,$child_accounts)) {
					continue;
				}

				$child_accounts[$child_acc_id] = $child_acc_id;
				$this->__getChildIds($child_acc_id, $child_accounts, $depth);
			}
		}
		return $child_accounts;
    }
	/**
	* Function to Recursively get all the child accounts of a given Account
	* @param  integer   $id      		- accountid
	* @param  array   $child_accounts   - Array of all the child accounts
	* @param  integer   $depth          - Depth at which the particular account has to be placed in the hierarchy
	* returns All the child accounts of the given accountid in array format
	*/
	function __getChildAccounts_1($id, &$child_accounts, $depth) {
		global  $adb;

		$userNameSql = getSqlForNameInDisplayFormat(array('first_name'=>
							'ld_users.first_name', 'last_name' => 'ld_users.last_name'), 'Users');
		$query = "SELECT ld_account.*, " .
				" ld_users.last_name as user_name " .
				" FROM ld_account" .
				" INNER JOIN ld_crmentity " .
				" ON ld_crmentity.crmid = ld_account.accountid" .
			
				" LEFT JOIN ld_users" .
				" ON ld_users.id = ld_account.smownerid" .
				" WHERE ld_account.deleted = 0 and parentid = ?";
		$params = array($id);
		$res = $adb->pquery($query, $params);
		$num_rows = $adb->num_rows($res);
        $hierarchHeader=array('accountname'=>'accountname','account_no'=>'account_no','assigned_user_id'=>'assigned_user_id');
		if ($num_rows > 0) {
			$depth = $depth + 1;
			for($i=0;$i<$num_rows;$i++) {
				$child_acc_id = $adb->query_result($res, $i, 'accountid');
				if(array_key_exists($child_acc_id,$child_accounts)) {
					continue;
				}
				$child_account_info = array();
				$child_account_info['depth'] = $depth;

                foreach($hierarchHeader as $fieldname=>$columnname) {
					if ($columnname == 'assigned_user_id') {
						$child_account_info[$columnname] = $adb->query_result($res, $i, 'user_name');
					} else {
						$child_account_info[$columnname] = $adb->query_result($res, $i, $columnname);
					}
				}
				$child_account_info['parentid'] = $id;
				$child_accounts[$child_acc_id] = $child_account_info;
			}
		}
		return $child_accounts;
	}
	function __getChildAccounts($id, &$child_accounts, $depth) {
		global  $adb;

		$userNameSql = getSqlForNameInDisplayFormat(array('first_name'=>
							'ld_users.first_name', 'last_name' => 'ld_users.last_name'), 'Users');
		$query = "SELECT ld_account.*, " .
				" ld_users.last_name as user_name " .
				" FROM ld_account" .
				" INNER JOIN ld_crmentity " .
				" ON ld_crmentity.crmid = ld_account.accountid" .
			
				" LEFT JOIN ld_users" .
				" ON ld_users.id = ld_account.smownerid" .
				" WHERE ld_account.deleted = 0 and parentid = ?";
		$params = array($id);
		$res = $adb->pquery($query, $params);
		$num_rows = $adb->num_rows($res);
        $hierarchHeader=array('accountname'=>'accountname','account_no'=>'account_no','assigned_user_id'=>'assigned_user_id');
		if ($num_rows > 0) {
			$depth = $depth + 1;
			for($i=0;$i<$num_rows;$i++) {
				$child_acc_id = $adb->query_result($res, $i, 'accountid');
				if(array_key_exists($child_acc_id,$child_accounts)) {
					continue;
				}
				$child_account_info = array();
				$child_account_info['depth'] = $depth;

                foreach($hierarchHeader as $fieldname=>$columnname) {
					if ($columnname == 'assigned_user_id') {
						$child_account_info[$columnname] = $adb->query_result($res, $i, 'user_name');
					} else {
						$child_account_info[$columnname] = $adb->query_result($res, $i, $columnname);
					}
				}
				$child_account_info['parentid'] = $id;
				$child_accounts[$child_acc_id] = $child_account_info;
				
				$this->__getChildAccounts($child_acc_id, $child_accounts, $depth);
			}
		}
		return $child_accounts;
	}

	// Function to unlink the dependent records of the given record by id
	function unlinkDependencies($module, $id) {
	

		//parent::unlinkDependencies($module, $id);
	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Campaigns') {
			$sql = 'DELETE FROM ld_campaignaccountrel WHERE accountid=? AND campaignid=?';
			$this->db->pquery($sql, array($id, $return_id));
		} else if($return_module == 'Products') {
			$sql = 'DELETE FROM ld_seproductsrel WHERE crmid=? AND productid=?';
			$this->db->pquery($sql, array($id, $return_id));
		} else {
			$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
			$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
			$this->db->pquery($sql, $params);
		}


		global $adb;
		$sql = 'update ld_groups set related_crmid = 0 where group_type = "prm" and related_crmid = ?';
        $adb->pquery($sql,array($id));
	}

	function save_related_module($module, $crmid, $with_module, $with_crmids) {
		$adb = $this->db;
        
		if(!is_array($with_crmids)) $with_crmids = Array($with_crmids);
		foreach($with_crmids as $with_crmid) {
			if($with_module == 'Products')
				$adb->pquery("insert into ld_seproductsrel values(?,?,?)", array($crmid, $with_crmid, $module));
			elseif($with_module == 'Campaigns') {
				$checkResult = $adb->pquery('SELECT 1 FROM ld_campaignaccountrel WHERE campaignid = ? AND accountid = ?',
												array($with_crmid, $crmid));
				if($checkResult && $adb->num_rows($checkResult) > 0) {
					continue;
				}
				$adb->pquery("insert into ld_campaignaccountrel(campaignid,accountid,campaignrelstatusid) values(?,?,1)", array($with_crmid, $crmid));
			} else {
				parent::save_related_module($module, $crmid, $with_module, $with_crmid);
			}
		}
	}
	/**
	 *  edit:can
	 *  date:20130727
     * reason:获取公海操作日志
	**/
	function getPublicAccountLog($accountid)
	{
	
		global $adb;
		$sql = "select ld_users.wx_userid,ld_users.last_name,ld_logpublicaccount.username,operation,opdate,ld_logpublicaccount.userid from ld_logpublicaccount 
        left join ld_users on ld_users.id=ld_logpublicaccount.userid
        where accountid=? order by opdate desc";
		$result = $adb->pquery($sql, array($accountid));

		$noofrows = $adb->num_rows($result);


        $loghtml="";

        //GYQ1230
        if(!empty ($noofrows))
        {
            for($i=0;$i<$noofrows;$i++)
            {
                //$loghtml.='<div class="dataField" valign="top" style="width: 95%; padding-top: 5px;">  </div>';
                $loghtml.='<div class="dataLabel" valign="top" style="border-bottom: 1px dotted rgb(204, 204, 204); width: 100%; height:37px;line-height:37px;color:#FF8001;">';
                $loghtml.='<font>'.getFixedLabel('DATE').':'.$adb->query_result($result,$i,"opdate");
              
                if(stripos($adb->query_result($result,$i,"operation"),'$###$')!==false)
                {
                    
                    $strs=explode('$###$',(string)$adb->query_result($result,$i,"operation"));
                 
                    $loghtml.='&nbsp;&nbsp;&nbsp;&nbsp;'.getFixedLabel('OPERATING').':'.sprintf(getFixedLabel($strs[0]),$strs[1]);

                }
                else if(stripos($adb->query_result($result,$i,"operation"),'$####$')!==false)//释放原因
                {
                     $strs = explode('$####$', (string)$adb->query_result($result, $i, "operation"));
                    $loghtml .= '&nbsp;&nbsp;&nbsp;&nbsp;' . getFixedLabel('OPERATING') . ':' . getFixedLabel($strs[0]);

                    $loghtml .= '&nbsp;&nbsp;&nbsp;&nbsp;' . getFixedLabel('RELEASEACCOUNTTREASON') . ':' . $strs[1];
                }
                else {
                  
                   $loghtml .= '&nbsp;&nbsp;&nbsp;&nbsp;' . getFixedLabel('OPERATING') . ':' . getFixedLabel($adb->query_result($result, $i, "operation"));
                    
                    

                }
                $loguserid=$adb->query_result($result, $i, "userid");
                if(!empty($loguserid))
                {
                    $userobj=new Users();
                    $userobj->last_name= $adb->query_result($result, $i, "last_name");
                    $userobj->wx_userid= $adb->query_result($result, $i, "wx_userid");
                    $loghtml .= '&nbsp;&nbsp;&nbsp;&nbsp;' . getFixedLabel('operatoroer') . ':' . getUserlastName($userobj);
                }
                else{
                    $userobj=new Users();
                    $userobj->last_name= $adb->query_result($result, $i, "username");
                    $userobj->wx_userid= $adb->query_result($result, $i, "wx_userid");
                    $loghtml .= '&nbsp;&nbsp;&nbsp;&nbsp;' . getFixedLabel('operatoroer') . ':' . getUserlastName($userobj);
                }
               
                $loghtml .= "</font></div>";
            }
            return $loghtml;
        }
        else
        {
            return '';
        }

	}

    /*
     * edit:kevin
     * date:2013-07-22
     * reason:是否启用公海客户，获取状态，单据值
     */
     /*function getAccountSet(){
        global $adb;
  
            $status=getAccount_Set('status');
            $bills=getAccount_Set('bills');
            if($status==0)
            {
                 $account[]=$status;
                $account[]=$bills;
            }

        //}
        return $account;
     }*/
     
 
    
     
     /**
     * edit:kevin
     * date:2013-07-22
     * reason:是否启用公海
     * $type:0 保存,1 编辑,2 删除,3 还原
     */
     function updateAccountInfo($module,$accountid='',$type=0,$record=''){
        global $adb,$default_charset;
		crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
		$cls_PublicAccounts = new cls_PublicAccounts($this->module_name);
		$public_account = $cls_PublicAccounts->getPublicAccount();
         if($public_account['status']!='yes')
         {
            //没有启用公海客户
            return false;
         }
         if(empty($module))
         {
            return false;
         }
         $focus=CRMEntity::getInstance($module);
         if($module=='Singin' || $module == $this->module_name)
         {

         }
         else
         {
             if(!$focus->fieldobj->getFieldInfoobjBykey('fieldname','account_id'))
             {
                 return false;//如果单据没有客户
             }
         }

        if(!empty($accountid))
        {
            $sql='select distributiondate, ld_account.accountid,ld_account.allocatedate,ld_account.publicaccount,protectdate
            ,ld_account.createdtime,ld_account.distributiondate,pool_id from ld_account where accountid =? ';
            $result=$adb->pquery($sql,array($accountid));
            $accountid=$adb->query_result($result,0,'accountid');
            $allocatedate=$adb->query_result($result,0,'allocatedate');
            $publicaccount=$adb->query_result($result,0,'publicaccount');
            $createdtime=$adb->query_result($result,0,'createdtime');
            $distributiondate=$adb->query_result($result,0,'distributiondate');
            $protectdate=$adb->query_result($result,0,'protectdate');
			$pool_id=$adb->query_result($result,0,'pool_id');


        }
        else

        {
            $sql = 'select ld_account.accountid,ld_account.allocatedate,ld_account.publicaccount,ld_account.createdtime,ld_account.distributiondate,protectdate,pool_id from  '.$focus->table_name;
            if($focus->table_name != 'ld_account'){
                $sql .= ' inner join ld_account on ld_account.accountid='.$focus->table_name.'.accountid ';
            } 
            $sql .= ' where '.$focus->table_name.'.'.$focus->table_index.' = ? ';
            $result=$adb->pquery($sql,array($record));
            if($adb->num_rows($result)>0)
            {
                $accountid=$adb->query_result($result,0,0);
                $allocatedate=$adb->query_result($result,0,'allocatedate');
                $publicaccount=$adb->query_result($result,0,'publicaccount');
                $createdtime=$adb->query_result($result,0,'createdtime');
                $distributiondate=$adb->query_result($result,0,'distributiondate');
                $protectdate=$adb->query_result($result,0,'protectdate');
				$pool_id=$adb->query_result($result,0,'pool_id');

            }

        }

         $bol='no';
        if($publicaccount>1)//公海客户
        {

            //$ruleinfo=getAccount_set_rule('complete',$pool_id);
            $all_program_arr = get_module_program_set_rule($this->module_name,'complete',$pool_id);
            //36077: （http://182.92.71.203:888/crm [^]）客户公海设置了目标为500天创建合同，但是创建了跟进记录，公海目标就显示达成。

            if(empty($allocatedate)||$allocatedate=='1600-01-01')
            {
                return false;
            }
            $startdate=$allocatedate;
            $timecolumnname='allocatedate';
        }
        else{
            $startdate=$distributiondate;
            $timecolumnname='distributiondate';
            //$ruleinfo=getAccount_set_rule('normal',1);
            $all_program_arr = get_module_program_set_rule($this->module_name,'normal',1);

        }

        if(empty($all_program_arr) || $publicaccount == 1)
        {
            if($publicaccount == 1){
                $sql='update ld_account set protectdate="",completed="" where accountid=?';
            }else{
                $sql='update ld_account set protectdate="",completed="已完成" where accountid=?';
            }
            $adb->pquery($sql,array($accountid));
            return false;
        }
        foreach ($all_program_arr as $tmpinfo){
            $ruleinfo = $tmpinfo['rule_arr'];
            foreach($ruleinfo as $tmp=>$tmpcontent)
            {
                if($tmpcontent['tabname']==$module)
                {
                    $bol='yes';
                    break;
                }
            }
        }
        if($module == $this->module_name){
            $bol = 'yes';
        }

        if($bol=='no')
        {
            return ;
        }

        $tmpdays=0;
        $tmpdates=array();
        $rulecondition='or';
        $sql="select ld_account.$timecolumnname,createdtime from ld_account where accountid=?";
        $result=$adb->pquery($sql,array($accountid));
        if($adb->num_rows($result)>0)
        {

            $timecolumnnamevalue=$adb->query_result($result,0,$timecolumnname);
            if($timecolumnnamevalue==''||date("Y-m-d",strtotime($timecolumnnamevalue))<='1600-01-01'){
                $timecolumnname = 'createdtime';
                $timecolumnnamevalue=$adb->query_result($result,0,'createdtime');
            }

        }
        //有多个回收方案的情况下,取最小的值

        $min_day = -1;
        $task_complete = 'yes';

        foreach ($all_program_arr as $tmpinfo) {
            $recycleselect = $tmpinfo['recycleselect'];
            if(!empty($recycleselect)){
                $recycleselect_sql = $recycleselect.' and ld_account.accountid = ?';
                $seletc_result = $adb->pquery(html_entity_decode($recycleselect_sql, ENT_QUOTES, $default_charset),[$accountid]);
                if($adb->num_rows($seletc_result)==0){
                    continue;
                }
            }

            $tmpdates =[];
            $ruleinfo = $tmpinfo['rule_arr'];

            foreach ($ruleinfo as $content) {

                $columnname = $content['columnname'];
                $days = $content['days'];
                $iscycle = $content['iscycle'];
                if ($content['tabname'] == 'Singin') {
                    $tmptablename = 'ld_singin';
                } else {
                    $tmpfocus = CRMEntity::getInstance($content['tabname']);
                    $tmptablename = $tmpfocus->table_name;
                }
                $othermoduledatecolumname = " max($tmptablename.$columnname) as othermoduledate";
                if ($iscycle != 'yes') {
                    $othermoduledatecolumname = " $tmptablename.$columnname as othermoduledate";
                }
                $rulecondition = $content['condition'];
                if ($content['condition'] == 'and') {

                    if ($content['tabname'] == 'Singin') {
                        $tmptablename = 'ld_singin';

                        $sql = " select  ld_account.accountid,ld_account.$timecolumnname,$othermoduledatecolumname from ld_account 
                             inner  join $tmptablename on $tmptablename.accountid=ld_account.accountid and DATE_FORMAT($tmptablename.createdtime,'%Y-%m-%d') >= ld_account.$timecolumnname 
                               and $tmptablename.accountid = ? and  $tmptablename.deleted=0 ";
                        $sql .= " and ld_account.smownerid=$tmptablename.userid ";
                    } else {


                        $tmptableindex = $tmpfocus->table_index;


                        $sql = " select  ld_account.accountid,ld_account.$timecolumnname,$othermoduledatecolumname from ld_account 
                             inner  join $tmptablename on $tmptablename.accountid=ld_account.accountid and DATE_FORMAT($tmptablename.createdtime,'%Y-%m-%d') >= ld_account.$timecolumnname 
                               and $tmptablename.accountid = ? and  $tmptablename.deleted=0 ";
                        $sql .= " and ld_account.smownerid=$tmptablename.smownerid ";

                    }
                    if ($iscycle == 'yes')
                        $sql .= "   where ld_account.accountid=?   group by ld_account.accountid having   datediff( curdate(),max($tmptablename.$columnname))<=$days  and max($tmptablename.$columnname)>ld_account.$timecolumnname  ";
                    else
                        $sql .= "   where ld_account.accountid=?   group by ld_account.accountid having   datediff(min($tmptablename.$columnname), ld_account.$timecolumnname)<=$days  and datediff(min($tmptablename.$columnname), ld_account.$timecolumnname)>=0    ";


                    $result = $adb->pquery($sql, array($accountid,$accountid));

                    if ($adb->num_rows($result) > 0) {
                        $columnnamedate = $adb->query_result($result, 0, 'othermoduledate');
                        if($iscycle == 'yes'){
                            $tmp_task_complete = 'no';
                        }else{
                            $tmp_task_complete = 'yes';
                        }
                        $tmpdates[] = array('startdate' => $columnnamedate, 'days' => $days, 'iscycle' => $iscycle, 'module' => $content['tabname']
                        , 'enddate' => DateOperation::addDays($columnnamedate, $days),'complete'=>$tmp_task_complete);

                    } else {
                        $tmp_task_complete = 'no';
                        $tmpdates[] = array('startdate' => $timecolumnnamevalue, 'days' => $days, 'iscycle' => $iscycle,
                        'module' => $content['tabname'], 'enddate' => DateOperation::addDays($timecolumnnamevalue, $days),'complete'=>$tmp_task_complete);
                    }
                    $tmpcondidtion = $content['condition'];

                } else if ($content['condition'] == 'or') {

                    if ($content['tabname'] == 'Singin') {
                        $tmptablename = 'ld_singin';

                        $sql = " select ld_account.accountid,ld_account.$timecolumnname,$othermoduledatecolumname from ld_account inner join $tmptablename  $tmptablename on $tmptablename.accountid=ld_account.accountid and DATE_FORMAT($tmptablename.createdtime,'%Y-%m-%d') >= ld_account.$timecolumnname   
                        and $tmptablename.accountid = ? and  $tmptablename.deleted=0 ";
                        $sql .= " and ld_account.smownerid=$tmptablename.userid ";
                    } else {
                        $tmpfocus = CRMEntity::getInstance($content['tabname']);
                        $tmptablename = $tmpfocus->table_name;
                        $tmptableindex = $tmpfocus->table_index;
                        $sql = " select ld_account.accountid,ld_account.$timecolumnname,$othermoduledatecolumname  from ld_account inner join $tmptablename  $tmptablename on $tmptablename.accountid=ld_account.accountid and DATE_FORMAT($tmptablename.createdtime,'%Y-%m-%d') >= ld_account.$timecolumnname 
                        and $tmptablename.accountid = ? and  $tmptablename.deleted=0 ";
                        $sql .= " and ld_account.smownerid=$tmptablename.smownerid ";
                    }


                    if ($iscycle == 'yes')
                        $sql .= "   where ld_account.accountid=?  
                         group by ld_account.accountid having  datediff( curdate(),max($tmptablename.$columnname))<=$days  and max($tmptablename.$columnname)>ld_account.$timecolumnname  ";
                    else
                        $sql .= "   where ld_account.accountid=?  having   datediff($tmptablename.$columnname, ld_account.$timecolumnname)<=$days and datediff($tmptablename.$columnname, ld_account.$timecolumnname)>=0 order by othermoduledate limit 1  ";
                        //   $sql.=" and datediff($tmptablename.$columnname,ld_account.$timecolumnname)<=$days ";

                    $result = $adb->pquery($sql, array($accountid,$accountid));

                    if ($adb->num_rows($result) > 0) {
                        if($iscycle == 'yes'){
                            $tmp_task_complete = 'no';
                        }else{
                            $tmp_task_complete = 'yes';
                        }
                        $columnnamedate = $adb->query_result($result, 0, 'othermoduledate');
                        $tmpdates[] = array('startdate' => $columnnamedate, 'days' => $days, 'iscycle' => $iscycle, 'module' => $content['tabname'], 'enddate' => DateOperation::addDays($columnnamedate, $days),'complete'=>$tmp_task_complete);

                    } else {
                        $tmp_task_complete = 'no';
                        $tmpdates[] = array('startdate' => $timecolumnnamevalue, 'days' => $days, 'iscycle' => $iscycle, 'module' => $content['tabname'], 'enddate' => DateOperation::addDays($timecolumnnamevalue, $days),'complete'=>$tmp_task_complete);
                    }
                }
            }

            //  if(empty($protectdate)||$protectdate=='1600-01-01')
            //  {
            //客户有保护结束日期，则只针对循环的判断获取最大值或最小值

            if ($content['condition'] == 'and') {
                $arr = array('enddate' => '3000-01-01');
                //且，获取最小值
                $tmp_all_complete = 'yes';
                foreach ($tmpdates as $dateinfo) {
                    //且条件中存在一个任务没完成就视为没完成
                    if($dateinfo['complete'] == 'no')$tmp_all_complete = 'no';
                    if ($dateinfo['enddate'] < $arr['enddate']) {
                        //<一定是小于，因为在创建时间相等的情况下，则取最小的的天数
                        $arr = $dateinfo;

                    }
                }
                if($tmp_all_complete == 'no')$task_complete = 'no';
            } else {
            //获取最大值
                $arr = array('enddate' => '1600-01-01');
                $tmp_all_complete = 'no';
                foreach ($tmpdates as $dateinfo) {
                    //或条件中存在一个任务完成就视为没完成
                    if($dateinfo['complete'] == 'yes')$tmp_all_complete = 'yes';

                    if ($dateinfo['enddate'] >= $arr['enddate']) {
                        //>=一定是大于等于，因为在创建时间相等的情况下，则取最大的天数
                        $arr = $dateinfo;
                    }
                }
                if($tmp_all_complete == 'no')$task_complete = 'no';
            }

            if($task_complete == 'yes')continue;

            $tmpdays = 0;
            if ($arr['startdate'] != '1600-01-01' && $arr['startdate'] != '2070-01-01') {
                $tmpdays = $arr['days'];
                $iscycle = $arr['iscycle'];
                $tmpmodule = $arr['module'];
                //存在多个回收方案时,取最小的时间计算保护结束日期
                if($min_day == -1 || $min_day > $tmpdays){
                    $result_arr = $arr;
                    $min_day = $tmpdays;
                }
            }
        }

         $tmpdays = $min_day;

         if($task_complete == 'yes'){
             $sql='update ld_account set protectdate="",completed="已完成" where accountid=?';
             $adb->pquery($sql,array($accountid));
         }else{
             if($tmpdays>0)
             {
                 //（1.6登录）公海已分配序时簿列表界面：设置公海客户回收条件保存后，在分配或领用之日起完成公海目标后，公海目标字段值没有显示“达成”（需要补丁）
                 $startdate=$result_arr['startdate'];
                 $enddate=$result_arr['enddate'];
                 $sql='update ld_account set protectdate="'.$enddate.'",completed="未完成" where accountid=?';

                 $adb->pquery($sql,array($accountid));
             }
             else
             {
                 /*
                 if($publicaccount>=2)
                 {
                     $days=getAccount_set_ProtectedDays("",$accountid);


                     $sql='update ld_account set protectdate=date_add(allocatedate,interval '.$days.' day) ,completed="" where accountid=?';
                     $adb->pquery($sql,array($accountid));

                 }

                 else if(empty($publicaccount))
                 {
                     $days= getAccount_set_normal_ProtectedDays_new("",$accountid);

                     $sql='update ld_account set protectdate=null,completed="" where accountid=?';
                     $adb->pquery($sql,array($accountid));
                 }
                 */
             }
         }
 }






	/**
	 * 判断本次操作是否选择了首要联系人字段，如果选择，则新增一个联系人
	 * @reason 0005694 导入客户信息时，选择首要联系人，未创建联系人信息
	 * @param $record Int 当前插入数据库的记录ID
	 * @return $importinfo Array 当前数据的结果集(字段名=>数据)
	 * @author Tujt 2014-05-05
	 */
	public function _after_import($record,$importinfo) {
	   //首要联系人
		if(isset($importinfo['lastname']) && !empty($importinfo['lastname'])){
			$contactfield = array('lastname','firstname','pphone','mobile','title',
										'assigned_user_id','salutationtype','email','faxx',
										'mailingstreet','mailingzip');
			$contactfocus = CRMEntity::getInstance('Contacts');
			foreach($contactfield as $fld){
				if(isset($importinfo[$fld]) && !empty($importinfo[$fld])){
					$contactfocus->column_fields[$fld] = $importinfo[$fld];
				}
			}
			$contactfocus->column_fields['account_id'] = $record;
			$contactfocus->column_fields['reference'] = 1;
			$_REQUEST['reference'] = 0;
			$contactfocus->save("Contacts");
		}
	}

     

    /*
    *更新操作
    *edit:andrwe
    *date:2015-05-27
    *reson:获取工作协同信息
    */
    function get_WorkReport($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global  $singlepane_view,$currentModule,$current_user,$adb;
        //duan 20221216 管理员和设置了查看所有关联数据的用户可以看到全部数据
        if($current_user->is_admin == 'on' || $current_user->accountallview == '1'){
            $SQL_WorkReport="select count(distinct tmp.workreportid) as count
                 from(select DISTINCT ld_workreport.workreportid from ld_workreport 
                        INNER JOIN ld_workreportrelatedto
                 on ld_workreport.workreportid=ld_workreportrelatedto.workreportid
                where ld_workreportrelatedto.relatedto=?) as tmp";
            $result = $adb->pquery($SQL_WorkReport,array($id));
        }else{
            $SQL_WorkReport="select count(distinct tmp.workreportid) as count
                 from(select DISTINCT ld_workreport.workreportid from ld_workreport 
                        INNER JOIN ld_workreportrelatedto
                 on ld_workreport.workreportid=ld_workreportrelatedto.workreportid
                  inner join ld_workreport2user on ld_workreport2user.workreportid=ld_workreport.workreportid
                where ld_workreport2user.userid=? and ld_workreportrelatedto.relatedto=?) as tmp";
            $result = $adb->pquery($SQL_WorkReport,array($current_user->id,$id));
        }
        
        if($adb->num_rows($result)>0)
             $noofrows = $adb->query_result($result,0,'count');
        else
            $noofrows='';
		$related_entries = array();
		$related_entries['relcount'] = $noofrows;
		return $related_entries;
	}
    function get_communicationLog($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global $adb;
		global $currentModule;
		global $list_max_entries_per_page_new_more;
        //获取字段
        $sql_field = 'select GROUP_CONCAT(CONCAT(tablename,".",columnname)) as columnname
                    from ld_field where uitype = 1101 and
                    (tabid = 4 or (tabid = 6 and tablename != "ld_contactdetails")) LIMIT 1;';
        $result_field = $adb->pquery($sql_field,array());
        $fieldlabel = $adb->query_result($result_field,0,'columnname');

		//手机、主题、接收人、发送时间、发件人，
        $header = array(getFixedLabel('Mobile'),getFixedLabel('Theme'),getFixedLabel('Recipient'),getFixedLabel('Delivery_time'),getFixedLabel('FROMMAIL'),getFixedLabel('Content'),getFixedLabel('SENDSTATESMS'));

        $sql_field_value='select '.$fieldlabel.' from ld_account
	                       LEFT JOIN ld_accountscf ON ld_account.accountid = ld_accountscf.accountid
	                       left join ld_contactdetails on ld_contactdetails.accountid = ld_account.accountid
	                       left join ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid
                           where ld_account.deleted = 0 and ld_account.accountid = ? ';
        $result = $adb->pquery($sql_field_value,array($id));
        $rows = $adb->num_rows($result);
        if($rows > 0){
            $fieldarr = explode(',',(string)$fieldlabel);
            $mobilearr = array();
            for($i=0;$i<$rows;$i++){
                foreach($fieldarr as $flds){
                    $fld = explode('.',$flds);
                    if(isset($fld[1])){
                        $val = $adb->query_result($result,$i,$fld[1]);
                        if(empty($val)) continue;
                        $mobilearr[$val] = $val;
                    }
                }
            }
        }
		if(!empty($mobilearr)){
			$phone_str = '"'.join('","',$mobilearr).'"';
		}else{
			$phone_str = '0';
		}
        $sql = 'select ld_smssend.taskid, ld_smssend.ReceiveContacts,ld_smssend.CalledNumber,
        ld_smssend.Subject, ld_smssend.SmsContent,ld_smssend.SmsBillingFee,
        case when IFNUll(SmsResult,0)=-1 then "待提交" when IFNUll(SmsResult,0)=1
        then "发送成功" when (IFNUll(SmsResult,0)<>1 and IFNUll(SmsResult,0)<>-1)
        then "发送失败" end smsresultname,createtime, ld_users.last_name as operator
        from ld_smssend left join ld_users on ld_smssend.operator = ld_users.user_name  where
        ld_smssend.CalledNumber in  ('.$phone_str.') and length(CalledNumber)>1     
        order by ld_smssend.createtime desc ';
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
        //手机、主题、接收人、发送时间、发件人、内容，
		$header = array(
			'<span title="'.getFixedLabel('Mobile').'">' . getFixedLabel('Mobile') . '</span>',
			'<span title="'.getFixedLabel('Recipient').'">' . getFixedLabel('Recipient') . '</span>',
			'<span title="'.getFixedLabel('Delivery_time').'">' . getFixedLabel('Delivery_time') . '</span>',
			'<span title="'.getFixedLabel('FROMMAIL').'">' . getFixedLabel('FROMMAIL') . '</span>',
			'<span title="'.getFixedLabel('Content').'">' . getFixedLabel('Content') . '</span>',
			'<span title="'.getFixedLabel('SENDSTATESMS').'">' . getFixedLabel('SENDSTATESMS') . '</span>'
		);
        $result = $adb->pquery($sql,array());
        $num_rows=$adb->num_rows($result);
        if($num_rows>0)
        {
            for($i=0;$i<$num_rows;$i++)
            {
                $listview_entrie = array();
                $taskid=$adb->query_result($result,$i,'taskid');
                $callednumber=$adb->query_result($result,$i,'callednumber');
				$listview_entrie[]= '<span title="'.fieldValueUitype::SetMobileStyle($taskid,$callednumber,"CommunicationLog").'">'.fieldValueUitype::SetMobileStyle($taskid,$callednumber,"CommunicationLog").'</span>';
                //$listview_entrie[]= $adb->query_result($result,$i,'subject');
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'receivecontacts').'">'.$adb->query_result($result,$i,'receivecontacts').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'createtime').'">'.$adb->query_result($result,$i,'createtime').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'operator').'">'.$adb->query_result($result,$i,'operator').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'smscontent').'">'.$adb->query_result($result,$i,'smscontent').'</span>';
                $listview_entrie[]= '<span title="'.$adb->query_result($result,$i,'smsresultname').'">'.$adb->query_result($result,$i,'smsresultname').'</span>';
                $listview_entries[] = $listview_entrie;
            }
        }
		$navigationOutput = Array();$url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
		$navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'CommunicationLog',$id);
        $tmpwidth=getCvColumnListWidth('CommunicationLog','related_customview',0);
        if(sizeof($tmpwidth))
        {
             foreach($tmpwidth as $columnname=>$width)
             {
                $fieldwidth[]=$width.'setting';
             }
        }
        else{
             $fieldwidth[]=getModuleFieldProportion(1);
            $fieldwidth[]=getModuleFieldProportion(1);
            $fieldwidth[]=1.5;
            $fieldwidth[]=getModuleFieldProportion(1);
            $fieldwidth[]=4;
            $fieldwidth[]=0.5;
        
        }
       $fieldwidth=getModuleWidth($focus,$fieldwidth,$currentModule);
        $headermodules=array('CommunicationLog','CommunicationLog','CommunicationLog','CommunicationLog','CommunicationLog','CommunicationLog');
        $headerfieldname=array('callednumber','receivecontacts','createdtime','last_name','smscontent','smresultname');
        $return_value = array('fieldwidth'=>$fieldwidth,'headername'=>array('module'=>$headermodules,'fieldname'=>$headerfieldname),'header'=>$header,'entries'=>$listview_entries,'navigation'=>$navigationOutput,'noofrows'=>$noofrows);
		return $return_value;
	}
    /**
     * edit：cyb
     * date：2015-11-30
     * reason：客户模块下，相关信息新增已购产品。
    **/
    function get_buyproduct($id, $cur_tab_id, $rel_tab_id, $actions=false)
    {
        //列头显示：
        $product_focus=CRMEntity::getInstance("Products");
        $product_fieldobj=$product_focus->fieldobj;
        $prodductnamelabel=$product_fieldobj->getFieldInfoBykeyValue("columnname","productname","fieldlabel");
        $prodductnolabel=$product_fieldobj->getFieldInfoBykeyValue("columnname","product_no","fieldlabel");
        //$prodductproductcategorylabel=$product_fieldobj->getFieldInfoBykeyValue("columnname","productcategory","fieldlabel");
        $rel_listheader=array();
        $rel_listheader[]=$prodductnamelabel;
        $rel_listheader[]=$prodductnolabel;
        //$rel_listheader[]=$prodductproductcategorylabel;
        $rel_listheader[]=getFixedLabel('TOTALHOLDINGS');
        $rel_listheader[]=getFixedLabel('THELATESTORDERDATE');
        $rel_listheader[]=getFixedLabel('OPERATING'); 

        //列表数据信息显示：
        global $adb;       
           
        //获取分页
       	global $related_left_type;
        global $related_left_start;
        global $list_max_entries_per_page_new_more;
        $query_count='';
        $query_count .='SELECT DISTINCT productid FROM ld_buyproducthistory WHERE  accountid=?';        
        //echo $query_count;
        $result=$adb->pquery($query_count,array($id));
       	$noofrows = $adb->num_rows($result);               
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
		$related_left_start = $start;
		$limstart=($start-1)*$list_max_entries_per_page_new_more;        
        $query_product='';
        $query_product .='select 
                            	ld_products.productid,
                                ld_products.productname,
                            	ld_products.product_no,
                            	ld_buyproducthistory.after_total,
                            	ld_buyproducthistory.operationtime,
                                ld_buyproducthistory.currencyid
                          from ld_buyproducthistory ';       
        $query_product .=" inner join
                                (
                            	  select max(id) as idd,productid 
                                  from 
                            	    ld_buyproducthistory 
                                  WHERE ld_buyproducthistory.accountid=$id
                                  group by productid";                    
        $query_product .=' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.') as tmp ';   
        $query_product .=" on tmp.idd=ld_buyproducthistory.id  
                            INNER JOIN ld_products ON ld_buyproducthistory.productid=ld_products.productid
                            WHERE ld_buyproducthistory.accountid=$id
                            order by ld_products.productname";                             
        // echo $query_product;
        $product_result = $adb->pquery($query_product,array());
        $num_rows = $adb->num_rows($product_result);   
        $trades=getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
        $tradename=ucwords($trades['trade']);//将字符串首字母转化成大写。    
        for($i = 0; $i < $num_rows; $i++)
        {
          $productid = $adb->query_result($product_result,$i,'productid');          
          $productname = $adb->query_result($product_result,$i,'productname');
          $product_no = $adb->query_result($product_result,$i,'product_no');          
          $after_total = $adb->query_result($product_result,$i,'after_total');
          $operationtime = $adb->query_result($product_result,$i,'operationtime');   
          $currencyid=$adb->query_result($product_result,$i,'currencyid');
          $curencyobj=new Currency($adb,$currencyid) ;
          $currency_sysbol=  $curencyobj->getCurrencySymbol();        
          $entityname = '<a style="text-decoration:none" href="javascript:void(0);" onclick="show_trade_history(\'\',\''.$productid.'\',\''.$id.'\',\''.$tradename.'\')">'.getFixedLabel('TRANSACTIONHISTORY').'</a>';   
          //获取列表显示数据：
          $history_products[$productid]=array
                                                  (
                                                   "productname"=>$productname,"product_no"=>$product_no,
                                                   //"productcategory"=>$productcategory,                                
                                                   "after_total" =>'<div align="right">'.$currency_sysbol.setNumberFormat($after_total,2).'</div>',
                                                   "operationtime"=>$operationtime,
                                                   "transactionhistory"=>$entityname                                        
                                                   );           
        }   
        $navigationOutput = Array();$url_qry = '';
         crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);             
 	    $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,"Accounts",'BoughtProduct',$id);		                                    	       
        $return_value = array('header'=>$rel_listheader,'entries'=>$history_products,'navigation'=>$navigationOutput,'fieldwidth'=>'');
		return $return_value;      
    }
    /**
     * edit：cyb
     * date：2016-01-15
     * reason：相关信息下增加金蝶订单。
    **/
    function get_Kingdeeorders($id, $cur_tab_id, $rel_tab_id, $actions=false)
    {       
        if(!empty($id)){
            $focus=CRMEntity::getInstance("Accounts");
            $focus->retrieve_entity_info($id,"Accounts");
            if(!empty($focus->column_fields['accountname'])){
                require_once('user_privileges/interface_reader_kingdee_k3.php');  
                     
                $rel_listdata=Account_Kingdeeorders($focus);      
                $rel_listheader=$rel_listdata['list_header']; 
                $rel_listentries=$rel_listdata['list_entries'];    
                $navigation = $rel_listdata['navigation'];    
            }
        }
        $return_value = array('header'=>$rel_listheader,'entries'=>$rel_listentries,'navigation'=>$navigation,'fieldwidth'=>'');
        return $return_value;   
    }
    /**
     * edit：cyb
     * date：2016-01-15
     * reason：相关信息下增加金蝶报价单。
    **/
    function get_Kingdeequotes($id, $cur_tab_id, $rel_tab_id, $actions=false)
    {
        if(!empty($id)){
            $focus=CRMEntity::getInstance("Accounts");
            $focus->retrieve_entity_info($id,"Accounts");
            if(!empty($focus->column_fields['accountname'])){
                require_once('user_privileges/interface_reader_kingdee_k3.php');        
                $rel_listdata=Account_Kingdeequotes($focus);      
                $rel_listheader=$rel_listdata['list_header']; 
                $rel_listentries=$rel_listdata['list_entries'];    
                $navigation = $rel_listdata['navigation'];    
            }
        }
        $return_value = array('header'=>$rel_listheader,'entries'=>$rel_listentries,'navigation'=>$navigation,'fieldwidth'=>'');
        return $return_value;   
    }
	
	//获取企企报表
	    public function get_qiqireport($id, $cur_tab_id, $rel_tab_id, $actions=false)
    {
        $return = [];
        if(!empty($id)){
            $focus=CRMEntity::getInstance("Accounts");
            $focus->retrieve_entity_info($id,"Accounts");
            $focus->id = $id;
            if(!empty($focus->column_fields['accountname'])){
                crm_load_class_file('cls_QiQiReport', 'modules/Accounts');
                $cls_QiQiReport = new cls_QiQiReport();
                $return = $cls_QiQiReport->get77ReportData($focus);
            }
        }

        return $return;
    }
	
    /**
     * edit:cyb
     * date:2016-01-19
     * reason:相关信息下增加鼎捷订单。
    **/
    function get_Digiwinorders($id, $cur_tab_id, $rel_tab_id, $actions=false)
    {
         if(!empty($id)){
            $focus=CRMEntity::getInstance("Accounts");
            $focus->retrieve_entity_info($id,"Accounts");
			$focus->id = $id;
            if(!empty($focus->column_fields['accountname'])){
                require_once('user_privileges/interface_reader_Digiwin.php');        
                $rel_listdata=Account_Digiwinorders($focus);      
                $rel_listheader=$rel_listdata['list_header']; 
                $rel_listentries=$rel_listdata['list_entries'];    
                $navigation = $rel_listdata['navigation'];
                $relcount = $rel_listdata['relcount'];    
            }
        }   
        $return_value = array('header'=>$rel_listheader,'entries'=>$rel_listentries,'navigation'=>$navigation,'fieldwidth'=>'','relcount'=>$relcount);
        return $return_value; 
    }
    /**
     * edit:cyb
     * date:2016-01-19
     * reason:相关信息下增加鼎捷服务单。
    **/
    function get_Digiwintickets($id, $cur_tab_id, $rel_tab_id, $actions=false)
    {
        if(!empty($id)){
            $focus=CRMEntity::getInstance("Accounts");
            $focus->retrieve_entity_info($id,"Accounts");
            if(!empty($focus->column_fields['accountname'])){
                require_once('user_privileges/interface_reader_Digiwin.php');        
                $rel_listdata=Account_Digiwintickets($focus);      
                $rel_listheader=$rel_listdata['list_header']; 
                $rel_listentries=$rel_listdata['list_entries'];    
                $navigation = $rel_listdata['navigation'];    
            }
        }    
        $return_value = array('header'=>$rel_listheader,'entries'=>$rel_listentries,'navigation'=>$navigation,'fieldwidth'=>'');
        return $return_value; 
    }



	/**
	 * @project PROT93 邮件管理改进
	 * @author Tujt 2015-01-05
	 */
	public function get_dingjiesales($id, $cur_tab_id, $rel_tab_id, $actions=false) {
	   require(globalStatic::$root_directory.'include/trade/dingjie.php');
	         project_dingjie::get_dingjiesales($id, $cur_tab_id, $rel_tab_id, $actions);
	}

    /**
     *edit:cyb
     *date:2016-05-18
     *reason:帮我吧接口开启，则同步删除bangwo8系统客户信息；
    **/
   function trash($module,$id){
		//调用帮我吧接口
      //$this->crm_operation_bangwo_ba(array($id),'del');
      parent::trash($module,$id);
   }
   /**
    * edit:cyb 
    * date:2016-05-18
    * reason:点击回收站还原按钮时，重写crmentity类中的还原函数；
    **/
   	function restore($module, $id) {
		//调用帮我吧接口
		//$this->crm_operation_bangwo_ba(array($id),'add');
		parent::restore($module,$id);
		$this->SyncAccountToBangwoba($id,'create');
   	}
    /**
     * edit：cyb
     * date：2016-06-22
     * reason：客户模块下，相关信息新增已购产品份额(基金)。
    **/
    function get_buyproductquantity($id, $cur_tab_id, $rel_tab_id, $actions=false)
    {
        //列头显示：
        $product_focus=CRMEntity::getInstance("Products");
        $product_fieldobj=$product_focus->fieldobj;
        $prodductnamelabel=$product_fieldobj->getFieldInfoBykeyValue("columnname","productname","fieldlabel");
        $prodductTimelabel=$product_fieldobj->getFieldInfoBykeyValue("columnname","productsheet","fieldlabel");
        $rel_listheader=array();
        $rel_listheader[]=$prodductnamelabel;
        $rel_listheader[]=$prodductTimelabel;
        $rel_listheader[]=getFixedLabel('HOLDQUANTITY');
        $rel_listheader[]=getFixedLabel('THELASTDAYOFCHANGE');
        $rel_listheader[]=getFixedLabel('OPERATING'); 
        
        //获取分页
        global $adb; 
       	global $related_left_type;
        global $related_left_start;
        global $list_max_entries_per_page_new_more;
        $query_count='';
        $query_count .='SELECT  DISTINCT(productid) FROM ld_fund_buyproductquantityhistory WHERE  accountid=?';        
        //echo $query_count;
        $result=$adb->pquery($query_count,array($id));
       	$noofrows = $adb->num_rows($result);               
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
		$related_left_start = $start;
		$limstart=($start-1)*$list_max_entries_per_page_new_more;        
        $query_product='';
        $query_product .='
                        SELECT
                            ld_fund_buyproductquantityhistory.productid,
                            ld_products.productname,
                            ld_products.productsheet,
                            SUM(ld_fund_buyproductquantityhistory.quantity) as quantity,
                            max(ld_fund_buyproductquantityhistory.operationtime)as operationtime
                        FROM
                            ld_fund_buyproductquantityhistory
                        INNER JOIN ld_products ON ld_fund_buyproductquantityhistory.productid = ld_products.productid
                        WHERE ld_fund_buyproductquantityhistory.accountid=?
                        GROUP BY ld_fund_buyproductquantityhistory.productid
                        ORDER BY ld_products.productname';                 
        $query_product .=' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more;
        $product_result = $adb->pquery($query_product,array($id));
        $num_rows = $adb->num_rows($product_result); 
        $trades=getVersionTradeInfo();//获取数据库版本（了解属于什么行业）。
        $tradename=ucwords($trades['trade']);//将字符串首字母转化成大写。
        for($i = 0; $i < $num_rows; $i++)
        {
          $productid = $adb->query_result($product_result,$i,'productid');  
          $productname = $adb->query_result($product_result,$i,'productname');          
          $productsheet = $adb->query_result($product_result,$i,'productsheet');
          $quantity = $adb->query_result($product_result,$i,'quantity');
          $operationtime = $adb->query_result($product_result,$i,'operationtime'); 
          $entityname = '<a style="text-decoration:none" href="javascript:void(0);" onclick="show_trade_history(\'\',\''.$productid.'\',\''.$id.'\',\''.$tradename.'\')">'.getFixedLabel('TRANSACTIONHISTORY').'</a>';   
          //获取列表显示数据：
          $history_products[$productid]=array
                                                  (
                                                   "productname"=>$productname,"productsheet"=>$productsheet,                                                                                
                                                   "quantity" =>'<div align="right">'.$currency_sysbol.setNumberFormat($quantity,2).'</div>',
                                                   "operationtime"=>$operationtime,
                                                   "transactionhistory"=>$entityname                                        
                                                   );           
        }
        $navigationOutput = Array();$url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);             
 	    $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,"Accounts",'buyProductQuantity',$id);		                                    	       
        $return_value = array('header'=>$rel_listheader,'entries'=>$history_products,'navigation'=>$navigationOutput,'relcount'=>$noofrows,'fieldwidth'=>'');
		return $return_value;      
    }

	public function getAccountPublicAccount($record){
		global $adb;
		$publicaccount = 0;
		if(!empty($record)){
			$query = 'select publicaccount from ld_account where accountid = ? limit 1';
			$result = $adb->pquery($query,array($record));
			$publicaccount = $adb->query_result($result,0,0);
		}
		return $publicaccount;
	}
    /*
    duan 2022-3-4
    客户模块单据导入规则：
    （1）如果所属公海为空，则设置公海状态为普通客户
    （2）如果所属公海不为空，但公海状态为普通客户，则设置为未分配
    （3）所属公海与公海状态字段冲突时，以所属公海为标准
    */
    public function updateImportPublicAccount($record){
        crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
        $cls_PublicAccounts = new cls_PublicAccounts($this->moduleName);
        $public_account = $cls_PublicAccounts->getPublicAccountConfig();
        //判断客户模块是否启用公海
        if($public_account['status'] == 'yes'){
            global $adb;
            $sql = 'UPDATE ld_account SET publicaccount = 
                        CASE 
                            WHEN pool_id = 0 THEN 0 
                            WHEN pool_id > 0 AND (publicaccount = 0 || publicaccount is null) THEN 1
                            ELSE publicaccount
                        END 
                        where accountid = ?;';
            $adb->pquery($sql,array($record));
        }
    }

    //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块
    //普通客户数量上限
    public function getCommonAccountLimitCount($userid=''){
        global $adb,$current_user,$static_user_limit_count_arr;
        if (empty($userid)) {
            $userid = $current_user->id;
        }
        if(is_array($static_user_limit_count_arr))
        {
            if(array_key_exists($userid.'aa',$static_user_limit_count_arr))
            return $static_user_limit_count_arr[$userid.'aa'];
        }
        else{
            $static_user_limit_count_arr=[];
        }
        
        crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
        $cls_PublicAccounts = cls_PublicAccounts::getInstance($this->moduleName);
        $public_account = $cls_PublicAccounts->getPublicAccount();
        $limit_type = $public_account['limit_type'];
        if ($limit_type == 'user') {
            $limit_count = $public_account['limit_count'];//按用户上限
        } else if ($limit_type == 'role'){
            require_once globalStatic::$root_directory.'include/utils/UserInfoUtil.php';
            $roleid = getUserRoleId($userid);
            $sql = 'SELECT limit_count FROM ld_account_role_limitcount_common WHERE roleid=? limit 1;';

            $result = $adb->pquery($sql, array($roleid));
            $rows = $adb->num_rows($result);
            if ($rows > 0) {
                $limit_count = $adb->query_result($result, 0, 'limit_count');
            } else {
                $limit_count = 0;
            }
        }else{
            $limit_count = 9999999999;
        }
        if ($limit_count == '') {
            $limit_count = 0;
        }
        $static_user_limit_count_arr[$userid.'aa']=$limit_count;
        return $limit_count;
    }
    //获取负责人已有的普通客户数量
    public function getSmowerNumForCommonAccount($userid=''){
        global $adb,$current_user;
        if (empty($userid)) {
            $userid = $current_user->id;
        }
        $query = "select count(1) as num from ld_account where smownerid = ?  and deleted = 0 and publicaccount = 0  and pool_id = 0";
        $result = $adb->pquery($query,array($userid));
        return $adb->query_result($result,0,'num');
    }
    //公海已分配客户数量上限
    public function getPublicAccountLimitCount($userid,$pool_id){
        global $adb,$current_user;
        if (empty($userid)) {
            $userid = $current_user->id;
        }
        crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
        $cls_PublicAccounts = new cls_PublicAccounts($this->moduleName);
        $public_account = $cls_PublicAccounts->getPublicAccountConfig();

        if ($public_account['status'] == 'yes') {
            //公海已分配客户数量上限
            $limit_type = $public_account['public_account_pool'][$pool_id]['limit_type'];
            if ($limit_type == 'user') {
                $limit_count = $public_account['public_account_pool'][$pool_id]['limit_count'];//按用户上限
            } else if ($limit_type == 'role'){
                crm_load_function_file('getUserRoleId', 'include/utils', 'UserInfoUtil');
                $roleid = getUserRoleId($userid);
                $sql = 'SELECT limit_count FROM ld_account_role_limitcount WHERE roleid=? and pool_id = ? limit 1;';

                $result = $adb->pquery($sql, array($roleid,$pool_id));
                $rows = $adb->num_rows($result);
                if ($rows > 0) {
                    $limit_count = $adb->query_result($result, 0, 'limit_count');
                } else {
                    $limit_count = 0;
                }
            }else{
                $limit_count = 9999999999;
            }
        }else{
            $limit_count = 9999999999;
        }
        if ($limit_count == '')
            $limit_count = 0;

        return $limit_count;
    }
    //获取负责人已有的公海已分配客户数量
    public function getSmowerNumForPublicAccount($userid,$pool_id){
        global $adb,$current_user;
        if (empty($userid)) {
            $userid = $current_user->id;
        }
        $query = "select count(1) as num from ld_account where smownerid = ? and publicaccount>1 and deleted = 0  and pool_id = ?";
        $result = $adb->pquery($query,array($userid,$pool_id));
        $num = $adb->query_result($result,0,'num');
        if ($num == '') $num = 0;
        return $num;
    }

}
Accounts::require_file();
?>