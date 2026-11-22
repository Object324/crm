<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/

global $app_strings, $mod_strings, $current_language, $currentModule, $current_user, $theme, $adb;

$selected_modules = array();
if(!empty($_SESSION['__UnifiedSearch_SelectedModules__']) && is_array($_SESSION['__UnifiedSearch_SelectedModules__'])) {
	$selected_modules = $_SESSION['__UnifiedSearch_SelectedModules__'];
}
else
{
    /*edit:Can
    date:20130918
    reason:4950: 右上角“快速查找”改进
    */
    $selected_modules=array('Accounts','Contacts','ContactRecords','Calendar','DailyReport','WeekReport','MonthReport','SalesOrder');
}
$allowed_modules = array();
/*
edit by LD Can
date:20130308
reason:0003360: 点击右上角"快速查找"黑色叉子图标,程序会弹出"选择要搜索的模块"窗体，希望将该窗体中部分不需要的模块选项删除或隐藏掉。
*/
$sql = 'select distinct ld_field.tabid,name from ld_field inner join ld_tab on ld_tab.tabid=ld_field.tabid 
INNER JOIN ld_entityname ON ld_entityname.`tabid` = ld_tab.`tabid`
where ld_tab.tabid not in (16,29) and ld_field.presence in (0,2) and ld_tab.presence in (0,2) order by ld_tab.tabsequence asc;';

@include('user_privileges/user_language_'.$current_user->id.'.php');
$moduleres = $adb->query($sql);
@include("dataCache/tabdatas/tab_language.php");
while($modulerow = $adb->fetch_array($moduleres)) {
	if(is_admin($current_user) || isPermitted($modulerow['name'], 'DetailView') == 'yes') {
		$modulename = $modulerow['name'];
        if($languageType=='zh')
            $modulelabel=$tab_string[$modulename];
        else
            $modulelabel=$entab_string[$modulename];
        if(empty($modulelabel))
        {
            continue;
        }
		$allowed_modules[$modulename] = array(
			'label' => $modulelabel,
			'selected' => in_array($modulename, $selected_modules)
		);
	}
}
/*
*更新操作
*负责人：karl
*日期：2013.12.16
*说明：添加日周月报
*/
if(vtlib_isModuleActive('ReportLog'))
{
    $allowed_modules['DailyReport']=array('label' => getFixedLabel('DAILYREPORT'),
			'selected' => in_array('DailyReport', $selected_modules)
            );
    $allowed_modules['WeekReport']=array('label' => getFixedLabel('WEEKREPORT'),
    			'selected' => in_array('WeekReport', $selected_modules)
                );
    $allowed_modules['MonthReport']=array('label' => getFixedLabel('MONTHREPORT'),
    			'selected' => in_array('MonthReport', $selected_modules)
                );
}

   
/*
edit:can
date:20130904
reason:4947: 快速查找出来的界面，界面上排版不合理，应该先将 客户名称、联系人、合同订单等信息放在最上面的，销售机会不需要放在最上
*/
//ksort($allowed_modules);

//require_once('Smarty_setup.php');

$smarty = new lingdangCRM_Smarty();
$smarty->assign('MOD', $mod_strings);
$smarty->assign('APP', $app_strings);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('ALLOWED_MODULES', $allowed_modules);
setGLobalURLSmarty($smarty);//设置js,css等访问路径
echo '$$$$$$$$$SUCCESS$$$$$$$$';
$smarty->display('UnifiedSearchModules.tpl');

?>