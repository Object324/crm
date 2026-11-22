<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$mobj = cls_Instance::get_moduleAction_Instance($currentModule,$_REQUEST['action']);
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
//editor:gyq_20190517 reason:0037096: （公司自用账套）企业微信、微信小程序>灵当CRM>服务合同新增界面：录入值点击保存，
//提示此记录已删除。  2019/5/17 11:12
/*$system = getSys_deploy(58);
if($system['deploy_value']==0&&$_REQUEST['previousAction']=='CreateView'){
    crm_load_class_file('cls_MassAdd','appCommon/modules/Payment');
    $massadd = new cls_MassAdd($mobj->focus->id,'ServiceContracts');
    $massadd->masssave();
}*/

//edit:duan reason:从购物车带出的产品信息创建合同订单后，删除原购物车记录
if(!empty($_REQUEST['relatedCreationInfo'])){
    $relatedCreationInfo = json_decode($_REQUEST['relatedCreationInfo'],true);
    if($relatedCreationInfo['type']=='shopcartCreationInfo'){
        crm_load_class_file('Shopcart','modules/Products');
        $shopcartobj = new Shopcart(); 
        foreach($relatedCreationInfo['cartids'] as $value){
            $shopcartobj->deletecart($value);
        }
    }
}
$mobj->ConvertTojsonStringInSave();
?>