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
$focus = CRMEntity::getInstance($currentModule);
$return_action = 'index';
$correct = 0;
$error = 0;
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$fieldobj=Field::getInstance($currentModule,$adb);
$smowner =$fieldobj->getWhereSmowner();
$edit_err = '';
$entityarray = getEntitynameInfo(getTabid($currentModule));
$tabname = $entityarray['tablename'];
$tabindex = $entityarray['entityidfield'];
$tabfieldname = $entityarray['fieldname'];
 
$idlist=$_REQUEST['idlist'];
if($idlist=='all'){
	$recordids = getSelectedRecords($_REQUEST,$currentModule,rtrim($idlist,';'),$excludedRecords);
}else{
	$recordids = explode(';',rtrim($idlist,';'));
}
//获取派息单 - 短信设置信息
$dividend_sms = $focus->getDividendSms();
if(count($dividend_sms['mobile_fieldname']) >= 1){
	$mobile_fieldname = ',' . implode(',', $dividend_sms['mobile_fieldname']);
}
//获取短信内容
$query = 'select content from ld_sendinformcontent where type in (9,10)';
$result = $adb->pquery($query,array());
$num_rows = $adb->num_rows($result);
if($num_rows > 0){
	$dividend_content = $adb->query_result($result,0,'content');
	$anti_dividend_content = $adb->query_result($result,1,'content');
}
$query = 'select '.$tabindex.','.$tabfieldname.' as subject,status,accountid'.$mobile_fieldname.' from '.$tabname.' where '.$tabindex.' in ('.implode(',',$recordids).')';
$result = $adb->pquery($query);
$showfieldvalueobj = new ShowFieldValue($focus->fieldobj,$currentModule,SHOW_POPUP);
$showfieldvalueobj->setadbResult($result);
$num_rows = $adb->num_rows($result);
for($i = 0; $i<$num_rows; $i++){
    $crmid = $adb->query_result($result,$i,$tabindex);
	$res_info[$crmid]['subject'] = $adb->query_result($result,$i,'subject');//模块链接字段
	$res_info[$crmid]['status'] = $adb->query_result($result,$i,'status');//单据状态  未派  已派
	$field=$focus->fieldobj->getFieldInfoobjBykey('columnname','accountid');
    $showvalue=$showfieldvalueobj->getFieldValueByField($field,$adb->query_result($result,$i,'accountid'),$adb->query_result($result,$i,'accountid'));
	$res_info[$crmid]['account_name'] = $showvalue['value'];
	foreach($dividend_sms['mobile_fieldname'] as $mobile_fieldname){
		$res_info[$crmid][$mobile_fieldname] = $adb->query_result($result,$i,$mobile_fieldname);
	}
}
if(isset($idlist)) {
	$batchlog = getFixedLabel('DOCUMENTNOSUCCESS');//单据[%s]%s不成功！原因：您没有该单据的%s权限!
	$batchstatus = getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIANSS');//单据[%s]%s不成功！原因：该单据已经派息
	$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');//单据[%s]%s成功！
	$batchtype = getFixedLabel('DIVIDENDBTN');//派息 操作
	if(isPermitted($currentModule,'Devidend',$recordid) == 'yes') {
		crm_load_class_file('cls_Send_MassSms','include/utils');
		$cls_Send_MassSms = new cls_Send_MassSms();
		for($index = 0; $index < count($recordids); ++$index) {
			$recordid = $recordids[$index];
			if($recordid == '') continue;
			if($btach_num <= $index)break;
			//批量派息的时候才会进入
			if($res_info[$recordid]['status'] == DIVIDEND_STATUS && isset($_REQUEST['operationtype']) && $_REQUEST['operationtype'] == 'mass'){
				$edit_err .= sprintf($batchstatus,'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"  >'.$res_info[$recordid]['subject'].'</a>',$batchtype,$batchtype).'<br>';
				$error++;
			}else{
				$sql = 'update '.$focus->table_name.' set status = ?,actualdividend_date=? where '.$focus->table_index.' = ? ';
				if(isset($_REQUEST['stype']) && $_REQUEST['stype'] == 0){
					//派息
					$adb->pquery($sql,array(DIVIDEND_STATUS,date("Y-m-d H:i:s"),$recordid));	
					if($dividend_sms['is_dividend'] == 0){
						foreach($dividend_sms['mobile_fieldname'] as $mobile_fieldname){
							if(!empty($res_info[$recordid][$mobile_fieldname])){
								$CalledNumber = $res_info[$recordid][$mobile_fieldname];
								$SmsContent = getResult($dividend_content,$currentModule,$recordid);
								$receiveTheme = getTranstab($currentModule) . getFixedLabel('DIVIDENDBTN') . getFixedLabel('DIVIDENDBTN');
								if(!empty($res_info[$recordid]['account_name'])){
									$CalledNumber = $CalledNumber . '<'.$res_info[$recordid]['account_name'].'>';
								}
								$cls_Send_MassSms->send($CalledNumber,$SmsContent,$recordid);
							}
						}
					}
				}else{
					//反派息
					$adb->pquery($sql,array(DIVIDEND_STATUS_NO,"",$recordid));
					if($dividend_sms['is_anti_dividend'] == 0){
						foreach($dividend_sms['mobile_fieldname'] as $mobile_fieldname){
							if(!empty($res_info[$recordid][$mobile_fieldname])){
								$CalledNumber = $res_info[$recordid][$mobile_fieldname];
								$SmsContent = getResult($anti_dividend_content,$currentModule,$recordid);
								$receiveTheme = getTranstab($currentModule) . getFixedLabel('ANTIDIVIDENDBTN') . getFixedLabel('DIVIDENDBTN');
								if(!empty($res_info[$recordid]['account_name'])){
									$CalledNumber = $CalledNumber . '<'.$res_info[$recordid]['account_name'].'>';
								}
								$cls_Send_MassSms->send($CalledNumber,$SmsContent,$recordid);
							}
						}
					}
				}
				$edit_err .= sprintf($batchsuccesslog,'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"  >'.$res_info[$recordid]['subject'].'</a>',$batchtype).'<br>';
				$correct++;	
			}
		}
	}
	else{
			$edit_err .= sprintf($batchlog,'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"  >'.$res_info[$recordid]['subject'].'</a>',$batchtype,$batchtype).'<br>';
			$error++;
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
$entity['title']['value'] = getFixedLabel('BATCHDIVIDEND');// 批量派息
$parenttab = getParentTab();
$SearchScope="";
if(isset($_REQUEST['SearchScope']))
{
    $SearchScope=$_REQUEST['SearchScope'];
}

$json = new Zend_Json();
$jsonentity = $json->encode($entity);
echo $jsonentity;die;

//获取短信内容
function getResult($Content,$module,$recordid)
{        
    global $adb;
    $printcols=preg_split("/(\[Var.|\[var.|\[VAR.|\[vAR.|\[VAr.|\[VaR.|\[vaR.|\[vAr.)/",$Content);
    $focus=CRMEntity::getInstance($module);
	$focus->retrieve_entity_info($recordid,$module);
	$showvalueobj=new ShowFieldValue($focus->fieldobj,$frommodule,SHOW_EDITVIEW);
    $showvalueobj->setRecorId($_REQUEST['record']);
    $showvalueobj->setLine_index(1);
    for($i=0;$i<count($printcols);$i++)
    {
        $fieldname='';
        if(strpos($printcols[$i],']')>0)
        {
            $endcol=strpos($printcols[$i],']');
            $colsinfo=substr($printcols[$i],0,$endcol);
            $colsinfovalue=substr($printcols[$i],$endcol+1,strlen($printcols[$i]));
            $tabcols=explode('_',$colsinfo);
            $curtabname=$tabcols[count($tabcols)-1];//当前打印字段所在模块
          
            
            for($fi=1 ;$fi<count($tabcols)-1;$fi++)
            {
                 if($fi!=(count($tabcols)-2))
                     $fieldname.=$tabcols[$fi].'_';
                else
                    $fieldname.=$tabcols[$fi];
            }
			$field=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
            if(count($tabcols)>0&&strlen($tabcols[1])>0&&strlen($tabcols[0])>0){
				 if($field){
					$showvalue=$showvalueobj->getFieldValueByField($field,$focus->column_fields[$fieldname],$focus->column_fields[$fieldname]);
					$value=$showvalue['value'];
				 }
				$printcols[$i] = $value.$colsinfovalue; 
            }
        }
    }
    return implode('',$printcols);
}

?>