<?php
ob_clean();
global $adb,$theme,$mod_strings,$current_user;
$languageType= getLanguageType($current_user);
$parenttabid=$_REQUEST['parenttabid'];
$smarty=new lingdangCRM_Smarty;

$sql='select * from ld_parenttab  where parenttabid=? ';
$presult=$adb->pquery($sql,array($parenttabid));

$inactive_icon = $adb->query_result($presult,0,'inactive_icon');//zxm2021-1206 菜单图标-未选中
$active_icon = $adb->query_result($presult,0,'active_icon');//zxm2021-1206 菜单图标-选中
//zxm2021-1206 判断图标文件是否存在
if(empty($inactive_icon)||!file_exists(globalStatic::$root_directory.$inactive_icon)){
    $inactive_icon = '';//图标值为空 或者文件不存在 返回空
}
if(empty($active_icon)||!file_exists(globalStatic::$root_directory.$active_icon)){
    $active_icon = '';//图标值为空 或者文件不存在 返回空
    if(!empty($inactive_icon)&&!file_exists($inactive_icon)){
        $active_icon = $inactive_icon;//如果选中图标不存在 未选中图标存在 则使用未选中图标
    }
}
//图标文件名
$inactive_icon_arr=explode('/',$inactive_icon);
$inactive_icon_name = $inactive_icon_arr[sizeof($inactive_icon_arr)-1];
$active_icon_arr=explode('/',$active_icon);
$active_icon_name = $inactive_icon_arr[sizeof($active_icon_arr)-1];

$inactive_icon = empty($inactive_icon)?'':$inactive_icon.'?a='.rand(0,999);
$active_icon = empty($active_icon)?'':$active_icon.'?a='.rand(0,999);
$smarty->assign('inactive_icon',$inactive_icon);//zxm2021-1206 菜单图标-未选中
$smarty->assign('active_icon',$active_icon);//zxm2021-1206 菜单图标-选中
$smarty->assign('inactive_icon_name',$inactive_icon_name);//zxm2021-1206 菜单图标名称-选中
$smarty->assign('active_icon_name',$active_icon_name);//zxm2021-1206 菜单图标名称-选中
$parenttablelabel = getFixedLabel('CONTROLPANEL');

$smarty->assign('PARENTTABID',$parenttabid);
$smarty->assign('THEME',$theme);
$smarty->assign('MOD',$mod_strings);
$smarty->assign('APP',$app_strings);

$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('EDIT');//.'"'.$parenttablelabel.'"&nbsp;&nbsp;('.getFixedLabel('LBL_TABLIST_DESCRIPTION').')';

$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Menu/EditMenu8.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>
