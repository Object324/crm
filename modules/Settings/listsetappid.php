<?php
global $mod_strings,$app_strings,$default_charset;

global $current_user;
global $adb;
$smarty = new lingdangCRM_Smarty;
$set_sql = "select * from ld_articles_appid_set";
$set_res = $adb->pquery($set_sql);
$nums = $adb->num_rows($set_res);
$_REQUEST['diony'] = 'yes';
if($_REQUEST['mode'] == 'edit'){
    $app_id = $_REQUEST['app_id'];
    $app_secret = $_REQUEST['app_secret'];
    //$token = $_REQUEST['token'];
    //||empty($token)
    if(empty($app_id)||empty($app_secret)){
        //ConvertTojsonString(-1, [], "app_id、app_secret、token".getFixedLabel('FieldCANNOTEMPTY')."！");
        ConvertTojsonString(-1, [], "app_id、app_secret".getFixedLabel('FieldCANNOTEMPTY')."！");
    }
    if($nums>=1){
        //$update_sql  = "update ld_articles_appid_set set app_id='$app_id',app_secret='$app_secret',token='$token'";
        $update_sql  = "update ld_articles_appid_set set app_id='$app_id',app_secret='$app_secret'";
        $update_res = $adb->pquery($update_sql);
        $effect_num = $adb->getAffectedRowCount($update_res);
    }else{
        //$update_sql  = "insert into ld_articles_appid_set (app_id,app_secret,token) values('$app_id','$app_secret','$token')";
        $update_sql  = "insert into ld_articles_appid_set (app_id,app_secret) values('$app_id','$app_secret')";
        $update_res = $adb->pquery($update_sql);
        $effect_num = $adb->getAffectedRowCount($update_res);
    }
    ConvertTojsonString(1, $effect_num, "success");
}else {
    $app_id = "";
    $app_secret = "";
    if ($nums >= 1) {
        $app_id = $adb->query_result($set_res, 0, "app_id");
        $app_secret = $adb->query_result($set_res, 0, "app_secret");
        //$token = $adb->query_result($set_res, 0, "token");
    }
    $smarty->assign("app_id", $app_id);
    $smarty->assign("app_secret", $app_secret);
    //$smarty->assign("token", $token);

    $arr['title'] = getFixedLabel("associatedOfficialAccountSettings");
    $arr['oktext'] = getFixedLabel("CONFIRMED");
    $arr['canceltext'] = getFixedLabel("CANCEL");
    $arr['content'] = $smarty->fetch('Settings/listsetappid.tpl');
    ConvertTojsonString(1, $arr, "success");
}