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
<div id="new_template_popup" class='layerPopup' style="display:none;">
	<table width="100%" cellspacing="0" cellpadding="5" border="0" class="layerHeadingULine">
		<tr>
			<td width="60%" align="left" class="layerPopupHeading">
				{$MOD.LBL_NEW_TEMPLATE}
			</td>
			<td width="40%" align="right">
				<a class="icon-homeimg icon-close" href="javascript:void(0);" id="new_template_popup_close">
				</a>
			</td>
		</tr>
	</table>

	<form action="index.php" method="get" accept-charset="utf-8" onsubmit="puyoungJS_DialogBox.block();">
	<div class="popup_content">
		<table width="100%" cellspacing="0" cellpadding="5" border="0" class="small">
		<tr align="left">
			<td width="40px" nowrap="nowrap"><font color="red">*</font> {$APP.LBL_TITLE}</td>
			<td><input type="text" name="title" class='detailedViewTextBox'></td>
		</tr>
		</table>
		<input type="hidden" name="module_name" value="{$workflow->moduleName}">
		<input type="hidden" name="save_type" value="new" id="save_type_new">
		<input type="hidden" name="module" value="{$module->name}" id="save_module">
		<input type="hidden" name="action" value="savetemplate" id="save_action">
		<input type="hidden" name="return_url" value="{$newTaskReturnUrl}" id="save_return_url">
		<input type="hidden" name="workflow_id" value="{$workflow->id}">

		<table width="100%" cellspacing="0" cellpadding="5" border="0" class="layerPopupTransport">
		<tr><td align="center">
			<input type="submit" class="save" value="{$APP.LBL_CREATE_BUTTON_LABEL}" name="save" id='new_template_popup_save'/>
			<input type="button" class="cancel" value="{$APP.LBL_CANCEL_BUTTON_LABEL} " name="cancel" id='new_template_popup_cancel'/>
		</td></tr>
		</table>
	</div>
	</form>
</div>