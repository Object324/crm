<!--修改编码格式:统一编码：UTF-8-->
<form name="frmsendpayment" method="post" class="noMargin">
<input type="hidden"  name="module"  value="Potentials"/>
<input type="hidden" name="edittype" value="{$EDITYPE}">
<input type="hidden" name="parenttab" value="Finical">
<input  type="hidden" name="record" value="{$POTENTIALID}"/>
<input  type="hidden" name="receivablesforecastid" value="{$REID}"/>
<input  type="hidden" name="MassPaymentPlan" value="yes"/>
<input type="hidden" name="NowDate" value="{$NOWDATE}"/>
<input  type="hidden" name="startPeriodTime" value="{$PERIODTIME}" id="startPeriodTime"/>
<input type="hidden" id="DeployValue" name="DeployValue" value="{$DEPLOYVALUE}" />
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td width="160" align="right">
                <span>{'Currency'|@getFixedLabel}</span>
            </td>
            <td>
                <input type="hidden" id="before_currency_id" name="before_currency_id" value="{$CURRENCYID}" />
				<select name="currency_id" tabindex="" class="borderALL hlineheight29" fieldonly='0' onchange="ChangeCurrency(this)">
                    {foreach key=currency_id item=currency from=$ALLCURRENCY}
						<option {if $CURRENCYID eq $currency.curid} selected {/if} value="{$currency.curid}">{$currency.currencylabel|@getTranslatedCurrencyString}</option>
					{/foreach}
                </select>
			</td>
        </tr>
        <tr>
			<td align="right">
                <span>{'TotalAmount'|@getFixedLabel}</span>
            </td>
            <td>
				<input type="text" readonly="true" name="potentialamount1" size="40" value="{$FORMATPOTENTIALAMOUNT}" class="detailedViewTextBox"/>
                <input type="hidden" readonly="true" name="potentialamount" size="40" value="{$POTENTIALAMOUNT}"/>
			</td>
        </tr>
		<tr>
            <td align="right">
				<span>{'PredictableAmount'|@getFixedLabel}</span>
            </td>
            <td>
				<span id="nopaymentamount1" name="nopaymentamount1">{$NOPOPRECEIVABLESFORECASTAMOUNT}</span>
				<input type="hidden" readonly="true" name="nopaymentamount" size="40" value="{$NOPOPRECEIVABLESFORECASTAMOUNT}" class="detailedViewTextBox"/>
			</td>
        </tr>