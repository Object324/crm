<table class="DetailContentTable linefeed" width="100%" cellspacing="0" cellpadding="0" border="0">
	<tr>
		<td>
			<table class="listEntries fir-center" border="0" cellpadding="0" cellspacing="0" width="100%;">
				<tr class="lvtColData">
					<th style="width:10%">工单号码</th>
					<th style="width:10%;">工单主状态</th>
					<th style="width:15%;">工单子状态</th>
					<th style="width:30%;">订单号码</th>
					<th style="width:10%;">进线号码</th>
					<th style="width:10%">来电方</th>
					<th style="width:10%">工单来源</th>
					<th style="width:10%">创建时间</th>
					<th style="width:10%">订单城市</th>
				</tr>
				
				{if $ORDERLISTLOG|@count gt 0}
					{foreach item=arr key=key from=$ORDERLISTLOG}
						<tr class="lvtColData">
							<td><span><a href="javascript::;" title="{$arr.account_no}" fieldname="account_no" referencemodule="Accounts" referencerecord="{$arr.accountid}" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record={$arr.accountid}" onclick="OpenTabDetailView(ld(this),event)">{$arr.account_no}</a></span></td>
							<td><span title="{$arr.cf_2880}">{$arr.cf_2880}</span></td>
							<td><span title="{$arr.cf_2882}">{$arr.cf_2882}</span></td>
							<td><span title="{$arr.cf_2834}">{$arr.cf_2834}</span></td>
							<td><span title="{$arr.accountname}">{$arr.accountname}</span></td>
							<td><span title="{$arr.industry}">{$arr.industry}</span></td>
							<td><span title="{$arr.leadsource}">{$arr.leadsource}</span></td>
							<td><span title="{$arr.createdtime}">{$arr.createdtime}</span></td>
							<td><span title="{$arr.bill_city}">{$arr.bill_city}</span></td>
						</tr>
					{/foreach}
				{else}
					<tr class="lvtColData">
						<td align="center" colspan="9" style="height:0px;padding: 0;">
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
			
		</td>
	</tr>
	
</table>