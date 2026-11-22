<?php
//zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $current_user;
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
crm_load_class_file('cls_AllocateAccount','modules/Accounts');
//include('modules/Accounts/cls_AllocateAccount.php');
$allocate = new cls_AllocateAccount();


if($_REQUEST['allocatetype']==2){//分配
    $user_role_id=$_REQUEST['userid'];
}elseif($_REQUEST['allocatetype']==3){//领取
	if(!empty($_REQUEST['userid']))
		$user_role_id=$_REQUEST['userid'];
	else
		$user_role_id=$current_user->id;
    
}

// 是否同步分配相关信息
if(isset($_REQUEST['enablerelatedinfo']) && !empty($_REQUEST['enablerelatedinfo'])){
    $allocate->relatedinfoset_arr['sharerelatedinfo'] = $_REQUEST['enablerelatedinfo'];
    if(isset($_REQUEST['shareoldsmowner']) && !empty($_REQUEST['shareoldsmowner'])){
        $allocate->relatedinfoset_arr['shareoldsmowner'] = $_REQUEST['shareoldsmowner'];
    }
    if(isset($_REQUEST['relmodule_scope']) && !empty($_REQUEST['relmodule_scope'])){
        $allocate->relatedinfoset_arr['relmodule_scope'] = $_REQUEST['relmodule_scope'];
        $allocate->relatedinfoset_arr['relmodule_selectedtabid_str'] = $_REQUEST['selectedtabid_str'];
    }
    if(isset($_REQUEST['reldata_scope']) && !empty($_REQUEST['reldata_scope'])){
        $allocate->relatedinfoset_arr['reldata_scope'] = $_REQUEST['reldata_scope'];
    }
    if(isset($_REQUEST['selectlen']) && !empty($_REQUEST['selectlen'])){
        $allocate->relatedinfoset_arr['type'] = 'seniorAverageHigndistribution';
    }else{
        $allocate->relatedinfoset_arr['type'] = 'seniorHigndistribution';
    }
}

$allocate->set_userid($user_role_id)->init_count()->switch_entrance();

$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
//$allocate->header();
?>