<?php



class CustomForm48 extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['CustomForm48']='CustomForm48';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='CustomForm48';
	var $table_name = "ld_customform48";
	var $table_index= 'customform48id';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_customform48','ld_customform48scf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform48'=>'customform48id','ld_customform48scf'=>'customform48id',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform48scf', 'customform48id');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','customform48'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='customform48_no';
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
        $this->fieldobj=Field::getInstance('CustomForm48',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm48');
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
    	// 商贸批发小程序
        // 东贸特殊开发，信息备案单审批成功后，同步到德立云
        // 东贸特殊开发，微信公众号，信息备案单推送
        $version_info = getVersionInfo();
		if($version_info['trade'] == 'dongmao' && $version_info['account'] == 'dongmao' && !empty($crmid)){
			global $adb;
			$query = 'select cf_4664,cf_4940,cf_4649,accountname,ld_customform48.approvetime,servicecharge_id from ld_customform48 
			LEFT JOIN ld_customform48scf on ld_customform48scf.customform48id = ld_customform48.customform48id 
			LEFT JOIN ld_account on ld_account.accountid = ld_customform48.servicecharge_id 
			where ld_customform48.customform48id = ?';
			$result = $adb->pquery($query,array($crmid));
			$car_no = array('京AM8912');	//特殊车牌号不做同步处理
			$cf_4664 = $adb->query_result($result,0,'cf_4664');	//车牌号
			$cf_4940 = $adb->query_result($result,0,'cf_4940');	//预计离场时间
			$cf_4649 = $adb->query_result($result,0,'cf_4649');	//到达日期时间
			$accountname = $adb->query_result($result,0,'accountname');
			$approvetime = $adb->query_result($result,0,'approvetime');
			$accountid = $adb->query_result($result,0,'servicecharge_id');
			if(!in_array($cf_4664,$car_no)){
				crm_load_class_file('cls_Car','WeiXinApp/dongmao');	
				$cls_Car = new cls_Car();
				$starttime = date('Y-m-d') . ' 00:00:00';
				if(empty($cf_4940)){
					$endtime = date("Y-m-d 23:59:59",strtotime($cf_4649));
				}else{
					$endtime = date("Y-m-d 23:59:59",strtotime($cf_4940));
				}
				$cls_Car->saveCar($cf_4664,$starttime,$endtime,5);
			}
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
					$dmMsgData = cls_DMmessageDefault::$DMmessageData['Reporting'];
					$dmMsgPage = cls_DMmessageDefault::$DMmessageJump['Reporting'];
					// 兰总:oslAm0mRG-6xUXoeBJ7Xx23Tw7HI;王总:oslAm0ptw4yIccjwf1Ba920DXQ8E;邱小光:oslAm0pdy-Da_vZxBvL9oY90IpYI
                    // 兰总:177594;王总:178611;邱小光:121653
					// $open_id = 'oslAm0mRG-6xUXoeBJ7Xx23Tw7HI';
					// $wechatuserid = 177594;
					$data = array(
						'title' => $dmMsgData['title'],	
						'accountname' => $accountname,
						'time' => $approvetime,
						'remark' => $dmMsgData['remark']
					);
					$dongmaoObj->send('Reporting',$open_id,$dmMsgPage['page'],$data,$wechatuserid,'CustomForm48',$crmid,$dmMsgPage['pageType'],$accountid);
				}
			}
		}

        global $adb;
        //海格送货地址确认单审批成功后，报价单可用状态改为“可用”
        if($version_info['account']=='haige'){
            $haigeresult = $adb->pquery('select approvestatus,quoteid from '.$this->table_name. ' where '.$this->table_index.' = ?',array($crmid));
            $approvestatus = $adb->query_result($haigeresult,0,'approvestatus');
            
            if($version_info['account']=='haige' && $approvestatus==constant('D_A_S_APPROVED'))
            {
                $haigequoteid = $adb->query_result($haigeresult,0,'quoteid');
                //更新报价单使用状态为可用
                $adb->pquery("update ld_quotes set available_status = '可用' where quoteid = $haigequoteid");
            }
       	}
	}
}
CustomForm48::require_file();
?>