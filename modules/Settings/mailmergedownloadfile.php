<?php
/********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
* 
 ********************************************************************************/

require_once('config.php');
require_once('include/database/PearDatabase.php');

global $fileId, $default_charset;

$templateid = $_REQUEST['record'];
$dbQuery = "SELECT filename,filetype, data ";
$dbQuery .= "FROM ld_wordtemplates ";
$dbQuery .= "WHERE templateid=?";

$result = $adb->pquery($dbQuery, array($templateid)) or die("Couldn't get file list");
if($adb->num_rows($result) == 1)
{
$fileType = $adb->query_result($result, 0, "filetype");
$name = $adb->query_result($result, 0, "filename");
$encoded_filename = urlencode($name);

$encoded_filename = str_replace("+", "%20", $encoded_filename);
$ua = $_SERVER["HTTP_USER_AGENT"];

//echo 'filetype is ' .$fileType;
$fileContent = $adb->query_result($result, 0, "data");
$size = $adb->query_result($result, 0, "filesize");
//$name = html_entity_decode($name, ENT_QUOTES, $default_charset);
header("Content-type: ".$fileType );
//header("Content-length: $size");
header("Cache-Control: private");
if (preg_match("/MSIE/", $ua)) {

header('Content-Disposition: attachment; filename="'.$encoded_filename.'"');
}
else if (preg_match("/Firefox/", $ua)) {

    header('Content-Disposition: attachment; filename*="utf8\'\'' . $name . '"');

} else {

    header('Content-Disposition: attachment; filename="' . $name . '"');

}



//header('Content-Disposition: attachment; filename*="utf8\'\'' . $name . '"');
 

header("Content-Description: PHP Generated Data");

echo base64_decode($fileContent);
}
else
{
echo "Record doesn't exist.";
}
?>
