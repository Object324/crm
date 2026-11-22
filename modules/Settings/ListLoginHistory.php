<?php
require_once(globalStatic::$root_directory.'modules/Users/LoginHistory.php');

global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='ListLoginHistory';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
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
$user_array=get_user_array(FALSE, "Active", $current_user->id);
$user_list = get_select_options_array($user_array, $current_user->id);

$pagecount = getUsersettingByLabel('Settings',$current_user->id,'ShowHistoryListPageNum');
if (empty($pagecount)){
    $pagecount = $list_max_entries_per_page_new;
}

$smarty->assign("CMOD", $mod_strings);
$smarty->assign("MOD", $current_module_strings);
$smarty->assign("APP", $app_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("USERLIST", $user_list);
$smarty->assign("CATEGORY",$category);

//editor:gyq_92 reason:系统设置登录日志查询增加分类功能  2018/12/20 17:18
$smarty->assign("LOGINMETHOD",$focus->get_login_method() );
$no_of_rows = $focus->get_loginlog_page_number( $_REQUEST['record'],$_REQUEST['login_type']);
if(isset($_REQUEST['start']) && $_REQUEST['start'] != '')
    $start = vtlib_purify($_REQUEST['start']);
else
    $start=1;
//17116: 控制面板>登录日志：列表条数没有根据系统参数【设置序时簿列表每页显示记录的条数】控制。
crm_load_function_file('getNavigationValues','include/utils','ListViewUtils');
$navigation_array = getNavigationValues($start, $no_of_rows, $pagecount);
/**edit:kevin date:2013-05-30 reason:3994*/
//$record_string= getFixedLabel('TOTALOF')." ".$no_of_rows." ".getFixedLabel('RECORDNUMS');
//$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $url_string,"Users","ShowHistory",'');

$smarty->assign("LIST_HEADER",$focus->getHistoryListViewHeader());
$smarty->assign("LIST_ENTRIES",$focus->getHistoryListViewEntries( $navigation_array, $sorder, $sortby));
//$smarty->assign("RECORD_COUNTS", $record_string);
//$smarty->assign("NAVIGATION", $navigationOutput);
$smarty->assign("STARTPAGE", ceil($start));
$smarty->assign("LISTVIEWRECORDCOUNT", ceil($no_of_rows));
$smarty->assign("LISTVIEWPAGECOUNT", ceil($no_of_rows/$pagecount));
$smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($pagecount)));

$smarty->assign("LASt_LOGIN_TYPE_VALUE",'all');
// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('ListLoginHistory.tpl');
ConvertTojsonString(1,$arr,"success");
?>