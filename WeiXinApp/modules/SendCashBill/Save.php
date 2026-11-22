<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');

class cls_Products_SaveWX extends cls_SaveWX{
    //对冲提醒
}
foreach($_REQUEST['wx_productFieldInfo'] as $key=>$val){
    $_REQUEST[$key] = $val;
}
$_REQUEST['sendcashbill_total']=$_REQUEST['p_total']['total']['value'];

if(!isset($_REQUEST['currency_id']) || empty($_REQUEST['currency_id'])){
    $_REQUEST['currency_id'] = 1;
}
$mobj = new cls_Products_SaveWX('SendCashBill');
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
for($i=1;$i<=$_REQUEST['rowcnt'];$i++){
    $_REQUEST['deleterow'.$i] = $_REQUEST['hidden_rowid_'.$i];
    //unset($_REQUEST['hidden_rowid_'.$i]);
}
$_REQUEST['selectsource'] = getSalesEntityType($_REQUEST['salesorder_id']);
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
?>