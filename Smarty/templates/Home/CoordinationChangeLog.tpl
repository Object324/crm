

{*修改日志列表模板*}
	<div id="hdScrolllistentries_yy_{$RELATED_MODULE}" name="hdScrolllistentries_yy_{$RELATED_MODULE}" style="position:relative;">
		<div style=" visibility: visible; top: 194px;overflow:hidden;" id="resize_header_table_divid_{$RELATED_MODULE}">
			<div  style="float:left; ">
				<table id="resize_header_tableid_{$RELATED_MODULE}" name="resize_header_tableid_{$RELATED_MODULE}" class="listEntries" border=0 cellspacing=1 cellpadding="0" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" >
					<tr>
						{foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header name=relheadforeach}
							<th style="width:{$RELATEDLISTDATA.fieldwidth[$index]}px;" tag="{$index}"
								headermodule="{$RELATEDLISTDATA.headername.module[$index]}" headername="{$RELATEDLISTDATA.headername.fieldname[$index]}" >{$_HEADER_FIELD}</th>
						{/foreach}
					</tr>
				</table>
			</div>
		</div>
		<div style="overflow:auto;" id="resize_content_table_divid_{$RELATED_MODULE}" name="resize_content_table_divid_{$RELATED_MODULE}">
			{*zkt 20220920 BUG0056732签到日志中，不应该有有横向滑动条*}
			<div  style="float:left; ">
				<table id="resize_content_tableid_{$RELATED_MODULE}" name="resize_content_tableid_{$RELATED_MODULE}" class="listEntries marT-53" style="width:{if $RELATEDLISTDATA.total_width >0}{$RELATEDLISTDATA.total_width}px {else}100%{/if}" border=0 cellspacing=1 cellpadding="0" >
					<tr>
						{foreach key=index item=_HEADER_FIELD from=$RELATEDLISTDATA.header name=relheadforeach}
							<th style="width:{$RELATEDLISTDATA.fieldwidth[$index]}px"  tag="{$index}""
								headermodule="{$RELATEDLISTDATA.headername.module[$index]}" headername="{$RELATEDLISTDATA.headername.fieldname[$index]}"  >{$_HEADER_FIELD}</th>
						{/foreach}
					</tr>
					{assign var="i" value=0}
					{foreach key=_RECORD_ID name=entriesList item=_RECORD from=$RELATEDLISTDATA.entries}
						{assign var="j" value=$i++}
						{if $smarty.foreach.entriesList.iteration mod 2 eq '1'}
							<tr id="relation_{$RELATED_MODULE}_{$j}" record="{$_RECORD_ID}" class="lvtColData" onmouseover="listOnMouseOver(ld(this), 'record')" onmouseout="listOnMouseOut(ld(this),'on', 'record')">
								{else}
							<tr id="relation_{$RELATED_MODULE}_{$j}" record="{$_RECORD_ID}" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this), 'record')" onmouseout="listOnMouseOut(ld(this),'On', 'record')">
						{/if}

						{foreach key=index item=_RECORD_DATA from=$_RECORD}
							{* vtlib customization: Trigger events on listview cell onmouseover="vtlib_listview.trigger('cell.onmouseover', $(this))" onmouseout="vtlib_listview.trigger('cell.onmouseout', $(this))"*}
							{if $index|@istdRight:$RELATED_MODULE==true}
								{assign var="tdalign" value='right'}
							{else}
								{assign var="tdalign" value='left'}
							{/if}
							<td width="40%" align="{$tdalign}">{$_RECORD_DATA}</td>
							{* END *}
						{/foreach}

						{foreachelse}
						<tr>
								{assign var=winheight value="250" }

							<td id="resize_content_tdid"  style="background-color:#FFF;height:{$winheight}px;padding: 0;" align="center" colspan='{$smarty.foreach.relheadforeach.iteration}'>

								{include file="NoRecords.tpl"}
							</td>
						</tr>
					{/foreach}
					{if $RELATEDLISTDATA.totalfldhtml !=''}
						{$RELATEDLISTDATA.totalfldhtml}
					{/if}
				</table>
			</div>


		</div>

	</div>

