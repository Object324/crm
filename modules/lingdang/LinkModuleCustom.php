<?php
/**
* @edit:dong
* @data:2020/09/17
* @reason:链接模块定制
* @description:
*/
$smarty=new lingdangCRM_Smarty;

$iframeUrl = urldecode($_REQUEST['link']);
//$iframeUrl .='&fromlinkmodule=yes';
//zkt 20231023
if(strpos($iframeUrl,'CustomReport/JsReport/index.php')!==false||(strpos($iframeUrl,'index.php')===0)){
    $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
    $iframeUrl = $cls_UrlEncryptyJudgeobj->EncryptyBynosorturlparseQueryParams($iframeUrl);
}

$smarty->assign("IFRAMEURL",$iframeUrl);
$smarty->display("LinkModuleCustom.tpl");
exit();

