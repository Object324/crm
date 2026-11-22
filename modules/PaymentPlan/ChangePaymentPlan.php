<?php
/**
 * 更新操作
 * edit:can
 * date:20131030
 * reason:合同订单调整回款计划功能(V3.1)
 * */
global $adb,$current_user;

if(isset($_REQUEST['salesid']))
{
    $salesorderid=$_REQUEST['salesid'];
	//inner join ld_crmentity on ld_crmentity.crmid=ld_paymentplan.paymentplanid  
    $sql="select ld_paymentplan.*  from ld_paymentplan 
           where (paymentstatus='未收') and entitytypeid=? and ld_paymentplan.deleted=0 order by paymentplan_no";
    $result=$adb->pquery($sql,array($salesorderid));
    $paymentlist="";
    if($adb->num_rows($result)==0)
    {
        /**
         * 更新操作
         * edit:can
         * date:20131209
         * reason:6002: 建议：当合同订单没有回款计划时，合同订单查看界面点击调整回款计划按钮后希望可以给出提示信息
         * */
         echo '###ERROR####';
         exit();
    }
	if($current_user->is_admin == 'off'){
	   if(isPermitted('PaymentPlan','EditView')=='no')
       {
          //36834: （1.6）使用“liflain 密码123”这个账号登录>合同订单>单据编号为SO396 >相关>回款计划：点击调整按钮提示“您没有编辑权限”，但是一条一条编辑又是可以的。（需要补丁）
             echo '###ERROR2####';
			exit();
       }
	   //17909: 升级帐套：普通用户、合同订单-查看明细界面：调整回款计划弹出层没有显示列值
		$sql="select ld_paymentplan.*  from ld_paymentplan 
           where (paymentstatus='未收') and entitytypeid=? and ld_paymentplan.deleted=0 order by paymentplan_no";
		 $result=$adb->pquery($sql,array($salesorderid));	
		 if($adb->num_rows($result)==0){
			 echo '###ERROR2####';
			exit();
		 } 
	}
  
    for($i=0;$i<$adb->num_rows($result);$i++)
    {
        $paymentplanid=$adb->query_result($result,$i,'paymentplanid');
        $paymentplanno=$adb->query_result($result,$i,'paymentplan_no');
        $paymentstatus=$adb->query_result($result,$i,'paymentstatus');
        $paymentperiodtime=$adb->query_result($result,$i,'periodtime');
        $paymentplandate=$adb->query_result($result,$i,'plandate');
        $paymentamount=$adb->query_result($result,$i,'amount');
        $lastmodifiedtime=$adb->query_result($result,$i,'modifiedtime');
       // $smownerid=$adb->query_result($result,$i,'smownerid');
        $paymentlist .=' <tr>';
        $paymentlist .=' <td><input type="checkbox" value="2" name="chk'.$i.'" id="chk'.$i.'"  onclick="paymentplanChk(this,'.$i.')"/></td>';
        $paymentlist.=" <td><input type='hidden' id='paymentplanid".$i."' name='paymentplanid".$i."' value='".$paymentplanid."'>"
                         .$paymentplanno."  </td>";
        $paymentlist .=" <td> <input type='hidden' name='paymentstatus".$i."'/>$paymentstatus</td>";
        $paymentlist .=" <td><input type='hidden' name='periodtime".$i." value='".$paymentperiodtime."/>$paymentperiodtime</td>";
        $paymentlist .=" <td><input type='hidden' name='plandate".$i." value='".$paymentplandate."'/>$paymentplandate</td>";
        $paymentlist .=" <td><input type='hidden' name='oldamount".$i."' id='oldamount".$i."' value='".$paymentamount."'>$paymentamount</td>";
        $paymentlist.=" <td>$lastmodifiedtime</td>";
        $paymentlist.=" <td><input size='8' type='text'  readonly='true' name='amountpercent".$i."' id='amountpercent".$i."' onchange='amountPercentChange(this,".$i.")'/></td>";
        $paymentlist .=" <td>&nbsp</td>";
        $paymentlist.=" </tr>"; 
    }
    $smarty= new lingdangCRM_Smarty();
    $smarty->assign("PAYMENTLIST",$paymentlist);
    echo "####:###";
    $smarty->display("modules/PaymentPlan/ChangeList.tpl");

}

exit();

?>