<!--修改编码格式:统一编码：UTF-8-->
<div class="skxxbill">
    <div class="DivCName DivCNamehover" style="border-bottom:1px solid #ddd;"  onclick="showHideStatus('SendCashBillrelatemessagediv','SendCashBillrelatemessagespan')">
        <span id="SendCashBillrelatemessagespan"></span>{'PAYMENTINFORMATION'|@getFixedLabel}
    </div>
    <!--<div class="skxxbill_t">{'PAYMENTINFORMATION'|@getFixedLabel}</div>-->
    <div class="divSocallProduct" id="SendCashBillrelatemessagediv" name="detailtable" style="display: block;">
    
      {$PAYMENTLIST}
     
	</div>
</div>