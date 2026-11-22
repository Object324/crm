<!--修改编码格式:统一编码：UTF-8-->
<form name="frmpaymentplan" method="post" action="index.php" class="noMargin">
	<input type="hidden"  name="module"  value="PaymentPlan"/>
	<input type="hidden" name="parenttab" value="Finical"/>
	<input  type="hidden" name="record" value="{$SERVICESONTRACTSID}"/>
	<input type="hidden" name="cust" value="{$ACCOUNTID}"/>
	<input  type="hidden" name="MassPaymentPlan" value="yes"/>
	<input type="hidden" name="NowDate" value="{$NOWDATE}"/>
	<input type="hidden" name="entitytype" value="ServiceContracts"/>
	<input  type="hidden" name="startPeriodTime" value="{$PERIODTIME}" id="startPeriodTime"/>
	<input type="hidden" id="DeployValue" name="DeployValue" value="{$DEPLOYVALUE}" />
	<input type="hidden" readonly="true" value="{$ACCOUNTNAME}" name="accountname" />
	<input type="hidden" readonly="true" name="salesorderno" value="{$SERVICESONTRACTSID}"/>
	<input type="hidden" readonly="true" name="paymenttypevalue" value="{$PAYMENTTYPEVALUE}"/>{*ls 2010-11-04 当模块Project关闭时，paymenttypevalue为noproject。重算期次页面有错误，参考bug：48559,*}
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
		{if $PAYMENTTYPEVALUE eq 'no'}
			<input type="hidden" value="计划回款日期" name="paymenttype" />
		{elseif $PAYMENTTYPEVALUE eq 'noproject'}
			<td width="230" align="right">
                <span>{$PAYMENTTYPE}</span>
            </td>
            <td>
				<input type="hidden" name="paymenttype" value="计划回款日期" />计划回款日期
			</td>
		{else}
			<tr>
				<td width="230" align="right">
					<span>{$PAYMENTTYPE}</span>
				</td>
				<td>
					<select name="paymenttype" id="paymenttype" tabindex="" class="commonSelectPop" fieldonly='0' onchange="changeListHeader(this)">    
						{foreach item=val from=$PAYMENTTYPEPICK}
							<option value="{$val}" {if $PAYMENTTYPEVALUE eq $val}selected{/if}>{$val}</option>
						{/foreach}
					</select>
				</td>
			</tr>
		{/if}
		<tr>
            <td align="right">
                <span>{'Currency'|@getFixedLabel}</span>
            </td>
            <td>
                <input type="hidden" id="before_currency_id" name="before_currency_id" value="{$CURRENCYID}" />
				<select name="currency_id" tabindex="" class="commonSelectPop" fieldonly='0' onchange="ChangeCurrency(this)" >    
                    {foreach key=currency_id item=currency from=$ALLCURRENCY}
						<option {if $CURRENCYID eq $currency.curid} selected {/if} value="{$currency.curid}">{$currency.currencylabel|@getTranslatedCurrencyString}</option>
					{/foreach}
                </select>
				 {if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" href="javascript:;" style="margin: 0;padding-top: 6px;" onclick="getLinksUrl('ServiceContracts','create_paymentplan','create_paymentplan');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
			</td>
        </tr>
		<tr>
            <td align="right">
                <span>{'SERVICECONTRACTSRESULTAMOUNT'|@getFixedLabel}</span>
            </td>
            <td>
                <span id="salesorderamount1">{$formatSERVICECONTRACTSRESULTAMOUNT}</span><input type="hidden" readonly="true" name="salesorderamount" value="{$SERVICECONTRACTSRESULTAMOUNT}"/>
            </td>
        <tr>
			<td align="right">
				<span>{'UNPLANAMOUNT'|@getFixedLabel}</span>
            </td>
            <td>
				<span id="nopaymentamount1">{$formatNOPAYMENTAMOUNT}</span><input type="hidden" readonly="true" name="nopaymentamount" value="{$NOPAYMENTAMOUNT}"/>
            </td>
        </tr>
		<tr>
            <td align="right">
                <span>{'PAYMENTPLANASSIGNED'|@getFixedLabel}</span>
            </td>
			<td>
            <input type="hidden" value="{$SelectedOwner2}" id="SmOwnerSearchScope" name="SmOwnerSearchScope">
				
			</td>
		</tr>   