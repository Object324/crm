<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_145 reason:销售机会增加产品分录  2019/9/19 17:35
//2020-1228 zxm 陌远特殊开发 销售机会保存查重以及判断有效销售机会数量
$versionInfo = getVersionInfo();
if($versionInfo['account'] == "moyuan"){
    $mode='create';
    $record = $_REQUEST['record'];
    if(!empty($record)) {
        $mode = $_REQUEST['mode'] ='edit';
    }else{
        $mode = $_REQUEST['mode'] = 'create';
    }
    include globalStatic::$root_directory.'modules/Home/CustomMade/MoyuanUtils.php';
    $moyuanObj = new MoyuanUtils();
    $judge = $moyuanObj->judgePotentials($mode,$_REQUEST['wx_fieldInfo']['assigned_user_id'],$_REQUEST['record']);
    if($judge['code'] == -1){
        $_REQUEST['diony'] = "yes";
        ConvertTojsonString($judge['code'], [], $judge['msg']);
    }
}
$mobj = cls_Instance::get_moduleAction_Instance($currentModule,$_REQUEST['action']);
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();


//2021-0118 zxm 陌远特殊开发 销售机会保存查重以及判断有效销售机会数量  商机状态字段无权限无法更新的问题
if($versionInfo['account'] == "moyuan"){
    global $adb;
    $update_sql = "update ld_potentialscf set cf_3329='".$_REQUEST['cf_3329']."' where potentialid=".$mobj->focus->id;
    $adb->pquery($update_sql,[]);
}
?>