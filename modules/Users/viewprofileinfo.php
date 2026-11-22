<?php
require_once globalStatic::$root_directory.'modules/Users/Group.class.php';

$group_focus = new Group();
$isbox = isset($_REQUEST['popup_inputtype'])?$_REQUEST['popup_inputtype']:'checkbox';
$profileArray = getAllProfile();
$treehtml .= $group_focus->setTreeList($profileArray,$isbox,'','selectprofileuser');

$list = $profileArray['profile'];
$list['type'] = 'profile';

$arr = [];
$arr['content'] = $treehtml;
$arr['groupuser'] = $profileArray['profile']['children'];
$arr['popup_inputtype'] = $isbox == 1 || $isbox == 'checkbox' ? 'checkbox':'radio';
$arr['listdata'] = [array('label'=>getFixedLabel('LBL_PROFILES'),'value'=>'group','list'=>$list,'group_parent_key'=>'profile')];
ConvertTojsonString(1,$arr,"success");
//获取所有的权限，并且按树形结构数组结构存储
function getAllProfile(){
	$profile_focus = new Profile();
	$allProfile = $profile_focus->getProfileArray();
	if(!empty($allProfile)){
		$profileArray['profile']['name'] = '所有角色';
		foreach($allProfile as $profileid => $profilename){
			$profileArray['profile']['children']['profile_'.$profileid]['name'] = $profilename;
		}
		return $profileArray;
	}
	return '';
}
?>