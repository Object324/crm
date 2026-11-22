<?php
/*******************************************
**edit:kevin
**date:2013-09-12
**reason:审批流程详情
*******************************************/
global $adb;
require_once('Smarty_setup.php');
$smarty=new lingdangCRM_Smarty;
if(isset($_REQUEST['record']) && $_REQUEST['record'])
$record=$_REQUEST['record'];
if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module'])
$fld_module=$_REQUEST['fld_module'];
if(isset($_REQUEST['approveid']) && $_REQUEST['approveid'])
$approveid=$_REQUEST['approveid'];
if(isset($_REQUEST['stepid']) && $_REQUEST['stepid'])
$stepid=$_REQUEST['stepid'];
$query="select * from ld_approvestep where approveid=? order by sequence ";
$result=$adb->pquery($query,array($approveid));
$num_rows=$adb->num_rows($result);
require_once('modules/Approve/Approve.php');

$approve=new Approve();
$approvestep=array();

for($i=0;$i<$num_rows;$i++){
    $approvetype=$adb->query_result($result,$i,'approvetype');
    $approvevalue=$adb->query_result($result,$i,'approvevalue');    
    $approvebyid=$approve->getApproveBy($approvetype,$approvevalue,$record);
  
    $approvebyname=$approve->getApproveByName($approvebyid);
 
    $approvestep[]=array('STEPID'=>$adb->query_result($result,$i,'id'),
 
    'STEPNAME'=>$adb->query_result($result,$i,'name'),
    'APPROVEBYNAME'=>$approvebyname,
    'ENDED'=>$adb->query_result($result,$i,'ended'),
    'STEP'=>$adb->query_result($result,$i,'step'),
	'specifyapproverid'=>$adb->query_result($result,$i,'specifyapproverid')
    );
  
       
}

echo "###SUCCESS###";
$smarty->assign('STEPID',$stepid);
$smarty->assign('APPROVESTEP',$approvestep);
$smarty->display('Approve/ApproveStepResult.tpl');
exit();
?>