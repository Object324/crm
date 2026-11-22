<!--**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ***********************************************************************************-->
<!--修改编码格式:统一编码：UTF-8-->
<div id='mm_selected_folder'></div>
<div id="_folderdiv_">{include file="modules/MailManager/Folder.List.tpl"}</div>
<input type="hidden" name="refresh_timeout" id="refresh_timeout" value="{$MAILBOX->refreshTimeOut()}"/>