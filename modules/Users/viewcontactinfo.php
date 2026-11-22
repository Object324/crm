<?php
require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
global $adb;
if(!empty($_REQUEST['contactid'])){
	$group_focus = new Group();
	$contactid = $_REQUEST['contactid'];
	$focus = CRMEntity::getInstance('Contacts');
	$field_obj=Field::getInstance('Contacts',$adb);
	$moduleFields=$field_obj->getModuleFields();
	$contact_list = Array();
	$encountered_contact = array($contactid);
	$contact_list = $focus->__getParentContacts($contactid, $contact_list, $encountered_contact);
	$contact_list = $focus->__getChildContacts($contactid, $contact_list, $contact_list[$contactid]['depth']);
	foreach($contact_list as $contact_info){
		if($contact_info['contactid'] == $contactid){
			$cur_accountid = $contact_info['accountid'];
			break;
		}
	}
	foreach($contact_list as $con_id => $contact_info){
		$depth_arr[] = $contact_info['depth'];
		$depth_arr_length[$contact_info['depth']][] = '';
	}
	$pos = array_search(max($depth_arr),$depth_arr);
	if($pos > 0){
		$depth_max = $depth_arr[$pos];
	}
	for($depth = 0; $depth <= $depth_max; $depth++){
		foreach($contact_list as $con_id => $contact_info){
			if($contact_info['depth'] == $depth){
				$description = [];
				$lastname = $contact_info['lastname'];
				if($contact_info['department'] != '' && !empty($moduleFields['department'])){
					$description[] = $contact_info['department'];
				}
				if($contact_info['title'] != '' && !empty($moduleFields['title'])){
					$description[] = $contact_info['title'];
				}
				if($contactid != $con_id && $contact_info['accountid'] != $cur_accountid){
					$description[] = $contact_info['accountname'];
				}
				if(sizeOf($description) >= 1){
					$lastname = $lastname . '&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#6166D3;font-size:12px;">' . implode('-',$description) . '</span>';
				}
				$data[]  = array(
					'contactid' => 	$con_id,
					'type' => 'Contacts',
					'name' => $lastname,
					'depth' => $contact_info['depth'],
					'parentid' => $contact_info['parentid'],
				);
			}
		}
	}
	//$contact_list = $focus->getContctsHierarchy($con_id);

	$tree_data = getTree($data,0,$depth_max,$depth_arr_length);
	$treehtml .= $group_focus->setTreeList($tree_data,'','','selectaccount');	
	echo $treehtml;die;

}

function getTree($data,$i,$depth_max,$depth_arr_length){
	$tree = array();
	$k = 1;
	foreach($data as $info){
		if($info['depth'] == $i){
			if($k <= count($depth_arr_length[$i])){
				$children = [];//ls 2022-01-12 0049645: （https://81mis.com/kfbtest/index.php [^]）联系人》单据详情，点击查看上下级关系，只显示了一级显示，没有上下级联
				$tree_data = getTree($data,$i+1,$depth_max,$depth_arr_length);
				if(!empty($tree_data)){
					foreach($tree_data as $key => $infos){
						if($infos['parentid'] == $info['contactid']){
							$children[$key] = $infos;
						}
					}
					$info['children'] = $children;
				}
				if($info['children'] == null){  
					unset($info['children']);
				}
			}

			$tree['contacts_'.$info['contactid']] = $info;
			$k++;
		}
	}
	 return $tree; 
}
?>