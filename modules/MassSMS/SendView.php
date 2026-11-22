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
global $app_strings, $mod_strings, $current_language, $currentModule, $theme;
global $current_user,$adb;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty();
/*
By LD Diony;
Date:2013-07-02;
reason:读取短信模板
*/
$languageType= getLanguageType($current_user);
$return_data=array();

//aliyun短信模板
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;
$smarty->assign("PlatForm",$platform);
$smsrelated_arr = [];
if ($platform == 'aliyun') {
    $smstemplatelist = $cls_Send_MassSms->getSmsTemplatePresenceInform($platform);
    $smarty->assign("SmsTemplateList",$smstemplatelist);//启用的短信模板列表

    $smarty->assign("SmsScene","MassSms");//隐藏变量信息行(选模块的)
}else{
    $SMStype=$_REQUEST['SMStype'];
    if($SMStype=="SMS_VOICE"){
        $sqltemplates = "select * from ld_wx_config where name='tencentcloud_sms_voice'";
        $resulttemplates = $adb->pquery($sqltemplates, array());
        $para_content = $adb->query_result($resulttemplates,0,'para_content');
        $para_content = Zend_Json::decode($para_content);
        foreach($para_content as $tid=>$tname){
            $return_data[] = array('TemplateID'=> $tid,
                'TemplateName'=> $tname,
            );
        }
    }
    else{
        $sqltemplates = "select * from ld_smstemplates order by templateid DESC";
        $resulttemplates = $adb->pquery($sqltemplates, array());
        $num_rows=$adb->num_rows($resulttemplates);
        if($num_rows){
            for($i=0;$i<$num_rows;$i++){
                $return_data[]=array('TemplateID'=> $adb->query_result($resulttemplates,$i,'templateid'),
                    'TemplateName'=> strCut($adb->query_result($resulttemplates,$i,'templatename'),20),
                    'Body'=> $adb->query_result($resulttemplates,$i,'body'),
                    'template_type'=> $adb->query_result($resulttemplates,$i,'template_type')
                );
            }
        }
    }
}



$type = $_REQUEST['type'];
if($type=='addtem'){   
    if(isset($_REQUEST['receivetem'])){
        $receivetemid = $_REQUEST['receivetem'];
        $sqltemplates = "select * from ld_smstemplates where templateid= " .$receivetemid;
        $resulttemplates = $adb->pquery($sqltemplates);     
        $receivetembody = $adb->query_result($resulttemplates,0,'body');//内容
        echo "#####".$receivetembody;
        exit();
    }
}
$smarty->assign('TABID',getTabid('MassSMS'));
$smarty->assign("TEMPLATES",$return_data);
// diony 20200707 判断是否是客户001账套
include_once (globalStatic::$root_directory.'appCommon/appCommon.php');
$smarty->assign('iskehu001',isKehu001ServerPc());
//阳光创信
$version = getVersionTradeInfo();
$smarty->assign('version_account',$version['account']);
$smarty->assign('SMStype',$_REQUEST['SMStype']);
//东贸——区分大巴车和下游客户
if($version['account']=='dongmao'){
    $sql = 'select linkcvid,zh_label,en_label from ld_linkmodulecustom where `name` in ("CRMLinkModuleCustom35","CRMLinkModuleCustom40") ';
    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    $linkmodule_info = array();
    for($i=0;$i<$num_rows;$i++){
        $linkmodule_info[$i]['linkcvid'] = $adb->query_result($result,$i,'linkcvid');
        $label = $adb->query_result($result,$i,'zh_label');
        if($languageType == 'en'){
            $label = $adb->query_result($result,$i,'en_label');
        }
        $linkmodule_info[$i]['label'] = $label;
        $linkmodule_info[$i]['module'] = 'ServiceCharge';
    }
    $smarty->assign('LINKMODULEINFO',$linkmodule_info);
}

//获取短信全名
$SMSarray = GetSMSAutograph();
$smarty->assign('accountautograph',$SMSarray['autograph']);
$_REQUEST['diony']='diony';
if($SMStype=="SMS_VOICE"){
    $title = getFixedLabel('MASSSEND').getFixedLabel('VOICE');
}else{
    $title = getTransTab('MassSMS');
}
$arr['title']=$title;
$arr['oktext'] = getTransTab('MASSSEND');
$arr['platform'] = $platform;
$str=$smarty->fetch(vtlib_getModuleTemplate($currentModule,'MassSMSPopup.tpl'));
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>