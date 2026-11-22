<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

global $adb;
$sa=$_REQUEST['sa'];
$pwd=$_REQUEST['pwd'];
$hostname=$_REQUEST['hostname'];
$databasename=$_REQUEST['databasename'];
$demoname=$_REQUEST['demo_name'];
$softfactory=$_REQUEST['soft_factory'];
if($softfactory == '金蝶'){
	$softversion=$_REQUEST['soft_version'];
}elseif($softfactory == '用友'){
	$softversion=$_REQUEST['soft_version_1'];
}else{
    $softversion=$_REQUEST['soft_version_2'];
}
$usingorder=$_REQUEST['using_order'];

if(empty($usingorder))
{
    $usingorder = 0;
}
$usingcredence=$_REQUEST['using_credence'];
if(empty($usingcredence))
{
    $usingcredence = 0;
}
$usinginventory=$_REQUEST['using_inventory'];
if(empty($usinginventory))
{
    $usinginventory = 0;
}
$using_order_read=$_REQUEST['using_order_read'];
if(empty($using_order_read))
{
    $using_order_read = 0;
}
$using_quote_read=$_REQUEST['using_quote_read'];
if(empty($using_quote_read))
{
    $using_quote_read = 0;
}
$using_ticket_read=$_REQUEST['using_ticket_read'];
if(empty($using_ticket_read))
{
    $using_ticket_read = 0;
}
$setting_mode=$_REQUEST['setting_mode'];
if(empty($setting_mode))
{
    $setting_mode = 1;
}
/*if(empty($demoname))
{
    //$usingorder = 0;
    //$usingcredence = 0;
    //$usinginventory = 0;
}*/
//连接方式
$connect_mode = $_REQUEST['connect_mode'];
if($_REQUEST['facetype'])
{
    //$HTTP_POST_VARS
     
      $hostname=$_FILES['file_demo_name']['tmp_name'];
      $databasename=$hostname;
      echo "<script>alert('".$HTTP_POST_VARS['file_demo_name']."')</script>";
      echo "<script>window.parent.puyoungJS_DialogBox.unblock();</script>";
      exit();
        $AccessCon=new AccessServer($databasename,$sa,$PassWord);
        $conResult=$AccessCon->Connect();
        if($conResult=="1")
        {
             
           
            $demoname="";
            echo "<script>alert('".$hostname."')</script>";
            exit();
        }
        else 
        {
            echo "<script>alert('".$conResult."')</script>";
            exit();
        }
        
}

$sql="delete from ld_datainterface";
$adb->pquery($sql,array());
$sql="insert into ld_datainterface(ID,soft_factory,soft_version,sa,pwd,demo_name,databasename,hostname,using_order,using_credence,using_inventory,using_order_read,using_quote_read,using_ticket_read,setting_mode,connect_mode)values
            (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
            
$adb->pquery($sql,array(1,$softfactory,$softversion,$sa,$pwd,$demoname,$databasename,$hostname,$usingorder,$usingcredence,$usinginventory,$using_order_read,$using_quote_read,$using_ticket_read,$setting_mode,$connect_mode));
//重新生成缓存文件，我故意传值为'aa';
getDatainterface('aa');
$loc = "Location: index.php?action=KISSetting&module=Settings&parenttab=Settings&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting'];

if(!$_REQUEST['facetype'])
{   
    header($loc);
}
else 
{
    echo "<script> window.parent.location.href='Location: index.php?action=KISSetting&module=Settings&parenttab=Settings'</script>";
}



?>