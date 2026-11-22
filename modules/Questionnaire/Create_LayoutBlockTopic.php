<?php
global   $theme, $currentModule, $current_user,$site_URL,$adb,$languageType;
$focus = CRMEntity::getInstance($currentModule);
$smarty = new lingdangCRM_Smarty;
$_REQUEST['diony']='diony';
$blockid = $_REQUEST['blockid'];
$focus->id = $_REQUEST['record'];
$focus->mode = 'create';
if ($blockid>0){
    $focus->mode = 'edit';
}
$blockinfo = [];
$tille_top = 'NEWBLOCK';
if($focus->mode == 'edit'){
    $blockinfo = $focus->get_BlockInfo($blockid);
}

$blockafter_list = $focus->get_BlockList($focus->id);
$smarty->assign('BLOCK_ID',$blockid);
$smarty->assign('BLOCK_NAME',$blockinfo['blockname']);
$smarty->assign('AUTONUMBER',$blockinfo['autonumber']);
$smarty->assign('BLOCK_TYPE',$blockinfo['blocktype']);
$smarty->assign('NUMBERSTYLE',$blockinfo['numberstyle']);
$smarty->assign('NUMBERSUFFIX',$blockinfo['numbersuffix']);
$smarty->assign('AFTERBLOCKID',$blockinfo['afterblockid']);
$smarty->assign('BLOCKLIST',$blockafter_list);

$str=$smarty->fetch("modules/Questionnaire/Create_LayoutBlockTopic.tpl");

$arr['title'] = getTranstab($currentModule);
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>