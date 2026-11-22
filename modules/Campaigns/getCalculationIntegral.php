<?php
//session_start();
/**
 * 读取过期基金，保存到中间表ld_handleintegral中
 * diony 
 * 2014-12-04
 */
if(isset($_REQUEST['ajax']))
{
    chdir('./../../');
}
require_once('./include/database/PearDatabase.php');

global $adb;

$fm_months = getMonthForseType(2).'-01';
//$fm_months = '2017-12-01';

$integralSql = "select ld_salesorder.accountid,ld_salesorder.salesorderid, ld_salesorderdetail.productid,
ld_salesorderdetail.lineitem_id,
ld_products.product_no,ld_products.productname,ld_productcf.cf_1358 
from ld_salesorderdetail inner JOIN 
ld_salesorder on ld_salesorder.salesorderid = ld_salesorderdetail.id
left join ld_products on ld_products.productid = ld_salesorderdetail.productid  
left join ld_productcf on ld_productcf.productid = ld_products.productid 
where ld_salesorder.deleted = 0 and isintegralset = 1 and sostatus != '已作废' 
and ld_productcf.cf_1358 < ? ";

$integralResult=$adb->pquery($integralSql,array($fm_months));
$num_rows=$adb->num_rows($integralResult);
$arr=array();
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        
        $accountid = $adb->query_result($integralResult,$i,'accountid');
        $salesorderid = $adb->query_result($integralResult,$i,'salesorderid');
        $productid = $adb->query_result($integralResult,$i,'productid');
        
        $selectSql = 'select 1 from ld_handleintegral where accountid = ?';
        $selectResult = $adb->pquery($selectSql, array($accountid));
        if(!$adb->num_rows($selectResult))
        {
            $sql = 'INSERT INTO ld_handleintegral(accountid) VALUES (?)';
            $adb->pquery($sql, array($accountid));
        }
        
        $update_query = "update ld_inventoryproductrel set isintegralset=1 where id=? and productid=? ";
		$update_params = array($salesorderid, $productid);
		$adb->pquery($update_query, $update_params);
        
    }
}
/**
*edit:diony 
*2014-12-04
*计算当前时间的前后月份
*/
function getMonthForseType($type)
{
    //得到系统的年月  
    $tmp_date=date("Ym");  
    //切割出年份  
    $tmp_year=substr($tmp_date,0,4);  
    //切割出月份  
    $tmp_mon =substr($tmp_date,4,2);  
    if($type == 1)
    {
        //得到当前月的下一个月  
        $tmp_nextmonth=mktime(0,0,0,$tmp_mon+1,1,$tmp_year);  
        return $fm_next_month=date("Ym",$tmp_nextmonth);  
    }
    elseif($type == 2)
    {
        //得到当前月的上一个月
        $tmp_forwardmonth=mktime(0,0,0,$tmp_mon-2,1,$tmp_year);  
        return $fm_forward_month=date("Ym",$tmp_forwardmonth);
    }
}
?>