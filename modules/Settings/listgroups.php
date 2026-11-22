<?php

/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/


require_once('./modules/Users/Group.class.php');


global $app_list_strings;
$smarty = new lingdangCRM_Smarty;
$group_focus = new Group();
require_once('./include/Zend/Json.php');
$json = new Zend_Json();
if(isset($_REQUEST['method']) && !empty($_REQUEST['method'])){//Ajax执行方法
	$method = $_REQUEST['method'];

	$entity = $group_focus->$method($_REQUEST);
	if(!empty($entity)){
		$jsonentity = $json->encode($entity);
		echo $jsonentity;die;
	}
	die;
}

$groupInfo = $group_focus->getGrouplist();
$cnt = 1;$output = '';
if($languageType == 'zh'){
    $width='220';
}else{
    $width='315';
}
$user_focus = CRMEntity::getInstance('Users');
$authtype =  $user_focus->getAuthType();
$output = '<tr><th width="20">#</th>
                <th align="left" title="'.getFixedLabel('GROUPNAME').'">'.getFixedLabel('GROUPNAME').'</th>
                <th align="left" title="'.getFixedLabel('DESCRIPTION').'">'.getFixedLabel('DESCRIPTION').'</th>';
if($authtype == 'no')
	$output .='<th width="'.$width.'" align="center">'.getFixedLabel('OPERATING').'</th>';
$output .='</tr>';
$idx = 1;
foreach($groupInfo as $id=>$group){
	$cKey = 0;
	//$output .= '<tr bgcolor="white" depth="'.$group['depth'].'" idx="'.($idx++).'">';
    if($cnt%2 == 0){
        $output .= '<tr id="setting_'.$cnt.'" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')"  depth="'.$group['depth'].'" idx="'.($idx++).'">';
    }else{
        $output .= '<tr id="setting_'.$cnt.'" class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" depth="'.$group['depth'].'" idx="'.($idx++).'">';
    }
	$groupidx = (26 * $group['depth']) + 5;
	$output .= '<td>'.($cnt ++).'</td>';
	//$output .= '<td title="'.(!empty($group['description'])?$group['description']:$group['groupname']).'" style="padding-left:'.$groupidx.'px" groupname="'.$group['groupname'].'" parentid="'.$group['parentid'].'" parentname="'.$groupInfo[$group['parentid']]['groupname'].'" descri="'.$group['description'].'"><a href="javascript:;" class="list-group"><b>'.$group['groupname'].'</b></a></td>';
	$output .= '<td title="'.$group['groupname'].'" style="padding-left:'.$groupidx.'px" groupname="'.$group['groupname'].'" parentid="'.$group['parentid'].'" parentname="'.$groupInfo[$group['parentid']]['groupname'].'" descri="'.$group['description'].'"><a href="javascript:;" class="list-group" title="'.$group['groupname'].'">'.$group['groupname'].'</a></td>';
    $output .= '<td title="'.$group['description'].'" style="width:300px" descri="'.$group['description'].'" title="'.textlength_check($group['description']).'">'.textlength_check($group['description']).'</td>';
	if($authtype == 'no'){
		$output .= '<td align="left">';
		$output .= '<a class="Anu3_a" btn="addBtn" record="'.$id.'">'.getFixedLabel('NEWROLESUBORDINATE').'</a>';
		$output .= '<a class="Anu3_a" btn="editBtn" record="'.$id.'">'.getFixedLabel('EDIT').'</a>';
		//<a class="Anu3_a" btn="copyBtn" record="'.$id.'">'.getFixedLabel('COPY').'</a>
		if($group['depth'] > 0)//跟部门不允许删除
			$output .= '<a class="Anu3_a" btn="delBtn" record="'.$id.'">'.getFixedLabel('DELETE').'</a>';

		$output .= '<a class="Anu3_a" btn="viewBtn" record="'.$id.'">'.getFixedLabel('SETMEMBERS').'</a>';
		$output .= '</td>';
	}
	$output .= '</tr>';
}
//一维数组转换为多维数组
$parentarray = $group_focus->setOneParent($groupInfo);
//多维数组组装成ul->li格式
$treehtml = $group_focus->setTreeList($parentarray,0,'groupname','parentgroup');
$treehtml = sprintf($treehtml,'selectgroupList');//添加ID值
//获取当前所有部门用户
$userinfo = getCurSmOwnerSearchScope('');
//bug 0015315 部门设置：设置成员弹出层，“可用成员”和“选择的成员”中按照用户名字母排序
$useridarr = array_keys($userinfo['UserCombo']);
$userarr = array_values($userinfo['UserCombo']);
$userarray['record'] = $useridarr;
$userarray['user'] = $userarr;
$usercombo = $json->encode($userarray);
$smarty->assign('USERCOMBO',$usercombo);

$smarty->assign('LIST_HEADER',$list_header);
$smarty->assign('OUTPUT',$output);
$smarty->assign('TREEHTML',$treehtml);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH',$image_path);
$smarty->assign('GRPCNT',count($groupInfo));
$smarty->assign('AUTHTYPE',$authtype);

require_once('SetmenuControl.php');
$smarty->display('ListGroup.tpl');
?>