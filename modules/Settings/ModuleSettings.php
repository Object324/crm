<?php
/**************************************************************************
*更新操作
*edit：cdw
*date：20131006
*reason：新需求：模块管理和页面设置功能改进
**************************************************************************/


global $mod_strings,$app_strings,$theme,$adb;
$smarty = new lingdangCRM_Smarty;
global $current_user;

// @edit:liushuai @date:2020-08-14 @reason:0042112: （61mis.com/kfbcrm）系统设置>页面设置>选择任意模块进入页面设置：点击刷新，刷新后界面显示空白。
if($_REQUEST['formodule']!='' && $_REQUEST['formodule']!='undefined')
{
    //模块查看界面点击页面设置
  $_REQUEST['ajax'] ='yes';
    include(globalStatic::$root_directory.'modules/Settings/LayoutBlockList.php');
}
$modinfo = array();
$sql = "SELECT name, presence, customized, isentitytype FROM ld_tab WHERE name NOT IN ('Reminds','Tooltip','ModTracker','lingdangBackup','Emails','ServiceCharge') AND  presence IN (0,2,5) ORDER BY tabsequence";
$sqlresult = $adb->pquery($sql,array());
$num_rows  = $adb->num_rows($sqlresult);
for($idx = 0; $idx < $num_rows; ++$idx) 
{
    $modinfo[] = array(
    'name'=>$adb->query_result($sqlresult,$i,'name'),
    'presence'=>$adb->query_result($sqlresult,$i,'presence'),
    'customized'=>$adb->query_result($sqlresult,$i,'customized'),
    'isentitytype'=>$adb->query_result($sqlresult,$i,'isentitytype')
    );
    
    $hassettings=file_exists("modules/$module/Settings.php");
    
}
//print_r($modinfo);
function vtlib_getToggleModuleInfoSetting() {
	global $adb;

	$modinfo = Array();
	/*$sqlresult = $adb->query("SELECT name, presence, customized, isentitytype FROM ld_tab WHERE name NOT IN ('BankAccountSet','Users','Reminds','Tooltip','ModTracker','lingdangBackup','Emails','Calendar','Attachment') AND  presence IN (0,2,5) ORDER BY tabsequence");
	$num_rows  = $adb->num_rows($sqlresult);
	for($idx = 0; $idx < $num_rows; ++$idx) {
		$module = $adb->query_result($sqlresult, $idx, 'name');
		$presence=$adb->query_result($sqlresult, $idx, 'presence');
		$customized=$adb->query_result($sqlresult, $idx, 'customized');
		$isentitytype=$adb->query_result($sqlresult, $idx, 'isentitytype');
		$hassettings=file_exists("modules/$module/Settings.php");
		$modinfo[$module] = Array( 'customized'=>$customized, 'presence'=>$presence, 'hassettings'=>$hassettings, 'isentitytype' => $isentitytype );
	}*/
    /**
     *@edit:andy 
     *@date:20140822
     *@reason:0010840: 控制面板>模块管理、页面设置：列头调整“模块（中文)、模块（英文）”
     *@version:v 5.61
     */
    // @edit:dong @date:2020/10/15 @reason:  表单推广不需要页面设置
    $Sql="select ld_tab.tabid,ld_tab.name,ld_tranlabel.fieldlabel as newtabname,ld_tab.presence,ld_tab.customized,ld_tab.isentitytype,
    languagetype from ld_tab inner join ld_tranlabel on
    ld_tab.tabid=ld_tranlabel.relateid where
    (languagetype='zh' or languagetype='en')
    and trantable='ld_tab'  and ld_tab.name not in
    ('BankAccountSet','Reminds','Tooltip','ModTracker','lingdangBackup','Emails','OftenUseReport','SocialPromotion','WorkReportList') 
    AND ld_tab.presence IN (0,2,5)
    ORDER BY ld_tab.tabsequence";
	$sqlresult = $adb->query($Sql);
	$num_rows  = $adb->num_rows($sqlresult);
    $modinfo=array();
    for($i=0;$i<$num_rows;$i++){
        $module = $adb->query_result($sqlresult, $i, 'name');
        $languagetype = $adb->query_result($sqlresult,$i,'languagetype');
        if($module=='Events')
        {
            $hassettings=file_exists("modules/Calendar/Settings.php");
        }
        else
            $hassettings=file_exists("modules/$module/Settings.php");
        $modinfo[$module]['presence'] = $adb->query_result($sqlresult,$i,'presence');
        $modinfo[$module]['customized'] = $adb->query_result($sqlresult,$i,'customized');
        $modinfo[$module]['hassettings'] =$hassettings;
        $modinfo[$module]['isentitytype'] = $adb->query_result($sqlresult,$i,'isentitytype');
        $modinfo[$module]['label'][$languagetype] = $adb->query_result($sqlresult,$i,'newtabname');
    }
  
	return $modinfo;
}

$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", "themes/$theme/images/");
$smarty->assign("TOGGLE_MODINFO",vtlib_getToggleModuleInfoSetting());
$smarty->assign("LANGUAGETYPE", $languageType);
$_REQUEST['diony']='yes';
$arr=array();
if($_REQUEST['ajax']=='true')
{
    
    
    $arr['content']=$smarty->fetch('Settings/ModuleManager/ModuleSettings.tpl');;
    
}
else
{
   // require_once('SetmenuControl.php');

    $arr['content']=$smarty->fetch('Settings/ModuleManager/ModuleSettings.tpl');

}
ConvertTojsonString(1,$arr,'success');
?>