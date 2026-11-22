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

require_once('Smarty_setup.php');
global $mod_strings;
global $app_strings;
global $app_list_strings;

$smarty = new lingdangCRM_Smarty;

global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

//editor:gyq_76 reason:呼叫中心来电弹屏增加创建销售机会 2018/8/23 13:27
require('user_privileges/user_language_'.$current_user->id.'.php');
$sql="
SELECT 
T1.tabid, 
GROUP_CONCAT(T2.columnname) as columnname, 
GROUP_CONCAT(T3.fieldlabel) as fieldlabel 
FROM 
( 
SELECT tabid,tabsequence FROM ld_tab WHERE presence = 0 AND NAME IN ('Leads','Accounts','Contacts','Vendors','VendorContact','Potentials') 
) AS T1 
LEFT JOIN ( 
SELECT tabid, fieldid,columnname FROM ld_field WHERE uitype IN (11, 1101,1102) AND presence <> 1 and callchecked=1
) AS T2 ON T1.tabid = T2.tabid 
left join ld_tranlabel as T3 on T3.tabid=T2.tabid 
and T3.relateid=T2.fieldid and T3.languagetype=? and T3.trantable=? 
group by T1.tabid
order by T1.tabsequence  ";
$list_result = $adb->pquery($sql,array($languageType,'ld_field'));
$num_rows=$adb->num_rows($list_result);
$arr=array();
if($num_rows){
    for($i=0;$i<$num_rows;$i++){
        $arr[]=array(
        'tabid'=> $adb->query_result($list_result,$i,'tabid'),
        'tabname'=> getTabname($adb->query_result($list_result,$i,'tabid')),
        'fieldid'=> getFieldsid($adb->query_result($list_result,$i,'tabid'),$adb->query_result($list_result,$i,'columnname')),
        'columnname'=> $adb->query_result($list_result,$i,'columnname'),
        'fieldlabel'=> $adb->query_result($list_result,$i,'fieldlabel')
        );
    }
}

$smarty->assign("RESULTLIST", $arr);

function getFieldsID($tabid,$fields)
{
    $fields_results=explode(",",$fields);
    $fieldids = '';
    foreach ($fields_results as $result)
    {   
        $fieldid = getID($tabid,$result);
        $fieldids .= $fieldid.','; 
    }
    $fieldids = substr($fieldids, 0, strlen($fieldids)-1);
    return $fieldids;
}

function getID($tabid,$columnname)
{
    global $adb;
    $query="select fieldid from ld_field where tabid = $tabid and columnname= '$columnname' ";
    $result=$adb->query($query);
    $columnname = $adb->query_result($result, 0, 'fieldid');
    return $columnname;
}
//销售线索
$leadsSQL = "select ld_field.fieldid,ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename,ld_field.callchecked 
        from ld_field inner join ld_tranlabel 
        on ld_field.fieldid = ld_tranlabel.relateid 
        where ld_tranlabel.languagetype=? and trantable=? and ld_tranlabel.tabid in (select tabid from ld_tab where name = 'Leads') and uitype in (11,1101,1102) and ld_field.presence<>1
        order by ld_field.tabid desc,ld_field.block asc,ld_field.sequence asc ";
$leadsSQL_result = $adb->pquery($leadsSQL,array($languageType,'ld_field'));
$leadsSQL_Num=$adb->num_rows($leadsSQL_result);
$idsLead = '';
if($leadsSQL_Num){
    for($i=0;$i<$leadsSQL_Num;$i++){
        $fieldid = $adb->query_result($leadsSQL_result,$i,'fieldid');
        $arrLead[$fieldid] = $adb->query_result($leadsSQL_result,$i,'fieldlabel');
        if($adb->query_result($leadsSQL_result,$i,'callchecked') == '1')
        {
            $idsLead .= $fieldid.',';
        }
    }
}

$idsLeadArr = explode(",", $idsLead);

$arrLeads = get_select_options_array($arrLead, $idsLeadArr);
$smarty->assign("LEADSRESULTLIST", $arrLeads);


//客户
$accountsSQL = "select ld_field.fieldid,ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename,ld_field.callchecked 
        from ld_field inner join ld_tranlabel 
        on ld_field.fieldid = ld_tranlabel.relateid 
        where ld_tranlabel.languagetype=? and trantable=? and ld_tranlabel.tabid=6  and ld_field.tabid=6 and ld_field.savedatabase='yes' and  uitype in (11,1101,1102) and ld_field.presence<>1
         AND ld_field.tablename<>'ld_contactdetails'
        order by ld_field.tabid desc,ld_field.block asc,ld_field.sequence asc ";
/* editor : gyq_11  reason:按照对应模块字段block,sequence的顺序排序显示,客户模块可选字段应该去掉首先联系人字段：tablename<>'ld_contactdetails' date:20160509*/
$accountsSQL_result = $adb->pquery($accountsSQL,array($languageType,'ld_field'));
$accountsSQL_Num=$adb->num_rows($accountsSQL_result);
$idsAccount = '';
if($accountsSQL_Num){
    for($i=0;$i<$accountsSQL_Num;$i++){
        $fieldid = $adb->query_result($accountsSQL_result,$i,'fieldid');
        $arrAccount[$fieldid] = $adb->query_result($accountsSQL_result,$i,'fieldlabel');
        if($adb->query_result($accountsSQL_result,$i,'callchecked') == '1')
        {
            $idsAccount .= $fieldid.',';
        }
    }
}

$idsAccountArr = explode(",", $idsAccount);

$arrAccounts = get_select_options_array($arrAccount, $idsAccountArr);
$smarty->assign("ACCOUNTRESULTLIST", $arrAccounts);


//联系人
$contactsSQL = "select ld_field.fieldid,ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename,ld_field.callchecked  
        from ld_field inner join ld_tranlabel 
        on ld_field.fieldid = ld_tranlabel.relateid 
        where ld_tranlabel.languagetype=? and trantable=? and ld_tranlabel.tabid=4  and ld_field.tabid=4 and ld_field.savedatabase='yes' and uitype in (11,1101,1102) and ld_field.presence<>1
        order by ld_field.tabid desc,ld_field.block asc,ld_field.sequence asc ";
$contactsSQL_result = $adb->pquery($contactsSQL,array($languageType,'ld_field'));
$contactsSQL_Num=$adb->num_rows($contactsSQL_result);
$idsContacts = '';
if($contactsSQL_Num){
    for($i=0;$i<$contactsSQL_Num;$i++){
        $fieldid = $adb->query_result($contactsSQL_result,$i,'fieldid');
        $arrContact[$fieldid] = $adb->query_result($contactsSQL_result,$i,'fieldlabel');
        if($adb->query_result($contactsSQL_result,$i,'callchecked') == '1')
        {
            $idsContacts .= $fieldid.',';
        }
    }
}
$idsContactsArr = explode(",", $idsContacts); 
$arrContacts = get_select_options_array($arrContact, $idsContactsArr);
$smarty->assign("CONTACTSRESULTLIST", $arrContacts);
//销售机会
$potentialSQL = "select ld_field.fieldid,ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename,ld_field.callchecked  
        from ld_field inner join ld_tranlabel 
        on ld_field.fieldid = ld_tranlabel.relateid 
        where ld_tranlabel.languagetype=? and trantable=? and ld_tranlabel.tabid=2 and uitype in (11,1101,1102) and ld_field.presence<>1
        order by ld_field.tabid desc,ld_field.block asc,ld_field.sequence asc ";
$potentialSQL_result = $adb->pquery($potentialSQL,array($languageType,'ld_field'));
$potentialSQL_Num=$adb->num_rows($potentialSQL_result);
$idsPotential = '';
if($potentialSQL_Num){
    for($i=0;$i<$potentialSQL_Num;$i++){
        $fieldid = $adb->query_result($potentialSQL_result,$i,'fieldid');
        $arrPotential[$fieldid] = $adb->query_result($potentialSQL_result,$i,'fieldlabel');
        if($adb->query_result($potentialSQL_result,$i,'callchecked') == '1')
        {
            $idsPotential .= $fieldid.',';
        }
    }
}
$idsPotentialArr = explode(",", $idsPotential);
$arrPotentials = get_select_options_array($arrPotential, $idsPotentialArr);
$smarty->assign("POTENTIALSRESULTLIST", $arrPotentials);
//供应商
$vendorsSQL = "select ld_field.fieldid,ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename,ld_field.callchecked  
        from ld_field inner join ld_tranlabel 
        on ld_field.fieldid = ld_tranlabel.relateid 
        where ld_tranlabel.languagetype=? and trantable=?  and  ld_field.savedatabase='yes'  and ld_tranlabel.tabid in (select tabid from ld_tab where name = 'Vendors')
        and uitype in (11,1101,1102) and ld_field.presence<>1 order by ld_field.tabid desc,ld_field.block asc,ld_field.sequence asc ";
$vendorsSQL_result = $adb->pquery($vendorsSQL,array($languageType,'ld_field'));
$vendorsSQL_Num=$adb->num_rows($vendorsSQL_result);
$idsVendors = '';
if($vendorsSQL_Num){
    for($i=0;$i<$vendorsSQL_Num;$i++){
        $fieldid = $adb->query_result($vendorsSQL_result,$i,'fieldid');
        $arrVendor[$fieldid] = $adb->query_result($vendorsSQL_result,$i,'fieldlabel');
        if($adb->query_result($vendorsSQL_result,$i,'callchecked') == '1')
        {
            $idsVendors .= $fieldid.',';
        }
    }
}
$idsVendorsArr = explode(",", $idsVendors); 
$arrVendors = get_select_options_array($arrVendor, $idsVendorsArr);
$smarty->assign("VENDORSRESULTLIST", $arrVendors);
//供应商联系人
$vendorContactSQL = "select ld_field.fieldid,ld_field.tabid,ld_tranlabel.fieldlabel,ld_field.tablename,ld_field.callchecked  
        from ld_field inner join ld_tranlabel 
        on ld_field.fieldid = ld_tranlabel.relateid 
        where ld_tranlabel.languagetype=? and trantable=? and  ld_field.savedatabase='yes' and ld_tranlabel.tabid in (select tabid from ld_tab where name = 'VendorContact')
        and uitype in (11,1101,1102) and ld_field.presence<>1 order by ld_field.tabid desc,ld_field.block asc,ld_field.sequence asc ";
$vendorContactSQL_result = $adb->pquery($vendorContactSQL,array($languageType,'ld_field'));
$vendorContactSQL_Num=$adb->num_rows($vendorContactSQL_result);
$idsVendorContacts = '';
if($vendorContactSQL_Num){
    for($i=0;$i<$vendorContactSQL_Num;$i++){
        $fieldid = $adb->query_result($vendorContactSQL_result,$i,'fieldid');
        $arrvendorContact[$fieldid] = $adb->query_result($vendorContactSQL_result,$i,'fieldlabel');
        if($adb->query_result($vendorContactSQL_result,$i,'callchecked') == '1')
        {
            $idsVendorContacts .= $fieldid.',';
        }
    }
}
$idsVendorContactsArr = explode(",", $idsVendorContacts); 
$arrvendorContacts = get_select_options_array($arrvendorContact, $idsVendorContactsArr);
$smarty->assign("VENDORCONTACTSRESULTLIST", $arrvendorContacts);


$deployarray=getSys_deploy(55);//呼叫中心类型
$smarty->assign("CALLCENTERVALUE", $deployarray['deploy_value']??'');
$regop=RegOp::getInstance();
$callcenter_interface=$regop->GetcallcenterInterfaceStatus();
//$callcenter_interface=1;//editor:gyq_69X reason:帮我吧呼叫中心 2018/6/7 17:19
if($callcenter_interface==1)   
{
        $deployarray=getSys_deploy(76);//软拨号自动加拨前缀
        $smarty->assign('INTERFACENUM',$deployarray['deploy_value']);


        /* gyq_11 新增呼叫中心地址，仅用于九维*/
        $deployarray = getSys_deploy(101);
        $php52 = getSys_deploy(107);
        $deployarray3 = getSys_deploy(121);
        $htrelvalue = getSys_deploy(160);
        $deployarray2 = $php52['deploy_value'];
        $jiuwei_deployvalue = explode(',',$deployarray['deploy_value']);//gyq_25 date:20170209

        $sopho_deployvalue = explode(',',$deployarray2);
        $smarty->assign('JIUWEIURL', $jiuwei_deployvalue[0]);
        $smarty->assign('JIUWEIPREFIX', $jiuwei_deployvalue[1]);
        $smarty->assign('JIUWEIURL_sopho', $sopho_deployvalue[0]);
        $smarty->assign('JIUWEIURL_sopho2', $sopho_deployvalue[1]);
        $smarty->assign('HANTIANRELVALUE',$htrelvalue['deploy_value']);
        $smarty->assign('HANTIANURL',$deployarray3['deploy_value']);

        // @edit:dong @date:2020/09/02 @reason: 天润融通 呼叫中心
    // @edit:dong @date:2020/09/02 @reason: 添加天润融通旧
        $deployarray=getSys_deploy(261);
        $smarty->assign('TIANRUNENTERPRISEIDVALUE',$deployarray['deploy_value']);
        $deployarray=getSys_deploy(262);
        $smarty->assign('TIANRUNZHANGHAOVALUE', $deployarray['deploy_value']);
        $deployarray=getSys_deploy(263);
        $smarty->assign('TIANRUNPASSWORDVALUE', $deployarray['deploy_value']);

        // @edit:dong @date:2020/11/11 @reason: 天润融通新
        $deployarray=getSys_deploy(264);
        $smarty->assign('NEWTIANRUNURLVALUE',$deployarray['deploy_value']);
        $deployarray=getSys_deploy(265);
        $smarty->assign('NEWTIANRUNKEYIDVALUE', $deployarray['deploy_value']);
        $deployarray=getSys_deploy(266);
        $smarty->assign('NEWTIANRUNSECRETVALUE', $deployarray['deploy_value']);
    
}  




$fieldlabel = getTranslabelSystems(101);
$smarty->assign('JIUWEIURLNAME', $fieldlabel);

$fieldlabel = getTranslabelSystems(107);
$smarty->assign('JIUWEIURLNAME_sopho', $fieldlabel);

$fieldlabel = getTranslabelSystems(121);
$smarty->assign('HANTIANURLNAME', $fieldlabel);

$fieldlabel = getTranslabelSystems(160);
$smarty->assign('HANTIANRELATENAME', $fieldlabel);

// @edit:dong @date:2020/09/02 @reason: 添加天润融通旧
$fieldlabel = getTranslabelSystems(261);
$smarty->assign('TIANRUNENTERPRISEID', $fieldlabel);

$fieldlabel = getTranslabelSystems(262);
$smarty->assign('TIANRUNZHANGHAO', $fieldlabel);

$fieldlabel = getTranslabelSystems(263);
$smarty->assign('TIANRUNPASSWORD', $fieldlabel);


$fieldlabel = getTranslabelSystems(264);
$smarty->assign('NEWTIANRUNINTERFACEADDRESS', $fieldlabel);
$fieldlabel = getTranslabelSystems(265);
$smarty->assign('NEWTIANRUNACCESSKEYID', $fieldlabel);
$fieldlabel = getTranslabelSystems(266);
$smarty->assign('NEWTIANRUNSECRET', $fieldlabel);

/**
 * 呼叫中心参数中，添加汉天EC2
 * @project PROT190 汉天呼叫中心接口
 * @author Tujt 2015-03-30
 */
if($callcenter_interface==1)
    //editor:gyq_69 reason:帮我吧呼叫中心 2018/6/6 9:44
    // @edit:dong @date:2020/09/07 @reason:  天润融通旧
    // @edit:dong @date:2020/11/11 @reason: 天润融通新
    $callcentertype = array('灵当语音盒','电话录音盒','三汇板卡','天润融通旧','天润融通新','汉天EC2','苏州九维','苏州思孚','帮我吧');
else
    $callcentertype = array('灵当语音盒','电话录音盒');
$smarty->assign("CALLCENTERTYPE", $callcentertype);

//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH",$image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('LBL_PHONESTEWARD_SET');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("Settings/EditPhoneSteward.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>