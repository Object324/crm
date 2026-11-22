<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

$mobj = cls_Instance::get_moduleAction_Instance($currentModule,$_REQUEST['action']);
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
if($_REQUEST['previousAction']=='CreateView'&&vtlib_isModuleActive('OutboundOrder')){
    //判断数量是否大于库存数量
    if($_REQUEST['makesure_save']!='yes'){
        $productinfo = array();
        for($i=1;$i<=$_REQUEST['rowcnt'];$i++){
            if($_REQUEST['hidden_rowid_'.$i]==0){
                $productinfo[] = $_REQUEST['hdnProductId'.$i].'|'.$_REQUEST['quantity'.$i];
            }
        }
        $_REQUEST['productinfo'] = implode(',',$productinfo);
        $_REQUEST['frommodule'] = $_REQUEST['module'];
        require_once(globalStatic::$root_directory.'modules/Products/CheckProductQtyinstock.php');
    }
}

$mobj->common_save();

//$system = getSys_deploy(12);
//if($system['deploy_value']==0&&$_REQUEST['previousAction']=='CreateView'){
//    crm_load_class_file('cls_MassAdd','appCommon/modules/Payment');
//    $massadd = new cls_MassAdd($mobj->focus->id,'CashBack');
//    $massadd->masssave();
//}
//
$mobj->ConvertTojsonStringInSave();
?>