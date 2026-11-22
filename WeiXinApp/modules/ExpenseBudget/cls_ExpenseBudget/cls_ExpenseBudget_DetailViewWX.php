<?php

crm_load_class_file('cls_SourceEntry_DetailViewWX', 'WeiXinApp/detail');
class cls_ExpenseBudget_DetailViewWX extends cls_SourceEntry_DetailViewWX
{

    //初始化详情页是否有编辑、分配、删除等按钮
    protected function init_detailButton()
    {
        parent::init_detailButton();
        $toRemove = ["edit", "copy"];
        $result = array_diff($this->jsonArr['list2'], $toRemove);
        $this->jsonArr['list2'] = array_merge($result);
    }
}