<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$getfile = $_REQUEST['getfile'];
if(!empty($getfile)){
    $_REQUEST['diony'] = 'true';

    require_once 'modules/ldsoukebao/lib/'.$getfile.'.php';
}

?>