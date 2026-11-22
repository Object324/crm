<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//editor:gyq_101 reason:产品单据明细界面,查看产品所在仓库数量分布情况  2019/1/28 17:15
crm_load_class_file('ReportModel','modules/OftenUseReport');
$Model = new ReportModel();
//BUG20240304-23 报表分析->即时库存查询，审批状态选择全部，点击库存数量600，弹出层中没有显示仓库明细
$list_entry = $Model->product_detail_qtyinstock($_REQUEST['record'],$_REQUEST['type'],'all',$_REQUEST['approvestatus']);
$smarty = new lingdangCRM_Smarty();
$arr = array();
$smarty->assign('TYPE', $_REQUEST['type']);
$smarty->assign('TITLE', $list_entry['title']);
$smarty->assign('LIST', $list_entry['list']);
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel("PRODUCTQTYINSTOCKTITLE");
$str=$smarty->fetch("modules/Products/detail_qtyinstock.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");


?>
