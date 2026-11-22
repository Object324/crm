<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
//editor:gyq_20190527 reason:系统参数“无工商信息不允许保存”控制  2019/5/27 17:36 0037038
//0037038: 企业微信和小程序：服务收费管理和供应商，没有根据系统参数“无工商信息不允许保存”控制
$mobj = cls_Instance::get_moduleAction_Instance($currentModule,'Save');
$contactid = 0;
if($_REQUEST['previousAction']=='EditView'){
    $sqlcontact="select contactid from ld_contactdetails 
	  where accountid=? and reference=1 and deleted=0 order by contact_no asc limit 0,1";
    $resultcontact=$adb->pquery($sqlcontact,array($_REQUEST['record']));
    $contactid = $adb->query_result($resultcontact,0,'contactid');
}
$_REQUEST['reference']=1;
$_REQUEST['contactid']=$contactid;
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
?>