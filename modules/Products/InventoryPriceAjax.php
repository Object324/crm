<?php
global $theme, $adb;
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$currencyid = $_REQUEST['currencyid'];
$products_list = $_REQUEST['productsList'];
$accountid=$_REQUEST['accountid'];//获取隐藏域里边的值，值来源于不含税单价。
$System_deploy=$_REQUEST['System_deploy'];//获取系统参数值。
$product_ids = explode("::", $products_list);
//系统参数：单价小数位
$sysdeploy_93 = getSys_deploy(93);
$lenprice = $sysdeploy_93['deploy_value'];
$price_list = array();
$costprice_list = array();

if (count($product_ids) > 0) {
	 crm_load_function_file('getPricesForProducts','include/utils','InventoryUtils');
	$prices_for_products = getPricesForProducts($currencyid,$product_ids,$_REQUEST['frommodule'],1);
}

$module = $_REQUEST['frommodule'];
// To get the Price Values in the same order as the Products
for ($i=0;$i<count($product_ids);++$i) {
	$product_id = $product_ids[$i];
	// Pick the price for the product_id from service prices/ product prices based on which array it is set.
	 if ($module == 'PurchaseOrder' || $module == 'PurchaseInquiryOrder' || $module == 'PurchaseBack' || $module == 'Stock' || $module == 'PurchaseInvoice') {
		$price_list[] =  sprintf('%.'.$lenprice.'f',$prices_for_products[$product_id]['costprice']);
	} else {
		$price_list[] =  sprintf('%.'.$lenprice.'f',$prices_for_products[$product_id]['unit_price']);
	}
	$costprice_list[] =  sprintf('%.'.$lenprice.'f',$prices_for_products[$product_id]['costprice']);
}
if(isset($_REQUEST['frommodule']) && isset($_REQUEST['accountid'])){
	$focus = CRMEntity::getInstance($_REQUEST['frommodule']);
	if($_REQUEST['frommodule'] == 'SalesOrder'||$_REQUEST['frommodule']=='ServiceContracts'){
	   $detailtable=$focus->Detail_table;
		$query = " select listprice,productid,".$focus->table_name.'.currency_id,'.$focus->table_name.".conversion_rate from '.$focus->table_name.' 
			LEFT JOIN $detailtable ON $detailtable.id = ".$focus->table_name.'.'.$focus->table_index.' 
			where accountid = ? and '.$focus->table_name.".deleted = 0 and $detailtable.productid in(".implode(',',$product_ids).') 
			ORDER BY  '.$focus->table_name.'.'.$focus->table_index.' desc limit 1';
		$result = $adb->pquery($query,array($_REQUEST['accountid']));
		$num_rows = $adb->num_rows($result);
		$trans = array_flip($product_ids);
		for($i = 0; $i<$num_rows; $i++){
			$listprice = $adb->query_result($result,$i,'listprice');
			$productid = $adb->query_result($result,$i,'productid');
			$currency_id = $adb->query_result($result,$i,'currency_id');
			$conversion_rate = $adb->query_result($result,$i,'conversion_rate');
			//echo $productid;echo '<br><br>';
			if($currencyid !=$currency_id){
				$currencyobj=new Currency($adb,$currencyid);
				$now_conversion_rate = $currencyobj->getCurrencyRate();//获取当前单据的币种最新汇率
				if($conversion_rate == 1 && $now_conversion_rate > 1){//人民币 -> 非人民币
					$listprice = $listprice*$now_conversion_rate;
				}else {//非人民币 - 非人民币
					$listprice = $listprice/$conversion_rate*$now_conversion_rate;
				}
			}
			//替换原数组中的listpirce对应值
			$price_list[$trans[$productid]] = sprintf('%.'.$lenprice.'f',$listprice);
			
		}
	}
}
crm_load_class_file("BankAccountSet",'modules/BankAccountSet'); 
$result=BankAccountSet::getBackAccount($currencyid);
$bankAccount = [];
$rowCount = $adb->num_rows($result);
for($i = 0; $i<$rowCount; $i++)
{
    $bankid = $adb->query_result($result,$i,'bankaccountsetid');
    $bankname = $adb->query_result($result,$i,'accountname');
    $bankAccount[$i]=$bankid . '&'.$bankname;
}
$price_values = implode("::", $price_list);
$costprice = implode("::", $costprice_list);

echo "SUCCESS$".$price_values . '|' . $costprice.'|'.implode(',',$bankAccount);

?>