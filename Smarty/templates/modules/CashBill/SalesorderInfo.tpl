<!--修改编码格式:统一编码：UTF-8-->
<form name="frmpaymentplan" method="post" action="index.php" class="noMargin">
	<input type="hidden" name="module" value="PaymentPlan"/>
	<input type="hidden" name="parenttab" value="Finical"/>
	<input type="hidden" name="record" value="{$SALESORDERID}"/>
	<input type="hidden" name="cust" value="{$ACCOUNTID}"/>
	<input type="hidden" name="MassPaymentPlan" value="yes"/>
	<input type="hidden" name="NowDate" value="{$NOWDATE}"/>
	<input type="hidden" name="entitytype" value="{$FROMMODULE}"/>
	<input type="hidden" name="startPeriodTime" value="{$PERIODTIME}" id="startPeriodTime"/>
	<input type="hidden" id="DeployValue" name="DeployValue" value="{$DEPLOYVALUE}" />
    <input type="hidden" readonly="true" name="paymenttypevalue" value="{$PAYMENTTYPEVALUE}"/>{*ls 2010-11-04 当模块Project关闭时，paymenttypevalue为noproject。重算期次页面有错误，参考bug：48559,*}
	<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;">
		<input size="60" type="hidden" style="text-overflow: ellipsis;border:1px solid #ccc" readonly="true" value="{$ACCOUNTNAME}" name="accountname" />
        <input type="hidden" readonly="true" style="border:1px solid #ccc" size="40" name="salesorderno" value="{$SALESORDERNO}"/></td>
		{if $PAYMENTTYPEVALUE eq 'no'}
			<input type="hidden" value="计划回款日期" id="paymenttype" name="paymenttype" />
		{elseif $PAYMENTTYPEVALUE eq 'noproject'}
			<td class="ld-form-item-label">
                <span>{$PAYMENTTYPE}</span>
            </td>
			<td class="ld-form-item-content">
				<input type="hidden" name="paymenttype" id="paymenttype" value="计划回款日期" />计划回款日期
			</td>
		{else}
			<tr>
				<td class="ld-form-item-label">
					<span>{$PAYMENTTYPE}</span>
				</td>
				<td class="ld-form-item-content">
					<select name="paymenttype" id="paymenttype" tabindex="" class="ld-select-inner gwidth30" fieldonly='0' >
						{foreach item=val from=$PAYMENTTYPEPICK}
							<option value="{$val}" {if $PAYMENTTYPEVALUE eq $val}selected{/if}>{$val}</option>
						{/foreach}
					</select>
				</td>
			</tr>
		{/if}
		<tr>
			<td class="ld-form-item-label">
                <span>{'Currency'|@getFixedLabel}</span>
            </td>
			<td class="ld-form-item-content">
                <input type="hidden" id="before_currency_id" name="before_currency_id" value="{$CURRENCYID}" />
				<select name="currency_id" tabindex="" class="ld-select-inner gwidth30" fieldonly='0' onchange="ChangeCurrency(this)">
                    {foreach key=currency_id item=currency from=$ALLCURRENCY}
						<option {if $CURRENCYID eq $currency.curid} selected {/if} value="{$currency.curid}">{$currency.currencylabel|@getTranslatedCurrencyString}</option>
					{/foreach}
                </select>
				{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" href="javascript:;" style="margin: 0;padding-top: 6px;" onclick="getLinksUrl('SalesOrder','create_paymentplan','create_paymentplan');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
			</td>
        </tr>
        <tr>
			<td class="ld-form-item-label">
                <span>{'SALESORDERAMOUNT'|@getFixedLabel}</span>
            </td>
			<td class="ld-form-item-content">
                <span id="salesorderamount1">{$formatSALESORDERAMOUNT}</span><input type="hidden" readonly="true" name="salesorderamount" value="{$SALESORDERAMOUNT}"/>
            </td>
        </tr>
        <tr>
			<td class="ld-form-item-label">
				<span>{'UNPLANAMOUNT'|@getFixedLabel}</span>
            </td>
			<td class="ld-form-item-content">
				<span id="nopaymentamount1">{$formatNOPAYMENTAMOUNT}</span><input type="hidden" readonly="true" name="nopaymentamount" value="{$NOPAYMENTAMOUNT}"/>
            </td>
        </tr>
		<tr>
			<td class="ld-form-item-label">
                <span>{$PLANDASSIGNEDTO}</span>
            </td>
			<td class="ld-form-item-content">
            	<input type="hidden" value="{$smownerid}" id="SmOwnerSearchScope" name="SmOwnerSearchScope">
			</td>
		</tr>