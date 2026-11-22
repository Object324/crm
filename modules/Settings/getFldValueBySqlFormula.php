<?php
//zkt 20231120 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//liushuai 20230718 XUQIU1001661 单据头字段录入方式增加“通过SQL查询”
global $adb,$current_user;
$_REQUEST['diony'] = 'yes';
$modulename = $_REQUEST['modulename'];
$formulaid = $_REQUEST['formulaid'];
if(isset($_REQUEST['requestvalue_arr'])){
    $requestvalues_arr = $_REQUEST['requestvalue_arr'];
}else{
    $requestvalues = urldecode($_REQUEST['requestvalues']);
    $requestvalues_arr = Zend_JSON::decode(str_replace("\n", '', $requestvalues));
}

$data=array();
if(isset($requestvalues_arr) && is_array($requestvalues_arr) && !empty($formulaid)){
    crm_load_class_file("cls_mainfieldsqlformula","include/fields");
    $mainfieldsqlformulaobj=cls_mainfieldsqlformula::getInstance($modulename);
    $formulaInfo = $mainfieldsqlformulaobj->getFormulaInfoById($formulaid);

    $query_sql = $formulaInfo['formulastring'];
    $columnstring = $formulaInfo['columnstring'];
    $fieldname = $formulaInfo['fieldname'];

    //检查sql合理性
    $checksql = parserSql($query_sql);
    if ($checksql['code'] != 1) {
        echo '';exit; //ConvertTojsonString($checksql['code'],array(),$checksql['msg']);
    }

    $query_sql = $mainfieldsqlformulaobj->handleSqlVar($query_sql,$columnstring);
    $query_sql = $mainfieldsqlformulaobj->handleSqlFieldValue($query_sql,$requestvalues_arr);
    $data = $mainfieldsqlformulaobj->getResultForSqlFormula($query_sql,$fieldname);
    if($data==null){
        $data = array();
    }
}

echo json_encode($data);exit;
?>
