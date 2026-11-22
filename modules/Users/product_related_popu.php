<?php
global $app_strings, $default_charset;
global $currentModule, $current_user;
global $theme, $adb;

require_once('include/ProductDetailsHtml/ProductRelatedPopu.php');
if(!empty($_REQUEST['selectmodule'])){
	$selectmodule = $_REQUEST['selectmodule'];
	$ProductRelatedPopu = new ProductRelatedPopu($selectmodule,$adb);
	$related_header = $ProductRelatedPopu->getRelatedHeader();
	foreach($related_header as $fieldlabel){
		$serachPromptarr[] = $fieldlabel;
	}
	$serachPrompt = implode('/',$serachPromptarr);
	$related_header_table = $ProductRelatedPopu->getSearchListTable();
}
$smarty = new lingdangCRM_Smarty;
$smarty->assign("SEARCHPROMPT",$serachPrompt);
$smarty->assign('TABLE',$related_header_table);
if($_REQUEST['search_type']=='true'){
    $smarty->display("SelectRelPopupContents.tpl");
}else{
    $smarty->display("SelectRelatedPopup.tpl");
}
exit();
?>