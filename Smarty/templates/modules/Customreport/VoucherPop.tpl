<!--修改编码格式:统一编码：UTF-8-->
{if $CONFIG eq 1}
	<div class="D_pop_content" style="padding:0px;">
		<div style="text-align:left;padding-left:8px;padding-top:8px;">{'TheserviceperiodhassynchronousgenerationofKingdee'|@getFixedLabel}？</div>
	<div>
	<div class="D_pbtn">
		<input id="report-save-sort-2" class="D_pbtnok" value="保存" type="button" onclick="SaveVoucher(this,'update')">
		<span> </span>
		<input id="report-hide-sort" class="D_pbtncancel" onclick="CancelVoucher(this)" value="取消" type="button">
	</div>
{else}
	<input id="startdate" name="startdate" value = "{$STARTDATE}" type="hidden" />
	<input id="enddate"  name="enddate" value = "{$ENDDATE}" type="hidden" />
	<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
		<tr>
			<td class="DetailedTd1Label" width="30%" align='right'>
			   {'Businessdate'|@getFixedLabel}
			</td>
			<td class="DetailedTd2Info" width="70%">
				<input id="voucherdate" tag="{'Businessdate'|@getFixedLabel}" class="Wdate" size="13" value="{$DATE}" name="voucherdate" onclick="WdatePicker()" type="text">
			</td>
		</tr>
		<tr>
			<td class="DetailedTd1Label" width="30%" align='right'>
				{'Singleplayer'|@getFixedLabel}
			</td>
			<td class="DetailedTd2Info" width="70%">
				<select name="single_userid" id="single_userid" tag="{'Singleplayer'|@getFixedLabel}" style="width:100px;">
				<option value=""></option>
				{foreach item=fname key=fid from=$USERS}
					<option value="{$fid}">{$fname}</option>
				{/foreach}
				</select>
			</td>
		</tr>
	</table>
	<div class="D_pbtn">
		<input id="report-save-sort-2" class="D_pbtnok" value="保存" type="button" onclick="SaveVoucher(this,'create')">
		<span> </span>
		<input id="report-hide-sort" class="D_pbtncancel" onclick="javascript:fninvshnew('voucherheader');" value="取消" type="button">
	</div>
{/if}
<div id="Demo_List">

</div>