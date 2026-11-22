<?php



class CustomForm92 extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['CustomForm92']='CustomForm92';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='CustomForm92';
	var $table_name = "ld_customform92";
	var $table_index= 'customform92id';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_customform92','ld_customform92scf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform92'=>'customform92id','ld_customform92scf'=>'customform92id',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform92scf', 'customform92id');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','customform92'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='customform92_no';
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
        $this->fieldobj=Field::getInstance('CustomForm92',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm92');
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
		//东贸： 业绩查询结果通知:佣金记录（CustomForm92）审批通过后，将当前佣金金额信息推送给大巴车司机
        // 商贸批发小程序
		if($version_info['account'] == 'dongmao'&&$version_info['trade'] == 'dongmao'){
			$query = "select servicecharge_id,customform92_no,createdtime,car_amount,totaluser_qty,user_amount,newuser_qty,newuser_amount,total from ld_customform92 
			LEFT JOIN ld_customform92scf on ld_customform92.customform92id = ld_customform92scf.customform92id 
			where deleted = 0 and ld_customform92.customform92id = ?";
			$result = $adb->pquery($query,array($crmid));
			$accountid = $adb->query_result($result,0,'servicecharge_id');
			$customform92_no = $adb->query_result($result,0,'customform92_no');
			$createdtime = $adb->query_result($result,0,'createdtime');
			$car_amount = $adb->query_result($result,0,'car_amount');	//车辆补贴
			$totaluser_qty = $adb->query_result($result,0,'totaluser_qty');	//实际到达人数
			$user_amount = $adb->query_result($result,0,'user_amount');	//总人员补贴
			$newuser_qty = $adb->query_result($result,0,'newuser_qty');	//新人人数
			$newuser_amount = $adb->query_result($result,0,'newuser_amount');	//总新人补贴
			$total = $adb->query_result($result,0,'total');	//总佣金
			$commission = [];
			if(!empty($car_amount) && $car_amount > 0){
				$commission[] = "车辆补贴".$car_amount."";
			}
			if(!empty($totaluser_qty) && $totaluser_qty > 0){
				$commission[] = "实际到达人数".$totaluser_qty."";
			}
			if(!empty($user_amount) && $user_amount > 0){
				$commission[] = "人员补贴".$user_amount."";
			}
			if(!empty($newuser_qty) && $newuser_qty > 0){
				$commission[] = "新人人数".$newuser_qty."";
			}
			if(!empty($newuser_amount) && $newuser_amount > 0){
				$commission[] = "新人补贴".$newuser_amount."";
			}
			if(!empty($total) && $newuser_amount > 0){
				$commission[] = "总佣金".$total."";
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
					$dmMsgData = cls_DMmessageDefault::$DMmessageData['Payment'];
					$dmMsgPage = cls_DMmessageDefault::$DMmessageJump['Payment'];
					// 兰总:oslAm0mRG-6xUXoeBJ7Xx23Tw7HI;王总:oslAm0ptw4yIccjwf1Ba920DXQ8E;邱小光:oslAm0pdy-Da_vZxBvL9oY90IpYI
                    // 兰总:177594;王总:178611;邱小光:121653
                    $open_id = 'oslAm0ptw4yIccjwf1Ba920DXQ8E';
	                $wechatuserid = 178611;
					$title = $dmMsgData['title'];
					$title = str_replace('单据编号',$customform92_no,$title);
					$data = array(
						'title' => $title,	
						'time' => date('Y年m月d日',strtotime($createdtime)),
						'commission' => implode('，',$commission),
						'remark' => $dmMsgData['remark']
					);
					$dongmaoObj->send('Payment',$open_id,$dmMsgPage['page'],$data,$wechatuserid,'CustomForm92',$crmid,$dmMsgPage['pageType'],$accountid);
				}
			}
		}
		
	}
 

}
CustomForm92::require_file();
?>