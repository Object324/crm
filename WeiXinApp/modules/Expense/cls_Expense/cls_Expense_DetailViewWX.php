<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_SourceEntry_DetailViewWX', 'WeiXinApp/detail');
class cls_Expense_DetailViewWX extends cls_SourceEntry_DetailViewWX
{

}
/*crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_Expense_DetailViewWX extends cls_DetailViewWX
{
    protected function get_CreateView()
    {
        $this->set_CreateView();
        crm_load_class_file('TabDetailFieldsDataWX','WeiXinApp/WeiXin_CustomView');
        $this->jsonArr['math']=$this->getSystemForPoint();
        $TabDetailFieldsData = new TabDetailFieldsDataWX($this->focus,$this->module);
        $this->jsonArr['listexpensefield'] = $TabDetailFieldsData->getJsonTabDetailFields();
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $tabid = getTabid($this->module);
        $TabDetailFields = new TabDetailFields($tabid);
//获取状态为不显示并且有字段公式的自定义字段
        $this->jsonArr['nopresenceproductfield']=$TabDetailFields->getNoPresenceInputDetailField();
//字段公式
        $this->jsonArr['listformulafield']['fields']=$TabDetailFields->getTabDetailFormulaField();
        $this->DetailLastExtra();
        return $this->jsonArr;
    }

    protected function get_DetailView()
    {
        $this->set_DetailView();
        crm_load_class_file('TabDetailFieldsDataWX','WeiXinApp/WeiXin_CustomView');
        $this->jsonArr['math']=$this->getSystemForPoint();
        $TabDetailFieldsData = new TabDetailFieldsDataWX($this->focus,$this->module);
        $this->jsonArr['listexpensefield'] = $TabDetailFieldsData->getJsonTabDetailFields();
        $this->jsonArr['listexpense']=$TabDetailFieldsData->getJsonTabDetailInfo();
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $tabid = getTabid($this->module);
        $TabDetailFields = new TabDetailFields($tabid);
//获取状态为不显示并且有字段公式的自定义字段
        $this->jsonArr['nopresenceproductfield']=$TabDetailFields->getNoPresenceInputDetailField();
//字段公式
        $this->jsonArr['listformulafield']['fields']=$TabDetailFields->getTabDetailFormulaField();

        $this->DetailLastExtra();

        return $this->jsonArr;
    }
}*/