<?php
global $adb,$current_user;
if(isset($_REQUEST['record']) && $_REQUEST['record'])
$record=$_REQUEST['record'];
if(isset($_REQUEST['approveid']) && $_REQUEST['approveid'])
$approveid=$_REQUEST['approveid'];
if(isset($_REQUEST['stepid']) && $_REQUEST['stepid'])
$stepid=$_REQUEST['stepid'];
/*$query='select T1.stepidcount,T2.nextstepidcount from
(select count(stepid) as stepidcount from ld_approvelog where crmid=? and approveid=? and stepid=?
) as T1,
(select count(nextstepid) as nextstepidcount from ld_approvelog where crmid=? and approveid=? and nextstepid=?
)as T2';
$result=$adb->pquery($query,array($record,$approveid,$stepid,$record,$approveid,$stepid));
$stepidcount=$adb->query_result($result,0,'stepidcount');
$nextstepidcount=$adb->query_result($result,0,'nextstepidcount');
if($stepidcount==$nextstepidcount){
    echo "###Approved###";
    exit();
}
*/
$query="select stepid,approved_by from ld_approvelog where crmid=? and approveid=?  ORDER BY createdtime asc limit 1 ;"
$result=$adb->pquery($query,array($record,$approveid,$stepid,$current_user->id))
if($adb->num_rows($result)>0){
    $res_stepid=$adb->query_result($result,0,0);
    $res_approve_by=$adb->query_result($result,0,1);
    if($res_stepid==$stepid&&$res_approve_by==$current_user->id)
            echo "###Approved###";
    exit();
}
?>