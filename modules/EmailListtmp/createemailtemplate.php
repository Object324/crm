<?php

require_once('include/CustomFieldUtil.php');

global $app_strings;
global $mod_strings;
global $current_language,$default_charset;

global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

//To get Email Template variables -- Pavani
$allOptions=getEmailTemplateVariables();
$smarty = new lingdangCRM_smarty;

$smarty->assign("APP", $app_strings);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("THEME", $theme);
$smarty->assign("THEME_PATH", $theme_path);
$smarty->assign("UMOD",$mod_strings);
$smarty->assign("PARENTTAB", getParentTab());
$smarty->assign("ALL_VARIABLES", $allOptions);

$smarty->assign("MOD", $smod_strings);
$smarty->assign("MODULE", 'Settings');

$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('CREATEMAILTEMPLAETES');	//{'EDITEMAILTEMPLAETES'|@getFixedLabel} &quot;{$TEMPLATENAME}&quot;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("CreateEmailTemplate.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>