{*ls 2022-03-10 【1002521】页面设置，增加【字段列表】标签*}
	<input type="hidden" name="fld_module" value="{$MODULE}">
	<input type="hidden" name="module" value="Settings">
	<input type="hidden" name="parenttab" value="Settings">
	<div style="clear: both;"></div>
	<div class="ld-search-bar width300" style="margin:5px 0 10px 0;">
		<input name="fieldlist_search" type="text" onkeyup="cls_fieldlist.getInstance().fieldlistsearch(event);" onkeydown="cls_fieldlist.getInstance().fieldlistViewText()" placeholder="{'SearchPleaseEnter'|@getFixedLabel}、{'DatabaseFieldName'|@getFixedLabel}" class="ld-input-inner">
		<b class="ld-icon-clearsearch" onclick="cls_fieldlist.getInstance().fieldlistClearText()"></b>
        <b class="ld-icon-search" title="{'SEARCHNEW'|@getFixedLabel}" onclick="cls_fieldlist.getInstance().callFieldlistSearch();"></b>
	</div>
	<div class="main_grid_box" style="height: 705px; overflow: hidden;">
		<div class="grid-analysis-box" name="fieldlist_table">
			<div class="grid-analysis-header">
			</div>
			<div id="vtlib_modulemanager_list" class="cont_wrap clear_float">
				{include file="Settings/LayoutBlockFieldListEntries.tpl"}
			</div>
		</div>
	</div>

