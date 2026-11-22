<?php
global $adb,$currentModule,$current_user;




/**
 * @edit:chj
 * @date:2014-9-16
 * @reason:判断公海客户分配时，是否已经被分配  $_REQUEST['record']:单条分配 $_REQUEST['idstring']:批量分配
 * @description:0011129: 并发测试bug一：对同一个公海客户，2个用户同时领取，结果都提示领取成功，但实际上是最后一个操作的用户领取成功。
 */
if(isset($_REQUEST['record']))
{
    //publicaccount 1:未分配,2:分配,3:领取
    $AllAccountId = $_REQUEST['record'];
    $query = "select publicaccount,pool_id from ld_account where accountid = ?";
    $publicresult = $adb->pquery($query,array($AllAccountId));
    if($adb->query_result($publicresult,0,'publicaccount') == 2) //已分配
    {
        echo "###error###2";
        exit();
    }
	$pool_id = $adb->query_result($publicresult,0,'pool_id');
}
if(!empty($pool_id)){
	crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
	$cls_PublicAccounts = new cls_PublicAccounts($currentModule);
	$public_account = $cls_PublicAccounts->getPublicAccountConfig();
	 $useraccount = $public_account['public_account_pool'][$pool_id]['administrators'];
	 $adminaccount = $public_account['public_account_pool'][$pool_id]['userids'];
	//$alphafrom .=' inner join  ld_cosler c on ((CONV(HEX(convert(left(last_name,1) using gbk)),16,10) between c.cBegin and c.cEnd ';
	// or is_admin="on"    公海分配成员， 暂时不加系统用户管理员，跟luyx讨论
	if(!empty($adminaccount) && !empty($useraccount))
	$sql="select last_name,id  from ld_users  where ( id in ( ".$adminaccount.') or id in ('.$useraccount.')) and status="active"';
	elseif(!empty($adminaccount) && empty($useraccount))
	$sql="select last_name,id  from ld_users  where ( id in ( ".$adminaccount.')) and status="active"';
	elseif((empty($adminaccount) && !empty($useraccount)))
	$sql="select last_name,id  from ld_users  where ( id in (".$useraccount.')) and status="active"';
	else
	$sql="select last_name,id  from ld_users  where   is_admin='on'  and status='active' ";


	$sql.= ' order by CONVERT( last_name USING gbk)  ASC ';
	$result=$adb->pquery($sql,array());
}
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $allocateusers[$adb->query_result($result,$i,1)]=$adb->query_result($result,$i,0);
   
    
}
$smarty = new lingdangCRM_Smarty();
$smarty->assign("ALLOCATEUSERS",$allocateusers);
 $smarty->assign("optText",$adb->query_result($result,0,0));

if(isset($_REQUEST['idstring'])||(isset($_REQUEST['pagepublicaccounttype']) && $_REQUEST['pagepublicaccounttype'] == 'NOALLOCATE'))
{
    $smarty->assign("MASSALLOCATE",'yes');
    $smarty->assign("IDSTRING",$_REQUEST['idstring']);
    
}
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
if(isset($_REQUEST['idstring'])=='all')
{
     $_REQUEST['mass_batch_num_all']=$btach_num;
    $smarty->assign('TOTALSELECTROWS',$_REQUEST['totalrows']);
}
$excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
$storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idstring'],$excludedRecords);
$storearray=array_filter($storearray);
$idlist_n=implode(',',$storearray);
$idlist_n_d = substr($idlist_n,0,strlen($idlist_n)-1); 

$sql = "select smownerid from ld_account where accountid in (".$idlist_n_d.") order by accountid asc ";
$result=$adb->pquery($sql,array());
$assign_user_id=array();
$num = $adb->num_rows($result);
for($i=0;$i<$num;$i++)
{
   $assign_user_id[$i]= $adb->query_result($result,$i,'smownerid'); 
}
sort($assign_user_id);
$smarty->assign("assign_user_id",implode(',', $assign_user_id));
if(isset($_REQUEST['detailview']) && $_REQUEST['detailview'] == 1){
	$smarty->assign("MASSALLOCATE",'yes');
}
if(isset($_REQUEST['listview']) && $_REQUEST['listview'] == 1 &&isset($_REQUEST['idstring'])){
	$smarty->assign("MASSALLOCATE",'no');
}
$smarty->assign('DETAILSVIEW',$_REQUEST['detailview']);
if($_REQUEST['record'])
{
   
    $smarty->assign("RECORD",$_REQUEST['record']);
}
$smarty->assign("VIEWID",$_REQUEST['viewid']);
$smarty->assign("SEARCHSCOPE",$_REQUEST['SearchScope']);
$smarty->assign("ACCOUNTTYPE",$_REQUEST['pagepublicaccounttype']);
if($_REQUEST['start'])
{
    $smarty->assign("START",$_REQUEST['start']);
}
echo "###SUCCESS###";

$smarty->display("AllocateUsers.tpl");
exit();

?>