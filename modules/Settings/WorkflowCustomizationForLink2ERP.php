<?php
$smarty=new lingdangCRM_Smarty;
global $adb,$theme,$mod_strings,$app_strings;
if(!empty($_REQUEST['getModuleField']) && $_REQUEST['getModuleField'] == 'yes' && !empty($_REQUEST['sel_tabid'])){
	$moduelfield = getModuleField($_REQUEST['sel_tabid']);
	$_REQUEST['diony']='yes';
	ConvertTojsonString(1,$moduelfield,"success");
}else{
	$moduelfield = getModuleField($_REQUEST['tabid']);
}
$moduelmainfield = getModuleMainField($_REQUEST['tabid']);//调用API只取主表字段

//所有相关模块
/*$sql='select  name ,tablabel,ld_tab.tabid,ld_tranlabel.fieldlabel from ld_tab
inner join ld_tranlabel on ld_tab.tabid=ld_tranlabel.relateid
 where  languagetype=? and trantable=? and `name` in (\'SalesOrder\',\'ServiceContracts\',\'Accounts\',\'Products\',\'Expense\') and presence in(0,2) order by tabsequence ';
$result=$adb->pquery($sql,array($languageType,'ld_tab'));
$workflow_module=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $tablabel=$adb->query_result($result,$i,'tablabel');
    $name=$adb->query_result($result,$i,'name');
    $tabid=$adb->query_result($result,$i,'tabid');
    if($tabid==9)
    {
        $tabid=16;
    }
    $workflow_module[$tabid]=$adb->query_result($result,$i,'fieldlabel');
}
$smarty->assign('WORKFLOW_MODULE',$workflow_module);*/
$smarty->assign('FIELDSEL',$moduelfield);
$smarty->assign('MAINFIELDSEL',$moduelmainfield);
$smarty->assign('MODULE_TABID',$_REQUEST['tabid']);
$workflow_api_parameter = [];

$workflow_actionid = (int)$_REQUEST['workflow_actionid'];
if(!empty($workflow_actionid)){
	$query = "select workflow_id,action_title,api_url,api_jsondata,body_query_type,api_receive_msg from ld_workflow_actions where id = ? limit 1";
	$result=  $adb->pquery($query,array($workflow_actionid));
	$workflow_id = $adb->query_result($result,0,'workflow_id');
	$action_data = array(
		'workflow_id' => $workflow_id,
		'action_title' => $adb->query_result($result,0,'action_title'),
		'api_url' => $adb->query_result($result,0,'api_url'),
		'api_jsondata' => $adb->query_result($result,0,'api_jsondata'),
		'workflow_actionid' => $workflow_actionid,
		'body_query_type' => $adb->query_result($result,0,'body_query_type'),
		'api_receive_msg' => $adb->query_result($result,0,'api_receive_msg'),
	);

    $query = "select workflow_id,workflow_action_id,parameter_name,parameter_type,parameter_value,parameter_description,sequence,workflow_api_type from ld_workflow_api_parameter where workflow_id = ? and workflow_action_id = ?";
    $result=  $adb->pquery($query,array($workflow_id,$workflow_actionid));
    if($adb->num_rows($result) >= 1){
        for($i = 0; $i < $adb->num_rows($result); $i++){
            $workflow_api_type = $adb->query_result($result,$i,'workflow_api_type');
            $sequence = $adb->query_result($result,$i,'sequence');
            $workflow_api_parameter[$workflow_api_type][$sequence] = array(
                'parameter_name' => $adb->query_result($result,$i,'parameter_name'),
                'parameter_type' => $adb->query_result($result,$i,'parameter_type'),
                'parameter_value' => $adb->query_result($result,$i,'parameter_value'),
                'parameter_description' => $adb->query_result($result,$i,'parameter_description'),
            );

        }
    }

}else{
	$workflow_id = (int)$_REQUEST['workflow_id'];
}



$smarty->assign('TABID',$_REQUEST['tabid']);
$smarty->assign('ACTION_DATA',$action_data);
$smarty->assign('WORDFLOW_ID',$workflow_id);

$_REQUEST['diony']='yes';
$arr['title'] = getFixedLabel('ADDITION').getFixedLabel('WorkflowActions').'  ->  '.getFixedLabel('CallLink2ERP');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['work_api_parameter']=$workflow_api_parameter;
$arr['content']= $smarty->fetch('WorkflowCustomization/WorkflowCustomizationForLink2ERP.tpl');
ConvertTojsonString(1,$arr,"success");

//获取所有模块字段
function getModuleField($tabid){
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
			if(in_array($uitype,array('1109','1108','28','69'))){
				continue;
			}
			if($module_type == 'moduel_productdetails' && in_array($fieldname,array('discount_percent','discount_amount','s_h_amount'))){
				continue;
			}
			$fields[$blockid][$columnname]=array("0"=>$tablename,"1"=>$fieldlabel,"2"=>$tabname);
		}
	}
	$fieldsel = ' <option>'.getFixedLabel('PLEASESELECTFIELD').'</option>';
	if(!empty($fields)){
		foreach($fields as $blockid => $fieldinfo){
			$fieldsel .= '<optgroup class="select" style="border:none" label="'.$blocks[$blockid].'">';
			foreach($fieldinfo as $columnname => $arr){
				$fieldsel .='<option value="[var.'.$arr[0].'_'.$columnname.'_'.$arr[2].']">'.$arr[1].'</option>';
			}
			$fieldsel .= '</optgroup>';
			
		}
	}
	$detail_fields = [];
	if($module_type == 'moduel_productdetails'){
		crm_load_class_file("ProductDetails",'include/ProductDetails');
    	$productDetails=ProductDetails::getInstance($tabname);
    	$productmoduleFields=$productDetails->getModuleFields();
		if(!empty($productmoduleFields)){
			$fieldsel .= '<optgroup class="select" style="border:none" label="'.getTranstab('Products').'">';
			foreach($productmoduleFields as $colname => $field){
				$fieldlabel = $field->getFieldLabelKey();
				$tablename = $field->getTableName();
				if($focus->Detail_table_scf == $tablename){
					$fieldsel .='<option value="[var.productdetails_'.$colname.'_products]">'.$fieldlabel.'</option>';
				}else{
					$fieldsel .='<option value="[var.productdetailscf_'.$colname.'_products]">'.$fieldlabel.'</option>';
				}
				
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
	}
	return $fieldsel;
}
//获取模块单据头字段(不包括分录)
function getModuleMainField($tabid){
    global $adb;
    $tabname=getTabname($tabid);
    $blocks = getBlockLabels($tabid);
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
            if(in_array($uitype,array('1109','1108','28','69'))){
                continue;
            }
            /*if($module_type == 'moduel_productdetails' && in_array($fieldname,array('discount_percent','discount_amount','s_h_amount'))){
                continue;
            }*/

            if ($field->getBigType() == 'reference') {
                $tmp_module = cls_module_uitype::getUitypeModule($uitype);
                $entityarray = getEntitynameInfo(getTabid($tmp_module));
//                $entity_field_info = getEntityFieldNames('Accounts');
                $fields[$blockid][$columnname]=array("0"=>$tablename,"1"=>$fieldlabel.'(fldid)',"2"=>$tabname);
                $fields[$blockid][$entityarray['fieldname']]=array("0"=>$entityarray['tablename'],"1"=>$fieldlabel.'(fldname)',"2"=>$entityarray['modulename']);
            }
            elseif ($field->getBigType() == 'selectsource') {
                $fields[$blockid][$columnname]=array("0"=>$tablename,"1"=>$fieldlabel.'(fldname)',"2"=>$tabname);
                $fields[$blockid][$columnname.'_id']=array("0"=>$tablename,"1"=>$fieldlabel.'(fldid)',"2"=>$tabname);
            }
            else{
                $fields[$blockid][$columnname]=array("0"=>$tablename,"1"=>$fieldlabel,"2"=>$tabname);
            }
        }
    }

    $fieldsel = ' <option>'.getFixedLabel('PLEASESELECTFIELD').'</option>';
    if(!empty($fields)){
        foreach($fields as $blockid => $fieldinfo){
            $fieldsel .= '<optgroup class="select" style="border:none" label="'.$blocks[$blockid].'">';
            foreach($fieldinfo as $columnname => $arr){
                $fieldsel .='<option value="[var.'.$arr[0].'_'.$columnname.'_'.$arr[2].']">'.$arr[1].'</option>';
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
?>