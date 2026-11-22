<?php


class CustomForm181 extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['CustomForm181']='CustomForm181';
          
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_customform181';
    var $table_index='customform181id';
    var $table_code='customform181_no';
    var $tab_name=Array('ld_crmentity','ld_customform181','ld_customform181scf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_customform181'=>'customform181id','ld_customform181scf'=>'customform181id');
   	var $customFieldTable = Array('ld_customform181scf', 'customform181id');
	var $entity_table = "ld_crmentity";
    var $Detail_table="ld_customform181detail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_customform181detailscf";//明细自定义表
     var $Detail_table_index="id";//明细表和主表关联的字段名称
	var $column_fields = Array();
    var $module_name='CustomForm181';
    var $sortby_fields=Array('customform181_no');

    var $relatedtab=array('accounts'=>'','salesorder'=>'','users'=>'','company'=>'','cashbill'=>'','customform181'=>'');
            
    var $list_link_field= 'customform181_no';
   	var $search_fields_name = Array();
    var $required_fields =  array();


	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'customform181_no');
	var $default_order_by = 'customform181_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="customform181_no";
    
    var $detailfieldobj;
    function __construct()
    {
	  // $this->log =LoggerManager::getLogger('CustomForm181');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CustomForm181',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm181');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
    }
   
    function massEdit_save_before($module,$ids)
    {
        
            global  $adb;
            $becurrency_id=$this->column_fields['currency_id'];
            parent::massEdit_save_before($module,$ids);
            if(isset($_REQUEST['currency_id_mass_edit_check'])&&$becurrency_id!=$_REQUEST['currency_id_mass_edit_check'])
            {
                
                	$conversion_rate = $this->currencyobj->getCurrencyRate();
    				$currency_symbol = $this->currencyobj->getCurrencySymbol();
                    $becurrency_rate=$this->before_currencyobj->getCurrencyRate();
            		
                   if($becurrency_id == 1)
        			{
        				$query = "update ld_customform181 set total = total*?,subtotal = subtotal*? where customform181id = ?";
        				$adb->pquery($query,array($conversion_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_customform181detail set amount = amount/? where id = ?";
        				$adb->pquery($query2payment,array($conversion_rate,$this->id));
        			}
        			else
        			{
        				$query = "update ld_customform181 set total = total/?*?,subtotal = subtotal/?*? where customform181id = ?";
        				$adb->pquery($query,array($becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_customform181detail set amount = amount/?*? where id = ?";
        				$adb->pquery($query2payment,array($becurrency_rate,$conversion_rate,$this->id));
        			}
         }
    }
   	function save_module($module)
	{
        global $adb;
        $i=1;

      if($_REQUEST['action'] != 'CustomForm181Ajax' && $_REQUEST['ajaxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		  
        }
        else
        {

            return ;
        }
        

		if($this->currency_status === true)
		{
			$update_query = "update ld_customform181 set currency_id=?, conversion_rate=?,currency_symbol=? where customform181id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
         crm_load_class_file('cls_save_moduledetail','data');
         $obj=new cls_save_moduledetail($this->module_name,$this->id);
         
    
          $obj->Savedetail();
          
    }
    
    function getSourceField($fieldname,$recordid)
    {
        global $adb;
        return array();
        $sql = "select entitytype,entitytypeid from ld_customform181detail where lineitem_id = ?";
        
        $result = $adb->pquery($sql,array($recordid));
        return $adb->query_result($result,0,0);
    }
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts'||$return_module=="SalesOrder"||$return_module=="PaymentPlan"|| $return_module == 'ServiceContracts'  ) {
			$this->trash('CustomForm181',$id);
		} 
	}
    
   
    
  
    function getCustomForm181Field($fieldname,$recordid)
    {
        global $adb;
        $sql = "select $fieldname from ld_customform181 where customform181id = $recordid";
        $result = $adb->pquery($sql,array());
        return $adb->query_result($result,0,0);
    }
    
}
CustomForm181::require_file();
?>