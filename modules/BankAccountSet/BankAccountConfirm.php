<?php
global $adb,$current_user;
    $nowdatetime = date('Y-m-d H:i:s',time());
    $sql = "update ld_bankaccountset set confirmed=1,curbalancemoney=initmoney,confirmtime='$nowdatetime',confirmby='$current_user->id' where bankaccountsetid=".$_REQUEST['record']; 
    $adb->pquery($sql);

    $_REQUEST['diony'] = 'yes';
    ConvertTojsonString(1, array(), "success");
//   	header("Location: index.php?module=BankAccountSet&action=BankAccountSetAjax&ajax=delete".$rstart."&file=ListView&viewname=".$viewid."&errormsg=".$errormsg.$url."&SearchScope=".$SearchScope);
?>