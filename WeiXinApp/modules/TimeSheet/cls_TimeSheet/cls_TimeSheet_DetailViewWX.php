<?php

/**
 * Created by PhpStorm.
 * User: gyqCom0314
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_SourceEntry_DetailViewWX', 'WeiXinApp/detail');
class cls_TimeSheet_DetailViewWX extends cls_SourceEntry_DetailViewWX
{

}
/*crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_TimeSheet_DetailViewWX extends cls_DetailViewWX
{
    protected function get_CreateView()
    {

    }

    protected function get_DetailView()
    {
        $this->set_DetailView();
        crm_load_class_file('cls_TabDetailFieldsHtmlWX','WeiXinApp/include/TabDetailFields');
        $cls_TabDetailFieldsHtmlWX = new cls_TabDetailFieldsHtmlWX($this->focus,$this->module);
        $this->jsonArr['detailextra'] = $cls_TabDetailFieldsHtmlWX->getTabDetailHtmlContent();

        $this->DetailLastExtra();
        return $this->jsonArr;
    }
}*/