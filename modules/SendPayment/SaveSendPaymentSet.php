<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

$i=1;

include("user_privileges/ConfigSendPaymentSet.php");
$arrpercent= array();
$arrperiodtime= array();
while(true)
{
    if(!isset($_REQUEST['percent'.$i]))
    {
        break;
    }
    $arrpercent[]=$_REQUEST['percent'.$i];
    $arrperiodtime[]=$_REQUEST['periodtime'.$i];
    $i++;
    
}

$SendPaymentSetting=implode(",",$arrpercent);

$periodtimes=implode(",",$arrperiodtime);
 $fp=fopen("user_privileges/ConfigSendPaymentSet.php","w+");
   fputs($fp,"<?php");
   fputs($fp,"\r\n");
   fputs($fp,"$"."SendPaymentSetting='".$SendPaymentSetting."';");
   fputs($fp,"\r\n");
   fputs($fp,"$"."periodtimes='".$periodtimes."';");
   fputs($fp,"\r\n");
   fputs($fp,"?>");
   
   fclose($fp);
  //zkt 20220531 51751（https://81mis.com/kfbtest/index.php）采购订单》相关创建付款计划，“设置付款计划默认期次和付款比例”保存失败
 if(function_exists("opcache_invalidate"))
 {
    opcache_invalidate(globalStatic::$root_directory."user_privileges/ConfigSendPaymentSet.php",true);
 }
$_REQUEST['diony']='diony';

ConvertTojsonString(1,array(),"success");

?>