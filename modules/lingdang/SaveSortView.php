<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/

global $mod_strings,$app_strings,$theme,$currentModule,$current_user;
global $adb;

require_once('Smarty_setup.php');
require_once('include/utils/utils.php');

$curr_viewid=$_REQUEST['curr_viewid'];
$new_viewid=$_REQUEST['new_viewid'];

$ssql = 'select cvid,sequence from ld_customview where entitytype = ? and cvid = ?';
$curr_params = array($currentModule,$curr_viewid);
$curr_result = $adb->pquery($ssql, $curr_params);
$curr_sequence = $adb->query_result($curr_result,0,'sequence');

$new_params = array($currentModule,$new_viewid);
$new_result = $adb->pquery($ssql, $new_params);
$new_sequence = $adb->query_result($new_result,0,'sequence');

$sql = 'update ld_customview set sequence = ? where cvid = ?';
if($currentModule=='Accounts'){
    $sql .= ' and customcategory = ?';    
}
if($currentModule=='Accounts'){
    $pagepublicaccounttype = $_SESSION['lvsAccount'][getTabModuleName($tabid)]['pagepublicaccounttype'];
    if(empty($pagepublicaccounttype)){
        $customcategory = 'ALLACCOUNT';
    }
    else{
        $customcategory = $pagepublicaccounttype;
    }       
    $adb->pquery($sql,array($new_sequence,$curr_viewid,$customcategory));
    $adb->pquery($sql,array($curr_sequence,$new_viewid,$customcategory));    
}
else{
    $adb->pquery($sql,array($new_sequence,$curr_viewid));
    $adb->pquery($sql,array($curr_sequence,$new_viewid));
}
unsetCacheDirectory('customview');
?>