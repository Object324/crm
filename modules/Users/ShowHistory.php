<?php
require_once(globalStatic::$root_directory.'modules/Users/LoginHistory.php');
global $app_strings;
global $mod_strings;
global $app_list_strings;
global $current_language, $current_user, $adb;
global $list_max_entries_per_page_new;
global $urlPrefix;
global $currentModule;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$focus = new LoginHistory();

$smarty = new lingdangCRM_Smarty;

$category = getParenttab();
//editor:gyq_92 reason:系统设置登录日志查询增加分类功能  2018/12/21 10:43
$no_of_rows = $focus->get_loginlog_page_number( $_REQUEST['record'],$_REQUEST['login_type']);
//Retreiving the start value from request
if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
	$start = vtlib_purify($_REQUEST['start']);
} else {
	$start=1;
}
if (isset($_REQUEST['pagecount'])){
    $pagecount = $_REQUEST['pagecount'];
    setUsersettingByLabel('Settings',$current_user->id,'ShowHistoryListPageNum',$pagecount);
}else{
    $pagecount = getUsersettingByLabel('Settings',$current_user->id,'ShowHistoryListPageNum');
    if (empty($pagecount)){
        $pagecount = $list_max_entries_per_page_new;
    }
}

//17116: 控制面板>登录日志：列表条数没有根据系统参数【设置序时簿列表每页显示记录的条数】控制。
crm_load_function_file('getNavigationValues','include/utils','ListViewUtils');
$navigation_array = getNavigationValues($start, $no_of_rows, $pagecount);
//$record_string= getFixedLabel('TOTALOF')." ".$no_of_rows." ".getFixedLabel('RECORDNUMS');
//
//$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string,"Users","ShowHistory",'');

$smarty->assign("CMOD", $mod_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("LIST_HEADER",$focus->getHistoryListViewHeader());
$smarty->assign("LIST_ENTRIES",$focus->getHistoryListViewEntries($navigation_array, $sorder, $sortby));
//$smarty->assign("RECORD_COUNTS", $record_string);
//$smarty->assign("NAVIGATION", $navigationOutput);
$smarty->assign("CATEGORY",$category);
$user_list = getUserslistSearch();
$smarty->assign("USERLIST", $user_list);
$smarty->assign("LOGINMETHOD",$focus->get_login_method());


$smarty->assign("STARTPAGE", ceil($start));
$smarty->assign("LISTVIEWRECORDCOUNT", ceil($no_of_rows));
$smarty->assign("LISTVIEWPAGECOUNT", ceil($no_of_rows/$pagecount));
$smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($pagecount)));

if($focus->languageType=='en'){
    $login_type = $focus->login_type_shift_en[$_REQUEST['login_type']];
}else{
    $login_type = $focus->login_type_shift_zh[$_REQUEST['login_type']];
}
$smarty->assign("LASt_LOGIN_TYPE",$login_type);

$smarty->assign("LASt_LOGIN_TYPE_VALUE",$_REQUEST['login_type']);

$last_search_user_array = $user_list[$_REQUEST['record']];
if(is_array($last_search_user_array) && count($last_search_user_array) > 0){
    foreach($last_search_user_array as $last_name => $value){
        $last_search_user = $last_name;
    }
}else{
    $last_search_user = '';
}
$smarty->assign("LASt_SEARCH_USER",$last_search_user);
$smarty->assign("LASt_SEARCH_USER_VALUE",$_REQUEST['record']);
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('ShowHistoryContents.tpl');
ConvertTojsonString(1,$arr,"success");
?>