<?php
require_once(globalStatic::$root_directory.'modules/Settings/cls_OperationLogs/cls_OperationLogs.php');

global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
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
$smarty = new lingdangCRM_Smarty;

$logtype = $_REQUEST['logtype'];//日志类型,目前有导入导出日志(ImportExport)

$selectmodule = $_REQUEST['selectmodule'];
$actiontype = $_REQUEST['actiontype'];
$userids = $_REQUEST['userids'];
$operationtime = $_REQUEST['operationtime'];

if(isset($_REQUEST['pagenum']) && $_REQUEST['pagenum'] != '')
    $pagenum = $_REQUEST['pagenum'];
else
    $pagenum = 1;

$cls_operationlogs = cls_OperationLogs::getInstance($selectmodule,$actiontype,$userids,$operationtime,$logtype);

if(isset($logtype) && $logtype != '')
    $cls_operationlogs->logtype = $logtype;

$list_max_entries_per_page_new=getUsersettingByLabel('OperationLogs',$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel('OperationLogs',1,'MaxEntriesPerPage');
$list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;
$cls_operationlogs->max_entries = $list_max_entries_per_page_new;
// $cls_operationlogs->max_entries = $list_max_entries_per_page_new;
// $cls_operationlogs->pagenum = $pagenum;
$smarty->assign("LogType", $logtype);
//获取表头
$table_header = $cls_operationlogs->getTableHeader();
$headerwidth = $cls_operationlogs->getHeaderWidth();
$smarty->assign('TableHeader',$table_header);
$smarty->assign('HeaderWidth',$headerwidth);
$smarty->assign('DataLength', -1);
$mode = $_REQUEST['mode'];
if($mode == 'setlogtime'){//设置日志存留时长
    $availabletimes = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18];

    $arr['title'] = getFixedLabel('SET');
    $arr['oktext'] = getFixedLabel("SAVE");
    $arr['canceltext'] = getFixedLabel("CANCEL");
    $arr['contentlabel'] = getFixedLabel("LogsRetentionTime");
    $arr['availabletimes'] = $availabletimes;
    $arr['availabletimelabel'] = getFixedLabel("MONTHSAPP");
    $sys_468 = getSys_deploy(468);//保存的日志存留时长
    $arr['savedtime'] = $sys_468['deploy_value'];

    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,$arr,"success");

}else if($mode == 'savelogtime'){//保存日志存留时长
    $savedtime = $_REQUEST['savedtime'];
    if(!empty($savedtime)){
        $updatesql = "UPDATE ld_systems_deploy SET deploy_value=? WHERE deploy_type = 468";
        $adb->pquery($updatesql, array($savedtime));
    }
    unsetCache('systems_deploy');

    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,$arr,"success");

}else if($mode == 'changemodule'){//切换模块，更新操作行为下拉框值
    $available_actions = $cls_operationlogs->setOperationActions();

    $arr['available_actions'] = $available_actions;
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,$arr,"success");

}else if($mode == 'setMaxEntriesPerPage'){//设置最大条数
    setUsersettingByLabel('OperationLogs',$current_user->id,'MaxEntriesPerPageByuser',$_REQUEST['pagecount']);

    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,$arr,"success");

}else if($mode == 'search'){//搜索

    if($actiontype == 'All'){
        $listdata = $cls_operationlogs->getAllLogData($pagenum);
    }else{
        $listdata = $cls_operationlogs->getLogData($pagenum);
    }
    
    $smarty->assign('ListData', $listdata);
    $smarty->assign('DataLength', is_array($listdata)?count($listdata):0);

    //分页
    //BUG20240722-73 wsh 2024-07-25
    $cls_operationlogs = cls_OperationLogs::getInstance($selectmodule,$actiontype,$userids,$operationtime,$logtype);
    $noofrows = $cls_operationlogs->getTotalRows();
    $smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);

    $queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
    $start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);

    $smarty->assign("TABNAME", getParentTab());
    $smarty->assign("STARTPAGE", ceil($start));
    $smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
    $smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$list_max_entries_per_page_new));
    crm_load_function_file('getlistmaxentries_per_page','include/utils','ListViewUtils');
    $smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($list_max_entries_per_page_new)));

    $smarty->assign("FunctionObj", 'OperationLogs');

    $arr['content']= $smarty->fetch('Settings/OperationLogsList.tpl');
    ConvertTojsonString(1,$arr,"success");

}else if($mode == 'changepage'){//换页

    if($actiontype == 'All'){
        $listdata = $cls_operationlogs->getAllLogData($pagenum);
    }else{
        $listdata = $cls_operationlogs->getLogData($pagenum);
    }

    $smarty->assign('ListData', $listdata);
    $smarty->assign('DataLength', count($listdata));
    $arr['content']= $smarty->fetch('Settings/OperationLogsListTable.tpl');
    ConvertTojsonString(1,$arr,"success");
}


//日历组件
$data_select = array(
    'all' => getFixedLabel('ALL'),
    'thistoday' => getFixedLabel('checktoday'),
    'yestoday' => getFixedLabel('checkyesterday'),
    'thisweek' => getFixedLabel('thisweek'),
    'lastweek' => getFixedLabel('lastweek'),
    'thismonth' => getFixedLabel('thismonth'),
    'lastmonth' => getFixedLabel('lastmonth'),
    'thisquarter' => getFixedLabel('thisfq'),
    'lastquarter' => getFixedLabel('prevfq'),
    'thisyear' => getFixedLabel('thisyear1'),
    'lastyear' => getFixedLabel('lastyear1'),
    'custom' => getFixedLabel('custom') . getFixedLabel('TIMES'),
);
$smarty->assign('DATASELECT',$data_select);
$smarty->assign('timesearchdefault','all');

//标题
$smarty->assign('Title',$cls_operationlogs->title);
//获取可选模块
$selectModule = $cls_operationlogs->getselectModules();
$smarty->assign('SELECTMODULE',$selectModule);
//获取可选操作行为
$available_actions = $cls_operationlogs->setOperationActions();
$smarty->assign('available_actions',$available_actions);
//操作人范围
$MergeSmowner['OtherInfo']['SmOwner_Search_All'] = array(getFixedLabel('ALL').getFixedLabel('MEMBER')=>'');
$MergeSmowner['OtherInfo']['smowner_search_senior'] = array(getFixedLabel('LBL_SENIOR')=>'');
$user_array=get_user_array(FALSE, "Active", $current_user->id);
$user_list = get_select_options_array($user_array, '');
$MergeSmowner['UserCombo'] = $user_list;

$smarty->assign('Merge_SmOwner',$MergeSmowner);
$smarty->assign('MODULE', $currentModule);

//分页
$noofrows = 0;

$smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);

$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows, $viewid, $queryMode);

$smarty->assign("TABNAME", getParentTab());
$smarty->assign("STARTPAGE", ceil($start));
$smarty->assign("LISTVIEWRECORDCOUNT", ceil($noofrows));
$smarty->assign("LISTVIEWPAGECOUNT", ceil($noofrows/$list_max_entries_per_page_new));
crm_load_function_file('getlistmaxentries_per_page','include/utils','ListViewUtils');
$smarty->assign("LISTVIEWPERPAGENUM", json_encode(getlistmaxentries_per_page($list_max_entries_per_page_new)));

// $cls_operationlogs->autoDeleteLogs();//删除过期日志

require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('Settings/OperationLogs.tpl');
ConvertTojsonString(1,$arr,"success");
?>