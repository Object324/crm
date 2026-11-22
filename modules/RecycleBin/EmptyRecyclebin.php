<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 *** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 ** ("License"); You may not use this file except in compliance with the License
 ** The Original Code is:  lingdang CRM Open Source
 ** The Initial Developer of the Original Code is lingdang.
 ** Portions created by lingdang are Copyright (C) lingdang.
 ** All Rights Reserved.
 **
 *********************************************************************************/

global $adb;
/*
edit:can
date:20130423
reason:解决清空回收站没有删除报价单表里的已删除数据
*/
$adb->query('delete from ld_quotes where quoteid in(select crmid from ld_crmentity where deleted=1 and setype="quotes" )');

$adb->query('delete from ld_Salesorder where salesorderid in(select crmid from ld_crmentity where deleted=1 and setype="salesorder")');


$adb->query('DELETE FROM ld_crmentity WHERE deleted = 1');
//TODO Related records for the module records deleted from lingdang_crmentity has to be deleted. 
//It needs lookup in the related tables and needs to be removed if doesn't have a reference record in lingdang_crmentity
 
$adb->query('DELETE FROM ld_relatedlists_rb');

$parenttab = getParentTab();

header("Location: index.php?module=RecycleBin&action=RecycleBinAjax&file=index&parenttab=$parenttab&mode=ajax");
?>
