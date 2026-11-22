<?php
global $current_user;
$_REQUEST['diony']='diony';

$changedcombox=$_REQUEST['changedcombox'];
$arr_changedcombox=json_decode($changedcombox,true);

$fieldname=$_REQUEST['fieldname'];
$moduleName=$_REQUEST['moduleName'];
$focus=CRMEntity::getInstance($moduleName);
$fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue('fieldname',$fieldname,'fieldlabel');

$smarty=new lingdangCRM_Smarty();
$smarty->assign("CHANGEDCOMBOXS",$arr_changedcombox);
$arr['content']=$smarty->fetch("modules/PickList/showChangedPickListData.tpl");
$arr['title']=getFixedLabel('EDITPICKLISTVALUE').'>'.$fieldlabel;
$arr['oktext']=getFixedLabel('CONFIRMED');
$arr['canceltext']=getFixedLabel('CANCEL');
ConvertTojsonString(1,$arr,"success");
?>