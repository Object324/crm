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
global $adb;
//@edit:zkt @date:2024/12/19 @reason: url验证
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$idlist = vtlib_purify($_REQUEST['idlist']);
$viewid = vtlib_purify($_REQUEST['viewname']);
$returnmodule = vtlib_purify($_REQUEST['return_module']);
$return_action = vtlib_purify($_REQUEST['return_action']);
$excludedRecords=vtlib_purify($_REQUEST['excludedRecords']);
$sign_val=vtlib_purify($_REQUEST['sign_value']);
$rstart='';
//Added to fix 4600
$url = getBasic_Advance_SearchURL();

//split the string and store in an array
$storearray = getSelectedRecords($_REQUEST,$returnmodule,$idlist,$excludedRecords);
$storearray = array_filter($storearray);
$ids_list = array();
$errormsg = '';
$error = 0;
$success = 0;
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
//获取模块链接字段
$entityarray = getEntitynameInfo(getTabid($returnmodule));
$tabname = $entityarray['tablename'];
$tabindex = $entityarray['entityidfield'];
$tabfieldname = $entityarray['fieldname'];

$query = "select * from (select status_rmd,remindsid,$tabfieldname as subject from ld_reminds

        union all select status_rmd,remindsid,$tabfieldname as subject from ld_reminds_accepted ) as tmp 
 where remindsid in (".implode(',',$storearray).")";
$result = $adb->pquery($query);
$num_rows = count($storearray);
for($i=0; $i<$num_rows; $i++){
    //zkt 20240903 BUG20240903-05 在消息界面全选并已读后，点击任意的超链接，看到的的消息单据跟点击的不一致（我怀疑是设为已读后，提示信息单据的顺序和勾选的单据顺序不一致导致的）
	//$remindsid = $storearray[$i];
    $remindsid = $adb->query_result($result,$i,'remindsid');
	$remind[$remindsid]['status_rmd'] = $adb->query_result($result,$i,'status_rmd');
	$remind[$remindsid]['subject'] = $adb->query_result($result,$i,'subject');
}
foreach($storearray as $key => $id)
{
	if($btach_num <= $key)break;
	$focus = CRMEntity::getInstance($returnmodule);
	if($sign_val == 1){
		$batchlog = getFixedLabel('SETREADERROR');
		$batchsuccesslog = getFixedLabel('SETREADSUCCESS');
		$entity['title']['value'] = getFixedLabel('SETREAD');//标题
		if($remind[$id]['status_rmd'] == '已读'){
			//单据[%s]设为已读失败！原因：当前单据已经是已读！
            
			$edit_err .= sprintf($batchlog,'<a referencemodule="Reminds" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.strip_tags($remind[$id]['subject']).'</a>').'<br>';
			$error++;
		}
		else{
			$edit_err .= sprintf($batchsuccesslog,'<a referencemodule="Reminds" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.strip_tags($remind[$id]['subject']).'</a>').'<br>';
			$success++;
			SignEntity($focus,$id,$sign_val);
		}
	}
	else{
		$batchlog = getFixedLabel('SETUNREADERROR');
		$batchsuccesslog = getFixedLabel('SETUNREADSUCCESS');
		$entity['title']['value'] = getFixedLabel('SETUNREAD');//标题
		if($remind[$id]['status_rmd'] == '未读'){
			//单据[%s]设为已读失败！原因：当前单据已经是已读！
			$edit_err .= sprintf($batchlog,'<a referencemodule="Reminds" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.strip_tags($remind[$id]['subject']).'</a>').'<br>';
			$error++;
		}
		else{
			$edit_err .= sprintf($batchsuccesslog,'<a referencemodule="Reminds" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.strip_tags($remind[$id]['subject']).'</a>').'<br>';
			$success++;
			SignEntity($focus,$id,$sign_val);
		}
	}
}
if($error == 0){
	$error = count($storearray) - $success;
}
$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
$submitlog = sprintf($submitlog,count($storearray),$success,$error);
$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
$edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";
if(isset($_SESSION['lvs'][$returnmodule]['viewname'])){
	$viewid = $_SESSION['lvs'][$returnmodule]['viewname'];
	$start = $_SESSION['lvs'][$returnmodule][$viewid]['start'];
}
if(!$start) $start = 1;
$entity['log']['value'] = $submitlog.$edit_err;//批量处理信息
$entity['start']['value'] = $start;//当前页数
$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认

$json = new Zend_Json();
$jsonentity = $json->encode($entity);
echo $jsonentity;die;
/*if(count($ids_list) > 0) {
	$ret = getEntityName($returnmodule,$ids_list);
	if(count($ret) > 0)
	{
       	$errormsg = implode(',',$ret);
	}
}
header("Location: index.php?module=".$returnmodule."&action=".$returnmodule."Ajax&ajax=SignMark&file=ListView&viewname=".$viewid."&errormsg=".$errormsg.$url);*/

?>