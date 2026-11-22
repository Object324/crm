<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_ProductEntry_DetailViewWX', 'WeiXinApp/detail');
class cls_QuotesChange_DetailViewWX extends cls_ProductEntry_DetailViewWX
{
    protected function get_CreateView()
    {
        $this->set_CreateView();
        crm_load_class_file('cls_QuotesChange_PageRecordValueWX','WeiXinApp/include/ProductDetailsHtml');
        if(!empty($this->relatedCreationInfo)){
            $relatedInfo = $this->relatedCreationInfo;
            $relatedfocus=cls_Instance::get_module_Instance($relatedInfo['frommodule']);
            $relatedfocus->retrieve_entity_info($relatedInfo['fromid'],$relatedInfo['frommodule']);
            //editor:gyq_134 reason:报价变更单新建修改  2019/7/26 16:23 
            if($_REQUEST['change_type']=='replace' ||$_REQUEST['change_type']=='edit' ){
                $productdetailObj = new cls_QuotesChange_PageRecordValueWX($this->module,'module_create',$relatedInfo['fromid'],$relatedInfo['frommodule'],$this->action);
            }else{
                $productdetailObj = new cls_QuotesChange_PageRecordValueWX($this->module,'create','','',$this->action);
            }
        }else{
            $productdetailObj = new cls_QuotesChange_PageRecordValueWX($this->module,'create','','',$this->action);
        }
        $entry = $productdetailObj->set_entrydetail($this->action,'',$relatedInfo);
        foreach($entry as $key=>$val){
            $this->jsonArr[$key] = $val;
        }
        return $this->jsonArr;
    }
    protected function get_DetailView(){
        $this->set_DetailView();
        crm_load_class_file('cls_QuotesChange_PageRecordValueWX','WeiXinApp/include/ProductDetailsHtml');
        //gyq170614
        //$productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($this->module,'',$this->record,'Products');
        $productdetailObj = new cls_QuotesChange_PageRecordValueWX($this->module,$this->productEntry_mode[$this->action],$this->record,'Products',$this->actionname);
        $entry = $productdetailObj->set_entrydetail($this->action,$this->outputProductFieldArr,null);
        foreach($entry as $key=>$val){
            $this->jsonArr[$key] = $val;
        }
        $this->DetailLastExtra();
        return $this->jsonArr;
    }  
}