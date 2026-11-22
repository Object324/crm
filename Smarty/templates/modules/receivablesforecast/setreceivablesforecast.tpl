<!--修改编码格式:统一编码：UTF-8-->
 <link rel="stylesheet" type="text/css" media="all" href="themes/softed/Paymentplan.css">
<form action="index.php" method="post" name="frmSendPaymentSet">
<input type="hidden" name="module" value="SendPayment" />
<input  type="hidden" name="action" value="SaveSendPaymentSet"/>
<input type="hidden" name="record" value="{$PURCHASEORDERID}"/>

    <div class="D_pop_tit">
    	<strong class="D_ptita">{'SETPAYMENTPERCENT'|@getFixedLabel}</strong>
        <a href="javascript:blocksetsendcashbillpop('SetSendPayment','{$PURCHASEORDERID}');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr>
        <td>
			<table id="tableSet" width="100%" border="0" cellspacing="1" cellpadding="0" class="listEntries">
				<tr>
					<th width="14%" style="text-align:center;">{'OPERATING'|@getFixedLabel}</th>
					<th width="35%">{$PERIODTIMENAME}</th>
					<th width="35%">{'PAYMENTRATIO'|@getFixedLabel}</th>						
				</tr>
				{$TRSET}
			</table>
			<ul class="LdPop_ul14" style="margin:0;padding-top: 5px;padding-bottom: 3px;">
				<li><a class="Anu3_a" style="padding: 0 5px;border: 1px solid #ccc;line-height: 23px;margin:0;" onclick="addSetTr(this)" href="javascript:;">{'ADDQICI'|@getFixedLabel}</a></li>
			</ul>
        </td>
      </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveSendPaymentSet(this)"/><span>&nbsp;</span>
        <!--input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('SetSendPayment');puyoungJS_DialogBox.unblock();"/-->
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="blocksetsendcashbillpop('SetSendPayment','{$PURCHASEORDERID}');puyoungJS_DialogBox.unblock();"/>
    </div>
</form>