<form name="selectall" method="POST">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="small">
		<tr>
			<td style="padding:0px;" colspan=3>
				<div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
					<div style=" visibility: visible; top: 194px;overflow:hidden" id="resize_header_table_divid" name="resize_header_table_divid">
						<div  style="float:left; padding-right:20px">
							<table id="resize_header_tableid" name="resize_header_tableid" class="chengya-table-content" border=0 cellspacing=1 cellpadding="0" style="width:{$WIDTH}px;" >
								<tbody>
								<tr>
									{foreach item=info from=$HEADER}
										<th style="width:{$info.width};">{$info.label}</th>
									{/foreach}
								</tr>
								{foreach key=id item=info from=$LISTENTITY}
									<tr class="lvtColData">
										<td>{$info.fnumber}</td>{*物料编码*}
										<td>{$info.fname}</td>{*物料名称*}
										<td>{$info.fpecification}</td>{*规格型号*}
										<td>{$info.fbaseqty}</td>
										<td>{$info.fbaseavbqty}</td>
										<td>{$info.fstockstatusid}</td>{*库存状态*}
										<td>{$info.stockname}</td>{*库存组织*}
										<td>{$info.zuzhi}</td>{*库存组织*}
									</tr>
									{foreachelse}
									<tr align="center" style="">
										<td colspan="8" bgcolor="#fff" style="height:0px;padding: 0;">
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
											{include file="NoRecords.tpl" NoRecords_STYLE = 'position: relative;top:0;left:0;'}
										</td>
									</tr>
								{/foreach}
								</tbody>
							</table>
						</div>
					</div>
				</div>
</form>
<script type="text/javascript">
	setContentHeight();
</script>