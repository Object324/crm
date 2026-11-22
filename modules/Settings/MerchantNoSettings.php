<?php

$_REQUEST['diony']='yes';
$smarty = new lingdangCRM_Smarty;
$MerchantNo_arr = getMerchantNoInfo();
foreach ($MerchantNo_arr as $paraName=>$paraValue){
    $smarty->assign(strtoupper($paraName),$paraValue);
}
$arr["content"] = $smarty->fetch("Settings/MerchantNoSettings.tpl");
ConvertTojsonString(1,$arr,'success');

function getMerchantNoInfo(){
    global $adb;
    $query = "select * from ld_wx_config where `name`= 'weixinpay_setting'";
    $result = $adb->pquery($query,array());
    $return_arr = array();
    if($adb->num_rows($result)>0){
        $return_arr = Zend_Json::decode($adb->query_result($result,0,'para_content'));
    }
    return $return_arr;
}


?>