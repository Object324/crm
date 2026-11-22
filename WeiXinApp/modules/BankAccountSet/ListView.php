<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
$module = $currentModule;
$relatemodule = $_REQUEST['related_module'];
//editor:gyq_130 reason:合同订单  2019/7/10 11:38 ID1000554
crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
$mobj = new cls_ListViewWX($currentModule);    
$details = $mobj->get_listdetail("",null);
//移动端银行账户不显示新增按钮
$list_buttons = array();
$details['list2'] = array(
    'viewname' => $_REQUEST['viewid'],
    'create_html'=>$list_buttons);
ConvertTojsonString(1, $details, 'success');
?>
