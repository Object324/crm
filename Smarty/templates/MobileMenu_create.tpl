<div class="divPopOverflow">
<input type="hidden" id="menu_id" name="menu_id" value="{$MENUID}" />
<input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}" />
<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
	<tbody>
		<tr>
			<td class="ld-form-item-label" style="width: 210px;">
				<font color="red">*</font>{'linenumber'|@getFixedLabel}
			</td>
			<td class="ld-form-item-content">
				<select class="ld-select-inner" id="linenumber" name="linenumber">
					{foreach item=row key=key from=$ARRAYLINE}
					<option value="{$row}" {if $LINENUMBER eq $row}selected{/if}>{$row}</option>
					{/foreach}
				</select>
			</td>
		</tr>
		<tr>
			<td class="ld-form-item-label">
				<font color="red">*</font>{'rownumber'|@getFixedLabel}
			</td>
			<td class="ld-form-item-content">
				<select class="ld-select-inner" id="rownumber" name="rownumber">
					<option value="1" {if $ROWNUMBER eq 1}selected{/if}>1</option>
					<option value="2" {if $ROWNUMBER eq 2}selected{/if}>2</option>
					<option value="3" {if $ROWNUMBER eq 3}selected{/if}>3</option>
				</select>
			</td>
		</tr>
		<tr>
			<td class="ld-form-item-label">
				<font color="red">*</font>{'LBL_FIELDNAME'|@getFixedLabel}
			</td>
			<td class="ld-form-item-content">
				<select class="ld-select-inner" id="columnname" name="columnname" tag="{'LBL_FIELDNAME'|@getFixedLabel}">
					<option value="">--{'NONE'|@getFixedLabel}--</option>
					{foreach key = number item = value from =$ALLFIELDS name=pname}
						<option value="{$value.columnname}" {if $COLUMNNAME eq $value.columnname} selected {/if}>{$value.fieldlabel}</option>
					{/foreach}
				</select>
			</td>
		</tr>
		<tr>
			<td class="ld-form-item-label">
				<font color="red">*</font>{'WHETHERTOENABLE'|@getFixedLabel}
			</td>
			<td class="ld-form-item-content">
				<input type="checkbox" class="second_switch" id="presence" name="presence" {if $PRESENCE neq 1}checked{/if} />
			</td>
		</tr>
		<tr>
			<td class="ld-form-item-label">
				<font color="red">*</font>{'MOBILELISTSHOWFIELDNAME'|@getFixedLabel}
			</td>
			<td class="ld-form-item-content">
				<input type="checkbox" class="second_switch" id="showtag" name="showtag" {if $SHOWTAG neq 'no'}checked{/if} />
			</td>
		</tr>
		<tr>
			<td class="ld-form-item-label">
				{'WhetherQueryBasedOnField'|@getFixedLabel}
			</td>
			<td class="ld-form-item-content">
				<input type="checkbox" class="second_switch" id="isforsearch" name="isforsearch" {if $ISFORSEARCH neq 'no'}checked{/if} {if $ISFORSEARCH_DISABLED eq 'yes'}disabled{/if}/>
			</td>
		</tr>
	</tbody>
</table>
</div>