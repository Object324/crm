{*页面设置，增加【自定义字段操作日志】标签*}
	<input type="hidden" name="fld_module" value="{$MODULE}">
	<input type="hidden" name="module" value="Settings">
	<input type="hidden" name="parenttab" value="Settings">
	<div style="clear: both;"></div>
	<div class="ld-search-bar width300" style="margin:5px 0 10px 0;">
		<input name="fieldlist_cfoplogsearch" type="text" onkeyup="cls_cfoplog.getInstance().customedfieldlistsearch(event);" onkeydown="cls_cfoplog.getInstance().fieldlistCfopLogViewText()" placeholder="{'SearchPleaseEnter'|@getFixedLabel}" class="ld-input-inner">
		<b class="ld-icon-clearsearch" onclick="cls_cfoplog.getInstance().fieldlistCfopLogClearText()"></b>
        <b class="ld-icon-search" title="{'SEARCHNEW'|@getFixedLabel}" onclick="cls_cfoplog.getInstance().CFOperationLOGSearch();"></b>
	</div>
	<div class="main_grid_box" style="height: 705px; overflow: hidden;">
		<div class="grid-analysis-box" name="fieldlist_cfoplogtable">
			{include file="Settings/LayoutBlockList_CFOperationLog.tpl"}
		</div>
	</div>