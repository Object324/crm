<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_100 reason:微信销售线索增加推进  2019/1/25 13:43
global $adb, $current_user;
require(globalStatic::$root_directory . 'user_privileges/user_privileges_' . $current_user->id . '.php');
$query = 'select `status`,failurereason from ld_leads where leadsid = ?';
$result = $adb->pquery($query, array($_REQUEST['record']));
$status = $adb->query_result($result, 0, 0);
switch ($status) {
    case '失败关闭':
        $status = 'Failedtoclose';
        break;
    case '跟进中':
    case '新建':
        $status = 'Following';
        break;
    case '升级':
        $status = 'Upgrade';
        break;
}
$select_content = array(
    array('text' => getFixedLabel('FOLLOWING'), 'value' => 'Following', 'selected' => ''),
    array('text' => getFixedLabel('FAILLEDTOCOLSE'), 'value' => 'Failedtoclose', 'selected' => ''),
    //editor:gyq_143 reason:销售线索升级为客户弹出层 2019/9/10 15:13 ID1000604
    array('text' => getFixedLabel('UPGRADE'), 'value' => 'Upgrade', 'selected' => '','module_label'=>getTranstab('Accounts'))
);
foreach ($select_content as $key => $value) {
    if ($value['value'] == $status) {
        $select_content[$key]['selected'] = 'selected';
    }
}
ConvertTojsonString(1, array('list' => $select_content,'modulename' => getTransTab('Accounts')), '');

?>