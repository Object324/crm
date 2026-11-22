<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$mobj = cls_Instance::get_moduleAction_Instance('Accounts','ListView');
/* 查重第一个序时簿弹框 */
$newDetailValues = array();
if (!empty($_REQUEST['search_content'])) {
    if (empty($_REQUEST['select_option_value'])) {
        $_REQUEST['select_option_value'] = 'ld_account|accountname';
    }
    $_REQUEST['weixin_mark'] = 3;
    //editor:gyq data:20170426 reason:查重改为普通客户序时簿
    $_REQUEST['filter']['searchcontent'] = $_REQUEST['search_content'];
    $_REQUEST['filter']['SearchScope'] = 'SmOwner_Search_All';
    global $currentModule;

    $DetailValues = $mobj->get_listdetail(null);
    $newDetailValues['list1'] = $DetailValues['list1'];
}
$option_values = $mobj->focus->getSelectOption();
$returnList['select_option'] =  $option_values;
$returnList['search_result'] =  $newDetailValues;
ConvertTojsonString(1,$returnList,'success');
exit;
?>