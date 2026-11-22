<?php
//ls 241111 XUQIU20241021-01 安付宝商务开发
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user,$currentModule,$sm4_key;

require_once globalStatic::$root_directory.'Register/ld_Sm4.php';
$sm4 = new ld_Sm4($sm4_key);
$arr = [];
//加密操作
$operationtype = $_REQUEST['operationtype'];
if ($operationtype == 'encryptstring') {
    $encrypt_string = trim($_REQUEST['encrypt_string']);//待加密字符串
    if (empty($encrypt_string)) {
        ConvertTojsonString(-1,[],"请输入待加密字符");
    }
    $arr['encryptdata'] = $sm4->Encrypt($encrypt_string);
    if (empty($arr['encryptdata'])) {
        ConvertTojsonString(-1,$arr,"加密失败");
    }

    ConvertTojsonString(1,$arr,"success");
}

//解密逻辑
$record = $_REQUEST['record'];
if (empty($record)) {
    ConvertTojsonString(-1,[],"操作失败");
}

//系统操作日志
crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
cls_OperationLogs::saveLogs($currentModule,'Decrypt',$record,$_REQUEST);
$_REQUEST['diony'] = 'yes';

//$version_info = getVersionInfo();
$focus = CRMEntity::getInstance($currentModule);
$fieldobj=$focus->fieldobj;


$focus->id = $record;
$focus->retrieve_entity_info($record, $currentModule);
$fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
$tmpmodulefields = $focus->fieldobj->getModuleFields();

//dump($tmpmodulefields);
//处理待解密字段值
foreach ($tmpmodulefields as $fieldname => $fieldinfo) {

    $tmp_decrypt_value = false;
    $is_encrypt_flag = false;
    if ($currentModule == 'Accounts' && ($fieldinfo->getTableName()=='ld_contactdetails'||$fieldinfo->getTableName()=='ld_contactscf')) {
        $referencemodule_focus = CRMEntity::getInstance("Contacts");
        $referencemodule_fieldinfo = $referencemodule_focus->fieldobj->getFieldInfoobjBykey("fieldname", $fieldinfo->getFieldName());
        if ($referencemodule_fieldinfo&&$referencemodule_fieldinfo->getIsEncrypt()=="yes") {
            $tmp_decrypt_value = $sm4->Decrypt($focus->column_fields[$fieldname]);
            $is_encrypt_flag = true;
        }

    } elseif ($fieldinfo->getBigType()=="text") {
        if ($fieldinfo->getIsEncrypt()=="yes") {
            $tmp_decrypt_value = $sm4->Decrypt($focus->column_fields[$fieldname]);
            $is_encrypt_flag = true;
        }

    } elseif ($fieldinfo->getBigType() == 'reference') {//关联选择单据
        crm_load_class_file("cls_module_uitype", 'include/fields');
        $uitypemodules = cls_module_uitype::getUitypeModules();
        $referencemodule = $uitypemodules[$fieldinfo->getUIType()];
        if(!empty($referencemodule)){
            $entityarray = getEntitynameInfo(getTabid($referencemodule));

            $referencemodule_focus = CRMEntity::getInstance($referencemodule);
            $referencemodule_fieldinfo = $referencemodule_focus->fieldobj->getFieldInfoobjBykey("fieldname", $entityarray['fieldname']);
            if ($referencemodule_fieldinfo && $referencemodule_fieldinfo->getIsEncrypt()=="yes" && $focus->column_fields[$fieldname] > 0) {
                $referencemodule_focus->id = $focus->column_fields[$fieldname];//单据recordid值
//                $referencemodule_focus->retrieve_entity_info($referencemodule_focus->id, $referencemodule);
//                $tmp_decrypt_value = $sm4->Decrypt($referencemodule_focus->column_fields[$entityarray['fieldname']]);// 模块超链接的值
                $href_value = getModuleHref($referencemodule,$referencemodule_focus->id);
                $tmp_decrypt_value = $sm4->Decrypt($href_value);// 模块超链接的值
                if ($tmp_decrypt_value === false) {//BUG20241121-13 客户名称（为明文时），解密后显示变成客户id
                    $is_encrypt_flag = true;
                }
            }
        }
    }

    if ($is_encrypt_flag) {
        $arr['column_fields_value'][] = array(
            "fieldname"=>$fieldname,
            "value"=>$tmp_decrypt_value !== false ? $tmp_decrypt_value:$focus->column_fields[$fieldname],
            "bigtype"=>$fieldinfo->getBigType(),
        );
    }

}

ConvertTojsonString(1,$arr,"success");


?>