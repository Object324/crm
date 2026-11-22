
<div class="skxx07">
    <div class="editrelhead"><b>{'COMMISSIONINFO'|@getFixedLabel}</b></div>
     <table class="skxx07_tb" border="0" id="CommissionList">
      <tr>
       {$THHTML}
      </tr>
      {$PAYMENTLIST}
      {if 'PurchaseOrder'|@vtlib_isModuleActive == true}      
          <tr>
            <td style="text-align:right" colspan="{$TABLECOSPLAN}"><strong>{'AMOUNT'|@getFixedLabel}{'SUBTOTAL'|@getFixedLabel}</strong></td>
            <td>{$TOTALHAVEESENDPAYMENTAMOUNT}</td>
          </tr>
      {/if}          
      {*<tr>
        <td style="text-align:right" colspan="8"><strong>{'OTHERPAYMENTS'|@getFixedLabel}</strong></td>
        <td><input type="text" name="nosendpayment" id="nosendpayment" onchange="return NoSendPayment(this)" value="{$TOTALNOSENDPAYMENTAMOUNT}" /></td>
      </tr>*}
      <tr>
        <td style="text-align:right" colspan="{$TABLECOSPLAN}">       
                <strong>{*OTHERPAYMENTS*}{'Adjustment'|@getFixedLabel}</strong>
                <input type="hidden" name="isselect" id="isselect" value="{$ISSELECT}" />
                <input type="hidden" id="totalhaveplaymentamount" name="totalhaveplaymentamount" value="{if $SELCK|@substrTd:3 >= 0 && $SELCK neq ''}{$SELCK|@substrTd:3}{else}{$TOTALHAVEESENDPAYMENTAMOUNT}{/if}" />
                <input type="hidden" id="totalplayment" name="totalplayment" value="{if $SELCK|@substrTd:4 >= 0 && $SELCK neq ''}{$SELCK|@substrTd:4}{else}{$TOTALSENDPAYMENTAMOUNT}{/if}" />
                <select name="otherselect" id="otherselect" onchange="selSendPayment(this.value)">
                    <option value="1" {if $ISSELECT eq 1 } selected {/if}>{'ADD'|@getFixedLabel}</option>
                    <option value="2" {if $ISSELECT eq 2 } selected {/if}>{'DEDUCT'|@getFixedLabel}</option>
                </select>                                       
        </td>        
        <td><input type="text" name="setnoamount" id="setnoamount" onchange="return NoAmount(this)" value="{if $SELCK|@substrTd:2 >0}{$SELCK|@substrTd:2}{else}{$TOTALNOSENDPAYMENTAMOUNT}{/if}" /></td>                
      </tr>     
      <tr>
        <td style="text-align:right" colspan="{$TABLECOSPLAN}"><strong>{'SUM'|@getFixedLabel}</strong></td>
        <td>{$TOTALSENDPAYMENTAMOUNT}</td>
      </tr>
    </table>

	
</div>