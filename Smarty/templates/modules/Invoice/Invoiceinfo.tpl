<!--修改编码格式:统一编码：UTF-8-->

<form name="frmpaymentplan" method="post" action="index.php" class="noMargin">
<input type="hidden"  name="module"  value="PaymentPlan"/>
<input type="hidden" name="parenttab" value="Finical"/>
<input  type="hidden" name="record" value="{$INVOICEID}"/>
<input type="hidden" name="cust" value="{$ACCOUNTID}"/>
<input  type="hidden" name="MassPaymentPlan" value="yes"/>
<input type="hidden" name="NowDate" value="{$NOWDATE}"/>
<input type="hidden" name="entitytype" value="Invoice"/>
<input  type="hidden" name="startPeriodTime" value="{$PERIODTIME}" id="startPeriodTime"/>
<input type="hidden" id="DeployValue" name="DeployValue" value="{$DEPLOYVALUE}" />
	<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0" style="table-layout: fixed;width: 98%;margin: 7px auto 0;">
       <!--/*
  andrew
  20141008
  改进功能  合同关联创建回款计划  
  */-->
        <!--tr>
            <td colspan='2' >
                <span>{'ACCORDING'|@getFixedLabel} {'ServiceContracts'|@getTranstab} {'CREATE'|@getFixedlabel} {'PaymentPlan'|@getTranstab},{'ADMINCONFIGPAY'|@getFixedLabel}</span>
                {if $ISADMIN eq 'on'}
				    <a href="#" onclick="CashSet(document.getElementById('createPaymentid'),'SetPaymentplan',DetailView.record.value);return false;">{'SETTINGS'|@getFixedLabel}</a>
				{/if}
            </td>
        </tr-->
        <!--tr>
			<td width="20%" align="right" class="DetailedTd1Label">
                <span>{'Accounts'|@getTranstab}</span>
            </td>
            <td-->
				<input size="60" type="hidden" style="text-overflow: ellipsis;border:1px solid #ccc" readonly="true" value="{$ACCOUNTNAME}" name="accountname" />
			<!--/td>
        </tr-->
        <!--tr>
			<td width="20%" align="right" class="DetailedTd1Label">
                <span>{'ServiceContracts'|@getTranstab} {'Numbers'|@getFixedLabel}</span>
            </td>
			<td--><input type="hidden" readonly="true" style="border:1px solid #ccc" size="40" name="salesorderno" value="{$SERVICESONTRACTSID}"/></td>
        <!--/tr-->
		<tr>
            <td width="120" align="right" class="DetailedTd1Label">
                <span>{$PAYMENTTYPE}</span>
            </td>
            <td width="470">
				<input type="hidden" name="paymenttype" value="{$paymenttype}" />{$paymenttype}
			</td>
			
        </tr>
		<tr>
            <td width="120" align="right" class="DetailedTd1Label">
                <span>{'Currency'|@getFixedLabel}</span>
            </td>
            <td width="470">
                <input type="hidden" id="before_currency_id" name="before_currency_id" value="{$CURRENCYID}" />
				<select name="currency_id" tabindex="" class="commonSelectPop" fieldonly='0' onchange="ChangeCurrency(this)" >    
                    {foreach key=currency_id item=currency from=$ALLCURRENCY}
						<option {if $CURRENCYID eq $currency.curid} selected {/if} value="{$currency.curid}">{$currency.currencylabel|@getTranslatedCurrencyString}</option>
					{/foreach}
                </select>
				{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" href="javascript:;" style="margin-right: 7px;margin-top: 1px;" onclick="getLinksUrl('ServiceContracts','create_paymentplan','create_paymentplan');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
			</td>
        </tr>
		<tr>
            <td width="120" align="right" class="DetailedTd1Label">
                <span>{'Invoice'|@getTranstab}{'AMOUNT'|@getFixedLabel}</span>
            </td>
            <td width="470">
                <span id="salesorderamount1">{$formatSERVICECONTRACTSRESULTAMOUNT}</span><input type="hidden" readonly="true" name="salesorderamount" value="{$SERVICECONTRACTSRESULTAMOUNT}"/>
            </td>
        <tr>
			<td width="120" align="right" class="DetailedTd1Label">
				<span>{'UNPLANAMOUNT'|@getFixedLabel}</span>
            </td>
            <td width="470">
				<span id="nopaymentamount1">{$formatNOPAYMENTAMOUNT}</span><input type="hidden" readonly="true" name="nopaymentamount" value="{$NOPAYMENTAMOUNT}"/>
            </td>
        </tr>
		<tr>
            <td width="120" align="right" class="DetailedTd1Label">
                <span>{'PAYMENTPLANASSIGNED'|@getFixedLabel}</span>
            </td>
			<td width="470">
				<input type="hidden" value="{$SelectedOwner2}" id="SmOwnerSearchScope" name="SmOwnerSearchScope">
			</td>
		</tr>
                