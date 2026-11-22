<!--*+********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
-->
<!--修改编码格式:统一编码：UTF-8-->
<!--<script src="include/js/json.js" type="text/javascript" charset="utf-8"></script>-->

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/advancefilter.js?v={$GLOBALMINVERSION}"></script>
{if $JS_DATEFORMAT eq ''}
	{assign var="JS_DATEFORMAT" value='YYYY-mm-ddd'|@parse_calendardate}
{/if}
<input type="hidden" id="jscal_dateformat" name="jscal_dateformat" value="{$JS_DATEFORMAT}" />
<input type="hidden" id="image_path" name="image_path" value="{$IMAGE_PATH}" />
<input type="hidden" name="advft_criteria" id="advft_criteria" value="" />
<input type="hidden" name="advft_criteria_groups" id="advft_criteria_groups" value="" />

<div style="overflow:auto;" id='adv_filter_div' name='adv_filter_div'>
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<th>{'DATARANGE'|@getFixedLabel}</th>
		</tr>
	</table>
    <div id="conditiongroup_1" name="conditionGroup">
        <table id="conditiongrouptable_1" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
            {foreach item=list from=$AdvancedSearch}
                <tr id="conditioncolumn_1_0" name="conditionColumn">
                    <td width="25%">{$list.columnname}</td>
                    <td width="25%">{$list.comparator}</td>
                    <td>{$list.value}</td>
                    <td>{if $list.column_condition eq 'and'}{'SEARCHAND'|@getFixedLabel}{else}{/if}{if $list.column_condition eq 'or'}{'OR'|@getFixedLabel}{else}{/if}</td>
                </tr>
            {/foreach}
            <tr id="groupfooter_1">
                <td align="left" colspan="5"></td>
            </tr>
        </table>
    </div>
</div>