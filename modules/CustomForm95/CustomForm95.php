<?php



class CustomForm95 extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['CustomForm95']='CustomForm95';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='CustomForm95';
	var $table_name = "ld_customform95";
	var $table_index= 'customform95id';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_customform95','ld_customform95scf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform95'=>'customform95id','ld_customform95scf'=>'customform95id',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform95scf', 'customform95id');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','customform95'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='customform95_no';
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
        $this->fieldobj=Field::getInstance('CustomForm95',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm95');
        $this->list_link_field=$entityname['fieldname'];
	}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	   global $adb;
		$version_info = getVersionInfo();
		//东贸特殊处理：优惠券发放（应该是核销记录）记录，增加区块优惠信息，增加字段优惠详情。显示具体优惠信息
		if($version_info['account'] == 'dongmao' && !empty($this->id)){
			if(!empty($this->column_fields['customform96_id'])){
				$query = "select customform97_no,coupon_name,Amount,threshold_amount,coupon_type from ld_customform97 where customform97id = ?";
				$result = $adb->pquery($query,array($this->column_fields['customform97_id']));
				$customform97_no = $adb->query_result($result,0,'customform97_no');
				$coupon_name = $adb->query_result($result,0,'coupon_name');
				$amount = $adb->query_result($result,0,'amount');
				$threshold_amount = $adb->query_result($result,0,'threshold_amount');
				$coupon_type = $adb->query_result($result,0,'coupon_type');
				$cur_amount = $this->column_fields['amount'];	//核销记录当前消费金额
				if($coupon_type == '满减劵'){
					if($cur_amount > $threshold_amount)
						$description = '当前消费【'.$cur_amount.'元】，达到规则【满'.$threshold_amount.'减'.$amount.'元】';
					else
						$description = '当前消费【'.$cur_amount.'元】，没有达到规则【满'.$threshold_amount.'减'.$amount.'元】';
				}else if($coupon_type == '现金劵'){
					$description = '当前消费【'.$cur_amount.'元】，现金返还【'.$amount.'元】';
				}
				//duan 2022-3-7 东贸-优惠券核销时带出优惠券编码
				$update = "update ld_customform95 set description = ?,coupon_no = ? where customform95id = ?";
				$adb->pquery($update,array($description,$this->column_fields['coupon_no'],$this->id));		

				/*$query = "select customform96_no from ld_customform96 where customform96id = ?";
				$result = $adb->pquery($query,array($this->column_fields['customform96_id']));
				$customform96_no = $adb->query_result($result,0,'customform96_no');
				
				$description = '使用'.$customform97_no.' - '.$coupon_name.'，优惠券发放记录'.$customform96_no.'，消费'.$amount.'金额！';
				$update = "update ld_customform95 set description = ? where customform95id = ?";
				$adb->pquery($update,array($description,$this->id));	*/			
			}
			
			//东贸  优惠券核销保存的时候 发送服务消息
			include_once (globalStatic::$root_directory.'include/weixinMsg/cls_MiniProgramMessage.php');
		    $cls_MessageObj = new cls_MiniProgramMessage();
		    $sendmsg = $cls_MessageObj->MessageCommonObj->writeOffCoupon('CustomForm96',$this->column_fields['customform96_id']);//核销
		}
	}
	
	function restore($module, $id) {

		parent::restore($module,$id); 
	
   	}
   
	

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
	  	
		
	}

	
 

}
CustomForm95::require_file();
?>