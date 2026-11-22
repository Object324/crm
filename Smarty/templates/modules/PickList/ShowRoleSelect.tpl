{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<b>{'ADDOTHERROLEPICK'|@getFixedLabel}</b><br>
<select multiple id="roleselect" name="roleselect" class="crmFormList" style="overflow:auto; height: 80px;width:200px;border:1px solid #666666;font-family:Arial, Helvetica, sans-serif;font-size:12px;">
	{foreach item=rolename key=roleid from=$ROLES}
		<option value="{$roleid}">{$rolename}</option>
	{/foreach}
</select>