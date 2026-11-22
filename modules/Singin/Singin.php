<?php



class Singin extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['Singin']='Singin';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='Singin';
	var $table_name = "ld_singin";
	var $table_index= 'signid';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_singin','ld_singinscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_singin'=>'signid','ld_singinscf'=>'signid',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_singinscf', 'signid');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','singin'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='';
	var $search_fields = Array(
	'Name' => Array('contactdetails'=>'lastname'),
	'Title' => Array('contactdetails'=>'title'),
	'Account Name'=>Array('contactdetails'=>'account_id'),
	'Assigned To'=>Array('crmentity'=>'smownerid'),
		);

	var $search_fields_name = Array(
	'Name' => 'lastname',
	'Title' => 'title',
	'Account Name'=>'account_id',
	'Assigned To'=>'assigned_user_id'
	);

	// This is the list of lingdang_fields that are required
	var $required_fields =  array("lastname"=>1);

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
	var $mandatory_fields = Array('assigned_user_id','createdtime' ,'modifiedtime');

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('firstname','lastname','salutation','title','email','department','phone','mobile','support_start_date','support_end_date');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'lastname';
	var $default_sort_order = 'ASC';

	// For Alphabetical search
	var $def_basicsearch_col = 'lastname';

	function __construct() {
	
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('Singin',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('Singin');
        $this->list_link_field=$entityname['fieldname'];
	}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	   
        global $current_user,$adb,$PlatformMC;
        $signdata=$_REQUEST['signData'];
        $longtitude=$signdata['longitude'];//+$littlelong;
        $longtitude=is_numeric($longtitude)?$longtitude:null;
        $latitude=$signdata['latitude'];//+$littlelati;
        $latitude=is_numeric($latitude)?$latitude:null;
        $uuid=$signdata['uuid'];
        $signway=$signdata['signway'];
        $record=$this->column_fields['selectlistval'];
        $module = $this->column_fields['entitytype'];
        $signaddress = $signdata['address'];
        if(empty($module)){
            $module = getSalesEntityType($record);
        }
        $distance=$signdata['distance'];
        $tabid = getTabid($module);
        
        if(!empty($record)) {
            if ($module == 'Accounts') {
                $sql = "select longtitude,latitude from ld_account where accountid=?";
                $result = $adb->pquery($sql, array($record));
                $accounts_lng = $adb->query_result($result, 0, 'longtitude');
                $accounts_lat = $adb->query_result($result, 0, 'latitude');
                $accounts_lng = is_numeric($accounts_lng) ? $accounts_lng : null;
                $accounts_lat = is_numeric($accounts_lat) ? $accounts_lat : null;
            }
            //editor:gyq_81 reason:签到考勤优化 2018/10/09 16:23
            //crm_load_class_file('cls_ParentRelatedField_Data', 'include/RelatedField');
            //$cls_ParentRelatedFields = new cls_ParentRelatedField_Data('Singin', $record, '');
            //$relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');
            //$data_address = $relatedfielddata[0]['rawValue']['value'];
            $data_address = $signdata['sysaddress'];
            $entityarray = getEntitynameInfo(getTabid($module));
            $tabname = $entityarray['tablename'];
            $tabindex = $entityarray['entityidfield'];
            $tabfieldname = $entityarray['fieldname'];
            $query = 'select ' . $tabindex . ',' . $tabfieldname . ' as subject from ' . $tabname . ' where ' . $tabindex . ' in (' . $record . ') limit 1';
            $result = $adb->pquery($query);
            $subject = $adb->query_result($result, 0, 'subject');
        }
        //editor:gyq_20190412 0036579: CRM小程序：拜访签到保存后，【signway】字段跟企业微信保存后值是一样，建议区分开来。
        if($PlatformMC['type_mini']){
            //editor:gyq_20190412 0036567: 小程序-考勤签到-常用报表-签到考勤表不显示手机设备号。
            $sql = 'select wx_openid from ld_users where id=?';
            $result = $adb->pquery($sql,array($current_user->id));
            $uuid = $adb->query_result($result,0,'wx_openid');
        }
        
        $sql='update ld_singin set longtitude = ?,latitude = ?,userid=smcreatorid,record=source_list,tabid=?,uuid=?,
                accounts_lng=?,accounts_lat=?,distince=?,signway=?,entityname=?,entityaddress=?,address=?,signin_address=?,from_module=? where signid = ?';
        $adb->pquery($sql,array($longtitude,$latitude,$tabid,$uuid,$accounts_lng,$accounts_lat,$distance,$signway,$subject,$data_address,$signaddress,$signaddress,$this->module_name,$this->id));
        
        //editor:gyq_20190124 0036089: 企业微信端/微信小程序：签到时，也应该更新客户经纬度
        if($module == 'Accounts' && !empty($record)){
            //$update_sql = 'update ld_account set longtitude=?,latitude=?,location_address=? where accountid=?';
            //$result = $adb->pquery($update_sql,array($longtitude,$latitude,$data_address,$record));
            $update_sql2 = 'update ld_singin set accountid=? where signid=?';
            $result2 = $adb->pquery($update_sql2,array($record,$this->id));
            /*crm_load_class_file('Accounts','modules/Accounts');
            $account=new Accounts();
              //反写保护结束日期
            $account->updateAccountInfo($this->module_name,$record);*/
        }
		
		 $sql='update ld_singin set triggercount=triggercount+1 where signid = ?';
		 $adb->pquery($sql,array($this->id));
        
	}
	
	function restore($module, $id) {

		parent::restore($module,$id); 
	
   	}
   
	

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		
	}
    

}
Singin::require_file();
?>