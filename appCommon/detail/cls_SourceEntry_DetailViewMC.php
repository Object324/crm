<?php

/**
 * Created by PhpStorm.
 * User: gyq_27
 * Date: 2017/4/17 0017
 * Time: 下午 4:29
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_SourceEntry_DetailViewMC extends cls_DetailViewWX
{
    protected function get_CreateView()
    {
        $this->set_CreateView();
        crm_load_class_file('cls_TabDetail_PageRecordValueWX','WeiXinApp/include/TabDetailFields');
        /*$tabdetailObj = new cls_TabDetail_PageRecordValueWX($this->module,'','','');
        $tabdetail = $tabdetailObj->set_entrydetail($this->action);
        $this->jsonArr['math'] = $this->getSystemForPoint();
        $this->jsonArr['entry'] = $tabdetail;*/
        if(!empty($this->relatedCreationInfo)){
            $relatedInfo = $this->relatedCreationInfo;
            $relatedfocus=cls_Instance::get_module_Instance($relatedInfo['frommodule']);
            $relatedfocus->retrieve_entity_info($relatedInfo['fromid'],$relatedInfo['frommodule']);
            $productdetailObj = new cls_TabDetail_PageRecordValueWX($this->module,'sourcemodule_create',$relatedInfo['fromid'],$relatedInfo['frommodule'],$this->actionname);
            $productdetailObj->related_create = 'yes';
        }else{
            $productdetailObj = new cls_TabDetail_PageRecordValueWX($this->module,'','','',$this->actionname);
        }
        $entry = $productdetailObj->set_entrydetail($this->action);
        if(!empty($this->relatedCreationInfo))
        $productdetailObj->tabDetailFieldDataobj->row_mode = 'related_create';
         crm_load_class_file('cls_detailfieldrule','include/fields/fieldrule');
         $this->detailfieldruleobj=cls_detailfieldrule::getInstance($this->module);
         $fieldrulecolsproperty= $this->detailfieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
       
        $entry['detailfieldruleinfo']=$this->detailfieldruleobj->getFieldRuleProperty();
        $detailfieldrulecolumn=$this->detailfieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发明细字段;
        $entry['detailfieldrulefieldnames']=$detailfieldrulecolumn;
        $this->jsonArr['entry'] = $entry;
        $this->jsonArr['math'] = $this->getSystemForPoint();
        $this->jsonArr['buttonname']['adddetailbutton'] = getFixedLabel('NEW').getFixedLabel('DETAIL');
        $this->jsonArr['buttonname']['allremarks'] = getFixedLabel('TOTAL');
        
        return $this->jsonArr;
    }

    protected function get_DetailView()
    {
        $this->set_DetailView();
 
        crm_load_class_file('cls_TabDetail_PageRecordValueWX','WeiXinApp/include/TabDetailFields');
        $tabdetailObj = new cls_TabDetail_PageRecordValueWX($this->module,'edit',$this->record,'',$this->actionname);
        $tabdetail = $tabdetailObj->set_entrydetail( $this->action);
       
        if($this->action=='EditView'){
            $this->jsonArr['math'] = $this->getSystemForPoint();
            $this->jsonArr['buttonname']['adddetailbutton'] = getFixedLabel('NEW').getFixedLabel('DETAIL');
            $this->jsonArr['buttonname']['allremarks'] = getFixedLabel('TOTAL');
        }
         crm_load_class_file('cls_detailfieldrule','include/fields/fieldrule');
         $this->detailfieldruleobj=cls_detailfieldrule::getInstance($this->module);
         $fieldrulecolsproperty= $this->detailfieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
       
        $tabdetail['detailfieldruleinfo']=$this->detailfieldruleobj->getFieldRuleProperty();
        $detailfieldrulecolumn=$this->detailfieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发明细字段;
        $tabdetail['detailfieldrulefieldnames']=$detailfieldrulecolumn;
        $this->jsonArr['entry'] = $tabdetail;
        $this->DetailLastExtra();
        return $this->jsonArr;
    }
}