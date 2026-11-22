<?php
global $adb;
require_once('Smarty_setup.php');
require_once('./modules/Users/Group.class.php');
$group_focus = new Group();
require_once('./include/Zend/Json.php');
$json = new Zend_Json();
$smarty=new lingdangCRM_Smarty;
$bangwo8Supportnameid=$_REQUEST['bangwo8supportnameid'];
//获取客服账号信息
$bangwo8_supportnamesql='
                SELECT
                    supportname,
                    operate_smownerid,
                    allocatetype,userid
                FROM
                    ld_bangwo8_supportname
                WHERE
                ld_bangwo8_supportname.id =?';
$bangwo8_supportnameResult=$adb->pquery($bangwo8_supportnamesql,array($bangwo8Supportnameid));
$bangwo8_supportnameNum=$adb->num_rows($bangwo8_supportnameResult);
if($bangwo8_supportnameNum>0){
    $supportname=$adb->query_result($bangwo8_supportnameResult,0,'supportname');
    $operate_smownerid=$adb->query_result($bangwo8_supportnameResult,0,'operate_smownerid');
	$allocatetype=$adb->query_result($bangwo8_supportnameResult,0,'allocatetype');
	if($allocatetype == 'user')
		$userids=$adb->query_result($bangwo8_supportnameResult,0,'userid');	
	else
        $userids=$adb->query_result($bangwo8_supportnameResult,0,'userid');
}
$i = 0;
//可用成员
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
foreach($MergeSmowner["UserCombo"] as $userid => $users){
    $userInfo[$i]['id'] = $userid;
    foreach($users as $last_name => $sel){
        $userInfo[$i]['last_name'] = $last_name;
    }
    $i++;
}
$smarty->assign('ALLOCATETYPE',$allocatetype);
$smarty->assign('USERIDS',$userids);
//$smarty->assign('GROUPIDS',$groupids);
$smarty->assign('USERINFO',$userInfo);
$smarty->assign('BANGWO8SUPPORTNAMEID',$bangwo8Supportnameid);
$smarty->assign('BLOCKIDSETTING',$_REQUEST['blockidsetting']);
$smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
$smarty->assign('SUPPORTNAME',$supportname);
$smarty->assign('OPERATESMOWNERID',$operate_smownerid);
//echo '&#&#&#';
//$smarty->display("settingsBangwo8info.tpl");
//exit();
$_REQUEST['diony']='yes';
$arr['title'] = getFixedLabel('SETTINGS');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('settingsBangwo8info.tpl');
ConvertTojsonString(1,$arr,"success");
?>