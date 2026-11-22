<?php
global   $theme, $currentModule, $current_user , $adb;
$record = intval(vtlib_purify($_REQUEST['record']));
//$step = vtlib_purify($_REQUEST['step']);
$focus = CRMEntity::getInstance($currentModule);
$focus->id = $record;
$focus->mode = 'edit';
$focus->retrieve_entity_info($focus->id, $currentModule);

//加载二维码配置文件
require_once ('QuestionnaireConfig.php');
$Qrcode = makeQrcode($prefix,$suffix,$htmlPath,$record,$qrcodePath,$currentModule,$focus->column_fields['smcreatorid']);

$_REQUEST['diony'] ='diony';
//$arr['oktext']=getFixedLabel("LBL_FINISH_BUTTON_LABEL");
//$arr['title']=getTranstab($currentModule);
$arr['Qrcode'] = $Qrcode;
//global $site_URL;
//$arr['site_URL'] = $site_URL.'/';
$arr['site_URL'] = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST'] .rtrim($_SERVER['PHP_SELF'],'index.php');

ConvertTojsonString(1,$arr,"success");