<?php
//ls 240827  XUQIU20240815-01 对接发票云的API接口
global $adb,$current_user,$currentModule;
$operation = $_REQUEST["operation"];
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();


$smarty = new lingdangCRM_Smarty;
$_REQUEST['diony'] = 'yes';
$frommodule = $_REQUEST['frommodule']?:$currentModule;
$record = $_REQUEST['record'];
//$focus = CRMEntity::getInstance($frommodule);

crm_load_class_file('PiaozoneClass', 'modules/lingdang');
$piaozoneObj = PiaozoneClass::getInstance($frommodule);


if ($operation == 'getCompanyInfo') {
    $piaozoneObj->getScopeCompanyInfo();
    if (empty($piaozoneObj->scopeCompanyInfo)) {
        ConvertTojsonString("-",array(),'您还没有适用的发票抬头，请联系管理员前往后台设置');
    }

    $arr = array();
    $arr['title'] = "选择公司税号";//暂定弹窗，后面需求可能会去掉
    $arr['oktext'] = getFixedLabel('SAVE');
    $arr['canceltext'] = getFixedLabel('CANCEL');
    $html = '<div style="padding: 10px 20px; display: flex;justify-content: center; align-items: center; line-height: 1.5;"><select name="selectcompany" class="commonSelectPop" style="width: 300px">';
    foreach ($piaozoneObj->scopeCompanyInfo as $company) {
        $html .= '<option value="'.$company['taxNo'].'" class="commonSelectPop">'.$company['name'].'</option>';
    }
    $html .= '</select></div>';

    $arr['content'] = $html;
    $arr['companyInfo'] = $piaozoneObj->scopeCompanyInfo;
    ConvertTojsonString("1",$arr,'success');
}
elseif ($operation == 'getImportInvoiceConfig') {//发票采集页参数
    if (empty($_REQUEST['selectcompanyInfo'])) {
        ConvertTojsonString("-1",[],'请先选择公司税号');
    }

    $piaozoneObj->selectcompanyInfo = json_decode($_REQUEST['selectcompanyInfo'], true);//可上传报销的抬头发票公司信息的集合

    $configInfo = $piaozoneObj->getImportInvoiceConfig($record);
    ConvertTojsonString("1",$configInfo,'success');
}
elseif ($operation == 'downloadInvoice') {
    //下载发票 或者  预览发票,根据type调用不同接口
    $downloadurl = $piaozoneObj->getDownloadUrl($_REQUEST['downloadurl'],$_REQUEST['type']);
    if (empty($downloadurl)) {
        ConvertTojsonString("-1",array(),'操作失败');
    }

    ConvertTojsonString("1",array("downloadurl"=>$downloadurl),'success');
}

ConvertTojsonString("-1",array(),'error');