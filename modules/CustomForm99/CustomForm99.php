<?php



class CustomForm99 extends CRMEntity {
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['CustomForm99']='CustomForm99';
         
            
           
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }

    }
    
	var $log;
	var $db;
    var $module_name='CustomForm99';
	var $table_name = "ld_customform99";
	var $table_index= 'customform99id';
	//'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
	//'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
	//'ld_customerdetails'=>'customerid'
	var $tab_name = Array('ld_crmentity','ld_customform99','ld_customform99scf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_customform99'=>'customform99id','ld_customform99scf'=>'customform99id',);
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_customform99scf', 'customform99id');

	var $column_fields = Array();
    
	var $sortby_fields = Array('lastname','firstname','title','email','phone','smownerid','accountname');

	var $list_link_field= 'lastname';
    var $relatedtab=array('accounts'=>'','customform99'=>'','users'=>'','company'=>'','vendors'=>'');


    var $table_code='customform99_no';
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
        $this->fieldobj=Field::getInstance('CustomForm99',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm99');
        $this->list_link_field=$entityname['fieldname'];
	}


	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	   global $adb;
		$version_info = getVersionInfo();
		//东贸特殊处理：客户档案适用范围
		if($version_info['account'] == 'dongmao' && !empty($this->id)){
			$modulefields = $this->fieldobj->getModuleFields();
			foreach($modulefields as $fieldname => $field){
				$uitype = $field->getUIType();
				if($uitype == 303){
					if(!empty($_REQUEST[$fieldname.'_advft_criteria']) && !empty($_REQUEST[$fieldname.'_advft_criteria_groups'])){
						$update = 'update ld_customform99 set advft_criteria = ?,advft_criteria_groups = ? where customform99id = ?';
						$adb->pquery($update,array($_REQUEST[$fieldname.'_advft_criteria'],$_REQUEST[$fieldname.'_advft_criteria_groups'],$this->id));
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

	//东贸特殊开发：活动配置相关信息选择活动记录时，更改为选择客户档案，并且自动生成活动记录
	function createCustomform99($record,$storearray){
		global $adb;
		if(!empty($storearray) && !empty($record)){
			$account_for_contactid = [];
			$query = 'select contactid,accountid from ld_contactdetails where accountid in ('.implode(',',$storearray).') and deleted = 0 and reference = 1';
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					$accountid = $adb->query_result($result,$i,'accountid');
					$contactid = $adb->query_result($result,$i,'contactid');
					$account_for_contactid[$accountid] = $contactid;
				}
			}
			
			foreach($storearray as $acc_id){
				$focus = CRMEntity::getInstance('CustomForm98');
				$query = 'select customform98id from ld_customform98 where customform99_id = ? and servicecharge_id = ? and deleted = 0 limit 1';
				$result = $adb->pquery($query,array($record,$acc_id));
				$num_rows = $adb->num_rows($result);
				$focus->record = 0;
				$focus->mode = 'create';
				if($num_rows >= 1){
					$customform98id = $adb->query_result($result,0,0);
					$focus->mode = 'edit';
					$focus->retrieve_entity_info($customform98id,'CustomForm03');
					$focus->record = $customform98id;
				}
                
				$focus->column_fields['customform99_id'] = $record;
				$focus->column_fields['servicecharge_id'] = $acc_id;
				$focus->column_fields['contact_id'] = $account_for_contactid[$acc_id];
				$focus->column_fields['assigned_user_id'] = 1;
                
                //edit:duan 东贸-增加客户信息引用字段的值（客户认证状态）
                $sql = "SELECT ld_field.columnname,ld_related_field.fromvalue_info
                        FROM ld_related_field INNER JOIN ld_field ON ld_field.fieldid = ld_related_field.effect_fieldid
                        WHERE ld_field.tabid = ? and ld_related_field.fromvalue_type = 'column' and ld_field.presence in (0,2)
                        and ld_related_field.frommodule = ?";
                $result = $adb->pquery($sql,array(246,'ServiceCharge'));
                $num_rows = $adb->num_rows($result);
                if($num_rows>0){
                    //获取关联客户档案信息
                    $servicecharge_sql = 'select * from ld_account inner join ld_accountscf 
                                on ld_account.accountid = ld_accountscf.accountid where ld_account.accountid = ?';
                    $servicecharge_result = $adb->pquery($servicecharge_sql,array($acc_id));
                    
                    for($i = 0;$i<$num_rows;$i++){
                        $fromvalue_info = $adb->query_result($result,$i,'fromvalue_info');//追踪字段名称
                        $effect_columnname = $adb->query_result($result,$i,'columnname');//关联字段名称
                        //设置关联字段值
                        $focus->column_fields[$effect_columnname] = $adb->query_result($servicecharge_result,0,$fromvalue_info);
                    }
                }
                
                
				$focus->save('CustomForm98');
			}
		}

	}

}
CustomForm99::require_file();
?>