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
<div style="display: flex;align-items: center;">
	<div class="page-topsec-area" style="width: 50%;margin: 20px 24px 10px;float: left;">
		<div class="page-topsec-inputbox">
			<a href="javascript:;" class="topsec-btn" title="{'SEARCH'|@getFixedLabel}" onclick="quickCreateSearchPop('search');"></a>
			<span class="search-clear-btn"></span>
			<input id="query_string" type="text" onkeyup="quickCreateSearchPop_Key(event,'search');" placeholder="{'SEARCHMODULE'|@getFixedLabel}" class="ui-autocomplete-input" style="width: 200px;">
		</div>
	</div>
	<div id="search_onlyin_all_div">
		{*wym 240109 BUG20240105-007 kfbcrm-全局查找-“全选”应该可以通过点击文字选中*}
		<input id="search_onlyin_all" type='checkbox' {if $isallcheck == 'yes'}checked{/if}  style="margin: -2px 5px 0 5px;cursor: pointer;" onchange="UnifiedSearch_SelectModuleToggle_Allcheck(this)"/><label for="search_onlyin_all" style="cursor: pointer;color: #3B4859;">{'ALLSELECT'|@getFixedLabel}</label>
	</div>
</div>
<div style="padding: 13px 35px;display: none" name="searchResultTip" id="searchResultTip">
</div>
<form id="UnifiedSearch_moduleform" name="UnifiedSearch_moduleform">
    <div class="scrollContent scrollContent-autoheight ld-pop-container" style="display: grid;grid-template-columns: repeat(4, 1fr);padding-top: 10px;padding-bottom: 4px;" id="UnifiedSearch_modulediv" name="UnifiedSearch_modulediv">
		{foreach item=SEARCH_MODULEINFO key=SEARCH_MODULENAME from=$ALLOWED_MODULES name=allowed_modulesloop}
			<div class="padB16" style="width: 138px;" name="UnifiedSearch_div" id="UnifiedSearch_div">
				<input type='checkbox' name='search_onlyin' class="marR5 cursorPointer" value='{$SEARCH_MODULENAME}' id='label_for_{$SEARCH_MODULENAME}'
					   {if $SEARCH_MODULEINFO.selected}checked=true{/if} onchange="UnifiedSearch_SelectModuleToggle_Inputcheck()">
				<label for='label_for_{$SEARCH_MODULENAME}' style="cursor: pointer;color: #3B4859;">
					<span tag="UnifiedSearch_span" data-fieldtable="{$SEARCH_MODULEINFO.label}">{$SEARCH_MODULEINFO.label}</span>
				</label>
			</div>
		{/foreach}
    </div>
	<div id="nocontent" style="line-height: 42px;display: none;text-align: center"><span>{'NOCONTENT'|@getFixedLabel}</span></div>

</form>