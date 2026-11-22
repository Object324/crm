<?php
global $adb;

crm_load_class_file('cls_DebuctionInfo','modules/CashBill');
$focus=CRMEntity::getInstance('CashBill');
$focus->column_fields['account_id']=$_REQUEST['accountid'];
$focus->column_fields['currency_id']=$_REQUEST['currency_id'];

$debuctioninfoobj=new cls_DebuctionInfo($_REQUEST['cashbillid'],$focus);
$tmparr=$debuctioninfoobj->getDebuctionListByAccountid();
$_REQUEST['diony']='yes';

$arr['list']=$tmparr;
$arr['debuctionlabel']=getFixedLabel('CreateDebuction');
$arr['DeductedAmountlabel']=getFixedLabel('DeductedAmount');
$arr['CanDeductibleAmount']=getFixedLabel('CanDeductibleAmount');

ConvertTojsonString(1,$arr,'success');

?>