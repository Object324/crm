<!--修改编码格式:统一编码：UTF-8-->
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/Paymentplan.css"/>
<form action="index.php" method="POST"  name="frmChangePayment" style="overflow:auto;">
    <input  type="hidden" value="SaveChangePaymentPlan" name="action"/>
    <input  type="hidden" value="PaymentPlan" name="module"/>
    
    <div class="D_pop_tit" style="margin-right: 0px;">
    	<strong class="D_ptita">{'Adjustment'|@getFixedLabel} {'PaymentPlan'|@getTranstab}</strong>
        <a href="javascript:fninvshnew('dvChangePaymentPlan');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
      <tr>
        <td class="Note">
            <ul class="LdPop_ul15head" style="margin:0">
				<li style="float:left;">
					<span>{'ATTUAFA'|@getFixedLabel}</span>:&nbsp;&nbsp;
                    <input class="LdPop_ul15headinput" type="text" id="txtChangePercent" size="10"/>
                    <input type="checkbox" name="chkIncreatement" id="chkIncreatement"/>
                    <span>{'paa'|@getFixedLabel}</span>
				</li>
                <li style="float:left;">&nbsp;&nbsp;<input class="Anu3_a" type="button" value="{'CONFIRMED'|@getFixedLabel}" onclick="AllChangePercent(this)"/></li>
			</ul>
            <div class="clear"></div>
            <div class="divPopOverflow" style="height:200px;">
			<table id="ChangePaymentList" width="100%" border="0" cellspacing="1" cellpadding="0" class="listEntries fir-center">
				<tr>
					<th><input name="" type="checkbox" value=""  onclick="ChangePaymentPlanchkAll(this)"/></th>
					<th width="10%">{'Numberofpaymentplans'|@getFixedLabel}</th>
					<th width="7%">{'STATUS'|@getFixedLabel}</th>
					<th width="7%">{'Stages'|@getFixedLabel}</th>
					<th width="17%">{'Planstoreturntothedatefunds'|@getFixedLabel}</th>
					<th width="17%">{'Theamountoftheoriginalplan'|@getFixedLabel}</th>
					<th width="17%" >{'MODIFIEDTIME'|@getFixedLabel}</th>
					<th width="10%" >{'Adjustmentfactor'|@getFixedLabel}</th>
					<th width="10%">{'AdjustedAmount'|@getFixedLabel}</th>
				</tr>
				  {$PAYMENTLIST}
			</table>
            </div>
            <div class="clear"></div>
        </td>
      </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveChangtePaymentPlan(this,'frmChangePayment')"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('dvChangePaymentPlan')"/>   
    </div>   
</form>