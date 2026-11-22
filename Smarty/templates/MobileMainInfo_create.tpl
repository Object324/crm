<!-- <div class="E_pop_box LdPopWidth400px" style="position: fixed; z-index: 9999; top: 50%; left: 50%; display: block; margin-top: -147.5px; margin-left: -202px;"> -->
	<!-- <div class="E_pop_tit">
		<strong id="createworktpldivtitlename" class="E_ptita">{'MobileAppMainInfoCustomization'|@getFixedLabel}</strong>
		<button id="colse_mobile_maininfo" class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"></button>
	</div> -->
<div class="divPopOverflow">
	<input type="hidden" id="maininfo_id" name="maininfo_id" value="{$MAININFOID}" />
	<input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}" />	
	<table class="ld-public-content-small" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'linenumber'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<select class="ld-select-inner" id="linenumber" name="linenumber">
						<option value="1" {if $LINENUMBER eq 1}selected{/if}>1</option>
						<option value="2" {if $LINENUMBER eq 2}selected{/if}>2</option>
						<option value="3" {if $LINENUMBER eq 3}selected{/if}>3</option>
						<option value="4" {if $LINENUMBER eq 4}selected{/if}>4</option>
						<option value="5" {if $LINENUMBER eq 5}selected{/if}>5</option>
					</select>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'LBL_FIELDNAME'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<select class="ld-select-inner" id="fieldname" name="fieldname" tag="{'LBL_FIELDNAME'|@getFixedLabel}">
						<option value="">--{'NONE'|@getFixedLabel}--</option>
						{foreach key = number item = value from =$ALLFIELDS name=pname}
							<option value="{$value.fieldname}" {if $FIELDNAME eq $value.fieldname} selected {/if}>{$value.fieldlabel}</option>
						{/foreach}
					</select>
				</td>
			</tr>
			<tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'WHETHERTODISPLAY'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
                    <input id="presence" name="presence" {if $PRESENCE neq 1}checked{/if} type="checkbox" class="second_switch" />
				</td>
			</tr>
            <tr>
				<td class="ld-form-item-label">
					<font color="red">*</font>{'MOBILELISTSHOWFIELDNAME'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
                    <input id="showtag" name="showtag" {if $SHOWTAG neq 'no'}checked{/if} type="checkbox" class="second_switch" />
				</td>
			</tr>
		</tbody>
	</table>
</div>
	<!-- <div class="E_pbtn">
		<input class="E_pbtnok" value="确认" type="button" id="save_mobile_maininfo">
		<span> </span>
		<input class="E_pbtncancel" value="取消" type="button" id="cancel_mobile_maininfo">
	</div> -->
<!-- </div> -->