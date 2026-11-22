<?php 
/*
edit:duan
date:2022-6-2
reason:获取移动端任务详情信息
*/
//保存必填字段的值
if($_REQUEST['mode'] == 'save'){
    crm_load_class_file('cls_SaveWX','WeiXinApp/detail');
    $mobj = new cls_SaveWX($_REQUEST['frommodule']);
    $mobj->checkeditpermit = 'no';
    $mobj->focus->id = $_REQUEST['record'];
    $mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
    
    $_REQUEST['module'] = $_REQUEST['frommodule'];
    $ismobile = 'yes';
    require(globalStatic::$root_directory."modules/lingdang/SaveAdvanceFieldValue.php");
    exit();
}else if($_REQUEST['mode'] == 'detail'){
    $module = $_REQUEST['frommodule'];
    $record = $_REQUEST['record'];

    crm_load_class_file('cls_module_advance','modules/Settings');
    $cls_module_advance_obj =  cls_module_advance::getInstance($module);
    $cls_module_advance_obj->showtype = 'detail';

    if($cls_module_advance_obj->moduleadvance['method'] == 'field'){
        $fieldname = $cls_module_advance_obj->moduleadvance['module_field'];
    }else{
        $fieldname = 'advance_stage';
    }
    $modtracker_value = $cls_module_advance_obj->getModtrackerData_public($record,$fieldname);
    $arr['advancerelationinfo'] = $cls_module_advance_obj->get_weixin_taskinfo($record);
    $stagename = $_REQUEST['stagename'];
    $modtracker_value[$stagename]['userfullname_getin'] = getFixedLabel('ENTERSTAGE').getFixedLabel('OPERATIONER').':'.$modtracker_value[$stagename]['userfullname_getin'];
    $modtracker_value[$stagename]['changedon_getin'] = getFixedLabel('ENTERSTAGE').getFixedLabel('operatoroertime').':'.$modtracker_value[$stagename]['changedon_getin'];
    $modtracker_value[$stagename]['userfullname'] = getFixedLabel('LEAVESTAGE').getFixedLabel('OPERATIONER').':'.$modtracker_value[$stagename]['userfullname'];
    $modtracker_value[$stagename]['changedon'] = getFixedLabel('LEAVESTAGE').getFixedLabel('operatoroertime').':'.$modtracker_value[$stagename]['changedon'];
    $modtracker_value[$stagename]['staytimecontent'] = getFixedLabel('CURRENT').getFixedLabel('LATESTDURATION').':'.$modtracker_value[$stagename]['staytimecontent'];
    $modtracker_value[$stagename]['showstaytimecontent'] = getFixedLabel('CURRENT').getFixedLabel('TOTALDURATION').':'.$modtracker_value[$stagename]['showstaytimecontent'];
    $arr['advancerelationinfo']['modtrackerdata'] = $modtracker_value[$stagename];
    
    $label_arr = array(
        'DETAIL1APP',
        'YES',
        'NO',
        'NOCREATED',
        'ADVANCEPUSHDETAIL',
        'PLEASECONFIRMSOFTWAREFORFILE',
        'OPENING',
    );
    $fixedlabel_arr = TransFieldlabel($label_arr);
    $arr['arrFixedLabel'] = $fixedlabel_arr;
}else{
    $module = $_REQUEST['frommodule'];
    $record = $_REQUEST['record'];
    crm_load_class_file('cls_module_advance','modules/Settings');
    $cls_module_advance_obj =  cls_module_advance::getInstance($module);
    $cls_module_advance_obj->setRequestColumn($_REQUEST['fieldvaluejson']);

    $arr['advancerelationinfo'] = $cls_module_advance_obj->get_weixin_taskinfo($record);
    $arr['arrFixedLabel'] = getAdvanceTaskFixedlabel();
}
$_REQUEST['diony'] = 'yes';
ConvertTojsonString(1,$arr,'success');
//duan 20221019 获取推进任务界面翻译
function getAdvanceTaskFixedlabel(){
    $label_arr=array(
        'LBL_ACTIVATE',//状态
        'LBL_PLEASE_SELECT',//请选择
        'YES',//是
        'NO',//否
        'pleaseenter',//请输入
        'LBL_Creates',//创建
        'TASKINFOEMPTY',//未设置任务信息
        'SAVE',//保存
        'TASK',//任务
        'UPLOADING',//上传中...
        'UPTOUPLOAD',//最多可上传
        'ALSOUPLOAD',//您还可以上传
        'NOTPICTUREFILETYPE',//不是图片文件类型
        'PLEASESELECTPICTURES',//请选择%dM以内的图片
        'UPLOADFAILED',//上传失败
        'UPLOADSUCCEEDED',//上传成功
        'IMAGEUPLOADING',//图片上传中...
        'ATTACHMENTUPLOADING',//附件上传中...
        'SUCCESSFULLYSAVED',//保存成功
        'PLEASECONFIRMSOFTWAREFORFILE',
        'OPENING',
        'PHOTOGRAPH',//拍照
        'PhotoAlbum',//相册
        'WECHATCLIENTCHOOSEFILE',//微信客户端会话选择文件
        'FORMATERROR',//格式错误
    );
    $fixedlabel_arr = TransFieldlabel($label_arr);
    return $fixedlabel_arr;;
}
?>