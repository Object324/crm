<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
require_once 'modules/lingdang/EditView.php';
$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

//新增、编辑单据可直接保存并提交审批
$approveobj=Approve::getInstance($currentModule);
$approve_arr=[];
global $weixin_user;
if($focus->id>0)
{
    if(!array_key_exists('approvestatus',$focus->column_fields)&&empty($focus->column_fields['approvestatus']))
    {
        //审批状态字段隐藏
        $sql= "select approvestatus from "  .$focus->table_name." where "  .$focus->table_index."=?";
        $result=$adb->pquery($sql,array($focus->id));
        $focus->column_fields['approvestatus']=$adb->query_result($result,0,0);

    }
    $status=$approveobj->getApproveStatus($focus->column_fields['approvestatus']);
    if($status==0||$status==3 ||$status==4 || ($status == 2 && $approveobj->recordAgainSubmit($currentModule)))
    {
        $weixin_user->action='default_on_submit';
        $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);
    }
}
else{
    $weixin_user->action='default_on_new';
    $approve_arr=$approveobj->showSubmitPopup($currentModule,$smarty);

}
$smarty->assign("APPROVE_ARR",$approve_arr);

if(empty($qcreate_array['form']) || (is_array($qcreate_array['form']) && sizeof($qcreate_array['form'])<=0))
{
    $quickcreatestr="##noquickdata##";
}
$str=$smarty->fetch("DetailView/PopupEditRelated.tpl");

$_REQUEST['diony']='diony';
$arr['picklistcontent']=$global_pick_list_values;
if (isset($_REQUEST['is_linkmodulecustom']) && $_REQUEST['is_linkmodulecustom'] == '1') {
    require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
    $arr['title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($currentModule);
} else {
    $arr['title'] = getTranstab($currentModule);
}
//wyt 221122 BUG0059030 通用问题，借款单新建界面右上角缺少页面设置按钮
$settingsBtn = $focus->getModuleLogic($currentModule)->getSettingsBtn();
$is_page_setting = "no";
if(isset($settingsBtn['Settings'])&&$settingsBtn['Settings']['permit']=='yes'){
    $is_page_setting = "yes";
}
$arr['is_page_setting'] = $is_page_setting;


$arr['mainfieldformula']=$focus->fieldobj->getFormula();
$arr['approve_arr']=$approve_arr;
$arr['savesubmittext']=getFixedLabel('SaveSubmitApprove');
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
$arr['picklistcontent']=$global_pick_list_values;
$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
$arr['isduplicate'] = getTabDuplicate($currentModule);
///保存判断
$arr["validatasave"]=getValidataSave($currentModule);
$arr["validatasaverule"]=getAllRule($currentModule);
//布局规则
    crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
    $fieldruleobj=cls_fieldrule::getInstance($currentModule);
    $arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段
ConvertTojsonString(1,$arr,"success");
?>
