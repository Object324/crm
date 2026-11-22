<?php
/*
 * zkt
 * 获取界面值中敏感规则的值
 * XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
 * */
//zkt 20231117 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user,$weixin_user;
$module = $_REQUEST['module'];
$record = $_REQUEST['record'];
$requestfieldname = $_REQUEST['fieldname'];
$focus = CRMEntity::getInstance($module);
$fieldname_arr = array();

if(isset($_REQUEST['requestvalues'])){
    $requestvalues_arr = json_decode($_REQUEST['requestvalues'],true);
    foreach($requestvalues_arr as $tmpfieldname=>$tmpfielidvalue)
    {
        $fieldname_arr[$tmpfieldname] = $tmpfielidvalue;
    }
}
$ModuleFields = $focus->fieldobj->getModuleFields();
foreach($ModuleFields as $tmpfieldname=>$tmpfieldinfo){
    if($tmpfieldinfo->getBigType() == 'longtextarea'||$tmpfieldinfo->getBigType() == 'textarea'){
        if(isset($_REQUEST[$tmpfieldname])){
            $fieldname_arr[$tmpfieldname] = $_REQUEST[$tmpfieldname];
        }
    }
}
crm_load_class_file('cls_fieldSensitiverule','include/fields');
$fieldSensitiveruleobj=cls_fieldSensitiverule::getInstance($module);
$fieldSensitiveruleobj->setColumnValuesbyfieldnamearr($fieldname_arr);
$sensitiveresultinfo = $fieldSensitiveruleobj->getSensitiveResultInfobyFieldnamearr($fieldname_arr,$record);
$cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
$returnsensitivedata = array();
if(!empty($sensitiveresultinfo)){
    foreach ($sensitiveresultinfo as $tmpfieldname=>$tmpinfo)
    {
        //如果要加密的字段是触发敏感规则的字段,则不作修改
        if($tmpfieldname  == $requestfieldname){
            continue;
        }
        $tmpfieldinfo = $focus->fieldobj->getFieldInfoobjByKey('fieldname',$tmpfieldname);
        if(isset($tmpinfo['secretvalue'])){
            $tmpfieldvalue = $tmpinfo['secretvalue'];
        }
        else{
            $tmpfieldvalue = $fieldname_arr[$tmpfieldname];
        }
        $rowvaluearr = array('input_name'=>$tmpfieldname,'value'=>$tmpfieldvalue);
        $valuearr = array('input_name'=>$tmpfieldname,'value'=>$tmpfieldvalue);
        if(!empty($tmpfieldinfo)){
            $rowvaluearr['uitype'] = $tmpfieldinfo->getUIType();
            $rowvaluearr['havesensitivevalue'] = $tmpfieldinfo->gethavesensitivevalue();
            $rowvaluearr['sensitiveencryptvalue'] = $tmpfieldinfo->getsensitiveencryptvalue();
            if($weixin_user && $weixin_user->environment && ($weixin_user->environment == 'wxwork' || $weixin_user->environment == 'weixin')){
                $rowvaluearr['sensitiveencryptvalue'] = $cls_AESencryptionbykeyobj->getdecryption($rowvaluearr['sensitiveencryptvalue']);
            }
        }
        $returnsensitivedata[] = array('rawValue'=>$rowvaluearr,'value'=>$valuearr);
    }
}

$arr = array();
$arr['sensitivedata'] = $returnsensitivedata;

ConvertTojsonString(1,$arr,"success");
?>