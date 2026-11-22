<?php

global $adb,$current_user,$languageType;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='save'){
    $InterfaceStaticField = array('apptype','appid','merchantnum','merchantcertificatenum','apikey','apiv3key');
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
        
        $sql = "update ld_wx_config set para_content=? where `name`=?";
        $adb->pquery($sql,array(json_encode($para_content),'weixinpay_setting'));
        ConvertTojsonString(1,array(),'success');
    }else{
        ConvertTojsonString(-1,array(),getFixedLabel('MerchantNumberSetting').' '.getFixedLabel('PARAMETERSNOTBENULL'));
    }
    exit();
}

// 注销执行逻辑
if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']=='delete'){
    $sql = "update ld_wx_config set para_content=? where `name`=?";
    $adb->pquery($sql,array('','weixinpay_setting'));
    ConvertTojsonString(1,array(),'success');
}

$smarty = new lingdangCRM_Smarty;
$sql = "select * from ld_wx_config where `name`= ?";
$result = $adb->pquery($sql,array('weixinpay_setting'));
if($adb->num_rows($result) > 0){
    $para_content_list =  Zend_Json::decode( $adb->query_result($result,0,'para_content'));
    foreach ($para_content_list as $paraName=>$paraValue){
        $smarty->assign(strtoupper($paraName),$paraValue);
    }
}
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('MerchantNumberSetting');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/MerchantNoSettings_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>