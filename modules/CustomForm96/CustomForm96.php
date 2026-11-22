<?php



class CustomForm96 extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['CustomForm96']='CustomForm96';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='CustomForm96';
	var $table_name = "ld_customform96";
	var $table_index= 'customform96id';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_customform96','ld_customform96scf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform96'=>'customform96id','ld_customform96scf'=>'customform96id',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform96scf', 'customform96id');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','customform96'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='customform96_no';
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
        $this->fieldobj=Field::getInstance('CustomForm96',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm96');
        $this->list_link_field=$entityname['fieldname'];
	}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
		global $adb;
		$version_info = getVersionInfo();
        // 商贸批发小程序
		if($version_info['account'] == 'dongmao'&&$version_info['trade'] == 'dongmao'){
			//东贸：优惠券配置》优惠券发放记录，增加【优惠券编码】字段，随机生成
			if(isset($this->column_fields['coupon_no']) && empty($this->column_fields['coupon_no']) && !empty($this->column_fields['customform97_id'])){
				$query = "select coupon_source,valid_days from ld_customform97 where customform97id = ?";
				$result = $adb->pquery($query,array($this->column_fields['customform97_id']));
				$coupon_source = $adb->query_result($result,0,'coupon_source');
				$valid_days = $adb->query_result($result,0,'valid_days');
				$cuspon_no = 'SH';
				if($coupon_source == '东贸'){
					$cuspon_no = 'DM';
				}
				//随机6位大写字母
				$str = array_merge(range('A','Z'));
				shuffle($str);
				$str = implode('',array_slice($str,0,6));
				$cuspon_no .= date('YmdHis') . $str;
				$update = "update ld_customform96 set coupon_no = ? where customform96id = ?";
				$adb->pquery($update,array($cuspon_no,$this->id));
				//优惠券信息-优惠券发放通知
				$query = "select 1 from ld_weixin_msg where modulename = ? and record = ?";
				$result = $adb->pquery($query,array($module,$this->id));
				$num_rows = $adb->num_rows($result);
				if(empty($num_rows) && empty($_REQUEST['dongmao_weixin'])){
					$query = "select unionid,wechatuserid from ld_wechatuser where accountid = ? and deleted = 0";
					$result = $adb->pquery($query,array($this->column_fields['account_id']));
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
						$dmMsgData = cls_DMmessageDefault::$DMmessageData['CouponIssuance'];
						$dmMsgPage = cls_DMmessageDefault::$DMmessageJump['CouponIssuance'];
						// 兰总:oslAm0mRG-6xUXoeBJ7Xx23Tw7HI;王总:oslAm0ptw4yIccjwf1Ba920DXQ8E;邱小光:oslAm0pdy-Da_vZxBvL9oY90IpYI
	                    // 兰总:177594;王总:178611;邱小光:121653
						// $open_id = 'oslAm0ptw4yIccjwf1Ba920DXQ8E';
	                	// $wechatuserid = 178611;
						$start = date('Y-m-d');
						$time = $start . ' ~ ' . date('Y-m-d', strtotime($start. ' + '.$valid_days.' days'));
						$data = array(
							'title' => $dmMsgData['title'],	
							'name' => $this->column_fields['cf_5089'],
							'time' => $start,
							'remark' => $dmMsgData['remark']
						);
						//print_r($data);die;
						$dongmaoObj->send('CouponIssuance',$open_id,$dmMsgPage['page'],$data,$wechatuserid,$module,$this->id,$dmMsgPage['pageType'],$this->column_fields['account_id']);
					}
				}
			}
		}
              
	}
	
	function restore($module, $id) {

		parent::restore($module,$id); 
	
   	}
   
	

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		
	}

	
 

}
CustomForm96::require_file();
?>