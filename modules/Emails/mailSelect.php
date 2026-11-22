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

global $current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');

global $app_strings,$mod_strings,$current_user,$theme,$adb;
$image_path = 'themes/'.$theme.'/images/';
$idlist = vtlib_purify($_REQUEST['idlist']);
$pmodule=vtlib_purify($_REQUEST['return_module']);
$excludedRecords=vtlib_purify($_REQUEST['excludedRecords']);

$single_record = false;
if(!strpos($idlist,':'))
{
	$single_record = true;
}
$smarty = new lingdangCRM_Smarty;

$userid =  $current_user->id;

$querystr = "select ld_field.fieldid,ld_field.fieldname,ld_tranlabel.fieldlabel,ld_field.tablename,ld_field.columnname
 from ld_field inner join ld_tranlabel 
 on ld_field.fieldid = ld_tranlabel.relateid 
 where ld_tranlabel.languagetype=? and trantable=? and ld_tranlabel.tabid=? and uitype=13 and ld_field.presence in (0,1,2)";
$res=$adb->pquery($querystr, array($languageType,'ld_field',getTabid($pmodule)));

$numrows = $adb->num_rows($res);
$returnvalue = Array();
for($i = 0; $i < $numrows; $i++)
{
	$value = Array();
	$fieldname = $adb->query_result($res,$i,"fieldname");
	
		$temp=$adb->query_result($res,$i,'columnname');
		$columnlists [] = $temp;
		$fieldid=$adb->query_result($res,$i,'fieldid');
		$fieldlabel =$adb->query_result($res,$i,'fieldlabel');
		$value[] = $fieldlabel;
		$returnvalue [$fieldid]= $value;
	
}

if($single_record && count($columnlists) > 0)
{
	$count = 0;
	$val_cnt = 0;
    /**
     * edit:kevin
     * date:2013-10-24
     * reason:5425
     */ 	
	switch($pmodule)
	{
		case 'Accounts':
        /*
        edit:can
        date:20131012
        reason:5193: 灵当试用问题：邮件按钮无效
        */
			$query = 'select accountname,'.implode(",",$columnlists).' from ld_account 
			left join ld_accountscf on ld_accountscf.accountid = ld_account.accountid 
			left join ld_contactdetails on ld_contactdetails.accountid=ld_account.accountid 
			LEFT JOIN ld_contactscf ON ld_contactscf.contactid = ld_contactdetails.contactid
			where ld_account.accountid = ? and ld_contactdetails.reference = ?';
			$result=$adb->pquery($query, array($idlist,1));
			$num_rows = $adb->num_rows($result);
			if($num_rows < 1){
				$query = 'select accountname,'.implode(",",$columnlists).' from ld_account left join ld_accountscf on ld_accountscf.accountid = ld_account.accountid left join ld_contactdetails on ld_contactdetails.accountid=ld_account.accountid where ld_account.accountid = ?';
				$result=$adb->pquery($query, array($idlist));
			}
        foreach($columnlists as $columnname)	
			{
				$acc_eval = $adb->query_result($result,0,$columnname);
				$field_value[$count++] = $acc_eval;
				if($acc_eval != "") $val_cnt++;
				
			}
			$entity_name = $adb->query_result($result,0,'accountname');
			break;
		case 'Leads':       
			$query = 'select concat(firstname," ",lastname) as leadname,'.implode(",",$columnlists).' from ld_leaddetails left join ld_leadscf on ld_leadscf.leadid = ld_leaddetails.leadid where ld_leaddetails.leadid = ?';
			$result=$adb->pquery($query, array($idlist));
		        foreach($columnlists as $columnname)	
			{
				$lead_eval = $adb->query_result($result,0,$columnname);
				$field_value[$count++] = $lead_eval;
				if($lead_eval != "") $val_cnt++;
			}
			$entity_name = $adb->query_result($result,0,'leadname');
			break;
		case 'Contacts':
			$query = 'select concat(firstname," ",lastname) as contactname,'.implode(",",$columnlists).' from ld_contactdetails left join ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid where ld_contactdetails.contactid = ?';
			$result=$adb->pquery($query, array($idlist));
		        foreach($columnlists as $columnname)	
			{
				$con_eval = $adb->query_result($result,0,$columnname);
				$field_value[$count++] = $con_eval;
				if($con_eval != "") $val_cnt++;
			}	
			$entity_name = $adb->query_result($result,0,'contactname');
			break;
        case 'Vendors':
		$query = 'select vendorname,'.implode(",",$columnlists).' from ld_vendor left join ld_vendorcf on ld_vendorcf.vendorid = ld_vendor.vendorid where ld_vendor.vendorid = ?';
		$result=$adb->pquery($query, array($idlist));
	        foreach($columnlists as $columnname)	
		{
			$con_eval = $adb->query_result($result,0,$columnname);
			$field_value[$count++] = $con_eval;
			if($con_eval != "") $val_cnt++;
		}	
		$entity_name = $adb->query_result($result,0,'vendorname');
		break;	
	}	
}
 
$smarty->assign('ENTITY_NAME',$entity_name);
$smarty->assign('ONE_RECORD',$single_record);
$smarty->assign('MAILDATA',$field_value);
$smarty->assign('MAILINFO',$returnvalue);
$smarty->assign("MOD", $mod_strings);
$smarty->assign("IDLIST", $idlist);
$smarty->assign("APP", $app_strings);
$smarty->assign("FROM_MODULE", $pmodule);
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("EXE_REC", $excludedRecords);
$smarty->assign("SEARCH_URL", vtlib_purify($_REQUEST['searchurl']));
$smarty->assign("VIEWID", vtlib_purify($_REQUEST['viewname']));
$smarty->assign('RECORDID',vtlib_purify($_REQUEST['recordid']));
$_REQUEST['diony']='yes';

if(($single_record && count($columnlists) > 0)){
	$content=$smarty->fetch("SelectEmail.tpl");
} else if(!$single_record && count($columnlists) > 0){
	$content=$smarty->fetch("SelectEmail.tpl");
}elseif ($val_cnt < 0){
	ConvertTojsonString("-1",array(),'error');
} else {
	$arr['modulename']=getTranstab($pmodule);
	ConvertTojsonString("-2",$arr,'error');
}
$arr['title']=getFixedLabel('PLEASESELECTEMAIL');
$arr['oktext']=getFixedLabel('SEND');
$arr['canceltext']=getFixedLabel('CANCEL');
$arr['content']=$content;
ConvertTojsonString(1,$arr,'success');
?>