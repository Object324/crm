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

<input type="hidden" name="module" value="{$FOR_MODULE}" />
<table style="width:70%;margin-left:auto;margin-right:auto;margin-top:10px;" cellpadding="10" cellspacing="10" class="searchUIBasic">
	<tr>
		<td class="heading2" align="left">
			{'IMPORT'|@getFixedLabel} - {'error'|@getFixedLabel}
		</td>
	</tr>
	<tr>
		<td valign="top">
			<table cellpadding="10" cellspacing="0" align="center" class="dvtSelectedCellCommon dvtSelectedCell thickBorder">
				<tr>
					<td class="redFont" align="left">
						{$ERROR_MESSAGE}
					</td>
				</tr>
				{if $ERROR_DETAILS neq ''}
				<tr>
					<td class="errorMessage" align="left">
						{'Detailed_lists_following'|@getFixedLabel}
						<table cellpadding="5" cellspacing="0">
						{foreach key=_TITLE item=_VALUE from=$ERROR_DETAILS}
							<tr>
								<td>{$_TITLE}</td>
								<td>-</td>
								<td>{$_VALUE}</td>
							</tr>
						{/foreach}
						</table>
					</td>
				</tr>
				{/if}
			</table>
		</td>
	</tr>
	<tr>
		<td align="right">
		{if $CUSTOM_ACTIONS neq ''}
		{foreach key=_LABEL item=_ACTION from=$CUSTOM_ACTIONS}
			<input type="button" name="{$_LABEL}" value="{$_LABEL|@getTranslatedString:$MODULE}"
				   onclick="{$_ACTION}" class="create" />
		{/foreach}
		{/if}
		<input type="button" name="goback" value="{'RETURN'|@getFixedLabel}"
			   onclick="window.history.back()" class="edit" />
		</td>
	</tr>
</table>