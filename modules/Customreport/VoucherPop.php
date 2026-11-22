<?php
$smarty = new lingdangCRM_Smarty;
$sa=getDatainterface('sa');	//获取DB用户名
$pwd=getDatainterface('pwd');//获取DB密码
$hostname=getDatainterface('hostname');//获取服务器IP地址
$databasename=getDatainterface('databasename');//获取DB name
$con = conSqlserver($hostname,$sa,$pwd,$databasename);
if($con['conResult'] != 1){
	echo 'ERRORDB';die;
}
$SqlCon = $con['sqlcon'];
if(!empty($_REQUEST['subjectcode'])){
	$subjectcode = $_REQUEST['subjectcode'];
	//$subjectcode = '5101.05';
	$query = 'select count(1) from t_account where FNumber = \''.$subjectcode.'\'';
	$result = $SqlCon->Query_result($query);
	$data=$SqlCon->fetch_row($result);
	if(empty($data[0])){
		echo 'ERRORCODE';die;
	}
}
$query = "select fname,fuserid from t_user where fuserid > 0";
$result = $SqlCon->Query_result($query);
$count = 1;
$data = $SqlCon->fetch_all($result,$count);
foreach($data as $key => $val){
    $users[$val['fuserid']] = $val['fname'];
}
$smarty->assign('DATE',date("Y-m-d"));
$smarty->assign('USERS',$users);
$smarty->assign('STARTDATE',$_REQUEST['startdate']);
$smarty->assign('ENDDATE',$_REQUEST['enddate']);
$smarty->display("modules/Customreport/VoucherPop.tpl");
exit();

?>