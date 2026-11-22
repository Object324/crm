<?php
$smarty=new lingdangCRM_Smarty;
global $adb,$theme,$mod_strings,$app_strings;
$tabid = $_REQUEST['tabid'];
$module=getTabModuleName($tabid);
crm_load_class_file('cls_WorkFlow_Json','include/Workflow');
$focus = CRMEntity::getInstance($module);
$cls_WorkFlow_Json = new cls_WorkFlow_Json($module,$focus);
$customfield = $cls_WorkFlow_Json->getCustomField($module);
$smarty->assign('CUSTOMFIELD_NUM',sizeOf($customfield));
$smarty->assign('CUSTOMFIELD',$customfield);
$smarty->assign('TABID',$_REQUEST['tabid']);
$smarty->assign('ACTION_DATA',$action_data);
$smarty->assign('WORDFLOW_ID',$workflow_id);
$_REQUEST['diony']='yes';
$arr['title'] = getFixedLabel('APIcustomfieldquery');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('WorkflowCustomization/WorkflowCustomizationForCustomField.tpl');
ConvertTojsonString(1,$arr,"success");
?>