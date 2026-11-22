<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
//D:\wamp\www\ldcrm\WeiXinApp\detail\cls_SourceEntry_DetailViewWX.php
crm_load_class_file('cls_SourceEntry_DetailViewWX', 'WeiXinApp/detail');
class cls_Commission_DetailViewWX extends cls_SourceEntry_DetailViewWX
{
    protected function get_CreateView_Old_WaitDelete()
    {
        $this->set_CreateView();
        crm_load_class_file('cls_TabDetail_PageRecordValueWX','WeiXinApp/include/TabDetailFields');
        $tabdetailObj = new cls_TabDetail_PageRecordValueWX($this->module,'','','',$this->actionname);
        $tabdetail = $tabdetailObj->set_entrydetail($this->action);
        $this->jsonArr['math'] = $this->getSystemForPoint();
        $this->jsonArr['entry'] = $tabdetail;
        /* crm_load_class_file('TabDetailFieldsDataWX','WeiXinApp/WeiXin_CustomView');
         $this->jsonArr['math']=$this->getSystemForPoint();
         $TabDetailFieldsData = new TabDetailFieldsDataWX($this->focus,$this->module);
         $this->jsonArr['listcommissionfield'] = $TabDetailFieldsData->getJsonTabDetailFields();
         crm_load_class_file('TabDetailFields','include/TabDetailFields');
         $tabid = getTabid($this->module);
         $TabDetailFields = new TabDetailFields($tabid);
 //获取状态为不显示并且有字段公式的自定义字段
         $this->jsonArr['nopresenceproductfield']=$TabDetailFields->getNoPresenceInputDetailField();
 //字段公式
         $this->jsonArr['listformulafield']['fields']=$TabDetailFields->getTabDetailFormulaField();
         $this->DetailLastExtra();*/
        return $this->jsonArr;
    }

    protected function get_DetailView_Old_WaitDelete()
    {
        $this->set_DetailView();
        crm_load_class_file('cls_TabDetail_PageRecordValueWX','WeiXinApp/include/TabDetailFields');
        $tabdetailObj = new cls_TabDetail_PageRecordValueWX($this->module,'edit',$this->record,'',$this->actionname);
        $tabdetail = $tabdetailObj->set_entrydetail($this->action);
        if($this->action=='EditView'){
            $this->jsonArr['math'] = $this->getSystemForPoint();
        }
        $this->jsonArr['entry'] = $tabdetail;
        $this->DetailLastExtra();
       /* crm_load_class_file('TabDetailFieldsDataWX','WeiXinApp/WeiXin_CustomView');
        $this->jsonArr['math']=$this->getSystemForPoint();
        $TabDetailFieldsData = new TabDetailFieldsDataWX($this->focus,$this->module);
        $this->jsonArr['listcommissionfield'] = $TabDetailFieldsData->getJsonTabDetailFields();
        $this->jsonArr['listcommission']=$TabDetailFieldsData->getJsonTabDetailInfo();
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $tabid = getTabid($this->module);
        $TabDetailFields = new TabDetailFields($tabid);
//获取状态为不显示并且有字段公式的自定义字段
        $this->jsonArr['nopresenceproductfield']=$TabDetailFields->getNoPresenceInputDetailField();
//字段公式
        $this->jsonArr['listformulafield']['fields']=$TabDetailFields->getTabDetailFormulaField();
        $this->DetailLastExtra();*/
        return $this->jsonArr;
    }
}
?>