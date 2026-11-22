<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/4/18 0018
 * Time: 上午 11:58
 */
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');
class cls_PublicAnnouncement_ListViewWX extends cls_ListViewWX
{
    public function get_listdetail($showtype='',$generatorName='')
    {
        global $adb;
        $this->set_listdetail($showtype);
        $page_list_query = $this->page_list_query;
        $list_query = $this->list_query;
        if($this->mark_tab_main == 1){
            global $customView,$viewid;
            $viewid = $customView->getViewIdByName('All',$this->module);
        }
        //BUG0071272 liushuai 20230818 通知邮件模块，电脑端显示列表正确，移动端显示列表不对.
        list($page_list_query2, $order_by, $sorder) = $this->customview->getOrderWhere($page_list_query);
        $count_result = $adb->query($page_list_query);
        if (!empty($count_result))
            $noofrows = $adb->num_rows($count_result);
        else
            $noofrows = null;
        $page_list_query = $this->page_list_query($noofrows, $page_list_query2, $order_by);
        //$list_query = $list_query . '  inner join   ( ' . $page_list_query . '  ) as tmp on tmp.' . $this->focus->table_index . '=' . $this->focus->table_name . '.' . $this->focus->table_index . ' order by ' . $order_by;
        $list_query =$page_list_query;

        $list_result = $adb->pquery($list_query,array());
        $num_rows = $adb->num_rows($list_result);
        $_REQUEST['weixin_mark'] = 1; //微信端号码原样输出 gyqTE
        $this->jsonArr['search_reminds'] = $this->getSearchReminds();//gyq_32
        $this->jsonArr['list1'] = $this->getListViewEntries($adb,$list_result,null);
        $this->jsonArr['high_search'] = $this->getHigheSearchField();
        $this->set_outputStyle();
        return $this->jsonArr;
    }

}