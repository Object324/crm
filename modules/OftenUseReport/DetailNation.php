<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_86 reason:库存报表,即时库存查询  待出入库数量 明细  2018/12/3 16:07
require_once(globalStatic::$root_directory.'Smarty_setup.php');
global $mod_strings,$app_strings,$theme,$currentModule,$singlepane_view,$current_user,$adb;
$smarty=new lingdangCRM_Smarty();

$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
if($_REQUEST['type']=='dairu_qty')
    $display_type = 1;
$smarty->assign('TYPE',$display_type);
$smarty->assign("ID",$_REQUEST['recordid']);

crm_load_class_file('ReportModel','modules/OftenUseReport');
$modelobj = new ReportModel();
$re_string = explode(',',$_REQUEST['re_string']);
$detail = $modelobj->InventoryQuery_ProductDetailQuery($re_string[0],$re_string[1],$re_string[2],$re_string[3],$_REQUEST['recordid'],$_REQUEST['type']);

$smarty->assign("NATIONINFO",$detail);

$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel("LISTOFDOCUMENTS");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("DetailNation.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>