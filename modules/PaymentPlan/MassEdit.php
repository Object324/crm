<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
if(isset($_REQUEST['smowner'])&&$_REQUEST['smowner']=='smowner')
{
    require_once("modules/lingdang/MassEdit.php");
    return;
}
elseif(isset($_REQUEST['smowner'])&&$_REQUEST['smowner']==1)//批量修改
{
    /**
     * 更新操作
     * edit:can
     * date:20131031
     * reason:回款计划添加批量修改
     * */
    if(isset($_REQUEST['idstring']))
    {
        /* $storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idstring'],$excludedRecords);
        $x = array_filter($storearray);
        $idstringval=implode(',',$x);
        
            $sql = "select paymentplanid,paymentplan_no,ld_paymentplan.accountid,ld_paymentplan.entitytypeid, accountname,ifnull(actualamount,0)as actualamount,ld_paymentplan.amount,(ld_paymentplan.amount-ifnull(ld_paymentplan.actualamount,0)) as thistime
        from ld_paymentplan 
        inner join ld_account 
        	on ld_paymentplan.accountid =ld_account.accountid 
        where  ld_paymentplan.deleted=0
        	and ( paymentstatus='已收' or paymentstatus='部分已收' ) and  ld_paymentplan.paymentplanid in (".$idstringval.")  order by ld_PaymentPlan.paymentplan_no desc"; 
        
            $result=$adb->pquery($sql,array());
            //echo $sql;
           if($adb->num_rows($result)>0)
            {
                echo "######error#";
                
                exit(); 
            }*/
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
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
for($i = 0; $i<count($x); $i++){
	if($i < $btach_num){
		$y[] = $x[$i];
	}
}
$idstringval=implode(',',$y);
$SearchScope=$_REQUEST['SearchScope'];
$smarty->assign("SEARCHSCOPE",$SearchScope);
$smarty->assign("CURRENCYID",1);//币种默认为人民币

/*
andrew
原搜索出来是salesorderid现在改为entitytypeid
*/
if(isset($_REQUEST['idstring']))
{

    $sql = "select paymentplanid,paymentplan_no,ld_paymentplan.accountid,ld_paymentplan.entitytypeid,ld_paymentplan.currency_id, accountname,ifnull(actualamount,0)as actualamount,ld_paymentplan.amount,(ld_paymentplan.amount-ifnull(ld_paymentplan.actualamount,0)) as thistime 
from ld_paymentplan 
left join ld_account 
	on ld_paymentplan.accountid =ld_account.accountid 
where  ld_paymentplan.deleted=0
	and ( paymentstatus='未收' or paymentstatus='部分已收') and  ld_paymentplan.paymentplanid in (".$idstringval.")  order by ld_paymentplan.paymentplan_no desc"; 
    $result=$adb->pquery($sql,array());
    //echo $sql;
    if($adb->num_rows($result)<=0)
    {
        $_REQUEST['diony']='diony';
      ConvertTojsonString("-1",array(),"");
        
        exit(); 
    }
    $trPayment="";
    $profileid=$current_user->profileid;
    crm_load_function_file('getAssignedPicklistValues','modules/PickList','PickListUtils'); 
	$picklistiscashbill = getAssignedPicklistValues("iscashbill", $profileid, $adb,array(),'ld_field');
    $picklistPeymentmethod=getAssignedPicklistValues("paymentmethod", $profileid, $adb,array(),'ld_field');
    
    /**
     * 更新操作
     * edit:can
     * date:20131219
     * reason:6350: 收款单中“是否开票”、“付款方式”设置默认值后，在回款计划批量收款中，“是否开票”、“付款方式”也应该读取默认值。
     * */
    $sql='select defaultvalue  from ld_field where tabid in(select tabid from ld_tab where name=?) and columnname=?';
    $cashbillresult=$adb->pquery($sql,array('CashBill','iscashbill'));
    $paymentresult=$adb->pquery($sql,array('CashBill','paymentmethod'));
    
    $cashbilldefault=$adb->query_result($cashbillresult,0,0);
    $paymentdefault=$adb->query_result($paymentresult,0,0);
    for($i=0;$i<$adb->num_rows($result);$i++)
    {
         $j=$i+1;
        $currency_id = $adb->query_result($result,$i,"currency_id");
        crm_load_class_file("BankAccountSet",'modules/BankAccountSet');       
        $bankaccountresult=BankAccountSet::getBackAccount($currency_id);//获取账户列表
        $amount = $adb->query_result($result,$i,"amount");
        $actualamount = $adb->query_result($result,$i,"actualamount");
        $thistime = $adb->query_result($result,$i,"thistime");
        //获取金额字段小数位数
        $system_351 = getSys_deploy(351);
        $system_deploy_351 = 2;
        if(is_numeric($system_351['deploy_value'])){
            $system_deploy_351 = $system_351['deploy_value'];
        }
        $trPayment.="<tr>";
        $trPayment.="<td align='center'><input name='chkPayment".$j."' id='chkPayment".$j."' type='checkbox' value='0' onclick='chkamount(this)' checked='checked'/></td>";
        $trPayment.="<td align='left'>".$adb->query_result($result,$i,"paymentplan_no")." </td>";
        $trPayment.="<td align='left'>".$adb->query_result($result,$i,"accountname")."<input type='hidden' name='salesorder".$j."' value='".$adb->query_result($result,$i,"entitytypeid")."'/> "." <input type='hidden' name='account".$j."' value='".$adb->query_result($result,$i,"accountid")."'/></td>";
        $trPayment.="<td align='right'>".setNumberFormat($amount,$system_deploy_351)."<input type='hidden' name='SysBol".$j."' value='".$adb->query_result($result,$i,"paymentplanid")."'/></td>";
        $trPayment.="<td align='right'>".setNumberFormat($actualamount,$system_deploy_351)."<input type='hidden' name='actualamount".$j."' value='".setNumberFormatEmptySeperator($actualamount,$system_deploy_351)."'/></td>";
        $trPayment.="<td align='right'>".setNumberFormat($thistime,$system_deploy_351)."<input type='hidden' name='thistime".$j."' value='".setNumberFormatEmptySeperator($thistime,$system_deploy_351)."'/></td>";
        /*$trPayment.="<td align='left'><select name='iscashbill".$j."'>";
        foreach($picklistiscashbill as $keycashbill=>$cashbillname)
        {
             if($cashbillname==$cashbilldefault)
             {
                $trPayment.="<option value='".$cashbillname."' selected >$cashbillname</option>";
             }
             else
             {
                $trPayment.="<option value='".$cashbillname."' >$cashbillname</option>";
             }
            
        }
        $trPayment.="</select></td>";*/
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
        $trPayment.="<td align='left'><select name ='paymentmethod".$j."'>";
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
        
        $trPayment.="</select>
        
        
        </td>";
        
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
$smarty->assign("MASS_EDIT",$trPayment);
require('user_privileges/user_language_'.$current_user->id.'.php');
//计划收款日期翻译
$sql='select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
where languagetype=? and trantable=? and   ld_tranlabel.tabid =(select tabid from ld_tab where  name=\'paymentplan\') and (columnname=? or columnname=? or columnname=?) order by columnname asc ';

$result=$adb->pquery($sql,array($languageType,'ld_field','plandate','amount','actualamount'));
$smarty->assign('ACTUALAMOUNTLABEL',($adb->query_result($result,0,0)));
$smarty->assign('AMOUNTLABEL',($adb->query_result($result,1,0)));

$smarty->assign('PLANDATELABEL',($adb->query_result($result,2,0)));

//客户名称翻译
$sql='select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
where languagetype=? and trantable=? and   ld_tranlabel.tabid =(select tabid from ld_tab where  name=\'Accounts\') and columnname=\'accountname\'';
$result=$adb->pquery($sql,array($languageType,'ld_field'));
if($adb->num_rows($result)>0)
{
    $smarty->assign('ACCOUNTNAMELABEL',($adb->query_result($result,0,0)));
}

 $cashbill_field_obj=Field::getInstance('CashBill',$adb);
$arrFieldLabel=$cashbill_field_obj->getFieldLables();
$smarty->assign('ARRFIELDLABEL',$arrFieldLabel);


 $paymentplan_field_obj=Field::getInstance('PaymentPlan',$adb);
$arrFieldLabel2=$paymentplan_field_obj->getFieldLables();
$smarty->assign('ARRFIELDLABEL2',$arrFieldLabel2);

//echo '###SUCCESS###';
$str=$smarty->fetch("MassEditPaymentPlan.tpl");
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel("RECEIVINGBATCH");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$str;

ConvertTojsonString(1,$arr,"success");
?>