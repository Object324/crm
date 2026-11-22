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


$smarty = new lingdangCRM_Smarty;
global $adb;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

function getColumnname($fieldid)
{
    global $adb;
    $query="select columnname from ld_field where fieldid = $fieldid ";
    $result=$adb->query($query);
    $columnname = $adb->query_result($result, 0, 'columnname');
    return $columnname;
}

$ids = '';
//zkt 20220510 【ID1002802】【电话录音盒和灵当语音盒，增加销售线索来电和去电匹配字段（郭惠宇-亿海蓝）】
if($_REQUEST['idLeads']&&$_REQUEST['idLeads']!='undefined')
{
    $idLeads=$_REQUEST['idLeads'];
    $idLeads = $idLeads . ',';
    $ids = $ids.$idLeads;
}
if($_REQUEST['idAccounts']&&$_REQUEST['idAccounts']!='undefined')
{
    $idAccounts=$_REQUEST['idAccounts'];
    $idAccounts = $idAccounts . ',';
    $ids = $ids.$idAccounts;
}
if($_REQUEST['idContacts']&&$_REQUEST['idContacts']!='undefined')
{
    $idContacts=$_REQUEST['idContacts'];
    $idContacts = $idContacts . ',';
    $ids = $ids.$idContacts;
}
//editor:gyq_76 reason:呼叫中心来电弹屏增加创建销售机会 2018/8/23 13:27
if($_REQUEST['idPotentials']&&$_REQUEST['idPotentials']!='undefined')
{
    $idContacts=$_REQUEST['idPotentials'];
    $idContacts = $idContacts . ',';
    $ids = $ids.$idContacts;
}
if($_REQUEST['idVendors']&&$_REQUEST['idVendors']!='undefined')
{
    $idVendors=$_REQUEST['idVendors'];
    $idVendors = $idVendors . ',';
    $ids = $ids.$idVendors;
}
if($_REQUEST['idVendorContact']&&$_REQUEST['idVendorContact']!='undefined')
{
    $idVendorContact=$_REQUEST['idVendorContact'];
    $idVendorContact = $idVendorContact . ',';
    $ids = $ids.$idVendorContact;
}

if($_REQUEST['interfaceType'])
{
    $interfaceType=$_REQUEST['interfaceType'];
}

$ids = substr($ids, 0, strlen($ids)-1);

$query="update ld_field set callchecked=0 where fieldid > 0 ";

$result=$adb->query($query);

$query="update ld_field set callchecked=1 where fieldid in ($ids) ";

$result=$adb->query($query);
if($_REQUEST['interfaceType']=='电话录音盒')
{
    /*if(empty($idAccounts))
    {
        $query="update ld_relatedlists set presence = 1 where  tabid=6 and label ='CallButler' and name = 'get_CallButler' ";
        $result=$adb->query($query);
    }
    if(empty($idContacts))
    {
         $query="update ld_relatedlists set presence = 1 where  tabid=4 and label ='CallButler' and name = 'get_CallButler' ";
        $result=$adb->query($query);
    }
    if(empty($idVendors))
    {
        $query="update ld_relatedlists set presence = 1 where  tabid=(select tabid from ld_tab where name=?)  and label ='CallButler' and name = 'get_CallButler' ";
        $result=$adb->pquery($query,array('Vendors'));
    }*/
    
    
    $query="update ld_relatedlists set presence = 0 where label ='CallButler' and name = 'get_CallButler' ";
}
else//26398: 电话小管家 把呼叫中心参数关闭后，供应商联系记录相关信息还显示通话记录。
    $query="update ld_relatedlists set presence = 1 where label ='CallButler' and name = 'get_CallButler' ";
$result=$adb->query($query);


$query="update ld_systems_deploy set deploy_value = '$interfaceType' where deploy_type = 55 ";

$result=$adb->query($query);

//电话录音盒 软拨号自动加拨前缀
if(!empty($_REQUEST['numinterface']) && $interfaceType == '电话录音盒'){
	$numinterface = $_REQUEST['numinterface'];
	$adb->pquery('update ld_systems_deploy set deploy_value = ? where deploy_type = ?',array($numinterface,76));
}
/*
 * edito:gyq_11
 * reason: 仅当呼叫中心参数设置为“苏州九维”时，用户面板显示九维坐席编号
 * date : 2016 05 09
 * */
if( $interfaceType == '苏州九维') {
    $adb->pquery('UPDATE ld_blocks SET visible=0 WHERE blocklabel = \'JW_INTERFACE_INFO\' AND tabid = 29');
    $adb->pquery('UPDATE ld_blocks SET visible=1 WHERE blocklabel = \'SOPHO_INTERFACE_INFO\' AND tabid = 29');
    $adb->pquery('UPDATE ld_blocks SET visible=1 WHERE blocklabel = \'HANTIAN_INTERFACE_INFO\' AND tabid = 29');
    $adb->pquery('UPDATE ld_blocks SET visible=1 WHERE blocklabel = \'TIANRUN_INTERFACE_INFO\' AND tabid = 29');
    $jiuweiurl = $_REQUEST['jiuweiurl'];
    $jiuweiprefix = $_REQUEST['jiuweiprefix'];//gyq_25
    $adb->pquery('update ld_systems_deploy set deploy_value = ? where deploy_type = ?', array($jiuweiurl.','.$jiuweiprefix, 101));
}else if($interfaceType == '苏州思孚'){
    $adb->pquery('UPDATE ld_blocks SET visible=0 WHERE blocklabel = \'SOPHO_INTERFACE_INFO\' AND tabid = 29');
    $adb->pquery('UPDATE ld_blocks SET visible=1 WHERE blocklabel = \'JW_INTERFACE_INFO\' AND tabid = 29');
    $adb->pquery('UPDATE ld_blocks SET visible=1 WHERE blocklabel = \'HANTIAN_INTERFACE_INFO\' AND tabid = 29');
    $adb->pquery('UPDATE ld_blocks SET visible=1 WHERE blocklabel = \'TIANRUN_INTERFACE_INFO\' AND tabid = 29');
    $jiuweiurl = $_REQUEST['sophourl'];
    $jiuweiurl2 = $_REQUEST['sophourl2'];

    $adb->pquery('update ld_systems_deploy set deploy_value = ? where deploy_type = ?', array($jiuweiurl.','.$jiuweiurl2, 107));
}else if($interfaceType == '汉天EC2') {
    $adb->pquery('UPDATE ld_blocks SET visible=0 WHERE blocklabel = \'HANTIAN_INTERFACE_INFO\' AND tabid = 29');
    $adb->pquery('UPDATE ld_blocks SET visible=1 WHERE blocklabel = \'SOPHO_INTERFACE_INFO\' AND tabid = 29');
    $adb->pquery('UPDATE ld_blocks SET visible=1 WHERE blocklabel = \'JW_INTERFACE_INFO\' AND tabid = 29');
    $adb->pquery('UPDATE ld_blocks SET visible=1 WHERE blocklabel = \'TIANRUN_INTERFACE_INFO\' AND tabid = 29');
    $hantianurl = $_REQUEST['hantianurl'];

    /* $hantian_file_url = $_REQUEST['hantian_file_url'];
     $adb->pquery('delete from ld_wx_config where name=\'record_file_url\'',array());
     $adb->pquery('insert into ld_wx_config (name, description, para_one) value (\'record_file_url\',\'呼叫中心录音文件地址\',?)',array($hantian_file_url));*/

    $adb->pquery('UPDATE ld_systems_deploy SET deploy_value = ? WHERE deploy_type = ?', array($hantianurl, 121));
    $htrelvalue = $_REQUEST['htrelvalue'] ? 0 : 1;
    $adb->pquery('UPDATE ld_systems_deploy SET deploy_value = ? WHERE deploy_type = ?', array($htrelvalue, 160));
}else if($interfaceType == '天润融通旧'){
    // @edit:dong @date:2020/09/02 @reason: 添加天润融通旧
    $adb->pquery("UPDATE ld_blocks SET visible=1 WHERE blocklabel in ('SOPHO_INTERFACE_INFO','JW_INTERFACE_INFO','HANTIAN_INTERFACE_INFO') AND tabid = 29");

    $adb->pquery('UPDATE ld_blocks SET visible=0 WHERE blocklabel = \'TIANRUN_INTERFACE_INFO\' AND tabid = 29');
    $enterpriseId = $_REQUEST['tianrun_enterpriseId'];
    $zhanghao = $_REQUEST['tianrun_zhanghao'];
    $password = $_REQUEST['tianrun_password'];
    $adb->pquery('update ld_systems_deploy set deploy_value = ? where deploy_type = ?', array($enterpriseId, 261));
    $adb->pquery('update ld_systems_deploy set deploy_value = ? where deploy_type = ?', array($zhanghao, 262));
    $adb->pquery('update ld_systems_deploy set deploy_value = ? where deploy_type = ?', array($password, 263));
}else if($interfaceType == '天润融通新'){
    // @edit:dong @date:2020/11/11 @reason: 天润融通新
    $adb->pquery("UPDATE ld_blocks SET visible=1 WHERE blocklabel in ('SOPHO_INTERFACE_INFO','JW_INTERFACE_INFO','HANTIAN_INTERFACE_INFO') AND tabid = 29");
    $adb->pquery('UPDATE ld_blocks SET visible=0 WHERE blocklabel = \'TIANRUN_INTERFACE_INFO\' AND tabid = 29');
    $newtianrun_address = vtlib_purify($_REQUEST['newtianrun_address']);
    $newtianrun_accesskeyid = vtlib_purify($_REQUEST['newtianrun_accesskeyid']);
    $newtianrun_secret = vtlib_purify($_REQUEST['newtianrun_secret']);
    $adb->pquery('update ld_systems_deploy set deploy_value = ? where deploy_type = ?', array($newtianrun_address, 264));
    $adb->pquery('update ld_systems_deploy set deploy_value = ? where deploy_type = ?', array($newtianrun_accesskeyid, 265));
    $adb->pquery('update ld_systems_deploy set deploy_value = ? where deploy_type = ?', array($newtianrun_secret, 266));
}else{
    $adb->pquery("UPDATE ld_blocks SET visible=1 WHERE blocklabel IN ('TIANRUN_INTERFACE_INFO','JW_INTERFACE_INFO','SOPHO_INTERFACE_INFO','HANTIAN_INTERFACE_INFO') AND tabid = 29");
}

//清除缓存，电话管家是否显示
$cachekey = 'cache_getcallLinkDisplay';
unsetCache($cachekey);
$cachekey = 'cache_get_callcenter_type';
unsetCache($cachekey);

getSys_deploy('aa');//17917: 升级帐套：控制面板>呼叫中心参数：缺少【软拨号自动加拨前缀】，接口类型值也无法保存成功
//异步清除缓存
f_sockopen('modules.Cache.unsetCache','ajax=true');
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array(),"success");
?>