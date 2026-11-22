<?php
/**
 * 根据组件类型和id返回组件预览的html
 * @author xll
 * date : 2023/08/08
 */
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$stuff_info_arr = ['boardid','boardstuffid','stuffid','stufflisttype','height','stufftitle_zh','stufftitle_en'
    ,'stufftitle','stufftype','chart_type','stufftitle_label','stuff_url'];
$stuff_info = [];
foreach ($stuff_info_arr as $tmpkey){
    $stuff_info[$tmpkey] = $_REQUEST[$tmpkey];
}
//dump($stuff_info);
if($stuff_info['stufflisttype'] == 'defaultstuff'){
    if(file_exists(globalStatic::$root_directory.'modules/Home/HomeBoardNew/HomeBoardNew_'.$stuff_info['stuffid'].'.php')){
        crm_load_class_file("HomeBoardNew_" . $stuff_info['stuffid'], 'modules/Home/HomeBoardNew');
        $stuff_sssclassname = "HomeBoardNew_" . $stuff_info['stuffid'];
        $HomeBaord_stuffobj = new $stuff_sssclassname();
    }else{
        crm_load_class_file("HomeBoardNewParent", 'modules/Home/HomeBoardNew');
        $HomeBaord_stuffobj = new HomeBoardNewParent();
    }
}else{
    if (file_exists(globalStatic::$root_directory.'modules/Home/HomeBoardNew/HomeBoardNew_'.$stuff_info['stufflisttype'].'.php')){
        crm_load_class_file("HomeBoardNew_" . $stuff_info['stufflisttype'], 'modules/Home/HomeBoardNew');
        $stuff_sssclassname = "HomeBoardNew_" . $stuff_info['stufflisttype'];
        $HomeBaord_stuffobj = new $stuff_sssclassname();
    }
}

$Stuff_PreHtml = '';
if(!empty($HomeBaord_stuffobj)){
    $HomeBaord_stuffobj -> viewStyle = 'Preview';
    $Stuff_PreHtml = $HomeBaord_stuffobj->get_stuff_content_html($stuff_info);
    //edit:xll 2023/09/02 BUG0071957 单独刷新组件：“最近六个月目标完成情况”和“目标完成率仪表盘”组件中，目标管理的保存，刷新的是整个界面（包括菜单栏）
    if(isset($_REQUEST['viewStyle']) && $_REQUEST['viewStyle'] == 'refresh'){
        $PageTabHtml =  $HomeBaord_stuffobj->PageTabHtml;
        ConvertTojsonString(1, array('PageTabHtml'=>$PageTabHtml), 'success');
    }
}
//dump($Stuff_PreHtml);
ConvertTojsonString(1, array('content'=>$Stuff_PreHtml), 'success');

?>