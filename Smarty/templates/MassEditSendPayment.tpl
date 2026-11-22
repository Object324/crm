
<form method="post" action="index.php" name="frmsendpayment" class="noMargin">

   
    <div class="billdate">
        <span>{$ARRFIELDLABEL.cashbilldate}:</span>
        <select name="SendCashBillDate" onchange="ChangeSendCashBilldate(this)">
           <option value="curdate">{'CURRENTDATE'|@getFixedLabel}</option>
           <option value="plandate">{$PLANDATELABEL}</option>
           <option value="customdate">{'custom'|@getFixedLabel}</option>
       </select>
       <input type='text' style="display:none;" size='15' onClick="WdatePicker()" class="Wdate" readonly='true' name='cashdate' value='' id='cashdate'/>
    </div>		
   {include file='EditViewHidden.tpl'}
   <input  type="hidden" name="module" value="SendCashBill"/>
   <input  type="hidden" name="action" value="SendCashBillAjax"/>
   <input  type="hidden" name="file" value="MassAdd"/>
   <input type="hidden" name="SearchScope" value="{$SEARCHSCOPE}"/>
   <input type="hidden" name="frmsendpayment_label" value="{'BATCHPAYMENT'|@getFixedLabel}"/>
   <div style="max-height:450px;overflow-y:auto;">
        <table id="MMassSendCashBill" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tr>
            <th align="center" valign="middle"><input name="" type="checkbox" value="" checked="checked" onclick="chkAllSendPayment(this)" /></th>
            <th align="center" valign="middle">{$ARRFIELDLABEL2.sendpayment_no}</th>
            <th align="center" valign="middle">{$VENDORNAMELABEL}</th>
            <th align="center" valign="middle">{$AMOUNTLABEL}</th>
            <th align="center" valign="middle">{$ACTUALAMOUNTLABEL}</th>
            <th align="center" valign="middle">{'THEPAYMENT'|@getFixedLabel}</th>
            <th align="center" valign="middle">{'Currency'|@getFixedLabel}</th>
            {*<th align="center" valign="middle">{$ARRFIELDLABEL.criscashbill}</th>*}
            <th align="center" valign="middle">{$ARRFIELDLABEL.crpaymentmethod}</th>
            <th align="center" valign="middle">{$ARRFIELDLABEL.bankaccountsetid}</th>
          </tr>
          {$MASS_EDIT}
        </table>
   </div>
  
</form>