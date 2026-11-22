<?php
/**
 * User: Administrator
 * Project: crm
 * Date: 2020/6/8 11:19
 * Description:
 */
global $current_user,$adb,$currentModule;
$tabid = getTabid($currentModule);

$update_sql = 'update ld_tab set fristvisit = ? where tabid = ?';
crm_load_function_file('getUserFristVisit','include/utils','ListViewUtils');
$userids = getUserFristVisit();
if(empty($userids)){
    $userids =$current_user->id.',';
    $adb->pquery($update_sql,array($userids,$tabid));
}else{
    if(!in_array($userids->id,$userids)){
        $userids =implode(',',$userids).','.$current_user->id.',';
        $adb->pquery($update_sql,array($userids,$tabid));
    }
}

$smarty = new lingdangCRM_Smarty();
$_REQUEST['diony'] ='diony';
$content = $smarty->fetch($currentModule."Fristvisit.tpl");

$arr['content'] = $content;
$arr['title'] = getFixedLabel('SOCIALPROMOTIONTIP');
$arr['oktext']  = getFixedLabel('CANCEL');

ConvertTojsonString(1,$arr,'success');