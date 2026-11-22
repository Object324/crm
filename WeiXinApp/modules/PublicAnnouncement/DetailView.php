<?php
/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2016/11/28 0028
 * Time: 下午 2:34
 */
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule,$current_user;
$focus = CRMEntity::getInstance($currentModule);

$recordid = isset($_REQUEST['record'])?$_REQUEST['record']:'';

if(!empty($recordid)){
    //进详情更新阅读状态
    if (method_exists($focus, 'updatePublicAnnouncementStatus')){
        $focus->updatePublicAnnouncementStatus($recordid,$current_user->id);
    }
}

$mobj =cls_Instance::get_moduleAction_Instance($currentModule,'DetailView');
$details = $mobj->common_getInfo();
echo $details;
?>