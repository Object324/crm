<div style="max-height:350px;width: 100%;overflow-y:auto;" id="dv_scroll">
	<table class="ld-public-content-small" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody> 
		<tr>
			<td class="ld-form-item-label" style="width:200px">{'deletetheunassignedpools'|@getFixedLabel}</td>
			<td class="ld-form-item-content"><input type="hidden" name="delete_pool_id" value="{$DELETE_POOL_ID}"><span class="ld-text-inner">{$DELETE_POOL_NAME}</span></td>
		</tr>
		<tr>
			<td class="ld-form-item-label">{'TransferoutToHighSeasPoolOfLeads'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<select name="all_pool" class="ld-select-inner">
					{foreach key=pool_id item=pool_name from=$DATA}
						<option value={$pool_id}>{$pool_name}</option>
					{/foreach}
				</select>
			</td>
		</tr>
		</tbody>
	</table>
</div>