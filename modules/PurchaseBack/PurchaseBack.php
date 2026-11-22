<?php



class PurchaseBack extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['PurchaseBack']='PurchaseBack';
        if(empty(globalStatic::$arr_module_require['Accounts']))
        {
                globalStatic::$arr_module_require['Accounts']='Accounts';
                include("modules/Accounts/Accounts.php");   
        }
        if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
         {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");    
         }
    }
    var $log;
    var $db;
    var $Detail_table="ld_purchasebackdetail";//明细表名称
    var $Detail_table_id="lineitem_id";//明细表主表和自定义表关联字段
	var $Detail_table_scf = "ld_purchasebackdetailscf";//明细scf表
     var $Detail_table_index="id";//明细表和主表关联的字段
    var $table_name='ld_purchaseback';
    public $table_index='purchasebackid';
    var $table_code='purchaseback_no';//表编号字段(审批中心)
    var $tab_name=Array('ld_crmentity','ld_purchaseback','ld_purchasebackscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_purchaseback'=>'purchasebackid','ld_purchasebackscf'=>'purchasebackid');
   	var $customFieldTable = Array('ld_purchasebackscf', 'purchasebackid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
    var $module_name='PurchaseBack';
	var $column_fields = Array();
    var $sortby_fields=Array('purchasebackid,purchasebackdate');
    /*
    edit:can
    date:20131024
    reason:打印关联模块
    */
    var $relatedtab=array('accounts'=>'','users'=>'','company'=>'','purchaseback'=>'','purchaseorder'=>'','products'=>'');
            
    var $list_link_field= 'purchaseback_no';
            
            
   	var $search_fields_name = Array(
		          
			);
            
   var $required_fields =  array();

//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'sendcashbill_no');
	var $default_order_by = 'purchasebackid';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="purchaseback_no";
    var $popup_fields=Array();
    function __construct()
    {
	  // $this->log =LoggerManager::getLogger('PurchaseBack');
		$this->db = PearDatabase::getInstance();
	    $this->fieldobj=Field::getInstance('PurchaseBack',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('PurchaseBack');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
        crm_load_class_file('ProductToolFields','include/ProductDetails');
        $this->detailfieldobj=ProductToolFields::getInstance($this->module_name);
    }
  
   function save_module($module)
   {        
        global $adb;
        
        /*if((isset($_REQUEST['createview'])&& $_REQUEST['createview']=='create_view')||$this->mode!='edit')
        {
            $update_query = "update ld_purchaseback set purchasebackstatus='未出库' where purchasebackid=?";
            $adb->pquery($update_query, array($this->id));
        }*/
        
        if($_REQUEST['action'] != 'PurchaseBackAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
					&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
			crm_load_function_file('saveInventoryProductDetails','include/utils','InventoryUtils');
            saveInventoryProductDetails($this, 'PurchaseBack');
		}
        
        //放在函数的最下面，等待主表更新total字段更新完成
        crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
        cls_Source_InverseCompute::Source_InveverseCompute($module,$this->id,$this);
 
		$update_query = "update ld_purchaseback set currency_id=?, conversion_rate=?,currency_symbol=? where purchasebackid=?";
        $update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
        $this->db->pquery($update_query, $update_params);

       //ls 20221201 XUQIU1000685  增加审批功能（采购退货单）
       //编辑时，状态不变，源单改变也需要重新计算总库存数量
       if($this->column_fields['purchasebackstatus']==ALLOUTBOUND){//已出库
           $this->operationwarehouse($this->id,'outstock');
       }
       else if($this->column_fields['purchasebackstatus']==NOTOUTBOUND&&$this->mode=='edit')//新增未出库不做反写处理
       {
           $this->operationwarehouse($this->id,'cancelstock');
       }
        
   }
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
        
        $this->trash('PurchaseBack',$id);
		 
	}

    //审批成功操作
    public function successApprove($record)
    {
        $this->operationwarehouse($record,'outstock');
    }
    //反审批操作
    public function rejectApproved($record)
    {
        $this->operationwarehouse($record,'cancelstock');
    }

    function operationwarehouse($record,$type)
    {
        global $current_user,$adb;
        if ($type == 'outstock') {
            $purchasebackstatus = '已出库';
            $typename = '退货出库';
        } else {
            $purchasebackstatus = '未出库';
            $typename = '撤销退货';
        }

//        $deployarray=getSys_deploy(132);//未入库订单是否允许退货 1：是，0：否
//        $deployvalue = $deployarray['deploy_value'];
        $sql = "select productid,quantity,parent_lineitem_id,entitytypeid,lineitem_id,batchtext from ld_purchaseback 
    		inner join ld_purchasebackdetail on id=purchasebackid where purchasebackid = ?";
        $results=$adb->pquery($sql,array($record));
        $num_rows=$adb->num_rows($results);

        //更改采购退货单的状态
        $update_query = "update ld_purchaseback set purchasebackstatus= ? where purchasebackid=?";

        $adb->pquery($update_query, array($purchasebackstatus,$record));
        crm_load_function_file("insertCondtion",'include/Stock','CommonStock');
        for ($i = 0; $i < $num_rows; $i++) {
            $productid = $adb->query_result($results,$i,'productid');

            $qty = $adb->query_result($results,$i,'quantity');
            $entitytypeid = $adb->query_result($results,$i,'entitytypeid');
            $parent_lineitem_id = $adb->query_result($results,$i,'parent_lineitem_id');
            $wareid = $adb->query_result($results,$i,'wareid');
            $lineitem_id = $adb->query_result($results,$i,'lineitem_id');
            $batchtext=$adb->query_result($results,$i,'batchtext');
            insertCondtion($batchtext, $record,$typename,$wareid,$productid,$currentModule,$current_user->id,0,0,$parent_lineitem_id,$lineitem_id);


        }

        //反写采购订单已入库和未入库数量
        crm_load_class_file("cls_Source_InverseCompute","include/OptionModule");
        cls_Source_InverseCompute::Source_InveverseCompute("PurchaseBack",$record);
    }
    
}
PurchaseBack::require_file();
?>