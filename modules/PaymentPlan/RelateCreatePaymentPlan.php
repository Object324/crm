<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
//require_once("Smarty_setup.php");
global $adb;
global $current_user;
$frommodule=$_REQUEST['frommodule'];

require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
$fromfocus = CRMEntity::getInstance($frommodule);
if(!empty($_REQUEST['frommoduleid']) && $_REQUEST['frommoduleid'] > 0)
    $fromfocus->retrieve_entity_info($_REQUEST['frommoduleid'], $frommodule);
$query = 'select approve_demand from ld_option_module where tabid = ? and option_tabid = ? and presence = 0';
$result = $adb->pquery($query,array(getTabid('PaymentPlan'),getTabid($frommodule)));
$approve_demand = $adb->query_result($result,0,0);
if($approve_demand == 1){
	if($fromfocus->column_fields['approvestatus'] != D_A_S_APPROVED){
		$_REQUEST['diony']='diony';
		ConvertTojsonString(-1,array(),getFixedLabel('NOTCREATERELVANTBILL'));
	}
}
$focus=CRMEntity::getInstance('PaymentPlan');
$fieldobj=$focus->fieldobj;
$payemnttype_value = 'no';

foreach($fieldobj->getModuleFields() as $fieldname=>$fieldinfo){
	if($fieldname == 'paymenttype'){
		$payemnttype_value = $fieldinfo->getDefaultvalue();
	}elseif($fieldname == 'plandate'){
        $plandate_defaultvalue = $fieldinfo->getDefaultvalue();//计划收款日期默认值
    }
    //wym XUQIU1001598 收款计划增加单选“项目立项”字段，关联新建收款计划界面增加项目立项字段
    if($fieldname == 'projectid' && $fieldinfo->getUIType()==82){
        $refermodule= cls_module_uitype::getUitypeModule(82);
        $project_fieldonly = $fieldinfo->getfieldOnly();
        $project_fieldlabel= $fieldinfo->getfieldLabel();
        $project_fieldname= $fieldinfo->getFieldName();
        $smarty->assign('PROJECTISSHOW',1);
        $smarty->assign('REFERMODULE',$refermodule);
        $smarty->assign('FIELDONLY',$project_fieldonly);
        $smarty->assign('FIELDLABEL',$project_fieldlabel);
        $smarty->assign('FIELDNAME',$project_fieldname);
        $project_typeofdata=$fieldinfo->getTypeOfData();
        $typedata_arr = explode('~',$project_typeofdata);
        $smarty->assign('PROJECTTYPEOFDATA',strtolower($typedata_arr[1]));
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


if(!vtlib_isModuleActive('Project')){
	$payemnttype_value = 'noproject';
}
$smarty->assign('PAYMENTTYPEVALUE',$payemnttype_value);
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
//获取期次和计划收款日期经过控制面板中布局设置后的名称
$sqlfield="select ld_tranlabel.fieldlabel,ld_field.typeofdata from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
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
/**
 * 2016-09-14   Liver 
 * 排序由periodtime(期次)改为根据paymentplanid，原因是期次排序10会排到9前面
 *0024372: 合同订单明细：创建回款计划，录入多个期次后重算，再次创建回款计划时带出的期次不对 
 */
$sql="select ifnull(amount,0),periodtime,currency_id,conversion_rate,plandate from ld_paymentplan 
    where ld_paymentplan.deleted=0 and entitytypeid= ".$_REQUEST['frommoduleid'].' order by paymentplanid asc ';
//echo $sql;
$paymentresult=$adb->pquery($sql,array());
$tablename=$fromfocus->table_name;
$table_index=$fromfocus->table_index;
$list_linkfield=$fromfocus->list_link_field;
//收款计划，源单超链接为副表时错误，这里没使用，可以去掉查询

$sqlsalesorder="select $tablename.approvestatus, ld_account.accountname,total,subtotal,ld_account.accountid,
$tablename.currency_id,$tablename.conversion_rate,$tablename.smownerid
 from $tablename left join ld_account on $tablename.accountid=ld_account.accountid
 where $tablename.$table_index= ".$_REQUEST['frommoduleid'];
                
$saleorderresult=$adb->pquery($sqlsalesorder,array());
 

// 获取系统参数配置信息

$deployarray=getSys_deploy(1);
$deployvalue = $deployarray['deploy_value'];
$smarty->assign("DEPLOYVALUE",$deployvalue);

//
$accountname="";
$salesorder_no="";
$total=0.00;
$subtotal=0.00;
$paymentamount=0.00;
$periodtime=1;
if($adb->num_rows($saleorderresult)>0)
{
    $accountname=$adb->query_result($saleorderresult,0,"accountname");
    $salesorder_no=$adb->query_result($saleorderresult,0,"salesorder_no");
    $total=$adb->query_result($saleorderresult,0,"total");
    //$subtotal=$adb->query_result($saleorderresult,0,"subtotal");
    $accountid=$adb->query_result($saleorderresult,0,"accountid");
    $currency_id=$adb->query_result($saleorderresult,0,"currency_id");
    $conversion_rate=$adb->query_result($saleorderresult,0,"conversion_rate");
    $approvestatus=$adb->query_result($saleorderresult,0,'approvestatus');
	$smownerid=$adb->query_result($saleorderresult,0,'smownerid');
    $smarty->assign("ACCOUNTID",$accountid);
    $smarty->assign("formatSALESORDERAMOUNT",number_format($total+$subtotal,2));
    //zkt 20230816 BUG0071207 销售订单创建不了收款计划，金额一致却显示金额不一致。 
    $smarty->assign("SALESORDERAMOUNT",setNumberFormatEmptySeperator($total+$subtotal,2));
    
}
else 
{
    $approvestatus='';
     $smarty->assign("ACCOUNTID",'');
    $smarty->assign("formatSALESORDERAMOUNT",0);
    $smarty->assign("SALESORDERAMOUNT",0);
}
//按照期次降序排序
//Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 5:15
crm_load_class_file("cls_PickList", 'modules/PickList');
$objpinklist = new cls_PickList();
$result_pick = $objpinklist->getPickListValues('periodtime','',array(),'id');
arsort($result_pick);
/*$sqlperiod="select periodtime from ld_periodtime order by periodtime+0 desc ";//Liver 2016-12-19,排序不正确，因为字段是varchar类型，加0可以解决
$periodresult=$adb->pquery($sqlperiod,array());*/

$smarty->assign('CURRENCYID',$currency_id);
$currencyobj=Currency::getInstance($adb);
$smarty->assign('ALLCURRENCY',$currencyobj->getAllCurrencies());//币种
$smarty->assign("ACCOUNTNAME",$accountname);
$smarty->assign("SALESORDERNO",$salesorder_no);
$smarty->assign("SALESORDERID",$_REQUEST['frommoduleid']);
$paymentamount=0;

$MergeSmowner['UserCombo'] = get_select_options_array(get_user_array(FALSE, "Active", $current_user->id), $current_user->id);
//unset($MergeSmowner["OtherInfo"]['SmOwer_Search_MeToShare']);

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

$smarty->assign("User_Arr",$user_arr);
$smarty->assign("SelectedOwner2",$smownerid);
$smarty->assign("smownerid",$smownerid);
$smarty->assign("ISADMIN",$current_user->is_admin);
$smarty->assign('IMMEDIATELYCREATE',$_REQUEST['Immediatelycreate']);
$smarty->assign("NOWDATE",$plandate_value);
//Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 上午 11:55
crm_load_class_file("cls_PickList", 'modules/PickList');
$objpinklist = new cls_PickList();
$result_pick = $objpinklist->getPickListValues('projectstatus','',array(),'');
$paymenttype_pick = $objpinklist->getPickListValues('paymenttype','',array(),'');
$smarty->assign('PAYMENTTYPEPICK',$paymenttype_pick);
$pliststr = '';
//	0033622: 用户创建回款计划无法显示，客户说以前版本回款计划可以定义界面，把时间改成了项目阶段
$plistarr = array_values($result_pick);
foreach($result_pick as $value){
    $pliststr.=$value.',';
}

/*$sqllist='SELECT DISTINCT projectstatus FROM ld_projectstatus WHERE presence=1 order by projectstatusid asc';
$plistresult=$adb->pquery($sqllist,array());
$plistrow = $adb->num_rows($plistresult);
for($i=0;$i<$plistrow;$i++){
    $plistarr[] = $adb->query_result($plistresult,$i,'projectstatus');
    $pliststr.=$adb->query_result($plistresult,$i,'projectstatus').',';
}*/
$smarty->assign("FROMMODULE",$frommodule);
$smarty->assign("PLISTSTR",$pliststr);
if($adb->num_rows($paymentresult)>0)//如果有回款计划
{
   //echo "have";
    for($i=0;$i<$adb->num_rows($paymentresult);$i++)
    {
        $amount = $adb->query_result($paymentresult,$i,0);//获取回款计划的金额
        $is_currency_id = $adb->query_result($paymentresult,$i,'currency_id');//获取回款计划的币种
        $is_conversion_rate = $adb->query_result($paymentresult,$i,'conversion_rate');//获取回款计划的汇率
        //判断回款计划的币种是否等于回款计划的币种
        if($currency_id != $is_currency_id)
        {
            if($currency_id == 1){
				/**
				 * 美金的汇率是0.163，需要用1除以汇率，才能正确计算
				 * @reason 0013828: 合同订单--相关信息,回款计划的金额有问题
				 * @author Tujt 2015-03-05
				 */
                $amount = $amount*(1/$is_conversion_rate);
            }else
                if(!empty($conversion_rate) && $conversion_rate > 0){
                    $amount = $amount*$is_conversion_rate/$conversion_rate;
                }else{
                    $amount = $amount*$is_conversion_rate;
                }
        }
        $paymentamount+=$amount;
       //获取该合同订单最大期次
        //（因为查询排序时按照期次升序排序)
        $periodtime=$adb->query_result($paymentresult,$i,2);
        $last_plandate=$adb->query_result($paymentresult,$i,'plandate');//最后一次的计划收款日期
        //wym BUG0072152 给空值默认值为当天
        if(empty($last_plandate)||$last_plandate=='0000-00-00'){
            $last_plandate=date('Y-m-d');
        }
    }

    $nopaymentamount=0.00;
    $nopaymentamount=floatval ($total)-floatval($paymentamount);
  
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
			$_REQUEST['diony']='diony';
			ConvertTojsonString(-1,array(),getFixedLabel('ORDERCREATED'));
        }   
    }
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 5:23
    if(!empty($result_pick))
    //if($adb->num_rows($periodresult)>0)
    {
        /**
         *去掉了 if($periodtime<$adb->query_result($periodresult,0,0))判断，原因是重算情况下，会出现期次大于下拉期次选项问题
         * bug0024372: 合同订单明细：创建回款计划，录入多个期次后重算，再次创建回款计划时带出的期次不对
         */
        //判断最大期次+1在期次下拉框表中是否存在
       // if($periodtime<$adb->query_result($periodresult,0,0))//如果小于最大期次
        //{
            $periodtime=$periodtime+1;
       // }
    }
    $HavePaymentList="<select class='ld-select-inner' name='projectstatus1' id='projectstatus1'>";
    foreach($plistarr as $arr){
        $HavePaymentList.="<option value='".$arr."'>".$arr."</option>";  
    }
    $HavePaymentList.="</select>";
    $smarty->assign("HAVEPAYMENTLIST",$HavePaymentList);
    $smarty->assign("formatNOPAYMENTAMOUNT",number_format($nopaymentamount,2));
    $smarty->assign("NOPAYMENTAMOUNT",setNumberFormatEmptySeperator($nopaymentamount,2));
    $smarty->assign("PERIODTIME",$periodtime);
    $smarty->assign("PLANDATE",date("Y-m-d", strtotime("+1 month",strtotime($last_plandate))));

	$title = getFixedLabel('EDIT').' '.getTranstab('PaymentPlan');
    $tpl="modules/CashBill/HavePayment.tpl";


}
else //如果没有回款计划
{
   
   //获取最小的期次值
    //$periodtime=$adb->query_result($periodresult,$adb->num_rows($periodresult)-1,0);
    $periodtime = 1;
    
    //未计划金额等于订单金额
    $salesorderamount=$total;
   // echo $subtotal;

    $smarty->assign("formatNOPAYMENTAMOUNT",number_format($salesorderamount,2));
    $smarty->assign("NOPAYMENTAMOUNT",setNumberFormatEmptySeperator($salesorderamount,2));
    //期次
    $smarty->assign("PERIODTIME",$periodtime);
    
    //回款计划设置
    $setPaymentarr=explode(",",$PaymentPlanSetting);

    //hzx BUG0071418关联创建收款计划时，对应最后一期取值按（未计划金额-前几期的金额之和）取值 2023-08-22
    $sum_setPaymentarr = 0;
    if(count($setPaymentarr) > 0){
        for($i = 0;$i<count($setPaymentarr);$i++){
            $sum_setPaymentarr +=  $setPaymentarr[$i];
        }
    }else{
        $sum_setPaymentarr = 100;
    }

    $setperiodtimearr=explode(",",$periodtimes);
    $paymenttr="";
	$plandate=$plandate_value;
	$monthlastday = DateOperation::getMonthDays($plandate);//获取当月的总天数

    $hascount_amount = 0;

    for($i=1;$i<=count($setPaymentarr);$i++)
    {
       // echo $setPaymentarr[$i-1]."<br>";
        if($i == count($setPaymentarr)){
            $amount = $salesorderamount*$sum_setPaymentarr/100 - $hascount_amount;
            //dump($amount);
        }else{
            $amount=$salesorderamount*$setPaymentarr[$i-1]/100;
            $hascount_amount += sprintf("%.2f",$amount);
        }

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
                        <td><input type='text' name='ratio".$i."' value='" . sprintf("%.2f", $setPaymentarr[$i-1]) ."' id='ratio".$i."' onchange=RelateCreatePayPlan.changeamountn(this,'amount".$i."','ratio".$i."','".$salesorderamount."'); size='10' class='ld-input-inner gwidth100'></td>
                        <td><input type='text' name='amount".$i."' value='" . sprintf("%.2f",$amount)."' id='amount".$i."' size='10' onchange=changeratio(this,'ratio".$i."','amount".$i."','".$salesorderamount."'); class='ld-input-inner gwidth100'></td>";
        if($payemnttype_value == '项目状态' ){
            $paymenttr .="<td class='ld-form-item-content' id='paymentpan_date_td_".$i."' style='display:none;'>";
            $paymenttr.="<input type='text' size='15' readonly='true' id='plandate".$i."' value='".$plandate."' name='plandate".$i."' onClick='WdatePicker()' class='Wdate ld-input-inner'/>";
            $paymenttr.="</td>";
            $paymenttr.="<td style='display:;' id='projectstatus_td_".$i."'>";
            $paymenttr.="<select class='ld-select-inner' name='projectstatus".$i."' id='projectstatus".$i."'>";
            foreach($plistarr as $arr){
                $paymenttr.="<option value='".$arr."'>".$arr."</option>";
            }
            $paymenttr.="</select>";
            $paymenttr.="</td>";

            if(isset($project_fieldname)){
                $paymenttr.="<td index='".$i."' id='project_td_".$i."' style='display:none;overflow: visible'>";
                $paymenttr.="<input readonly name='".$project_fieldname.$i."_name' type='text' fieldonly='".$project_fieldonly."' value='' class='ld-input-inner gwidth70'>";
                $paymenttr.="<input name='".$project_fieldname.$i."' type='hidden' value=''>";
                $paymenttr.="<a index='".$i."' class='icon-homeimg icon-select' href='javascript:;' title='".getFixedLabel('SELECT')."' onclick=showrelatedlist('PaymentPlan','".$refermodule."','select','','".$project_fieldname."',this);></a>";
                $paymenttr.="<input index='".$i."' class='icon-homeimg icon-clear inpb-reset' type='button' title='".getFixedLabel('CLEAR')."' onclick=clear_relatedfielddata('PaymentPlan','".$project_fieldname."','".$project_fieldname."_name','".$project_fieldname."','".$refermodule."','popupselectfield',this)>";
                $paymenttr.="</td>";
            }
        }else{
            $paymenttr .="<td class='ld-form-item-content' id='paymentpan_date_td_".$i."'>";
            $paymenttr.="<input type='text' size='15' readonly='true' id='plandate".$i."' value='".$plandate."' name='plandate".$i."' onClick='WdatePicker()' class='Wdate ld-input-inner'/>";
            $paymenttr.="</td>";
            $paymenttr.="<td style='display:none;' id='projectstatus_td_".$i."'>";
            $paymenttr.="<select class='ld-select-inner' name='projectstatus".$i."' id='projectstatus".$i."'>";
            foreach($plistarr as $arr){
                $paymenttr.="<option value='".$arr."'>".$arr."</option>";
            }
            $paymenttr.="</select>";
            $paymenttr.="</td>";
            //wym XUQIU1001598 收款计划增加单选“项目立项”字段，无收款计划界面添加项目立项字段
            if(isset($project_fieldname)){
                $paymenttr.="<td index='".$i."' id='project_td_".$i."' style='display:none;overflow: visible'>";
                $paymenttr.="<input readonly name='".$project_fieldname.$i."_name' type='text' fieldonly='".$project_fieldonly."' value='' class='ld-input-inner gwidth70'>";
                $paymenttr.="<input name='".$project_fieldname.$i."' type='hidden' value=''>";
                $paymenttr.="<a index='".$i."' class='icon-homeimg icon-select' href='javascript:;' title='".getFixedLabel('SELECT')."' onclick=showrelatedlist('PaymentPlan','".$refermodule."','select','','".$project_fieldname."',this);></a>";
                $paymenttr.="<input index='".$i."' class='icon-homeimg icon-clear inpb-reset' type='button' title='".getFixedLabel('CLEAR')."' onclick=clear_relatedfielddata('PaymentPlan','".$project_fieldname."','".$project_fieldname."_name','".$project_fieldname."','".$refermodule."','popupselectfield',this)>";
                $paymenttr.="</td>";
            }
        }
        $paymenttr .="<td><textarea name='description".$i."' value='' id='description".$i."' cols='100%' class='ld-textarea-inner' style='height: 30px;'></textarea>
        </td>
                    </tr>";
        $periodtime=$periodtime+1;

    }
    $smarty->assign("PAYMENTPLANSETTING",$paymenttr);

	/**
	 * diony    
	 * 2014-11-27
	 * 合同订单保存后是否立即打印1:否，0:是
	 */
	$deployarray=getSys_deploy('57');
	$pirintStr = '';
	$printStatus = 'no';
    if(isset($_REQUEST['isshowPrintDiv'])&&$_REQUEST['isshowPrintDiv']!=''){
        $isshowPrintDiv=$_REQUEST['isshowPrintDiv'];    
    }
	if($deployarray['deploy_value'] == 0&&$isshowPrintDiv=='yes'){
		$pirintStr = '&isprint=yes';
		$printStatus = 'yes';
	}
	$smarty->assign("PIRINTSTR",$pirintStr);
	$smarty->assign('PRINTSTATUS',$printStatus);
    $tpl="modules/CashBill/NoPayment.tpl";
	$title = getFixedLabel('CREATE').' '.getTranstab('PaymentPlan');
   
}
//$deployarr=getSys_deploy(68);//设置管理单据是否选择审批
$focus= CRMEntity::getInstance('CashBill');
//project:PROT387 edit：cyb date:2016-08-05 description:获取审批要求字段值；
$approve_demand=$focus->get_approve_demand_byModule($frommodule);
$_REQUEST['diony']='diony';
if($approve_demand==1&&$approvestatus!=constant('D_A_S_APPROVED'))
{   
	ConvertTojsonString(-1,array(),getFixedLabel('NOTCREATERELVANTBILL'));
}
$t_arr['title']=$title;
$t_arr['oktext']=getFixedLabel("SAVE");
$t_arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch($tpl);
$t_arr['content']=$str;
$t_arr['selectedlastname']=$selectedlastname;
$t_arr['user_arr']=$user_arr;
ConvertTojsonString(1,$t_arr,"success");
?>