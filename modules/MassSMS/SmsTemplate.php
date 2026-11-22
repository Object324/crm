<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$_REQUEST['diony'] = 'yes';

crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = new cls_Send_MassSms();
$platform = $cls_Send_MassSms->platform;


$arr = [];
$operationtype = trim($_REQUEST['operationtype']);
switch ($operationtype) {
    case 'getsmstemplate':
        $smstemplatelist = $cls_Send_MassSms->getSmsTemplatePresenceInform($platform);//获取启用的通知类短信
        $arr['smstemplatelist'] = $smstemplatelist;
        ConvertTojsonString(1, $arr, 'success');
        break;
    case 'getmasssmsrelated':
        $templateid = $_REQUEST['templateid']??'';
        if (empty($templateid)) {
            ConvertTojsonString(-1, $arr, 'fail');
        }
        $smsrelated_arr = $cls_Send_MassSms->getSmsRelated("ld_smstemplates",$templateid);//获取群发短信 当前所选模板的历史设置参数

        $arr['templateparamconf_arr'] = count($smsrelated_arr)>1?$smsrelated_arr['templateparamconf_arr']:'';
        ConvertTojsonString(1, $arr, 'success');
        break;
    default:
        break;
}

ConvertTojsonString(1, $arr, 'success');

?>