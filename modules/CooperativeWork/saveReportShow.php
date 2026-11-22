<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file('cls_workreportshow',"modules/CooperativeWork");
$workreportshowobj=new cls_workreportshow();
$mode = $_REQUEST['mode'];
//@edit:liushuai,2020-07-28,reason:ID1000926/工作汇报设置弹出层界面优化，增加“类别设置”和“文字描述设置”区块标签，文字描述可修改
if($mode == 'savetext') {
    $workreportshowobj->saveWorkReportText();//点击保存
}else{
    $datainfo = $_REQUEST['data'];
    $workreportshowobj->saveWorkReportTypeAndShow($datainfo);
}

?>