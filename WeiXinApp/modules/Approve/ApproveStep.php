<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module']!=''){    
    $fld_module=$_REQUEST['fld_module'];
    $blockid=getTabid($fld_module);
}
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
$record=$_REQUEST['record'];
require_once(globalStatic::$root_directory.'WeiXinApp/modules/Approve/cls_Approve/ApproveWX.php');
$approve = new ApproveWX();
require_once(globalStatic::$root_directory.'appCommon/modules/Approve/ApproveStep.php');
?>