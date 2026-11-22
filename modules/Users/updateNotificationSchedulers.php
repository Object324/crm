<?php


/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/




/**
 *
 *  File to update the notification schedulers in the db
 *
 */


global $adb;
$flag=0;
//pass the lingdang_table id as a parameter and then update directly instead of using the name lingdang_field 
for ($i=1;$i<10;$i++)
{
  if($_POST[$i] == 'on')
  {
    $flag=1;
  }
  else
  {
    $flag=0;
  }
 $sql = "update ld_notificationscheduler set active=?  where schedulednotificationid=?"; 
 $adb->pquery($sql, array($flag, $i));
}

header("Location:index.php?module=Users&action=listnotificationschedulers");





?>