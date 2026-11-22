<?php
global $adb,$current_user;
$smarty = new lingdangCRM_Smarty();
require('user_privileges/user_privileges_'.$current_user->id.'.php');
$mapmodule_str=$_REQUEST['mapmodule']; // wym XUQIU20240204-09 销售线索可编辑追踪字段
$mapmodule_arr=explode(':',$mapmodule_str);
if(in_array('Accounts',$mapmodule_arr)){// wym 目前不支持多选映射模块 客户和商机是从客户关联创建商机
    $map_module='Accounts';
}else{
    $map_module=$mapmodule_arr[0];
}
if(!empty($_REQUEST['select_mapfields']) && $_REQUEST['select_mapfields'] == 'no'){
	$fieldobj=Field::getInstance('Leads',$adb);
	$modules = $fieldobj->getModuleFields();
	crm_load_class_file('cls_MappingFields','modules/Leads');
	$cls_MappingFields = new cls_MappingFields('Leads');
	$mappingfields = $cls_MappingFields->getMappingFields($map_module);
	$no_mappingfields = array('createdtime','modifiedtime','modifiedby','upgradeaccountid');
    $users_fileds['curuser'] = array('fieldlabel' =>getFixedLabel('CURUSER'));
	foreach($modules as $field){
		$columnname = $field->getColumnName();
		if(in_array($columnname,$no_mappingfields))continue;
		$fieldlabel = $field->getfieldLabel();
		$typeofdata = explode('~',$field->getTypeOfData());
        $bigtype = $field->getBigType();
        $uitype = $field->getUIType();
		$mapping_module = $mappingfields[$columnname]['mapping_module'];
		if(empty($mapping_module))$mapping_module = $map_module;  // wym XUQIU20240204-09 销售线索可编辑追踪字段
        $mapping_columnname = $mappingfields[$columnname]['mapping_columnname'];
        $is_disabled = $mappingfields[$columnname]['is_disabled'];
        //edit:duan date:2021-12-6 销售线索映射字段优化
        if($columnname == 'smcreatorid'||$columnname == 'smownerid'){
            $fieldsMap[$columnname] = array(
                'fieldlabel' => $fieldlabel,
    			'typeofdata' => $typeofdata[1],
    			'mapmodule' => $mapping_module,
    			'fieldmaping' => $mapping_columnname,
    			'is_disabled' => $is_disabled
    		);
            //负责人和创建人可另外设置映射前字段
            $mapped_columnname = $mappingfields[$columnname]['mapped_columnname'];
            if(!empty($mapped_columnname)){
                $fieldsMap[$columnname]['mapped_columnname'] = $mapped_columnname;
            }
        }
        else{
            $fieldsMap[$columnname] = array(
                'fieldlabel' => $fieldlabel,
    			'typeofdata' => $typeofdata[1],
    			'mapmodule' => $mapping_module,
    			'fieldmaping' => $mapping_columnname,
    			'is_disabled' => $is_disabled,
                'bigtype'=>$bigtype,
                'uitype'=>$uitype
    		);
        }
		//edit:duan date:2021-12-6 销售线索映射字段优化
        if($bigtype == 'users' || $bigtype == 'selectoneuser'){
            $users_fileds[$columnname] = array(
                'fieldlabel' => $fieldlabel
            );
        }
	}
    
	$fieldobj=Field::getInstance($map_module,$adb);
	$modules = $fieldobj->getModuleFields();
    $file_field = array();
	foreach($modules as $field){
		$bigtype = $field->getBigType();
        $uitype = $field->getUIType();
        if($bigtype == 'fileattachment'){
            $file_field[] = array(
    			'columnname' => $field->getColumnName(),
    			'tag' => $map_module,
    			'fieldlabel' => $field->getfieldLabel(),
                'bigtype' => $bigtype,
                'uitype'=>$uitype
    		);
        }else{
            $mapping_fields[] = array(
    			'columnname' => $field->getColumnName(),
    			'tag' => $map_module,
    			'fieldlabel' => $field->getfieldLabel()
    		);
        }
	}
    if($map_module=='Accounts'){//客户模块还有首要联系人
        $fieldobj=Field::getInstance('Contacts',$adb);
        $modules = $fieldobj->getModuleFields();
        foreach($modules as $field){
            $bigtype = $field->getBigType();
            if($bigtype != 'fileattachment'){
                $mapping_fields[] = array(
                    'columnname' => $field->getColumnName(),
                    'tag' => 'Contacts',
                    'fieldlabel' => $field->getfieldLabel()
                );
            }
        }
    }
    $smarty->assign('FILEFIELD',$file_field);
	$smarty->assign('MAPPINGFIELDS',$mapping_fields);
	$smarty->assign('FIELDSMAP',$fieldsMap);
    $smarty->assign('USERFIELDS',$users_fileds);
}
else if(!empty($_REQUEST['save']) && $_REQUEST['save'] == 'yes'){
	if(!empty($_REQUEST['record']) && !empty($_REQUEST['mappingfields_info'])){
		$focus= CRMEntity::getInstance($module);
		crm_load_class_file('cls_SaveMappingFields','modules/Leads');
		$cls_SaveMappingFields = new cls_SaveMappingFields('Leads',$_REQUEST['record']);
		$result = $cls_SaveMappingFields->saveMappingFields($_REQUEST['mappingfields_info'],$map_module);
           
		//映射结束后，删除当前单据
		if($result == 'success'){
			$tab_name_index = $focus->tab_name_index;
            
            //要有人人推广平台参数判断，目前还没有做，所以不做判断
            
           $accountstatus='account';
             $_REQUEST['crmid']=$_REQUEST['record'];
            include(globalStatic::$root_directory."crmmarket/updateaccountSaveStatus.php");
			foreach($focus->tab_name as $key=>$arr){
				//$sql='delete from '.$arr.' where '.$tab_name_index[$arr].' = '.$_REQUEST['record'];
				//$adb->query($sql);
			}
			$customView = CustomView::getInstance('Leads');
			$viewid = $customView->getViewId('Leads');
			if(isset($_SESSION['lvs']['Leads']['viewname'])){
				$start = $_SESSION['lvs']['Leads'][$viewid]['start'];
			}
			if(!$start) $start = 1;
			$entity['start']['value'] = $start;//当前页数
			$entity['result']['value'] = $result;
			$json = new Zend_Json();
			$jsonentity = $json->encode($entity);
		}
		echo $jsonentity;

	}
	exit();
}
else{
	$query = 'select `status`,failurereason from ld_leads where leadsid = ?';
	$result = $adb->pquery($query,array($_REQUEST['record']));
	$status = $adb->query_result($result,0,0);
	switch($status){
		case '失败关闭':
		   $status = 'Failedtoclose';
		   break;
		case '跟进中':
		case '新建':
		   $status = 'Following';
		   break;
		case '升级':
		   $status = 'Upgrade';
		   break;
	}
	$smarty->assign('STATUS',$status);
	$smarty->assign('FAILEUREREASON',$adb->query_result($result,0,1));
}
$smarty->assign('THEME', $theme);
$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign('LANGUAGETYPE',$languageType);
$smarty->assign('SELECTMAPPFIELDS',$_REQUEST['select_mapfields']);
$smarty->assign('RECORDID',$_REQUEST['record']);
$smarty->assign('MAPMODULE',$map_module);
$smarty->display("FieldsMapping.tpl");
exit();
?>