<?php
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
if(isset($_REQUEST['funName']) && !empty($_REQUEST['funName'])) {
    $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
    $cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
    $funName = $_REQUEST['funName'];
    crm_load_class_file('AdvanceSearchUtil', 'modules/lingdang');
    if(method_exists('AdvanceSearchUtil',$funName)) {
        $res = AdvanceSearchUtil::$funName($_REQUEST);
        $_REQUEST['diony'] = 'diony';
        ConvertTojsonString(1, $res, "success");
    }
    ConvertTojsonString(1, [], "failed");
}
?>