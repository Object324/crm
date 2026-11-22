<?php


class CustomForm25 extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['CustomForm25']='CustomForm25';
          
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_customform25';
    var $table_index='customform25id';
    var $table_code='customform25_no';
    var $tab_name=Array('ld_crmentity','ld_customform25','ld_customform25scf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_customform25'=>'customform25id','ld_customform25scf'=>'customform25id');
   	var $customFieldTable = Array('ld_customform25scf', 'customform25id');
	var $entity_table = "ld_crmentity";
    var $Detail_table="ld_customform25detail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_customform25detailscf";//明细自定义表
     var $Detail_table_index="id";//明细表和主表关联的字段名称
	var $column_fields = Array();
    var $module_name='CustomForm25';
    var $sortby_fields=Array('customform25_no');
    var $relatedtab=array('accounts'=>'','salesorder'=>'','users'=>'','company'=>'','cashbill'=>'','customform25'=>'');
            
    var $list_link_field= 'customform25_no';
   	var $search_fields_name = Array();
    var $required_fields =  array();

	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'customform25_no');
	var $default_order_by = 'customform25_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="customform25_no";
    
    var $detailfieldobj;
    function __construct()
    {
	  // $this->log =LoggerManager::getLogger('CustomForm25');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CustomForm25',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm25');
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
        				$query = "update ld_customform25 set total = total*?,subtotal = subtotal*? where customform25id = ?";
        				$adb->pquery($query,array($conversion_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_customform25detail set amount = amount/? where id = ?";
        				$adb->pquery($query2payment,array($conversion_rate,$this->id));
        			}
        			else
        			{
        				$query = "update ld_customform25 set total = total/?*?,subtotal = subtotal/?*? where customform25id = ?";
        				$adb->pquery($query,array($becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_customform25detail set amount = amount/?*? where id = ?";
        				$adb->pquery($query2payment,array($becurrency_rate,$conversion_rate,$this->id));
        			}
         }
    }
   	function save_module($module)
	{
        global $adb;
        $i=1;

      if($_REQUEST['action'] != 'CustomForm25Ajax' && $_REQUEST['ajaxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		  
        }
        else
        {
            return ;
        }

		if($this->currency_status === true)
		{
			$update_query = "update ld_customform25 set currency_id=?, conversion_rate=?,currency_symbol=? where customform25id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
        crm_load_class_file('cls_save_moduledetail','data');
        $obj=new cls_save_moduledetail($this->module_name,$this->id);
         
        $obj->Savedetail();
		  
		$update_query = "update ld_customform25 set triggercount=triggercount+1 where customform25id=?";
		$update_params = array($this->id);
		$this->db->pquery($update_query, $update_params);
          
    }
    
    function getSourceField($fieldname,$recordid)
    {
        global $adb;
        return array();
        $sql = "select entitytype,entitytypeid from ld_customform25detail where lineitem_id = ?";
        
        $result = $adb->pquery($sql,array($recordid));
        return $adb->query_result($result,0,0);
    }
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts'||$return_module=="SalesOrder"||$return_module=="PaymentPlan"|| $return_module == 'ServiceContracts'  ) {
			$this->trash('CustomForm25',$id);
		} 
	}
    
   
    
  
    function getCustomForm25Field($fieldname,$recordid)
    {
        global $adb;
        $sql = "select $fieldname from ld_customform25 where customform25id = $recordid";
        $result = $adb->pquery($sql,array());
        return $adb->query_result($result,0,0);
    }
	
	function getBaxterFileLog() {
        global $adb,$current_user,$languageType,$currentModule;
        $query = "select ld_baxterfilelog.*,ld_users.last_name from ld_baxterfilelog INNER JOIN ld_users ON ld_users.id = ld_baxterfilelog.creator where crmid=? ORDER BY created_at DESC";

        //读取数据
//        echo $record;dump($query);
//        $result = $adb->pquery($query,array($record));
        $result = $adb->pquery($query,array($this->id));
        $rows = $adb->num_rows($result);

        $filelist_arr = array();
        if($rows > 0){
            for ($i=0; $i < $rows; $i++) {
                $filelist['fileid'] = $adb->query_result($result,$i,'fileid');
                $filelist['title'] = $adb->query_result($result,$i,'title');
                $filelist['file_name'] = $adb->query_result($result,$i,'file_name');
                $filelist['file_type'] = $adb->query_result($result,$i,'file_type');
                $filelist['file_path'] = $adb->query_result($result,$i,'file_path');
                $filelist['cloud_path'] = $adb->query_result($result,$i,'cloud_path');
                $filelist['crmid'] = $adb->query_result($result,$i,'crmid');
                $filelist['creator'] = $adb->query_result($result,$i,'last_name');
                $filelist['created_at'] = $adb->query_result($result,$i,'created_at');
                $filelist_arr[] = $filelist;
            }
        }

        return $filelist_arr;
    }
    
}
CustomForm25::require_file();
?>