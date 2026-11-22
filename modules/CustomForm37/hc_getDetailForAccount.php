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

//lineitem_id
global $adb;
$versioninfo=getVersionInfo();
if($versioninfo['account']=='huacanguangdian' && $_REQUEST['accountid'] > 0){
    $sql_next = 'select lineitem_id from ld_customform37detail INNER JOIN ld_customform37 on ld_customform37detail.id = ld_customform37.customform37id where ld_customform37.accountid = ? and ld_customform37.deleted = 0;';
    $result_next = $adb->pquery($sql_next,array($_REQUEST['accountid']));
    $lineitem_id = [];
    if($adb->num_rows($result_next) > 0){
        for($i=0;$i<$adb->num_rows($result_next);$i++){
            $lineitem_id[] = $adb->query_result($result_next,$i,'lineitem_id');
        }
    }
    $arr['lineitem_id_list'] = $lineitem_id;
    ConvertTojsonString(1,$arr,"success");
}


?>