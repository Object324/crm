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
<script language="JavaScript" type="text/javascript" src="modules/MailManager/resources/jquery.min.js"></script>
<script type="text/javascript" charset="utf-8">
	jQuery.noConflict();
</script>
<script language="JavaScript" type="text/javascript" src="modules/Import/resources/Import.js"></script>

<table style="width:70%;margin-left:auto;margin-right:auto;margin-top:10px;" cellpadding="10" cellspacing="10" class="searchUIBasic">
	<tr>
		<td class="heading2" align="left" colspan="2">
			{'Import_plan'|@getFixedLabel}
		</td>
	</tr>
	{if $ERROR_MESSAGE neq ''}
	<tr>
		<td class="redFont" align="left" colspan="2">
			{$ERROR_MESSAGE}
		</td>
	</tr>
	{/if}
	<tr>
		<td colspan="2" valign="top">
			<table cellpadding="10" cellspacing="0" align="center" class="dvtSelectedCellCommon dvtSelectedCell thickBorder">
				<tr>
					<td>{'LBL_TOTAL_RECORDS_IMPORTED'|@getFixedLabel}</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right" colspan="2">
			<input type="button" name="cancel" value="{'CANCEL'|@getFixedLabel}" class="delete"
				onclick="location.href='index.php?module={$FOR_MODULE}&action=Import&mode=cancel_import&import_id={$IMPORT_ID}'" />
			{include file='modules/Import/Import_Done_Buttons.tpl'}
		</td>
	</tr>
</table>