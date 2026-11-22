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
<table width="100%" cellpadding="5" cellspacing="0" class="listTable" >
	<tr>
	<td class="colHeader" width="30%" nowrap="nowrap">{$CMOD.LBL_PROVIDER}</td>
	<td class="colHeader" width="25%" nowrap="nowrap">{$MOD.LBL_USERNAME}</td>
	<td class="colHeader" width="10%" nowrap="nowrap">{$APP.Active}</td>
	<td class="colHeader" width="10%">{$MOD.Tools}</td>
	</tr>
	{foreach item=SMSSERVER from=$SMSSERVERS}
	<tr>
	<td class="listTableRow">{$SMSSERVER.providertype}</td>
	<td class="listTableRow">{$SMSSERVER.username}</td>
	<td class="listTableRow">{if $SMSSERVER.isactive}{$APP.yes}{else}{$APP.no}{/if}</td>
	<td class="listTableRow">
		<a class="icon-homeimg icon-editfield" href="javascript:;" onclick="fnvshobj(this,'editdiv');_SMSConfigServerFetchEdit('{$SMSSERVER.id}');" title="{$APP.LBL_EDIT}"></a>
		<a class="icon-homeimg icon-sdel" href="javascript:;" onclick="fnvshobj(this,'editdiv');_SMSConfigServerDelete('{$SMSSERVER.id}');" title="{$APP.LBL_DELETE}"></a>
	</td>

	</tr>
	{/foreach}
</table>
