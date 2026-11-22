<?php
require_once('./modules/Users/Group.class.php');
$group_focus=new Group();
$groupInfo = $group_focus->getGrouplist();
//date:2021-9-6 edit:duan reason:0047840,删除某部门时，转移成员和下级部门时 ，没有排除当前删除的部门
if(isset($_REQUEST['delgroupid'])&&$_REQUEST['delgroupid']!=""){
    $delgroupid = $_REQUEST['delgroupid'];
    unset($groupInfo[$delgroupid]);
}
//一维数组转换为多维数组
$parentarray = $group_focus->setOneParent($groupInfo);
//多维数组组装成ul->li格式
$treehtml = $group_focus->setTreeList($parentarray,0,'groupname','parentgroup');
$treehtml = sprintf($treehtml,'selectgroupList');//添加ID值
$_REQUEST['diony']='diony';
$arr['content']=$treehtml;
$arr['title']=getFixedLabel('SELECT').getFixedLabel('Sector');
ConvertTojsonString(1,$arr,"");
?>