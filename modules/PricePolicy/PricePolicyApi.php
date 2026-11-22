<?php
if(isset($_REQUEST['funName']) && !empty($_REQUEST['funName'])) {
    $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
    $cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
    $funName = $_REQUEST['funName'];
    crm_load_class_file('PricePolicyUtils', 'modules/PricePolicy');
    if(method_exists('PricePolicyUtils',$funName)) {
        $res = PricePolicyUtils::$funName();
        $_REQUEST['diony'] = 'diony';
        ConvertTojsonString(1, $res, "success");
    }
}
?>