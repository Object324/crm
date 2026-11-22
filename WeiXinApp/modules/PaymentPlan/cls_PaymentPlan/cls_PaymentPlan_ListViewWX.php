<?php

crm_load_class_file('cls_ListViewWX','WeiXinApp/list');
class cls_PaymentPlan_ListViewWX extends cls_ListViewWX
{
    public function get_page_query($showtype,$isSingle){
        $page_list_query = parent::get_page_query($showtype,$isSingle);
        //zxm 1222 PaymentPlan_计划收款日期
        if(!empty($_REQUEST['plandate'])){
            $page_list_query .= " and ".$_REQUEST['plandate'];
        }
        return $page_list_query;
    }
}