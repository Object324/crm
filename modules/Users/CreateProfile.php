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



global $mod_strings,$adb;
$profilename=vtlib_purify($_REQUEST['profile_name']);
if(isset($_REQUEST['dup_check']) && $_REQUEST['dup_check']!='')
{
      if($_REQUEST['profileid']!='')
      {
            $profileId=$_REQUEST['profileid'];
            $query="select 1 from ld_profile where profilename=? and profileid!=?";
            $result = $adb->pquery($query, array($profilename,$profileId));

            if($adb->num_rows($result) > 0)
            {
                    echo getFixedLabel('LBL_ROLENAME_EXIST');
                    die;
            }else
            {
                    echo 'SUCCESS';
                    die;
            }
        
      }
      else 
      {
            $query="select 1 from ld_profile where profilename=? ";
            $result = $adb->pquery($query, array($profilename));
            if($adb->num_rows($result) > 0)
            {
                    echo getFixedLabel('LBL_ROLENAME_EXIST');
                    die;
            }else
            {
                    echo 'SUCCESS';
                    die;
            }
      }
        

}
?>