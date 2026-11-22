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
	<tr>
		<td>{'LBL_TOTAL_RECORDS_FAILED'|@getFixedLabel}:{$IMPORT_RESULT.FAILED} / {$IMPORT_RESULT.TOTAL}</td>
	</tr>
</table>