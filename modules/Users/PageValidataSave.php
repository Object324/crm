<?php
//zkt 20231116 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$frommodule=$_REQUEST['pagevalidatamodule'];
$module=$frommodule;
$id=$_REQUEST['record'];

crm_load_class_file('cls_PageValidataSave','data');
$PageValidataSaveobj=new cls_PageValidataSave($module,$id,$_REQUEST['rowcnt']);

$currency_id=$_REQUEST['currency_id'];
if(get_file_address($module,"ProductDetails"))
{
    $currency_id=$_REQUEST['inventory_currency'];
}
if(empty($currency_id))
{
    $currency_id=1;
}
$PageValidataSaveobj->setCurrencyId($currency_id);

if(isset($_REQUEST['application']) && ($_REQUEST['application']!='create' || $_REQUEST['application']!='edit')){
    $PageValidataSaveobj->resetobj($module,$id);
    $PageValidataSaveobj->setApplication($_REQUEST['application']);
    $PageValidataSaveobj->setAllowSave('no');
    $PageValidataSaveobj->ResetCurrencyid();
    $PageValidataSaveobj->getValidDataInfoPhp();
    if(!empty($PageValidataSaveobj->errortip)){
        $_REQUEST['diony']='yes';
        ConvertTojsonString("-1",array(),$PageValidataSaveobj->errortip);
    }
}
if($id>0){
	$PageValidataSaveobj->focus->retrieve_entity_info($id, $module);
}
$PageValidataSaveobj->resetinfo = 'yes';
$PageValidataSaveobj->setAllowSave('yes');
$PageValidataSaveobj->getValidDataInfoPhp();
//ConvertTojsonString("-2",array(),$PageValidataSaveobj->errortip);
if(!empty($PageValidataSaveobj->errortip)){
//edit:can 20210425 保存验证规则
    $_REQUEST['diony']='yes';
    
    ConvertTojsonString("-2",array(),$PageValidataSaveobj->errortip);
}
else{
    //保存并提交审批时增加提交审批判断
    if($_REQUEST['issavesubmit'] == 'yes'){
        $PageValidataSaveobj->all_validatainfo_arr = [];
        $PageValidataSaveobj->setApplication('savesubmit');
        $PageValidataSaveobj->setAllowSave('yes');
        $PageValidataSaveobj->ResetCurrencyid();
        $PageValidataSaveobj->getValidDataInfoPhp();
        if(!empty($PageValidataSaveobj->errortip)){
            $_REQUEST['diony']='yes';
            ConvertTojsonString("-2",array(),$PageValidataSaveobj->errortip);
        }
    }


    $_REQUEST['diony']='yes';
    ConvertTojsonString("1",array(),"success");
}


?>