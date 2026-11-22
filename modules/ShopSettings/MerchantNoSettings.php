<?php

$_REQUEST['diony']='yes';
$smarty = new lingdangCRM_Smarty;
$MerchantNo_arr = getMerchantNoInfo();
foreach ($MerchantNo_arr as $paraName=>$paraValue){
    $smarty->assign(strtoupper($paraName),$paraValue);
}
$arr["content"] = $smarty->fetch("modules/ShopSettings/MerchantNoSettings.tpl");
ConvertTojsonString(1,$arr,'success');

function getMerchantNoInfo(){
    global $adb;
    $query = "select * from ld_shop_settings where `name`= 'MerchantNoSettings'";
    $result = $adb->pquery($query,array());
    $return_arr = array();
    if($adb->num_rows($result)>0){
        $return_arr = Zend_Json::decode($adb->query_result($result,0,'input_content'));
    }
    return $return_arr;
}


?>