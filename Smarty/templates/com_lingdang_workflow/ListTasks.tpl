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
<table class="tableHeading" width="100%" border="0" cellspacing="0" cellpadding="5">
	<tr>
		<td class="big" nowrap="nowrap">
			<strong>{$MOD.LBL_TASKS}</strong>
		</td>
		<td class="small" align="right">
			<input type="button" class="create" value="{$MOD.LBL_NEW_TASK_BUTTON_LABEL}" id='new_task' style="display:none;" />
		</td>
	</tr>
</table>
{include file='com_lingdang_workflow/TaskSummaryList.tpl'}