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
global $currentModule,$current_user;
global $adb;
require_once('modules/ModTracker/ModTracker.php');
$module = $_REQUEST['from_module'];

$focus = CRMEntity::getInstance($module);

$idlist= vtlib_purify($_REQUEST['massedit_recordids']);
$return_action = 'index';
$correct = 0;
$error = 0;
global $rstart;
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$fieldobj=Field::getInstance($module,$adb);
$smowner =$fieldobj->getWhereSmowner();
$edit_err = '';
$idArr = explode(';',rtrim($idlist,';'));
$entityarray = getEntitynameInfo(getTabid($module));
$tabname = $entityarray['tablename'];
$tabindex = $entityarray['entityidfield'];
$tabfieldname = $entityarray['fieldname'];
//$sql = getListAllQuery($module);//获取query，不需要任何附加条件
//$query = $sql['query'];
$idlist = vtlib_purify($_REQUEST['massedit_recordids']);
$_REQUEST['idlist']=$_REQUEST['massedit_recordids'];
if($idlist=='all')
{
   // $_REQUEST['mass_batch_num_all']=$btach_num;
}
$recordids = getSelectedRecords($_REQUEST,$module,rtrim($idlist,';'),$excludedRecords);


$query = 'select '.$tabindex.','.$tabfieldname.' as subject,'.$smowner[0]['columnname'].' as smownerid from '.$tabname.' where '.$tabindex.' in ('.implode(',',$recordids).')';
$result = $adb->pquery($query);
$num_rows = $adb->num_rows($result);
for($i = 0; $i<$num_rows; $i++){
    $crmid = $adb->query_result($result,$i,$tabindex);
	$subject[$crmid]['subject'] = $adb->query_result($result,$i,'subject');
	$subject[$crmid]['smownerid'] = $adb->query_result($result,$i,'smownerid');
}
if(isset($idlist)) {
	$batchlog = getFixedLabel('DOCUMENTNOSUCCESS');
	$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');
	$batchtype = getFixedLabel('ALLOCATE');
 
    $columname=$focus->getSmownerColumName();
    $assigned = $focus->fieldobj->getFieldInfoBykeyValue('columnname',$columname,'fieldname');
	if(isPermitted($module,'Allocate',$recordid) == 'yes') {
	   
    for($index = 0; $index < count($recordids); ++$index) {
		$recordid = $recordids[$index];
		if($recordid == '') continue;
		if($btach_num <= $index)break;
		
            $sql = 'update '.$focus->table_name.' set '.$smowner[0]['columnname'].' = ? where '.$focus->table_index.' = ? ';
            $adb->pquery($sql,array($_REQUEST['assigned_user_id'],$recordid));
            
			$edit_err .= sprintf($batchsuccesslog,'<a referencemodule="'.$module.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$recordid]['subject'].'</a>',$batchtype).'<br>';
			$correct++;
            //19364: 销售退货单>列表：勾选单据，分配给刘影8，然后又分配给用户刘影-销售。结果：刘影8还是可以收到分配提醒。
            $sql=" delete from ld_reminds where content like '%分配给您，请及时关注！' and status_rmd='未读' and related_to=?";
            $adb->pquery($sql,array($recordid)); 
            $crmid= $adb->getUniqueID("ld_crmentity");
            $sql="insert into ld_crmentity(crmid,setype)
            value(?,?)";
            $adb->pquery($sql,array($crmid,'Reminds'));
            $sql="insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,smcreatorid,smownerid,modifiedby,description,createdtime,modifiedtime)
                            value(?,?,?,?,?,?,?,?,?,?,?,?,?)";
            $adb->pquery($sql,array($crmid,'有新的'.getTranstab($module).'分配给您，请及时关注！',date('Y-m-d H:i:s'),$_REQUEST['assigned_user_id'],'未读',$recordid,$module,$current_user->id,$_REQUEST['assigned_user_id'],0,'',date('Y-m-d H:i:s'),date('Y-m-d H:i:s')));
			$adb->pquery('delete from ld_tabshare where crmid = ?',array($recordid));
			//变更负责人后，删除单据的共享记录
			if($_REQUEST['assigned_user_id'] != $subject[$recordid]['smownerid']){
				$focus->getModuleStatic('ModTracker');//字段修改日志
         
                $focus->modstatic->saveFieldLogOne($module,$assigned,$recordid,
						$subject[$recordid]['smownerid'], $_REQUEST['assigned_user_id']);
			}
        }
	}
	else{
			$edit_err .= sprintf($batchlog,'<a referencemodule="'.$module.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject[$index].'</a>',$batchtype,$batchtype).'<br>';
			$error++;
		}
	if($error == 0){
		$error = count($recordids) - $correct;
	}
	$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
	$submitlog = sprintf($submitlog,count($recordids),$correct,$error);
}
if(isset($_SESSION['lvs'][$module]['viewname'])){
	$viewid = $_SESSION['lvs'][$module]['viewname'];
	$start = $_SESSION['lvs'][$module][$viewid]['start'];
}
if(!$start) $start = 1;
$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
$edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";
$entity['log']['value'] = $submitlog.$edit_err;//批量处理信息
$entity['start']['value'] = $start;//当前页数
$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
$parenttab = getParentTab();
$SearchScope="";
if(isset($_REQUEST['SearchScope']))
{
    $SearchScope=$_REQUEST['SearchScope'];
}
require_once('./include/Zend/Json.php');
$json = new Zend_Json();
$jsonentity = $json->encode($entity);
echo $jsonentity;die;


?>