<?php
global $current_language, $theme;
$image_path = "themes/$theme/images/";

$req_module = vtlib_purify($_REQUEST['module']);
$focus = CRMEntity::getInstance($req_module);

$return_module = vtlib_purify($_REQUEST['module']);
$delete_idstring = vtlib_purify($_REQUEST['idlist']);
$smarty = new lingdangCRM_Smarty;
//判断用户是否具有合并权限
//editor:gyq 2018/8/8 18:07  0034796: （1.6登录）非管理员登录：设置成员没有“合并”权限时自动查重合并功能查找重复记录后，操作列没有显示“合并”按钮
//if (isPermitted($_REQUEST['module'], "Merge", "") == 'yes') {
$smarty->assign("MODULEMERGE", 'permitted');
//}
$ids_list = array();
$errormsg = '';
if (isset($_REQUEST['del_rec'])) {
    $delete_id_array = explode(",", $delete_idstring, -1);

    foreach ($delete_id_array as $id) {
        if (isPermitted($req_module, 'Delete', $id) == 'yes') {
            DeleteEntity($req_module, $return_module, $focus, $id, "");
        } else {
            $ids_list[] = $id;
        }
    }
    if (count($ids_list) > 0) {
        $ret = getEntityName($req_module, $ids_list);
        if (count($ret) > 0) {
            $errormsg = implode(',', $ret);
        }
        echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
        echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>

			<table border='0' cellpadding='5' cellspacing='0' width='98%'>
			<tbody><tr>
			<td rowspan='2' width='11%'><img src='themes/$theme/images/denied.gif' ></td>
			<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'>
				<span class='genHeaderSmall'>" . getFixedLabel('NOTPERMITTEDDELETE') . getTranstab($req_module) . ": $errormsg</span></td>
			</tr>
			<tr>
			<td class='small' align='right' nowrap='nowrap'>
			<a href='javascript:window.location.reload();'>" . getFixedLabel('RETURN') . "</a><br>
			</td>
			</tr>
			</tbody></table>
			</div>";
        echo "</td></tr></table>";
        exit;
    }
}
include(globalStatic::$root_directory . 'include/utils/duplicateFindRecords.php');
//数据表存储当前模块选择的查重字段
include(globalStatic::$root_directory . "include/saveMergeCriteria.php");
//获取重复记录的条目数
if (!empty($_REQUEST['get_rows']) && $_REQUEST['get_rows'] == 'yes') {
    $num_rows = duplicateFindRecords::getDuplicateRecordsArr($req_module, true);
    if (empty($num_rows)) {
       // echo 'no_rows';
//        exit();
        $_REQUEST['diony']='yes';
        ConvertTojsonString('-1',array(),getFixedLabel('NODUPRECORDS'));
        

    }
}
$ret_arr = duplicateFindRecords::getDuplicateRecordsArr($req_module);

//@edit:liushuai,2021-03-05,reason:【ID1001390】：客户、联系人、服务收费管理，自动查重合并，合并单据后，应该仍停留在自动查重合并界面（如果全部合并完应该被正确返回）
if (!is_array($ret_arr) && $ret_arr == 0) {
    $_REQUEST['diony']='yes';
    $arr['content'] = "<br><br><table align='center' class='big' width='95%'><tr><td align='center'>" . getFixedLabel('NODUPRECORDS') . "</td></tr></table><br><br>";
    ConvertTojsonString('-1',$arr,getFixedLabel('NODUPRECORDS'));
}


$fld_values = $ret_arr[0];
$total_num_group = count($fld_values);
$fld_name = $ret_arr[1];

//zkt 20220928 XUQIU1000659  自动查重合并，合并弹出层中显示列增加拖动功能（李发林）
$field_width= $ret_arr['listview_width'];
$customViewFieldsarr = $ret_arr['customViewFieldsarr'];
$smarty->assign("customViewFieldsarr",$customViewFieldsarr);
$smarty->assign('LISTHEADERWIDTH',$ret_arr['listview_width']);
$smarty->assign('LISTVIEWTOTALWIDTH',$ret_arr['listview_totalwidth']);
$smarty->assign("CHKBOXWIDTH",$ret_arr['listview_checkboxwidth']);
$smarty->assign("OPERATIONWIDTH",$ret_arr['listview_optionwidth']);
$smarty->assign("HEADERNAME",$ret_arr['listview_headername']);
$smarty->assign("LISTVIEWHEIGHT",$ret_arr['listview_height']);
$smarty->assign("POPUPTYPE",'mergduplicate');
$smarty->assign("DUPLICATE_VIEWID",$ret_arr['duplicate_viewid']);


$smarty->assign("NAVIGATION", $ret_arr["navigation"]);//Added for page navigation
$smarty->assign('recordListRange',$ret_arr["recordListRangeMsg"]);
$smarty->assign("MODULE", $req_module);
$smarty->assign("NUM_GROUP", $total_num_group);
$smarty->assign("FIELD_NAMES", $fld_name);
$smarty->assign("ALL_VALUES", $fld_values);
//editor:gyq_72 reason:查重合并样式修改 date:20180705
$smarty->assign("RECORDID_ARR", $ret_arr[3]);
if (isPermitted($req_module, 'Delete', '') == 'yes')
    $button_del = $app_strings['LBL_MASS_DELETE'];
$smarty->assign("DELETE", $button_del);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("MODE", 'view');
if (isset($_REQUEST['button_view'])) {
    $smarty->assign("VIEW", 'true');
}
$_REQUEST['diony']='yes';
$fields=$focus->fieldobj->getFieldListArray();
$arr['fields']=$fields['fields'];

if (isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
   $arr['content']= $smarty->fetch("FindDuplicateAjax.tpl");
else
    $arr['content']=$smarty->fetch('FindDuplicateDisplay.tpl');
//editor:gyq_170 reason:自动查重合并返回值修改  2020/3/9 15:46 
$arr['title']=getFixedLabel('CHECKMERGE').' '.getTranstab($req_module);
//$arr['oktext']="确定"
//$arr['canceltext']="取消";
ConvertTojsonString(1,$arr,'success');
?>