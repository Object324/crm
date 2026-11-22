<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user,$languageType;
$smarty=new lingdangCRM_Smarty;
$module = $_REQUEST['from_module'];
if($_REQUEST['from_module'] == 'Settings'){
    $module = 'Home';
} else if (!isset($_REQUEST['from_module'])){
    $module = $_REQUEST['module'];
}
//删除没有区块的看板  不让它显示出来  ---原因是新建看板的时候 点击下一步就需要保存看板数据了,最后一步点了取消,但是看板主表数据还是被保存了.但是这个时候的看板没有区块,是无效数据
//$delete_sql = "update   ld_homeboard h left join ld_homeboard_plate p on h.boardid=p.boardid set h.deleted=1 where p.boardid is null ";
//$adb->pquery($delete_sql);

$Homeboard_list = [];
//edit: xll 2023/07/20 BUG0069781 看板列表中仅包含我创建的和分配给我的
crm_load_class_file("VisualAnalysisBoardList",'modules/VisualAnalysis');
$boardlistobj = new VisualAnalysisBoardList($module,'All');
$Homeboard_list = $boardlistobj -> getBoardListByType();

$list_header=array(getFixedLabel('TOOLS'),getFixedLabel('TEMLATENAME'),getFixedLabel('DESCRIPTION'),getFixedLabel('MODIFIEDBY'),getFixedLabel('MODIFIEDTIME'));
$smarty->assign('LIST_HEADER',$list_header);
$smarty->assign("MODULE",$module);
$smarty->assign("HomeboardList",$Homeboard_list);
$smarty->assign("languageType",$languageType);

//edit: xll 2023/07/13 BUG0069844 管理数据看板列表名称错误
$HeadMSG = getFixedLabel('BOARDMANAGEMENT');

$smarty->assign("HEADMSG",$HeadMSG);

$arr['title'] = ($module == 'Home') ? getFixedLabel('LBL_TEMPLATES') : getFixedLabel('TemplatesCustomization');
if($_REQUEST['ajax'] == 'no') {
    $str = $smarty->fetch("Home/HomeboardListview_content.tpl");
    $arr['content'] = $str;
}else{
    $str = $smarty->fetch("Home/HomeboardListview.tpl");
    $arr['content'] = $str;
}
ConvertTojsonString(1,$arr,"success");
?>