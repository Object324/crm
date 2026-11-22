<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
if(!empty($_REQUEST['fromapprovemodule'])){
    crm_load_class_file('cls_Approve_ListViewWX','WeiXinApp/modules/Approve/cls_Approve');
    crm_load_class_file('cls_Approve_CustomViewWX','WeiXinApp/modules/Approve/cls_Approve');
    global $approvestatus,$adb,$customView,$mobile_pagerecordcount;
    if(empty($_REQUEST['approvestatus'])){
        $approvestatus = 0;
    }else{
        $approvestatus = $_REQUEST['approvestatus'];
    }
    $arrapprove=array(0,1,2);
    if(!in_array($approvestatus,$arrapprove))
    {
        ConvertTojsonString('-1',null,getFixedLabel('PARAMETERINPUTERROR'));
    }
    $fromApproveModule = $_REQUEST['fromapprovemodule'];
    if(!vtlib_isModuleActive($fromApproveModule) || 'no' == isPermitted($fromApproveModule,'index')){
        ConvertTojsonString('-1',null,getFixedLabel('YOUDONOTHAVEMODULEOPERATIONRIGHTSAPP'));
    }
    $customView = new cls_Approve_CustomViewWX($fromApproveModule);
    if(isset($_REQUEST['viewid'])&& $_REQUEST['viewid']){
        $viewid = $_REQUEST['viewid'];
        $_REQUEST['viewname'] = $viewid;
    } else{
        //$viewid = $customView->getViewIdByName('All',$fromApproveModule);
        $viewid = $customView->getViewId($fromApproveModule);
    }
    //实例化列表SQL类
    $queryGenerator = new cls_Approve_ListViewWX($fromApproveModule);
    //$queryGenerator->setDisplayColumns($customView);
    $focus = $queryGenerator->focus;
    $list_query = $queryGenerator->getquery($fromApproveModule, $current_user,$customView);

    $page_list_query=$queryGenerator->getPageListQuery();
   
    $noofrows=$adb->num_rows($adb->pquery($page_list_query));
    $page = $_REQUEST['page'];
    $navigation_array = cls_StaticCommonFun::VT_getJsonSimpleNavigationValues($page,$fromApproveModule,$noofrows);
    $_REQUEST['start']=$navigation_array['startpagenum']+1;
    $startpagerecord=$navigation_array['startpagenum']*$mobile_pagerecordcount;
    list($page_list_query,$order_by,$sorder) = $customView->getOrderWhere($page_list_query);
    $list_query .= " inner join ( $page_list_query limit $startpagerecord,$mobile_pagerecordcount ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";
    list($list_query,$order_by,$sorder) = $customView->getOrderWhere($list_query,'',$queryGenerator);
    $list_result = $adb->pquery($list_query);
    $data  = null;
    if($approvestatus == 2){
        $table_name = $focus->table_name;
        $table_index = $focus->table_index;
        $query = "$page_list_query limit $startpagerecord,$mobile_pagerecordcount";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        for($i = 0; $i<$num_rows; $i++){
            $records[] = $adb->query_result($result,$i,0);
        }
        $query = "select approvestatus,$table_index from $table_name where $table_index in (".implode(',',$records).")";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        for($i = 0; $i<$num_rows; $i++){
            $record = $adb->query_result($result,$i,$table_index);
            $data[$record] = $adb->query_result($result,$i,'approvestatus');
        }
    }
    $jsonArray['list1']=$queryGenerator->getListViewEntries($adb,$list_result,$data);//查询数据内容
    $jsonArray['pagecount']=$navigation_array['totalpagecount'];
    $jsonArray['havenextpage']=$navigation_array['havenextpage'];
    $jsonArray['haveprevpage']=$navigation_array['haveprevpage'];
    $jsonArray['curpagenum']=$navigation_array['startpagenum']+1;
}
ConvertTojsonString(1,$jsonArray,'');
?>