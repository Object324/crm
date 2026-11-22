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
        <td width="12%" height="1"></td>
        <td width="75%" height="1"></td>
    </tr>
    <tr>
		<td class="heading2" width="15%">
			<input type="checkbox" class="small" id="auto_merge" name="auto_merge" onclick="ImportJs.toogleMergeConfiguration();" />
			{'Stage'|@getFixedLabel} 3:
		</td>
		<td>
			<span class="big">{'Repeat_recording_process'|@getFixedLabel}</span>
			<span class="small">( {'STOTEASTCFDM'|@getFixedLabel} )</span>
		</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>
			<table width="100%" cellspacing="0" cellpadding="5" id="duplicates_merge_configuration" style="display:none;">
				<tr>
					<td>
						<span class="small">{'CHTDWDR'|@getFixedLabel}</span>&nbsp;&nbsp;
						<select name="merge_type" id="merge_type" class="small">
							{foreach key=_MERGE_TYPE item=_MERGE_TYPE_LABEL from=$AUTO_MERGE_TYPES}
							<option value="{$_MERGE_TYPE}">{$_MERGE_TYPE_LABEL|@getFixedLabel}</option>
							{/foreach}
						</select>
					</td>
				</tr>
				<tr>
					<td class="small">{'STFTFTMDR'|@getFixedLabel}</td>
				</tr>
				<tr>
					<td>
						<table class="calDayHour" cellpadding="5" cellspacing="0">
							<tr>
								<td><b>{'Available_fields'|@getFixedLabel}</b></td>
								<td></td>
								<td><b>{'Field_matches'|@getFixedLabel}</b></td>
							</tr>
							<tr>
								<td>
									<select id="available_fields" multiple size="10" name="available_fields" style="width: 100%">
										{foreach key=_FIELD_NAME item=_FIELD_INFO from=$AVAILABLE_FIELDS}
										<option value="{$_FIELD_NAME}">{$_FIELD_INFO->getFieldLabelKey()|@getTranslatedString_temp:$FOR_MODULE}</option>
										{/foreach}
									</select>
								</td>
								<td width="6%">
									<div align="center">
										<input type="button" name="Button" value="&nbsp;&rsaquo;&rsaquo;&nbsp;" onClick="copySelectedOptions('available_fields', 'selected_merge_fields')"/><br /><br />
										<input type="button" name="Button1" value="&nbsp;&lsaquo;&lsaquo;&nbsp;" onClick="removeSelectedOptions('selected_merge_fields')"/><br /><br />
									</div>
								</td>
								<td>
									<input type="hidden" id="merge_fields" size="10" name="merge_fields" value="" />
									<select id="selected_merge_fields" size="10" name="selected_merge_fields" multiple style="width: 100%">
										{foreach key=_FIELD_NAME item=_FIELD_INFO from=$ENTITY_FIELDS}
										<option value="{$_FIELD_NAME}">{$_FIELD_INFO->getFieldLabelKey()|@getTranslatedString_temp:$FOR_MODULE}</option>
										{/foreach}
									</select>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>