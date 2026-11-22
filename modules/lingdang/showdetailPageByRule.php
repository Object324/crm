<?php
//查看界面的布局规则

global $currentModule;
$focus=CRMEntity::getInstance($currentModule);
$focus->id=$_REQUEST['record'];
$modulefields=$focus->fieldobj->getModuleFields();
//duan 20221118 小编辑时，如果当前用户没有部分字段的修改权限，则前端不会传值，所以先从数据库读取再覆盖
$focus->retrieve_entity_info($focus->id,$currentModule);
foreach($modulefields as $fieldname=>$fieldinfo)
{
    //duan 20221118 小编辑时，如果当前用户没有部分字段的修改权限，则前端不会传值，所以不能直接覆盖
    if(!isset($_REQUEST[$fieldname])){
        continue;
    }
    $focus->column_fields[$fieldname]=$_REQUEST[$fieldname];
    if($fieldinfo->getBigType()=='reference'||Field::user_fields($fieldinfo->getUIType()))
    {
        $focus->column_fields[$fieldname.'_name']=$_REQUEST[$fieldname.'_name'];
    }
     else if($fieldinfo->getUIType()==33)
    {
        $focus->column_fields[$fieldname]=setsaveMutliPickListValue($_REQUEST[$fieldname]);
    }
    
}

foreach($modulefields as $fieldname=>$fieldinfo)
{
    if($fieldinfo->getBigType()=='reference'&&isset($_REQUEST[$fieldname.'_name']))
    {
        $focus->column_fields[$fieldname.'_name']=$_REQUEST[$fieldname.'_name'];
    }
}
$smarty=new lingdangCRM_Smarty();

//edit:can 2020-09-27 42759: (61mis.com/kfbcrm)首页-附件管理-详情；在附件管理详情界面进行编辑，保存后，附件编号会消失，附件会变为1的样式
$focus->column_fields['record_id']=$focus->id;
crm_load_function_file("getDetailommonSmarty",'include/utils','DetailViewUtils');
//布局规则和新增编辑界面都会用到该函数
getDetailommonSmarty($smarty,'detail_view',$currentModule,$focus,$mode);
$focus->fieldobj->setPageMode("detailview");

$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
$_REQUEST['diony']='yes';
//$smarty->display('DetailView/ModuleDetailFields.tpl');
//exit();
if(get_file_address($currentModule,"ProductDetails"))
{
   $arr['content']=$smarty->fetch('DetailView/ModuleDetailFields.tpl');
}
else
{
  
     $arr['content']=$smarty->fetch('DetailView/MainDetailFields.tpl');
}
$arr['fields'] = $fields['fields'];
$arr['filejsondata'] = $fieldjsondata;
$arr['isadmin'] = $current_user->is_admin;
$arr['columnfields_value'] = $focus->column_fields;
ConvertTojsonString(1,$arr,'success');


/*$fieldjsondata = array();
    if ($focus->id > 0 && $focus->fieldobj->getFieldInfoBykeyValue("uitype", 1109, 'fieldname') != '')
        $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype", 1109, 'fieldname')] = getAttachmentsTableInfo($focus->id, $currentModule);
    if ($focus->id > 0 && $focus->fieldobj->getFieldInfoBykeyValue("uitype", 69, 'fieldname') != '')
        $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype", 69, 'fieldname')] = getImageFileInfo($focus->id, $currentModule);
*/
?>