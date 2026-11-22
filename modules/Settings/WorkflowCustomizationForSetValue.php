<?php
$smarty=new lingdangCRM_Smarty;
global $adb,$theme,$mod_strings,$app_strings;
$tabid = $_REQUEST['tabid'];

$_REQUEST['diony']='yes';
if(empty($_REQUEST['select_mode'])){
	$_REQUEST['select_mode'] = 'Text';
}
$select_mode = $_REQUEST['select_mode'];
if(Field::user_fields($_REQUEST['field_uitype'])){
    $smarty->assign('is_user_one','yes');
    if($select_mode != 'Field') {
        $select_mode = 'User_one';
    }
}else{
    $smarty->assign('is_user_one','no');
}
if(Field::user_multi_fields($_REQUEST['field_uitype'])){
    $smarty->assign('is_user_more','yes');
    if($select_mode != 'Field') {
        $select_mode = 'User_more';
    }
}else{
    $smarty->assign('is_user_more','no');
}
$tmp_user_arr = getAllUsers();
$smarty->assign('USERS_ARR',$tmp_user_arr);
$new_user_arr = [];
foreach ($tmp_user_arr as $userid => $value){
    $new_user_arr[$value] = $userid;
}

$smarty->assign('SELECT_LABEL',$_REQUEST['select_label']);
$smarty->assign('SELECT_MODE',$select_mode);
$smarty->assign('SELECT_VALUE',$_REQUEST['select_value']);
$moduelfield = getModuleField($tabid,$_REQUEST['select_value'],$select_mode);
$smarty->assign('ROWID',$_REQUEST['rowid']);
$smarty->assign('moduelfield',$moduelfield);
$smarty->assign('WORDFLOW_ID',$_REQUEST['workflow_id']);
$arr['title'] = getFixedLabel('setvalue');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['USERS_ARR']=$new_user_arr;
$arr['content']= $smarty->fetch('WorkflowCustomization/WorkflowCustomizationForSetValue.tpl');
ConvertTojsonString(1,$arr,"success");

//获取模块字段
function getModuleField($tabid,$select_value,$select_mode){
	$tabname=getTabname($tabid);
	$blocks = getBlockLabels($tabid);
	$module_type = '';
	if(get_file_address($tabname,'ProductDetails')){
	   $module_type = 'moduel_productdetails';
	}
	if(get_file_address($tabname,$tabname.'DetailFieldsHtml')){
	   $module_type = 'moduel_tabdetails';
	}
	$focus = CRMEntity::getInstance($tabname);
	$modulefields = $focus->fieldobj->getModuleFields();
	if(!empty($modulefields)){
		foreach($modulefields as $fieldname => $field){
			$blockid = $field->getBlockId();
			$uitype = $field->getUIType();
			$savedatabase = $field->getSaveDataBase();
			$uitype = $field->getUIType();
			$tablename = $field->getTableName();
			$fieldlabel = $field->getFieldLabelKey();
			$columnname = $field->getColumnName();
			if($savedatabase == 'no'){
				continue;
			}
			if(in_array($uitype,array('1109','1108','28','69','301','306'))){
				continue;
			}
			if($module_type == 'moduel_productdetails' && in_array($fieldname,array('discount_percent','discount_amount','s_h_amount'))){
				continue;
			}
			if($select_mode == 'User_one' && !Field::user_fields($uitype)){
                continue;
            }
			if($select_mode == 'User_more' && (!Field::user_fields($uitype) && !Field::user_multi_fields($uitype))){
                continue;
            }
			$fields[$blockid][$columnname]=array("0"=>$tablename,"1"=>$fieldlabel,"2"=>$tabname,'3'=>$fieldname);
		}
	}
	$fieldsel = ' <option value="">'.getFixedLabel('PLEASESELECTFIELD').'</option>';
	if(!empty($fields)){
		foreach($fields as $blockid => $fieldinfo){
			$fieldsel .= '<optgroup class="select" style="border:none" label="'.$blocks[$blockid].'">';
			foreach($fieldinfo as $columnname => $arr){
				$selected = 'yes';
				if(!empty($select_value) && $select_value == $arr[3]){
					$selected = "selected";
				}
				$fieldsel .='<option value="'.$arr[3].'" tag="'.$arr[1].'" '.$selected.'>'.$arr[1].'</option>';
			}
			$fieldsel .= '</optgroup>';
			
		}
	}
	return $fieldsel;
}

function getBlockLabels($tabid){
	global $adb,$current_language,$current_user;
	$blocks = [];
	$languageType= getLanguageType($current_user);
	$query = "select ld_tranlabel.fieldlabel,ld_blocks.blockid from ld_blocks 
	LEFT JOIN ld_tranlabel on ld_tranlabel.tabid = ld_blocks.tabid and ld_tranlabel.Relateid = ld_blocks.blockid 
	where ld_blocks.tabid= ? and languagetype = ? and ld_tranlabel.trantable = 'ld_blocks'";
	$result = $adb->pquery($query,array($tabid,$languageType));
	for($i=0;$i<$adb->num_rows($result);$i++)
	{
		$blockid = $adb->query_result($result,$i,'blockid');
		$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
		$blocks[$blockid] = $fieldlabel;
	}
	return $blocks;
}

//获取所有成员
function getAllUsers(){
    $user_array = get_user_array();
    return $user_array;
}
?>