<!--修改编码格式:统一编码：UTF-8-->
<form name="frmsendpayment" method="post" action="index.php" class="noMargin">
    <input type="hidden" name="module" value="SendPayment"/>
    <input type="hidden" name="parenttab" value="Finical">
    <input type="hidden" name="record" value="{$PURCHASEORDERID}"/>
    <input type="hidden" name="entitytype" value="{$ENTITYTYPE}"/>
    <input type="hidden" name="cust" value="{$VENDORID}"/>
    <input type="hidden" name="MassPaymentPlan" value="yes"/>
    <input type="hidden" name="NowDate" value="{$NOWDATE}"/>
    <input type="hidden" name="startPeriodTime" value="{$PERIODTIME}" id="startPeriodTime"/>
    <input type="hidden" id="DeployValue" name="DeployValue" value="{$DEPLOYVALUE}" />
    <input type="hidden" size="40" readonly="true" value="{$VENDORNAME}" name="vendorname"/>
    <input type="hidden" readonly="true" size="40" name="purchaseorderno" value="{$PURCHASEORDERNO}"/>
	<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;">
        <tr>
            <td class="ld-form-item-label">
                <span>{'Currency'|@getFixedLabel}</span>
            </td>
            <td class="ld-form-item-content">
                <input type="hidden" id="before_currency_id" name="before_currency_id" value="{$CURRENCYID}" />
				<select name="currency_id" tabindex="" class="ld-select-inner gwidth30" fieldonly='0' onchange="ChangeCurrency(this)" >
                    {foreach key=currency_id item=currency from=$ALLCURRENCY}
						<option {if $CURRENCYID eq $currency.curid} selected {/if} value="{$currency.curid}">{$currency.currencylabel|@getTranslatedCurrencyString}</option>
					{/foreach}
                </select>
			</td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                <span>{if $ENTITYTYPE eq 'PurchaseOrder'}{'PurchaseOrder'|@getTranstab}{else}{'PurchaseInvoice'|@getTranstab}{/if} {'AMOUNT'|@getFixedLabel}</span>
            </td>
            <td class="ld-form-item-content">
				<span id="purchaseorderamount1">{$FORMATPURCHASEORDERAMOUNT}</span><input type="hidden" readonly="true" name="salesorderamount" size="40" value="{$SALESORDERAMOUNT}"/>
			</td>
        </tr>
		<tr>
            <td class="ld-form-item-label">
				<span>{'UNPLANAMOUNT'|@getFixedLabel}</span>
            </td>
            <td class="ld-form-item-content">
				<span id="nopaymentamount1">{$FORMATNOPAYMENTAMOUNT}</span><input type="hidden" readonly="true" name="nopaymentamount" size="40" value="{$NOPAYMENTAMOUNT}"/>
			</td>
        </tr>
		<tr>
            <td class="ld-form-item-label">
                <span>{'SendPayment'|@getTranstab} {$PLANDASSIGNEDTO}</span>
            </td>
            <td class="ld-form-item-content">
            <input type="hidden" value="{$SelectedOwner2}" id="SmOwnerSearchScope" name="SmOwnerSearchScope">
			
            </td>  
        </tr>