<input type="hidden" name="base_currency" value="{$base_currency}" />
<input type="hidden" name="base_conversion_rate" value="{$base_currency}" />
<input type="hidden" name="price_decimal" value="{$price_decimal}" />
<table class="D_pop_bod listEntries" border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<th>{'Currency'|@getFixedLabel}{$MASS_EDIT}</th>            
		<th>{'Price'|@getFixedLabel}</th>
		<th>{'CONVERSIONRATE'|@getFixedLabel}</th>
		<th>{'RPrice'|@getFixedLabel}</th>
		<th style="display:none">{'Base_Currency'|@getFixedLabel}</th>
	</tr>
	{foreach item=price key=count from=$price_detail}
		<tr>
			{if $price.check_value eq 1 || $price.is_basecurrency eq 1}
				{assign var=check_value value="checked"}
				{assign var=disable_value value=""}
			{else}
				{assign var=check_value value=""}
				{assign var=disable_value value="disabled=true"}
			{/if}

			{if $price.is_basecurrency eq 1}
				{assign var=base_cur_check value="checked"}
			{else}
				{assign var=base_cur_check value=""}
			{/if}

			{if $price.curname eq $base_currency}
				{assign var=call_js_update_func value="updateUnitPrice('$base_currency', '$fldname');"}
			{else}
				{assign var=call_js_update_func value=""}
			{/if}
			{*BUG0069033 txy 20230719 产品管理，“产品报价”和“参考成本价”字段，更多币种界面优化1、复选框优化2、文本输入框优化3、重算价格按钮优化*}
			<td class="select-input">
				<input id="currencystring_{$price.curid}" type="checkbox"  {if $price.curid eq 1}disabled="true"{/if} name="{$fldname}_cur_{$price.curid}_check" onclick="fnenableDisable(this,'{$price.curid}','{$fldname}'); updateCurrencyValue(this,'{$price.curname}','{$fldname}','{$price.conversionrate}');" {$check_value}/>
				<label for="currencystring_{$price.curid}">{$price.currencylabel|@getTranslatedCurrencyString} ({$price.currencysymbol})</label>
            </td>
			<td>
				{*BUG0069946 wym 20230724 kfbcrm-产品管理->更多币种 输入无效数字点击保存 页面出现NaN *}
				<input {$disable_value} type="text" size="10" class="ld-input-inner" name="{$price.curname}" value="{$price.curvalue}" onkeyup="value=value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');"/>
			</td>
			<td>
				<input disabled=true type="text" size="10" class="ld-input-inner" name="{$fldname}_cur_conv_rate{$price.curid}" value="{$price.conversionrate}"/>
			</td>
			<td align="center">
				<div class="ld-button ld-button-primary" name="cur_reset{$price.curid}" onclick="resetCurrencyValue(this,'{$price.curname}','{$fldname}','{$price.conversionrate}');">{'RePrice'|@getFixedLabel}</div>
			</td>
			<td style="display:none">
				<input {$disable_value} type="radio" name="base_currency_input" value="{$price.curname}" {$base_cur_check} onchange="updateBaseCurrencyValue()" />
                <input type="text" style="display:none" value="{$price.curid}" name="base_currency_curid"/>
			</td>
		</tr>
	{/foreach}
</table>