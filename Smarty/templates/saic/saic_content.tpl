<div style="overflow: auto; height: 360px;">
<table class="listEntries fir-center" border="0" cellpadding="0" cellspacing="1" width="100%">
	<tr class="lvtColData">
		<th style="width:15%;">操作</th>
		<th style="width:35%;">MIS订单号</th>
		<th style="width:10%;">手机号</th>
		<th style="width:15%;">上车点</th>
		<th style="width:15%;">下车点</th>
		<th style="width:8%;">车牌号</th>
		<th style="width:6%;">城市</th>
		<th style="width:13%;">下单时间</th>
	  </tr>
	{if $ORDERLIST|@count gt 0}
		{foreach item=obj key=key from=$ORDERLIST}
			{assign var=num value=$key+1}
			<tr class="lvtColData">
				<td><input type="radio" value="order" name="source_order_type_{$num}" checked>&nbsp;关联订单&nbsp;<input type="radio" value="driver" name="source_order_type_{$num}">&nbsp;关联司机</td>
				<td><span><a href="javascript::;" title="{$obj->orderId}" onclick="get_saic_orderdetail('{$obj->orderId}',{$num},'{$obj->channelCode}')">{$obj->orderId}</a></span></td>
				<td><span title="{$obj->passengerMobile}">{$obj->passengerMobile}</span></td>
				<td><span title="{$obj->origin}">{$obj->origin}</span></td>
				<td><span title="{$obj->destination}">{$obj->destination}</span></td>
				<td><span title="{$obj->vehicleNo}">{$obj->vehicleNo}</span></td>
				<td><span title="{$obj->cityName}">{$obj->cityName}</span></td>
				<td><span title="{$obj->createTime}">{$obj->createTime}</span></td>
			</tr>
		{/foreach}
	{else}
		<tr class="lvtColData">
			<td align="center" colspan="8" style="height:0px;padding: 0;">
				{* <div class="warningTableContent" style="z-index:600;">
					<div class="wtc_img">
						<img src="themes/icon2023/ld-no-records.png">
						</div>
					<div class="wtc_content">没有找到任何记录</div>
				</div> *}
				{include file="NoRecords.tpl"}
			</td>
		</tr>
	{/if}
</table>
</div>