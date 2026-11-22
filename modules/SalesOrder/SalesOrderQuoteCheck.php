<?php
global $adb;
if(!$adb){
    
    exit();
}
$lengthdecimaldigits=getSys_deploy(49);//设置单据分录明细中数量字段小数位数
//海格5.订单的产品品种和数量不能超出报价单的相关数据
$quantityarr=explode(',',$_REQUEST['quantitys']);
$productids=$_REQUEST['productids'];
$productidarr=explode(",",$productids);
$quoteid=$_REQUEST['quoteid'];
$salesorderrecord=$_REQUEST['salesorderrecord'];

$sql='select (ifnull(ld_quotesdetail.quantity,0)-ifnull(ld_quotesdetail.haveordercount,0)) as balanceordercount ,ld_quotesdetail.productid,ld_products.productname from ld_quotesdetail 
inner join ld_products on ld_products.productid=ld_quotesdetail.productid where id=?';
$result=$adb->pquery($sql,array($quoteid));
$rows=$adb->num_rows($result);
$db_info=array();
for($i=0;$i<$rows;$i++)
{
    $productid=$adb->query_result($result,$i,'productid');
    $balanceordercount=$adb->query_result($result,$i,'balanceordercount');
    $producname=$adb->query_result($result,$i,'productname');
    $db_info[$productid]=$balanceordercount;
    $dbproductnames[$productid]=$producname;
}
if($salesorderrecord>0)
{
    $sql='select quantity,productid from ld_salesorderdetail
    inner join ld_salesorder on ld_salesorder.salesorderid=ld_salesorderdetail.id
     where ld_salesorderdetail.id=? and ld_salesorder.quoteid=?';
    $salesorderResult=$adb->pquery($sql,array($salesorderrecord,$quoteid));
    $salesorderrows=$adb->num_rows($salesorderResult);
    for($i=0;$i<$salesorderrows;$i++)
    {
        $productid=$adb->query_result($salesorderResult,$i,'productid');
        $quantity=$adb->query_result($salesorderResult,$i,'quantity');
        if(array_key_exists($productid,$db_info)){
            $db_info[$productid]=$quantity+$db_info[$productid];
        }
    }
    
}
$code=1;
$error='';

foreach($productidarr as $index=>$productid)
{
    if(array_key_exists($productid,$db_info)){
        if($quantityarr[$index]>$db_info[$productid])
        {
            $code=-1;
            //zkt 20230629 BUG0068877 海格：合同订单创建模块，错误提示可下单数量不足时显示的小数去掉 
            $error.='第'.($index+1)."行".$dbproductnames[$productid]."下单数量".$quantityarr[$index]
                ."必须小于等于可下单数量".setNumberFormat($db_info[$productid],$lengthdecimaldigits['deploy_value'])."<br>";//  第y行产品数量a超出报价单中的“可下单”数量b
        }
        else{
            $db_info[$productid] -= $quantityarr[$index];
        }
    }
    else
    {
         $code=-1;
        $error.='第'.($index+1)."行产品报价单中不存在<br>";
    }
}
$_REQUEST['diony']='yes';
ConvertTojsonString($code,array(),$error);
?>