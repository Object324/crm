<?php
$smarty=new lingdangCRM_Smarty;
global $adb,$theme,$mod_strings,$app_strings,$current_user;
crm_load_class_file("cls_PickList", 'modules/PickList');
$objpinklist = new cls_PickList();
//选择模块， 获取模块下的全部字段
if(!empty($_REQUEST['getModuleField']) && $_REQUEST['getModuleField'] == 'yes' && !empty($_REQUEST['sel_module'])){
	$sel_tabid = getTabid($_REQUEST['sel_module']);
	$moduelfield = getModuleField($sel_tabid,'');
	ConvertTojsonString(1,$moduelfield,"success");
}
//选择字段
if(!empty($_REQUEST['selectfield']) && $_REQUEST['selectfield'] == 'yes' && !empty($_REQUEST['fieldname']) && !empty($_REQUEST['sel_module'])){
    $module = $_REQUEST['sel_module'];
    $focus = CRMEntity::getInstance($module);
	$modulefields = $focus->fieldobj->getModuleFields();
	$fieldname = $_REQUEST['fieldname'];
	$field = $modulefields[$fieldname];
	if(!empty($field)){
		$uitype = $field->getUIType();
		$columnname = $field->getColumnName();
		$data['type'] = 'other';	//除了下拉框和多选框以外的其他类型
		if($uitype == 15 || $uitype == 33){
			$data['type'] = 'select';
            //zxm 20221226 BUG0060173 客户服务单里面的处理状态字段下拉框，在工作流程里面设定取值的时候，下拉框的值不—样!!
			$picklist = $objpinklist->getPickListValues($fieldname,"",array(),"");
			$data['select_html'] = setSelectHtml($picklist,$_REQUEST['rowid'],'',$uitype);
			$temp_picklist = array_values($picklist);
			$data['select_value'] = $temp_picklist[0];
		}
		if($uitype == 56){
			$data['type'] = 'boolean';
			$data['select_html'] = setCheckboxHtml($_REQUEST['rowid'],'',$uitype);
		}
		if($columnname == 'pool_id' || $columnname == 'publicaccount'){
            $picklist = getEnuPicklist($module,$columnname);
            $data['type'] = 'select';
            $data['select_html'] = setEnuSelectHtml($picklist,$_REQUEST['rowid'],'',$uitype);
            $data['select_value'] = $picklist[0];
        }
		if($focus->fieldobj->is_user_field($uitype)){
            $data['type'] = 'user';
        }
		$data['uitype'] = $uitype;
	}
	ConvertTojsonString(1,$data,"success");
}
$tabid = $_REQUEST['tabid'];
$module = getTabname($tabid);
$focus = CRMEntity::getInstance($module);
$cur_modulefields = $focus->fieldobj->getModuleFields();
$action_data = [];
if(!empty($_REQUEST['workflow_actionid'])){
	$query = "select action_title,module,tabid,fieldname,setmode,setvalue from ld_workflow_actions 
	LEFT JOIN ld_workflow_updatefields on ld_workflow_updatefields.workflow_action_id = ld_workflow_actions.id 
	where ld_workflow_actions.id = ?";
	$result = $adb->pquery($query,array($_REQUEST['workflow_actionid']));
	if($adb->num_rows($result) >= 1){
		$action_title = $adb->query_result($result,0,'action_title');
		$smarty->assign('ACTION_TITLE',$action_title);
		for($i = 0; $i < $adb->num_rows($result); $i++){
			$fieldname = $adb->query_result($result,$i,'fieldname');
			$workflow_module = $adb->query_result($result,$i,'module');
			$workflow_tabid = $adb->query_result($result,$i,'tabid');
			$setvalue = $adb->query_result($result,$i,'setvalue');
			$moduelfield = getModuleField($workflow_tabid,$fieldname);
			$setmode = $adb->query_result($result,$i,'setmode');
			$focus = CRMEntity::getInstance($workflow_module);
			$modulefields = $focus->fieldobj->getModuleFields();
			$field = $modulefields[$fieldname];
			$select_html = '';
            $setvalue_label = '';
			if(!empty($field)){
				$uitype = $field->getUIType();
				$columnname = $field->getColumnName();
				if($uitype == 15 || $uitype == 33){
                    //zxm 20221226 BUG0060173 客户服务单里面的处理状态字段下拉框，在工作流程里面设定取值的时候，下拉框的值不—样!!
					$picklist = $objpinklist->getPickListValues($fieldname,"",array(),"");
					$select_html = setSelectHtml($picklist,$i+1,$setvalue,$uitype);	//获取下拉值
				}
				if($uitype == 56){
					$select_html = setCheckboxHtml($i+1,$setvalue,$uitype);
				}
                if($columnname == 'pool_id' || $columnname == 'publicaccount'){
                    $picklist = getEnuPicklist($workflow_module,$columnname);
                    $uitype = 15;
                    $select_html = setEnuSelectHtml($picklist,$i+1,$setvalue,$uitype);
                    $setvalue_label = $picklist[$setvalue];
                }
			}
			if($setmode == 'Field'){
				$field = $cur_modulefields[$setvalue];
				if(!empty($field)){
					$fieldlabel = $field->getFieldLabelKey();
				}
			}
            if($setmode == 'User_one'){//单选用户
                $setvalue_label = getUserFullName($setvalue);
            }
            if($setmode == 'User_more'){//多选用户
                $tmp_userid_arr = explode(',',$setvalue);
                $tmp_username_arr = [];
                if(count($tmp_userid_arr) > 0){
                    for($i = 0;$i < count($tmp_userid_arr); $i++){
                        $tmp_username_arr[] = getUserFullName($tmp_userid_arr[$i]);
                    }
                }
                $setvalue_label = implode(',',$tmp_username_arr);
            }
			$action_data[] = array(
				'rowid' => $i+1,
				'module' => $workflow_module,
				'tabid' => $workflow_tabid,
				'fieldname' => $fieldname,
				'setmode' => $setmode,
				'fieldlabel' => $fieldlabel,
				'setvalue' => $setvalue,
                'setvalue_label' => $setvalue_label,
				'select_html' => $select_html,
				'moduelfield' => $moduelfield,
                'field_uitype' => $uitype
			);
		}
	}
	$smarty->assign('workflow_actionid',$_REQUEST['workflow_actionid']);
	$smarty->assign('ACITON_DATA',$action_data);
}
$smarty->assign('ACITON_DATA_CNT',sizeOf($action_data));
//获取关联当前工作流模块的所有系统模块
$referencemodules = getReferenceForModule($tabid,$module);
// 拜访签到还需获取有签到字段的模块
if($module == 'Singin'){
	$select_sql = "SELECT tabid FROM ld_field WHERE bigtype = 'signin' AND presence IN (0,2) AND columnname != 'signout'";
	$select_result = $adb->query($select_sql);
	$num_rows = $adb->num_rows($select_result);
	$modules_signin = [];
	if($num_rows > 0) {
		for($i = 0; $i<$num_rows; $i++){
			$tabid_signin = $adb->query_result($select_result,$i,'tabid');
			$module_signin = getTabModuleName($tabid_signin);
			if(vtlib_isModuleActive($module_signin))
				$modules_signin[$module_signin] = getTranstab($module_signin);
		}
	}
	$referencemodules = $referencemodules + $modules_signin;
}

$smarty->assign('referencemodule_json',json_encode($referencemodules));
$smarty->assign('referencemodules',$referencemodules);
$_REQUEST['diony']='yes';
$smarty->assign('TABID',$tabid);
$smarty->assign('WORDFLOW_ID',$_REQUEST['workflow_id']);
$arr['title'] = getFixedLabel('ADDITION').getFixedLabel('WorkflowActions').'  ->  '.getFixedLabel('updatefields');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('WorkflowCustomization/WorkflowCustomizationForUpdateFields.tpl');
ConvertTojsonString(1,$arr,"success");

function getReferenceForModule($tabid,$module){
	global $adb;
    
   crm_load_class_file('cls_OptionModule','include/OptionModule');
  $sourcemodules= cls_OptionModule::getInstance($module)->getSourceModule($module);
  $data=[];
  $data[$module]=getTranstab($module);
  foreach($sourcemodules  as $info)
  {
    $data[$info['entitytype']]=getTranstab($info['entitytype']);
  }
  $sql="select ld_tab.`name` from ld_field 
    inner join ld_ws_fieldtype 
    on ld_field.uitype=ld_ws_fieldtype.uitype
    inner join ld_ws_referencetype
    on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
    inner join ld_tab on ld_tab.name=ld_ws_referencetype.type
    where ld_field.tabid=? and ld_field.presence in(0,2) and savedatabase='yes' 
    and ld_tab.presence in(0,2) ";
    $result=$adb->pquery($sql,array($tabid));
    $rows=$adb->num_rows($result);
    for($i=0;$i<$rows;$i++)
    {
            $name=$adb->query_result($result,$i,'name');
        	$data[$name] = getTranstab($name);
    }
    return $data;
        
/*	crm_load_class_file('cls_module_uitype','include/fields');
	$uitypes=cls_module_uitype::getAllUitypes();
	$query = "select tabid from ld_option_module where option_tabid = ? and presence <> 1";
	$result = $adb->pquery($query,array($tabid));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$tabid = $adb->query_result($result,$i,'tabid');
			$referencemodule = getTabname($tabid);
			if($module != $referencemodule && vtlib_isModuleActive($referencemodule))
				$data[$referencemodule] = getTranstab($referencemodule);
		}
	}
	$query = "select ld_field.tabid from ld_field where  tabid=? and  uitype in (".implode(',',$uitypes).")
    and savedatabase='yes' GROUP BY ld_field.tabid";
	$result = $adb->pquery($query,array($tabid));
   
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$tabid = $adb->query_result($result,$i,'tabid');
			$referencemodule = getTabname($tabid);
			if($module != $referencemodule && vtlib_isModuleActive($referencemodule))
				$data[$referencemodule] = getTranstab($referencemodule);
		}
	}
	foreach($data as $referencemodule => $modulelabel){
		if(in_array($referencemodule,array('Singin','Emails'))){
			unset($data[$referencemodule]);
		}
	}*/
	return $data;
}

//获取模块字段
function getModuleField($tabid,$select_fieldname = ''){
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
			if(in_array($uitype,array('1109','1108','28','69','301','306'))){//301：标签；
				continue;
			}
			if($module_type == 'moduel_productdetails' && in_array($fieldname,array('discount_percent','discount_amount','s_h_amount'))){
				continue;
			}
            if ($tabname == 'Accounts' && !in_array($tablename,$focus->tab_name)) {//目前无法更新首要联系人
                continue;
            }
			$fields[$blockid][$columnname]=array("0"=>$tablename,"1"=>$fieldlabel,"2"=>$tabname,'3'=>$fieldname,'4'=>$uitype);
		}
	}
	$fieldsel = ' <option value="">'.getFixedLabel('PLEASESELECTFIELD').'</option>';
	if(!empty($fields)){
		foreach($fields as $blockid => $fieldinfo){
			$fieldsel .= '<optgroup class="select" style="border:none" label="'.$blocks[$blockid].'">';
			foreach($fieldinfo as $columnname => $arr){
				$selected = '';
				if(!empty($select_fieldname) && $select_fieldname == $arr[3]){
					$selected = 'selected';
				}
				$fieldsel .='<option value="'.$arr[3].'" tag="'.$arr[3].'"  uitype="'.$arr[4].'" '.$selected.' >'.$arr[1].'</option>';
			}
			$fieldsel .= '</optgroup>';
			
		}
	}
	$detail_fields = [];
	/*if($module_type == 'moduel_productdetails'){
		crm_load_class_file("ProductDetails",'include/ProductDetails');
    	$productDetails=ProductDetails::getInstance($tabname);
    	$productmoduleFields=$productDetails->getModuleFields();
		if(!empty($productmoduleFields)){
			$fieldsel .= '<optgroup class="select" style="border:none" label="'.getTranstab('Products').'">';
			foreach($productmoduleFields as $colname => $field){
				$fieldlabel = $field->getFieldLabelKey();
				$fieldsel .='<option value="[var.productdetails_'.$colname.'_products]">'.$fieldlabel.'</option>';
			}
			$fieldsel .= '</optgroup>';
		}
	}
	if($module_type == 'moduel_tabdetails'){
		crm_load_class_file("TabDetailFields",'include/TabDetailFields');
    	$TabDetailFields = new TabDetailFields($tabid);
		$tabDetailFields = $TabDetailFields->getTabDetailFields();
		if(!empty($tabDetailFields)){
			$fieldsel .= '<optgroup class="select" style="border:none" label="'.getTranstab($tabname).getFixedLabel('DETAIL').'">';
			foreach($tabDetailFields as $colname => $field){
				$fieldlabel = $field->getFieldLabelKey();
				$fieldsel .='<option value="[var.'.strtolower($tabname).'details_'.$colname.'_'.strtolower($tabname).']">'.$fieldlabel.'</option>';
			}
			$fieldsel .= '</optgroup>';
		}
	}*/
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
//复选框
function setCheckboxHtml($rowid,$select_value='',$uitype=0){
	$selected = '';
	if($select_value == 1){
		$selected = 'checked';
	}
	$html = '<input type="checkbox" name="fval" class="small" tag="checkbox_fval" rowid="'.$rowid.'" '.$selected.'>';
	return $html;
}
//下拉框 多选框 样式
function setSelectHtml($picklist,$rowid,$select_value='',$uitype){
	if($uitype == 33){
		$html = '<select MULTIPLE id="fval" name="fval[]" rowid="'.$rowid.'" tag="select_fval" class="commonSelectPop gwidth100">';
	}else{
		$html = '<select name="fval" rowid="'.$rowid.'" tag="select_fval" class="commonSelectPop gwidth100">';
	}
	
	foreach($picklist as $val){
		$selected = '';
		if($uitype == 33){
			$temp_select_value = explode(' |##| ',$select_value);
			if(in_array($val,$temp_select_value)){
				$selected = 'selected';
			}
		}else{
			if(!empty($select_value) && $select_value == $val){
				$selected = 'selected';
			}
		}
		$html .= '<option value="'.$val.'" '.$selected.'>'.$val.'</option>';
	}
	$html .= '</select>';
	return $html;
}
//获取特殊的枚举类型的下拉框内容
function getEnuPicklist($module,$columnname){
    global $current_user;
    $picklist = [];
    if($columnname == 'publicaccount'){
        $picklist[0] = getFixedLabel('COMMONACCOUNT');
        if($module=='Leads'){
            $picklist[0] = getFixedLabel('COMMONLEADS');
        }
        $picklist[1] = getFixedLabel('LBL_NOALLOCATE');
        $picklist[2] = getFixedLabel('LBL_PUBLICALLOCATE');
    }else if($columnname == 'pool_id'){
        $language_type = getLanguageType($current_user);
        if($module == 'Accounts'){
            crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
            $cls_PublicAccounts = cls_PublicAccounts::getInstance($module);
            $public_account = $cls_PublicAccounts->getPublicAccountConfig();
        }else if($module == 'Leads'){
            crm_load_class_file('cls_PublicLeads', 'modules/Leads');
            $cls_PublicAccounts = cls_PublicLeads::getInstance($module);
            $public_account = $cls_PublicAccounts->getPublicAccountConfig();
        }
        $picklist = [];
        $picklist[0] = '';
        if($public_account['status'] == 'yes' && !empty($public_account['public_account_pool'])){
            if($language_type == 'zh'){
                $tmp_key = 'zh_name';
            }else{
                $tmp_key = 'en_name';
            }
            foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
                $picklist[$pool_id] = $pool_info[$tmp_key];
            }
        }
    }

    return $picklist;
}


//下拉框以外的枚举类型的字段
function setEnuSelectHtml($picklist,$rowid,$select_value='',$uitype){
    if($uitype == 33){
        $html = '<select MULTIPLE id="fval" name="fval[]" rowid="'.$rowid.'" tag="select_fval" class="commonSelectPop gwidth100">';
    }else{
        $html = '<select name="fval" rowid="'.$rowid.'" tag="select_fval" class="commonSelectPop gwidth100">';
    }

    foreach($picklist as $hide_val => $val){
        $selected = '';
        if(!empty($select_value) && $select_value == $hide_val){
            $selected = 'selected';
        }
        $html .= '<option value="'.$hide_val.'" '.$selected.'>'.$val.'</option>';
    }
    $html .= '</select>';
    return $html;
}
?>