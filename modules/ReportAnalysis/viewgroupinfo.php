<?php
global $adb;
//zxm SQL统计表 部门组件 。只显示当前登录用户有数据范围的人所在的部门。
if(!class_exists("Group"))
{
    require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
}
$group_focus = new Group();
$view = isset($_REQUEST['popup_scopetype'])?$_REQUEST['popup_scopetype']:'';
$selecttype = isset($_REQUEST['popup_selecttype'])?$_REQUEST['popup_selecttype']:'group';
$view = 'private';
$fld_module = isset($_REQUEST['popup_module'])?$_REQUEST['popup_module']:'';//模块
$filterown = '';//是否过滤自己
$isbox = isset($_REQUEST['popup_inputtype'])?$_REQUEST['popup_inputtype']:1;//1 多选  2 单选
$ishighseaallocate='no';
$groupuser = $group_focus->getGroupListUser($fld_module,$view,$filterown,$selecttype,$ishighseaallocate,'','');

$group_focus->showallgroupstructure = 'no';
//选部门  需要根据数据范围成员所属部门的ID来控制显示
if($selecttype=='group') {
    $filterid = $_REQUEST['filterid'];

    crm_load_class_file('cls_SqlTableDetailView', 'modules/CustomTables/');
    $SqlTableDetailObj = new cls_SqlTableDetailView($_REQUEST);
    $sqlFilter_sql = "select * from ld_customtablesql_filter where id=? ";
    $sqlFilter_res = $adb->pquery($sqlFilter_sql, array($filterid));
    $sqlFilter_nums = $adb->num_rows($sqlFilter_res);
    $groupid_arr = [];
    if ($sqlFilter_nums > 0) {
        $filterline = $adb->query_result_rowdata($sqlFilter_res, 0, 0);
        $groupid_arr = $SqlTableDetailObj->getGroupIds($filterline);
    }
    $groupid_str = isset($groupid_arr['groupid_str'])?explode(',', $groupid_arr['groupid_str']):'';


    $group_focus->setshowgroupid_arr($groupid_str);
}

$groupuserarray = $group_focus->setOneParent($groupuser);
$groups = $group_focus->getGrouplist();
//多维数组组装成ul->li格式
if(isset($groups)){
    $array[$group_focus->group_parent_key] = $groupuserarray[$group_focus->group_parent_key];

    $treehtml = $group_focus->setTreeList($array,$isbox,'','parentgroup');
    $arr = [];
    $arr['content'] = $treehtml;
    $arr['groupuser'] = $groupuser;
    $arr['popup_inputtype'] = $isbox == 1 || $isbox == 'checkbox' ? 'checkbox':'radio';
    $arr['listdata'] = [array('label'=>getFixedLabel('DEPARTMENT'),'value'=>'group','list'=>$groupuserarray[$group_focus->group_parent_key],'group_parent_key'=>$group_focus->group_parent_key)];
    ConvertTojsonString(1,$arr,"success");
}else{
    echo getFixedLabel('LBL_NOTGROUPINFO');die;
}
?>