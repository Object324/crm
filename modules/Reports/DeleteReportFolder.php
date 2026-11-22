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
require_once('include/logging.php');
require_once('include/database/PearDatabase.php');

global $adb,$mod_strings;


$rfid = vtlib_purify($_REQUEST['record']);
if($rfid != "")
{
	$records_in_folder = $adb->pquery("SELECT * from ld_report WHERE folderid=?",array($rfid));
	if($adb->num_rows($records_in_folder)>0){
		echo getTranslatedString('LBL_FLDR_NOT_EMPTY',"Reports");
	} else {
		$sql .= "delete from ld_reportfolder where folderid=?";
		$result = $adb->pquery($sql, array($rfid));
		if($result!=false)
        {
                $pquery = "delete from ld_report where folderid=?";
                $res = $adb->pquery($pquery, array($rfid));
                if ($res != "")
                        header("Location: index.php?action=ReportsAjax&mode=ajax&file=ListView&module=Reports");
                else {
                        include('modules/lingdang/header.php');
                        $errormessage = "<font color='red'><B>Error Message<ul>
                        <li><font color='red'>Error while deleting the reports of the folder</font>
                        </ul></B></font> <br>" ;
                        echo $errormessage;
                }
        }else
        {
                include('modules/lingdang/header.php');
                $errormessage = "<font color='red'><B>Error Message<ul>
                <li><font color='red'>Error while deleting the folder</font>
                </ul></B></font> <br>" ;
                echo $errormessage;
        }
	}
}
  	
?>