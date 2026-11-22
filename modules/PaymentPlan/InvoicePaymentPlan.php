<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//require_once("Smarty_setup.php");
global $adb;
global $current_user,$currentModule;
$_REQUEST['diony']='diony';
getLanguageType($current_user);
$currencyobj = Currency::getInstance($adb);
$smarty = new lingdangCRM_Smarty;
$focus = CRMEntity::getInstance('Invoice');
$focus->retrieve_entity_info($_REQUEST['invoiceid'], "Invoice");
$query = 'select approve_demand from ld_option_module where tabid = ? and option_tabid = ? and presence = 0';
$result = $adb->pquery($query,array(getTabid('PaymentPlan'),getTabid('Invoice')));
$approve_demand = $adb->query_result($result,0,0);
if($approve_demand == 1){
	if($focus->column_fields['approvestatus'] != D_A_S_APPROVED){
		$_REQUEST['diony']='diony';
		ConvertTojsonString(-1,array(),getFixedLabel('NOTCREATERELVANTBILL'));
	}
}

//ls 20220714 XUQIU1000446 创建收款计划时，·第一期计划收款日期·以及右下角的·首次收款日期·根据计划收款日期字段设置的默认时间带出,付款计划同理。
$pfocus=CRMEntity::getInstance('PaymentPlan');
$fieldobj=$pfocus->fieldobj;
$payemnttype_value = 'no';
foreach($fieldobj->getModuleFields() as $fieldname=>$fieldinfo){
    if($fieldname == 'plandate'){
        $plandate_defaultvalue = $fieldinfo->getDefaultvalue();//计划收款日期默认值
    }
}
$plandate_value=date("Y-m-d");
if (!empty($plandate_defaultvalue)) {
    if(strpos(strtolower($plandate_defaultvalue),'afterday') !== false){
        $value_arr = explode('afterday',$plandate_defaultvalue);
        $day = $value_arr[1];
        $plandate_value=date("Y-m-d", strtotime("+".$day." day"));
    }
}

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
//$PaymentPlanSetting='100.00';
//$periodtimes='1';

//获取期次和计划收款日期经过控制面板中布局设置后的名称
$sqlfield="select ld_tranlabel.fieldlabel,ld_field.typeofdata  from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
  where ld_tranlabel.languagetype=? and trantable=? and tablename='ld_paymentplan' and columnname in('periodtime','plandate','smownerid','description','paymenttype') order by columnname";

$fieldResult=$adb->pquery($sqlfield,array($languageType,'ld_field'));
$paymenttype=$adb->query_result($fieldResult,1,0);
$fieldperiod=$adb->query_result($fieldResult,2,0);
$fieldplandate=$adb->query_result($fieldResult,3,0);
$fieldAssignedTo=$adb->query_result($fieldResult,4,0);
$fieldRemark=$adb->query_result($fieldResult,0,0);//备注字段
$typeofdata=$adb->query_result($fieldResult,0,'typeofdata');//
$typeofdatas=explode("~",$typeofdata);

$smarty->assign('PAYMENTTYPE',$paymenttype);
$smarty->assign("PERIODTIMENAME",$fieldperiod);
$smarty->assign("PLANDATENAME",$fieldplandate);
$smarty->assign("PLANDASSIGNEDTO",$fieldAssignedTo);
$smarty->assign("PLANDREMARK",$fieldRemark);//备注字段
$smarty->assign('PLANREMARKTYPEOFDATA',strtolower($typeofdatas[1]));//
//edit:can 2020-10-12 042864: 销售发票->创建收款计划->收款计划类型：默认显示为“计划收款日期”，该标签是在 Invoiceinfo.tpl 中写死的
$sql="
select * from  ld_picklist_values 
INNER JOIN ld_picklist_set on ld_picklist_set.listid=ld_picklist_values.listid
where listname='paymenttype'  ORDER BY  id asc ;
";
$result=$adb->pquery($sql,array());
$paymenttype=$adb->query_result($result,0,'listvalue');
$smarty->assign("paymenttype",$paymenttype);

$sql="select ifnull(if(currency_id>1,amount*conversion_rate,amount),0),entitytypeid,periodtime,currency_id,conversion_rate,plandate from ld_paymentplan 
    where ld_paymentplan.deleted=0 and entitytypeid= ".$_REQUEST['invoiceid']." and entitytype='Invoice' order by periodtime asc ";

$paymentresult=$adb->pquery($sql,array());
$query='select ld_invoice.smownerid,ld_account.accountname,invoice_no,ld_invoice.total,subtotal,ld_account.accountid,ld_invoice.currency_id,
    ld_invoice.conversion_rate 
from ld_invoice left join ld_account on ld_invoice.accountid=ld_account.accountid
                where invoiceid= '.$_REQUEST['invoiceid'];
$result=$adb->pquery($query,array());

// 获取系统参数配置信息:设置销售发票关联创建回款计划时是否控制回款计划总金额等于销售发票金额
$deployarray=getSys_deploy(147);
$deployvalue = $deployarray['deploy_value'];
$smarty->assign("DEPLOYVALUE",$deployvalue);

$accountname="";
$invoice_no="";
$total=0.00;
$subtotal=0.00;
$paymentamount=0.00;
$periodtime=1;
 
if($adb->num_rows($result)>0)
{
    $accountname=$adb->query_result($result,0,"accountname");
    $invoice_no=$adb->query_result($result,0,"invoice_no");
    $total=$adb->query_result($result,0,"total");
	$smownerid = $adb->query_result($result,0,"smownerid");
    //$subtotal=$adb->query_result($result,0,"subtotal");
    $accountid=$adb->query_result($result,0,"accountid");
	$currency_id=$adb->query_result($result,0,"currency_id");
    $conversion_rate=$adb->query_result($result,0,"conversion_rate");
    $smarty->assign("ACCOUNTID",$accountid);
    $smarty->assign("formatSERVICECONTRACTSRESULTAMOUNT",number_format($total+$subtotal,2));
    $smarty->assign("SERVICECONTRACTSRESULTAMOUNT",$total+$subtotal);
    
}
else 
{
    //echo "####:###";
  //  echo "合同订单或客户不存在!";
   // exit();
     $smarty->assign("ACCOUNTID",'');
    $smarty->assign("formatSERVICECONTRACTSRESULTAMOUNT",0);
    $smarty->assign("SERVICECONTRACTSRESULTAMOUNT",0);
}
//按照期次降序排序
//Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 5:15
crm_load_class_file("cls_PickList", 'modules/PickList');
$objpinklist = new cls_PickList();
$result_pick = $objpinklist->getPickListValues('periodtime','',array(),'id');
arsort($result_pick);
/*$sqlperiod="select periodtime from ld_periodtime order by periodtime desc ";
$periodresult=$adb->pquery($sqlperiod,array());*/

$smarty->assign('CURRENCYID',$currency_id);
$smarty->assign('ALLCURRENCY',$currencyobj->getAllCurrencies());//币种
$smarty->assign("ACCOUNTNAME",$accountname);
$smarty->assign("CONTRACTNO",$contract_no);
$smarty->assign("INVOICEID",$_REQUEST['invoiceid']);
$paymentamount=0;

//负责人

$MergeSmowner['UserCombo'] = get_select_options_array(get_user_array(FALSE, "Active", $smownerid), $smownerid);
$smarty->assign("MERGEOWNER",$MergeSmowner);
$user_arr=[];
$selectedlastname='';

foreach($MergeSmowner['UserCombo'] as $tmp_userid=>$tmp_info )
{
    foreach($tmp_info as $tmp_lastname=>$selected)
    {
        $user_arr[$tmp_lastname]=$tmp_userid;
        if($tmp_userid==$smownerid)
            $selectedlastname=$tmp_lastname;
    }
}
$smarty->assign("SelectedOwner2",$smownerid);
$smarty->assign("ISADMIN",$current_user->is_admin);

$smarty->assign("NOWDATE",$plandate_value);
$smarty->assign('IMMEDIATELYCREATE',$_REQUEST['Immediatelycreate']);
 
if($adb->num_rows($paymentresult)>0)//如果有回款计划
{
   //echo "have";
    for($i=0;$i<$adb->num_rows($paymentresult);$i++)
    {
        $paymentamount+=$adb->query_result($paymentresult,$i,0);//获取合同订单的合计计划金额
		$is_currency_id = $adb->query_result($paymentresult,$i,'currency_id');//获取回款计划的币种
        $is_conversion_rate = $adb->query_result($paymentresult,$i,'conversion_rate');//获取回款计划的汇率
       //获取该合同订单最大期次
        //（因为查询排序时按照期次升序排序)
        $periodtime=$adb->query_result($paymentresult,$i,2);
        $last_plandate=$adb->query_result($paymentresult,$i,'plandate');//最后一次的计划收款日期
    }
    $nopaymentamount=0.00;
    $nopaymentamount=floatval ($total)*$conversion_rate-floatval($paymentamount);
  
    if($nopaymentamount < 0)
    {
        $nopaymentamount = 0;
    }    
    /*
    edit:chj
    date:201300814
    reason:创建回款计划按钮功能修改
    */
    if($deployvalue == 1)
    {
        if($nopaymentamount<=0)
        {
           
            ConvertTojsonString(-1,array(),getFixedLabel('ORDER1CREATED'). getTranstab('PaymentPlan'));
        }   
    }
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 5:19
    if(!empty($result_pick)){
        //判断最大期次+1在期次下拉框表中是否存在
        if($periodtime<current($result_pick))//如果小于最大期次
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
	$nopaymentamount = $nopaymentamount/$conversion_rate;
    $smarty->assign("formatNOPAYMENTAMOUNT",number_format($nopaymentamount,2));
    $smarty->assign("NOPAYMENTAMOUNT",sprintf("%.2f",$nopaymentamount));
    $smarty->assign("PERIODTIME",$periodtime);
    $smarty->assign("PLANDATE",date("Y-m-d", strtotime("+1 month",strtotime($last_plandate))));
   $title = getFixedLabel('EDIT').' '.getTranstab('PaymentPlan');
	$tpl="modules/Invoice/HavePayment.tpl";
}
else //如果没有回款计划
{
   
   //获取最小的期次值
    //$periodtime=$adb->query_result($periodresult,$adb->num_rows($periodresult)-1,0);
    $periodtime = 1;
     
    //未计划金额等于订单金额
    $servicecontractsamount=$total;
   // echo $subtotal;

    $smarty->assign("formatNOPAYMENTAMOUNT",number_format($servicecontractsamount,2));
    $smarty->assign("NOPAYMENTAMOUNT",$servicecontractsamount);
    //期次
    $smarty->assign("PERIODTIME",$periodtime);
    
    //回款计划设置
    $setPaymentarr=explode(",",$PaymentPlanSetting);
    $setperiodtimearr=explode(",",$periodtimes);
    $paymenttr="";
    $plandate=$plandate_value;
    $monthlastday = DateOperation::getMonthDays($plandate);//获取当月的总天数
    for($i=1;$i<=count($setPaymentarr);$i++)
    {
       // echo $setPaymentarr[$i-1]."<br>";
        $amount=$servicecontractsamount*$setPaymentarr[$i-1]/100;
        $j=$i-1;
        if($i > 1 && $monthlastday == date('d',strtotime($plandate))){
            $nextMonth = DateOperation::getNextMonthDays($plandate);
            $plandate = $nextMonth[1];
        }else{
            $plandate=date("Y-m-d", strtotime("+$j month",strtotime($plandate_value)));
        }
        
        $paymenttr.="<tr id='row".$i."'>
                        <td align='center'><i class='ld-fonticon ld-fonticon-del' onclick='deletetr(this)'></i></td>
                        <td><input type='text' name='periodtime".$i."'  value='" . $periodtime."' id='periodtime".$i."' size='10' class='ld-input-inner gwidth100'></td>
                        <td><input type='text' name='ratio".$i."' value='" . sprintf("%.2f", $setPaymentarr[$i-1]) ."' id='ratio".$i."' onchange=changeamountn(this,'amount".$i."','ratio".$i."','".$servicecontractsamount."'); size='10' class='ld-input-inner gwidth100'></td>
                        <td><input type='text' name='amount".$i."' value='" . sprintf("%.2f",$amount)."' id='amount".$i."' size='10' onchange=changeratio(this,'ratio".$i."','amount".$i."','".$servicecontractsamount."'); class='ld-input-inner gwidth100'></td>
                        <td class='ld-form-item-content'>";
            $paymenttr.="<input type='text' size='15' readonly='true' id='plandate".$i."' value='".$plandate."' name='plandate".$i."' onClick='WdatePicker()' class='Wdate ld-input-inner'/>
                    "; 
                  
        $paymenttr.="</td>
            <td><textarea name='description".$i."'  value='' id='description".$i."' cols='100%' class='ld-textarea-inner' style='height: 30px;'></textarea></td>
                    </tr>";
        $periodtime=$periodtime+1;
                        
    }
      $smarty->assign("PAYMENTPLANSETTING",$paymenttr);
   $tpl="modules/Invoice/NoPayment.tpl";
	$title = getFixedLabel('CREATE').' '.getTranstab('PaymentPlan');
}

unset($adb);
unset($current_user);

$t_arr['title']=$title;
$t_arr['oktext']=getFixedLabel("SAVE");
$t_arr['canceltext']=getFixedLabel("CANCEL");
$t_arr['selectedlastname']=$selectedlastname;
$t_arr['user_arr']=$user_arr;
$str=$smarty->fetch($tpl);
$t_arr['content']=$str;
ConvertTojsonString(1,$t_arr,"success");
exit();
?>