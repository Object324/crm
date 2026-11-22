<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once 'modules/lingdang/EditView.php';
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

$smarty->assign("QUICKCREATE", $qcreate_array['form']);
if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}
else
    $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");

$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");


$_REQUEST['diony']='diony';
$arr['title']=getTranstab($currentModule);
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$quickcreatestr;
$arr['allcontent']=$str;
$arr['fieldname']=$data['fieldname'];
$arr['datatype']=$data['datatype'];
$arr['fieldlabel']=$data['fieldlabel'];
$arr['fields']=$fields['fields'];
$arr['filejsondata']=$fieldjsondata;
$arr['isadmin']=$current_user->is_admin;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['columnfields_value']=$focus->column_fields;
$arr['picklistcontent']=$global_pick_list_values;
$arr['isduplicate'] = getTabDuplicate($currentModule);
///保存判断
$arr["validatasave"]=getValidataSave($currentModule);

//布局规则
crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
$fieldruleobj=cls_fieldrule::getInstance($currentModule);
$arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
ConvertTojsonString(1,$arr,"success");
?>