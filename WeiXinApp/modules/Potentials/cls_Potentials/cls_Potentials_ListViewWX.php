<?php

crm_load_class_file('cls_ListViewWX','WeiXinApp/list');
class cls_Potentials_ListViewWX extends cls_ListViewWX
{
    public function get_page_query($showtype,$isSingle){
        $page_list_query = parent::get_page_query($showtype,$isSingle);
        //zxm 1224 预期成交时间
        if(!empty($_REQUEST['closingdate'])){
            $page_list_query .= " and ".$_REQUEST['closingdate'];
        }
        return $page_list_query;
    }
}