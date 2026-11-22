<?php
global  $current_user;
$smarty=new lingdangCRM_Smarty;
$module=$_REQUEST['module'];
$tabid=getTabid($module);
$focus=CRMEntity::getInstance($module);
$PrintSettingCategories=getUsersettingByLabel($module,1,'PrintSettingCategories');
$PrintSettingCategoriesArr = explode(',',$PrintSettingCategories);
$prints=$focus->getPrintTemplate($tabid);
$_REQUEST['diony']='diony';
//浩辰特殊开发  chj  20220530 合同生成页面的合同类别与打印模板绑定，即选择打印模板时，默认显示唯一打印模板，不允许选择
$version_info = getVersionInfo();
if($version_info['account'] == 'haochen' && $module == 'CustomForm14'){
    $prints=$focus->getPrintTemplate_haochen($prints,$tabid);
}
$arr['is_admin']='no';
if(is_admin($current_user)){
    $smarty->assign('is_admin','yes');
    $arr['is_admin']='yes';
}


// crm_load_class_file('cls_uploads','modules/uploads');
// $cls_uploads = new cls_uploads($newfile_name,$filepath,$fileid);
// $openofficeStatus = $cls_uploads->isInstalledOpenOffice('com.sun.star.ServiceManager');// 判断是否安装了openoffice,有些客户走这个方法会超时先注释
$arr['openofficeStatus'] = 'no';

if(empty($prints))
{
    ConvertTojsonString("-1",array('title'=>getFixedLabel("WARMPROMPT"),"oktext"=>getFixedLabel("CONFIRME")),getFixedLabel("HAVENOPRINTTEMPLATE"));

}
else
{
    $arr['PrintSettingCategoriesArr']=$PrintSettingCategoriesArr;
    $arr['content']=$prints;
    $arr['title']=getFixedLabel("PRINTTOOL");
    $arr['oktext']=getFixedLabel("CONFIRME");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['printname']=getFixedLabel("PRINTTEMPLAATE");
    $arr['chooseoperatename']=getFixedLabel("CHOOSEOPERATE");
    $arr['exportname']=getFixedLabel('ExporttoPDF');
    $arr['emailname']=getFixedLabel("Send_Email_Add_PDF");
    $arr['print']=getFixedLabel("PRINT");
    $arr['email_status']=vtlib_isModuleActive('Emails');
    ConvertTojsonString(1,$arr,"");
}

?>