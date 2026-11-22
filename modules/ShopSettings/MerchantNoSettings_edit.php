<?php

global $adb,$current_user;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='save'){
    $InterfaceStaticField = array('merchantnum','merchantcertificatenum','apikey','apiv3key');
    $para_content = array();
    foreach ($InterfaceStaticField as $key=>$value){
        //任意一个参数没有配置，不保存
        if(empty($_REQUEST[$value])){
            $para_content = array();
            break;
        }else{
            $para_content[$value] = trim($_REQUEST[$value]);
        }
    }
	$_REQUEST['diony']='diony';
    if(!empty($para_content)){
        
        $sql = "update ld_shop_settings set input_content=? where `name`=?";
        $adb->pquery($sql,array(json_encode($para_content),'MerchantNoSettings'));
        ConvertTojsonString(1,array(),'success');
    }else{
        ConvertTojsonString(-1,array(),getFixedLabel('MerchantNumberSetting').' '.getFixedLabel('PARAMETERSNOTBENULL'));
    }
    exit();
}
$smarty = new lingdangCRM_Smarty;
$sql = "select * from ld_shop_settings where `name`= ?";
$result = $adb->pquery($sql,array('MerchantNoSettings'));
if($adb->num_rows($result) > 0){
    $para_content_list =  Zend_Json::decode( $adb->query_result($result,0,'input_content'));
    foreach ($para_content_list as $paraName=>$paraValue){
        $smarty->assign(strtoupper($paraName),$paraValue);
    }
}
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('MerchantNumberSetting');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("modules/ShopSettings/MerchantNoSettings_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>