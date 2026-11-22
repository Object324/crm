<?php
global $adb;
$bangwo8supportnameid=$_REQUEST['bangwo8supportnameid'];//帮我吧客服账号id
$operate_smownerid=$_REQUEST['operate_smownerid'];//新增或者编辑同步crm的负责人
$userid=$_REQUEST['selectmember'];//用户，部门信息
/*editor:gyq_14 reason:统一为类型+信息 date:20160715*/
//$selectgroup = $_REQUEST['selectgroup'];//部门信息
$supportname=$_REQUEST['supportname'];//客服账号
$allocatetype = $_REQUEST['allocatetype'];//用户范围 用户user|部门group|所有用户all
/*$userid = '';
switch($allocatetype){
	case 'group':
	   $userid = $selectgroup;
	   break;
	case 'user':
	   $userid = $selectmember;
	   break;
}*/
$updatebanwo8Supportnamesql='update ld_bangwo8_supportname set operate_smownerid=?,allocatetype=?,userid=? where id=?';
$adb->pquery($updatebanwo8Supportnamesql,array($operate_smownerid,$allocatetype,$userid,$bangwo8supportnameid));
 $_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>