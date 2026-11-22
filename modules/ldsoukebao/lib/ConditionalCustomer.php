<?php
global $currentModule;
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
crm_load_class_file("cls_soukebao","modules/ldsoukebao/lib");
$soukebaoobj = cls_soukebao::getInstance();
$soukebaoobj->setoperationtype("conditionshowdata");
$soukebaoobj->setmodulename($currentModule);
if(isset($_REQUEST['searchtext'])&&!empty($_REQUEST['searchtext'])){
    $searchtext = $_REQUEST['searchtext'];
    $searchcolumn = $_REQUEST['searchcolumn'];
    $soukebaoobj->setsearchtext($searchtext);
    $soukebaoobj->setsearchcolumn($searchcolumn);
}
$data = $soukebaoobj->getlistByoperationtype();
$data['searchplaceholder'] = getFixedLabel('PLEASEENTERCOMPANYNAME');
ConvertTojsonString(1,$data,'sussess');
?>
