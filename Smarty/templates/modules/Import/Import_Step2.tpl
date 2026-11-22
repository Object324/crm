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
<table width="100%" cellspacing="0" cellpadding="5">
	<tr>
		<td class="heading2">{'Stage'|@getFixedLabel} 2:</td>
		<td class="big">{'Specified_format'|@getFixedLabel}</td>
		<td>&nbsp;</td>
	</tr>
	<tr id="file_type_container">
		<td>&nbsp;</td>
		<td><span>{'File_Type'|@getFixedLabel}</span></td>
		<td>
			<select name="type" id="type" class="small" onchange="ImportJs.handleFileTypeChange();">
				{foreach item=_FILE_TYPE from=$SUPPORTED_FILE_TYPES}
				<option value="{$_FILE_TYPE}">{$_FILE_TYPE|@getTranslatedString:$MODULE}</option>
				{/foreach}
			</select>
		</td>
	</tr>
	<tr id="file_encoding_container">
		<td>&nbsp;</td>
		<td><span>{'Character_Encoding'|@getFixedLabel}</span></td>
		<td>
			<select name="file_encoding" id="file_encoding" class="small">
				{foreach key=_FILE_ENCODING item=_FILE_ENCODING_LABEL from=$SUPPORTED_FILE_ENCODING}
				<option value="{$_FILE_ENCODING}">{$_FILE_ENCODING_LABEL|@getTranslatedString:$MODULE}</option>
				{/foreach}
			</select>
		</td>
	</tr>
	<tr id="delimiter_container">
		<td>&nbsp;</td>
		<td><span>{'Delimiter'|@getFixedLabel}</span></td>
		<td>
			<select name="delimiter" id="delimiter" class="small">
				{foreach key=_DELIMITER item=_DELIMITER_LABEL from=$SUPPORTED_DELIMITERS}
				<option value="{$_DELIMITER}">{$_DELIMITER_LABEL|@getFixedLabel}</option>
				{/foreach}
			</select>
		</td>
	</tr>
	<tr id="has_header_container">
		<td>&nbsp;</td>
		<td><span>{'There_title'|@getFixedLabel}</span></td>
		<td><input type="checkbox" class="small" id="has_header" name="has_header" checked /></td>
	</tr>
</table>