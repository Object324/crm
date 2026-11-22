<!--修改编码格式:统一编码：UTF-8-->
<div class="skxxbill">
    <div class="DivCName DivCNamehover" tag="headblock-title" style="border-bottom:1px solid #ddd;"  onclick="showHideStatus('CashBillrelatemessagediv','CashBillrelatemessagespan')">
        <span id="CashBillrelatemessagespan"></span>{'GATHERINGINFORMATION'|@getFixedLabel}
    </div>
    <!--<div class="skxxbill_t">{'GATHERINGINFORMATION'|@getFixedLabel}</div>-->
     <div class="divSocallProduct" id="CashBillrelatemessagediv" style="display: block;">
     {if 'PaymentPlan'|@vtlib_isModuleActive eq true && $ISSOURCEMODULE eq 'SalesOrder'}
     <table id="PaymentList" class="ProductTab" width="150%" border="0" cellpadding="0" cellspacing="0">
     {else}
     <table id="PaymentList" class="ProductTab" width="100%" border="0" cellpadding="0" cellspacing="0">
     {/if}
      <tr class="Tdhead">       
        <td>{$ISSOURCEMODULE|@getTranstab}</td>
        <td>{'SALESORDERCONTRACTAMOUNT'|@getFixedLabel}</td>
        <td>{'RECEIVED'|@getFixedLabel}{'SLAESORDERTOTAL'|@getFixedLabel}</td>
        {if 'PaymentPlan'|@vtlib_isModuleActive eq true && $ISSOURCEMODULE eq 'SalesOrder'}
            <td>{$ARRFIELDLABEL.paymentplan_no}</td>
            <td>{$ARRFIELDLABEL.plandate}</td>
            <td>{$ARRFIELDLABEL.periodtime}</td>
            <td>{$ARRFIELDLABEL.amount}</td>
            <td>{$ARRFIELDLABEL.actualamount}</td>
        {/if}
        <td>{'INVOICENO'|@getFixedLabel}</td>
        <td>{'THENEWINVOICEDATE'|@getFixedLabel}</td>
        <td>{'HASBILLINGAMOUNT'|@getFixedLabel}</td>
        <td>{'THEAMOUNTCOLLECTED'|@getFixedLabel}</td>
      </tr>
      {$PAYMENTLIST}
      <tr>
       {assign var=payment value='PaymentPlan'|@getTranstab}
        <td style="text-align:right" colspan="{$TABLECOSPLAN}"><strong>{'SUBTOTAL'|@getFixedLabel}</strong></td>
        <td>{$TOTALHAVEEPAYMENTAMOUNT}</td>
      </tr>
      <tr>
        <td style="text-align:right" colspan="{$TABLECOSPLAN}"><strong>{'Adjustment'|@getFixedLabel}</strong></td>
        <td>{$TOTALNOPAYMENTAMOUNT}</td>
      </tr>
      <tr>
        <td style="text-align:right" colspan="{$TABLECOSPLAN}"><strong>{'SUM'|@getFixedLabel}</strong></td>
        <td>{$TOTALPAYMENTAMOUNT}</td>
      </tr>

    </table>
    </div>
	
</div>