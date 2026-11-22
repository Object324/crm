{*<!--
/*+*******************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<table class="listTable" width="100%" border="0" cellspacing="1" cellpadding="5" id='expressionlist'>
	<tr>
		<td class="colHeader small" width="70%">
			{$MOD.LBL_TASK}
		</td>
		<td class="colHeader small" width="15%">
			{$MOD.LBL_STATUS}
		</td>
		<td class="colHeader small" width="15%">
			{$MOD.LBL_LIST_TOOLS}
		</td>
	</tr>
	{foreach item=task from=$tasks}
	<tr>
		<td class="listTableRow small">{$task->summary|@to_html}</td>
		<td class="listTableRow small">{if $task->active}{'LBL_Active'|@getTranslatedString:$MODULE}{else}{'LBL_Inactive'|@getTranslatedString:$MODULE}{/if}</td>
		<td class="listTableRow small">
			<a class="icon-homeimg icon-editfield" id="expressionlist_editlink_{$task->id}" href="{$module->editTaskUrl($task->id)}" title="{'LBL_EDIT_BUTTON'|@getTranslatedString:$MODULE}"></a>
			<a class="icon-homeimg icon-sdel" id="expressionlist_deletelink_{$task->id}" title="{'LBL_DELETE_BUTTON'|@getTranslatedString:$MODULE}" href="{$module->deleteTaskUrl($task->id)}" onclick="return confirm('{$APP.SURE_TO_DELETE}');">
			</a>
		</td>
	</tr>
	{/foreach}
</table>