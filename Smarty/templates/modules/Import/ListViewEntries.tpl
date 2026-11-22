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
<table width="100%" class="layerPopupTransport" cellpadding="5">
	<tr>
		<td align="left">
			{$recordListRange}
		</td>
		<td align="right" class="page">
			<a href="javascript:;" onClick="ImportJs.loadListViewPage('{$FOR_MODULE}', 1, '{$FOR_USER}');" title="{'LBL_FIRST'|@getTranslatedString:$FOR_MODULE}">
				<span class="icon-firstpage"></span>
            </a>
			<a href="javascript:;" onClick="ImportJs.loadListViewPage('{$FOR_MODULE}', {$CURRENT_PAGE}-1, '{$FOR_USER}');" title="{'LNK_LIST_PREVIOUS'|@getTranslatedString:$FOR_MODULE}">
				<span class="icon-prevpage"></span>
            </a>
			<input class="small" id="page_num" type="text" value="{$CURRENT_PAGE}" style="width: 3em;margin-right: 0.7em;"
				   onchange="ImportJs.loadListViewSelectedPage('{$FOR_MODULE}', '{$FOR_USER}');"
				   onkeypress="return VT_disableFormSubmit(event);" />
			<a href="javascript:;" onClick="ImportJs.loadListViewPage('{$FOR_MODULE}', {$CURRENT_PAGE}+1, '{$FOR_USER}');" title="{'LNK_LIST_NEXT'|@getTranslatedString:$FOR_MODULE}">
				<span class="icon-nextpage"></span>
            </a>
			<a href="javascript:;" onClick="ImportJs.loadListViewPage('{$FOR_MODULE}', 'last', '{$FOR_USER}');" title="{'LBL_LAST'|@getTranslatedString:$FOR_MODULE}">
				<span class="icon-lastpage"></span>
            </a>
		</td>
	</tr>
</table>
<table border=0 cellspacing=1 cellpadding=3 width=100% class="lvt small">
	<tr>
		{foreach name="listviewforeach" item=header from=$LISTHEADER}
		<td class="lvtCol commonCol">{$header|@strip_tags}</td>
		{/foreach}
	</tr>
	{foreach item=entity key=entity_id from=$LISTENTITY}
		<tr bgcolor=white onMouseOver="this.className='lvtColDataHover'" onMouseOut="this.className='lvtColData'" id="row_{$entity_id}">
			{foreach item=data from=$entity}
			{* vtlib customization: Trigger events on listview cell onmouseover="vtlib_listview.trigger('cell.onmouseover', $(this))" onmouseout="vtlib_listview.trigger('cell.onmouseout', $(this))"*}
			<td >{$data}</td>
			{* END *}
	        {/foreach}
		</tr>
	{foreachelse}
		<tr>
			<td style="background-color:#FFF;height:340px" align="center" colspan="{$smarty.foreach.listviewforeach.iteration+1}">
				<div style="border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 45%; z-index: 1;">
					<table border="0" cellpadding="5" cellspacing="0" width="98%">
						<tr>
							<td rowspan="2" width="25%"><img src="{'empty.jpg'|@lingdang_imageurl:$THEME}" height="60" width="61"></td>
							<td style="border-bottom: 1px solid rgb(204, 204, 204);" nowrap="nowrap" width="75%">
								<span class="genHeaderSmall">
								{'NORECORDSAREFOUND'|@getFixedLabel}!
								</span>
							</td>
						</tr>
					</table>
				</div>
			</td>
		</tr>
	{/foreach}
</table>