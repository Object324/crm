{*<!--
/*+*******************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/

-->*}
<script>
//edit:can 20210401 45265: （武汉太勒）没有外网；全局查找SO1802，编辑合同订单，然后点击保存没有反应
AjaxJSPage('{$MODULE}'+ "_js", 'include/js/modules/' + '{$MODULE}' + '/' + '{$MODULE}' + '.js');
</script>
<!--修改编码格式:统一编码：UTF-8-->
{if $MODULE eq $SEARCH_MODULE && $SEARCH_MODULE neq ''}
	<div id="global_list_{$SEARCH_MODULE}" style="display:block;clear:both;">
{else}
	<div id="global_list_{$MODULE}" style="display:block;clear:both;">
{/if}
<form name="massdelete" method="POST">

<input name="idlist" type="hidden">
 <input name="change_owner" type="hidden">
 <input name="change_status" type="hidden">
 <input name="search_tag" type="hidden" value="{$TAG_SEARCH}" >
 <input name="search_criteria" type="hidden" value="{$SEARCH_STRING}">
 <input name="module" type="hidden" value="{$MODULE}" />
 <input name="{$MODULE}_viewid" type="hidden" value="{$viewid}" />
 <input name="{$MODULE}RecordCount" id="{$MODULE}RecordCount" type="hidden" value="{$ModuleRecordCount.$MODULE.count}" />

<div class="global_searchDiv">
	<div style="height: 36px;" id="list_header_{$MODULE}">
	    {assign var="MODULELABEL" value=$MODULE}
		{if $MODULE|@getTranstab neq ''}
			{assign var="MODULELABEL" value=$MODULE|@getTranstab}
		{/if}
		<div style="float:left;line-height: 36px;">
			{if $MODULE eq 'DailyReport' || $MODULE eq 'WeekReport' || $MODULE eq 'MonthReport'}
                {if $MODULE eq 'DailyReport'}
                    {'DAILYREPORT'|@getFixedLabel} - {$SEARCH_CRITERIA}
                {elseif $MODULE eq 'WeekReport'}
                    {'WEEKREPORT'|@getFixedLabel} - {$SEARCH_CRITERIA}
                {elseif $MODULE eq 'MonthReport'}
                    {'MONTHREPORT'|@getFixedLabel} - {$SEARCH_CRITERIA}
                {/if}
            {else}
            {$MODULELABEL} - {$SEARCH_CRITERIA}
            {/if}
		</div>
		<div class="PageDiv0" style="float:right;">
			<div class="ld-flex-start">
				<div class="ld-pagenum-div">{$ModuleRecordCount.$MODULE.recordListRangeMessage}</div>
                {$NAVIGATION}
			</div>
		</div>
	</div>



    <div class="main_grid lfloat main_grid_list" style="padding-bottom: 10px">
    	<div class="main_grid_box">
            <div class="grid-analysis-box">
                <div class="grid-analysis-header">
                </div>
                <div class="cont_wrap clear_float">
                	<div id="divMapShow" class="divMapShow" style="width:100%; display:none;" >
                		<div class="divMapLeft" id="divMapLeft">

                		</div>
                		<div class="divMapRight">
                			<div id="map_div" name="map_div" style="width:100%;">

                			</div>
                		</div>
                	 </div>
                    {assign var=operating value='OPERATING'|@getFixedLabel}
                    <div id="hdScrolllistentries_yy_{$MODULE}" name="hdScrolllistentries_yy_{$MODULE}" style="position: relative;"><!-- style="width:100%;" -->
                        <div style=" visibility: visible; top: 194px;overflow: hidden;" id="resize_header_table_divid_{$MODULE}" name="resize_header_table_divid_{$MODULE}">
                            <div style="float:left; padding-right:20px">
                                <table border="0" cellspacing="1" cellpadding="0" name="resize_header_tableid_{$MODULE}" id="resize_header_tableid_{$MODULE}" style="width:{$TOTALWIDTH}px" class="listEntries">
                                    <tr>
                                    	{if $DISPLAYHEADER eq 1}
												{foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
													{if $header neq $operating || $LIST_NOOPERATING eq 'no'}
														<th style="width:{$LISTHEADERWIDTH[$i]}px" headermodule='{$MODULE}' headername='{$HEADERNAME[$i]}' tag="{$i+1}">{$header}</th>
													{else}
														<th width="{$OPERATIONWIDTH}">{$header}</th>
													{/if}
												{/foreach}
										{else}
											<td class="searchResultsRow" colspan="{$HEADERCOUNT}"> {'NOTFOUNDANYRECORD'|@getFixedLabel} </td>
										{/if}
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div style="overflow: auto;max-height:300px;" id="resize_content_table_divid_{$MODULE}" name="resize_content_table_divid_{$MODULE}">
                            <table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid_{$MODULE}" name="resize_content_tableid_{$MODULE}" style="width:{$TOTALWIDTH}px" class="listEntries marT-53">
								{if $DISPLAYHEADER eq 1}
									<tr name="tr_header">
										{foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
											{if $header neq $operating || $LIST_NOOPERATING eq 'no'}
												<th style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}'>{$header}</th>
											{else}
												<th width="{$OPERATIONWIDTH}">{$header}</th>
											{/if}
										{/foreach}
									</tr>
									{$SEARCHLISTHTML}
								{else}
									<td class="searchResultsRow" colspan="{$HEADERCOUNT}"> {'NOTFOUNDANYRECORD'|@getFixedLabel} </td>
								{/if}
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


</div>



</form>	
</div>
{if $SEARCH_MODULE eq 'All'}
<script>
displayModuleList(document.getElementById('global_search_module'));
</script>
{/if}