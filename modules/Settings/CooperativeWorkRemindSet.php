<?php
/**
 * DESCRIPTION:工作汇报提醒设置
 */
 global $current_user,$languageType;

$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='CooperativeWorkRemindSet';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
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
'6'=>'19:00',
'7'=>'20:00',
'8'=>'21:00',
'9'=>'22:00',
'10'=>getFixedLabel('DontRemind'),);
$weekArr=array('1'=>getFixedLabel('Wednesday'),
'2'=>getFixedLabel('Thursday'),
'3'=>getFixedLabel('Friday'),//Friday
'4'=>getFixedLabel('Saturday'),//Saturday
'5'=>getFixedLabel('Sunday'),//Sunday
'6'=>getFixedLabel('DontRemind'));
if($languageType=='en'){
    $monthArr=array('1'=>'NO.20',
        '2'=>'NO.25',
        '3'=>'NO.28',
        '4'=>getFixedLabel('ENDOFMONTH'),
        '5'=>'The 1st of next month',
        '6'=>'The 2nd of next month',
        '7'=>'The 3rd of next month',
        '8'=>'The 4th of next month',
        '9'=>'The 5th of next month',
        '10'=>getFixedLabel('DontRemind'));
}else{
    $monthArr=array('1'=>'20号',
        '2'=>'25号',
        '3'=>'28号',
        '4'=>getFixedLabel('ENDOFMONTH'),
        '5'=>'下月1号',
        '6'=>'下月2号',
        '7'=>'下月3号',
        '8'=>'下月4号',
        '9'=>'下月5号',
        '10'=>getFixedLabel('DontRemind'));
}

$query="select * from ld_workremindset";
$result=$adb->query($query);

function ChineseDaily($daily){
    switch($daily){
        case 'no':
            return getFixedLabel('DontRemind');
            break;
        default:
            return $daily;
            break;
    }
}

function ChineseWeek($week){
    switch($week){
        case 1:
        return '周一';break;
        case 2:
        return '周二';break;
        case 3:
        return '周三';break;
        case 4:
        return '周四';break;
        case 5:
        return '周五';break;
        case 6:
        return '周六';break;
        case 7:
        return '周日';break;
		case 'no':
        return '不提醒';break;
    }
}
 
 function ChineseMonth($month){
    $max=date('t');//本月最大天数
    switch($month){
        case 20:
        return '20号';break;
        case 25:
        return '25号';break;
        case 28:
        return '28号';break;
        case 40:
        return '月末';break;
        case 1:
        return '下月1号';break;
        case 2:
        return '下月2号';break;
        case 3:
        return '下月3号';break;
        case 4:
        return '下月4号';break;
        case 5:
        return '下月5号';break;
		case 'no':
        return '不提醒';break;
    }
}
if($adb->num_rows($result)){
    $values=array();
    $values[]=ChineseDaily($adb->query_result($result,0,'cooperativeworkdaily'));
    $values[]=ChineseWeek($adb->query_result($result,0,'cooperativeworkweek'));
    $values[]=ChineseMonth($adb->query_result($result,0,'cooperativeworkmonth'));
}
$smarty->assign('OEM_CRM',$common_version['oem_crm']);
$smarty->assign('VALUES',$values);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("ACTION",'SaveCooperativeWorkRemindSet');
$smarty->assign('DAILYARR',$dailyArr);
$smarty->assign('WEEKARR',$weekArr);
$smarty->assign('MONTHARR',$monthArr);
// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('CooperativeWorkRemindSet.tpl');
ConvertTojsonString(1,$arr,"success");
?>