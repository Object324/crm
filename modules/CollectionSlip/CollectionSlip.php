<?php


class CollectionSlip extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['CollectionSlip']='CollectionSlip';
          
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_collectionslip';
    var $table_index='collectionslip_id';
    var $table_code='collectionslip_no';
    var $tab_name=Array('ld_crmentity','ld_collectionslip','ld_collectionslipscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_collectionslip'=>'collectionslip_id','ld_collectionslipscf'=>'collectionslip_id');
   	var $customFieldTable = Array('ld_collectionslipscf', 'collectionslip_id');
	var $entity_table = "ld_crmentity";
    var $Detail_table="ld_collectionslipdetail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_collectionslipdetailscf";//明细自定义表
     var $Detail_table_index="id";//明细表和主表关联的字段名称
	var $column_fields = Array();
    var $module_name='CollectionSlip';
    var $sortby_fields=Array('collectionslip_no');

    var $relatedtab=array('accounts'=>'','salesorder'=>'','users'=>'','company'=>'','cashbill'=>'','collectionslip'=>'');
            
    var $list_link_field= 'collectionslip_no';
   	var $search_fields_name = Array();
    var $required_fields =  array();


	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'collectionslip_no');
	var $default_order_by = 'collectionslip_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="collectionslip_no";
    
    var $detailfieldobj;
    public $collectionslip_status;
    function __construct()
    {
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CollectionSlip',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CollectionSlip');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);

        $this->collectionslip_status = array('all'=>getFixedLabel('ALL'),
            'uncollected'=>getFixedLabel('UNCOLLECTED'),
            'collected'=>getFixedLabel('COLLECTED'),
            'havecashbill'=>getFixedLabel('GENERATED').getTranstab('CashBill'));
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
                $query = "update ld_collectionslip set total = total*?,subtotal = subtotal*? where collectionslip_id = ?";
                $adb->pquery($query,array($conversion_rate,$conversion_rate,$this->id));
                $query2payment = "update ld_collectionslipdetail set amount = amount/? where id = ?";
                $adb->pquery($query2payment,array($conversion_rate,$this->id));
           } else {
                $query = "update ld_collectionslip set total = total/?*?,subtotal = subtotal/?*? where collectionslip_id = ?";
                $adb->pquery($query,array($becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$this->id));
                $query2payment = "update ld_collectionslipdetail set amount = amount/?*? where id = ?";
                $adb->pquery($query2payment,array($becurrency_rate,$conversion_rate,$this->id));
           }
        }
    }
   	function save_module($module)
	{
        global $adb;
        $i=1;
        if($_REQUEST['action'] != 'CollectionSlipAjax' && $_REQUEST['ajaxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails') {
        } else {
            return ;
        }
		if($this->currency_status === true) {
			$update_query = "update ld_collectionslip set currency_id=?, conversion_rate=?,currency_symbol=? where collectionslip_id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
        crm_load_class_file('cls_save_moduledetail','data');
        $obj=new cls_save_moduledetail($this->module_name,$this->id);
        $obj->Savedetail();
        //收款认领单保存时默认为未分配（要放在工作流位置之前）
        if($this->mode == 'create'){
            //新建工单更新为待分配状态
            $sql = 'update '.$this->table_name.' set collectionslip_status=? where '.$this->table_index.'= ?';
            $this->db->pquery($sql,array('uncollected',$this->id));
        }
    }
    
    function getSourceField($fieldname,$recordid)
    {
        global $adb;
        return array();
        $sql = "select entitytype,entitytypeid from ld_collectionslipdetail where lineitem_id = ?";
        $result = $adb->pquery($sql,array($recordid));
        return $adb->query_result($result,0,0);
    }
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts'||$return_module=="SalesOrder"||$return_module=="PaymentPlan"|| $return_module == 'ServiceContracts'  ) {
			$this->trash('CollectionSlip',$id);
		} 
	}
    
   
    
  
    function getCollectionSlipField($fieldname,$recordid)
    {
        global $adb;
        $sql = "select $fieldname from ld_collectionslip where collectionslip_id = $recordid";
        $result = $adb->pquery($sql,array());
        return $adb->query_result($result,0,0);
    }
    
}
CollectionSlip::require_file();
?>