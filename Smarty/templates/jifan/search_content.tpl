<form name="selectall" method="POST">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="small">
   	<tr>
	    <td style="padding:0px;" colspan=3>


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
							<td>{$info.fnumber}</td>
							<td>{$info.fname}</td>
							<td>{$info.fmneminiccode}</td>
							<td>{$info.stickname}</td>
							<td>{$info.fbaseavbqty}</td>
							<td>{$info.pihao}</td>
							<td>{$info.fproducedate}</td>
							<td>{$info.fexpirydate}</td>
							<td>{$info.fpecification}</td>
							<td>{$info.danwei}</td>
							
							<td>{$info.duzhi}</td>
						</tr>
					{foreachelse}
							<tr align="center" style="">
								<td colspan="30" bgcolor="#efefef" style="height:0px;padding: 0;">
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