<?php

/**
 * @author phpadmin
 * @copyright 2014
 */
//echo "<pre>";
//print_r($_REQUEST);
//$smarty = new lingdangCRM_Smarty();
if(isset($_REQUEST['ajax']) && ($_REQUEST['ajax'] =='true')) {
    $userid=$_REQUEST['userid'];
    $year=$_REQUEST['year'];
    $month=$_REQUEST['month'];
    $value=$_REQUEST['val'];
    $type=$_REQUEST['type'];
    switch($type)
    {
        case 1:
            $sqlname = 'paymentamount';
            break;
        case 2:
            $sqlname = 'contractamount';
            break;
        case 3:
            $sqlname = 'accountsnumber';
            break;    
    }
    $sql = "select * from ld_salestarget where userid = ? and targetyear = ? and targetmouth = ?";
    //echo $sql;exit;
    $result = $adb->pquery($sql,array($userid,$year,$month));
    //echo $adb->num_rows($result).'========';
    if($adb->num_rows($result) > 0)
    {
        $sql_update="UPDATE ld_salestarget SET $sqlname=? where userid=? AND targetmouth=? and targetyear=?";
        $result_update = $adb->pquery($sql_update,array($value,$userid,$month,$year));
    }
    else
    {   if($type==1)
        {
           $sql_insert="INSERT into  ld_salestarget (userid,targetyear,targetmouth,paymentamount) VALUES (?,?,?,?) "; 
        }
        if($type==2)
        {
           $sql_insert="INSERT into  ld_salestarget (userid,targetyear,targetmouth,contractamount) VALUES (?,?,?,?) "; 
        }
        if($type==3)
        {
           $sql_insert="INSERT into  ld_salestarget (userid,targetyear,targetmouth,accountsnumber) VALUES (?,?,?,?) "; 
        }
        $result_update = $adb->pquery($sql_insert,array($userid,$year,$month,$value));
    }
}
else {
    require_once('include/Ajax/CommonAjax.php');

}


?>