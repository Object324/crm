<?php
//获取切换币种后价格D:\wamp\www\ldcrm\WeiXinApp\modules\Users\getInfoExpansion.php
function get_inventoryPrice($module){
    $currencyid = $_REQUEST['currencyid'];
    $products_list = $_REQUEST['productsList'];
    $product_ids = explode("::", $products_list);
    $price_list = array();
    if (count($product_ids) > 0) {
        crm_load_function_file('getPricesForProducts','include/utils','InventoryUtils');
        $prices_for_products = getPricesForProducts($currencyid, $product_ids,$module,1);
    }
    for ($i=0;$i<count($product_ids);++$i) {
        $product_id = $product_ids[$i];
        $price_list[] =  $prices_for_products[$product_id]['unit_price'];
        $costprice_list[] =  $prices_for_products[$product_id]['costprice'] ;
    }
    $price_values = implode("::", $price_list);
    $costprice = implode("::", $costprice_list);

    $jsonArray['price_values']=$price_values;
    $jsonArray['costprice']=$costprice;
    return $jsonArray;
}
