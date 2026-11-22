<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

//editor:gyq_86 reason:产品批次 2018/11/2 11:09
global $current_user,$adb;
crm_load_class_file('ModelBatch','modules/Products/batch');
$module_obj = new ModelBatch();
$module_obj->setParams(['adb'=>$adb]);
$frommodule = $_REQUEST['frommodule'];
$module_obj->setFromModule($frommodule);
$smarty=new lingdangCRM_Smarty();
//chj 2022/6/20 设置：选择批次，批次数量自动覆盖产品数量
if(!empty($_REQUEST['setbatchqtysettings']) && $_REQUEST['setbatchqtysettings'] == 'yes'){
	$query = "delete from ld_batchqtysetting where module = ? and userid = ?";
	$adb->pquery($query,array($frommodule,$current_user->id));
	if($_REQUEST['select_batch_qty'] == 'yes'){
		$query = "insert into ld_batchqtysetting(module,userid) values (?,?)";
		$adb->pquery($query,array($frommodule,$current_user->id));
	}
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),'success');
}
if($frommodule=='OutboundOrder')
{
    $tmparr = $module_obj->getSelectMultibatchList();
   
}
else
    $tmparr = $module_obj->getbatchList();

$listHeaderWidth = $module_obj->getListHeaderWidth();
$smarty->assign("listHeaderWidth",$listHeaderWidth);
//dump([$tmparr,$listHeaderWidth]);

$smarty->assign("TMPARR",$tmparr);
$smarty->assign("Headdtitle",$tmparr['title'][0]);
$focus=CRMEntity::getInstance("Products");
$fieldObj=$focus->fieldobj;
$productdatelabel=$fieldObj->getFieldInfoBykeyValue("columnname","productdate",'fieldlabel');
$protectqualitydate=$fieldObj->getFieldInfoBykeyValue("columnname","protectqualitydate",'fieldlabel');

$query = "select 1 from ld_batchqtysetting where module = ? and userid = ?";
$result = $adb->pquery($query,array($frommodule,$current_user->id));
if($adb->num_rows($result) >= 1){
	$smarty->assign('SELECT_BATCH_QTY','yes');
}else{
	$smarty->assign('SELECT_BATCH_QTY','no');
}
//没有查询到数据，提示信息跨列数量
$smarty->assign("COLSPAN",$module_obj->colspan);
$smarty->assign('FROMMODULE',$frommodule);
$arr['checkbox']='no';
 if($frommodule=='OutboundOrder')
{
   
  $warehouselist= getWareAllInfo($current_user);
  $smarty->assign("warehouselist",$warehouselist);
  $smarty->assign("wareid",$_REQUEST['wareid']);
  if($_REQUEST['query']=='yes')
  {
    $content=$smarty->fetch("batchlistmulticontent.tpl");
    
  }
  else
    $content=$smarty->fetch("batchlistmulti.tpl");
  $arr['checkbox']='yes';
}
else
    $content=$smarty->fetch("batchlist.tpl");

$_REQUEST['diony']='diony';
$arr['content']=$content;
$arr['frommodule'] = $frommodule;
$arr['title']=getFixedLabel("SELECT").getFixedLabel('BATCH');
ConvertTojsonString(1,$arr,'success');

?>