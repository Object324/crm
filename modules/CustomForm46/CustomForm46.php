<?php



class CustomForm46 extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['CustomForm46']='CustomForm46';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='CustomForm46';
	var $table_name = "ld_customform46";
	var $table_index= 'customform46id';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_customform46','ld_customform46scf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform46'=>'customform46id','ld_customform46scf'=>'customform46id',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform46scf', 'customform46id');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','customform46'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='customform46_no';
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
        $this->fieldobj=Field::getInstance('CustomForm46',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm46');
        $this->list_link_field=$entityname['fieldname'];
	}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	   
              
	}
	
	function restore($module, $id) {

		parent::restore($module,$id); 
	
   	}
   
	

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		
	}

	public function successApprove($crmid)
    {  
		global $adb;
		$version_info = getVersionInfo();
        // 商贸批发小程序
		if($version_info['account'] == 'dongmao'&&$version_info['trade'] == 'dongmao'){
			$query = "select ld_customform46.servicecharge_id,accountname,mobile,ld_customform46.approvetime,cf_5002 from ld_customform46 
			LEFT JOIN ld_customform46scf on ld_customform46.customform46id = ld_customform46scf.customform46id 
			LEFT JOIN ld_account on ld_account.accountid = ld_customform46.servicecharge_id 
			LEFT JOIN ld_contactdetails on ld_contactdetails.accountid = ld_account.accountid
			where ld_customform46.customform46id = ?";
			$result = $adb->pquery($query,array($crmid));
			$accountid = $adb->query_result($result,0,'servicecharge_id');
			$accountname = $adb->query_result($result,0,'accountname');
			$mobile = $adb->query_result($result,0,'mobile');
			$approvetime = $adb->query_result($result,0,'approvetime');
			$cf_5002 = $adb->query_result($result,0,'cf_5002');	//处理进度
			if(!empty($accountid)){
				$query = "select unionid,wechatuserid from ld_wechatuser where accountid = ? and deleted = 0";
				$result = $adb->pquery($query,array($accountid));
				$unionid = $adb->query_result($result,0,0);
				$query = "select open_id,wechatuserid from ld_wechatuser where unionid = ? and deleted = 0 and userfromvalue = 'offiaccount_dmgjsc'";
				$result = $adb->pquery($query,array($unionid));
				$num_rows = $adb->num_rows($result);
				if($num_rows >= 1){
					$open_id = $adb->query_result($result,0,'open_id');
					$wechatuserid = $adb->query_result($result,0,'wechatuserid');
					require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DongmaoMessage.php');
					require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DMmessageDefault.php');
					$dongmaoObj = new cls_DongmaoMessage();
					$dmMsgData = cls_DMmessageDefault::$DMmessageData['Complaint'];
					$dmMsgPage = cls_DMmessageDefault::$DMmessageJump['Complaint'];
					// 兰总:oslAm0mRG-6xUXoeBJ7Xx23Tw7HI;王总:oslAm0ptw4yIccjwf1Ba920DXQ8E;邱小光:oslAm0pdy-Da_vZxBvL9oY90IpYI
                    // 兰总:177594;王总:178611;邱小光:121653
					// $open_id = 'oslAm0ptw4yIccjwf1Ba920DXQ8E';
	                // $wechatuserid = 178611;
					$data = array(
						'title' => $dmMsgData['title'],	
						'accountname' => $accountname,
						'mobile' => $mobile,
						'time' => $approvetime,
						'status' => $cf_5002,
						'remark' => $dmMsgData['remark']
					);
					$dongmaoObj->send('Complaint',$open_id,$dmMsgPage['page'],$data,$wechatuserid,'CustomForm46',$crmid,$dmMsgPage['pageType'],$accountid);
				}
			}
		}
		
	}
 

}
CustomForm46::require_file();
?>