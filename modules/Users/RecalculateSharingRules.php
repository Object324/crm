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
global $php_max_execution_time;
//set_time_limit($php_max_execution_time);
//RecalculateSharingRules();
//清空缓存
clearCacheFiles();
clearMinifyFiles();
clearSmartyFiles();
clearDefaultFile();

header("Location: index.php?action=OrgSharingDetailView&parenttab=Settings&module=Settings&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting']);
?>