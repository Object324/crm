<!--修改编码格式:统一编码：UTF-8-->
<div class="ld-pop-container ld-table-container ld-table-container-lines">
	<div class="divPopOverflow">
		<link rel="stylesheet" type="text/css" media="all" href="themes/softed/Paymentplan.css">
		<form action="index.php" method="post" name="frmSendPaymentSet" class="setSendCashBillForm">
		<input type="hidden" name="module" value="SendPayment" />
		<input  type="hidden" name="action" value="SaveSendPaymentSet"/>
		<input type="hidden" name="record" value="{$PURCHASEORDERID}"/>
			<table id="tableSet" class="" border="0" cellpadding="0" cellspacing="0" width="100%">
				<thead>
				<tr>
					<th width="35%">{$PERIODTIMENAME}</th>
					<th width="35%">{'PAYMENTRATIO'|@getFixedLabel}</th>
					<th width="14%">{'OPERATING'|@getFixedLabel}</th>
				</tr>
				</thead>
				<tbody>
					{$TRSET}
				</tbody>
			</table>
		</form>
	</div>
	<div class="padT20">
		<a class="" onclick="addSetTr(this)" href="javascript:;">{'ADDQICI'|@getFixedLabel}</a>
	</div>
</div>