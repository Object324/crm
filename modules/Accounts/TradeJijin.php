<?php
$focus=CRMEntity::getInstance('Accounts');
$focus->id=$_REQUEST['accountid'];
$method=$_REQUEST['method'];
include('include/trade/Jijin/Jijin_Accounts.php');
$finance_focus=new Jijin_Accounts($focus);
echo $finance_focus->$method();
exit();
?>
