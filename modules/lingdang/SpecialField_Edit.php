<?php

global $theme,$currentModule,$current_user,$default_charset;
$smarty = new lingdangCRM_Smarty;
$excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
$SearchScope=$_REQUEST['SearchScope'];
$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;
$data = $fieldobj->split_validationdataArray();
$focus->mode = '';
$mode = '';
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$disp_view = getView($focus->mode);
$idstring = vtlib_purify($_REQUEST['idstring']);

if($idstring=='all')
{
    $_REQUEST['mass_batch_num_all']=$btach_num;
    $smarty->assign('TOTALSELECTROWS',$_REQUEST['totalrows']);
}
$storearray = getSelectedRecords($_REQUEST, $currentModule, $_REQUEST['idstring'],$excludedRecords);
foreach($storearray as $key=>$value)//去除数组中的空值
{
    if($value == ""){unset($storearray[$key]);}
}
$arraycount = sizeof($storearray);
$smarty->assign("COUNT",$arraycount);
if($arraycount==1)//选中单据为一条时
{
    $focus->retrieve_entity_info($storearray[0],$currentModule);//读取当前选中单据的数据
}

$smarty->assign("SEARCHSCOPE",$SearchScope);
$smarty->assign('MODULE',$currentModule);
$smarty->assign('THEME', $theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
if(isset($_REQUEST['return_action']))
{
    $smarty->assign('RETURN_ACTION',$_REQUEST['return_action']);
}
if(isset($_REQUEST['return_module']))
{
    $smarty->assign('RETURN_MODULE',$_REQUEST['return_module']);
}
$idstringval=implode(',',$storearray);
global $global_pick_list_values;
$act_data = getBlocks($currentModule,$disp_view,$mode,$focus->column_fields);



$query = 'select columnname from ld_field_specialedit where module = ?';
$result = $adb->pquery($query,array($currentModule));
$num_rows = $adb->num_rows($result);
$speciale_field = [];
$speciale_field_fieldname = [];
if($num_rows>= 1){
	for($i = 0; $i < $num_rows; $i++){
		$columnname = $adb->query_result($result,$i,'columnname');
		$speciale_field[] = $columnname;
		$fieldname = $focus->fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'fieldname');
		$speciale_field_fieldname[] = $fieldname;

	}
}
$num = 0;
foreach($act_data as $block_label => $block_field){
	foreach($block_field as $fieldinfo){
		if((!empty($fieldinfo[0]) && in_array($fieldinfo[0][5],$speciale_field)) || (!empty($fieldinfo[1]) && in_array($fieldinfo[1][5],$speciale_field))){
			if(!empty($fieldinfo[0]) && in_array($fieldinfo[0][5],$speciale_field)){
				$fieldinfo[0][4] = 'O';
				if(!isset($new_act_data['form'][$num])){
					$k = 0;
				}else{
					$k = 1;
				}
				$new_act_data['form'][$num][$k] = $fieldinfo[0];
			}
			
			if(!empty($fieldinfo[1]) && in_array($fieldinfo[1][5],$speciale_field)){
				$fieldinfo[1][4] = 'O';
				if(!isset($new_act_data['form'][$num])){
					$k = 0;
				}else{
					$k = 1;
				}
				$new_act_data['form'][$num][$k] = $fieldinfo[1];
			}
			if(sizeOf($new_act_data['form'][$num]) == 2){
				$num++;
			}
		}
		
		
	}
}

$fields=$fieldobj->getFieldListArray();
$fields['module']=$currentModule;
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($currentModule);
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

$smarty->assign("QUICKCREATE", $new_act_data['form']);
$strcontent=$smarty->fetch('DetailView/PopupEditQuickCreate.tpl'); 
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('EDITAPPROVEORDER');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$strcontent;
$arr['speciale_field'] = implode(',',$speciale_field_fieldname);
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['idstring'] = $idstringval;
$arr['fieldlabel']=$data['fieldlabel'];
$arr["validatasave"]=getValidataSave($currentModule);
$arr['fields']=$fields['fields'];
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
ConvertTojsonString(1,$arr,"success");

?>