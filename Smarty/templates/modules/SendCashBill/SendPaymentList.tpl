<!--修改编码格式:统一编码：UTF-8-->
<link rel="stylesheet" type="text/css" media="all" href="{$CSSURL}themes/softed/Paymentplan.css">
<div class="divSocallProduct popDetailTable" style="overflow:hidden;">
    <div class="ld-from-headblock-title"{if $DISPLAYTABDETAIL eq 'no'}style="display:none;"{/if} name="sendcashbilltitle"><b tag="headblock-title">{'PAYMENTINFORMATION'|@getFixedLabel}</b></div>
    <div class="popDetailTable" name="sendcashbillsource">{$THHTML}</div>
</div>
<script type="text/javascript">
//22827: 采购订单>明细：关联创建付款单界面，小计、合计显示为0
curSendCashBill(undefined);
</script>