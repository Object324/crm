<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
$_REQUEST['diony']='diony';
if(isset($_REQUEST['smowner'])&&$_REQUEST['smowner']=='smowner')
{
    require_once("modules/lingdang/MassEdit.php");
    return;
}
elseif(isset($_REQUEST['smowner'])&&$_REQUEST['smowner']==1)//批量修改
{
    
    if(isset($_REQUEST['idstring']))
    {
        $storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idstring'],$excludedRecords);
        $x = array_filter($storearray);
        $idstringval=implode(',',$x);
            $sql = "select sendpayment_no,sendpaymentid,ld_sendpayment.purchaseorder_id,ld_sendpayment.vendorid,ifnull(actualamount,0)as actualamount,ld_sendpayment.amount,(ld_sendpayment.amount-ifnull(ld_sendpayment.actualamount,0)) as thistime
        from ld_sendpayment 
        left join ld_purchaseorder 
        	on ld_sendpayment.purchaseorder_id =ld_purchaseorder.purchaseorderid 
        
        where  ld_sendpayment.deleted=0
        	and ( cpstatus='已付' or cpstatus='部分已付' ) and  ld_sendpayment.sendpaymentid in (".$idstringval.")  order by ld_sendpayment.sendpayment_no desc"; 
        
            $result=$adb->pquery($sql,array());
            if($adb->num_rows($result)>0)
            {
                $_REQUEST['diony']='diony';
                 ConvertTojsonString("-1",$arr,"success");
                
                exit(); 
            }
           
    }
    require_once('modules/lingdang/MassEdit.php');
    return ;
}

global $adb,$currentModule,$current_user;
$currencyobj = Currency::getInstance($adb);
$excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
$smarty=new lingdangCRM_Smarty();
$storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idstring'],$excludedRecords);
$x = array_filter($storearray);
$idstringval=implode(',',$x);
$SearchScope=$_REQUEST['SearchScope'];
$smarty->assign("SEARCHSCOPE",$SearchScope);


if(isset($_REQUEST['idstring']))
{
    $sql = "select Sendpayment_no,sendpaymentid,ld_sendpayment.vendorid,ld_sendpayment.purchaseorder_id, vendorname,ifnull(actualamount,0)as actualamount,ld_sendpayment.amount,(ld_sendpayment.amount-ifnull(ld_sendpayment.actualamount,0)) as thistime,currency_id,currency_symbol 
from ld_sendpayment 
left join ld_vendor 
	on ld_sendpayment.vendorid =ld_vendor.vendorid 
where  ld_sendpayment.deleted=0
	and ( cpstatus='未付' or cpstatus='部分已付') and  ld_sendpayment.sendpaymentid in (".$idstringval.")  order by ld_sendpayment.sendpayment_no desc"; 

    $result=$adb->pquery($sql,array());

    if($adb->num_rows($result)<=0)
    {
        ConvertTojsonString("-1",$arr,"success");
        
       
    }
    $SQL="SELECT * FROM ld_field WHERE tabid=80 AND columnname='bankaccountsetid' AND typeofdata LIKE '%M%'";
    $Mresult=$adb->pquery($SQL,array());
    $trPayment="";
    $profileid=$current_user->profileid;
    crm_load_function_file('getAssignedPicklistValues','modules/PickList','PickListUtils');
	$picklistiscashbill = getAssignedPicklistValues("criscashbill", $profileid, $adb,array(),'');
    $picklistPeymentmethod=getAssignedPicklistValues("crpaymentmethod", $profileid, $adb,array(),'');
    $sql='select defaultvalue  from ld_field where tabid in(select tabid from ld_tab where name=?) and columnname=?';
    $cashbillresult=$adb->pquery($sql,array('SendCashBill','criscashbill'));
    $paymentresult=$adb->pquery($sql,array('SendCashBill','crpaymentmethod'));
    $cashbilldefault=$adb->query_result($cashbillresult,0,0);
    $paymentdefault=$adb->query_result($paymentresult,0,0);
    //print_r($result);
    for($i=0;$i<$adb->num_rows($result);$i++)
    {
         $j=$i+1;
        $currency_id = $adb->query_result($result,$i,"currency_id");
        crm_load_class_file("BankAccountSet",'modules/BankAccountSet'); 
        $bankaccountresult=BankAccountSet::getBackAccount($currency_id);//获取账户列表
       
        if($adb->num_rows($bankaccountresult)==0&&$adb->num_rows($Mresult)!=0){
           ConvertTojsonString("-2",$arr,"success");
        }
        $amount = $adb->query_result($result,$i,"amount");
        $actualamount = $adb->query_result($result,$i,"actualamount");
        $thistime = $adb->query_result($result,$i,"thistime");
        //获取金额字段小数位数
        $system_351 = getSys_deploy(351);
        $system_deploy_351 = 2;
        if(is_numeric($system_351['deploy_value'])){
            $system_deploy_351 = $system_351['deploy_value'];
        }
		$currency_symbol = $adb->query_result($result,$i,"currency_symbol");
        $trPayment.="<tr>";
        $trPayment.="<td align='center'><input name='chkPayment".$j."' id='chkPayment".$j."' type='checkbox' value='0' onclick='chkamount(this)' checked='checked'/></td>";
        $trPayment.="<td align='left'>".$adb->query_result($result,$i,"sendpayment_no")." </td>";
        $trPayment.="<td align='left'>".$adb->query_result($result,$i,"vendorname")."<input type='hidden' name='vendor".$j."' value='".$adb->query_result($result,$i,"vendorid")."'/> "." <input type='hidden' name='purchaseorder".$j."' value='".$adb->query_result($result,$i,"purchaseorder_id")."'/></td>";
        $trPayment.="<td align='right'>".$currency_symbol.setNumberFormat($amount,$system_deploy_351)."<input type='hidden' name='SysBol".$j."' value='".$adb->query_result($result,$i,"sendpaymentid")."'/></td>";
        $trPayment.="<td align='right'>".$currency_symbol.setNumberFormat($actualamount,$system_deploy_351)."<input type='hidden' name='actualamount".$j."' value='".setNumberFormatEmptySeperator($actualamount,$system_deploy_351)."'/></td>";
        $trPayment.="<td align='right'>".$currency_symbol.setNumberFormat($thistime,$system_deploy_351)."<input type='hidden' name='thistime".$j."' value='".setNumberFormatEmptySeperator($thistime,$system_deploy_351)."'/></td>";
       
        $trPayment.="<td align='left'><select disabled name='currency".$j."'>";
            $currency_info = $currencyobj->getALlCurrencies();
            foreach($currency_info as $key => $currency)
            {
                $currency_label = getTranslatedCurrencyString($currency['currencylabel']);
                if($currency['curid']==$currency_id)
                 {
                    $trPayment.="<option value='".$currency['curid']."' selected >$currency_label</option>";
                 }
                 else
                 {
                    $trPayment.="<option value='".$currency['curid']."' >$currency_label</option>";
                 }
            }
        $trPayment.="</select></td>";
        
        $trPayment.="<td align='left'><select style='border: 1px solid #EAEAEA;' name ='crpaymentmethod".$j."'>";
        foreach($picklistPeymentmethod as $keypaymentmethod=>$paymentmethodname)
        {
            if($paymentmethodname==$paymentdefault)
            {
                $trPayment.="<option value='".$paymentmethodname."' selected >$paymentmethodname</option>";
            }
            else
            {
                $trPayment.="<option value='".$paymentmethodname."' >$paymentmethodname</option>";
            }
        }
        
        $trPayment.="</select></td>";
        $trPayment.="<td align='left'><select id ='bankaccountsetid".$j."' name ='bankaccountsetid".$j."'>";//账户
            for($bi=0;$bi<$adb->num_rows($bankaccountresult);$bi++)
            {
              
                  $bankaccountname=$adb->query_result($bankaccountresult,$bi,'accountname');
                  $trPayment.="<option value='".$adb->query_result($bankaccountresult,$bi,'bankaccountsetid')."' >$bankaccountname</option>";
                
            }
        
        $trPayment.="</select>
        
        
        </td>";
        $trPayment.="</tr>";
    } 
}
require('user_privileges/user_language_'.$current_user->id.'.php');
//计划付款日期翻译
$sql='select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
where languagetype=? and trantable=? and   ld_tranlabel.tabid =(select tabid from ld_tab where  name=\'sendpayment\') and (columnname=? or columnname=? or columnname=?) order by columnname asc ';

$result=$adb->pquery($sql,array($languageType,'ld_field','plandate','amount','actualamount'));
$smarty->assign('ACTUALAMOUNTLABEL',($adb->query_result($result,0,0)));
$smarty->assign('AMOUNTLABEL',($adb->query_result($result,1,0)));

$smarty->assign('PLANDATELABEL',($adb->query_result($result,2,0)));

//供应商名称翻译
$sql='select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
where languagetype=? and trantable=? and   ld_tranlabel.tabid =(select tabid from ld_tab where  name=\'vendors\') and columnname=\'vendorname\'';
$result=$adb->pquery($sql,array($languageType,'ld_field'));
if($adb->num_rows($result)>0)
{
    $smarty->assign('VENDORNAMELABEL',($adb->query_result($result,0,0)));
}

$sendcashbill_field_obj=Field::getInstance('SendCashBill',$adb);
$arrFieldLabel=$sendcashbill_field_obj->getFieldLables();
$smarty->assign('ARRFIELDLABEL',$arrFieldLabel);


$sendpayment_field_obj=Field::getInstance('SendPayment',$adb);
$arrFieldLabel2=$sendpayment_field_obj->getFieldLables();
$smarty->assign('ARRFIELDLABEL2',$arrFieldLabel2);


$smarty->assign("MASS_EDIT",$trPayment);

$str=$smarty->fetch("MassEditSendPayment.tpl");


$arr['title']=getFixedLabel("BATCHPAYMENT");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$str;

ConvertTojsonString(1,$arr,"success");

?>