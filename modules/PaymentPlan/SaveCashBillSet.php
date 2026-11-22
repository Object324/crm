<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

$i=1;

include("user_privileges/ConfigCashBillSet.php");
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

$PaymentPlanSetting=implode(",",$arrpercent);

$periodtimes=implode(",",$arrperiodtime);
 $fp=fopen("user_privileges/ConfigCashBillSet.php","w+");
   fputs($fp,"<?php");
   fputs($fp,"\r\n");
   fputs($fp,"$"."PaymentPlanSetting='".$PaymentPlanSetting."';");
   fputs($fp,"\r\n");
   fputs($fp,"$"."periodtimes='".$periodtimes."';");
   fputs($fp,"\r\n");
   fputs($fp,"?>");
   
   fclose($fp);
 
 //edit:can 20211011 48197: （81mis.com/kfbtest）合同订单详情》创建收款计划，设置收款比例，保存没有生效
 if(function_exists("opcache_invalidate"))
 {
    opcache_invalidate(globalStatic::$root_directory."user_privileges/ConfigCashBillSet.php",true);
 }
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>