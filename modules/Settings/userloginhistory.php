<?php

/**
 * @author phpadmin
 * @copyright 2014
 */
global $adb;

$sql="  
    select max(ld2.login_time) as login_time,ld1.phone,ld1.cversion,ld2.user_login_ip,ld2.user_login_ip_city, count(*) as scount 
    from ld_userlogincheck ld1 
    inner join ld_userloginhistroy ld2 ON ld1.id = ld2.code_id WHERE  1=1";
if(isset($_REQUEST['startmonth']) && $_REQUEST['startmonth'] != '' && isset($_REQUEST['endmonth']) && $_REQUEST['endmonth'] != '')
{
    $sql.=" and login_time >= '{$_REQUEST['startmonth']}' and login_time <= '{$_REQUEST['endmonth']}'";
}
if(isset($_REQUEST['cversion']) && $_REQUEST['cversion'] != '' )
{
    if($_REQUEST['cversion'] !='全部'){
        $sql.=" and ld1.cversion  = '{$_REQUEST['cversion']}'";
    }
    
}
if(isset($_REQUEST['city']) && $_REQUEST['city'] != '' )
{
    if($_REQUEST['city'] !='全部'){
        $sql.=" and ld2.user_login_ip_city  = '{$_REQUEST['city']}' ";
    }
    
}
if(isset($_REQUEST['phone']) && $_REQUEST['phone'] != '' )
{
    if($_REQUEST['city'] !=''){
        $sql.=" and ld1.phone  = '{$_REQUEST['phone']}' ";
    }
    
}
$sql.=" GROUP BY ld1.phone,ld1.cversion 
    order by  login_time DESC";

$result=$adb->query($sql);
//城市
$sql_city="SELECT Ctitle from t_public";
$result_city=$adb->query($sql_city);

$datemonth=date("Y-m");
$startdatemonth=$datemonth.'-01';
$enddatemonth=$datemonth.'-'.date(t,strtotime($datemonth));

$smarty->assign('startdatemonth',$startdatemonth);
$smarty->assign('enddatemonth',$enddatemonth);

$smarty->assign('result_city',$result_city);

$smarty->assign('result',$result);
if($_REQUEST['ajax'] == 'true'){
     echo '###SUCCESS###';
     $smarty->display("Settings/userloginnalysisAjax.tpl");
     exit();
}else{
    $smarty->display('userloginnalysis.tpl');
}



?>