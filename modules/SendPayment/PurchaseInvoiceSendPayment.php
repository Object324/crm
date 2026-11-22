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
$focus = CRMEntity::getInstance('PurchaseInvoice');
$focus->retrieve_entity_info($_REQUEST['purchaseinvoiceid'], "PurchaseInvoice");
$query = 'select approve_demand from ld_option_module where tabid = ? and option_tabid = ? and presence = 0';
$result = $adb->pquery($query,array(getTabid('SendPayment'),getTabid('PurchaseInvoice')));
$approve_demand = $adb->query_result($result,0,0);
if($approve_demand == 1){
	if($focus->column_fields['approvestatus'] != D_A_S_APPROVED){
		$_REQUEST['diony']='diony';
		ConvertTojsonString(-1,array(),getFixedLabel('NOTCREATERELVANTBILL'));
	}
}

$sfocus=CRMEntity::getInstance('SendPayment');
$fieldobj=$sfocus->fieldobj;
foreach($fieldobj->getModuleFields() as $fieldname=>$fieldinfo){
    if($fieldname == 'plandate'){
        $plandate_defaultvalue = $fieldinfo->getDefaultvalue();//计划回款日期默认值
    }
}
//ls 20220714 XUQIU1000446 创建收款计划时，·第一期计划收款日期·以及右下角的·首次收款日期·根据计划收款日期字段设置的默认时间带出,付款计划同理。
$plandate_value=date("Y-m-d");
if (!empty($plandate_defaultvalue)) {
    if(strpos(strtolower($plandate_defaultvalue),'afterday') !== false){
        $value_arr = explode('afterday',$plandate_defaultvalue);
        $day = $value_arr[1];
        $plandate_value=date("Y-m-d", strtotime("+".$day." day"));
    }
}

if(!is_file("user_privileges/ConfigSendPaymentSet.php"))
{
   $fp=fopen("user_privileges/ConfigSendPaymentSet.php","w+");
   fputs($fp,"<?php");
   fputs($fp,"\r\n");
   fputs($fp,"$"."SendPaymentSetting='30,50,20';");
   fputs($fp,"\r\n");
   fputs($fp,"$"."periodtimes='1,2,3';");
   fputs($fp,"\r\n");
   fputs($fp,"?>");
   
   fclose($fp);
   
}
include("user_privileges/ConfigSendPaymentSet.php");
//获取期次和计划收款日期经过控制面板中布局设置后的名称
$sqlfield="select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
  where ld_tranlabel.languagetype=? and trantable=? and tablename='ld_sendpayment' and columnname in('cpperiodtime','plandate','smownerid','description') order by columnname";

$fieldResult=$adb->pquery($sqlfield,array($languageType,'ld_field'));
$fieldperiod=$adb->query_result($fieldResult,0,0);
$fieldRemark=$adb->query_result($fieldResult,1,0);//备注字段
$fieldplandate=$adb->query_result($fieldResult,2,0);
$fieldAssignedTo=$adb->query_result($fieldResult,3,0);


$smarty->assign("PERIODTIMENAME",$fieldperiod);
$smarty->assign("PLANDATENAME",$fieldplandate);
$smarty->assign("PLANDASSIGNEDTO",$fieldAssignedTo);
$smarty->assign("PLANDREMARK",$fieldRemark);//备注字段

$sql="select ifnull(if(ld_sendpayment.currency_id > 1,amount/ld_sendpayment.conversion_rate,amount),0) as amount,purchaseorder_id,cpperiodtime,currency_id,conversion_rate,plandate from ld_sendpayment inner join ld_crmentity
      on ld_crmentity.crmid=ld_sendpayment.sendpaymentid  
    where ld_sendpayment.deleted=0 and purchaseorder_id= ".$_REQUEST['purchaseinvoiceid'].' and entitytype = "PurchaseInvoice" order by cpperiodtime asc';
$paymentresult=$adb->pquery($sql,array());
$sqlpurchaseorder='select ld_vendor.vendorname,purchaseinvoice_no,total,subtotal,ld_vendor.vendorid,currency_id,conversion_rate,ld_purchaseinvoice.smownerid from ld_purchaseinvoice left join ld_vendor on ld_purchaseinvoice.vendorid=ld_vendor.vendorid
                where purchaseinvoiceid= '.$_REQUEST['purchaseinvoiceid'];
$purchaseorderresult=$adb->pquery($sqlpurchaseorder,array());

// 获取系统参数配置信息
//$sqldeploy = 'select deploy_value from ld_systems_deploy where deploy_type = 20';
//$sqldeployresult=$adb->pquery($sqldeploy,array());
$deployarray=getSys_deploy(149);
$deployvalue = $deployarray['deploy_value'];
$smarty->assign("DEPLOYVALUE",$deployvalue);

//
$vendorname="";
$purchaseinvoice_no="";
$total=0.00;
$subtotal=0.00;
$paymentamount=0.00;
$periodtime=1;
if($adb->num_rows($purchaseorderresult)>0)
{
    $vendorname=$adb->query_result($purchaseorderresult,0,"vendorname");
    $purchaseinvoice_no=$adb->query_result($purchaseorderresult,0,"purchaseinvoice_no");
    $total=$adb->query_result($purchaseorderresult,0,"total");
    $currency_id=$adb->query_result($purchaseorderresult,0,"currency_id");
    $conversion_rate=$adb->query_result($purchaseorderresult,0,"conversion_rate");
    $smownerid=$adb->query_result($purchaseorderresult,0,"smownerid");
    $vendorid=$adb->query_result($purchaseorderresult,0,"vendorid");
    $smarty->assign("VENDORID",$vendorid);
    $smarty->assign("FORMATPURCHASEORDERAMOUNT",number_format($total+$subtotal,2));
    $smarty->assign("PURCHASEORDERAMOUNT",$total+$subtotal);
    
}
else 
{

     $smarty->assign("VENDORID",'');
    $smarty->assign("FORMATPURCHASEORDERAMOUNT",0);
    $smarty->assign("PURCHASEORDERAMOUNT",0);
}
$smarty->assign('ENTITYTYPE','PurchaseInvoice');
//按照期次降序排序
//Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 2:35
crm_load_class_file("cls_PickList", 'modules/PickList');
$objpinklist = new cls_PickList();
$periodresult = $objpinklist->getPickListValues('cpperiodtime',"",array(),"");
arsort($periodresult);
/*$sqlperiod="select cpperiodtime from ld_cpperiodtime order by cpperiodtime+0 desc ";//Liver20161219，加0是为了排序，原因是这个字段是varchar类型
$periodresult=$adb->pquery($sqlperiod,array());*/

$smarty->assign("VENDORNAME",$vendorname);
$smarty->assign("PURCHASEORDERNO",$purchaseinvoice_no);
$smarty->assign("PURCHASEORDERID",$_REQUEST['purchaseinvoiceid']);
$paymentamount=0;

//负责人

$MergeSmowner['UserCombo'] = get_select_options_array(get_user_array(FALSE, "Active", $current_user->id), $current_user->id);
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
$smarty->assign('CURRENCYID',$currency_id);
$smarty->assign('ALLCURRENCY',$currencyobj->getAllCurrencies());//币种
$smarty->assign("SelectedOwner2",$smownerid);
$smarty->assign("ISADMIN",$current_user->is_admin);

echo "####:###";
$smarty->assign("NOWDATE",$plandate_value);
$smarty->assign('IMMEDIATELYCREATE',$_REQUEST['Immediatelycreate']);
if($adb->num_rows($paymentresult)>0)//如果有付款计划
{
   //echo "have";
    for($i=0;$i<$adb->num_rows($paymentresult);$i++)
    {
        $paymentamount+=$adb->query_result($paymentresult,$i,0);//获取采购订单的合计计划金额
       //获取该采购订单最大期次
        //（因为查询排序时按照期次升序排序)
        $periodtime=$adb->query_result($paymentresult,$i,2);
        $last_plandate=$adb->query_result($paymentresult,$i,'plandate');//最后一次的计划回款日期
    }
    $nopaymentamount=0.00;
    if($currency_id != 1)
        $paymentamount = $paymentamount*$conversion_rate;
    $nopaymentamount=floatval ($total)-floatval($paymentamount);
  
    if($nopaymentamount < 0)
    {
        $nopaymentamount = 0;
    }    

    if($deployvalue == 1)
    {
        if($nopaymentamount<=0)
        {
			$_REQUEST['diony']='diony';
			ConvertTojsonString(-1,array(),getFixedLabel('ORDER1CREATED').getTranstab('SendPayment'));
            
        }   
    }
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 2:36
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
    
    $smarty->assign("FORMATNOPAYMENTAMOUNT",number_format($nopaymentamount,2));
    $smarty->assign("NOPAYMENTAMOUNT",sprintf("%.2f",$nopaymentamount));
    $smarty->assign("PERIODTIME",$periodtime);
    $smarty->assign("PLANDATE",date("Y-m-d", strtotime("+1 month",strtotime($last_plandate))));
    
    $tpl="modules/SendPayment/HavePayment.tpl";
	$title = getFixedLabel('EDIT').' '.getTranstab('SendPayment');
    
}
else //如果没有付款计划
{
   
   //获取最小的期次值
    //$periodtime=$adb->query_result($periodresult,$adb->num_rows($periodresult)-1,0);
	$periodtime = 1;
    
    //未计划金额等于订单金额
    $purchaseorderamount=$total;
   // echo $subtotal;
    
    $smarty->assign("FORMATNOPAYMENTAMOUNT",number_format($purchaseorderamount,2));
    $smarty->assign("NOPAYMENTAMOUNT",$purchaseorderamount);
    //期次
    $smarty->assign("PERIODTIME",$periodtime);
    
    //付款计划设置
    $setPaymentarr=explode(",",$SendPaymentSetting);
    $setperiodtimearr=explode(",",$periodtimes);
    $paymenttr="";
	$plandate=date("Y-m-d");
	$monthlastday = DateOperation::getMonthDays($plandate);//获取当月的总天数
    for($i=1;$i<=count($setPaymentarr);$i++)
    {
       // echo $setPaymentarr[$i-1]."<br>";
        $amount=$purchaseorderamount*$setPaymentarr[$i-1]/100;
        $j=$i-1;
		if($i > 1 && $monthlastday == date('d',strtotime($plandate))){
			$nextMonth = DateOperation::getNextMonthDays($plandate);
			$plandate = $nextMonth[1];
		}else{
			$plandate=date("Y-m-d", strtotime("+$j month",strtotime($plandate_value)));
		}
        $paymenttr.="<tr id='row".$i."'>
                        <td align='center'><i class='ld-fonticon ld-fonticon-del' onclick='deletetr(this)'></i></td>
                        <td><input type='text' class='ld-input-inner' name='periodtime".$i."'  value='" . $periodtime."' id='periodtime".$i."' size='10' ></td>
                        <td><input type='text' class='ld-input-inner' name='ratio".$i."' value='" .sprintf("%.2f", $setPaymentarr[$i-1])."' id='ratio".$i."' onchange=changeamountn(this,'amount".$i."','ratio".$i."','".$purchaseorderamount."'); size='10'></td>
                        <td><input type='text' class='ld-input-inner' name='amount".$i."' value='" . sprintf("%.2f",$amount)."' id='amount".$i."' size='20' onchange=changeratio(this,'ratio".$i."','amount".$i."','".$purchaseorderamount."');></td>
                        <td class='ld-form-item-content'>
                            <input type='text' size='15' readonly='true' id='plandate".$i."' value='".$plandate."' name='plandate".$i."' onClick='WdatePicker()' class='Wdate ld-input-inner'/>    
                        </td>
                          <td><textarea name='description".$i."'  value='' id='description".$i."'  cols='100%' class='ld-textarea-inner' style='height: 30px;'></textarea></td>
                    </tr>";
        $periodtime=$periodtime+1;
                        
    }

   $smarty->assign("SENDPAYMENTSETTING",$paymenttr);
   $tpl="modules/SendPayment/NoSendPayment.tpl";
   //edit:can 20210201 043960: （61mis.com/kfbcrm）财务管理-采购发票-相关信息-收款计划-新建（需要补丁）；新建收款计划时，若收款金额少于未计划金额，弹出层信息有误，且确认保存或取消后界面变灰色；
   $title = getFixedLabel('CREATE').' '.getTranstab('SendPayment');
   
}
$_REQUEST['diony']='diony';
$t_arr['title']=$title;
$t_arr['oktext']=getFixedLabel("SAVE");
$t_arr['canceltext']=getFixedLabel("CANCEL");
$t_arr['selectedlastname']=$selectedlastname;
$t_arr['user_arr']=$user_arr;
$str=$smarty->fetch($tpl);
$t_arr['content']=$str;
ConvertTojsonString(1,$t_arr,"success");
unset($adb);
unset($current_user);
 exit();
?>