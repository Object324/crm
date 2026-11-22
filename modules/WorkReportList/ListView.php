<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule, $theme, $languageType;
global $list_max_entries_per_page_new;
global $current_user, $adb;

//wym 230605 获取该模块列表最多条数
//wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
$list_max_entries_per_page_new=getUsersettingByLabel($currentModule,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($currentModule,1,'MaxEntriesPerPage');
$list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;
if (isset($_REQUEST['SearchScope']) && $_REQUEST['SearchScope'] != '') {
    //越权访问
    $ScopOfAuthority = ScopOfAuthority::getInstance($adb, $currentModule);
    $ScopOfAuthority->isCorrectSearchScope($_REQUEST['SearchScope']);
}
if (isset($_REQUEST['senioruserid'])) {
    //越权访问
    $ScopOfAuthority = ScopOfAuthority::getInstance($adb, $currentModule);
    $userids = explode(',', $_REQUEST['senioruserid']);
    for ($i = 0; $i < sizeof($userids); $i++) {
        $ScopOfAuthority->isCorrectSearchScope($userids[$i]);
    }
}

crm_load_function_file('VT_getSimpleNavigationValues', 'include/utils', 'ListViewUtils');
crm_load_class_file('Inventory', 'data');

$smarty = new lingdangCRM_Smarty();
$url_string = '';
$stockquery = '';

$focus = CRMEntity::getInstance($currentModule);
//$focus->initSortbyField($currentModule);

/* 列表按钮 begin */
$focus->getModuleLogic($currentModule)->getListViewButtons();
$smarty->assign('LISTBUTTON', $focus->logic->list_buttons);

$MergeSmowner = getCurSmOwnerSearchScope($currentModule);//只保留 全部和我创建的（即我发起的）
if (is_array($MergeSmowner)){
    unset($MergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
//    unset($MergeSmowner["UserCombo"]);
//    unset($MergeSmowner["OtherInfo"]['smowner_search_senior']);
    unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Me']);
    unset($MergeSmowner["OtherInfo"]['SmOwer_Search_ShareMe']);
    unset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']);
}
// ljj 20231030 XUQIU1002070 工作汇报（列表）查看范围优化1、查看范围下拉框内增加分类“抄送给我的”
//工作汇报列表添加分类'抄送给我的'
$MergeSmowner["OtherInfo"]['SmOwer_Search_CopyToMe'] = array(getFixedLabel('COPYFORME')=>'');
//20240305 hzx XUQIU20240112-01 查询分类显示优化（仿腾讯云），一行显示4个，点击出现弹出层注：注意区分普通、悬浮、选中状态
if(count($MergeSmowner) > 0){
    $SmOwner_option_arr = [];
    $showviewrange = false;
    foreach($MergeSmowner as $User_Key => $User_value){
        foreach($User_value as $User_id => $User_name){
            foreach($User_name as $User_name_key => $User_name_value){
                $SmOwner_option_arr[] = array('label'=>$User_name_key,'value'=>$User_id);
                if($User_id == 'smowner_search_senior'){
                    $showviewrange = true;
                }
            }
        }
    }
    if($showviewrange == true){
        $smarty->assign('showviewrange',$showviewrange);
    }
}else{
    $SmOwner_option_arr = [];
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));

$fieldobj = $focus->fieldobj;
$smarty->assign('FIELDOBJ', $fieldobj);

//$smarty->assign('CUSTOM_MODULE', $focus->IsCustomModule);
$smarty->assign('Merge_SmOwner', $MergeSmowner);
$smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);

$smarty->assign('MODULE', $currentModule);
//$smarty->assign('SINGLE_MOD', getTranstab($currentModule));
$smarty->assign('CATEGORY', $category);


//$smarty->assign('CHECK', $tool_buttons);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");


$logtype = $focus->workreport_logtype;
$smarty->assign('ALLLOGTYPE',$logtype);


// Custom View
$customView = CustomView::getInstance($currentModule);
if(isset($_REQUEST['workreport_logtype'])&&$_REQUEST['workreport_logtype']!=""){

    $workreport_logtype = $_REQUEST['workreport_logtype'];
    $_SESSION['lvs'][$currentModule]['workreport_logtype'] = $workreport_logtype;
}else if(isset($_SESSION['lvs'][$currentModule]['workreport_logtype'])&&$_SESSION['lvs'][$currentModule]['workreport_logtype']!=""){
    $workreport_logtype = $_SESSION['lvs'][$currentModule]['workreport_logtype'];
}else{
    $workreport_logtype = '0';
}


// @edit:dong @date:2020/10/28 @reason: 数据分类设置为自定义链接模块
if (isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] == 'ld_linkmodulecustom') {
    $smarty->assign('LINKMODULECUSTOM', true);
}
/*
edit:Can
date:20130605
reason:4067: 视图中：排序功能失效。
*/
if (isset($_REQUEST["selectedColumnsString2"])) {
    include("modules/lingdang/ViewOrderEditSave.php");

}
//BUG20240428-02 工作汇报（列表），在‘日志’页签下进行查询，跳出来的列表是‘全部’的列表
if(isset($_REQUEST['ajaxtype']) && $_REQUEST['ajaxtype'] =='ld_linkmodulecustom'){
    $smarty->assign('LINKMODULECUSTOM', true);
}

$viewid = $customView->getViewId($currentModule);
$viewname = $customView->getViewNameDetail($viewid);
if($viewname == 'All'){
    $viewname = getFixedLabel('ALL');
}
$smarty->assign("VIEWID", $viewid);
$smarty->assign("VIEWNAME", $viewname);
$smarty->assign('workreport_logtype', $workreport_logtype);//当前所选页签，默认全部

$Navbarlist = [];
$Navbarlistcur = 0;
foreach ($logtype as $tmptype=>$tmpvalue)
{
    $Navbarlist[] =  array(
        'value'=>$tmptype,
        'label'=>$tmpvalue
    );
}

$smarty->assign('ListViewNavbarcur',$workreport_logtype);
$smarty->assign('ListViewNavbarlist',json_encode($Navbarlist));

//视图hTML
$customview_html = $customView->getCustomViewAll($viewid, $module, $category);
//@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化
//获取查询分类分组列表
$groupList=$customView->getCustomViewGroupList($customview_html);
$smarty->assign("CUSTOMVIEWGROUPLIST",$groupList);

//前五个数据分类
//$customview_html_before = $customView->getCustomViewCombo2Before($viewid,$module,$category);

//$edit_permit = $customView->isPermittedCustomView($viewid,'Create',$currentModule);
//$delete_permit = $customView->isPermittedCustomView($viewid,'Delete',$currentModule);

//$smarty->assign("CUSTOMVIEW_PERMISSION",$statusdetails);
//$smarty->assign("CV_EDIT_PERMIT",$edit_permit);
//$smarty->assign("CV_DELETE_PERMIT",$delete_permit);


//by LD tifa 20130104 bug0003118
/*
edit:can
date:20130426
reason:记住上次查询范围

*/
if ($_REQUEST['senioruserid'] != "") {
    $_SESSION['lvs'][$currentModule]['senioruserid'] = $_REQUEST['senioruserid'];
}
if ($_SESSION['lvs'][$currentModule]['senioruserid'] != "") {
    $smarty->assign("senioruserid", $_SESSION['lvs'][$currentModule]['senioruserid']);
}
if ($_REQUEST['SearchScope'] != null && $_REQUEST['SearchScope'] != '') {
    $SearchScope = $_REQUEST['SearchScope'];
    $_SESSION['lvs'][$currentModule]['SearchScope'] = $SearchScope;

    $smarty->assign('SelectedOwner2', $_REQUEST['SearchScope']);

} else if (isset($_SESSION['lvs'][$currentModule]['SearchScope']) && $_SESSION['lvs'][$currentModule]['SearchScope'] != null) {
    $smarty->assign('SelectedOwner2', $_SESSION['lvs'][$currentModule]['SearchScope']);

} else {
    $SearchScope = "SmOwner_Search_All";
    $_SESSION['lvs'][$currentModule]['SearchScope'] = $SearchScope;
    $smarty->assign('SelectedOwner2', "SmOwner_Search_All");
}
//获取批量操作时记录数上限
$deployarray = getSys_deploy(67);
$smarty->assign('BATCHNUM', $deployarray['deploy_value']);
$viewname = $customView->getViewNameDetail($viewid);
$smarty->assign('ALL', $viewname);
if ($viewname == 'All') {
    $viewname = getFixedLabel('ALL');
}
$smarty->assign("VIEWNAME", $viewname);

if ($viewid == 0) {
    include(globalStatic::$root_directory . "modules/lingdang/ExitWithoutPermission.php");
    exit;
}


$queryGenerator = QueryGenerator::getInstance($currentModule, $current_user, $customView);
/**
 * query_session=1时，读取session中的搜索条件，否则将清空session
 * 查看页面返回列表、列表编辑之后保存 返回列表时，返回query_session=1的参数
 * @project 序时簿查询记住搜索条件
 * @author Tujt 2014-04-25
 */
if (isset($_REQUEST['query_session']) && $_REQUEST['query_session'] == '1'
    && isset($_SESSION['LiveViewSearch'][$currentModule])) {
    $input = $_SESSION['LiveViewSearch'][$currentModule]['input'];
    global $search_session;
    $search_session = 1;
    if ($input['searchtype'] == 'BasicSearch') {
        if (!empty($input['search_text'])) {
            $_REQUEST['search_field'] = $input['search_field'];
            $_REQUEST['search_text'] = $input['search_text'];
            $_REQUEST['SearchScope'] = $input['SearchScope'];
            $_REQUEST['searchtype'] = $input['searchtype'];
            $_REQUEST['type'] = $input['type'];
        } else {
            $search_session = 0;
            unset($_SESSION['LiveViewSearch'][$currentModule]);
        }
        // @edit:dong @date:2020/08/24 @reason: 添加平铺查找
    } else if ($input['searchtype'] == 'advance' || $input['searchtype'] == 'tiled') {
        if (!empty($input['advft_criteria']) && $input['advft_criteria'] != '[]') {
            $_REQUEST['advft_criteria'] = $input['advft_criteria'];
            $_REQUEST['advft_criteria_groups'] = $input['advft_criteria_groups'];
            $_REQUEST['SearchScope'] = $input['SearchScope'];
            $_REQUEST['searchtype'] = $input['searchtype'];
            //初始化搜索条件
            $json = new Zend_Json();
            $advft_criteria = $json->decode($input['advft_criteria']);

            $advft_criteria_groups = $json->decode($input['advft_criteria_groups']);
            $advfilterlist = getAdvancedSearchCriteriaList($advft_criteria, $advft_criteria_groups, $currentModule, $queryGenerator);
            $smarty->assign('CRITERIA_GROUPS', $advfilterlist);
        } else {
            $search_session = 0;
            unset($_SESSION['LiveViewSearch'][$currentModule]);
        }
    }
    if ($search_session == 1) {
        $smarty->assign('SEATCH_INPUT', $input);
        $smarty->assign('SEARCH_URL', $_SESSION['LiveViewSearch'][$currentModule]['url']);
        $_REQUEST['query'] = 'true';
    }
} else {
    unset($_SESSION['LiveViewSearch'][$currentModule]);
}
///得到对应视图的查询字段
if ($viewid != "0") {
    $queryGenerator->initForCustomViewById($viewid);
} else {
    $queryGenerator->initForDefaultCustomView();
}
$smarty->assign("LISTPAGEURL", getlisturl_aftersave());
// Enabling Module Search
Crm_load_class_file("CommonView", "modules/CustomView");
$smarty->assign("DATETIMESTR", json_encode(CommonView::stdFilterDateTimeStr()));

$url_string = '';
if ($_REQUEST['query'] == 'true') {

    $_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
    $queryGenerator->addUserSearchConditions($_REQUEST);
    /**
     * query=true时 把搜索参数存入session中
     * @project 序时簿查询记住搜索条件
     * @author Tujt 2014-04-25
     */
    if ($_REQUEST['searchtype'] == 'BasicSearch') {
        $_REQUEST['search_text'] = trim($_REQUEST['search_text']);
        $searcharr = explode(':', $_REQUEST['search_field']);
        //18399: 回款计划、付款计划、收款单、付款单、费用报销单、佣金单、提现单、存现单-序列表界面：基本查找，按照金额等于0查找，结果基本查找区块会自动收起
        if ($_REQUEST['search_text'] != '' || (empty($_REQUEST['search_text']) && 'D' == $searcharr[count($searcharr) - 1])) {
            $input['search_field'] = trim($_REQUEST['search_field']);
            $input['search_text'] = trim($_REQUEST['search_text']);
            $input['SearchScope'] = trim($_REQUEST['SearchScope']);
            $input['searchtype'] = trim($_REQUEST['searchtype']);
            $input['type'] = trim($_REQUEST['type']??'');
        } else {
            unset($_SESSION['LiveViewSearch'][$currentModule]);
        }
        // @edit:dong @date:2020/08/24 @reason: 平铺搜索
    } else if ($_REQUEST['searchtype'] == 'advance' || $_REQUEST['searchtype'] == 'tiled') {
        $_REQUEST['advft_criteria'] = trim($_REQUEST['advft_criteria']);
        if (!empty($_REQUEST['advft_criteria']) && $_REQUEST['advft_criteria'] != '[]') {
            $input['advft_criteria'] = $_REQUEST['advft_criteria'];
            $input['advft_criteria_groups'] = trim($_REQUEST['advft_criteria_groups']);
            $input['SearchScope'] = trim($_REQUEST['SearchScope']);
            $input['searchtype'] = trim($_REQUEST['searchtype']);
        } else {
            unset($_SESSION['LiveViewSearch'][$currentModule]);
        }
    }
    ////上一页和下一页点击使用使用
    $ustring = getSearchURL($_REQUEST);
    $url_string .= "&query=true$ustring";
    $smarty->assign('SEARCH_URL', $url_string);

    if (!empty($input)) {
        $_SESSION['LiveViewSearch'][$currentModule]['input'] = $input;
        $_SESSION['LiveViewSearch'][$currentModule]['url'] = $url_string;
        $smarty->assign('SEATCH_INPUT', $input);
    }
}

$page_list_query = $queryGenerator->getQuery('', 'groupby');
$list_query = $queryGenerator->getQuery('', 2);
//dump($list_query);

$ChartFrom = str_replace(' ', '//B/', $queryGenerator->page_left_join . $queryGenerator->gettabshareSql());//$queryGenerator->getChartFrom()
$ChartFrom = str_replace("'", "//,/", $ChartFrom);
$ChartFrom = str_replace("%'", "//,,/", $ChartFrom);
$ChartFrom = str_replace('"', '', $ChartFrom);


$ChartWhere = str_replace('<', '//lt/', $queryGenerator->getChartWhere());
$ChartWhere = str_replace(' ', '//B/', $ChartWhere);
$ChartWhere = str_replace("'", "//,/", $ChartWhere);
$ChartWhere = str_replace(">", "//tgt/", $ChartWhere);
//bug 23792 edit cyb date:2016-07-28 替换掉"%";
$ChartWhere = str_replace("%", "//lk/", $ChartWhere);//%
$ChartWhere = str_replace("<=", '//lteq/', $ChartWhere);//<=

$ChartOwner = str_replace(' ', '//B/', $queryGenerator->getChartOwner());
$smarty->assign('CHARTFROM', $ChartFrom);
$smarty->assign('CHARTWHERE', $ChartWhere);
$smarty->assign('CHARTOWNER', $ChartOwner);
$where = $queryGenerator->getConditionalWhere();
//$queryGenerator->getQueryRow_Count()
$count_sql = $queryGenerator->getQueryRow_Count('', 'groupby');
$LIST_NOCHECKBOX = 'yes';

$count_result = $adb->query($count_sql);
if (!empty($count_result))
    $noofrows = $adb->query_result($count_result, 0, 0);
else
    $noofrows = null;


if (empty($order_by)) {
    $orderModArr = array('InventoryAccount' => 1, 'InventoryQuery' => 1, 'Checks' => 1);
    if (isset($orderModArr[$module])) {
        $stockquery = $queryGenerator->isStockQuery($module);
        $page_list_query .= $stockquery;

        $order_by = ' ld_warehousecondtions.operationtime ';
    } else {

        list($page_list_query, $order_by, $sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);

    }
}

ListViewSession::setSessionQuery($currentModule, $page_list_query, $viewid);


$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);

$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new, $noofrows);
$table_id_index = $focus->table_index;

$limit_start_rec = ($start - 1) * $list_max_entries_per_page_new;
$list_query .= ' inner join ( ' . $page_list_query . " LIMIT $limit_start_rec, $list_max_entries_per_page_new ) as tmp
             on tmp.$table_id_index=" . $focus->table_name . '.' . $table_id_index;
//echo($list_query);
list($list_query, $order_by, $sorder) = $queryGenerator->customview->getOrderWhere($list_query, '', $queryGenerator);
//echo($list_query);
$list_result = $adb->pquery($list_query, array());
//dump($list_query);
$recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec, $noofrows);
/**
 * edit:can
 * date:20131212
 * reason:5648: 序时簿全选功能异常：需要选两次，才能出现 全选小页签
 * */
$smarty->assign('recordListRange', $recordListRangeMsg);
$smarty->assign('NUMOFROWS', $noofrows);
$smarty->assign("CUSTOMVIEW_OPTION", $customview_html);
//$smarty->assign("CUSTOMVIEW_OPTION_BEFORE",$customview_html_before);

// Navigation
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string, $currentModule, 'index', $viewid);
$smarty->assign("NAVIGATION", $navigationOutput);

//hzx 20231207 XUQIU1002273 PC端模块列表界面，分页样式优化
$smarty->assign("TABNAME", getParentTab());
$smarty->assign("STARTPAGE", ceil($start));
$smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
$smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$list_max_entries_per_page_new));
$smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($list_max_entries_per_page_new)));

$controller = new ListViewController($adb, $current_user, $queryGenerator);


if ($currentModule == 'Reminds') {
    $skipAction = false;//edit:can reaosn:12564: 提醒叙事簿界面：序列表中多显示了一列“操作列”-如图，1024*768
}
//得到列头
$listview_header = $controller->getListViewHeader($focus, $currentModule, $url_string, $sorder, $order_by, $skipAction);

$listview_entries = $controller->getListViewEntries($focus, $currentModule, $list_result, $navigation_array, false);


$listview_header_search = $controller->getBasicSearchFieldInfoList();

//菜单查询和立即查找的数据
$smarty->assign('LISTHEADER', $listview_header);
$smarty->assign("HEADERNAME", $controller->headername);
//$smarty->assign('LISTENTITY', $listview_entries);
//合并列
$smarty->assign('LISTHEADERCOUNT', count($listview_header) + 1);

$smarty->assign('SEARCHLISTHEADER',$listview_header_search);

// Module Search//拼音查找
//$alphabetical = AlphabeticalSearch($currentModule,'index',$focus->def_basicsearch_col,'true','basic','','','','',$viewid);
$fieldnames = $controller->getAdvancedSearchOptionString();
//$criteria = getcriteria_options();
$smarty->assign("ALPHABETICAL", $alphabetical);
$smarty->assign("FIELDNAMES", $fieldnames);
$smarty->assign("CRITERIA", $criteria);

//Added to select Multiple records in multiple pages
$smarty->assign("SELECTEDIDS", vtlib_purify($_REQUEST['selobjs']));
$smarty->assign("ALLSELECTEDIDS", vtlib_purify($_REQUEST['allselobjs']));
$smarty->assign('IS_ADMIN', is_admin($current_user));

$languageType = getLanguageType($current_user);
$smarty->assign("LANUGAGETYPE", $languageType);
/**
 * 每列宽度的信息
 * edit:can 20200720
 * */
$smarty->assign("FieldWidthSetting", ldcrm_json_encode($controller->getModuleViewFieldsWidth()));

//获取列表操作列按钮名称总汇，并返回宽度
$operationWidth = $focus->getModuleLogic($currentModule)->getListButtomName();
$widthinfo = getModuleWidth($focus, $controller->getModuleViewFieldsWidth(), $currentModule);
$smarty->assign('LISTHEADERWIDTH', $widthinfo);
$total_width = $controller->getListTotalWidth($widthinfo, $operationWidth);
$smarty->assign('TOTALWIDTH', $total_width);
$smarty->assign('OPERATIONWIDTH', $operationWidth);
$smarty->assign("CHKBOXWIDTH", $controller->listchkbox_width);

$VersionInfo = getVersionInfo();
$smarty->assign('VERSION_ACCOUNT', $VersionInfo['account']);

//库存流水账列表没有操作列
if ($currentModule == 'InventoryAccount') {
    $colspan_count = sizeof($listview_header);//没有内容时，合并列
} else {
    $colspan_count = sizeof($listview_header) + 1;
}

// 列表页数据
$smarty->assign('DEAILHTML',Inventory::createHTML($listview_entries,$currentModule,0,$colspan_count,$focus->logic->list_buttons,$controller,$LIST_NOCHECKBOX));
setGLobalURLSmarty($smarty);//设置js,css等访问路径

$fields = $focus->fieldobj->getListViewFields();
$smarty->assign('FIELDINFOJSON', ldcrm_json_encode($fields['fields']));
$smarty->assign('MODULEBILLNOTIP', $_SESSION[$currentModule . '_modulebillnotip']);
$_SESSION[$currentModule . '_modulebillnotip'] = 'no';
// @edit:dong @date:2020/08/19 @reason: 查找 用于区分搜索类型
$smarty->assign('SEARCHTYPE', $_REQUEST['searchtype']);

//zkt 2021/12/27 用于区分是否显示平铺搜索界面
if (isset($_REQUEST['tiledSearchdisplay']) && $_REQUEST['tiledSearchdisplay'] == 'none') {
    $smarty->assign('SHOWtiledSearch', 'no');
}
//zkt 2021/12/28 平铺查找条件保存在数据库
$sql = 'select id,searchvalue from ld_searchhistory where modulename = ? and smownerid = ? and searchtype = ? order by searchtime desc';
$result = $adb->pquery($sql, array($currentModule, $current_user->id, 'tiled'));
$num_rows = $adb->num_rows($result);
$tiledSearch = '';
if ($num_rows > 0) {
    $tiledSearch = $adb->query_result($result, 0, 'searchvalue');
}
$smarty->assign("tiledSearch", html_entity_decode($tiledSearch));

// ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
$cls_MyCRMcryptobj=new cls_MyCRMcrypt();
$smarty->assign("Encrypt_TreeWhere",$cls_MyCRMcryptobj->encode($queryGenerator->getSqlNoTreeWhere($page_list_query)));

//xll 20221214 获取最近一次的基本搜索框字段选项
$controller->getFieldStorage($smarty);

//zxm 20230614 获取列表页面公共参数并assign到tpl
ListViewCommonAssign($currentModule,$smarty,$focus);



if (isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '') {
    $smarty->display("ListViewEntries.tpl");
} else {
    $smarty->display('ListView.tpl');
}


?>