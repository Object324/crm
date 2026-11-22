<?php
 global $adb,$current_user;
$bankaccountsetid=$_REQUEST['bankaccountsetid'];
$allviewids=$_REQUEST['owners'];
$sql="DELETE  from ld_bankaccountprofile where Bankaccountsetid=$bankaccountsetid";
$adb->pquery($sql);

if($_REQUEST['aa']=='Y'){
    $sql='insert into ld_bankaccountprofile(bankaccountsetid,userid)values(?,?)';
 
    $adb->pquery($sql,array($bankaccountsetid,'-1'));
}elseif($_REQUEST['aa']=='N')
{
    
    $allviewids = explode(",",$allviewids);
    
    foreach($allviewids as $key=>$arr){
        $sql='insert into ld_bankaccountprofile(bankaccountsetid,userid)values(?,?)';
       
        $adb->pquery($sql,array($bankaccountsetid,$arr));
    }
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");

//header("Location:index.php?module=BankAccountSet&parenttab=Finacial&action=DetailView&record=".$potentialid);
?>