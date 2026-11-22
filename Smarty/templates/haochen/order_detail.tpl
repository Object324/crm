<div class="main_grid_top">	
		<div class="clear"></div>
		<div class="divButtons">
			<div class="PageDiv0">
				<ul>
					<input id="curPage" name="page" style="width:50px;margin-right:4px;" type="hidden" value="{$PAGE}">
					<li> 共 {$total_nums} 条记录</li>
					{if $PREVPAGE eq 'yes'}
						<li><span class="icon-prevpage" title="上一页" onclick="lastPage();"></span></li>
					{else}
						<li><span class="no-icon-prevpage"></span></li>
					{/if}
					<li class="Input">{$PAGE}/{$total_pages}</li>
					{if $NEXTPAGE eq 'yes'}
						<li><span class="icon-nextpage" title="下一页" onclick="nextPage();"></span></li>
					{else}
						<li><span class="no-icon-nextpage"></span></li>
					{/if}
				</ul>
			</div>
		</div>
		<div class="clear"></div>
	</div>
<form name="selectall" method="POST">

	<input type="hidden" id="list_num" value="{$LISTLEN}">
	<!--end-->
	<div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="overflow: auto;overflow-y: auto; width: {$ALLWIDTH}px;position: relative;">
		<!--<div style=" visibility: visible; top: 194px;overflow:hidden;" id="resize_header_table_divid" name="resize_header_table_divid">
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
		</div>-->
		<div style="overflow:auto;" id="resize_content_table_divid" name="resize_content_table_divid">
			<table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid" name="resize_content_tableid" style="width:{$WIDTH}px;" class="listEntries" >
				<tbody>
					<tr>
						{foreach item=info from=$HEADER}
							<th style="width:{$info.width};">{$info.label}</th>
						{/foreach}
					</tr>
					{foreach key=id item=info from=$LISTENTITY}
						{if $info.accountid eq -1}
							{assign var="i" value=0} 
						{else}
							{assign var="i" value=$i+1} 
						{/if}
						<tr class="lvtColData">
							<td align="left">
								{if $info.source_list gt 0}
									<a target="_blank" href="index.php?pageto_module=CustomForm14&pageto_action=index&pageto_record={$info.source_list}" onclick="ListReferenceLinkClick(ld(this),event)" title="{$info.order_no}" referencemodule="CustomForm14" referencerecord="{$info.source_list}">{$info.order_no}</a>
								{else}
									{$info.order_no}
								{/if}
							</td>
							<td align="left">{$info.bianhao}</td>
							<td align="left">{$info.sign_date}</td>
							<td align="left">{$info.last_name}</td>
							<td align="left">{$info.accountname}</td>
							<td align="left">{if $info.zhuangtai eq '作废'}<font color="red">{$info.zhuangtai}</font>{else}{$info.zhuangtai}{/if}</td>
							<td align="left">{$info.fangshi}</td>
							<td align="left">{$info.caozuo}</td>

							<td align="left">{if $info.zhuangtai eq '正常'}<input type="button" name="search" onclick="order_con({$info.recordid},{$info.id},'{$info.order_no}');" class="saveauto" value="作废">{else}{/if}</td>
						</tr>
					{foreachelse}
							<tr align="center" style="">
								<td colspan="10" bgcolor="#efefef" style="height:0px;padding: 0;">
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
				</tbody>
			</table>
		</div>
	</div>
</form>

<script type="text/javascript">
setContentHeight();
</script>