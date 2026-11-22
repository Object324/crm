<?php
global $adb;
$_REQUEST['diony']='yes';
$smarty = new lingdangCRM_Smarty;
$interface_arr = getInterfaceInfo();
foreach ($interface_arr as $paraName=>$paraValue){
    $smarty->assign(strtoupper($paraName),$paraValue);
}
$image_path = 'storage/ShopSettings/';
if(!empty($interface_arr['sharepicture']))
{
    $image = $root_directory.$image_path.$cardinfo['sharepicture'];
    if(!file_exists($image)||!@getimagesize($image)){
        $interface_arr['sharepicture'] = '';
    }
}
$arr["content"] = $smarty->fetch("modules/ShopSettings/InterfaceSettings.tpl");
ConvertTojsonString(1,$arr,'success');

function getInterfaceInfo(){
    global $adb;
    $query = "select * from ld_shop_settings where `name`= 'InterfaceSettings'";
    $result = $adb->pquery($query,array());
    $return_arr = array();
    if($adb->num_rows($result)>0){
        $return_arr = Zend_Json::decode($adb->query_result($result,0,'input_content'));
    }
    return $return_arr;
}


?>