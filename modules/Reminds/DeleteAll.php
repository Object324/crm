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



$viewid = vtlib_purify($_REQUEST['viewname']);
$returnmodule = vtlib_purify($_REQUEST['return_module']);
$return_action = vtlib_purify($_REQUEST['return_action']);
$rstart='';
//Added to fix 4600


//split the string and store in an array

$ids_list = array();
$errormsg = '';

$focus = CRMEntity::getInstance('Reminds');
ClearAll($viewid);
function ClearAll($viewid){
        
        global $current_user,$adb;
        $date=date('Y-m-d H:i');
        if($viewid==108){
            $adb->pquery("update ld_reminds set is_del_rec=1  WHERE status_rmd='未读' AND recieverid=".$current_user->id ." and date_time<='".$date."' and is_del_rec=0");
            $adb->pquery("update ld_reminds_accepted set is_del_rec=1  WHERE status_rmd='未读' AND recieverid=".$current_user->id ." and date_time<='".$date."' and is_del_rec=0");
            
        }else if($viewid==114){
            $adb->pquery("update ld_reminds set is_del_rec=1 WHERE status_rmd='已读' AND recieverid=".$current_user->id ." and is_del_rec=0");
            $adb->pquery("update ld_reminds_accepted set is_del_rec=1 WHERE status_rmd='已读' AND recieverid=".$current_user->id ." and is_del_rec=0");
            
        }else if($viewid==115){
            $adb->pquery("update ld_reminds,ld_crmentity  set is_del_send=1  WHERE ld_reminds.remindsid=crmid and smcreatorid=".$current_user->id ." and ld_reminds.is_del_send=0");
            $adb->pquery("update ld_reminds_accepted,ld_crmentity  set is_del_send=1  WHERE ld_reminds.remindsid=crmid and smcreatorid=".$current_user->id ." and ld_reminds.is_del_send=0");
            
        }
    }
	header("Location: index.php?module=".$returnmodule."&action=".$returnmodule."Ajax&ajax=deleteAll&file=ListView&viewname=".$viewid."&errormsg=".$errormsg);

?>