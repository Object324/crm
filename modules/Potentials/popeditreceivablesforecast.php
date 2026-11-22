<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//require_once("Smarty_setup.php");
global $adb;
global $current_user,$currentModule;
$languageType= getLanguageType($current_user);
$currencyobj = Currency::getInstance($adb);
$smarty = new lingdangCRM_Smarty;

//获取期次和计划收款日期经过控制面板中布局设置后的名称
$sqlfield="select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
  where ld_tranlabel.languagetype=? and trantable=? and tablename='ld_sendpayment' and columnname in('cpperiodtime','plandate','smownerid') order by columnname";

$fieldResult=$adb->pquery($sqlfield,array($languageType,'ld_field'));
$fieldperiod=$adb->query_result($fieldResult,0,0);
$fieldplandate=$adb->query_result($fieldResult,1,0);
$fieldAssignedTo=$adb->query_result($fieldResult,2,0);

$smarty->assign("PERIODTIMENAME",$fieldperiod);
$smarty->assign("PLANDATENAME",$fieldplandate);
$smarty->assign("PLANDASSIGNEDTO",$fieldAssignedTo);

$sql="SELECT
	ifnull(amount, 0) as amount,total,currency_id,
	potentialsid,
	periodtime,receivablesforecastid,receivablesforecastdate 
FROM
	ld_receivablesforecast 
where receivablesforecastid =  ".$_REQUEST['receivablesforecastid'].' limit 1';
    $paymentresult=$adb->pquery($sql,array());
    $amount=$adb->query_result($paymentresult,0,'amount');
    $potentialsid=$adb->query_result($paymentresult,0,'potentialsid');
   $totals=$adb->query_result($paymentresult,0,'total');
    $plandate=$adb->query_result($paymentresult,0,'receivablesforecastdate');
    $currency_id = $adb->query_result($paymentresult,0,'currency_id');

$smarty->assign("CURRENCYID",$currency_id);
// 获取系统参数配置信息
$deployarray=getSys_deploy(54);
$deployvalue = $deployarray['deploy_value'];
$smarty->assign("DEPLOYVALUE",$deployvalue);

    $total=$totals;
    $smarty->assign("FORMATPOTENTIALAMOUNT",number_format($total,2));
    $smarty->assign("POTENTIALAMOUNT",$total);
  
$smarty->assign("POTENTIALID",$potentialsid);
$paymentamount=0;

//负责人
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Me']);//去除"我的"
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_All']);//全部
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_SubRole']);//我下属的
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Create']); //SmOwner_Search_Create
$smarty->assign("MERGEOWNER",$MergeSmowner);

$smarty->assign('ALLCURRENCY',$currencyobj->getAllCurrencies());
$smarty->assign("SelectedOwner2",$current_user->id);
$smarty->assign("ISADMIN",$current_user->is_admin);

$smarty->assign("NOWDATE",date("Y-m-d"));
    $sqlss="SELECT
	total-sum(ifnull(amount, 0)) as amount 
FROM
	ld_receivablesforecast 
where potentialsid =  ".$potentialsid.' group by potentialsid';

    $paymentresultgroup=$adb->pquery($sqlss,array());
        $groupamount=$adb->query_result($paymentresultgroup,0,'amount');
     
    $smarty->assign("FORMATNOPOPRECEIVABLESFORECASTAMOUNT",number_format($groupamount,2));
    $smarty->assign("NOPOPRECEIVABLESFORECASTAMOUNT",$groupamount);
    $paymenttr="";
        $i=1;
        $raido=$totals/$amount;
        $j=$i-1;
        
        $paymenttr.="<tr id='row".$i."'>
                        <td><input type='text' name='amount".$i."' value='" . sprintf("%.2f",$amount)."' id='amount".$i."' size='10'></td>
                        <td>
                            <input type='text' size='15' readonly='true' id='plandate".$i."' value='".$plandate."' onClick='WdatePicker()' class='Wdate' name='plandate".$i."'/>
                            
                        </td>
                    </tr>";
    $smarty->assign("EDITYPE",1);
    $smarty->assign("REID",$_REQUEST['receivablesforecastid']);
    $smarty->assign("SENDPAYMENTSETTING",$paymenttr);
	$_REQUEST['diony']='diony';
	$t_arr['title']=getFixedLabel('EDITreceivablesforecast');;
	$t_arr['oktext']=getFixedLabel("SAVE");
	$t_arr['canceltext']=getFixedLabel("CANCEL");
	$str=$smarty->fetch("modules/receivablesforecast/editnoreceivablesforecast.tpl");
	$t_arr['content']=$str;
	ConvertTojsonString(1,$t_arr,"success");
    $smarty->display("modules/receivablesforecast/editnoreceivablesforecast.tpl");
   

unset($adb);
unset($current_user);
 exit();
?>