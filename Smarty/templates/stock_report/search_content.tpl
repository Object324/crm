<form name="selectall" method="POST">
	
	{if $invoke_login neq ''}
		<div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
			<div style="overflow:auto;" id="resize_content_table_divid" name="resize_content_table_divid">
				<table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid" name="resize_content_tableid" style="margin-top:-55px;width:{$WIDTH}px;background-color: unset" class="listEntries" >
					<tr align="center" style="height:340px">
						<td colspan="30" style="height:0px;padding: 0;">
							{* <div class="warningTableContent" style="z-index:600;">
								<div class="wtc_img">
									<img src="themes/icon2023/ld-no-records.png">
								</div>
								<div class="wtc_content">
									<font color="red">{$invoke_login}</font>
								</div>
								<div class="wtc_btn"></div>
								<div></div>
							</div> *}
							{assign var = "tmp_content" value = "<font color='red'>{$invoke_login}</font>"}
							{include file="NoRecords.tpl" NoRecords_CONTENT={$tmp_content}}
						</td>
					</tr>
				</table>
			</div>
		</div>
	{else}
		{if $ALL_ROWS gte 1}
			<div class="divButtons">
			<!--分页-->
                <div class="PageDiv0">
                    <ul>
                    <li> 共 {$ALL_ROWS} 条记录</li>
                    <li>
						{if $PREVPAGE gte 1}
							<span class="icon-prevpage" title="上一页" onclick="search_pro_stock_btn('search',{$PAGE}-1);"></span>
						{else}
							<span class="no-icon-prevpage"></span>
						{/if}
					</li>
					<li class="Input">{$PAGE}/{$ALL_PAGE}</li>
					<li>
						{if $NEXTPAGE gte 1}
							<span class="icon-nextpage" title="下一页" onclick="search_pro_stock_btn('search',{$PAGE}+1);"></span>
						{else}
							<span class="no-icon-nextpage"></span></li>
						{/if}
					</ul>
                </div>
            </div>
			<div class="clear"></div>
		{/if}
		<!--end-->
		
		<div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
			<div style=" visibility: visible; top: 194px;overflow:hidden" id="resize_header_table_divid" name="resize_header_table_divid">
				<div  style="float:left; padding-right:20px">
					<table id="resize_header_tableid" name="resize_header_tableid" class="listEntries" border=0 cellspacing=1 cellpadding="0" style="width:{$WIDTH}px;" >
						<tbody>
							<tr>
								{foreach item=info from=$HEADER}
									<th style="width:{$info.width};">{$info.label}</th>
								{/foreach}
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div style="overflow:auto;" id="resize_content_table_divid" name="resize_content_table_divid">
				<table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid" name="resize_content_tableid" style="margin-top:-55px;width:{$WIDTH}px;" class="listEntries" >
					<tbody>
						<tr>
							{foreach item=info from=$HEADER}
								<th style="width:{$info.width};">{$info.label}</th>
							{/foreach}
						</tr>
						{foreach key=id item=info from=$LISTENTITY}
							<tr class="lvtColData">
								{foreach item=colname from=$FIELDKEYS}
									<td><span title="{$info[$colname]}">{$info[$colname]}</span></td>
								{/foreach}
								
							</tr>
						{foreachelse}
							<tr align="center" style="">
								<td colspan="{$HEADERLENGTH}" bgcolor="#fff" style="height:0px;padding: 0;">
									{* <div class="warningTableContent" style="z-index:600;">
										<div class="wtc_img">
											<img src="themes/icon2023/ld-no-records.png">
										</div>
										<div class="wtc_content">
											{'NOTFOUNDANYRECORD'|@getFixedLabel}
										</div>
										<div class="wtc_btn"></div>
										<div></div>
									</div> *}
									{include file="NoRecords.tpl"}
								</td>
							</tr>
						{/foreach}

						{* tcloudnew 的可用量等数量统计*}
						{if count($LISTENTITY) gt 0 && count($FieldCounts) gt 0}
							<tr class="lvtColData">
								<td colspan="{$FieldCounts[0]['index']}" align="right"><span>本页小计</span></td>
								{assign var='previndex' value=$FieldCounts[0]['index']}
								{foreach item=info from=$FieldCounts}
									{assign var='curindex' value=$info['index']}
									{*当前循环行距离前一个的空白td个数*}
									{for $i = 1 to $curindex-$previndex-1}
										<td align="right"></td>
									{/for}
									<td align="right"><span title="{$info['subtotal']}">{$info['subtotal']}</span></td>
									{assign var='previndex' value=$curindex}
								{/foreach}
								{*根据列头总长度循环最后的空白*}
								{for $i = 1 to $HEADERLENGTH-$previndex-1}
									<td align="right"></td>
								{/for}
							</tr>

							<tr class="lvtColData">
								<td colspan="{$FieldCounts[0]['index']}" align="right"><span>全部合计</span></td>
								{assign var='previndex' value=$FieldCounts[0]['index']}
								{foreach item=info from=$FieldCounts}
									{assign var='curindex' value=$info['index']}

									{for $i = 1 to $curindex-$previndex-1}
										<td align="right"></td>
									{/for}
									<td align="right"><span title="{$info['total']}">{$info['total']}</span></td>
									{assign var='previndex' value=$curindex}
								{/foreach}
								{for $i = 1 to $HEADERLENGTH-$previndex-1}
									<td align="right"></td>
								{/for}
							</tr>
						{/if}
					</tbody>
				</table>
			</div>
		</div>
	{/if}
</form>
<script type="text/javascript">
setContentHeight();
</script>