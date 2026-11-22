<?php
/**
 * User: diony
 * Date: 2019/03/01
 */
crm_load_class_file('cls_ProductEntry_DetailViewWX', 'WeiXinApp/detail');
class cls_PurchaseCashBack_DetailViewWX extends cls_ProductEntry_DetailViewWX
{
    protected function get_CreateView_Old_WaitDelete()
    {
        $this->set_CreateView();
        crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX','WeiXinApp/include/ProductDetailsHtml');
        if(!empty($this->relatedCreationInfo)){
            $relatedInfo = $this->relatedCreationInfo;
            $productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($this->module,'module_create',$relatedInfo['fromid'],$relatedInfo['frommodule'],$this->actionname);
        }else{
            $productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($this->module,'','','',$this->actionname);
        }
        $this->set_entrydetail($productdetailObj);
        return $this->jsonArr;
    }

    protected function get_DetailView_Old_WaitDelete(){
        $this->set_DetailView();
        crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX','WeiXinApp/include/ProductDetailsHtml');
        $productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($this->module,'',$this->record,'Products',$this->actionname);
        $this->set_entrydetail($productdetailObj);
        $this->DetailLastExtra();
        return $this->jsonArr;
    }
    //初始化分录返回值 20170411
    protected function set_entrydetail_Old_WaitDelete($productdetailObj)
    {
        $productdetail = $productdetailObj->getValues();
        $fieldids_content_orign = file_get_contents(globalStatic::$root_directory.'user_privileges/Config_PurchaseCashBack_ProductShowFields_Mobile.php');
        if(empty($fieldids_content_orign)){
            $fieldids_content_orign = '{quantity}x{taxprice}';
        }
        $MixproductValues = $productdetail['value'];
        $productValues = array();

        foreach($MixproductValues as $listnum=>$content) {
            $fieldids_content = $fieldids_content_orign;
            foreach ($content as $columnname => $mixed_fieldvalue) {
                if(is_array($mixed_fieldvalue)){
                    $productValues[$listnum][$columnname] = $mixed_fieldvalue['value'];
                }else{
                    $productValues[$listnum][$columnname] = $mixed_fieldvalue;
                }
            }
        }
        foreach($productValues as $listnum=>$content){
            $fieldids_content = $fieldids_content_orign;
            foreach($content as $columnname=>$fieldvalue){
                if($columnname=='imagename'){//图片返回值特殊处理
                    $imagearr = array();
                    foreach($fieldvalue['image_id_array'] as $key=>$value){
                        $imagearr[$key]['imgid'] = $value;
                        $imagearr[$key]['value'] = $fieldvalue['imagepath_array'][$key].$fieldvalue['image_array'][$key];
                    }
                    $productValues[$listnum][$columnname]=$imagearr;
                    continue;
                }
                if(strpos($fieldids_content,'{'.$columnname.'}') !== false){
                    $fieldids_content = str_replace('{'.$columnname.'}',$fieldvalue,$fieldids_content);
                }
            }
            $productValues[$listnum]['productshowfieldslabel'] = $fieldids_content;
            $productValues[$listnum]['sequence_no']= $listnum+1;
        }
        $outputProductValues['blocklabel'] = '产品清单';
        if($this->action=='DetailView') {
            $outputFieldArr = $this->outputProductFieldArr;
            foreach ($productValues as $listnum => $content) {
                $item=0;
                foreach ($content as $columnname => $fieldvalue) {
                    if($columnname=='productid'){
                        $outputProductValues['list'][$listnum]['entryid'] = $fieldvalue;
                        $outputProductValues['list'][$listnum]['entrytype'] = 'product';
                    }elseif($columnname=='sequence_no'){
                        $outputProductValues['list'][$listnum]['sequence_no'] = $fieldvalue;
                    }elseif (in_array($columnname, $outputFieldArr)) {
                        $item++;
                        $outputProductValues['list'][$listnum]['item'.$item] = $fieldvalue;
                    }
                }
            }
        }else{
            $editProductValues = array();
            foreach($productValues as $listnum=>$content){
                foreach($content as $fieldname=>$value){
                    $editProductValues[$listnum][$fieldname]['value'] = $value;
                    $editProductValues[$listnum][$fieldname]['hiddenvalue'] = $value;
                }
            }
            $outputProductValues['list'] = $editProductValues;
        }
        $subtotalvalue = array();//QQ目前仅记录数量和价税合计的小计

        foreach($productdetail['subtotalvalue'] as $key=>$val){
            if($key=='quantity' || $key=='subtotal'){
                if($key=='quantity'){
                    $subtotalvalue[$key]['label']='数量小计';
                }else{
                    $subtotalvalue[$key]['label']='金额小计';
                }
                $subtotalvalue[$key]['value']=empty($val)?'':$val;
            }
        }
        $lastRowValue = $productdetailObj->getLastRow_Value();//QQ整单折扣信息不全      \      编辑时最后一行合计空值

        $lastRowValue_orign = array_merge($subtotalvalue,$lastRowValue);

        if($this->action=='DetailView') {
            $item=0;
            $total = '';
            $lastRowValue_out = array();
            foreach($lastRowValue_orign as $fieldname=>$content){
                if($fieldname=='total'){
                    $total = $content;
                }else{
                    $lastRowValue_out[$item] = $content;
                    $item++;
                }
            }
            $lastRowValue_out[$item] = $total;
        }else{
            $lastRowValue_out = $lastRowValue_orign;
        }

        $outputProductValues['p_total'] = $lastRowValue_out;
        $this->jsonArr['currency']['current']=  $this->getCurrency($this->module, $this->focus->id);

        if($this->action=='EditView'||$this->action=='CreateView'){
            $this->jsonArr['math']=$productdetailObj->getSystemForPoint();
            $outputProductValues['listfield'] = $productdetail['headers'];//headers中的字段缺少fieldtype
            $outputProductValues['listformulafield'] = $productdetailObj->getModuleProductFormulaField();
            $outputProductValues['nopresencefield'] = $productdetailObj->getNoPresenceFieldFormula();
            $this->jsonArr['currency']['allcurrencies'] = $this->getCurrency(null,null,'all');
        }

        $this->jsonArr['entry'] = $outputProductValues;
    }
}