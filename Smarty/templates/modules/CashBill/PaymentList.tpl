<!--修改编码格式:统一编码：UTF-8-->
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/Paymentplan.css">
<div class="skxx07">
    <div class="editrelhead"><b>{'GATHERINGINFORMATION'|@getFixedLabel}</b></div>
     <table class="skxx07_tb" border="0" id="PaymentList">
      <tr>
        {$THHTML}
        {*<th>{$ARRFIELDLABEL.paymentplan_no}</th>
        <th>{$ARRFIELDLABEL.paymentstatus}</th>
        <th>{$ARRFIELDLABEL.periodtime}</th>
        <th>{$ARRFIELDLABEL.plandate}</th>
        <th>{$ARRFIELDLABEL.amount}</th>
        <th>{$ARRFIELDLABEL.actualamount}</th>
        <th width="200">{'CURRECEIVERMB'|@getFixedlabel}</th>*}
      </tr>
      {$PAYMENTLIST}
      <tr>
      {assign var=payment value='PaymentPlan'|@getTranstab}
        <td style="text-align:right" colspan="{$TABLECOSPLAN}"><strong>{*ACCORDRECEV*}{'RECEIPT'|@getFixedLabel}</strong></td>
        <td>{if $SELCK|@substrTd:3 >= 0 && $SELCK neq ''}{$SELCK|@substrTd:3}{else}{$TOTALHAVEEPAYMENTAMOUNT}{/if}</td>
      </tr>
      <tr>
        <td style="text-align:right" colspan="{$TABLECOSPLAN}">
            <strong>{*OTHERPAYMENTS*}{'Adjustment'|@getFixedLabel}</strong>
            <input type="hidden" name="isselect" id="isselect" value="{$ISSELECT}" />
            <input type="hidden" id="totalhaveplaymentamount" name="totalhaveplaymentamount" value="{if $SELCK|@substrTd:3 >= 0 && $SELCK neq ''}{$SELCK|@substrTd:3}{else}{$TOTALHAVEEPAYMENTAMOUNT}{/if}" />
            <input type="hidden" id="totalplayment" name="totalplayment" value="{if $SELCK|@substrTd:4 >= 0 && $SELCK neq ''}{$SELCK|@substrTd:4}{else}{$TOTALPAYMENTAMOUNT}{/if}" />
            <select name="otherselect" id="otherselect" onchange="selpayment(this.value);">
                {if $SELCK|@substrTd:1 > 0}
                    <option value="1" {if $SELCK|@substrTd:1 eq 1} selected {/if}>{'ADD'|@getFixedLabel}</option>
                    <option value="2" {if $SELCK|@substrTd:1 eq 2} selected {/if}>{'DEDUCT'|@getFixedLabel}</option>
                {else}
                    <option value="1" {if $ISSELECT eq 1 } selected {/if}>{'ADD'|@getFixedLabel}</option>
                    <option value="2" {if $ISSELECT eq 2 } selected {/if}>{'DEDUCT'|@getFixedLabel}</option>
                {/if}
            </select>
        </td>
        <td><input type="text" name="nopaymentplan" id="nopaymentplan" onchange="return nopayment(this)" value="{if $SELCK|@substrTd:2 >0}{$SELCK|@substrTd:2}{else}{$TOTALNOPAYMENTAMOUNT}{/if}" /></td>
      </tr>
      <tr>
        <td style="text-align:right" colspan="{$TABLECOSPLAN}"><strong>{'SUM'|@getFixedLabel}</strong></td>
        <td>{if $SELCK|@substrTd:4 >= 0 && $SELCK neq ''}{$SELCK|@substrTd:4}{else}{$TOTALPAYMENTAMOUNT}{/if}</td>
      </tr>

    </table>

	
</div>
