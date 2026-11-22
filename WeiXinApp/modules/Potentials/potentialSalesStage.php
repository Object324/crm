<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/5/11 0011
 * Time: 下午 3:53
 */
//module=Potentials&action=potentialSalesStage&setype=opts
//module=Potentials&action=potentialSalesStage&setype=save&mode=detail&select_id=53781;&salesstage=方案报价
global $adb;
$setype = $_REQUEST['setype'];
if('opts' == $setype){//获取销售阶段
    crm_load_function_file('getPicklistValesForNORole','modules/PickList','PickListUtils');
    $picklist = getPicklistValesForNORole('sales_stage',$adb);
    $options = array_filter($picklist);
    $newoptions = array();
    foreach($options as $key=>$val){
        $newoptions[] = array('text'=>$key,'value'=>$val);
    }
    ConvertTojsonString(1,array($newoptions),'');
}else {
//选中记录ID
    $select_id = $_REQUEST['select_id'];
//选中销售阶段类型
    $salesstage = $_REQUEST['salesstage'];
    crm_load_class_file('cls_SalesStage', 'modules/Potentials');
    $SalesStage = new cls_SalesStage();
    $finalresult = $SalesStage->save_salesStage_multi($select_id, $salesstage);
    $error = $finalresult['noofrows'] - $finalresult['correct'];

    if ($finalresult['noofrows'] > 0 && $error === 0) {
        ConvertTojsonString(1, array(), 'success');
    }else{
        if($SalesStage->errorcolumn!='')
        {
            $focus=CRMEntity::getInstance('Potentials');
       
            $fieldLabel=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$SalesStage->errorcolumn,'fieldlabel');
           $msg= $fieldLabel.getFixedLabel('FieldCANNOTEMPTY');//批量处理信息
            ConvertTojsonString(-1, array(), $msg);
        
        }
        else
        {
             ConvertTojsonString(-1, array(), getFixedLabel('SALESSTAGENOTCHANGED'));
        }
       
    }
}