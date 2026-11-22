<?php


class ProductProperty extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
        globalStatic::$arr_module_require['ProductProperty']='ProductProperty';
        if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
        {
            globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
            include("modules/$requiremodules/$requiremodules.php");
        }
    }
    var $log;
    var $db;
    var $table_name='ld_productproperty';
    var $table_index='productpropertyid';
    var $table_code='productproperty_no';
    var $tab_name=Array('ld_crmentity','ld_productproperty','ld_productpropertyscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_productproperty'=>'productpropertyid','ld_productpropertyscf'=>'productpropertyid');
   	var $customFieldTable = Array('ld_productpropertyscf', 'productpropertyid');
	var $entity_table = "ld_crmentity";
    var $Detail_table="ld_productpropertydetail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_productpropertydetailscf";//明细自定义表
    var $Detail_table_index="id";//明细表和主表关联的字段名称
	var $column_fields = Array();
    var $module_name='ProductProperty';
    var $sortby_fields=Array('productproperty_no');
    var $relatedtab=array('accounts'=>'','salesorder'=>'','users'=>'','company'=>'','cashbill'=>'','productproperty'=>'');
    var $list_link_field= 'productproperty_no';
   	var $search_fields_name = Array();
    var $required_fields =  array();
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'productproperty_no');
	var $default_order_by = 'productproperty_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="productproperty_no";
    var $detailfieldobj;
    public function __construct()
    {
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('ProductProperty',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('ProductProperty');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
    }
    public function massEdit_save_before($module,$ids)
    {
        parent::massEdit_save_before($module,$ids);
    }

    public function before_save($record)
    {
        $row_cnt = $_REQUEST['rowcnt'];//多少行分录
        $tmp_property_value_name=[];
        $tmp_property_value_no=[];
        //验证分录是否重复
        for ($i = 1; $i <= $row_cnt; $i++){
            $tmp_property_value_name[] = $_REQUEST['property_value_name' . $i];
            $tmp_property_value_no[] = $_REQUEST['property_value_no' . $i];
        }
        $length1 = count(array_unique($tmp_property_value_name));//去重后的行数
        $length2 = count(array_unique($tmp_property_value_no));//去重后的行数
        //分录重复给提示
        if($length1<$row_cnt||$length2<$row_cnt){
            $msg = "分录属性值名称和属性值编号不允许重复";
            ConvertTojsonString(-1,[],$msg);
        }
    }
    public function save_module($module)
	{
        if($_REQUEST['action'] != 'ProductPropertyAjax' && $_REQUEST['ajaxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		  
        }
        else
        {
            return ;
        }
        //crm_load_class_file('cls_save_moduledetail','data');
        //$obj=new cls_save_moduledetail($this->module_name,$this->id);
        //$obj->Savedetail();
        $this->Savedetail();
    }

    //ZXM 20240926 重写保存明细
    public function Savedetail(){
        global $adb;
        //记录保存前的分录信息
        $row_cnt = $_REQUEST['rowcnt'];//多少行分录
        $lineitem_id_arr = [];
        for($i=1;$i<=$row_cnt;$i++){
            $tmp_lineitem_id = isset($_REQUEST['lineitem_id'.$i])?$_REQUEST['lineitem_id'.$i]:0;
            $tmp_property_value_name = $_REQUEST['property_value_name'.$i];
            $tmp_property_value_no = $_REQUEST['property_value_no'.$i];
            $tmp_description = $_REQUEST['description'.$i];

            //先查询这个属性值是否在记录里面存在
            if($tmp_lineitem_id>0){
                //update lineitem_id大于0 更新数据
                $query = 'update ld_productpropertydetail set property_value_name=?,property_value_no=?,description=?,sequence=? where lineitem_id=?';
                $adb->pquery($query, array($tmp_property_value_name,$tmp_property_value_no,$tmp_description,$i,$tmp_lineitem_id));

            }else{
                //查询
                $select_nums = 0;
                if($this->id>0){
                    $select_query = " select lineitem_id from ld_productpropertydetail where  id=? and property_value_name=? ";
                    $select_res = $adb->pquery($select_query,array($this->id,$tmp_property_value_name));
                    $select_nums = $adb->num_rows($select_res);
                }
                if($select_nums>0){
                    //update
                    $query = 'update ld_productpropertydetail set property_value_no=?,description=?,sequence=? where property_value_name=? and id=?';
                    $adb->pquery($query, array($tmp_property_value_no,$tmp_description,$i,$tmp_property_value_name,$this->id));
                    $tmp_lineitem_id = $adb->query_result($select_res,0,'lineitem_id');
                }else{
                    //insert 不存在属性值名称相同的 直接新增一条新数据
                    $query = 'insert into ld_productpropertydetail (id,property_value_name,property_value_no,description,sequence) values(?,?,?,?,?)';
                    $adb->pquery($query, array($this->id,$tmp_property_value_name,$tmp_property_value_no,$tmp_description,$i));
                    $tmp_lineitem_id = $adb->getLastInsertID();
                }

            }
            $lineitem_id_arr[$i] = $tmp_lineitem_id;
        }
        //todo 删除
    }
    public function getSourceField($fieldname,$recordid)
    {
        return array();
    }
    public function unlinkRelationship($id, $return_module, $return_id) {
		
        if(empty($return_module) || empty($return_id)) return;
		if($return_module == 'Accounts'||$return_module=="SalesOrder"||$return_module=="PaymentPlan"|| $return_module == 'ServiceContracts'  ) {
			$this->trash('ProductProperty',$id);
		} 
	}
    public function getProductPropertyField($fieldname,$recordid)
    {
        global $adb;
        $sql = "select $fieldname from ld_productproperty where productpropertyid = $recordid";
        $result = $adb->pquery($sql,array());
        return $adb->query_result($result,0,0);
    }
}
ProductProperty::require_file();
?>