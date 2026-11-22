<?php
/*******************************************************
**更新操作
**edit:kevin
**date:2013-10-31
**reason:新增编辑仓库
*******************************************************/
require_once('Smarty_setup.php');
global $adb,$mod_strings,$theme,$app_strings,$current_user;
$MergeSmowner=getCurSmOwnerSearchScope($currentModule);
//print_r(count($MergeSmowner['UserCombo']));
//$MergeSmowner['UserCombo']
$userid=$current_user->id;
$smarty=new lingdangCRM_Smarty;
$mode='create';
if(isset($_REQUEST['warehousename']) && $_REQUEST['warehousename']!='')
	$warehousename=$_REQUEST['warehousename'];
$allocatetype = 'all';
if(isset($_REQUEST['record']) && $_REQUEST['record'] !=''){
    $record=$_REQUEST['record'];
    $query='select ld_warehouse.name,ld_warehouse.description,ld_warehouse2user.userid,ld_warehouse.allocatetype from ld_warehouse 
    left join ld_warehouse2user on ld_warehouse.id=ld_warehouse2user.warehouseid where ld_warehouse.id=?';
    $result=$adb->pquery($query,array($record));
    $num_rows=$adb->num_rows($result);
    $name=$adb->query_result($result,0,'name');
    $description=$adb->query_result($result,0,'description');
    $useridsarr=array();
    for($i=0;$i<$num_rows;$i++){
        $uid=$adb->query_result($result,$i,'userid');
		$allocatetype=$adb->query_result($result,$i,'allocatetype');
        $useridsarr[$uid]=$uid;
    }    
    $mode='edit';
  
    $smarty->assign('WAREHOUSENAME',$name);
    $smarty->assign('DESCRIPTION',$description);
    $smarty->assign('USERIDSARR',$useridsarr);
    $smarty->assign('RECORD',$record);
}

$uids = !empty($useridsarr)?implode(',',$useridsarr):'';
$smarty->assign('UIDS',$uids);
$smarty->assign('allocatetype',$allocatetype);

if(isset($useridsarr[-1]) ||empty($_REQUEST['record'])){
    $smarty->assign('ALLUSER','checked="checked"');
}else{
    $smarty->assign('SELECTUSER','checked="checked"');
}

$smarty->assign('MODE',$mode);

if(isset($_REQUEST['module']) && $_REQUEST['module']!='')
$return_module=$_REQUEST['module'];
if(isset($_REQUEST['action']) && $_REQUEST['action']!='')
$return_action=$_REQUEST['action'];
$smarty->assign('RETURN_MODULE',$return_module);
$smarty->assign('RETURN_ACTION','ListWareHouse');

$smarty->assign('MOD',$mod_strings);
$smarty->assign('THEME',$theme);
$smarty->assign('APP',$app_strings);
 $_REQUEST['diony']='diony';
 if($mode == 'edit'){
	$arr['title'] = getFixedLabel('EDIT') . '&nbsp;&nbsp;'.$name;
 }else{
	$arr['title'] = getFixedLabel('LBL_WASEHOUSE');
 }
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("WareHouse/EditWareHouse.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>