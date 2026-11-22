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



    $quickcreatestr="##noquickdata##";

    $quickcreatestr=$smarty->fetch("DetailView/PopupEditQuickCreate.tpl");

$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");
$_REQUEST['diony']='diony';
if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
    require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
    $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
} else {
    $arr['title'] = getTranstab($currentModule);
}

//edit: xll 2023/06/05 XUQIU1001203 提醒模块增加页面设置
$focus = CRMEntity::getInstance($currentModule);
$settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();//dump($settingsBtn);
$is_page_setting = "no";
if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
    $is_page_setting = "yes";
}
$arr['is_page_setting'] = $is_page_setting;

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
$arr['columnfields_value']=$focus->column_fields;
$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
//zkt 20240402 BUG20240327-46  kfbcrm-消息中心-页面设置-快速创建-设置默认显示快速创建字段，不勾选“相关对象”，保存-新建消息通知，相关对象还是显示
$arr['isduplicate'] =getTabDuplicate($currentModule);
ConvertTojsonString(1,$arr,"success");
?>