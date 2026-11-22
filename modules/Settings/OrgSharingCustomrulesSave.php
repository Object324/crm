<?php
global $current_user;
if($current_user->getHaveSetProfile("Settings")!="yes") {
    exit();
}
global $adb;
if(!empty($_REQUEST['mode']) && $_REQUEST['mode'] == 'save'){
    $customruleid=$_REQUEST['customruleid'];
    $tabid=$_REQUEST['frommodule'];
    $permission=$_REQUEST['permission'];
    $groupid=$_REQUEST['groupid'];
    $userid=$_REQUEST['userid'];
    $user_role=$_REQUEST['user_role'];
    $advft_criteria=$_REQUEST['advft_criteria'];
    $advft_criteria_groups=$_REQUEST['advft_criteria_groups'];
    $query = 'select 1 from ld_org_share_customrules where customruleid = ?';
    $result = $adb->pquery($query,array($customruleid));
    $num_rows = $adb->num_rows($result);
    if($num_rows >= 1){
        $query = "update ld_org_share_customrules set tabid = ?,permission = ?,profileid = ?,groupid=?,userid = ?,share_demand = ?,share_demand_groups = ?,modifiedtime=? where customruleid = ?";
        $adb->pquery($query,array($tabid,$permission,$user_role,$groupid,$userid,$advft_criteria,$advft_criteria_groups,date('Y-m-d H:i:s'),$customruleid));
    }else{
        $query = "insert into ld_org_share_customrules(customruleid,tabid,permission,profileid,groupid,userid,share_demand,share_demand_groups,createdtime) values (?,?,?,?,?,?,?,?,?)";

        $adb->pquery($query,array($customruleid,$tabid,$permission,$user_role,$groupid,$userid,$advft_criteria,$advft_criteria_groups,date('Y-m-d H:i:s')));
    }
}
$cachekey = 'cache_getmodulesharecustominfo';
unsetCache($cachekey);
$_REQUEST['diony']='yes';
ConvertTojsonString(1,'',"success");


?>

