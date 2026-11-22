<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
require_once(globalStatic::$root_directory.'modules/Reminds/Reminds.php');
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');
$mobj = new cls_SaveWX($currentModule);
$mobj->setFieldInfoFromPost();
//editor:gyq_109 reason:日程管理模块   2019/5/7 12:00
if(isset($_REQUEST['set_remind'])){
    if(empty($_REQUEST['set_remind']))
        $_REQUEST['set_remind']='No';
    else{
        $_REQUEST['set_remind']='Yes';
        if(empty($_REQUEST['email_date_only'])){
            $email_date_only = time();
            ConvertTojsonString(-1,array(),getFixedLabel('SENDEMAILREMINDERTIME').getFixedLabel('CANOTEMPTYGTH'));
        }else{
            $email_date_only = strtotime($_REQUEST['email_date_only']);
        }
        $_REQUEST['email_date_only']=date('Y-m-d H:i:s',$email_date_only);
    }
    if(empty($_REQUEST['pop_reminds']))
        $_REQUEST['pop_reminds']='No';
    else{
        $_REQUEST['pop_reminds']='Yes';
        if(empty($_REQUEST['date_time'])){
            $date_time = time();
            ConvertTojsonString(-1,array(),getFixedLabel('POPMESSAGENOTICETIME').getFixedLabel('CANOTEMPTYGTH'));
        }else{
            $date_time = strtotime($_REQUEST['date_time']);
        }
        $_REQUEST['date_time']=date('Y-m-d H:i:s',$date_time);
    }
}
if(!empty($_REQUEST['inviteesid'])){
    $inviteesid = explode(',',$_REQUEST['inviteesid']);
    $_REQUEST['inviteesid'] = implode(';',$inviteesid);
}
$mobj->common_save();
$focus_rel = new Reminds();//添加提醒
$focus_rel->saveRemindsInfo($currentModule,$mobj->focus->id);
$mobj->ConvertTojsonStringInSave();
?>
