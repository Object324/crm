<!--修改编码格式:统一编码：UTF-8-->
<div class="skxxbill">
    <div class="DivCName DivCNamehover" tag="headblock-title" style="border-bottom:1px solid #ddd;"  onclick="showHideStatus('CashBillrelatemessagediv','CashBillrelatemessagespan')">
        <span id="CashBillrelatemessagespan"></span>{'GATHERINGINFORMATION'|@getFixedLabel}
    </div>
    <!--<div class="skxxbill_t">{'GATHERINGINFORMATION'|@getFixedLabel}</div>-->
     
     
     <div class="divSocallProduct popDetailTable" id="CashBillrelatemessagediv" style="display: block;" name="detailtable">
		{$PAYMENTLIST}
    </div>	
</div>