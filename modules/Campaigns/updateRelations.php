<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/


global $singlepane_view, $currentModule;
$idlist = vtlib_purify($_REQUEST['idlist']);
$dest_mod = vtlib_purify($_REQUEST['destination_module']);
//$parenttab = getParentTab();
$parenttab = '';
$forCRMRecord = vtlib_purify($_REQUEST['parentid']);

if($singlepane_view == 'true')
	$action = "DetailView";
else
	$action = "CallRelatedList";

$storearray = array();

if($_REQUEST['idlist']=='all')
{
    //27265: 市场活动>明细>相关信息>客户：选择客户，没有显示【全选所有N条记录】按钮。
   $storearray= getSelectedRecords($_REQUEST,$dest_mod,$_REQUEST['idlist'],'');
  
}
else if(!empty($_REQUEST['idlist'])) {
	// Split the string of ids
	$storearray = explode (";",trim($idlist,";"));
} else if(!empty($_REQUEST['entityid'])){
	$storearray = array($_REQUEST['entityid']);
}
$focus = CRMEntity::getInstance($currentModule);
if(!empty($storearray)) {
	relateEntities($focus, $currentModule, $forCRMRecord, $dest_mod, $storearray);
}
//edit: chj date: 2020/9/29 市场活动，相关信息全选客户 - 跳转到首页了
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
//header("Location: index.php?action=$action&module=$currentModule&record=".$forCRMRecord."&parenttab=".$parenttab);

?>