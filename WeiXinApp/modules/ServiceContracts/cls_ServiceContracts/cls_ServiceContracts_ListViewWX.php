<?php

crm_load_class_file('cls_ListViewWX','WeiXinApp/list');

class cls_ServiceContracts_ListViewWX extends cls_ListViewWX
{
    public function get_page_query($showtype,$isSingle){
        $page_list_query = parent::get_page_query($showtype,$isSingle);

        return $page_list_query;
    }
}