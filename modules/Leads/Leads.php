<?php
class Leads extends CRMEntity{
    public $db;
    var $table_name = "ld_leads";
	var $table_index= 'leadsid';//主表主键
    var $table_code='leads_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_leads','ld_leadscf');
    //定义各个表主键
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_leads'=>'leadsid','ld_leadscf'=>'leadsid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_leadscf', 'leadsid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    
	var $column_fields = Array();
	public  $module_name='Leads';
 //和主表关联的模块
    var $relatedtab=array('salesorder'=>'','users'=>'','accounts'=>'','company'=>'','leads'=>'','potentials'=>'');
	var $sortby_fields = Array('leads_no','smownerid');
    
	
	var $list_link_field= 'leads_no';

	var $search_fields = Array(
			'leads No'=>array('ld_leads'=>'leads_no')
			);

	var $search_fields_name = Array(
			'Account Name'=>'accountname',
		
			'Assigned To'=>'assigned_user_id',
			);
	// This is the list of lingdang_fields that are required
	var $required_fields =  array();

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
    //比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'accountname');

	//Default Fields for Email Templates -- Pavani
//	var $emailTemplate_defaultFields = array('accountname','account_type','industry','annualrevenue','phone','email1','rating','website','fax');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'leads_no';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
    //拼音查询字段
	var $def_basicsearch_col = 'leads_no';
    var $popup_fields=Array();
    var $detailfieldobj;//明细表字段对象
    public $usersaccount;
    public $administrator;
    public $publicaccountstatus;
    public $public_account_pool;
    public $adminaccount;
    function __construct() {
		//$this->log =LoggerManager::getLogger('Expense');
		$this->db = PearDatabase::getInstance();
		 $this->fieldobj=Field::getInstance('Leads',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
      
             /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('Leads');
        $this->list_link_field=$entityname['fieldname'];
        
        $this->popup_fields=Array($this->list_link_field);
        $this->module_name='Leads';
	}
  

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
    
   	function unlinkRelationship($id, $return_module, $return_id)
    {
			$this->trash('Leads',$id);
		//}
    }
	
	//更改商机状态
	function updateStatus($recordid,$status,$fileurereason){
		global $adb;
		if(!empty($status) && !empty($recordid)){
			$focus = CRMEntity::getInstance('Leads');
			switch($status){
				case 'Upgrade':
				   $status = '升级';
				   break;
				case 'Following':
				   $status = '跟进中';
				   break;
				case 'Failedtoclose':
				   $status = '失败关闭';
				   break;
			}
			$query = 'select status from ld_leads where leadsid = ?';
			$result = $adb->pquery($query,array($recordid));
			$db_status = $adb->query_result($result,0,0);
			$s_status = $status;
			$query = 'update ld_leads set status = ?,failurereason=?,modifiedtime="'.date('Y-m-d H:i:s').'" where leadsid = ?';
             
			if($s_status == '升级')$s_status = '跟进中';
			$adb->pquery($query,array($s_status,$fileurereason,$recordid));
			$focus->getModuleStatic('ModTracker');//字段修改日志
			$focus->modstatic->saveFieldLogOne('Leads','status',$recordid,$db_status, $s_status);
            $accountstatus=$status;
             $_REQUEST['record']=$recordid;
			if($status == '升级'){
				crm_load_class_file('cls_SaveMappingFields','modules/Leads');
				$cls_SaveMappingFields = new cls_SaveMappingFields('Leads',$_REQUEST['record']);
				$resultupdate = $cls_SaveMappingFields->Upgrade();
               
                $_REQUEST['crmid']=$resultupdate['accountid'];
				//升级成功后删除对应的销售线索
			     include(globalStatic::$root_directory."crmmarket/updateaccountSaveStatus.php");
				if($resultupdate['code'] == 1){
					foreach($this->tab_name as $key=>$arr){
						//Edit by luyx 2022-08-09 Reason:线索转化报表需要显示创建时间
						//$sql='delete from '.$arr.' where '.$this->tab_name_index[$arr].' = '.$_REQUEST['record'];
						$sql='update '.$arr.' SET deleted=1 where '.$this->tab_name_index[$arr].' = '.$_REQUEST['record'];
						$adb->query($sql);
					}
				}
			}
            else
            {
                $_REQUEST['crmid']=$_REQUEST['record'];
                include(globalStatic::$root_directory."crmmarket/updateaccountSaveStatus.php");
            }

             
             
            
            
		}
	}

	function save_module($module){
        global $adb,$current_user;
        if(isset($_REQUEST['bill_state'])||isset($_REQUEST['bill_city'])
            ||isset($_REQUEST['bill_street'])||isset($_REQUEST["bill_street_mass_edit_check"])
            ||isset($_REQUEST["bill_city_mass_edit_check"]))
            $this->updateAccountAddress($this->id);
        if($this->mode != 'edit'){
			//chj 2022/3/24 复制销售线索，导致没有公海池的问题
			if(!empty($_REQUEST['isDuplicate']) && ($_REQUEST['isDuplicate'] == true || $_REQUEST['isDuplicate'] == 'true')){
				$query = "select pool_id,publicaccount from ld_leads where leadsid = ?";
				$result = $adb->pquery($query,array($_REQUEST['record']));
				if($adb->num_rows($result) >= 1){
					$_REQUEST['publicaccount'] = $adb->query_result($result,0,'publicaccount');
					$_REQUEST['pool_id'] = $adb->query_result($result,0,'pool_id');
				}
			}
            if($_REQUEST['publicaccount']) {
                $publicaccount = $_REQUEST['publicaccount'];
                //公海池
                if(!empty($_REQUEST['pool_id'])){
                    $update_query = "update ld_leads set pool_id=? where leadsid=?";
                    $adb->pquery($update_query, array($_REQUEST['pool_id'],$this->id));
                }
                $opdate = date('Y-m-d');
                $days = getLeads_set_ProtectedDays("",$this->id);
                $protectdate=date("Y-m-d",strtotime("$opdate +$days day"));
                if($days=='')
                {
                    $protectdate=null;
                }
                if($publicaccount == 2){
                    $update_query = "update ld_leads set publicaccount=?,lastdistributedate=?,allocatedate=?,protectdate=?,protectstartdate=now() where leadsid=?";
                    $adb->pquery($update_query, array($publicaccount,$opdate,$opdate,$protectdate,$this->id));
                }else{
                    $update_query = "update ld_leads set publicaccount=?,allocatedate=? where leadsid=?";
                    $adb->pquery($update_query, array($publicaccount,'',$this->id));
                }

            }else{
				$opdate=date('Y-m-d');
				$days=getLeads_set_normal_ProtectedDays("",$this->id);
				if(!empty($days)){
					$protectdate=date("Y-m-d",strtotime("$opdate +$days day"));
				}
                $update_query = "update ld_leads set allocatedate=?,protectdate=?,protectstartdate=now() where leadsid=?";
                $adb->pquery($update_query, array('',$protectdate,$this->id));
            }
        }
        //因为存在编辑字段后导致条件变化的可能性，所以每次保存的时候重算一下保护结束日期
        $this->updateAccountInfo($this->moduleName,$this->id);
    }
    /**
    * @edit:dong
    * @data:2020/08/20
    * @reason:分配负责人，修改创建人后操作
    * @description:
    */
    function massChangeUser_after($module,$ids,$type)
    {
        global $current_user,$adb;
        if(empty($ids)||$ids=='')
        {
            return ;
        }
        if(is_array($ids))
        {
            $ids=implode(',',$ids);
        }
        if(strtolower($type)=='allocate')
        {
            $ids=explode(',',$ids);
            $ids=array_unique($ids);
            $opdate=date('Y-m-d');
            foreach($ids as $recordid)
            {
				//chj 2022/7/20 普通客户和公海客户回收规则相关功能优化（杨奇寰） 
				$query = "select publicaccount from ld_leads where leadsid = ?";
				$result = $adb->pquery($query,array($recordid));
				if($adb->num_rows($result) >= 1){
					$publicaccount = $adb->query_result($result,0,0);
					if($publicaccount <= 0){
						$days=getLeads_set_normal_ProtectedDays("",$recordid);
						if(!empty($days)){
							$protectdate=date("Y-m-d",strtotime("$opdate +$days day"));
						}
						$sql = 'update '.$this->table_name.' set lastdistributer = ? ,distributiondate=?,protectdate=? where '.$this->table_index.' = ? ';
						$adb->pquery($sql,array($current_user->id,$opdate,$protectdate,$recordid));
					}else{
						$days=getLeads_set_ProtectedDays("",$record);
						if(!empty($days)){
							$protectdate=date("Y-m-d",strtotime("$opdate +$days day"));
						}
						$sql = 'update '.$this->table_name.' set lastdistributer = ? ,allocatedate=?,protectdate=? where '.$this->table_index.' = ? ';
						$adb->pquery($sql,array($current_user->id,$opdate,$protectdate,$recordid));
					}
					
				}
                //分配后重算保护结束日期
                $this->updateAccountInfo($this->moduleName,$recordid);
            }
        }
    }

    //更新客户定位地址、经纬度
    function updateAccountAddress($leadsid)
    {
        $accountaddressPath = globalStatic::$root_directory . 'modules/' . $this->module_name . '/accountaddress.txt';
        //duan 20231116 增加优化，如果通过移动端的定位功能获取到经纬度，则不需要重新计算经纬度（在详细地址不修改的情况下）
        global $weixin_user, $adb;
        if (!empty($weixin_user) && $_REQUEST['locationaddress_lat'] != '' && $_REQUEST['locationaddress_lng'] != '') {
            $tablename = $this->table_name;
            $tableindex = $this->table_index;
            $address = $_REQUEST['locationaddress'];
            $latitude = $_REQUEST['locationaddress_lat'];
            $longtitude = $_REQUEST['locationaddress_lng'];
            $update_address_sql = "update $tablename set location_address =?, longtitude = ?, latitude = ? where $tableindex = ?";
            $adb->pquery($update_address_sql, array($address, $longtitude, $latitude, $leadsid));
            return;
        }
        //31591: 客户新增保存后，获取地址经纬度判断服务器是否能上网
        if (file_exists($accountaddressPath)) {
            $filehandler = file_get_contents($accountaddressPath);
            $handlerinfos = explode("\r\n", (string) $filehandler);

            $date = $handlerinfos[0];
            $tmpcheck = $handlerinfos[1];
            if ($date != date("Y-m-d")) {
                file_put_contents($accountaddressPath, date("Y-m-d"));
                //$check = @fopen('http://www.baidu.com',"r");
                $check = @fopen('http://apis.map.qq.com', "r");
                if ($check) {
                    file_put_contents($accountaddressPath, "\r\n" . 'yes', FILE_APPEND);
                } else {
                    file_put_contents($accountaddressPath, "\r\n" . 'no', FILE_APPEND);
                    return;
                }
            }

            if ($tmpcheck == 'no') {
                return;
            }
        } else {
            file_put_contents($accountaddressPath, date("Y-m-d"));

            //$check = @fopen('https://www.baidu.com/',"r");
            $check = @fopen('http://apis.map.qq.com', "r");
            if ($check) {
                file_put_contents($accountaddressPath, "\r\n" . 'yes', FILE_APPEND);
            } else {
                file_put_contents($accountaddressPath, "\r\n" . 'no', FILE_APPEND);
                return;
            }
        }
        $this->updateAccountAddressWithoutCheckNet($leadsid);
    }

    function updateAccountAddressWithoutCheckNet($leadsid){
        global $adb;
        $query = "select CONCAT_WS('',bill_state,bill_city,bill_street) as address,leadsid from ld_leads";
        if(!empty($leadsid)){
            $query .= " where leadsid = $leadsid";
        }
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        for($i=0; $i<$num_rows; $i++){
            $address = $adb->query_result($result,$i,0);
            $leadsid = $adb->query_result($result,$i,1);
            if(!empty($address)){
                //客户表中保存的坐标由百度经纬度改为腾讯经纬度  date:20180525 xxs
                //$accountAddress=file_get_contents("http://api.map.baidu.com/geocoder/v2/?address=".urlencode($address)."&output=json&ak=Hgvb6X18khZw223dBW1hFHuT");
                //$accountAddress=file_get_contents("https://apis.map.qq.com/ws/geocoder/v1/?address=".$address."&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X");
                $accountAddressInfos=getCoordinateByTecentApi($address);
                if(array_key_exists('result',$accountAddressInfos)){
                    $longtitude = $accountAddressInfos['result']['location']['lng'];
                    $latitude = $accountAddressInfos['result']['location']['lat'];
                    $adb->pquery('update ld_leads set location_address =?, longtitude = ?, latitude = ? where leadsid = ?',array($address,$longtitude,$latitude,$leadsid));
                }else{
                    $adb->pquery('update ld_leads set location_address =?, longtitude = ?, latitude = ? where leadsid = ?',array($address,'','',$leadsid));
                }
            }else{
                $adb->pquery('update ld_leads set location_address =?, longtitude = ?, latitude = ? where leadsid = ?',array($address,'','',$leadsid));
            }
        }
    }
    
    
    public function setpublicLeadsCount($obj, $recordid)
    {
        static $publicaccountcount;
        global $adb;
        if (!empty($publicaccountcount) && $publicaccountcount > 2000) {
            return;
        }
		$sql_accountid = 'select publicaccount,pool_id from ld_leads  where leadsid=? limit 1;';

		$sql_result = $adb->pquery($sql_accountid, array($recordid));
		$publicaccount = $adb->query_result($sql_result, 0, 'publicaccount');
		$pool_id = $adb->query_result($sql_result, 0, 'pool_id');
        if ($obj->public_account['status'] == 'yes') {
            //0025702: 客户列表：公海参数设置，按角色控制，设置报表库数量上限4
            crm_load_function_file('getUserRoleId', 'include/utils', 'UserInfoUtil');
            $roleid = getUserRoleId($obj->getUserId());
            //公海已分配客户数量上限
			$public_account_limit_type = $obj->public_account['public_account_pool'][$pool_id]['limit_type'];
			if ($public_account_limit_type == 'user') {
				$count = $obj->public_account['public_account_pool'][$pool_id]['limit_count'];//按用户上限
			}else if ($public_account_limit_type == 'role'){
				$sql = 'SELECT limit_count FROM ld_leads_role_limitcount WHERE roleid=? and pool_id = ? limit 1;';

				$result = $adb->pquery($sql, array($roleid,$pool_id));
				$rows = $adb->num_rows($result);
				if ($rows > 0) {
					$count = $adb->query_result($result, 0, 'limit_count');
				} else {
					$count = 0;
				}
			}else{
                $count = 9999999999;
            }
            $publicaccountcount = $count;

            if ($count >= 20000) {

                return;
            }
        }
        $count = $publicaccountcount;

        //分配公海已分配的客户，判断被分配人的公海已分配客户数量是否达上限
        //是否启用公海参数
        if ($obj->public_account['status'] == 'yes' && $publicaccount > 1) {
            $sql = "select ld_leads.accountname from ld_leads
                          where ld_leads.smownerid=? and ld_leads.deleted=0 and ld_leads.publicaccount>1 and pool_id = ?";
            $result = $adb->pquery($sql, array($obj->getUserId(),$pool_id));
            $have_allocate = $adb->num_rows($result);
    
    
            if ($count == '') {
                $count = 0;
            }
    
            if ($count <= $have_allocate) {
                //公海已分配   移动端和PC端详情页分配可以直接提示(因为只有一条单据)，PC端列表分配要修改成错误弹窗信息，需要一直往下分配。
                if ($_REQUEST['mode'] == 'detail') {
                    $obj->setReturnStyleInDetail();  //editor:gyq reason:返回值不同
                }else{
                    return -1;//公海已分配超出上限错误提示
                }
                //$edit_err .= sprintf($batreachmax, '<a href="index.php?module=' . $module . '&action=DetailView&record=' . $recordid . '"  target="_black" >' . $subject[$recordid]['subject'] . '</a>', $batchtype, getUserFullName($_REQUEST['caterorid'])) . '<br>';
    
            }
        }

        //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（线索分配）
        if ($publicaccount == 0) {//普通销售线索
            $limit_count = $this->getCommonAccountLimitCount($obj->getUserId());
            if($limit_count<9999999999)
            {
                $haved_count = $this->getSmowerNumForCommonAccount($obj->getUserId());
                if ($limit_count <= $haved_count) {
                    //历史原因没办法，只能兼容。PC详情页、PC列表页、移动端，返回值格式风格迥异。
                    global $weixin_user;
                    if(!empty($weixin_user)){
                        if ($obj->public_account['status'] == 'yes')
                            ConvertTojsonString(-1,array(),getFixedLabel('ALLOCATERREACHMAXLeadsAppError1'));//被分配人普通销售线索数量已达上限!
                        else
                            ConvertTojsonString(-1,array(),getFixedLabel('ALLOCATERREACHMAXLeadsAppError'));
                    }elseif ($_REQUEST['mode'] == 'detail'){
                        echo $obj->public_account['status'] == 'yes'?'###ALLOCATERREACHMAXLeadsJSError1###':'###ALLOCATERREACHMAXLeadsJSError###';//PC详情页返回
                        exit();
                    }else{
                        return -2;//普通销售线索超出上限错误提示 列表页
                    }
                }
            }
        }
        
        return $pool_id;
        
    }
    
    
    /**
     * edit:kevin
     * date:2013-07-22
     * reason:是否启用公海
     * $type:0 保存,1 编辑,2 删除,3 还原
     */
    function updateAccountInfo($module,$accountid='',$type=0,$record=''){
        global $adb,$default_charset;
		crm_load_class_file('cls_PublicLeads', 'modules/Leads');
		$cls_PublicAccounts = new cls_PublicLeads($this->module_name);
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
            if(!$focus->fieldobj->getFieldInfoobjBykey('fieldname','leads_id'))
            {
                return false;//如果单据没有客户
            }
        }
      
        if(!empty($accountid))
        {
            $sql='select ld_leads.leadsid,ld_leads.allocatedate,ld_leads.publicaccount,protectdate
            ,ld_leads.createdtime,ld_leads.distributiondate,pool_id from ld_leads where leadsid =? ';
            $result=$adb->pquery($sql,array($accountid));
            $accountid=$adb->query_result($result,0,0);
            $allocatedate=$adb->query_result($result,0,'allocatedate');
            $publicaccount=$adb->query_result($result,0,'publicaccount');
            $createdtime=$adb->query_result($result,0,'createdtime');
            $distributiondate=$adb->query_result($result,0,'distributiondate');
            $protectdate=$adb->query_result($result,0,'protectdate');
			$pool_id=$adb->query_result($result,0,'pool_id');
            
        }
        else
            
        {
            $sql = 'select ld_leads.leadsid,ld_leads.allocatedate,ld_leads.publicaccount,ld_leads.createdtime
                        ,ld_leads.distributiondate,protectdate,pool_id from  ' . $focus->table_name;
            if ($module != 'Leads') {
                if($module == 'Singin'){
                    $sql .= ' inner join ld_leads on ld_leads.leadsid=' . $focus->table_name . '.source_list ';
                }else{
                    $sql .= ' inner join ld_leads on ld_leads.leadsid=' . $focus->table_name . '.leads_id ';
                }
            }
            $sql .= ' where ' . $focus->table_index . ' = ? ';
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
                $sql='update ld_leads set protectdate="",completed="" where leadsid=?';
            }else{
                $sql='update ld_leads set protectdate="",completed="已完成" where leadsid=?';
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
        $sql="select ld_leads.$timecolumnname,createdtime from ld_leads where leadsid=?";
        $result=$adb->pquery($sql,array($accountid));
        if($adb->num_rows($result)>0)
        {

            $timecolumnnamevalue=$adb->query_result($result,0,$timecolumnname);
            if($timecolumnnamevalue==''||date("Y-m-d",strtotime($timecolumnnamevalue))<='1600-01-01'){
                $timecolumnname = 'createdtime';
                $timecolumnnamevalue=$adb->query_result($result,0,'createdtime');
            }

        }

        $min_day = -1;
        $task_complete = 'yes';

        foreach ($all_program_arr as $tmpinfo) {
            $recycleselect = $tmpinfo['recycleselect'];
            if (!empty($recycleselect)) {
                $recycleselect_sql = $recycleselect . ' and ld_leads.leadsid = ?';
                $seletc_result = $adb->pquery(html_entity_decode($recycleselect_sql, ENT_QUOTES, $default_charset), [$accountid]);
                if ($adb->num_rows($seletc_result) == 0) {
                    continue;
                }
            }

            $tmpdates = [];
            $ruleinfo = $tmpinfo['rule_arr'];
            $tmpdays = 0;
            $tmpdates = array();

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
                if ($content['condition'] == 'and') {

                    if ($content['tabname'] == 'Singin') {
                        $tmptablename = 'ld_singin';

                        $sql = " select  ld_leads.leadsid,ld_leads.$timecolumnname,$othermoduledatecolumname from ld_leads 
                                     inner  join $tmptablename on $tmptablename.record=ld_leads.leadsid and DATE_FORMAT($tmptablename.createdtime,'%Y-%m-%d') >= ld_leads.allocatedate 
                                       and $tmptablename.record = ? and  $tmptablename.deleted=0 ";
                        $sql .= " and ld_leads.smownerid=$tmptablename.userid ";
                    } else {


                        $tmptableindex = $tmpfocus->table_index;


                        $sql = " select  ld_leads.leadsid,ld_leads.$timecolumnname,$othermoduledatecolumname from ld_leads 
                                     inner  join $tmptablename on $tmptablename.leads_id=ld_leads.leadsid and DATE_FORMAT($tmptablename.createdtime,'%Y-%m-%d') >= ld_leads.allocatedate 
                                       and $tmptablename.leads_id = ? and  $tmptablename.deleted=0 ";
                        $sql .= " and ld_leads.smownerid=$tmptablename.smownerid ";

                    }
                    if ($iscycle == 'yes')
                        $sql .= "   where ld_leads.leadsid=?   group by ld_leads.leadsid having   datediff( curdate(),max($tmptablename.$columnname))<=$days  and max($tmptablename.$columnname)>ld_leads.$timecolumnname  ";
                    else
                        $sql .= "   where ld_leads.leadsid=?   group by ld_leads.leadsid having   datediff(min($tmptablename.$columnname), ld_leads.$timecolumnname)<=$days  and datediff(min($tmptablename.$columnname), ld_leads.$timecolumnname)>=0    ";


                    $result = $adb->pquery($sql, array($accountid,$accountid));

                    if ($adb->num_rows($result) > 0) {
                        $columnnamedate = $adb->query_result($result, 0, 'othermoduledate');

                        if ($iscycle == 'yes') {
                            $tmp_task_complete = 'no';
                        } else {
                            $tmp_task_complete = 'yes';
                        }
                        $tmpdates[] = array(
                            'startdate' => $columnnamedate,
                            'days' => $days,
                            'iscycle' => $iscycle,
                            'module' => $content['tabname']
                            ,
                            'enddate' => DateOperation::addDays($columnnamedate, $days),
                            'complete' => $tmp_task_complete
                        );

                    } else {
                        $tmp_task_complete = 'no';
                        $tmpdates[] = array(
                            'startdate' => $timecolumnnamevalue,
                            'days' => $days,
                            'iscycle' => $iscycle,
                            'module' => $content['tabname'],
                            'enddate' => DateOperation::addDays($timecolumnnamevalue, $days),
                            'complete' => $tmp_task_complete
                        );
                    }
                    $tmpcondidtion = $content['condition'];

                } else if ($content['condition'] == 'or') {

                    if ($content['tabname'] == 'Singin') {
                        $tmptablename = 'ld_singin';

                        $sql = " select ld_leads.leadsid,ld_leads.$timecolumnname,$othermoduledatecolumname from ld_leads inner join $tmptablename  $tmptablename on $tmptablename.record=ld_leads.leadsid and DATE_FORMAT($tmptablename.createdtime,'%Y-%m-%d') >= ld_leads.$timecolumnname   
							and $tmptablename.record = ? and  $tmptablename.deleted=0 ";
                        $sql .= " and ld_leads.smownerid=$tmptablename.userid ";
                    } else {
                        $tmpfocus = CRMEntity::getInstance($content['tabname']);
                        $tmptablename = $tmpfocus->table_name;
                        $tmptableindex = $tmpfocus->table_index;
                        $sql = " select ld_leads.leadsid,ld_leads.$timecolumnname,$othermoduledatecolumname  from ld_leads inner join $tmptablename  $tmptablename on $tmptablename.leads_id=ld_leads.leadsid and DATE_FORMAT($tmptablename.createdtime,'%Y-%m-%d') >= ld_leads.$timecolumnname 
							and $tmptablename.leads_id = ? and  $tmptablename.deleted=0 ";
                        $sql .= " and ld_leads.smownerid=$tmptablename.smownerid ";
                    }


                    if ($iscycle == 'yes')
                        $sql .= "   where ld_leads.leadsid=?  
                                 group by ld_leads.leadsid having  datediff( curdate(),max($tmptablename.$columnname))<=$days  and max($tmptablename.$columnname)>ld_leads.$timecolumnname  ";
                    else
                        $sql .= "   where ld_leads.leadsid=?  having   datediff($tmptablename.$columnname, ld_leads.$timecolumnname)<=$days and datediff($tmptablename.$columnname, ld_leads.$timecolumnname)>=0 order by othermoduledate limit 1  ";
                    //   $sql.=" and datediff($tmptablename.$columnname,ld_leads.$timecolumnname)<=$days ";

                    $result = $adb->pquery($sql, array($accountid,$accountid));

                    if ($adb->num_rows($result) > 0) {
                        if ($iscycle == 'yes') {
                            $tmp_task_complete = 'no';
                        } else {
                            $tmp_task_complete = 'yes';
                        }
                        $columnnamedate = $adb->query_result($result, 0, 'othermoduledate');
                        $tmpdates[] = array('startdate' => $columnnamedate, 'days' => $days, 'iscycle' => $iscycle, 'module' => $content['tabname'], 'enddate' => DateOperation::addDays($columnnamedate, $days), 'complete' => $tmp_task_complete);

                    } else {
                        $tmp_task_complete = 'no';
                        $tmpdates[] = array('startdate' => $timecolumnnamevalue, 'days' => $days, 'iscycle' => $iscycle, 'module' => $content['tabname'], 'enddate' => DateOperation::addDays($timecolumnnamevalue, $days), 'complete' => $tmp_task_complete);
                    }
                }


            }

            if ($content['condition'] == 'and') {
                $arr = array('enddate' => '3000-01-01');
                //且，获取最小值
                $tmp_all_complete = 'yes';
                foreach ($tmpdates as $dateinfo) {
                    //且条件中存在一个任务没完成就视为没完成
                    if ($dateinfo['complete'] == 'no')
                        $tmp_all_complete = 'no';
                    if ($dateinfo['enddate'] < $arr['enddate']) {
                        //<一定是小于，因为在创建时间相等的情况下，则取最小的的天数
                        $arr = $dateinfo;

                    }
                }
                if ($tmp_all_complete == 'no')
                    $task_complete = 'no';
            } else {
                //获取最大值
                $arr = array('enddate' => '1600-01-01');
                $tmp_all_complete = 'no';
                foreach ($tmpdates as $dateinfo) {
                    //或条件中存在一个任务完成就视为没完成
                    if ($dateinfo['complete'] == 'yes')
                        $tmp_all_complete = 'yes';

                    if ($dateinfo['enddate'] >= $arr['enddate']) {
                        //>=一定是大于等于，因为在创建时间相等的情况下，则取最大的天数
                        $arr = $dateinfo;
                    }
                }
                if ($tmp_all_complete == 'no')
                    $task_complete = 'no';
            }

            if ($task_complete == 'yes')
                continue;

            if ($arr['startdate'] != '1600-01-01' && $arr['startdate'] != '2070-01-01') {
                $tmpdays = $arr['days'];
                $iscycle = $arr['iscycle'];
                $tmpmodule = $arr['module'];
                //存在多个回收方案时,取最小的时间计算保护结束日期
                if ($min_day == -1 || $min_day > $tmpdays) {
                    $result_arr = $arr;
                    $min_day = $tmpdays;
                }

            }
        }

        if ($task_complete == 'yes') {
            $sql = 'update ld_leads set protectdate="",completed="已完成" where leadsid=?';
            $adb->pquery($sql, array($accountid));
        } else {
            if ($tmpdays > 0) {
                //（1.6登录）公海已分配序时簿列表界面：设置公海客户回收条件保存后，在分配或领用之日起完成公海目标后，公海目标字段值没有显示“达成”（需要补丁）
                $startdate = $result_arr['startdate'];
                $enddate = $result_arr['enddate'];
                $sql = 'update ld_leads set protectdate="' . $enddate . '",completed="未完成" where leadsid=?';

                $adb->pquery($sql, array($accountid));
            } else {
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

    //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块(线索)
    //普通销售线索数量上限
    public function getCommonAccountLimitCount($userid=''){
        global $adb,$current_user;
        if (empty($userid)) {
            $userid = $current_user->id;
        }
        crm_load_class_file('cls_PublicLeads', 'modules/Leads');
        $cls_PublicAccounts = new cls_PublicLeads($this->moduleName);
        $public_account = $cls_PublicAccounts->getPublicAccount();
        $limit_type = $public_account['limit_type'];
        if ($limit_type == 'user') {
            $limit_count = $public_account['limit_count'];//按用户上限
        } else if ($limit_type == 'role'){
            require_once globalStatic::$root_directory.'include/utils/UserInfoUtil.php';
            $roleid = getUserRoleId($userid);
            $sql = 'SELECT limit_count FROM ld_leads_role_limitcount_common WHERE roleid=? limit 1;';

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
        return $limit_count;
    }
    //获取负责人已有的普通销售线索数量
    public function getSmowerNumForCommonAccount($userid=''){
        global $adb,$current_user;
        if (empty($userid)) {
            $userid = $current_user->id;
        }
        $query = "select count(1) as num from ld_leads where smownerid = ? and deleted = 0 and publicaccount = 0 and pool_id = 0";
        $result = $adb->pquery($query,array($userid));
        return $adb->query_result($result,0,'num');
    }
    //公海已分配销售线索数量上限
    public function getPublicAccountLimitCount($userid,$pool_id){
        global $adb,$current_user,$static_user_limit_count_common_arr;
        if (empty($userid)) {
            $userid = $current_user->id;
        }
        if(is_array($static_user_limit_count_common_arr))
        {
            if(array_key_exists($userid.'aa',$static_user_limit_count_common_arr))
                return $static_user_limit_count_common_arr[$userid.'aa'];
        }
        else{
            $static_user_limit_count_common_arr=[];
        }

        crm_load_class_file('cls_PublicLeads', 'modules/Leads');
        $cls_PublicAccounts = new cls_PublicLeads($this->moduleName);
        $public_account = $cls_PublicAccounts->getPublicAccountConfig();

        if ($public_account['status'] == 'yes') {
            //公海已分配客户数量上限
            $limit_type = $public_account['public_account_pool'][$pool_id]['limit_type'];
            if ($limit_type == 'user') {
                $limit_count = $public_account['public_account_pool'][$pool_id]['limit_count'];//按用户上限
            } else if ($limit_type == 'role') {
                crm_load_function_file('getUserRoleId', 'include/utils', 'UserInfoUtil');
                $roleid = getUserRoleId($userid);
                $sql = 'SELECT limit_count FROM ld_leads_role_limitcount WHERE roleid=? and pool_id = ? limit 1;';

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
        $static_user_limit_count_common_arr[$userid.'aa']=$limit_count;
        return $limit_count;
    }
    //获取负责人已有的公海已分配销售线索数量
    public function getSmowerNumForPublicAccount($userid,$pool_id){
        global $adb,$current_user;
        if (empty($userid)) {
            $userid = $current_user->id;
        }
        $query = "select count(1) as num from ld_leads where smownerid = ? and publicaccount>1 and deleted = 0  and pool_id = ?";
        $result = $adb->pquery($query,array($userid,$pool_id));
        $num = $adb->query_result($result,0,'num');
        if ($num == '') $num = 0;
        return $num;
    }

    function getDuplicatesQuery($module,$table_cols,$field_values,$ui_type_arr,$select_cols='') {
        $select_clause = "SELECT ". $this->table_name .".".$this->table_index ." as recordid, ".$table_cols;

        if (isset($select_cols) && trim($select_cols) != ''){
            $tmpselectcols = trim($select_cols,',');
            $tmpselectcolarr = explode(',',$tmpselectcols);
            $table_colarr = explode(',',$table_cols);
            $select_colarr = array();
            //链接字段
            $fieldinfo=$this->fieldobj->getFieldInfoobjBykey("fieldname",$this->list_link_field);
            if(!empty($fieldinfo)){
                $select_colarr[] = $fieldinfo->getTableName().'.'.$fieldinfo->getColumnName()." as entityname ";
            }
            if($this->table_code != $this->list_link_field){
                $select_colarr[] = $this->table_name .".".$this->table_code." as billno ";//编号字段
            }
            foreach ($tmpselectcolarr as $tmpselectcol){
                $tmparr = explode('.',(string)$tmpselectcol);
                if(sizeof($tmparr)<2||in_array($tmpselectcol , $table_colarr)){
                    continue;
                }
                $tmptablename = $tmparr[0];
                if(in_array($tmptablename,$this->tab_name)&&!in_array($tmpselectcol,$select_colarr)){
                    $select_colarr[] = $tmpselectcol;
                }
            }
            if(is_array($select_colarr) && sizeof($select_colarr)>0){
                $select_clause .= ','.implode(',',$select_colarr);
            }
        }
        else{
            if(isset($this->customFieldTable)) $select_clause .= ", " . $this->customFieldTable[0] . ".* ";
        }
        $from_clause = " FROM $this->table_name";
        $from_clause .= "	INNER JOIN ld_crmentity ON ld_crmentity.crmid = $this->table_name.$this->table_index";
        // Consider custom table join as well.
        if(isset($this->customFieldTable)) {
            $from_clause .= " INNER JOIN ".$this->customFieldTable[0]." ON ".$this->customFieldTable[0].'.'.$this->customFieldTable[1] .
                " = $this->table_name.$this->table_index";
        }
        $from_clause .= " LEFT JOIN ld_users ON ld_users.id = $this->table_name.".$this->getSmownerColumName().' ';
        $where_notnull_sql = '';
        $column_arr = explode(',',$table_cols);
        foreach ($column_arr as $key=>$value){
            $where_notnull_sql .= $value.'<>\'\' and ';
        }
        $where_clause = "	WHERE ".$where_notnull_sql."  $this->table_name.deleted = 0";
        $where_clause .= $this->getListViewSecurityParameter($module);

        $sub_query = "SELECT $table_cols $from_clause $where_clause GROUP BY $table_cols HAVING COUNT(*)>1";
        $query = $select_clause . $from_clause .
            " INNER JOIN (" . $sub_query . ") AS temp ON ".get_on_clause($field_values,$ui_type_arr,$module) .
            $where_clause .
            " ORDER BY $table_cols,". $this->table_name .".".$this->table_index ." ASC";


        //dump($query);
        return $query;
    }
    function getListViewSecurityParameter($module) {
        global $current_user,$adb;
        $ScopOfAuthority = ScopOfAuthority::getInstance($adb,$module);
        return $ScopOfAuthority->getModuleListViewQuery();
    }
}
?>