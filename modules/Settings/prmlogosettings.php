<?php
global $current_user,$adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty = new lingdangCRM_Smarty();

crm_load_class_file('MenuUtils','modules/Users');
$MenuUtilsObj = new MenuUtils();
$prmlogoname = $MenuUtilsObj->getPRMlogoname();

if (isset($prmlogoname))
    $smarty->assign("PRMLOGONAME",$prmlogoname);

$smarty->assign('RANDNUM',strtotime(date("Y-m-d H:i:s")).rand(1000,9999));

$arr = [];
$arr['content']= $smarty->fetch('Settings/prmlogosettings.tpl');
$arr['title']=getFixedLabel("logo_settings");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");


ConvertTojsonString(1,$arr,'success');
?>