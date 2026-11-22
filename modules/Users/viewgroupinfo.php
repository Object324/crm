<?php

if(!class_exists("Group"))
{
    require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
}
$group_focus = new Group();


$view = isset($_REQUEST['popup_scopetype'])?$_REQUEST['popup_scopetype']:'';
if($_REQUEST['popup_module'] == 'NOALLOCATEACCOUNTS'||$_REQUEST['popup_module'] == 'UnAssignedAccounts'){
	$_REQUEST['popup_module'] = 'Accounts';
}


$fld_module = isset($_REQUEST['popup_module'])?$_REQUEST['popup_module']:'';//模块
$filterown = isset($_REQUEST['filterown'])?$_REQUEST['filterown']:'';//是否过滤自己
$isbox = isset($_REQUEST['popup_inputtype'])?$_REQUEST['popup_inputtype']:1;//1 多选  2 单选
$ishighseaallocate=isset($_REQUEST['ishighseaallocate'])?$_REQUEST['ishighseaallocate']:'no';

//20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
if($fld_module == 'Users' && $_REQUEST['fieldname'] && $_REQUEST['fieldname']=='groupid' && $_REQUEST['user_type']){
    $group_focus->setgroup_type($_REQUEST['user_type']);
}

$groupuser = $group_focus->getGroupListUser($fld_module,$view,$filterown,$_REQUEST['popup_selecttype'],$ishighseaallocate,'',$_REQUEST['fieldname']);
//zkt 20231201 BUG0076130  	kfbcrm-服务合同-“多选用户”字段，没有勾选“展示全部组织架构信息”，设置可选择的成员范围为“按角色权限（财务主管）”，此权限下只有成员“邱小光14”，新建服务合同，该字段弹出层中应只显示成员“邱小光14”的部门
$fieldname = $_REQUEST['fieldname'];
if(!empty($fieldname)){
    $focus = CRMEntity::getInstance($fld_module);
    if(!empty($focus->fieldobj)){
        $fieldinfo= $focus->fieldobj->getFieldInfoobjBykey('columnname',$fieldname);
        //if(!empty($fieldinfo)&&$fieldinfo->getshowallgroupstructure() == 'yes'&&$focus->fieldobj->is_user_field($fieldinfo->getUIType())){
        if(!empty($fieldinfo)&&!$fieldinfo->isshowallgroupstructure()){
            $group_focus->showallgroupstructure = 'no';
        }
    }
}
$groupuserarray = $group_focus->setOneParent($groupuser);
$groups = $group_focus->getGrouplist();
//多维数组组装成ul->li格式
//isset($groupuserarray[$group_focus->group_parent_key]['children'])
if(isset($groups)){
	$array[$group_focus->group_parent_key] = $groupuserarray[$group_focus->group_parent_key];
	$treehtml = $group_focus->setTreeList($array,$isbox,'','parentgroup');

}else{
    $treehtml = getFixedLabel('LBL_NOTGROUPINFO');
}

$arr = [];
$arr['content'] = $treehtml;
$arr['groupuser'] = $groupuser;
$arr['popup_inputtype'] = $isbox == 1 || $isbox == 'checkbox' ? 'checkbox':'radio';
$arr['listdata'] = [array('label'=>getFixedLabel('DEPARTMENT'),'value'=>'group','list'=>$groupuserarray[$group_focus->group_parent_key],'group_parent_key'=>$group_focus->group_parent_key)];
ConvertTojsonString(1,$arr,"success");
?>