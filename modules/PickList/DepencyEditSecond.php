<?php
require_once 'modules/PickList/PickListUtils.php';
require_once 'modules/PickList/DependentPickListUtils.php';

crm_load_class_file('cls_PickList_Ori','include/Functions/PickList');
$_REQUEST['diony']='yes';

$smarty=new lingdangCRM_Smarty();
$modulename=$_REQUEST['moduleName'];
$parentfieldname=$_REQUEST['sourcefield'];
$childfieldname=$_REQUEST['targetfield'];
$pick_obj=new cls_PickList_Ori();
if($_REQUEST['sourcevalue']!="")
{
    $arr_parentpicklist[]=$_REQUEST['sourcevalue'];
    $smarty->assign("SOURCEVALUE",$_REQUEST['sourcevalue']);
    
}
else
    $arr_parentpicklist=$pick_obj->getPickListValues($parentfieldname,"ld_field");
$arr_childpicklist=$pick_obj->getPickListValues($childfieldname,"ld_field");
$smarty->assign("ARRPARENTPICKLIST",$arr_parentpicklist);
$smarty->assign("ARRCHILDPICKLIST",$arr_childpicklist);
$smarty->assign("SOURCEFIELD",$parentfieldname);
$smarty->assign("TARGETFIELD",$childfieldname);
$focus=CRMEntity::getInstance($modulename);
$smarty->assign("CHILDLABEL",$focus->fieldobj->getFieldInfoBykeyValue("fieldname",$childfieldname,'fieldlabel'));
$smarty->assign("PARENTLABEL",$focus->fieldobj->getFieldInfoBykeyValue("fieldname",$parentfieldname,'fieldlabel'));

if($_REQUEST['mode']!='edit')
{
    $cyclicDependencyExists = lingdang_DependencyPicklist::checkCyclicDependency($modulename, $parentfieldname, $childfieldname);
    if($cyclicDependencyExists) {
    		
        ConvertTojsonString("-1",array(),getFixedLabel('DEPENCYCYCLE'));
    }
}
$smarty->assign("MODE",$_REQUEST['mode']);

//exit();
if($_REQUEST['mode']=='create')
{
    $arr['title']=getFixedLabel("LBL_PICKLIST_DEPENDENCY_SETUP");
    $arr['oktext']=getFixedLabel("ASTEP");
    $arr['canceltext']=getFixedLabel("SAVE");
}
else
{
    $arr['title']=getFixedLabel("EDIT");
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
}
$arr['content']=$smarty->fetch("modules/PickList/DepencyEditSecond.tpl");
ConvertTojsonString(1,$arr,'success');

?>