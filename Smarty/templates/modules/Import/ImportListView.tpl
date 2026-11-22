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
<link rel="stylesheet" type="text/css" href="themes/{$THEME}/style.css">
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/vtlib.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}modules/MailManager/resources/jquery.min.js"></script>
<script type="text/javascript" charset="utf-8">
	jQuery.noConflict();
</script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}modules/Import/resources/Import.js"></script>

<div id="status" style="position:absolute;display:none;left:850px;top:15px;height:27px;white-space:nowrap;">
	<img src="{'status.gif'|@lingdang_imageurl:$THEME}">
</div>
<form onsubmit="puyoungJS_DialogBox.block();" action="index.php" enctype="multipart/form-data" method="POST" name="importBasic">
	<input type="hidden" name="module" value="{$FOR_MODULE}" />
	<input type="hidden" name="action" value="Import" />
	<input type="hidden" name="mode" value="upload_and_parse" />
	<table cellpadding="5" cellspacing="12" class="searchUIBasic">
		<tr>
			<td class="heading2" align="left" colspan="2">
				{'IMPORT'|@getFixedLabel} {$FOR_MODULE|@getTranstab} - {'LBL_LAST_IMPORTED_RECORDS'|@getFixedLabel}
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
			<td class="leftFormBorder1" width="60%" valign="top">
				<div id="import_listview_contents" class="small">
				{include file='modules/Import/ListViewEntries.tpl'}
				</div>
			</td>
		</tr>
	</table>
</form>