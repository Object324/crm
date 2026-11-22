<?php



class CustomForm98 extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['CustomForm98']='CustomForm98';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='CustomForm98';
	var $table_name = "ld_customform98";
	var $table_index= 'customform98id';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_customform98','ld_customform98scf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform98'=>'customform98id','ld_customform98scf'=>'customform98id',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform98scf', 'customform98id');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','customform98'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='customform98_no';
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
        $this->fieldobj=Field::getInstance('CustomForm98',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm98');
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
		// 东贸特殊开发
		$version_info = getVersionInfo();
		if($version_info['account'] == 'dongmao' && !empty($crmid)){
			global $adb;
			$query = 'select ld_customform98.car_no,ticket_type,start_date,end_date,activity_type,minus_scope,amount,ld_customform98.description,ld_customform98.contactid,ld_customform98.servicecharge_id,duration_setting from ld_customform98 
			LEFT JOIN ld_customform99 on ld_customform99.customform99id = ld_customform98.customform99_id 
			where customform98id  = ?';
			$result = $adb->pquery($query,array($crmid));
			$car_no = $adb->query_result($result,0,'car_no');	//车牌号
			$ticket_type = $adb->query_result($result,0,'ticket_type');	//停车券类型
			$activity_type = $adb->query_result($result,0,'activity_type');	//活动类型
			$minus_scope = $adb->query_result($result,0,'minus_scope');	//满减配置
			$amount = $adb->query_result($result,0,'amount');	//消费金额
			$description = $adb->query_result($result,0,'description');	//活动记录备注
			$contactid = $adb->query_result($result,0,'contactid');	//申请联系人
			$servicecharge_id = $adb->query_result($result,0,'servicecharge_id');	//客户名称
			$duration_setting = $adb->query_result($result,0,'duration_setting');	//客户名称

			if($ticket_type == '关联小票'){
				$duration_arr = ldcrm_json_decode($duration_setting);
				$shichang = 0;
				$string = '';
				foreach($duration_arr as $duration_str){
					$dur_arr = explode(',',$duration_str);
					if($dur_arr[0] < $amount && $amount <= $dur_arr[1]){
						$shichang = $dur_arr[2];
						$string = "当前消费【".$amount."】，满足规则【大于".$dur_arr[0]."小于".$dur_arr[1]."】，减少时长【".$shichang."】";
							break;
					}
				}
				if($shichang > 0){
					if(!empty($string)){
						if(!empty($description)){
							$string = $string . PHP_EOL . $description;
						}
						$update = 'update ld_customform98 set description = ? where customform98id = ?';
						$adb->pquery($update,array($string,$crmid));
					}
					if(!empty($car_no)){
						$start_date = $adb->query_result($result,0,'start_date');	//活动开始时间
						$end_date = $adb->query_result($result,0,'end_date');	//活动结束时间
						// 东贸特殊开发，停车活动同步到德立云
						if($version_info['trade'] == 'dongmao'){
							crm_load_class_file('cls_Car','WeiXinApp/dongmao');	
							$cls_Car = new cls_Car();
							$res = $cls_Car->findParkInLog($car_no,$start_time,$end_time);
							if(!empty($res) && !empty($car_no)){
								$start_date = $res['inTime'];
								if(empty($start_date)){
									$start_date = date('Y-m-d H:i:s');
								}
								$time = strtotime($start_date) + $shichang *60 *60;
								$end_date = date('Y-m-d H:i:s',$time);
								$cls_Car->saveCar($car_no,$start_date,$end_date,'2');
							}
						}
					}
				}
			}
			if($activity_type == '满减活动' && !empty($minus_scope)){
				$minus_scope_arr = ldcrm_json_decode($minus_scope);
				$string = '';
				foreach($minus_scope_arr as $manjian_string){
					$manjians = explode(',',$manjian_string);
					if($amount > $manjians[0]){
						$string = "当前消费【".$amount."】，达到规则【满".$manjians[0]."减".$manjians[1]."】";
						break;
					}
					
				}
				if(strpos($description,$string) !==false){
				
				}else{
					if(!empty($string)){
						$string = $string . PHP_EOL . $description;
						$update = 'update ld_customform98 set description = ? where customform98id = ?';
						$adb->pquery($update,array($string,$crmid));
					}
				}
			}
			//活动类型为“满减活动”的单据审核时，根据消费金额同步增加积分数据到“积分”模块
			//活动类型为“路费报销”的单据审核时，根据消费金额同步增加积分数据到“积分”模块
			//活动类型为“积分活动”的单据审核时，根据消费金额同步增加积分数据到“积分”模块
			if($activity_type == '满减活动' || $activity_type == '路费报销' || $activity_type == '积分活动' || $activity_type == '其他'){
				$query = 'select customform94id from ld_customform94 where customform98id = ? and deleted = 0 limit 1';
				$result = $adb->pquery($query,array($crmid));
				$num_rows = $adb->num_rows($result);
				$focus = CRMEntity::getInstance('CustomForm94');
				$moduleFields=$focus->fieldobj->getModuleFields();
				if($num_rows >= 1){
					$customform94id = $adb->query_result($result,0,0);
					$focus->mode = 'edit';
					$focus->id = $customform94id;
					$focus->record = $customform94id;
					$focus->retrieve_entity_info($customform94id, 'CustomForm94');
				}
				$focus->operate_api = 'api';
                $focus->column_fields['creator'] = 1;
				$focus->column_fields['smcreatorid'] = 1;
				$focus->column_fields['assigned_user_id'] = 1;
				$focus->column_fields['contact_id'] = $contactid;
				$focus->column_fields['servicecharge_id'] = $servicecharge_id;
				$focus->column_fields['score_status'] = '订单';
				$focus->column_fields['score_type'] = '增加';
				$focus->column_fields['score_value'] = $amount;
				$focus->save('CustomForm94');
				if(!empty($focus->id)){
					$query = 'update ld_customform94 set customform98id = ?,approvestatus=? where customform94id = ?';
					$adb->pquery($query,array($crmid,'已批准',$focus->id));
				}
			}
		}
	}
 

}
CustomForm98::require_file();
?>