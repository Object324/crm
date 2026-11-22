<?php
/**
 * AUTHOR:BY LD KEVIN
 * DATE:2013-05-01
 * DESCRIPTION:工作报告提醒设置
 */
require_once('Smarty_setup.php'); 
global $mod_strings;
global $app_strings;
global $app_list_strings;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty=new lingdangCRM_Smarty;
$dailyArr=array('1'=>'14:00',
'2'=>'15:00',
'3'=>'16:00',
'4'=>'17:00',
'5'=>'18:00',
'6'=>'不提醒');
$weekArr=array('1'=>'周三',
'2'=>'周四',
'3'=>'周五',
'4'=>'周六',
'5'=>'周日',
'6'=>'不提醒');
$monthArr=array('1'=>'20号',
'2'=>'25号',
'3'=>'28号',
'4'=>'月末',
'5'=>'下月1号',
'6'=>'下月2号',
'7'=>'下月3号',
'8'=>'下月4号',
'9'=>'下月5号',
'10'=>'不提醒');
$query="select * from ld_workremindset";
$result=$adb->query($query);
function ChineseWeek($week){
    switch($week){
        case 1:
        return '周一';breack;
        case 2:
        return '周二';breack;
        case 3:
        return '周三';breack;
        case 4:
        return '周四';breack;
        case 5:
        return '周五';breack;
        case 6:
        return '周六';breack;
        case 7:
        return '周日';breack;
		case '不提醒':
        return '不提醒';breack;
    }
 }
 
 function ChineseMonth($month){
    $max=date('t');//本月最大天数
    switch($month){
        case 20:
        return '20号';breack;
        case 25:
        return '25号';breack;
        case 28:
        return '28号';breack;
        case 40:
        return '月末';breack;
        case 1:
        return '下月1号';breack;
        case 2:
        return '下月2号';breack;
        case 3:
        return '下月3号';breack;
        case 4:
        return '下月4号';breack;
        case 5:
        return '下月5号';breack;
		case '不提醒':
        return '不提醒';breack;
    }
 }
if($adb->num_rows($result)){
    $values=array();
    $values[]=$adb->query_result($result,0,'dailyreminddate');
    $values[]=ChineseWeek($adb->query_result($result,0,'weekreminddate'));
    $values[]=ChineseMonth($adb->query_result($result,0,'monthreminddate'));
}
$smarty->assign('OEM_CRM',$common_version['oem_crm']);
$smarty->assign('VALUES',$values);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("ACTION",'SaveWorkRemidSet');
$smarty->assign('DAILYARR',$dailyArr);
$smarty->assign('WEEKARR',$weekArr);
$smarty->assign('MONTHARR',$monthArr);
// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('WorkRemindSet.tpl');
ConvertTojsonString(1,$arr,"success");
?>