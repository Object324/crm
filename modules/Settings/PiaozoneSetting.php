<?php
//XUQIU20240829-13 接口参数，增加“发票识别验真接口”菜单导航栏

$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

crm_load_class_file('PiaozoneClass', 'modules/lingdang');
$piaozoneObj = PiaozoneClass::getInstance("Expense");
$mode = $_REQUEST['mode'];
$mode = empty($mode)?'view':$mode;

$smarty = new lingdangCRM_Smarty;
$smarty->assign('mode',$mode);
$arr = [];

if ($mode == 'view'){//列表界面
    $smarty->assign('service_url',$piaozoneObj->service_url);
    $smarty->assign('appId',$piaozoneObj->appId);
    $smarty->assign('appSecret',$piaozoneObj->appSecret);
    $smarty->assign('accountId',$piaozoneObj->accountId);
    $smarty->assign('user',$piaozoneObj->user);
    $smarty->assign('orgNumber',$piaozoneObj->orgNumber);
    $smarty->assign('companyInfo',$piaozoneObj->companyInfoByApplication);
    $smarty->assign('companyLength',sizeof((array)$piaozoneObj->companyInfoByApplication));
    $arr['content'] = $smarty->fetch('Settings/PiaozoneSetting.tpl');
}
elseif ($mode == 'editSetting'){//编辑按钮
    $smarty->assign('service_url',$piaozoneObj->service_url);
    $smarty->assign('appId',$piaozoneObj->appId);
    $smarty->assign('appSecret',$piaozoneObj->appSecret);
    $smarty->assign('accountId',$piaozoneObj->accountId);
    $smarty->assign('user',$piaozoneObj->user);
    $smarty->assign('orgNumber',$piaozoneObj->orgNumber);
    $smarty->assign('companyInfo',$piaozoneObj->companyInfoByApplication);
    $smarty->assign('companyLength',sizeof((array)$piaozoneObj->companyInfoByApplication));


    $arr['fixedLabelArr'] = array('service_url'=>getFixedLabel('InvoiceLoginAddress'),
        'user'=>getFixedLabel('LoginAccount'),
        'accountId'=>getFixedLabel('TenantId'),
        'appId'=>'appId',
        'appSecret'=>'appSecret',
        'orgNumber'=>getFixedLabel('OrganizationCode'),
    );

    $arr['title'] = getFixedLabel('LBL_PIAOZONE_SETTINGS');
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");

    $arr['content'] = $smarty->fetch('Settings/PiaozoneSetting.tpl');

}
elseif ($mode == 'saveSetting'){//保存设置
    $dataArr = $_REQUEST['data'];
    $piaozoneObj->savePiaozoneSetting($dataArr);
    $piaozoneObj->getCompanyInfoByApplication();
    $smarty->assign('service_url',$piaozoneObj->service_url);
    $smarty->assign('appId',$piaozoneObj->appId);
    $smarty->assign('appSecret',$piaozoneObj->appSecret);
    $smarty->assign('accountId',$piaozoneObj->accountId);
    $smarty->assign('user',$piaozoneObj->user);
    $smarty->assign('orgNumber',$piaozoneObj->orgNumber);
    $smarty->assign('companyInfo',$piaozoneObj->companyInfoByApplication);
    $smarty->assign('companyLength',sizeof((array)$piaozoneObj->companyInfoByApplication));
    $arr['content'] = $smarty->fetch('Settings/PiaozoneSetting.tpl');
    unset($dataArr);
}
elseif ($mode == 'createTax'){//新增编辑发票抬头
    $arr['fixedLabelArr'] = array(
        'name'=>getFixedLabel('COMPANYNAME'),
        'taxNo'=>getFixedLabel('CompanyTaxID'),
    );
    $taxNo = $_REQUEST['taxNo'];
    if (empty($taxNo)){

        $smarty->assign('scopeType','all');
        $smarty->assign('scopeValue',-1);
    }else{
        $companyInfo = $piaozoneObj->companyInfo;
        foreach ($companyInfo as $index => $info){
            if ($info['taxNo'] == $taxNo){
                $companyName = $info['name'];
                $scopeType = $info['scopeType'];
                $scopeValue = $info['scopeValue'];
                break;
            }
        }
        $smarty->assign('taxNo',$taxNo);
        $smarty->assign('companyName',$companyName);
        $smarty->assign('scopeType',$scopeType);
        $smarty->assign('scopeValue',$scopeValue);
        unset($companyInfo,$scopeType,$scopeValue,$companyName);
    }
    $arr['title'] = getFixedLabel('InvoiceHeader');
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content'] = $smarty->fetch('Settings/PiaozoneSetting.tpl');
    unset($taxNo);
}
elseif ($mode == 'saveTax'){//保存发票抬头
    $dataArr = $_REQUEST['data'];
    $refreshtype = $_REQUEST['refreshtype'];
    $status = $piaozoneObj->savePiaozoneTax($dataArr);
    if (!$status){
        unset($mode,$arr,$piaozoneObj,$smarty,$status,$refreshtype,$dataArr);
        ConvertTojsonString(-1,'',getFixedLabel('CompanyTaxID').getFixedLabel('CANNOTREPEAT'));
    }else{
        $piaozoneObj->getCompanyInfoByApplication();
        $smarty->assign('companyInfo',$piaozoneObj->companyInfoByApplication);
        $smarty->assign('companyLength',sizeof((array)$piaozoneObj->companyInfoByApplication));
        $smarty->assign('refreshtype',$refreshtype);
        $arr['content'] = $smarty->fetch('Settings/PiaozoneSettingCommon.tpl');
        unset($status,$refreshtype,$dataArr,$status);
    }

}
elseif ($mode == 'deleteTax'){//删除发票抬头
    $refreshtype = $_REQUEST['refreshtype'];
    $taxNo = $_REQUEST['taxNo'];
    $piaozoneObj->deleteTax($taxNo);
    $piaozoneObj->getCompanyInfoByApplication();
    $smarty->assign('companyInfo',$piaozoneObj->companyInfoByApplication);
    $smarty->assign('companyLength',sizeof((array)$piaozoneObj->companyInfoByApplication));
    $smarty->assign('refreshtype',$refreshtype);
    $arr['content'] = $smarty->fetch('Settings/PiaozoneSettingCommon.tpl');
    unset($refreshtype,$taxNo);
}
elseif ($mode == 'setTaxScope'){//改变发票抬头的适用范围/tag
    $taxNo = $_REQUEST['taxNo'];
    foreach ($piaozoneObj->companyInfo as $key => $info){
        if ($info['taxNo'] == $taxNo){
            $smarty->assign('scopeType', $info['scopeType']);
            $smarty->assign('scopeValue', $info['scopeValue']);
            break;
        }
    }
    unset($taxNo);
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['title'] = getFixedLabel('ALLOCATE');
    $arr['content'] = $smarty->fetch('Settings/PiaozoneSetting.tpl');
}elseif ($mode == 'saveTaxScope'){
    $taxNo = $_REQUEST['taxNo'];
    $refreshtype = $_REQUEST['refreshtype'];
    $scopeType = $_REQUEST['scopeType'];
    $scopeValue = $_REQUEST['scopeValue'];
    $piaozoneObj->saveTaxScope($taxNo,$scopeType,$scopeValue);
    $piaozoneObj->getCompanyInfoByApplication();
    $smarty->assign('companyInfo',$piaozoneObj->companyInfoByApplication);
    $smarty->assign('companyLength',sizeof((array)$piaozoneObj->companyInfoByApplication));
    $smarty->assign('refreshtype',$refreshtype);
    $arr['content'] = $smarty->fetch('Settings/PiaozoneSettingCommon.tpl');
    unset($taxNo,$refreshtype,$scopeType,$scopeValue);
}
unset($smarty,$piaozoneObj,$mode);

ConvertTojsonString(1,$arr,'success');






?>