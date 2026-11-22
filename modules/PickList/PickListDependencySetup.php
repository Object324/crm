<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/

require_once 'modules/PickList/PickListUtils.php';
require_once 'modules/PickList/DependentPickListUtils.php';
 global $current_user;
$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='listroles';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='PickList';

global $app_list_strings, $currentModule, $theme, $current_user;

if($current_user->getHaveSetProfile("Settings")!="yes"){
	echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
	echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>
			<table border='0' cellpadding='5' cellspacing='0' width='98%'>
				<tr>
					<td rowspan='2' width='11%'><img src='". lingdang_imageurl('denied.gif', $theme) . "' ></td>
					<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span class='genHeaderSmall'>".getFixedLabel('NOPERMITTEDEXECUTE')."</span></td>
				</tr>
				<tr>
					<td class='small' align='right' nowrap='nowrap'>
						<a href='javascript:window.history.back();'>".getFixedLabel('RETURN')."</a><br>
					</td>
				</tr>
			</table>
		</div>";
	echo "</td></tr></table>";
	die;
}

$modules = lingdang_DependencyPicklist::getDependentPickListModules();

if(!empty($_REQUEST['moduleName'])) {
	$fld_module = vtlib_purify($_REQUEST['moduleName']);
}

$smarty = new lingdangCRM_Smarty;

$smarty->assign("MODULE_LISTS",$modules);

$smarty->assign("MODULE",$fld_module);
$smarty->assign("PICKLIST_MODULE",'PickList');
$smarty->assign("THEME",$theme);

$smarty->assign("SUBMODE",vtlib_purify($_REQUEST['submode']));

$smarty->assign('LANGUAGETYPE',$languageType);
// require_once('modules/Settings/SetmenuControl.php');
$_REQUEST['diony']='yes';
$profile = new Profile();
$tabid = getTabid($fld_module);
$cachekey = 'getPicklistValesForNORole'.$tabid;
unsetCache($cachekey);
if($_REQUEST['directmode'] == 'ajax') {
	$subMode = vtlib_purify($_REQUEST['submode']);

	if($subMode == 'getpicklistvalues') {
		$fieldName = vtlib_purify($_REQUEST['fieldname']);
		$fieldValues = getAllPickListValues($fieldName);
		$picklistValues = array();
		for($i=0;$i<count($fieldValues);++$i) {
			$picklistValues[$fieldValues[$i]] = $fld_module;
		}
		$json = new Zend_Json();
		echo $json->encode($picklistValues);

	} elseif($subMode == 'editdependency') {
		$sourceField = vtlib_purify($_REQUEST['sourcefield']);
		$targetField = vtlib_purify($_REQUEST['targetfield']);

		//$cyclicDependencyExists = lingdang_DependencyPicklist::checkCyclicDependency($fld_module, $sourceField, $targetField);

    	$picklistmode = '';
	//	if($cyclicDependencyExists) {
		  //	echo "PickListDependencyCyclicError##&".$fld_module;
		  //	die;
           // ConvertTojsonString("-1",array(),getFixedLabel('DEPENCYCYCLE'));
        
			//$smarty->assign('RETURN_URL', 'index.php?module=PickList&action=PickListDependencySetup&parenttab=Settings&moduleName='.$fld_module);
			//$smarty->display("modules/PickList/PickListDependencyCyclicError.tpl");

		//} else {
	
			$available_module_picklist = lingdang_DependencyPicklist::getAvailablePicklists($fld_module);
            
            $_REQUEST['diony']='yes';
			$smarty->assign("ALL_LISTS",$available_module_picklist);
			$dependencyMap = array();
			if(!empty($sourceField) && !empty($targetField)) {

				$sourceFieldValues = array();
				$targetFieldValues = getAllPickListValues($targetField);    //二级字段
           
				$sourceFieldarray = getAllPickListValues($sourceField);     //一级字段
				foreach ($sourceFieldarray as $key => $value) {
					if(empty($displayvalue)) $displayvalue = $value;
					$sourceFieldValues[htmlentities($value,ENT_QUOTES,'UTF-8')] = $value;
				}
				$displayvalue = '';
				if(isset($_REQUEST['displayvalue']) && !empty($_REQUEST['displayvalue']))
					$displayvalue = $_REQUEST['displayvalue'];
				else
					$displayvalue = current($sourceFieldValues);
				$smarty->assign("SOURCE_VALUES", $sourceFieldValues);
				$smarty->assign("TARGET_VALUES", $targetFieldValues);
              
				$smarty->assign("SOURCEFIELD", $sourceField);
				$smarty->assign("TARGETFIELD", $targetField);
				$smarty->assign('DISPLAYVALUE',$displayvalue);

				//$dependentPicklists = lingdang_DependencyPicklist::getDependentPicklistFields($fld_module);
				//$smarty->assign("DEPENDENT_PICKLISTS",$dependentPicklists);
				$dependencyMap = getPickListDependency($fld_module, $sourceField, $targetField,$displayvalue);
               
				$picklistmode = 'edit';
		    }
			$smarty->assign('PICKLISTMODE',$picklistmode);
			$roleDetails = $profile->getProfileArray();
			$smarty->assign("DEPENDENCY_MAP", $dependencyMap);
              
            $content=$smarty->fetch("modules/PickList/PickListDependencyContents.tpl");
            $arr['content']=$content;
            $arr['title']=getFixedLabel("LBL_PICKLIST_DEPENDENCY_SETUP");
            $arr['oktext']=getFixedLabel("NEXT");
            $arr['canceltext']=getFixedLabel("CANCEL");
            ConvertTojsonString(1,$arr,'success');
            
            
	//	}

	} else {
		/**
		 * 重写保存关联方法，增加添加上下级下拉框值功能
		 * @project PROT78 级联字段设置改进
		 * @author Tujt 2014-08-19
		 */
		if($subMode == 'savedependency') {
			//$dependencyMapping = vtlib_purify($_REQUEST['dependencymapping']);
			//$json = new Zend_Json();
			//$dependencyMappingData = $json->decode($dependencyMapping);
			//lingdang_DependencyPicklist::savePickListDependencies($fld_module, $dependencyMappingData);

			$sourceField = vtlib_purify($_REQUEST['sourcefield']);
			$targetField = vtlib_purify($_REQUEST['targetfield']);
			$dispvalue = vtlib_purify($_REQUEST['displayvalue']);
			$mapping = vtlib_purify($_REQUEST['dependencyMapping']);
			savePickListDependencies($fld_module,$sourceField,$targetField,$dispvalue,$mapping);
			echo 'SUCCESS';die;
		}else if($subMode == 'addfldopts'){
			//Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/15 0015 上午 10:52
			crm_load_class_file("cls_PickList_ServeicePer", 'modules/PickList');
			$objpinklist = new cls_PickList_ServeicePer();
            $objpinklist->addPickValue($_REQUEST['picklistfld'],$_REQUEST['picklistval']);
            echo 'SUCCESS';die;
         

		}elseif($subMode == 'deletedependency') {
			$sourceField = vtlib_purify($_REQUEST['sourcefield']);
			$targetField = vtlib_purify($_REQUEST['targetfield']);
			lingdang_DependencyPicklist::deletePickListDependencies($fld_module, $sourceField, $targetField);
             @unlink(globalStatic::$root_directory.'dataCache/picklist/datacache_'.$fld_module.'_pickdepencylist.php');
            $fld_module = $_REQUEST['pickmodule'];
		}
		$dependentPicklists = lingdang_DependencyPicklist::getDependentPicklistFields($fld_module);
		$smarty->assign("DEPENDENT_PICKLISTS",$dependentPicklists);
		$smarty->display("modules/PickList/PickListDependencyList.tpl");
	}
}
else {
   
	$dependentPicklists = lingdang_DependencyPicklist::getDependentPicklistFields($fld_module);
	$smarty->assign("DEPENDENT_PICKLISTS",$dependentPicklists);
	$arr['content']= $smarty->fetch('modules/PickList/PickListDependencySetup.tpl');
 	ConvertTojsonString(1,$arr,"success");
}

/**
 * 重写getPickListDependency方法
 * @project PROT78 级联字段设置改进
 * @author Tujt 2014-08-19
 */
function getPickListDependency($module, $sourceField, $targetField,$displayvalue) {
	global $adb;
	$tabid = getTabid($module);
	$result = $adb->pquery('SELECT sourcevalue,targetvalues FROM ld_picklist_dependency 
						WHERE tabid=? AND sourcefield=? AND targetfield=? and sourcevalue = ? ',
							array($tabid,$sourceField,$targetField,$displayvalue));
	$rows = $adb->num_rows($result);
	$valueMapping = array();
	for($i=0; $i<$rows; ++$i) {
		$sourceValue = $adb->query_result($result, $i, 'sourcevalue');
		$targetValues = $adb->query_result($result, $i, 'targetvalues');
		$unserializedTargetValues = Zend_Json::decode(html_entity_decode($targetValues));
		if(!is_array($unserializedTargetValues)){
			$unserializedTargetValues = explode(',',$unserializedTargetValues);
		}
		$valueMapping[$sourceValue] = $unserializedTargetValues ;
	}
	return $valueMapping;
}
/**
 * 重写savePickListDependencies方法
 * @project PROT78 级联字段设置改进
 * @author Tujt 2014-08-19
 */
function savePickListDependencies($module,$sourceField,$targetField,$sourceValue,$mapping) {
	global $adb;
	$tabid = getTabid($module);
	$mapping = trim($mapping,',');
	$mapping = explode(',',$mapping);
	$mapping = ldcrm_json_encode($mapping);
	$query = 'SELECT id FROM ld_picklist_dependency WHERE tabid=? 
				AND sourcefield=? AND targetfield=? AND sourcevalue=?;';
	$result = $adb->pquery($query,array($tabid,$sourceField,$targetField,$sourceValue));
	$rows = $adb->num_rows($result);
	if($rows > 0){//编辑
		$id = $adb->query_result($result,0, 'id');
		$adb->pquery("UPDATE ld_picklist_dependency SET targetvalues=? WHERE id=?",
						array($mapping, $id));
	}else{//新增
		$adb->pquery("INSERT INTO ld_picklist_dependency(id, tabid, sourcefield, targetfield, sourcevalue, targetvalues, criteria)
								VALUES (?,?,?,?,?,?,?)",
						array($adb->getUniqueID('ld_picklist_dependency'), $tabid, $sourceField, $targetField, $sourceValue,
						$mapping,''));
	}
    
    @unlink(globalStatic::$root_directory.'dataCache/picklist/datacache_'.$module.'_pickdepencylist.php');
    
}


/** Function to get tablename, columnname, fieldname, fieldlabel and uitypes of fields of merge criteria for a particular module*/
function getFieldValues($module)
{
	global $adb,$current_user;

    $languageType= getLanguageType($current_user);
	$fld_table_arr = Array();
	$special_fld_arr = Array();
	$tabid = getTabid($module);

	$fieldname_query="select fieldname,ld_tranlabel.fieldlabel,uitype,tablename,columnname from ld_field
                     inner join ld_tranlabel  on ld_tranlabel.relateid=ld_field.fieldid
                     where  languagetype=? and trantable=? and fieldid in
			(select fieldid from ld_user2mergefields WHERE tabid=? AND userid=? AND visible = ?) and ld_field.presence in (0,2)";
	$fieldname_result = $adb->pquery($fieldname_query, array($languageType,'ld_field',$tabid, $current_user->id, 1));

	$field_num_rows = $adb->num_rows($fieldname_result);

	$fld_arr = array();
	$col_arr = array();
	for($j=0;$j< $field_num_rows;$j ++)
	{
		$tablename = $adb->query_result($fieldname_result,$j,'tablename');
		$column_name = $adb->query_result($fieldname_result,$j,'columnname');
		$field_name = $adb->query_result($fieldname_result,$j,'fieldname');
		$field_lbl = $adb->query_result($fieldname_result,$j,'fieldlabel');
		$ui_type = $adb->query_result($fieldname_result,$j,'uitype');
		$table_col = $tablename.".".$column_name;
		if(getFieldVisibilityPermission($module,$current_user->id,$field_name) == 0)
		{
			$fld_name = ($special_fld_arr[$field_name] != '')?$special_fld_arr[$field_name]:$field_name;

			$fld_arr[] = $fld_name;
			$col_arr[] = $column_name;
			if($fld_table_arr[$table_col] != '')
				$table_col = $fld_table_arr[$table_col];

			$field_values_array['fieldnames_list'][] = $table_col . "." . $fld_name;
			$fld_labl_arr[]=$field_lbl;
			$uitype[$field_name]=$ui_type;
		}
	}
	$field_values_array['fieldnames_list']=implode(",",$field_values_array['fieldnames_list']);
	$field_values=implode(",",$fld_arr);
	$field_values_array['fieldnames']=$field_values;
	$field_values_array["fieldnames_array"]=$fld_arr;
	$field_values_array["columnnames_array"]=$col_arr;
	$field_values_array['fieldlabels_array']=$fld_labl_arr;
	$field_values_array['fieldname_uitype']=$uitype;

	return $field_values_array;
}
?>