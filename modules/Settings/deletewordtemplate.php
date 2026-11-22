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

$idlist = $_REQUEST['idlist'];
$id_array=explode(';', $idlist);

for($i=0; $i < count($id_array)-1; $i++) {
	$sql = "delete from ld_wordtemplates where templateid=?";
	$adb->pquery($sql, array($id_array[$i]));
}

header("Location:index.php?module=Settings&action=listwordtemplates&parenttab=Settings");

?>