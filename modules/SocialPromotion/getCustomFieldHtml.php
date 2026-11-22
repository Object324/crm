<?php
/**
 * User: Dong
 * Project: crm
 * Date: 2020/6/24
 * Description: 获取新建页面的自定义字段的html
 */
global  $theme, $currentModule, $current_user,$languageType;
$mappingModule = $_REQUEST['mappingModule'];
$record = intval(vtlib_purify($_REQUEST['record']));
$type = vtlib_purify($_REQUEST['type']);
// if($type =='changemodule'){
//     $mappingModule = getTabByModule($mappingModule);
// }

$customFieldsNum = intval(vtlib_purify($_REQUEST['customFieldsNum']));
$usedFields = array_filter(explode(';',$_REQUEST['usedFields']));
//编辑
if($record !=''){
    $sql = 'SELECT customfieldsorder from ld_socialpromotion where  socialpromotionid=?';
    $result = $adb->pquery($sql,array($record));
    $num_rows = $adb->num_rows($result);
    if($num_rows>0){
        $customFields = $adb->query_result($result,0,0);
        $customFields = json_decode($customFields,true);
        foreach ($customFields as $key => $field){
            // @edit:dong @date:2020/07/15 @reason: 获取单选和多多选的值
            if($field['bigtype'] =='picklist' || $field['bigtype'] =='multipicklist' ){
                $customFields[$key]['pickListValue'] = explode(';',$field['pickListValue']);
            }
        }
    }
    //BUG0064937 表单推广----编辑单据----定制活动页面-----第一个字段不应该显示向上的箭头 
    $customFields = array_values($customFields);
}else {
    if($type == 'create' || $type =='changemodule'){
        //    创建 和改映射模块
        if ($mappingModule == 'Accounts') {
            $usedFields = array('accountname', 'industry', 'lastname', 'mobile', 'description');
        }
        if ($mappingModule == 'Leads') {
            $usedFields = array('accountname', 'contactname', 'mobile', 'description');
        }
    }

    //载入配置文件
    require_once ('SocialPromotionConfig.php');

    $focus = CRMEntity::getInstance($mappingModule);
    $fieldObj = $focus->fieldobj;
    $moduleFields = $fieldObj->getModuleFields();
    $tmpFields = array();
    $customFields = array();
    crm_load_function_file('getAssignedPicklistValues', 'modules/PickList', 'PickListUtils');

    foreach ($moduleFields as $columnname => $field) {
//    创建 和改映射模块
        if($type == 'create' || $type =='changemodule'){
            if (in_array($columnname, $usedFields)) {
                $tmpFields[$columnname] =$field;
            }
        }else{  //添加字段
            //可添加的字段：uitype IN (1,21,19,11,1101,1102,1103,1109,15,33,56,7,71,5,14,86,17) AND displaytype=1 AND presence<>1 AND IFNULL(allowedit,'')<>'no'
            if (in_array($columnname, $usedFields) && in_array($field->uitype,$needUiType) && $field->displaytype ==1 && $field->presence != 1 && $field->allowedit != 'no') {
                $tmpFields[$columnname] =$field;
            }
        }
    }
    foreach ($tmpFields as $columnname => $field){
        $tmp = array();
        $tmp['bigtype'] = $field->bigtype;
        // @edit:dong @date:2020/07/15 @reason: 单选框和复选框获取值
        if ($tmp['bigtype'] == 'picklist' || $tmp['bigtype'] == 'multipicklist') {
            //获取下拉字段的下拉值
            $picklistValues = getAssignedPicklistValues($field->columnName, 1, $adb, array(), $field);
            $tmp['pickListValue'] = $picklistValues;
        }
        $tmp['columnname'] = $field->columnName;
        $tmp['module'] = $mappingModule;
        $tmp['typeofdata'] = $field->typeofData;
        $tmp['tablename'] = $field->tableName;
        if (substr($tmp['tablename'], -3) != 'scf') {
            $tmp['isfixedtable'] = 1;
        } else {
            $tmp['isfixedtable'] = 0;
        }
        $tmp['fieldlabel'] = $field->fieldLableKey;
        //增加默认附件条件
        if ($tmp['columnname'] == 'accountname') {
            $tmp['disabled'] = 1;  //客户名称不可修改
        } else {
            $tmp['disabled'] = 0;
        }
        //设置字段的默认值  默认字段有些为不可为空  添加的字段 默认可以为空
        if ($tmp['columnname'] == 'lastname' || $tmp['columnname'] == 'mobile' || $tmp['columnname'] == 'accountname' || $tmp['columnname'] == 'contactname') {
            $tmp['required'] = 1;
        } else {
            $tmp['required'] = 0;
        }
        //设置默认字段的所属模块  lastname mobile 属于联系人模块
        if ($tmp['columnname'] == 'lastname' || ($tmp['columnname'] == 'mobile' && $mappingModule =='Accounts')){
            $tmp['module'] = 'Contacts';
        }

        if ($tmp['columnname'] == 'mobile') {
            $tmp['only'] = 1;
        } else {
            $tmp['only'] = 0;
        }
        $customFields[] = $tmp;
    }
}




$smarty = new lingdangCRM_Smarty;
$smarty->assign('type',$type);
$smarty->assign('customFields',$customFields);
if($type == 'add'){
    $smarty->assign('customFieldsNum',$customFieldsNum);
}else{
    $smarty->assign('customFieldsNum',count($customFields));
}
$content=$smarty->fetch("modules/SocialPromotion/SocialCustomFieldHtml.tpl");
$iphoneContent=$smarty->fetch("modules/SocialPromotion/SocialCustomFieldIphone.tpl");

$_REQUEST['diony'] ='diony';
$arr['content'] = $content;
$arr['customFieldsNum'] = $customFieldsNum+count($customFields);
$arr['contentIphone']=$iphoneContent;
ConvertTojsonString(1,$arr,"success");
