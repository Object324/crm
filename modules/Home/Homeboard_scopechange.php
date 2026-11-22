<?php
global $adb;

$boardid = $_REQUEST['boardid'];
$scope = $_REQUEST['scope'];
$scopeid = $_REQUEST['scopeid'];
$module = $_REQUEST['module'];
$boardtype = $_REQUEST['boardtype'];
$scope_list = explode(',',$scopeid);
if($boardid > 0){
    $sql = 'UPDATE ld_homeboard set scope = ? where boardid = ?;';
    $adb->pquery($sql,array($scope,$boardid));
    if($scope == 'all'){
        crm_load_class_file("cls_related_scope",'include/utils');
        cls_related_scope::delete_related_scope($boardtype,'Homeboard_scope',$boardid);
    }else{
        crm_load_class_file("cls_related_scope",'include/utils');
        cls_related_scope::save_related_scope($boardtype,'Homeboard_scope',$boardid,$scope_list);
    }
}
ConvertTojsonString(1,'',"success");
?>