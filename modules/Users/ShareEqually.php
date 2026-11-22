<?php

global $adb;
$smarty=new lingdangCRM_Smarty;
$module = $_REQUEST['frommodule'];
$focus = CRMEntity::getInstance($module);
$fieldname = $_REQUEST['fieldname'];
$defaultmodule = '';
if(!empty($fieldname)){
	$field=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
	$query = 'select module,entitytype,`default`,presence from ld_shareequally where fieldname = ? order by sequence asc';
	$result = $adb->pquery($query,array($fieldname));
	$num_rows = $adb->num_rows($result);
	if($num_rows > 0){
		for($i = 0; $i < $num_rows; $i++){
			$module = $adb->query_result($result,$i,'module');
			$entitytype = $adb->query_result($result,$i,'entitytype');
			if(vtlib_isModuleActive($entitytype)){
				$default = $adb->query_result($result,$i,'default');
				$presence = $adb->query_result($result,$i,'presence');
				if($default == 1){
					$defaultmodule = $entitytype;
				}
				$sourcemodule[$entitytype] = array(
					'default' => $default,
					'label' => getTranstab($entitytype),
					'presence' => $presence,
				);
			}
		}
	}
}
$smarty->assign('SOURCEMODULEJSON',json_encode($sourcemodule));
$smarty->assign('SOURCEMODULE',$sourcemodule);
$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);
$smarty->assign('FIELDNAME',$_REQUEST['fieldname']);
if($_REQUEST['setSourceModule'] == 'yes'){
	$table = '';
	$rowid = 1;
	foreach($sourcemodule as $entitytype => $shareinfos){
		$table .= '<tr class="lvtColData" name="row_'.$rowid.'"">';
		$table .= '<td align="center">'.$rowid.'</td>';
		$table .= '<td align="left"><span>' . $shareinfos['label'] . '</span><input type="hidden" value="'.$entitytype.'" /></td>';
		if($shareinfos['presence'] == 1){
			$table .= '<td align="left"><input type="checkbox" name="share_presence" /></td>';
		}else{
			$table .= '<td align="left"><input type="checkbox" name="share_presence" checked /></td>';
		}
		if($shareinfos['default'] == 1){
			$table .= '<td align="left"><input type="radio" name="share_default" checked /></td>';
		}else{
			$table .= '<td align="left"><input type="radio" name="share_default" /></td>';
		}
		
		if($rowid == 1){
			$table .= '<td align="left"><a class="icon-category category-sdown marR8 datacategory_down" href="javascript:;" tag="'.$rowid.'" name="setsourcemodule" movetype="movedown" title="'.getFixedLabel('MOVEDOWN').'"></a></td>';
		}else if($rowid == sizeOf($sourcemodule) && sizeOf($sourcemodule) > 1){
			$table .= '<td align="left"><a class="icon-category category-sup marR8 datacategory_up" href="javascript:;" tag="'.$rowid.'" name="setsourcemodule" movetype="moveup" title="'.getFixedLabel('MOVEUP').'"></a></td>';
		}else{
			$table .= '<td align="left"><a class="icon-category category-sdown marR8 datacategory_down" href="javascript:;" tag="'.$rowid.'" name="setsourcemodule" movetype="movedown" title="'.getFixedLabel('MOVEDOWN').'"></a>';
			$table .= '<a class="icon-category category-sup marR8 datacategory_up" href="javascript:;" tag="'.$rowid.'" name="setsourcemodule" movetype="moveup" title="'.getFixedLabel('MOVEUP').'"></a></td>';
		}
		$table .= '</tr>';
		$rowid++;
	}
	$smarty->assign('TABLE',$table);
	$_REQUEST['diony']='diony';
	$arr['title']=getFixedLabel("SOURCETYPE") . getFixedLabel('SETTINGS');
	$arr['oktext']=getFixedLabel("SAVE");
	$arr['canceltext']=getFixedLabel("CANCEL");
	$str=$smarty->fetch("ShareSourceModule.tpl");
	$arr['content']=$str;
	ConvertTojsonString(1,$arr,"success");
	exit();
}else{
	//分摊方式  1:均摊  2：比例分摊
	$shareequally_type = 1;
	$shareequally_values[1] = array(
		'entitytype' => $defaultmodule,
		'entitytype_linkvalue' => '',
		'entitytypeid' => '',
		'percent' => '0',
	);
	if(!empty($_REQUEST['shareequally_type'])){
		$shareequally_type = $_REQUEST['shareequally_type'];
	}
	if(!empty($_REQUEST['shareequally_value'])){
		$shareequally_value = explode('|',$_REQUEST['shareequally_value']);
		foreach($shareequally_value as $key => $values){
			$val = explode(',',$values);
			if(!empty($val[0]) && !empty($val[1])){
				$focus = CRMEntity::getInstance($val[0]);
				$focus->retrieve_entity_info($val[1], $val[0]);
				$entityarray = getEntitynameInfo(getTabid($val[0]));
				if($val[0] == 'Users'){
					$link_label = $focus->column_fields['last_name'];
				}else{
					$link_label = $focus->column_fields[$entityarray['fieldname']];
				}
				$shareequally_values[$key+1] = array(
					'entitytype' => $val[0],
					'entitytype_linkvalue' => $link_label,
					'entitytypeid' => $val[1],
					'percent' => $val[2],
				);
			}
		}
	}
	$smarty->assign('SHAREEQUALLYVALUES',$shareequally_values);
	$smarty->assign('SHARESEQUALLYTYPE',$shareequally_type);
	$_REQUEST['diony']='diony';
	$arr['title']=$field->getFieldLabel();
	$arr['oktext']=getFixedLabel("SAVE");
	$arr['canceltext']=getFixedLabel("CANCEL");
	$str=$smarty->fetch("ShareEqually.tpl");
	$arr['content']=$str;
	ConvertTojsonString(1,$arr,"success");
	exit();
}
?>