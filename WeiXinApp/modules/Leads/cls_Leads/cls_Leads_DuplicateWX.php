<?php
crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
class  cls_Leads_DuplicateWX extends cls_ListViewWX
{
    public function get_page_query($showtype, $isSingle)
    {
        global $current_user;
        crm_load_class_file ('DupSearch_ProductDetails',"modules/lingdang");
        crm_load_class_file ('DupSearch_queryGenerator',"modules/lingdang");
        $module = $this->module;
        $productdetail_obj = DupSearch_ProductDetails::getInstance($module);
        $this->obj_query = $querygenerator = DupSearch_queryGenerator::getInstance($module, $current_user, $productdetail_obj, $productdetail_obj);
        if ($_REQUEST['action'] == 'duplicate_related_popu_multifields') {
            $mixedDisplayColumns = array();
            //wym 240416 查重类文件结构优化
            crm_load_class_file('cls_DuplicateColumn','modules/lingdang');
            $duplicate_obj=cls_DuplicateColumn::getInstance($module);
            $duplicate_obj->judgeBlacklist();
            $productdetail_obj->blackcolumnarray = $duplicate_obj->blackcolumnarr;
            $productdetail_obj->getpermission = $duplicate_obj->permit;
        }
        $querygenerator->initForCustomViewById(0);
        $this->order_by = $productdetail_obj->duplicate_orderby;
        $page_list_query = $this->page_list_query = $querygenerator->getQuery('', 1);
        return $page_list_query;
    }
}
?>