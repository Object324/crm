<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
if($_REQUEST['frommodule']=='PurchaseOrder')
{
    $_REQUEST['purchaseorderid']=$_REQUEST['fromid'];
}
require_once 'modules/lingdang/CustomFormEditView.php';

?>