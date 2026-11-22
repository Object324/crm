<?php

require_once('include/CustomFieldUtil.php');
global $theme;
global $current_language;

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
global $default_charset;

$mode = 'create';

if(isset($_REQUEST['templateid']) && $_REQUEST['templateid']!='')
{
	$mode = 'edit';
	$templateid = $_REQUEST['templateid'];
}
$sql = "select * from ld_documenttemplates where templateid=?";
$result = $adb->pquery($sql, array($templateid));
$emailtemplateResult = str_replace('"','&quot;',$adb->fetch_array($result));
//To get Email Template variables -- Pavani
$allOptions=getEmailTemplateVariables();
$smarty = new lingdangCRM_smarty;

$smarty->assign("THEME", $theme_path);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("FOLDERNAME", $emailtemplateResult["foldername"]);
$smarty->assign("TEMPLATENAME", $emailtemplateResult["templatename"]);
$smarty->assign("TEMPLATEID", $emailtemplateResult["templateid"]);
$smarty->assign("DESCRIPTION", $emailtemplateResult["description"]);
$smarty->assign("SUBJECT", $emailtemplateResult["subject"]);
$smarty->assign("BODY", decode_html($emailtemplateResult["body"]));
$smarty->assign("MODULE", 'Settings');
$smarty->assign("PARENTTAB", getParentTab());
$smarty->assign("EMODE", $mode);
$smarty->assign("ALL_VARIABLES", $allOptions);

$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('EDIT') .' '. $emailtemplateResult["templatename"];
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("CreateDocumentsTemplate.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>