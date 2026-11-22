<?php
//editor:gyq_159 reason:系统设置增加移动端报表菜单定制  2019/11/6 16:33 ID1000638
global $adb, $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='listroles';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';

require_once globalStatic::$root_directory . 'user_privileges/user_language_' . $current_user->id . '.php';
$menu_user_type = empty($menu_user_type)?'crm':$menu_user_type;
$smarty = new lingdangCRM_Smarty;
//菜单设置分crm用户和prm用户 zxm 20240911  XUQIU20240826-02 经销商渠道定制--增加移动端相关菜单设置
$query = 'select * from ld_mobile_report_parent_tab WHERE presence in(0,1) and menu_user_type=? ORDER BY sequence ';
$result = $adb->pquery($query, array($menu_user_type));
$num_rows = $adb->num_rows($result);
$del_btn = 'no';
$profile = new Profile();
$reports = $profile->getMobileReportNames();
$mobile_report_list = array();
//列表分配
$type = $_REQUEST['type'];
if($type == 'allocate'){
	$query = "update ld_mobile_report_parent_tab set allocatetype = ?,allocateid = ? where block_id = ?";
	$adb->pquery($query,array($_REQUEST['radiotype'],$_REQUEST['selectallocateid'],$_REQUEST['record']));
	$_REQUEST['diony']='yes';
	ConvertTojsonString(1,array(),"success");
}
foreach ($reports as $key=>$value){
    $mobile_report_list[$value['id']] = $value;
}
if ($num_rows > 0) {
    $table = '';
    crm_load_class_file("cls_LinkModuleCustom", 'include/utils');

    for ($i = 0; $i < $num_rows; $i++) {
        $module_name = array();
        $blockid = $adb->query_result($result, $i, 'block_id');
        $blockname = $adb->query_result($result, $i, 'block_name');
        $enblockname = $adb->query_result($result, $i, 'enblock_name');
        $presence = $adb->query_result($result, $i, 'presence');
        $systemdefault = $adb->query_result($result, $i, 'systemdefault');
        $parenttab_label = $adb->query_result($result, $i, 'parenttab_label');
		$allocatetype=$adb->query_result($result,$i,'allocatetype');
		$allocateid=$adb->query_result($result,$i,'allocateid');
        $sql = 'select * from ld_mobile_report_tab_rel where block_id=? order by sequence asc ';
        $reportresult = $adb->pquery($sql, array($blockid));
        $reportrows = $adb->num_rows($reportresult);
        for ($k = 0; $k < $reportrows; $k++) {
            $tab_tablename = $adb->query_result($reportresult, $k, 'tab_tablename');
            $tabid = $adb->query_result($reportresult, $k, 'tabid');
            if ($tab_tablename == 'ld_tab') {
                if(isset($mobile_report_list[$tabid]))
                    $module_name[] = $mobile_report_list[$tabid]['fieldlabel'];
            } else {
                $linkinfo = cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
                //zxm 2021-1221 049340: （81mis.com/kfbcrm/index.php）系统设置》移动端报表菜单定制》设置菜单时，不应显示图表的链接模块，应只显示报表库的链接模块
                //if($linkinfo['linkmodule']!='CustomTables'&&$linkinfo['linkmodule']!='CustomEcharts'){
                    if ($languageType == 'zh')
                        $module_name[] = $linkinfo['zh_label'];
                    else if ($languageType == 'en')
                        $module_name[] = $linkinfo['en_label'];
                //}
            }
        }
        if (sizeOf($module_name) < 1) {
            $blockempty = 1;
        } else {
            $blockempty = 0;
        }
        if ($i % 2 == 0) {
            $table .= '<tr id="setting_' . $i . '" class="lvtColData ld-category-draggable"" tag="'.$blockid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" >';
        } else {
            $table .= '<tr id="setting_' . $i . '" class="lvtColDataBj ld-category-draggable"" tag="'.$blockid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" >';
        }
        $number = $i + 1;
        $table .= '<td align="left">' . $number . '</td>';
        $table .= '<td align="left">' . $blockname . '</td>';
        $table .= '<td align="left">' . $enblockname . '</td>';
        $table .= '<td align="left">' . implode('、', array_filter($module_name)) . '</td>';
        //duan 2022-2-16 关于是否启用按钮的显示优化
        $table .= '<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$blockid.',\'mobile_report_parent_tab\')" class="second_switch" ';
		if($presence == 1 || $blockempty==1){
            $table .= ' /></td>';
		}else{
			$table .= 'checked /></td>';
		}
        $button = '';
        $button .= '<a class="Anu3_a" btn="editBtn" record="' . $blockid . '" onclick="fun_mobile_list.getInstance(\'' . $blockid . '\').MobileReportBlockEdit()">' . getFixedLabel('EDIT') . '</a>'; 
		$button .= '<a class="Anu3_a" btn="editBtn" record="'.$blockid.'" onclick="ScopePopup_Details.getInstance().allocateTemplate(this,\'0\',\''.$blockid.'\',\''.$allocateid.'\',\''.$allocatetype.'\',\'reportMenuCustomization\');">'.getFixedLabel('ALLOCATE').'</a>';	//分配
        //系统预置字段不能编辑
        if($parenttab_label != 'sales')
            $button .= '<a class="Anu3_a redFont" btn="addBtn" record="' . $blockid . '" onclick="fun_mobile_list.getInstance(\'' . $blockid . '\').MobileBlock_delete(\'report\')">' . getFixedLabel('DELETE') . '</a>';
        $del_btn = 'yes';
        $button .='<a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="'.getFixedLabel('DRAGTOSORT').'"  data-direction="left" data-type="position" style="display:none;cursor:move;" ></a>';
        $table .= '<td align="left" width="170px">' . $button . '</td>';
        $table .= '</tr>';
    }
}
$smarty->assign('DELBTN', $del_btn);
$smarty->assign('MOBILEMODULEHTML', $table);
$smarty->assign('LANGUAGETYPE', $languageType);
$_REQUEST['diony']='yes';
// require_once('SetmenuControl.php');
if($menu_user_type=='prm'){
    echo implode('、',$module_name);exit();
}
else
if ($_REQUEST['ajax'] && $_REQUEST['ajax'] == true) {
    $smarty->display('MobileListEntries.tpl');
    exit();
} else {
    $arr['content']= $smarty->fetch('reportMenuCustomization.tpl');
    ConvertTojsonString(1,$arr,"success");
}
?>