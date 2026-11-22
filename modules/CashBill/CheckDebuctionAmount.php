<?php
global $adb;
if(!$adb){
    exit();
}
if(isset($_REQUEST['jsstr']))
{
    
    $jsstr=json_decode($_REQUEST['jsstr'],true);
}
else{
    $jsstr='';
}
$record=$_REQUEST['record'];
//$debuctionids=array();//预收款单id
//foreach($jsstr as $debuctionid=>$amount){
//    $debuctionids[]=$debuctionid;
//}
crm_load_class_file("cls_CheckDebuctionInfo",'modules/CashBill');
$checkobj=new cls_CheckDebuctionInfo($_REQUEST['record'],$jsstr);
$checkobj->Check($_REQUEST['accountid'],$_REQUEST['bankaccountsetid']);
$checkobj->setEcho();

/*$db_debuctioninfo=array();
$db_cashbillnos=array();
if($record<=0){
    //收款单新增界面获取预收款的剩余可抵扣金额
    $sql='select debuctionbalanceamount,cashbillid,ld_cashbill.cashbill_no from ld_cashbill where cashbillid in ('.implode(',',$debuctionids).')';
    $result=$adb->pquery($sql,array());
    $rows=$adb->num_rows($result);
  
    for($i=0;$i<$rows;$i++){
        $cashbillid=$adb->query_result($result,$i,'cashbillid');
        $debuctionbalanceamount=$adb->query_result($result,$i,'debuctionbalanceamount');
        $db_debuctioninfo[$cashbillid]=$debuctionbalanceamount;
        $db_cashbillnos[$cashbillid]=$adb->query_result($result,$i,'cashbill_no');
    }
    
}
else{
    $sql='select accountid,bankaccountsetid from ld_cashbill where cashbillid=?';
    $result=$adb->pquery($sql,array($record));
    $accountid=$adb->query_result($result,0,'accountid');
    $Bankaccountsetid=$adb->query_result($result,0,'accountid');
    if(!empty($accountid)&&$accountid!=$_REQUEST['accountid']){
        ConvertTojsonString("-1",array(),'该单据已有核销客户名称不允许修改');
    }
    if(!empty($Bankaccountsetid)&&$Bankaccountsetid!=$_REQUEST['bankaccountsetid']){
        ConvertTojsonString("-1",array(),'该单据已有核销账户名称不允许修改');
    }
    //编辑界面
    $sql="select ld_cashbill.debuctionbalanceamount,ld_cashbill.cashbillid,
          ld_cashbilldebuction.amount,ld_cashbill.cashbill_no  from ld_cashbill

        left  JOIN (select sum(amount) as amount,cashbillid,debuctionid
         from ld_cashbilldebuctiondetail group by cashbillid,debuctionid ) as ld_cashbilldebuction
                        
             on ld_cashbill.cashbillid=ld_cashbilldebuction.debuctionid
        where   ld_cashbill.cashbillid in (".implode(',',$debuctionids).')';//获取编辑的收款单数据库中已收金额
     $result=$adb->pquery($sql,array());
     $rows=$adb->num_rows($result);
   
    for($i=0;$i<$rows;$i++){
        $cashbillid=$adb->query_result($result,$i,'cashbillid');
        $debuctionbalanceamount=$adb->query_result($result,$i,'debuctionbalanceamount');
        $amount=$adb->query_result($result,$i,'amount');
        if(empty($amount)){
            $amount=0;
        }
        $db_debuctioninfo[$cashbillid]=$debuctionbalanceamount+$amount;
        $db_cashbillnos[$cashbillid]=$adb->query_result($result,$i,'cashbill_no');
    }
}

foreach($jsstr as $debuctionid => $tmpamount)
{
    if($tmpamount>$db_debuctioninfo[$debuctionid])
    {
        $msg="预收".$db_cashbillnos[$cashbillid].'本次收款金额大于可抵扣金额';
        ConvertTojsonString("-1",array(),$msg);
        
    }
}
 ConvertTojsonString("1",array(),'success');*/
 
?>