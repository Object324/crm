<div class="">
	<table class="D_pop_bod" width="100%" align="center" cellspacing="0" cellpadding="0" border="0" height="200px;">
	   <tr>
		   	<td width="100">
				{'Theallocationway'|@getFixedLabel}
		   	</td>
		   	<td class="select-input">
			   <input type="radio" name="share_type" value="1" {if $SHARESEQUALLYTYPE eq 1}checked{/if} /><label class="padR10">{'shareequally'|@getFixedLabel}</label><input type="radio" name="share_type" value="2" {if $SHARESEQUALLYTYPE eq 2}checked{/if} /><label class="padR10">{'apportionmentofdifferentproportions'|@getFixedLabel}</label>
		   	</td>
		</tr>
		<tr>
		    <td colspan="2" style="height:230px;" valign="top">
				<div style="height: 230px;overflow: auto;clear:both;">
					<input type="hidden" id="sourcemodule_json" value='{$SOURCEMODULEJSON}' />
					<table name="share_table" class="listEntries fir-center" width="100%" cellspacing="1" cellpadding="0" align="center" border="0">
						<tr>
							<th align="center" width="10%">{'OPERATING'|@getFixedLabel}</th>
							<th width="25%">{'SOURCETYPE'|@getFixedLabel}</th>
							<th width="50%" name="share_entitytype_label">{'ORIGNALBILL'|@getFixedLabel}</th>
							<th width="15%" name="percent_label">{'PROPORTTION'|@getFixedLabel}</th>
						</tr>
						{foreach key=rowid item=val from=$SHAREEQUALLYVALUES}
							<tr class="lvtColData" name="list_row_{$rowid}">
								<td align="center"><a class="icon-homeimg icon-sdel" href="javascript:;" tag="{$rowid}" name="delShare_row" title="{'DELETE'|@getFixedLabel}"></a></td>
								<td>
									<select class="ld-select-inner" name="sourcemodule{$rowid}" tag="{$rowid}">
									{foreach key=module item=data from=$SOURCEMODULE}
										{if $data.presence neq 1}
											<option value="{$module}" {if $module eq $val.entitytype} selected="true" {/if}>{$data.label}</option>
										{/if}
									{/foreach}
									</select>
								</td>
								<td class="ld-form-item-content">
									<input class="ld-input-inner ld-input-inner-add" type="text" value="{$val.entitytype_linkvalue}" name="share_entitytype_{$rowid}" readonly=""><input type="hidden" name="share_entitytypeid_{$rowid}" value="{$val.entitytypeid}"><a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" name="selectSourceModule" tag="{$rowid}">+</a><a class="ld-text-clear" title="{'CLEAR'|@getFixedLabel}" name="clearSourceModule" tag="{$rowid}">+</td>
								</td>
								<td class="ld-form-item-content">
									<input type="text" class="ld-input-inner" name="percent_{$rowid}" value="{$val.percent}"><a class="ld-text-span" href="javascript:;">%</a>
								</td>
							</tr>
						{/foreach}
						<tr>
							<td colspan="4" name="share_last_row" style="padding: 0;">
								<a class="Anu3_a" style="padding: 0 15px;line-height: 23px;margin:6px 0px;" name="addShare_row" href="javascript:;">{'NEW'|@getFixedLabel}</a>
							</td>
						</tr>
					</table>
				</div>
		    </td>
	    </tr>
	</table>
</div>