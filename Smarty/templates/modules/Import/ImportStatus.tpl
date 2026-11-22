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
{literal}
<script type="text/javascript">
jQuery(document).ready(function() {
	setTimeout(function() {
		jQuery("[name=importStatusForm]").get(0).submit();
		}, 500);
});
</script>
{/literal}

<form onsubmit="puyoungJS_DialogBox.block();" action="index.php" enctype="multipart/form-data" method="POST" name="importStatusForm">
	<input type="hidden" name="module" value="{$FOR_MODULE}" />
	<input type="hidden" name="action" value="Import" />
	{if $CONTINUE_IMPORT eq 'true'}
	<input type="hidden" name="mode" value="continue_import" />
	{else}
	<input type="hidden" name="mode" value="" />
	{/if}
</form>
<table style="width:70%;margin-left:auto;margin-right:auto;margin-top:10px;" cellpadding="10" cellspacing="10" class="searchUIBasic">
	<tr>
		<td class="heading2" align="left" colspan="2">
			{'IMPORT'|@getFixedLabel} {$FOR_MODULE|@getTranstab} - 
			<span class="redFont">{'Operation'|@getFixedLabel} ... </span>
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
		<td valign="top">
			<table cellpadding="10" cellspacing="0" align="center" class="dvtSelectedCellCommon dvtSelectedCell thickBorder">
				<tr>
					<td>{'LBL_TOTAL_RECORDS_IMPORTED'|@getFixedLabel}:{$IMPORT_RESULT.IMPORTED} / {$IMPORT_RESULT.TOTAL}</td>
				</tr>
				<tr>
					<td>
						<table cellpadding="10" cellspacing="0" class="calDayHour">
							<tr>
								<td>{'LBL_NUMBER_OF_RECORDS_CREATED'|@getFixedLabel}</td>
								<td width="10%">:</td>
								<td width="10%">{$IMPORT_RESULT.CREATED}</td>
							</tr>
							<tr>
								<td>{'LBL_NUMBER_OF_RECORDS_UPDATED'|@getFixedLabel}</td>
								<td width="10%">:</td>
								<td width="10%">{$IMPORT_RESULT.UPDATED}</td>
							</tr>
							<tr>
								<td>{'LBL_NUMBER_OF_RECORDS_SKIPPED'|@getFixedLabel}</td>
								<td width="10%">:</td>
								<td width="10%">{$IMPORT_RESULT.SKIPPED}</td>
							</tr>
							<tr>
								<td>{'LBL_NUMBER_OF_RECORDS_MERGED'|@getFixedLabel}</td>
								<td width="10%">:</td>
								<td width="10%">{$IMPORT_RESULT.MERGED}</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">
		<input type="button" name="cancel" value="{'CANCEL'|@getFixedLabel}" class="delete"
			   onclick="location.href='index.php?module={$FOR_MODULE}&action=Import&mode=cancel_import&import_id={$IMPORT_ID}'" />
		</td>
	</tr>
</table>