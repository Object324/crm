<?php
/********************************************************
**更新操作
**edit:kevin
**date:2013-11-11
**reason:菜单定制
********************************************************/
global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='MenuList';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
global $adb,$theme,$app_strings,$mod_strings,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$languageTypeNew = getLanguageType($current_user);
$smarty=new lingdangCRM_Smarty;
//wym 原先存在ld_organizationdetails表中,现在修改成在ld_module_setting_byuser表里,如果新表没数据则取老表的数据
$menuback_color = getUsersettingByLabel('notbymodule',$current_user->id,'Menuback_color');
if($menuback_color){
    $menuhover_color = getUsersettingByLabel('notbymodule',$current_user->id,'Menuhover_color');
}else{
    $query = 'select menuback_color,menuhover_color from ld_organizationdetails';
    $result = $adb->pquery($query,array());
    $menuback_color = $adb->query_result($result,0,'menuback_color');
    $menuhover_color = $adb->query_result($result,0,'menuhover_color');
}
if(empty($menuback_color) && empty($menuhover_color)){
    $file_path = "dataCache/tabdatas/skinset.css";
	if(file_exists($file_path)){
		$file_arr = file($file_path);
		for($i=0;$i<count($file_arr);$i++){//逐行读取文件内容
			if(strpos($file_arr[$i],'.btn1.choosed_color{background: ') !== false){
				$length = strlen('.btn1.choosed_color{background: ');
				$menuback = substr($file_arr[$i],$length,7);	//菜单背景色
				$smarty->assign('MENUBACK',$menuback);
			}
			if(strpos($file_arr[$i],'.btn2.choosed_color{background: ') !== false){
				$length = strlen('.btn2.choosed_color{background: ');
				$menuhover = substr($file_arr[$i],$length,7);	//选中色背景
				$smarty->assign('MENUHOVER',$menuhover);
			}
			fclose($file_arr);
		}
	}
}else{
	$smarty->assign('MENUBACK',$menuback_color);
	$smarty->assign('MENUHOVER',$menuhover_color);
}

/**菜单排序操作
**@edit:liushuai
**@date:2020-8-62
**@reason:ID1000738/网页端菜单定制优化：增加“菜单排序”功能
 */
$type = $_REQUEST['type'];
if ($type == 'delete'){ //XUQIU20240823-04 网页端菜单定制增加删除功能 wsh 20240826
    $parenttabid = $_REQUEST['parenttabid'];
    $query = 'select allow_delete from ld_parenttab where parenttabid = ?';
    $result = $adb->pquery($query,array($parenttabid));
    $allow_delete = $adb->query_result($result,0,'allow_delete');
    if ($allow_delete == "yes"){
        $adb->pquery('delete from ld_parenttab where parenttabid = ?', array($parenttabid));
        $adb->pquery('delete from ld_tranlabel  where ld_tranlabel.trantable = ? and ld_tranlabel.tabid = ?', array("ld_parenttab",$parenttabid));
        $adb->pquery('delete from ld_parenttabrel  where ld_parenttabrel.parenttabid = ?', array($parenttabid));
        create_tab_data_file();
        create_parenttab_data_file();
        create_parent_language();
        $cachekey = 'cache_getparenttabrelinfo';
        unsetCache($cachekey);
    }
}
if ($type == 'sortMenu') { //菜单排序(弹窗)
    $query = "select ld_parenttab.parenttabid,ld_tranlabel.fieldlabel,ld_parenttab.sequence
 from ld_parenttab inner  join ld_tranlabel on ld_tranlabel.relateid=ld_parenttab.parenttabid
where  trantable='ld_parenttab'  and ld_parenttab.visible in(0,1) and languagetype = ? order by ld_parenttab.sequence";
    $result = $adb->pquery($query,array($languageTypeNew));
    $num_rows = $adb->num_rows($result);
    if($num_rows > 0){
        for($i = 0; $i<$num_rows; $i++){
            $blockid = $adb->query_result($result,$i,'parenttabid');
            $sequence = $adb->query_result($result,$i,'sequence');
            $blockname = $adb->query_result($result,$i,'fieldlabel');
            $allblocks[$blockid] = array('sequence'=>$sequence,'blockname'=>$blockname);
        }
    }

    $smarty->assign('ALLBLOCKS',$allblocks);
    $_REQUEST['diony']='diony';
    $arr['title'] = getFixedLabel('SortMenu');
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $str=$smarty->fetch("Menu/SortMenu.tpl");
    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
    exit();
}else if ($type == 'saveSortMenu') {   //菜单排序(保存)
    if(!empty($_REQUEST['tabids'])){
        $tabids_arr = explode(',',$_REQUEST['tabids']);
        $sequence = 1;
        foreach($tabids_arr as $parenttabid){
            $adb->pquery('update ld_parenttab set sequence = ? where parenttabid = ?',array($sequence,$parenttabid));
            $sequence++;
        }
        clearAllCache();
    }
}else if($type == 'allocate'){
	$query = "update ld_parenttab set allocatetype = ?,allocateid = ? where parenttabid = ?";
	$adb->pquery($query,array($_REQUEST['radiotype'],$_REQUEST['selectallocateid'],$_REQUEST['record']));
	$_REQUEST['diony']='yes';
    //网页菜单分配清除缓存
    unsetCache('cache_getparenttabrelinfo');
    create_tab_data_file();
    create_parenttab_data_file();
    create_parent_language();
	ConvertTojsonString(1,array(),"success");
}

    /*
    $query='select ld_parenttab.parenttabid,ld_tranlabel.fieldlabel,ld_parenttab.sequence,ld_parenttab.visible
     from ld_parenttab inner  join ld_tranlabel on ld_tranlabel.relateid=ld_parenttab.parenttabid
    where ld_tranlabel.languagetype=? and trantable=?  order by ld_parenttab.sequence';
    $result=$adb->pquery($query,array($languageType,'ld_parenttab'));
    */
/**
 *@edit:andy 
 *@date:
 *@reason:
 *@version:
 */
 $query='select ld_parenttab.parenttab_label,ld_parenttab.parenttabid,ld_tranlabel.fieldlabel,ld_parenttab.sequence,ld_parenttab.visible,ld_parenttab.allow_delete,languagetype,inactive_icon,active_icon,allocatetype,allocateid
 from ld_parenttab inner  join ld_tranlabel on ld_tranlabel.relateid=ld_parenttab.parenttabid
where  trantable=?  and ld_parenttab.visible in(0,1)  order by ld_parenttab.sequence';
$result=$adb->pquery($query,array('ld_parenttab'));
$num_rows=$adb->num_rows($result);
$menu=array();
$setting_parenttabid = 8;
$reg = RegOp::getInstance();
for($i=0;$i<$num_rows;$i++){
    $parenttab_label = $adb->query_result($result,$i,'parenttab_label');
    //zkt 20240904 BUG20240914-10 没有授权小程序商城时，网页端菜单定制中的“商城设置”菜单也应该不显示
    if(!$reg->getShopProfile()&&$parenttab_label=='ShopSettings'){
        unset($parenttab_label);
        continue;
    }
    $parenttabid=$adb->query_result($result,$i,'parenttabid');
    $languagetype = $adb->query_result($result,$i,'languagetype');
    $menu[$parenttabid]['parenttabid']=$parenttabid;
    $menu[$parenttabid]['parenttab_label']=$parenttab_label;
    $menu[$parenttabid]['allow_delete']=$adb->query_result($result,$i,'allow_delete');
    $menu[$parenttabid]['sequence']=$adb->query_result($result,$i,'sequence');
    $menu[$parenttabid]['visible']=$adb->query_result($result,$i,'visible');
	$menu[$parenttabid]['allocatetype']=$adb->query_result($result,$i,'allocatetype');
    $menu[$parenttabid]['allocateid']=$adb->query_result($result,$i,'allocateid');
    $menu[$parenttabid]['name'][$languagetype]=$adb->query_result($result,$i,'fieldlabel');
    $menu[$parenttabid]['inactive_icon']=$adb->query_result($result,$i,'inactive_icon');
    $menu[$parenttabid]['inactive_icon'] = empty($menu[$parenttabid]['inactive_icon'])?'':$menu[$parenttabid]['inactive_icon'].'?a='.rand(0,999);
    $menu[$parenttabid]['active_icon']=$adb->query_result($result,$i,'active_icon');
    $menu[$parenttabid]['active_icon'] = empty($menu[$parenttabid]['active_icon'])?'':$menu[$parenttabid]['active_icon'].'?a='.rand(0,999);
    // ljj 2024-12-11 BUG20241209-57 用户和权限管理应该是在预制在最下方的，并且我记得这个模块是不允许修改位置
    if ($parenttab_label == 'Settings'){
        $setting_parenttabid = $parenttabid;
    }
    unset($parenttab_label);
    unset($parenttabid);
    unset($languagetype);
}

$setting_menu_arr = $menu[$setting_parenttabid];
$setting_menu_arr['visible'] = 0;
$setting_menu_arr['allow_sort']= 'no';//控制不允许排序
$setting_menu_arr['allow_delete'] = 'no';//控制不允许删除
unset($menu[$setting_parenttabid]);
$menu[$parenttabid] = $setting_menu_arr;

$smarty->assign('MENU',$menu);
$smarty->assign('THEME',$theme);
$smarty->assign('APP',$app_strings);
$smarty->assign('MOD',$mod_strings);
$smarty->assign('LANGUAGETYPE',$languageTypeNew);


$_REQUEST['diony']='yes';
$arr=array();
if($_REQUEST['ajax']=='true')
{
    $smarty->display('Menu/MenuList.tpl');
}
else if($_REQUEST['ajax']=='yes')
{
     $arr['content']=$smarty->fetch("Menu/MenuListContent.tpl");
}
else
{
    $arr['content']=$smarty->fetch("Menu/MenuList.tpl");
}
ConvertTojsonString(1,$arr,"success");
?>