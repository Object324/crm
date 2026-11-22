<script language="JavaScript" type="text/javascript" src="include/js/modules/Accounts/publicAccounts.js?v={$GLOBALMINVERSION}"></script>
<div class="ld-pop-container ld-table-container ld-table-container-lines">
	<div style="max-height:350px;width: 100%;overflow-y:auto;" id="dv_scroll">
		<table class="" width="100%" cellspacing="0" cellpadding="0" border="0" name="viewpublicaccount_table">
			<thead>
				<tr>
					<th>{'MAILNAME'|@getFixedLabel}</th>
					<th style="width: 20%;">{'Set_Default'|@getFixedLabel}</th>
					<th style="width: 22%;">{'OPERATING'|@getFixedLabel}</th>
				</tr>
			</thead>
			<tbody>
			{assign var="i" value=0}
			{foreach key=pool_id item=pool_info from=$DATA}
				{assign var="j" value=$i++}
				<tr class="ld-category-draggable" pool_id="{$pool_id}" name="tr_pool_id_{$pool_id}" accounttype="{$pool_info.accounttype}">
					<td><span name="td_pool_name_{$pool_id}">{$pool_info.pool_name}</span></td>
					<td>
						<input name="set_default_pool" pool_id="{$pool_id}" {if $pool_info.default_pool eq 'yes'}checked=""{/if} type="checkbox" class="second_switch" style="margin-left: 5px;" onclick="publicAccounts.getInstance().SetDefaultPool(this)">
					</td>
					{if $pool_id gt 1}
						<td class="sort_td">
							<div class="displayflex flexcenter">
								<a class="tip-items-list" href="javascript:void(0);" tag="edit" pool_id="{$pool_id}" onclick="publicAccounts.getInstance().account_public_pool(ld(this),event);" data-tip="{'EDIT'|@getFixedLabel}" data-direction="top" data-type="position">
									<i class="ld-fonticon ld-fonticon-edit"></i>
								</a>
								<a class="tip-items-list" href="javascript:void(0);" tag="delete" pool_id="{$pool_id}" onclick="publicAccounts.getInstance().del_account_public_pool(ld(this),event);" style="margin-left:8px;" data-tip="{'DELETE'|@getFixedLabel}" data-direction="top" data-type="position">
									<i class="ld-fonticon ld-fonticon-del"></i>
								</a>
								<a class="ld-category-icon ld-category-drag drag-handle tip-items-list" style="cursor: move;" data-tip="{'drag'|@getFixedLabel}" data-direction="right" data-type="position"></a>
							</div>
						</td>
					{else}
						<td>
							<div class="displayflex flexcenter">
								<a class="tip-items-list" href="javascript:void(0);" tag="edit" pool_id="{$pool_id}" onclick="publicAccounts.getInstance().account_public_pool(ld(this),event);" data-tip="{'EDIT'|@getFixedLabel}" data-direction="top" data-type="position">
									<i class="ld-fonticon ld-fonticon-edit"></i>
								</a>
								<a class="ld-category-icon ld-category-drag drag-handle tip-items-list" style="cursor: move;{if $DATA|@sizeof <= 1}display:none;{/if}" data-tip="{'drag'|@getFixedLabel}" data-direction="right" data-type="position"></a>
							</div>
						</td>
					{/if}
				</tr>
			{/foreach}
		</tbody>
		</table>
	</div>
	<div class="padT20 ld-btn-icontext-items">
		<div class="ld-btn-icontext-item" href="javascript:void(0);" tag="create" pool_id="0" onclick="publicAccounts.getInstance().account_public_pool(ld(this),event);"><i class="ld-fonticon ld-fonticon-add"></i><span>{'createpublicaccountpool'|@getFixedLabel}</span></div>
		{if $IS_ADMIN eq 'yes'}
			&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
			<div class="ld-btn-icontext-item" href="javascript:void(0);" onclick="cls_PublicAccount.set_account_public();"><i class="ld-fonticon ld-fonticon-set"></i><span>{'Highseasparametersetting'|@getFixedLabel}</span></div>
		{/if}
	</div>
</div>
