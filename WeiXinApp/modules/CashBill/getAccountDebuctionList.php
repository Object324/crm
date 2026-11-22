<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;

crm_load_class_file('cls_DebuctionInfo','modules/CashBill');
$focus=CRMEntity::getInstance('CashBill');
$focus->column_fields['account_id']=$_REQUEST['accountid'];
$focus->column_fields['bankaccountsetid']=$_REQUEST['bankaccountsetid'];

$debuctioninfoobj=new cls_DebuctionInfo($_REQUEST['cashbillid'],$focus);
$tmparr=$debuctioninfoobj->getDebuctionListByAccountid();
$_REQUEST['diony']='yes';

$arr['list']=$tmparr;
$arr['debuctionlabel']=getFixedLabel('CreateDebuction');
$arr['DeductedAmountlabel']=getFixedLabel('DeductedAmount');
$arr['CanDeductibleAmount']=getFixedLabel('CanDeductibleAmount');

ConvertTojsonString(1,$arr,'success');

?>