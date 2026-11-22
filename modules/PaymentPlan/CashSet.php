<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

require_once('Smarty_setup.php');
global $current_user;
require_once('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty();
if(!is_file("user_privileges/ConfigCashBillSet.php"))
{
   $fp=fopen("user_privileges/ConfigCashBillSet.php","w+");
   fputs($fp,"<?php");
   fputs($fp,"\r\n");
   fputs($fp,"$"."PaymentPlanSetting='30,50,20';");
   fputs($fp,"\r\n");
   fputs($fp,"$"."periodtimes='1,2,3';");
   fputs($fp,"\r\n");
   fputs($fp,"?>");
   
   fclose($fp);
   
}
include("user_privileges/ConfigCashBillSet.php");

$arrset=explode(",",$PaymentPlanSetting);
$arrperiodtime=explode(",",$periodtimes);

 $trset="";
for($i=0;$i<count($arrset);$i++)
{
    $j=$i+1;
    $trset.="<tr id=row$j>";
    $trset.='<td><input name="periodtime'.$j.'" id="periodtime'.$j.'" type="text" value="'.$arrperiodtime[$i].'" class="ld-input-inner" /></td>';
    $trset.='<td><input onchange="return percentChange(this)" name="percent'.$j.'" id="percent'.$j.'" type="text" value="'.$arrset[$i].'" class="ld-input-inner" /></td>';
    $trset.='<td align="center"><i class="ld-fonticon ld-fonticon-del" href="javascript:;" onclick="deletesettr(this)"></i></td>';
    $trset.="</tr>";
    
}

$smarty->assign("SALESORDERID",$_REQUEST['salesorderid']);
$smarty->assign("TRSET",$trset);
$sqlfield="select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
  where ld_tranlabel.languagetype=? and trantable=? and tablename='ld_paymentplan' and columnname in('periodtime') order by columnname";

$fieldResult=$adb->pquery($sqlfield,array($languageType,'ld_field'));
$fieldperiod=$adb->query_result($fieldResult,0,0);
$smarty->assign("PERIODTIMENAME",$fieldperiod);
$_REQUEST['diony']='diony';
$t_arr['title']=getFixedLabel('SETPAYPERCENT');
$t_arr['oktext']=getFixedLabel("SAVE");
$t_arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("modules/CashBill/SetCashBill.tpl");
$t_arr['content']=$str;
ConvertTojsonString(1,$t_arr,"success");
?>