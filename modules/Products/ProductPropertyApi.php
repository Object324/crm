<?php
if(isset($_REQUEST['funName']) && !empty($_REQUEST['funName'])) {
    $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
    $cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
    $funName = $_REQUEST['funName'];
    crm_load_class_file('ProductPropertyUtils', 'modules/Products');
    if(method_exists('ProductPropertyUtils',$funName)) {
        $ProductPropertyUtilsObj = new ProductPropertyUtils($_REQUEST);
        $res = $ProductPropertyUtilsObj->$funName();
        $_REQUEST['diony'] = 'diony';
        ConvertTojsonString(1, $res, "success");
    }
}
?>