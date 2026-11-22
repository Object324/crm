<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$mod_strings;
$smarty=new lingdangCRM_Smarty();

$id=$_REQUEST['salesorderid'];
$type=$_REQUEST['type'];
if($type==1){
    $listValue=getlistvalue($id);
}elseif($type==2){
    $listValue=getlistvalue2($id);
}elseif($type==3){
    $listValue=getlistvalue3($id);
}elseif($type==4){
    $listValue=getlistvalue4($id);
}



function getlistvalue($id){
    global $adb; 
    //echo $useridSQL;
    $SQL = "SELECT subject,
                   ld_products.productname,
                   ld_products.product_no,
                   ld_products.productcategory,
                   ld_products.productsheet,
                   ld_products.usageunit,
                   b.quantity,
                   f1.taxprice as taxprice,
			       round(f1.taxprice*b.quantity,2) AS total
            FROM (
            				SELECT DISTINCT	ld_outboundorder.out_id,
                            ld_outboundorder.presence,
                            ld_outboundorder.deleted,
                            ld_outboundorderdetail.entitytypeid
                    FROM ld_outboundorder
            				LEFT JOIN ld_outboundorderdetail ON ld_outboundorderdetail.id = ld_outboundorder.out_id
                    where ld_outboundorderdetail.entitytypeid<>0) AS a 
            LEFT JOIN ld_salesorderdetail b ON a.out_id=b.id
            LEFT JOIN ld_products ON ld_products.productid=b.productid
            LEFT JOIN ld_salesorder on ld_salesorder.salesorderid=a.entitytypeid
            LEFT JOIN (
            			SELECT productid,
            										 SUM(taxprice * quantity) / SUM(quantity) AS taxprice
                        	FROM ld_stock
                        	LEFT JOIN ld_stockdetail ON ld_stockdetail.id = ld_stock.stock_id
                        	WHERE ld_stock.deleted = 0
                        		    AND ld_stock.presence = '已入库' 
            										GROUP BY
            												productid	
                            ) as f1 on b.productid=f1.productid
            WHERE a.presence = '已出库' 
       			  AND a.deleted = 0
                  AND a.entitytypeid=$id";
            //echo $SQL."<br>"; 
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {    
        $list[$i]['subject'] = $adb->query_result($result, $i, 'subject');        
        $list[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $list[$i]['product_no'] = $adb->query_result($result, $i, 'product_no');
        $list[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $list[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $list[$i]['quantity'] = $adb->query_result($result, $i, 'quantity');
        $list[$i]['taxprice'] = $adb->query_result($result, $i, 'taxprice');
        $list[$i]['total'] = $adb->query_result($result, $i, 'total');
        $list[$i]['usageunit'] = $adb->query_result($result, $i, 'usageunit');
    }
    
     for ($i = 0; $i < $rowCount; $i++) {
        $list['合计']['subject'] = '';
        $list['合计']['productname'] = '合计金额：';
        $list['合计']['product_no'] = '';
        $list['合计']['productcategory'] = '';
        $list['合计']['productsheet'] = '';
        $list['合计']['quantity'] = '';
        $list['合计']['taxprice'] = '';
        $list['合计']['total'] += $list[$i]['total'];
        $list['合计']['usageunit'] = '';
    }
   /* foreach($list as $key=>$arr){
        unset($list[$key]['salesorderid']);
    }*/
      //print_r($productList);  
    return $list;
}

function getlistvalue2($id){
    global $adb; 
    //echo $useridSQL;
    $SQL = "SELECT solution,fees FROM ld_troubletickets
        WHERE
        	deleted = 0 and approvestatus='已批准'
        AND salesorderid=$id";
          //  echo $SQL."<br>"; and ld_salesorder.approvestatus='已批准'
            $result=$adb->pquery($SQL,array());
            $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {    
        $list[$i]['solution'] = $adb->query_result($result, $i, 'solution');        
        $list[$i]['fees'] = $adb->query_result($result, $i, 'fees');
    }
    
     for ($i = 0; $i < $rowCount; $i++) {
        $list['合计']['solution'] = '合计金额：';
        $list['合计']['fees'] += $list[$i]['fees'];
    }
   /* foreach($list as $key=>$arr){
        unset($list[$key]['salesorderid']);
    }*/
      //print_r($productList);  
    return $list;
}

function getlistvalue3($id){
    global $adb; 
    //echo $useridSQL;
    $SQL = "SELECT last_name,total FROM ld_expense
            LEFT JOIN ld_users ON ld_users.id=ld_expense.smownerid
            WHERE ld_expense.deleted = 0 and ld_expense.approvestatus='已批准' AND salesorderid=$id;";
            //echo $SQL."<br>"; 
            $result2=$adb->pquery($SQL,array());
            //print_r($result2);
            $rowCount = $adb->num_rows($result2);
    for ($i = 0; $i < $rowCount; $i++) {    
        $list[$i]['last_name'] = $adb->query_result($result2, $i, 'last_name');        
        $list[$i]['total'] = $adb->query_result($result2, $i, 'total');
    }
    
     for ($i = 0; $i < $rowCount; $i++) {
        $list['合计']['last_name'] = '合计金额：';
        $list['合计']['total'] += $list[$i]['total'];
    }
   /* foreach($list as $key=>$arr){
        unset($list[$key]['salesorderid']);
    }*/
      //print_r($productList);  
    return $list;
}

function getlistvalue4($id){
    global $adb; 
    //echo $useridSQL;
    $SQL = "SELECT
	commissiontype,
	amount
        FROM
        	ld_commission
            LEFT JOIN ld_commission2payment ON ld_commission2payment.commission_id = ld_commission.commission_id
        WHERE deleted = 0 and approvestatus='已批准' AND entitytypeid=$id;";
            //echo $SQL."<br>"; 
            $result2=$adb->pquery($SQL,array());
            //print_r($result2);
            $rowCount = $adb->num_rows($result2);
    for ($i = 0; $i < $rowCount; $i++) {    
        $list[$i]['commissiontype'] = $adb->query_result($result2, $i, 'commissiontype');        
        $list[$i]['amount'] = $adb->query_result($result2, $i, 'amount');
    }
    
     for ($i = 0; $i < $rowCount; $i++) {
        $list['合计']['commissiontype'] = '合计金额：';
        $list['合计']['amount'] += $list[$i]['amount'];
    }
   /* foreach($list as $key=>$arr){
        unset($list[$key]['salesorderid']);
    }*/
      //print_r($productList);  
    return $list;
}
$sql="select subject from ld_salesorder where salesorderid=$id";
            $result1=$adb->pquery($sql,array());
            $rowCount = $adb->num_rows($result1);
            $subject=$adb->query_result($result1, 0, 'subject');
$smarty->assign("type",$type);            
$smarty->assign("subject",$subject);
$smarty->assign("listValue",$listValue);
$smarty->display('Comprehensivereport/yijiapopup1.tpl');

exit();
?>