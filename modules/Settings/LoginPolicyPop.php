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
require_once('modules/Users/Profile.class.php');


include('ActionLabel.php');
global $app_strings;
global $mod_strings;
global $current_user, $currentModule;
global $adb;
global $theme;
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";

$smarty = new lingdangCRM_Smarty;
$mode = $_REQUEST['mode'];
$ruleid = $_REQUEST['ruleid'];

function get_picklist_dependency($sourcefield,$targetfield,$tabid='') {
    global $adb;
    $sql = "SELECT * FROM ld_picklist_dependency where tabid = ? and sourcefield = ? and targetfield = ?";
    $result = $adb->pquery($sql, array($tabid,$sourcefield,$targetfield));
    $num_rows = $adb->num_rows($result);
    $searchinfo = [];
    if ($num_rows >= 1) {
        for($i = 0; $i<$num_rows; $i++){
            $sourcevalue = $adb->query_result($result, $i, 'sourcevalue');
            $targetvalues = $adb->query_result($result, $i, 'targetvalues');
            $searchinfo[$sourcevalue] = Zend_Json::decode(html_entity_decode($targetvalues));
        }
    }
    return $searchinfo;
}
$tabid = getTabid('Accounts');

//读取中国的省份
$sql_chinastatus = "SELECT * from ld_picklist_dependency where sourcefield = 'bill_country' and tabid = '6'  and targetfield = 'bill_state' and sourcevalue = '中国'";
$result = $adb->pquery($sql_chinastatus, array());
if($adb->num_rows($result)>0)
{
    $sourcevalue_chinastatus = $adb->query_result($result, 0, 'targetvalues');
    $sourcevalue_chinastatus = ldcrm_json_decode(html_entity_decode($sourcevalue_chinastatus));
}

$sql = "SELECT * FROM ld_picklist_dependency where tabid = '6' and sourcefield = 'bill_state' and targetfield = 'bill_city'";
$result = $adb->pquery($sql, array());
$num_rows = $adb->num_rows($result);
$sourcevalue = [];
if ($num_rows >= 1) {
    for($i = 0; $i<$num_rows; $i++){
        $tmp_source = $adb->query_result($result, $i, 'sourcevalue');
        if(is_array($sourcevalue_chinastatus)&& in_array($tmp_source,$sourcevalue_chinastatus)){
            $sourcevalue[$i] = $tmp_source;
            $targetvalue[$i] = $adb->query_result($result, $i, 'targetvalues');
        }
    }
}
// $sourcevalue = array_unshift($sourcevalue,"");
$Region_arr = get_picklist_dependency('bill_state','bill_city','6');
$smarty->assign('sourcevalue',$sourcevalue);
$smarty->assign('targetvalue',$targetvalue);
$smarty->assign('Region_arr',$Region_arr);

if($ruleid >0){
    $sql = "SELECT * from ld_loginpolicy where ruleid = ? ";
    $result = $adb->pquery($sql,[$ruleid]);
    $rulename = $adb->query_result($result,0,'rulename');
    $ruletype = $adb->query_result($result,0,'ruletype');
    $controlmode = $adb->query_result($result,0,'controlmode');
    $enablestatus = $adb->query_result($result,0,'enablestatus');
    $description = $adb->query_result($result,0,'description');
    $typecontent = (string)$adb->query_result($result,0,'typecontent');
    $statusvalue = (string)$adb->query_result($result,0,'statusvalue');
    $applicablescope = $adb->query_result($result,0,'applicablescope');

    $smarty->assign('mode',$mode);
    $smarty->assign('ruletype',$ruletype);
    $smarty->assign('rulename',$rulename);
    $smarty->assign('ruleid',$ruleid);
    $smarty->assign('controlmode',$controlmode);
    $smarty->assign('enablestatus',$enablestatus);
    $smarty->assign('description',$description);
    $typecontent = explode(',',$typecontent);
    // dump($typecontent_arr);
    $statusvalue = explode(',',$statusvalue);
    $typecontent_arr['typecontent'] = $typecontent;
    $typecontent_arr['statusvalue'] = $statusvalue;
    $smarty->assign('typecontent_arr',$typecontent_arr);
    $smarty->assign('applicablescope',$applicablescope);
    // dump($typecontent_arr);
    // $smarty->assign('statusvalue_arr',$statusvalue_arr);
    $sql_user = "SELECT * from ld_loginpolicy_user where ruleid = ? ";
    $user_result = $adb->pquery($sql_user,[$ruleid]);
    $num_rows = $adb->num_rows($user_result);
    $allocateid = [];
    for($i=0;$i<$num_rows;$i++){
        $allocateid[$i] = $adb->query_result($user_result,$i,'userid');
    }
    $allocateid = implode(',',$allocateid);
    $smarty->assign('allocateid',$allocateid);

    // if($ruletype == 'MACaddress'){
    //     $sql = "SELECT * from ld_loginpolicy_mapping where ruleid = ? and mapping_type = ?";
    //     $result = $adb->pquery($sql,[$ruleid,'MAC']);
    //     $num_rows = $adb->num_rows($result);
    //     $mac_arr = [];
    //     if ($num_rows >= 1) {
    //         for($i=0;$i<$num_rows;$i++){
    //             $mac_arr['username'] = $adb->query_result($result,0,'user_name');
    //             $mac_arr['lastname'] = $adb->query_result($result,0,'last_name');
    //             $mac_arr['MacContent'] = $adb->query_result($result,0,'typecontent');
    //         }
    //     }
    // }
    // dump($mac_arr);
}

function getIp() {
    //strcasecmp 比较两个字符，不区分大小写。返回0，>0，<0。
    if (getenv('HTTP_CLIENT_IP') && strcasecmp(getenv('HTTP_CLIENT_IP'), 'unknown')) {
        $ip = getenv('HTTP_CLIENT_IP');
    } else if (getenv('HTTP_X_FORWARDED_FOR') && strcasecmp(getenv('HTTP_X_FORWARDED_FOR'), 'unknown')) {
        $ip = getenv('HTTP_X_FORWARDED_FOR');
    } else if (getenv('REMOTE_ADDR') && strcasecmp(getenv('REMOTE_ADDR'), 'unknown')) {
        $ip = getenv('REMOTE_ADDR');
    } else if (isset($_SERVER['REMOTE_ADDR']) && $_SERVER['REMOTE_ADDR'] && strcasecmp($_SERVER['REMOTE_ADDR'], 'unknown')) {
        $ip = $_SERVER['REMOTE_ADDR'];
    }
    $res =  preg_match ( '/[\d\.]{7,15}/', $ip, $matches ) ? $matches [0] : '';
    return $res;
}
// function getMACAddress() {//获取mac地址
//     switch (PHP_OS_FAMILY) {
//         case 'Windows':
//             $mac = shell_exec('getmac');
//             $mac = explode("\n", $mac);
//             $mac_arr = []; 
//             foreach ($mac as $addr) {
//                 if (preg_match('/([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})/', $addr, $matches)) {
//                     $mac = $matches[0];
//                     $mac = str_replace('-', ':', $mac);
//                     $mac_arr[] = $mac;
//                 }
//             }
//             return $mac_arr;

//         case 'Linux':
//             $mac = shell_exec('ifconfig -a | grep -o -E "([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}"');
//             return strtok($mac, "\n");

//         default:
//             return false;
//     }
// }
// $mac = getMACAddress();
// $mac = iconv('gb2312','utf-8',$mac);
// dump($mac);
if ($mode == 'allocate') {
    $arr['title'] = getFixedLabel("ALLOCATE");
    $allocatePopup = 'yes';
} else {
    $allocatePopup = 'no';
}
$smarty->assign('allocatePopup',$allocatePopup);
$str = $smarty->fetch("LoginPolicyPop.tpl");
$myIP = getIP();
$arr['myip'] = $myIP;
$arr['content'] = $str;
$arr['title'] = getFixedLabel('LOGINPOLICY');
if ($mode == 'allocate') {
    $arr['title'] = getFixedLabel("ALLOCATE");
}
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['region_arr'] = $Region_arr;
$arr['sourcevalue'] = $sourcevalue;
$arr['applicablescope'] = $applicablescope;
$arr['allocateid'] = $allocateid;

ConvertTojsonString(1, $arr, "success");

exit();
?>