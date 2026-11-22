<?php
/****************************************************************
**edit:wym
**date:2023/12/20
**reason:每页显示单据条数
****************************************************************/
global $adb,$current_user;

$modulename=$_REQUEST['modulename'];
$pagepernum=$_REQUEST['pagepernum'];
//以前的每页显示多少条数对应的label是MaxEntriesPerPage,现在为了继承以前数据并和以前区分开,label改成了MaxEntriesPerPageByuser(XUQIU1002380 需求要求)
if(isset($pagepernum) && $pagepernum!='') {
    setUsersettingByLabel($modulename, $current_user->id, 'MaxEntriesPerPageByuser', $pagepernum);
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,'',"success");
exit();
?>