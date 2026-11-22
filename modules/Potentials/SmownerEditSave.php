<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule;
global $adb;
global $current_user;
require_once('modules/ModTracker/ModTracker.php');
$focus = CRMEntity::getInstance($currentModule);
$focusContact=CRMEntity::getInstance('Contacts');
$focus_rel =CRMEntity::getInstance('Reminds');

$idlist= vtlib_purify($_REQUEST['massedit_recordids']);//获取分配单据ID

$id_before = explode(";",$idlist);
$new_id_before = "";
for($i=0;$i<count($id_before);$i++)
{
    $new_id_before.=$id_before[$i].",";
}
$new_id_before = rtrim($new_id_before,  ",");
//$new_id_before = substr($new_id_before,0,strlen($new_id_before)-1);
$viewid = vtlib_purify($_REQUEST['viewname']);
$return_module = vtlib_purify($_REQUEST['massedit_module']);
$return_action = 'index';

global $rstart;
//Added to fix 4600
$url = getBasic_Advance_SearchURL();

if(isset($_REQUEST['start']) && $_REQUEST['start']!=''){
	$rstart = "&start=".vtlib_purify($_REQUEST['start']);
}
$assigned_user_id = $_REQUEST['assigned_user_id'];

//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$correct = 0;	//正确记录数
$error = 0;	//错误记录数
$edit_err = '';
$idArr = explode(';',rtrim($idlist,';'));
$entityarray = getEntitynameInfo(getTabid($currentModule));
$tabname = $entityarray['tablename'];
$tabindex = $entityarray['entityidfield'];
$tabfieldname = $entityarray['fieldname'];
$query = "select $tabindex as id,$tabfieldname as subject,smownerid from $tabname where $tabindex in (".implode(',',$idArr).")";
$result = $adb->pquery($query);
$num_rows = $adb->num_rows($result);
for($i = 0; $i<$num_rows; $i++){
	$id = $adb->query_result($result,$i,'id');
	$subject[$id]['subject'] = $adb->query_result($result,$i,'subject');
	$subject[$id]['smownerid'] = $adb->query_result($result,$i,'smownerid');
}
if(isset($idlist) && isset($assigned_user_id)) {
	$recordids = explode(';', rtrim($idlist,';'));
	$batchlog = getFixedLabel('DOCUMENTNOSUCCESS');
	$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');
	$batchtype = getFixedLabel('ALLOCATE');
    $idlist="";
	for($index = 0; $index < count($recordids); ++$index) {
		$recordid = $recordids[$index];
		if($recordid == '') continue;
		if($btach_num <= $index)break;
		if(isPermitted($currentModule,'Allocate',$recordid) == 'yes') {
			$sql='select smownerid from ld_potential where potentialid=?';
            $result =$adb->pquery($sql,array($recordids[$index]));
            if($adb->num_rows($result)>0)
            {
				$assOldOwnerID[] = $adb->query_result($result,0,0);
            }
			$edit_err .= sprintf($batchsuccesslog,'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$recordid]['subject'].'</a>',$batchtype).'<br>';
			$correct++;
			
            /**
            * edit:andy
            * date:2014-3-18
            * reason:销售机会分配时，修改销售机会负责人
            **/
            $allocated_time=date("Y-m-d");
            $adb->pquery("update ld_potential set smownerid = $assigned_user_id where potentialid = $recordid");
			//变更负责人后，删除单据的共享记录
			$adb->pquery('delete from ld_tabshare where crmid = ?',array($recordid));
			if($assigned_user_id != $subject[$recordid]['smownerid']){
				$focus->getModuleStatic('ModTracker');//字段修改日志
				$focus->modstatic->saveFieldLogOne($currentModule,'assigned_user_id',$recordid,
						$subject[$recordid]['smownerid'], $assigned_user_id);
			}
			$deployarray=getSys_deploy(26);//0 是 1否
            $deployvalue = $deployarray['deploy_value'];
            /**
             * andy 
             * 新增字段 分配时间
             * date 20140403
             */ 
            $sql_change= "UPDATE ld_potential set allocated_time='$allocated_time' where potentialid=$recordid";
            $adb->pquery($sql_change);
            /**
            * edit:andy
            * date:2014-3-18
            * reason:销售机会分配时，是否同时分配相关信息
            **/
            //是
            if($deployvalue != 'none')
            {
				//更改相关信息模块单据的负责人ID
				$focus->UpdateRelatedListModuleSmownerid($currentModule,$recordid,$assigned_user_id);
            }
            
		}else{
			$edit_err .= sprintf($batchlog,'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)">'.$subject[$recordid].'</a>',$batchtype,$batchtype).'<br>';
			$error++;
		}
	}
	if($error == 0){
		$error = count($recordids) - $correct;
	}
	$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
	$submitlog = sprintf($submitlog,count($recordids),$correct,$error);
}
if(isset($_SESSION['lvs'][$currentModule]['viewname'])){
	$viewid = $_SESSION['lvs'][$currentModule]['viewname'];
	$start = $_SESSION['lvs'][$currentModule][$viewid]['start'];
}
if(!$start) $start = 1;
$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
$edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";
$entity['log']['value'] = $submitlog.$edit_err;//批量处理信息
$entity['start']['value'] = $start;//当前页数
$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
$parenttab = getParentTab();
$SearchScope=$_REQUEST['SearchScope'];
$massHref="index.php?module=$return_module&action=$return_action&parenttab=$parenttab$rstart&SearchScope=$SearchScope&query_session=1";
$_REQUEST['id']=$new_id_before;
$_REQUEST['sendSms']=implode(',',$assOldOwnerID);
include("modules/Potentials/Potentialsalertmsg.php");
require_once('include/Zend/Json.php');
$json = new Zend_Json();
$jsonentity = $json->encode($entity);
echo $jsonentity;die;
?>