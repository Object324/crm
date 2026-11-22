<?php
/****************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 **AUTHOR:BY hzx
 **DATE:20230307
 *DESCRIPTION:创建首页看板
 ****************************************************/
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $mod_strings,$app_strings,$adb,$languageType,$currentModule;
$smarty=new lingdangCRM_Smarty;

$boardid = $_REQUEST['boardid'];
$from_module = $_REQUEST['from_module'];
$from_module = empty($from_module)?$currentModule:$from_module;
$mode = 'create';
if($boardid > 0){
    $mode = 'edit';
}
crm_load_class_file('DateOperation','include');
$data_select = DateOperation::getHomeDateSearchSelect();
$smarty->assign('DATASELECT',$data_select);

crm_load_class_file("Homeboard",'modules/Home');
$Homeboardobj = Homeboard::getInstance($boardid,$from_module);

$Homeboard_content = [];
$DatarangeSetListDefault = [];//zxm 20230613 所有组件范围设置的默认数组
$DatarangeSetList = [];
if($mode == 'edit'){
    $Homeboard_content = $Homeboardobj->get_Homeboard_info($boardid);
    $DatarangeSetList = $Homeboardobj->DatarangeSetList;//zxm 20230613 看板数据范围设置的数组
    $Homeboard_content['timesearchdefault_label'] = $data_select[$Homeboard_content['timesearchdefault']];
    $Homeboard_content['approve_value_array'] = explode(',',$Homeboard_content['approve_value']);
}
//zxm 20230606 将时间默认值返回到页面
$smarty->assign('timesearchdefault',$Homeboard_content['timesearchdefault']);

$all_stufflist = array(
    'default_stuff'=>array(
        'style'=>'defaultstuff',
        'stufflist'=>$Homeboardobj->getHomeStuffList($from_module),
        'stufflist_label'=>getFixedLabel('Preset_components')
    )
);
$all_stufflist['custormreport'] = array(
    'style'=>'customreport',
    'stufflist'=>$Homeboardobj->getCustomEchartList(),
    'stufflist_label'=>getFixedLabel('CustomEcharts')
);
$all_stufflist['customtable'] = array(
    'style'=>'customtable',
    'stufflist'=>$Homeboardobj->getCustomTableList(),
    'stufflist_label'=>getFixedLabel('CustomTables')
);
$DatarangeSetListDefault = $Homeboardobj->DatarangeSetListDefault;

//edit: xll 2023/07/13 各组件的其他设置信息
$StuffOtherSet = $Homeboardobj->getStuffOtherSet();

//edit: xll 2023/07/13 XUQIU1001446 增加“可视化分析”模块（创建看板上传图标提示）
$IconMSG = getFixedLabel('VISUALANALYSISICONMSG');
$IconMSG_array = explode('%',$IconMSG);
$IconMSG = $IconMSG_array[0] . getTranstab($currentModule) . $IconMSG_array[2];
$smarty->assign("ICONMSG",$IconMSG);

$smarty->assign("MODULE",$currentModule);
$smarty->assign("from_module",$from_module);
$smarty->assign("boardid",$boardid);
$smarty->assign("stufflist",$all_stufflist);
$smarty->assign("LANGUAGETYPE",$languageType);
$smarty->assign("HOMEBOARD_CONTENT",$Homeboard_content);
$OperationTip = '1. ' . getFixedLabel('EditHomeBoardTip') . '<br>' . '2. ' . getFixedLabel('EditHomeBoardTip2') ;
$smarty -> assign('OperationTip',$OperationTip);
$arr['title'] = ($currentModule == 'VisualAnalysis') ? getFixedLabel('TemplatesCustomization') : getFixedLabel('LBL_TEMPLATES');
$smarty->assign("boardtype",$_REQUEST['boardtype']);
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Home/HomeboardEditView.tpl");
$arr['content']=$str;
$arr['Homeboard_content']=$Homeboard_content;
$arr['DatarangeSetListDefault']=$DatarangeSetListDefault;
$arr['DatarangeSetList']=$DatarangeSetList;
$arr['data_select']=$data_select;
$arr['StuffOtherSet']=$StuffOtherSet;
ConvertTojsonString(1,$arr,"success");
exit();
?>