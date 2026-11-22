<?php
/**
* 产品明细HTML
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
/**
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
crm_load_class_file('Parent_ProductDetailsData','include/ProductDetailsHtml');
class cls_productDetailsData extends Parent_ProductDetailsData{
	
	public function __construct($module){
		parent::__construct($module);
	}

    function getProductToolFieldSql($frommdouleFocus){
        $ld_inventoryproductrel=$this->focus->Detail_table;
        $Detail_table_id=$this->focus->Detail_table_id;//明细表主表和自定义表关联字段
        $Detail_table_scf=$this->focus->Detail_table_scf;//明细自定义表
        $Detail_table_index=$this->focus->Detail_table_index;//明细表和主表关联的字段
        $sql=$this->getInventorySql($frommdouleFocus);
        //zkt 20230217 BUG0061762 选择源单-设置 带入分录明细范围 (主表字段)=》关联创建时分录未带出
        //设置主表连接
        $sql .= $this->getOtherSourceModuleMainLeftjoin();
        if($this->isRelatedModuleCreate($frommdouleFocus)=='yes')
        {
            $ld_inventoryproductrel=$frommdouleFocus->Detail_table;
            $Detail_table_id=$frommdouleFocus->Detail_table_id;//明细表主表和自定义表关联字段
            $Detail_table_scf=$frommdouleFocus->Detail_table_scf;//明细自定义表
            $Detail_table_index=$frommdouleFocus->Detail_table_index;//明细表和主表关联的字段
        }
        $versioninfo=getVersionInfo();
        if($this->focus->id > 0 && empty($frommdouleFocus->lineitemIds)){//单据编辑、详情条件

            if($versioninfo['account']=='huacanguangdian' && $this->module == 'CustomForm37' && $this->productdetail_mode != 'details'){
                $sql_next = 'select lineitem_id from ld_customform37detail INNER JOIN ld_customform37 on ld_customform37detail.id = ld_customform37.customform37id where ld_customform37.accountid = (select accountid from ld_customform37 where customform37id = ?) and ld_customform37.deleted = 0;';
                $result_next = $this->db->pquery($sql_next,array($this->focus->id));
                $newarr = [];
                $result_num = $this->db->num_rows($result_next);
                if($result_num > 0){
                    for($i =0;$i<$result_num;$i++){
                        $newarr[] = $this->db->query_result($result_next,$i,'lineitem_id');
                    }
                }
                $sql .= " where $ld_inventoryproductrel.$Detail_table_id in (" . implode(',',$newarr) . ')';
            }else{
                $sql .= " where $ld_inventoryproductrel.$Detail_table_index in (" . $this->focus->id . ')';
            }
        }elseif(is_string($frommdouleFocus->lineitemIds) && trim($frommdouleFocus->lineitemIds)!=""){	//选择源单条件
            $sql .= " where $ld_inventoryproductrel.$Detail_table_id in (" . $frommdouleFocus->lineitemIds. ')';
        }else{
            return '';
        }

        //设置源单分录明细范围
        $sql .= $this->getOtherSourceModuleSqlWhere();
        //报价单合并创建合同订单，将来自同一个报价单的产品排一起
        if($frommdouleFocus->mode == 'mergecreate'){
            $sql .= " order by field($ld_inventoryproductrel.$Detail_table_id ," . $frommdouleFocus->lineitemIds. ')';
        }else{
            $sql .= " order by $ld_inventoryproductrel.$Detail_table_index,$ld_inventoryproductrel.sequence_no asc";
        }
        //echo $sql;die;
        // exit();
        return $sql;
    }

    public function getProductToolFieldsInfos($productToolFieldsValues,$frommdouleFocus,$productdetail_mode) {
        $versioninfo=getVersionInfo();
        if($versioninfo['account']=='huacanguangdian'){
            foreach($this->inventoryFields as $columnname => $table_column){
                if($columnname == 'parent_lineitem_id')
                    $productdetail_value[$columnname] = $this->getParentLineitemId($productToolFieldsValues);
                else
                    $productdetail_value[$columnname] = $productToolFieldsValues[$columnname];
            }
            $productdetail_value['detailid']=$productToolFieldsValues['detailid'];

            $productToolTr = $this->getProductToolTrData($frommdouleFocus,$productdetail_mode);
            //  dump($productToolTr);

            $fieldobj = Field::getInstance('Products', $this->db);
            $accounts_focus = CRMEntity::getInstance('Accounts');
            $product_moduleFields = $fieldobj->getModuleFields();

            foreach($productToolTr as $key=>$productToolFieldInfo){
                $columnname = strtolower($productToolFieldInfo->getColumnName());

                $productinfo[$columnname]['input_type']=$productToolFieldInfo->getinput_type();
                $productinfo[$columnname]['typedata'] = $productToolFieldInfo->getTypeOfData();
                $productinfo[$columnname]['newline'] = $productToolFieldInfo->getNewLine();
                $productinfo[$columnname]['tablename']=$productToolFieldInfo->getTableName();
                $productinfo[$columnname]['width']=$productToolFieldInfo->getWidth();
                $productinfo[$columnname]['fieldvaluecolor']=$productToolFieldInfo->getFieldValueColor();
                $productinfo[$columnname]['fieldplaceholder']=$productToolFieldInfo->getFieldPlaceholder();
                if($productToolFieldInfo->getinput_type() == 1){
                    $profieldarr=$fieldobj->FieldInfoListByKeyValue('columnname',$columnname);
                    if(!empty($product_moduleFields[$profieldarr['fieldname']])){
                        $field = $product_moduleFields[$profieldarr['fieldname']];
                        $productinfo[$columnname]['uitype'] = $field->getUIType();
                    }else{
                        $productinfo[$columnname]['uitype'] =  $productToolFieldInfo->getUIType();
                    }
                }else{
                    $productinfo[$columnname]['uitype'] =  $productToolFieldInfo->getUIType();
                }
                $productinfo[$columnname]['fieldlabel'] = $productToolFieldInfo->getFieldLabel();
                $productinfo[$columnname]['columnname'] = $columnname;
                $productinfo[$columnname]['edit_perssion'] = $productToolFieldInfo->getEdit_permission();
                $productinfo[$columnname]['selectpricefrombook'] = $productToolFieldInfo->getSelectpricefrombook();
                if($productdetail_mode != 'addrow_create'){
                    $column_value = $productToolFieldsValues[$columnname];
                }else{
                    //服务合同选择合同订单带出产品明细（服务开始日期结束日期取给定默认值）
                    if($this->productdetail_mode == 'sourcemodule_create' && $frommdouleFocus->object_name == 'SalesOrder' && $this->focus->module_name == 'ServiceContracts' && $columnname == 'servicecontracts_start_date'){
                        $column_value=date('Y-m-d');
                    }else{
                        $column_value = $productToolFieldInfo->getDefaultvalue();
                    }
                }
                //复制，关联创建单据需要重算最近价格
                if((in_array($productdetail_mode,array('sourcemodule_create','module_create','product_create'))||$_REQUEST['isDuplicate']=='true') && in_array($productToolFieldInfo->getUIType(),array(730,731,810,811))){
                    crm_load_function_file('getLastPrice','include/utils','InventoryUtils');
                    $lastprice = getLastPrice($frommdouleFocus->module_name,$productdetail_value['productid'],$frommdouleFocus->column_fields['account_id'],$productToolFieldInfo->getUIType(),'');
                    if($columnname=='lasttaxprice'){
                        $column_value = $lastprice['lasttaxprice'];
                    }else{
                        $column_value = $lastprice['lastlistprice'];
                    }
                }
                //合同订单、报价单选择客户，如果客户有扣率则直接在产品明细中带出
                if(($this->module == 'SalesOrder' || $this->module == 'Quotes') && !empty($_REQUEST['accvenid']) && $columnname == 'discount_percent'){
                    $accounts_focus->retrieve_entity_info($_REQUEST['accvenid'], 'Accounts');
                    if(!empty($accounts_focus->column_fields['discount_rate'])){
                        $column_value = 100 - $accounts_focus->column_fields['discount_rate'];
                    }
                }
                $typeofdata = explode('~', $productinfo[$columnname]['typedata']);
                //38407: （1.6）出库单新建界面：选择入库单源单保存时界面报错
                if(($typeofdata[0] == 'N' || $typeofdata[0] == 'NN') && !in_array($columnname,array('entitytype','entitytypeid'))){


                    $lengthdecimaldigits = $this->getDecimalDigits($productToolFieldInfo,$productinfo[$columnname]['typedata']);
                    $productinfo[$columnname]['lengthdecimaldigits'] = $lengthdecimaldigits;
                    //产品参考成本
                    if(!in_array($productinfo[$columnname]['uitype'],$this->noSubtotalUitype)){
                        //盘点 账面数量

                        if($productinfo[$columnname]['columnname'] == 'qtyinstock' && $this->module == 'Checks'){
                            $wareid = $this->focus->column_fields['wareid'];
                            $column_value = getWareProductNum($wareid,$productdetail_value['productid']);
                        }
                        if(!empty($this->subtotalTrData[$key])){
                            $this->subtotalTrData[$key] += $column_value;
                        }else{
                            $this->subtotalTrData[$key] = $column_value;
                        }
                    }
                    //chj 2021/1/13 43941: 易冲（http://171.221.206.240:88/crm/ [^]）OA审批>样品申请>表单新建不保存是这么多，保存后就变成截图的值，其他表单没有这个问题。详情见附件
                    if($this->productdetail_mode == 'details' && $productinfo[$columnname]['input_type'] != 1){

                        $column_value = setNumberFormat($column_value,$lengthdecimaldigits);
                    }
                }
                $productdetail_value[$columnname]=$column_value;
                $productinfo[$columnname]['column_value'] = $column_value;
            }

            return array('productdetail_value'=>$productdetail_value,'producttoolfield_info'=>$productinfo);
        }
        else{
            return parent::getProductToolFieldsInfos($productToolFieldsValues,$frommdouleFocus,$productdetail_mode);
        }

    }
}
?>