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
	<td class="colHeader" width="5%">#</td>
	<td class="colHeader" width="40%">{$CMOD.LBL_NOTIFICATION}</td>
	<td class="colHeader" width="40%">{$CMOD.LBL_DESCRIPTION}</td>
	<td class="colHeader" width="10%">{$CMOD.LBL_STATUS}</td>
	<td class="colHeader" width="10%">{$CMOD.Tools}</td>
	</tr>
	{foreach name=notifyfor item=elements from=$NOTIFICATION}
	<tr>
	<td class="listTableRow">{$smarty.foreach.notifyfor.iteration}</td>
	<td class="listTableRow">{$elements.notificationname}</td>
	<td class="listTableRow">{$elements.label}</td>
	{if $elements.status eq 'Active'}
	<td class="listTableRow active">{$elements.status}</td>
	{else}
	<td class="listTableRow inactive">{$elements.status}</td>
	{/if}
	<td class="listTableRow" align="center" ><a class="icon-homeimg icon-editfield" href="javascript:;" onclick="fnvshobj(this,'editdiv');fetchEditNotify('{$elements.id}');" title="{$APP.LBL_EDIT}"></a></td>
	</tr>
	{/foreach}
	</table>
