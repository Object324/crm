<?php
/**********************************************************
**更新操作
**edit:kevin
**date:2013-11-1
**reason:保存仓库信息
**********************************************************/
global $adb;
if(isset($_REQUEST['wareHouseName']) && $_REQUEST['wareHouseName']!='')
$name=$_REQUEST['wareHouseName'];
if(isset($_REQUEST['description']) && $_REQUEST['description']!='')
$description=$_REQUEST['description'];
if(isset($_REQUEST['owners']) && $_REQUEST['owners']!='')
	$userids=$_REQUEST['owners'];
if(isset($_REQUEST['record']) && $_REQUEST['record']!=''){
    $record=$_REQUEST['record'];
    $query='select * from ld_warehouse where id!=? and name=?';
    $result=$adb->pquery($query,array($record,$name));
}
else{
    $query='select * from ld_warehouse where name=?';
    $result=$adb->pquery($query,array($name));
}

if(isset($_REQUEST['return_module']) && $_REQUEST['return_module']!='')
$return_module=$_REQUEST['return_module'];
if(isset($_REQUEST['return_action']) && $_REQUEST['return_action']!='')
$return_action=$_REQUEST['return_action'];
$num_rows=$adb->num_rows($result);

if($num_rows>0){
	echo '####Used###';
	exit();
}
if(empty($userids)){
	$userids = -1;
}
$userarr=explode(',',$userids);
$allocatetype = $_REQUEST['radiouser'];

if(empty($record)){
    $id=$adb->getUniqueID('ld_warehouse');
    $query='insert into ld_warehouse(id,name,description,allocatetype) value(?,?,?,?)';//仓库信息，仓库状态默认为0(使用中)
    $adb->pquery($query,array($id,$name,$description,$allocatetype));   
}else{
    $query='update ld_warehouse set name=?,description=?,allocatetype=? where id=?';
    $id=$record;
    $adb->pquery($query,array($name,$description,$allocatetype,$id));
    $query='delete from ld_warehouse2user where warehouseid=?';
    $adb->pquery($query,array($id));   
}
//zkt 20240524 BUG20240523-71  仓库名称已改了，列表界面还是显示的是 系统默认的仓库名称仓库名称
$key = 'cache_warehousename';
unsetCache($key);
function getWareName($name)
{
    global $adb;
    $sql = "select * from ld_warehouse where name = '".$name."'";
    $result=$adb->pquery($query,array());
    return $adb->num_rows($result); 
}

if(!empty($_REQUEST['radiouser'])){
	$adb->pquery('delete from ld_warehouse2user where warehouseid = ? and userid > 0',array($id));
	foreach($userarr as $userid){
		$query='insert into ld_warehouse2user(warehouseid,userid) values (?,?)';
		$adb->pquery($query,array($id,$userid));
	}
}

echo '####success###';
exit();
?>