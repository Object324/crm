<?php
global $adb;
if(!empty($_REQUEST['accountname'])){
	$accountname = $_REQUEST['accountname'];	//客户名称 
	$cf_2967 = $_REQUEST['cf_2967'];	//项目
	$assigned_user_id = $_REQUEST['assigned_user_id'];
	//分公司
	$query = "SELECT c.groupname from ld_users2group a
		LEFT JOIN  ld_groups b on a.groupid=b.groupid
		LEFT JOIN ld_groups c on SUBSTRING_INDEX(substring_index(b.parentgroup,'::',2),'::',-1)=c.groupid
		where a.userid= ? GROUP BY a.userid";
	$result = $adb->pquery($query,array($assigned_user_id));
	$groupname = $adb->query_result($result,0,0);

	$query = 'select 1 from ld_account LEFT JOIN ld_accountscf on ld_accountscf.accountid = ld_account.accountid
	where ld_account.accountname = ? and ld_account.fenggongsi = ?';
	if(!empty($cf_2967)){
		$query .= ' and ld_accountscf.cf_2967 = "'.$cf_2967.'"';
	}
	if(!empty($_REQUEST['record'])){
		$query .= ' and ld_account.accountid != "'.$_REQUEST['record'].'"';
	}
	$result = $adb->pquery($query,array($accountname,$groupname));
	if($adb->num_rows($result) >= 1){
		echo '##error##';exit();
	}
}
echo '##success##';exit();