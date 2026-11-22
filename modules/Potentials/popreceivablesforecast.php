<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//require_once("Smarty_setup.php");
global $adb;
global $current_user,$currentModule;
require('user_privileges/user_language_'.$current_user->id.'.php');
$currencyobj = Currency::getInstance($adb);
$smarty = new lingdangCRM_Smarty;
$SendPaymentSetting='100.00';
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
	ifnull(amount, 0),potentialsid,periodtime,currency_id,conversion_rate
    FROM
	ld_receivablesforecast 
where potentialsid =  ".$_REQUEST['potentialsid'].' order by periodtime asc';
$paymentresult=$adb->pquery($sql,array());

$sqlpotential='SELECT
	amount,currency_id,conversion_rate
FROM
	ld_potential
WHERE
	potentialid = '.$_REQUEST['potentialsid'];
   
$potentialresult=$adb->pquery($sqlpotential,array());

// 获取系统参数配置信息
//$sqldeploy = 'select deploy_value from ld_systems_deploy where deploy_type = 20';
//$sqldeployresult=$adb->pquery($sqldeploy,array());
$deployarray=getSys_deploy(54);
$deployvalue = $deployarray['deploy_value'];
$smarty->assign("DEPLOYVALUE",$deployvalue);

//
$vendorname="";
$purchaseorder_no="";
$total=0.00;
$subtotal=0.00;
$paymentamount=0.00;
$periodtime=1;
if($adb->num_rows($potentialresult)>0)
{
    $total=$adb->query_result($potentialresult,0,"amount");
    $currency_id = $adb->query_result($potentialresult,0,"currency_id");//获取销售机会的币种ID
    $conversion_rate = $adb->query_result($potentialresult,0,"conversion_rate");//获取销售机会的汇率
    $smarty->assign("FORMATPOTENTIALAMOUNT",number_format($total,2));
    $smarty->assign("POTENTIALAMOUNT",$total);
    $smarty->assign("CURRENCYID",$currency_id);
    
}
else 
{
    $smarty->assign("FORMATPOTENTIALAMOUNT",0);
    $smarty->assign("POTENTIALAMOUNT",0);
    $smarty->assign("CURRENCYID",1);//如果没有销售机会，则默认为1 人民币
}
$smarty->assign('ALLCURRENCY',$currencyobj->getAllCurrencies());
//按照期次降序排序
//Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 1:55
crm_load_class_file("cls_PickList", 'modules/PickList');
$objpinklist = new cls_PickList();
$periodresult = $objpinklist->getPickListValues('cpperiodtime','');
arsort($periodresult);
/*$sqlperiod="select cpperiodtime from ld_cpperiodtime order by cpperiodtime desc ";
$periodresult=$adb->pquery($sqlperiod,array());*/

$smarty->assign("POTENTIALID",$_REQUEST['potentialsid']);
$paymentamount=0;
//负责人
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Me']);//去除"我的"
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_All']);//全部
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_SubRole']);//我下属的
unset($MergeSmowner["OtherInfo"]['SmOwner_Search_Create']); //SmOwner_Search_Create
$smarty->assign("MERGEOWNER",$MergeSmowner);
$smarty->assign('MODULE',$currentModule);
$smarty->assign("SelectedOwner2",$current_user->id);
$smarty->assign("ISADMIN",$current_user->is_admin);

echo "####:###";
$smarty->assign("NOWDATE",date("Y-m-d"));

if($adb->num_rows($paymentresult)>0)//如果有回款预测
{
    for($i=0;$i<$adb->num_rows($paymentresult);$i++)
    {
        $is_currency_id = $adb->query_result($paymentresult,$i,'currency_id');//获取回款预测的币种ID
        $is_conversion_rate = $adb->query_result($paymentresult,$i,'conversion_rate');//获取回款预测币种汇率
        $amount = $adb->query_result($paymentresult,$i,0);//获取回款预测的合计计划金额
        if($currency_id != $is_currency_id)
        {
            //如果销售机会的币种ID为人民币
            if($currency_id == 1)
            {
                $amount = $amount/$is_conversion_rate;//0014857: 销售机会>明细,关于创建回款预测金额计算错误的问题
            }
            else
            {
                //echo $amount . $conversion_rate;
                $amount = $amount*$is_conversion_rate/$conversion_rate;
            }
                
        }
        $paymentamount+=$amount;   
       //获取该回款预测最大期次
        //（因为查询排序时按照期次升序排序)
        $periodtime=$adb->query_result($paymentresult,$i,2);
    }
    $nopopreceivablesforecastamount=0.00;
    
    $nopopreceivablesforecastamount=floatval ($total)-floatval($paymentamount);
  
    if($nopopreceivablesforecastamount < 0)
    {
        $nopopreceivablesforecastamount = 0;
    }    

    if($deployvalue == 1)
    {
        if($nopopreceivablesforecastamount<=0)
        {
            $_REQUEST['diony']='diony';
			ConvertTojsonString(-1,array(),"success");
        }   
    }
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 2:13
    if(!empty($periodresult)){
        //判断最大期次+1在期次下拉框表中是否存在
        if($periodtime<current($periodresult))//如果小于最大期次
        {
            $periodtime=$periodtime+1;
        }
    }
    /*if($adb->num_rows($periodresult)>0)
    {
        //判断最大期次+1在期次下拉框表中是否存在
        if($periodtime<$adb->query_result($periodresult,0,0))//如果小于最大期次
        {
            $periodtime=$periodtime+1;
        }
    }*/
    
    $smarty->assign("FORMATNOPOPRECEIVABLESFORECASTAMOUNT",number_format($nopopreceivablesforecastamount,2));
    $smarty->assign("NOPOPRECEIVABLESFORECASTAMOUNT",sprintf("%.2f",$nopopreceivablesforecastamount));
    $smarty->assign("PERIODTIME",$periodtime);
    $smarty->assign("PLANDATE",date("Y-m-d"));
    $title = getFixedLabel('EDITreceivablesforecast');
    $tpl="modules/receivablesforecast/havereceivablesforecast.tpl";
    
}
else //如果没有付款计划
{
   
   //获取最小的期次值
    //$periodtime=$adb->query_result($periodresult,$adb->num_rows($periodresult)-1,0);
	$periodtime = 1;
    
    //未计划金额等于订单金额
    $purchaseorderamount=$total;
   // echo $subtotal;
    
    $smarty->assign("FORMATNOPOPRECEIVABLESFORECASTAMOUNT",number_format($purchaseorderamount,2));
    $smarty->assign("NOPOPRECEIVABLESFORECASTAMOUNT",$purchaseorderamount);
    //期次
    $smarty->assign("PERIODTIME",$periodtime);
    
    //付款计划设置
    $setPaymentarr=explode(",",$SendPaymentSetting);
    $setperiodtimearr=explode(",",$periodtimes);
    $paymenttr="";
    for($i=1;$i<=count($setPaymentarr);$i++)
    {
       // echo $setPaymentarr[$i-1]."<br>";
        $amount=$purchaseorderamount*$setPaymentarr[$i-1]/100;
        $j=$i-1;
        $plandate=date("Y-m-d", strtotime("+$j month"));
        
        $paymenttr.="<tr id='row".$i."'>
                        <td align='center'><i class='ld-fonticon ld-fonticon-del' onclick='deletetr(this)'></i></td>
                        <input type='hidden' name='periodtime".$i."'  value='" . $periodtime."' id='periodtime".$i."' size='10' >
                        <td><input type='text' name='ratio".$i."' value='" .sprintf("%.2f", $setPaymentarr[$i-1])."' id='ratio".$i."' onchange=changeamountn(this,'amount".$i."','ratio".$i."','".$purchaseorderamount."'); size='10' class='ld-input-inner gwidth100'></td>
                        <td><input type='text' name='amount".$i."' value='" . sprintf("%.2f",$amount)."' id='amount".$i."' size='10' onchange=changeratio(this,'ratio".$i."','amount".$i."','".$purchaseorderamount."'); class='ld-input-inner gwidth100'></td>
                        <td class='ld-form-item-content'>
                            <input type='text' size='15' readonly='true' id='plandate".$i."' value='".$plandate."' onClick='WdatePicker()' class='Wdate ld-input-inner' name='plandate".$i."'/>
                        </td>
                    </tr>";
        $periodtime=$periodtime+1;
                        
    }
	$tpl="modules/receivablesforecast/noreceivablesforecast.tpl";
	$title = getFixedLabel('Createreceivablesforecast');
	$smarty->assign("SENDPAYMENTSETTING",$paymenttr);
   
}
$_REQUEST['diony']='diony';
$t_arr['title']=$title;
$t_arr['oktext']=getFixedLabel("SAVE");
$t_arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch($tpl);
$t_arr['content']=$str;
ConvertTojsonString(1,$t_arr,"success");
unset($adb);
unset($current_user);
 exit();
?>