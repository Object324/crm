<?php
/**
 * 更新操作
 * edit:can
 * date:20131030
 * reason:合同订单调整回款计划
 * */
 
 require_once("modules/PaymentPlan/PaymentPlan.php");
 $i=0;

 while(true)
 {
    
     if(!isset($_REQUEST['paymentplanid'.$i]))
     {
         
        break;
     }
    
    if($_REQUEST['chk'.$i]==1)
    {
        $focus=new PaymentPlan();
        $focus->id=$_REQUEST['paymentplanid'.$i];
        $focus->mode="edit";
        $focus->retrieve_entity_info($focus->id,"PaymentPlan");
        $focus->column_fields['amount']=$_REQUEST['nowamount'.$i];
        $focus->save("PaymentPlan");
    }
    $i++;
 }
$setype=getSalesEntityType($focus->column_fields['entitytypeid']);
header("Location:index.php?module=$setype&action=DetailView&record=".$focus->column_fields['entitytypeid']);


?>