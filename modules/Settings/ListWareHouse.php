<?php
/***************************************************************
**更新操作
**edit:kevin
**date:2013-10-31
**reason:仓库序时簿
***************************************************************/
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='ListWareHouse';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
global $adb,$theme,$mod_strings,$default_charset;
$smarty=new lingdangCRM_Smarty;
$smarty->assign('THEME',$theme);
$smarty->assign('MOD',$mod_strings);
//列表分配
if(!empty($_REQUEST['ajax']) && $_REQUEST['ajax'] == true){
	if($_REQUEST['type'] == 'allocate'){
		$update = "update ld_warehouse set allocatetype = ? where id = ?";
		$adb->pquery($update,array($_REQUEST['radiotype'],$_REQUEST['record']));
		if($_REQUEST['radiotype'] == 'all'){
			$_REQUEST['selectallocateid'] = -1;
		}
		$delete = "delete from ld_warehouse2user where warehouseid = ?";
		$adb->pquery($delete,array($_REQUEST['record']));
		$userids = explode(',',$_REQUEST['selectallocateid']);
		foreach($userids as $userid){
			$insert = "insert into ld_warehouse2user(warehouseid,userid) values (?,?)";
			$adb->pquery($insert,array($_REQUEST['record'],$userid));
		}
		$_REQUEST['diony']='yes';
		ConvertTojsonString(1,array(),"success");
	}
}
//获取所有的仓库
$query="select id,STATUS,NAME,last_name,allocatetype,userids from (
SELECT 
    ld_warehouse.id, 
    ld_warehouse. STATUS, 
    ld_warehouse. NAME,
	ld_warehouse.allocatetype,
    'AllUser' as last_name,
	'-1' as userids
FROM 
ld_warehouse 
INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'all'
GROUP BY 
    ld_warehouse.id
UNION ALL
SELECT 
    ld_warehouse.id, 
    ld_warehouse. STATUS, 
    ld_warehouse. NAME,
	ld_warehouse.allocatetype, 
    GROUP_CONCAT(ld_users.last_name SEPARATOR '; ' ) as last_name,
		 GROUP_CONCAT(ld_warehouse2user.userid) as userids 
FROM 
ld_warehouse 
INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'user'
INNER JOIN ld_users ON ld_warehouse2user.userid = ld_users.id 
GROUP BY 
    ld_warehouse.id
UNION ALL
SELECT 
    ld_warehouse.id, 
    ld_warehouse. STATUS, 
    ld_warehouse. NAME,
	ld_warehouse.allocatetype, 
    GROUP_CONCAT(ld_groups.groupname SEPARATOR '; ' ) as last_name,
		GROUP_CONCAT(ld_warehouse2user.userid) as userids
FROM 
ld_warehouse 
INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'group'
INNER JOIN ld_groups ON ld_warehouse2user.userid = ld_groups.groupid 
GROUP BY 
    ld_warehouse.id
UNION ALL
SELECT 
    ld_warehouse.id, 
    ld_warehouse. STATUS, 
    ld_warehouse. NAME,
	ld_warehouse.allocatetype, 
    GROUP_CONCAT(ld_profile.profilename SEPARATOR '; ' ) as last_name,
		GROUP_CONCAT(ld_warehouse2user.userid) as userids
FROM 
ld_warehouse 
INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'role'
INNER JOIN ld_profile ON ld_warehouse2user.userid = ld_profile.profileid 
GROUP BY 
    ld_warehouse.id
) as temp ORDER BY id 
";
$result=$adb->query($query);
$num_rows=$adb->num_rows($result);

$warehouse=array();
$j = 1;
for($i=0;$i<$num_rows;$i++){
    $k=$j;
    $id=$adb->query_result($result,$i,'id');
    $status=$adb->query_result($result,$i,'status');
    $name=$adb->query_result($result,$i,'name');
    $last_name=$adb->query_result($result,$i,'last_name');
	$allocatetype=$adb->query_result($result,$i,'allocatetype');
	$userids=$adb->query_result($result,$i,'userids');
    if($last_name == 'AllUser'){//所有用户
        $last_name = getFixedLabel('ALLTHEUSERS');
    }
    $warehouse=array('k'=>$k,'id'=>$id,'status'=>$status,'name'=>$name,'last_name'=>$last_name,'allocatetype'=>$allocatetype,'userids'=>$userids);
    $warehouses[$k]=$warehouse; 
    $j++;           
  }

$smarty->assign('WAREHOUSE',$warehouse);                          

$smarty->assign('WAREHOUSES',$warehouses);
$smarty->assign('LANGUAGETYPE',$languageType);

// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
$arr['content']= $smarty->fetch('WareHouse/ListWareHouse.tpl');
ConvertTojsonString(1,$arr,"success");
?>