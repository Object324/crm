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
			<strong>{$MOD.LBL_CONDITIONS}</strong>
		</td>
		<td class="small" align="right">
			<span id="workflow_loading" style="display:none">
			  <b>{$MOD.LBL_LOADING}</b><img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0">
			</span>
			<input type="button" class="create"
				value="{$MOD.LBL_NEW_CONDITION_GROUP_BUTTON_LABEL}" id="save_conditions_add" style='display: none;'/>
		</td>
	</tr>
</table>
<br>
<div id="save_conditions"></div>
<br>
{include file="com_lingdang_workflow/FieldExpressions.tpl"}