<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
unset($_REQUEST['userid']);
$allocate = cls_Instance::get_commonAction_Instance('Leads','AllocateAccount',1);
if(isset($_REQUEST['allocate_userid'])){
    $userid = $_REQUEST['allocate_userid'];
}else{
    $userid = $current_user->id;
}
$allocate->set_userid($userid)->init_count()->switch_entrance();

ConvertTojsonString(1,array(),'success');
?>