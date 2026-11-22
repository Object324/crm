<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_145 reason:销售机会增加产品分录  2019/9/19 11:43
//editor:gyq_20190923 reason:销售机会增加产品分录受系统参数控制
$deploy_value = getSys_deploy('205');
$value = $deploy_value['deploy_value'];
if($value==0){
    crm_load_class_file('cls_ProductEntry_DetailViewWX', 'WeiXinApp/detail');
    $mobj = new cls_ProductEntry_DetailViewWX($currentModule);
}else{
    $mobj = cls_Instance::get_moduleAction_Instance($currentModule,'DetailView');
}
//销售机会查重权限判断，新增界面机会名称旁边有搜索功能
if (isPermitted($currentModule,'accountdatadup')=='yes'){
    $list_buttons['Datadupcheck'] = 'yes';
}
$mobj->jsonArr['list2'] = $list_buttons;

$details = $mobj->common_getInfo();
echo $details;

?>