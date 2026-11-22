<?php
/**
* @edit:dong
* @data:2020/7/8
* @reason: 社交推广外部访问 生成静态html
* @description:
 * @test测试地址 :http://127.0.0.1:85/ldcrm/index.php?module=SocialPromotion&action=SocialPromotionAjax&file=SocialPromotionCreateHtml&record=4131&form=0
*/

global   $theme, $currentModule, $current_user , $adb,$site_URL;
$smarty = new lingdangCRM_Smarty();
$record =$_REQUEST['record'];
$focus = CRMEntity::getInstance($currentModule);
$focus->id =$record;
$focus->mode = 'edit';
$focus->retrieve_entity_info($focus->id, $currentModule);

//加载二维码配置文件
require_once ('SocialPromotionConfig.php');

if(!is_dir($htmlPath)){
    mkdir( $htmlPath,0777,true);
}
$htmlFileName = $prefix.$record.$suffix;
//iframe类型 生成两个文件 一个为iframe 一个为form
if($_REQUEST['form'] == 1){
    $htmlFileName = $prefix.$record.'_form'.$suffix;
}

//用于判断
$activitytypeArr = array('仅表单'=>'onlyForm','H5页面链接 + 表单'=>'H5+form');

ob_start();
ob_clean();
$mappingmodule = $focus->column_fields['mappingmodule'];
$mTabid = getTabid($mappingmodule);
// @edit:dong @date:2020/07/14 @reason: 加载级联类
crm_load_class_file("lingdang_DependencyPicklist", 'modules/PickList');
//当前模块的级联关系
$cascade = lingdang_DependencyPicklist::getPickListDepencyFields($mappingmodule);

// @edit:dong @date:2020/07/15 @reason:  联动关系,用于js 上级值改变后清空下级联动值。
$smarty->assign('cascade',json_encode($cascade));
//获取自定义字段信息
$customFields = json_decode($focus->column_fields['customfieldsorder'],true);
//$newCustomFieldNames =array_column($customFields,'columnname');
// @edit:dong @date:2020/09/14 @reason: 兼容5.4
$newCustomFieldNames =_array_column($customFields,'columnname');
foreach ($customFields as $key=>$field){
//    设置下拉框的选项
    if($field['bigtype'] =='picklist'){
        $customFields[$key]['pickListValue'] = explode(';',$field['pickListValue']);
    }elseif($field['bigtype'] =='date'){   // @edit:dong @date:2020/07/14 @reason: 设置页面上js所需的时间选择器格式化样式
        $customFields[$key]['formate'] ="'YYYY-MM-DD'";
    }elseif($field['bigtype'] =='time'){
        $customFields[$key]['formate'] ="'hh:mm:ss'";
    }elseif($field['bigtype'] =='datetime'){
        $customFields[$key]['formate'] ="'YYYY-MM-DD hh:mm:ss'";
    }elseif ($field['bigtype'] =='multipicklist'){ //复选框
        $picklist =array_filter(explode(';',$field['pickListValue']));
        $newpicklist= array();
        foreach ($picklist as $k=>$value){
            $newpicklist[]= array('id'=>$k,'cont'=>$value);
        }
        $customFields[$key]['pickListValue'] = json_encode($newpicklist);
    }
//    级联信息
    if(isset($cascade[$field['columnname']]) && in_array($cascade[$field['columnname']],$newCustomFieldNames)){
        $customFields[$key]['beforecascade'] = $cascade[$field['columnname']]; //级联字段的上级字段
//        unset($customFields[$key]['pickListValue']);
    }
    if(in_array($field['columnname'],$cascade)){
        $customFields[$key]['aftercascade'] = array_keys($cascade,$field['columnname'])[0]; //级联字段的上级字段
    }
}

//获取share img
if(($focus->id>0||$_REQUEST['record']>0)&&$focus->fieldobj->getFieldInfoBykeyValue('bigtype','fileattachment','fieldname')!='') {
    global $site_URL;
    if($focus->id>0){
        $tmp_record = $focus->id;
    }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
        $tmp_record = $_REQUEST['record'];
    }
    $attach = getAllFile_imageInfo($tmp_record, $currentModule)['sharepicture'][0];
    if($attach['storage_location'] =='local'){
        $sharepicture = $site_URL.'/'.$attach['file_path'].$attach['newfile_name'];
    }else{
        $sharepicture = $attach['cloud_path'];
    }

    $smarty->assign('sharepicture',$sharepicture);
}
// @edit:dong @date:2020/07/14 @reason: 前台js使用对应的字段名
// @edit:dong @date:2020/09/14 @reason: 兼容5.4
//$fieldsColumnName = array_column($customFields,'fieldlabel','columnname');
$fieldsColumnName = _array_column($customFields,'fieldlabel','columnname');

$smarty->assign('fieldsColumnName',json_encode($fieldsColumnName));

$smarty->assign('formUrl','/'.$htmlPath.$prefix.$record.'_form'.$suffix);
$smarty->assign('h5url','/'.$htmlPath.$prefix.$record.$suffix);
$smarty->assign('siteUrl',$site_URL.'/');
$activity = $focus->column_fields;
$smarty->assign('customFields',$customFields);
$smarty->assign('record',$record);
$smarty->assign('form',$_REQUEST['form']);
$smarty->assign('uid',$id);
$smarty->assign('activityname',$activity['activityname']);
$smarty->assign('mappingmodule',$activity['mappingmodule']);
$smarty->assign('social_activitytype',$activitytypeArr[$activity['social_activitytype']]);
$smarty->assign('h5pageurl',$activity['h5pageurl']);
$smarty->assign('h5pagebutton',$activity['h5pagebutton']);
$smarty->assign('h5buttoncolor',$activity['h5buttoncolor']);
$smarty->assign('activitytitle',$activity['activitytitle']);
$smarty->assign('activityintroduction',$activity['activityintroduction']);
$smarty->assign('buttonname',$activity['buttonname']);
$smarty->assign('buttoncolor',$activity['buttoncolor']);
$smarty->assign('formheadcolor',$activity['formheadcolor']);
$smarty->assign('sharetitle',$activity['sharetitle']);
$smarty->assign('shareintroduction',$activity['shareintroduction']);

$smarty->caching = false;
$smarty->display('modules/SocialPromotion/SocialPromotionActivity.tpl');
$html=ob_get_contents();
file_put_contents($htmlPath.$htmlFileName, $html);
ob_end_flush();//输出并关闭缓冲区

/**
* @edit:dong
* @data:2020/07/14
* @reason: 获取所有字段的级联关系字段。
* @description:
*/
function check($columnName,$cascadeKey,$cascade,&$result){
    if(in_array($columnName,$cascadeKey)){
        $result[] =$columnName;
        $newColumnName = $cascade[$columnName];
        check($newColumnName,$cascadeKey,$cascade,$result);
    }
    return $result;
}

