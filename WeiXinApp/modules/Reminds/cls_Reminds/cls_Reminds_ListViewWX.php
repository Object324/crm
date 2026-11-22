<?php
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');
class  cls_Reminds_ListViewWX extends cls_ListViewWX
{
    //联系人模块获取查询手机号码的查询语句 gyq_32
    protected function get_phone_sql($focus,$list_query){
        return $list_query;
    }

    public function setreturnJson_listContent()
    {

    }
}