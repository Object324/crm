<?php
global $adb;
$modulename = $_REQUEST['from_module'];
$record = $_REQUEST['record'];
$focus = CRMEntity::getInstance($modulename);
$focus->retrieve_entity_info($record,$modulename);

//通过模块名获取fieldname，从而定位到点击字段名
$entitynames = getEntitynameByModulename($modulename);
$fieldname = ($entitynames['fieldname']);
$hrefname = $focus->column_fields[$fieldname];
//判斷是否为 编号字段(fieldname->fieldinfo->uitype)
$fieldobj =Field::getInstance($modulename, $adb);
$fieldinfo = $fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
$uitype = $fieldinfo->getUIType();

$no_value = '';
// unitype=4? 编号直接返回;非编号 获取编号 连接之后返回
if($uitype!=4){
    $no_fieldinfo = $fieldobj->getFieldInfoobjBykey('uitype',4);
    if(!empty($no_fieldinfo)){
        $no_fieldname = $no_fieldinfo->getFieldName();
        $no_value = $focus->column_fields[$no_fieldname];
    }
}

if(empty($no_value)){
    $copycontent=$hrefname;
}else{
    $copycontent=$no_value.' '.$hrefname;
}

$data['copycontent'] = $copycontent;
ConvertTojsonString(1,$data,"success");
?>