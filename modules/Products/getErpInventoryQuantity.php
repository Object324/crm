<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

global $mod_strings;
global $app_strings;
global $theme;
$smarty = new lingdangCRM_Smarty();
if(!empty($_REQUEST['pro_id'])){
	$query = 'select product_no from ld_products where productid in ('.$_REQUEST['pro_id'].')';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$data[] = $adb->query_result($result,$i,'product_no');
		}
		$productid_str = implode(',',$data);
		$url='http://localhost:88/link2erp/Api/api_get_WarehouseQuantity.php';
		$postdata = array(
			'warehouse' => '一般贸易B仓（镇江三晟）',
			'product_no'=>$productid_str,
			
		);
		$postdata=json_encode($postdata);
		$ret_data = curl_post($url, $postdata);
		$ret_data = object_array(json_decode($ret_data));
	}else{
		ConvertTojsonString(-1,$arr,'success');
	}
}
$smarty->assign('RET_DATA',$ret_data['result']); 
$_REQUEST['diony']='diony';
$arr['title']='产品库存查询';
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
//$smarty->display('getErpInventoryQuantity.tpl');
$str=$smarty->fetch("getErpInventoryQuantity.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");

function curl_post($url, $postdata)
{
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_POST, true);
    curl_setopt($curl, CURLOPT_POSTFIELDS, $postdata);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($curl, CURLOPT_HTTPHEADER,array('Content-Type: text/plain'));
    $result = curl_exec($curl);
	curl_close($curl);
    return $result;
}

function object_array($array) {  
    if(is_object($array)) {  
        $array = (array)$array;  
     } if(is_array($array)) {  
         foreach($array as $key=>$value) {  
             $array[$key] = object_array($value);  
             }  
     }  
     return $array;  
}



?>