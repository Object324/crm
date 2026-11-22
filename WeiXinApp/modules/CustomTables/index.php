<?php
//zkt 20231020 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$weixin_user;
//自定义统计图  移动端链接模块
if($weixin_user->environment=='weixinh5'){
    $wx_userid = $_REQUEST['userid'];
    //企业微信 weixinh5
    $sql = 'SELECT id,user_name,last_name,status,wx_userid,wx_userid_old FROM ld_users WHERE wx_userid = ? or wx_userid_old=? LIMIT 1';
    $result = $adb->pquery($sql, array($wx_userid,$wx_userid));
    $rows = $adb->num_rows($result);
    if($rows>0) {
        $id = $adb->query_result($result, 0, 'id');
    }else{
        ConvertTojsonString(-3, null, '登录失败，CRM账号绑定企业微信后，才能登录');
    }
}else if($weixin_user->environment=='dingtalk'){
    $wx_userid = $_REQUEST['userid'];
    $sql = 'SELECT id,user_name,last_name,status,dingtalk_userid FROM ld_users WHERE dingtalk_userid = ? LIMIT 1';
    $result = $adb->pquery($sql, array($wx_userid));
    $rows = $adb->num_rows($result);
    if($rows>0) {
        $id = $adb->query_result($result, 0, 'id');
    }else{
        ConvertTojsonString(-3, null, '登录失败，CRM账号绑定企业微信后，才能登录111');
    }
}else if($weixin_user->environment=='yunzhijia'){
    $id = $_REQUEST['userid'];
}else{
    //wxwork 企业微信小程序
    //weixin 微信小程序
    $id = $_REQUEST['userid'];
}

cls_StaticCommonFun::initUserPrivileges($id);
include(globalStatic::$root_directory.'Smarty_setup.php');
if($_REQUEST['file']=='SqlTableDetailView'){
    include globalStatic::$root_directory.'modules/CustomTables/SqlTableDetailView.php';
}
if($_REQUEST['file']=='ModuleInfo'){
    include globalStatic::$root_directory.'modules/CustomTables/ModuleInfo.php';
}
if($_REQUEST['file']=='CustomTablesDetailView'){
    include globalStatic::$root_directory.'modules/CustomTables/CustomTablesDetailView.php';
}
if($_REQUEST['file']=='CustomTablesEditView'){
    include globalStatic::$root_directory.'modules/CustomTables/CustomTablesEditView.php';
}
if($_REQUEST['file']=='viewgroupinfo'){
    include globalStatic::$root_directory.'/modules/Users/viewgroupinfo.php';
}
