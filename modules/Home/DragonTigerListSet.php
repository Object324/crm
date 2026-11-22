<?php

global $adb,$current_user,$languageType;
if(!is_admin($current_user)){
    exit('error');
}

$boardid=$_REQUEST['boardid'];
$classArr = [
    'DragonTigerList' => 'DragonTigerList',
    'TargetAnalysis' => 'TargetAnalysis',
];
$className = 'DragonTigerList';
if(isset($classArr[$_REQUEST['stuffName']])){
    $className = $classArr[$_REQUEST['stuffName']];
}
crm_load_class_file($className,'modules/Home/HomeBoardNew');
$stuffDetailObj = $className::getInstance($boardid);
$stuffDetailObj->setStuffId($_REQUEST['stuffid']);
$mode = $_REQUEST['mode'];
$fun_name = 'fun_' . $mode;

if(method_exists($stuffDetailObj,$fun_name))
    $stuffDetailObj->$fun_name();

ConvertTojsonString(1, '', "success");

?>