<?php
$focus=CRMEntity::getInstance('Accounts');
$focus->id=$_REQUEST['accountid'];
$method=$_REQUEST['method'];
include('include/trade/Finance/Finance_Accounts.php');
$finance_focus=new Finance_Accounts($focus);
echo $finance_focus->$method();
exit();
?>

