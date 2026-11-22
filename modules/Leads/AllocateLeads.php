<?php
//zkt 20231009 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//领取和批量领取
global $adb;
if($_REQUEST['regetpoolid']=='yes'){
    $query = 'select pool_id from ld_account where accountid = ?';
    $result = $adb->pquery($query,array($_REQUEST['record']));
    if($adb->num_rows($result)>0){
        $tmppool_id = $adb->query_result($result,0,'pool_id');
        $_REQUEST['pool_id']=$tmppool_id;
    }
}
crm_load_class_file('cls_AllocateLeads','modules/Leads');
//include('modules/Accounts/cls_AllocateAccount.php');
$allocate = new cls_AllocateLeads();
global $current_user;
if($_REQUEST['allocatetype']==2){//分配
    $user_role_id=$_REQUEST['userid'];
}elseif($_REQUEST['allocatetype']==3){//领取
	if(!empty($_REQUEST['userid']))
		$user_role_id=$_REQUEST['userid'];
	else
		$user_role_id=$current_user->id;
    
}

$allocate->set_userid($user_role_id)->init_count()->switch_entrance();

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
//$allocate->header();
?>