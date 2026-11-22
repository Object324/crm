<?php
/**
 * 2016-03-22
 * V6.3 财务模块 - 明细类
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
 crm_load_class_file('TabDetailFields','include/TabDetailFields');
 crm_load_class_file("TabDetailFieldsData",'include/TabDetailFields');
class SendCashBillTabDetailFieldsData extends TabDetailFieldsData{
    
	public $module;
	public $TabDetailFields;
	public $tabPresenceDetailFields;
	public $focus;
	public $haveSubtotalField;//小计字段
	public $haveSubtotalFieldValue;//小计字段对应结果节
	public $haveTotalFieldValue;
	public $module_nullfield;

    function __construct($focus,$module,$sourceModule){
		$this->focus = $focus;
		$this->setmode($focus->mode);
		$this->db = PearDatabase::getInstance();
		$tabid = getTabid($module);
		$this->module = $module;
		$this->TabDetailFields = new TabDetailFields($tabid);
        $this->TabDetailFields->setsourceModulesqlwhere($sourceModule);
		//有权限看到并且启用的自定义字段
		$this->tabPresenceDetailFields = $this->TabDetailFields->getTabPresenceDetailFields();
		//空行基准字段
		$this->module_nullfield = $this->TabDetailFields->getRowNullField();
		//小计字段
		$this->haveSubtotalField = $this->TabDetailFields->getTabSubtotalField();
    }
    
    public function getTabDetailHtmlContentData($start_row_index=''){
        //选择源单、关联创建需要查引用信息的字段
        if(empty($this->focus->id)){
            $this->SourceCreate_Relatedcolumn_arr[] = 'amount';//本次付款金额
        }
        //zkt 20230908 BUG0072441 付款计划（CP665）查看详情界面，关联创建付款单时，分录明细中的合同金额显示错误，显示0 
        if($this->row_mode == 'related_create'){
            //BUG0072623 20230913 客户关联创建收款单缺少分录行
            if(empty($this->entitytypeid)){
                $column_value = [];
                foreach($this->tabPresenceDetailFields as $columnname => $field){
                    if(!empty($field)){
                        $column_value[0]['parent_lineitem_id']=0;
                        $value = '';
                        if($field->getNewLine() == 1){
                            $this->haveTotalFieldValue[$columnname] = $value;
                        }
                        $column_value[0][$columnname] = $value;
                    }
                }
                $this->productrows = 1;
            }
            else{
                $column_value = $this->getTabDetailHtmlContentDataSelectSource($this->entitytypeid,getSalesEntityType($this->entitytypeid));
                //zkt 20240807 BUG20240806-61 在付款单列表里面直接新增付款单时，分录上所有数据都可以带出来（见图一）；如果点某一个采购订单进入关联做付款单分录就是空（见图二图三）
                foreach ($column_value as &$tmpvalue_arr ){
                    foreach($this->tabPresenceDetailFields as $columnname => $field){
                        if(!empty($field)&&!isset($tmpvalue_arr[$columnname])){
                            $value = $field->getDefaultvalue();
                            $tmpvalue_arr[$columnname] = $value;
                        }
                    }
                }
            }
        }
        else{
            $column_value = parent::getTabDetailHtmlContentData($start_row_index);
        }
        //zkt 20230206 BUG0061196kfbcrm，付款单模块，新建付款单，源单选择付款计划，选择后，分录的信息会显示付款计划关联的合同信息，但是保存后这个合同信息就不显示了，如图。客户系统也有这种情况，修改好之后麻烦帮客户也修改一下。
        /*$tmpcolumn_value = $column_value;
        foreach($tmpcolumn_value as $tmpindex =>$column_value_info)
        {
            $tmpentitytype = $column_value['entitytype'];
            foreach($column_value_info as $columnname=>$tmpvalue)
            {
                if($tmpentitytype!='PurchaseOrder'&&in_array($columnname,array('plan_contract','plan_contract_amount','plan_orderpayamount','plan_orderreceivedamount'))){
                    unset($column_value[$tmpindex][$columnname]);
                }
            }
            
        }*/
        
        return $column_value;
    }
    
    public function getTabDetailHtmlContentDataSelectSource($entitytypeids,$sourceModule){
        
        $column_value_arr = parent::getTabDetailHtmlContentDataSelectSource($entitytypeids,$sourceModule);
        return $column_value_arr;
        
        
    }
    

}
?>
