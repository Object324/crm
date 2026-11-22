<?php
global $currentModule;
$mobj = cls_Instance::get_moduleAction_Instance($currentModule,'ListView');
$details = $mobj->get_listdetail(null);

if (isPermitted($currentModule, 'Create', '') == 'yes') {

    if(strpos($mobj->relatedModuleActions,'add')!==false || empty($mobj->relatedModuleActions)){
        $list_buttons = array(1);
    }else{
        $list_buttons = array();
    }
} else {
    $list_buttons = array();
}

$details['list2'] = array(
    'viewname' => $_REQUEST['viewid'],
   // 'moduletitle' => getTranstab('CustomForm08'),
    'camcard'=>$camcard,
    'create_html'=>$list_buttons);
ConvertTojsonString(1, $details, 'success');

?>
