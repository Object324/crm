<?php
global $adb,$current_user;

require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
$sql = "select para_content from ld_wx_config where name=?";
$result = $adb->pquery($sql,array('wxselfbuiltapp_setting'));
if($adb->num_rows($result) > 0){

    $para_content_json = $adb->query_result($result,0,'para_content');
    $para_content_list =  Zend_Json::decode($para_content_json);
    foreach ($para_content_list as $paraName=>$paraValue){
        $smarty->assign(strtoupper($paraName),$paraValue);
    }
}

$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('Settings/wxselfbuiltapp_setting.tpl');
ConvertTojsonString(1,$arr,"success");
?>