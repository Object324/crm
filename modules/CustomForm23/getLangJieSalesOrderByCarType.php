<?php
//客服下单->运输订单->选择车型之后表体根据“车型”自动带出“报价单”中单据分录是对应车型的“分录信息”
//a.报价单中的“启运地” 到 运输订单中的“装货地点”
//b.报价单中的“目的地” 到 运输订单中的“送货地点”
global $adb;
//sf5371:车型
//sf5099启运地
//sf5235目的地
// @edit:luyx @date:2020-09-04 @reason: 只带2条出来，避免太多
$sql='select ld_salesorderdetailscf.sf5099 ,ld_salesorderdetailscf.sf5235
from ld_salesorderdetail inner join ld_salesorderdetailscf on ld_salesorderdetailscf.lineitem_id=ld_salesorderdetail.lineitem_id
inner join ld_products on ld_products.productid=ld_salesorderdetail.productid
inner join ld_productcf on ld_productcf.productid=ld_products.productid 
where ld_salesorderdetail.id=? and ld_salesorderdetailscf.sf5371=? 
and (ifnull(ld_salesorderdetailscf.sf5099,"")<>"" or  ifnull(ld_salesorderdetailscf.sf5235,"")<>"")
group by ld_salesorderdetailscf.sf5099,ld_salesorderdetailscf.sf5235
order by ld_salesorderdetail.lineitem_id asc  LIMIT 2';

$result=$adb->pquery($sql,array($_REQUEST['selectid'],$_REQUEST['cartype']));
$rows=$adb->num_rows($result);
$arr=array();
for($i=0;$i<$rows;$i++)
{

    $start_address=$adb->query_result($result,$i,'sf5099');
    $end_address=$adb->query_result($result,$i,'sf5235');
    if(!$start_address)
        $start_address='';
     if(!$end_address)
        $end_address='';
          
    $arr['addressinfo'][$i]=array('start_address'=>$start_address,'end_address'=>$end_address);
        

}
 $_REQUEST['diony']='yes';
 ConvertTojsonString(1,$arr,'success');

?>