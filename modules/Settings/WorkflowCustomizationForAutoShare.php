<?php
$smarty=new lingdangCRM_Smarty;
global $adb,$theme,$mod_strings,$app_strings;
crm_load_class_file("cls_PickList", 'modules/PickList');
$objpinklist = new cls_PickList();

$tabid = $_REQUEST['tabid'];
$module = getTabname($tabid);
$focus = CRMEntity::getInstance($module);
$modulefields = $focus->fieldobj->getModuleFields();
$users_field_arr = [];
foreach ($modulefields as $columname => $field){
    if(Field::user_fields($field->getUIType()) || Field::user_multi_fields($field->getUIType())){
        $users_field_arr[$columname] = $field->getFieldLabelKey();
    }
}

$action_title = '';

$autoshare_type = 'User';
$share_setvalue_user = '';
$share_setvalue_username = '';
$share_setvalue_field = '';
$share_setvalue_fieldlabel = '';

if(!empty($_REQUEST['workflow_actionid'])){
    $sql = 'select ld_workflow_actions.action_title,ld_workflow_autoshare.share_setmode,ld_workflow_autoshare.share_setvalue from ld_workflow_actions LEFT JOIN ld_workflow_autoshare on ld_workflow_actions.id = ld_workflow_autoshare.workflow_action_id where ld_workflow_actions.id = ?';
    $result = $adb->pquery($sql,array($_REQUEST['workflow_actionid']));
    if($adb->num_rows($result) > 0){
        $action_title = $adb->query_result($result,0,'action_title');
        $autoshare_type = $adb->query_result($result,0,'share_setmode');
        if($autoshare_type == 'User'){
            $share_setvalue_user = $adb->query_result($result,0,'share_setvalue');
            $tmp_userid_arr = explode(',',$share_setvalue_user);
            if(count($tmp_userid_arr) > 0){
                $share_setvalue_username_arr = [];
                for($i = 0;$i < count($tmp_userid_arr);$i++){
                    $share_setvalue_username_arr[] = getUserFullName($tmp_userid_arr[$i]);
                }
                $share_setvalue_username = implode(',',$share_setvalue_username_arr);
            }
        }elseif($autoshare_type == 'UserField'){
            $share_setvalue_field = $adb->query_result($result,0,'share_setvalue');
            $tmp_field = $modulefields[$adb->query_result($result,0,'share_setvalue')];
            $share_setvalue_fieldlabel = $tmp_field->getFieldLabelKey();
        }
    }
}

$smarty->assign('autoshare_type',$autoshare_type);
$smarty->assign('share_setvalue_user',$share_setvalue_user);
$smarty->assign('share_setvalue_username',$share_setvalue_username);
$smarty->assign('share_setvalue_field',$share_setvalue_field);
$smarty->assign('share_setvalue_fieldlabel',$share_setvalue_fieldlabel);



$smarty->assign('action_title',$action_title);
$smarty->assign('MODULE',$module);
$smarty->assign('USERS_FIELD_ARR',$users_field_arr);
$smarty->assign('workflow_actionid',$_REQUEST['workflow_actionid']);
$smarty->assign('workflow_id',$_REQUEST['workflow_id']);

$arr['title'] = getFixedLabel('ADDITION').getFixedLabel('WorkflowActions').'  ->  '.getFixedLabel('AUTOSHARE');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('WorkflowCustomization/WorkflowCustomizationForAutoShare.tpl');
ConvertTojsonString(1,$arr,"success");
?>