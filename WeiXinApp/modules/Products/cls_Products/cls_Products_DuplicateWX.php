<?php
//微信产品管理查重，查询方法继承PC端
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');
class  cls_Products_DuplicateWX extends cls_ListViewWX
{
    public $wherecolum;
    public function get_page_query($showtype,$isSingle){
        global  $current_user;
        global $currentModule;
        $module = $currentModule;
        crm_load_class_file('DupSearch_ProductDetails',"modules/lingdang");
        crm_load_class_file('DupSearch_queryGenerator',"modules/lingdang");
        $productdetail_obj=DupSearch_ProductDetails::getInstance(($module);
        $this->obj_query = $querygenerator=DupSearch_queryGenerator::getInstance($module ,$current_user,$productdetail_obj,$productdetail_obj);
        $querygenerator->initForCustomViewById(0);
        $this->wherecolum=$querygenerator->getWhereClause(); 
        $this->order_by = $productdetail_obj->duplicate_orderby;
        $page_list_query = $this->page_list_query = $querygenerator->getQuery('',1);
        return $page_list_query;
    }
    
    public function get_listdetail($showtype='',$generatorName='')
    {
        global $adb,$viewid,$current_user;
        $this->set_listdetail("");
        $page_list_query = $this->page_list_query;
      
        $list_query = $this->list_query;
        if($this->mark_tab_main == 1){
            global $customView;
            $viewid = $customView->getViewIdByName('All',$this->module);
        }
        //微信产品管理查重，查询方法改为继承PC端  
        if(empty($this->customview)){
            $page_list_query2 = $page_list_query;
            $order_by = $this->order_by;
            // @edit:dong @date:2020/08/07 @reason: 没有排序导致pc查重和手机端查重结果不一致
            $page_list_query2 .= ' order by '.$order_by;
        }else{
            list($page_list_query2, $order_by, $sorder) = $this->customview->getOrderWhere($page_list_query);
        }
        $noofrows = $this->limitAccountsRowsBySetting($noofrows);
        $page_list_query = $this->page_list_query($noofrows, $page_list_query2, $order_by);

        $list_query = $list_query . '  inner join   ( ' . $page_list_query . '  ) as tmp on tmp.' . 
                $this->focus->table_index . '=' . $this->focus->table_name . '.' . $this->focus->table_index
                .$this->wherecolum.' order by '.$order_by.' '.$sorder;
        $list_result = $adb->pquery($list_query,array());
        $num_rows = $adb->num_rows($list_result);
        $_REQUEST['weixin_mark'] = 1; //微信端号码原样输出 gyqTE
        $this->jsonArr['search_reminds'] = $this->getSearchReminds();
        $result = $this->getListViewEntries($adb,$list_result,null);
        
        $sql_common = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type = 7';
        $result_common = $adb->pquery($sql_common,array($current_user->id));
        if($adb->num_rows($result_common)>0){
            $is_open = $adb->query_result($result_common,0,'is_open');
        } else{
            $is_open = 'yes';
        }
        $this->jsonArr['list1'] = $result;
        $this->jsonArr['high_search'] = $this->getHigheSearchField();
        
        $this->set_outputStyle("");
        return $this->jsonArr;

    }
}