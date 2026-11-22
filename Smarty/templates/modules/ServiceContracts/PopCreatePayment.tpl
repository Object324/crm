<!--修改编码格式:统一编码：UTF-8-->
    <form name="frmpaymentplan" method="post" >
    <input type="hidden"  name="module"  value="PaymentPlan"/>
    <input  type="hidden" name="action" value="MassAdd"/>
    <input type="hidden" name="parenttab" value="Finical">
    <input  type="hidden" name="record" value="{$SALESORDERID}"/>
    <input type="hidden" name="cust" value="{$ACCOUNTID}"/>
    <input  type="hidden" name="MassPaymentPlan" value="yes"/>
    <input type="hidden" name="amount1" value="{$SALESORDERAMOUNT}"/>
    <input type="hidden" name="periodtime1" value="1"/>
    <input type="hidden" name="SmOwnerSearchScope" value="{$CURUSERID}"/>
    <input type="hidden" name="autocreate"/>
    <input type="hidden" name="DeployValue" id="DeployValue" value="2" />

    <div class="D_pop_tit" >
    	<strong class="D_ptita">{'CREATE'|@getFixedLabel} {'PaymentPlan'|@getTranstab}</strong>
        <a href="#" onclick="location.href='index.php?module=ServiceContracts&action=DetailView&record={$SERVICESONTRACTSID}';fninvshnew('CreatePaymentplan');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr>
        <td>
    		<div class="skxx10_t">①{'AUTOCREATE'|@getFixedLabel} {'PaymentPlan'|@getTranstab}</div>
            <div class="skxx10_n">
               {'PLANRECEDATE'|@getFixedLabel}: <input type="text" readonly="true" name="plandate1" id="plandate" style="border:1px #ddd solid;" value="{$PLANDATE}" onClick="WdatePicker()" class="Wdate"/>
                <!--<img src='themes/softed/images/btnL3Calendar.gif' 
                onclick='showCalendar("plandate","%Y-%m-%d",true,"12",this)' class="popimg"/>-->
                {'AMOUNTRECEIVE'|@getFixedLabel}:{$SALESORDERAMOUNT}<br />
                {assign var=paymentplan value='PaymentPlan'|@getTranstab}
                <span style="color:red;">{'ONCEAUTOPERIODONEPAY'|@getVarFixedLabel:$paymentplan},<br/>{'Person_in_charge'|@getFixedLabel}、{'Accounts'|@getTranstab} {'CONSISTENWITHCURORDERINFO'|@getFixedLabel} </span>
                <div class="D_pbtn">
                	<input type="button" class="D_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" onclick="SavePaymentPlan(this,'frmpaymentplan')"/><span>&nbsp;</span>
                    <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('CreatePaymentplan');puyoungJS_DialogBox.unblock();"/>
                </div>
                <div class="clear"></div>
            </div>
           <div class="skxx10_t">②{'MANUALCREATE'|@getFixedLabel} {'PaymentPlan'|@getTranstab}</div>
            <div class="skxx10_n">
            	<a href="#" style="text-decoration:underline;" onclick="NewPaymentPlan(this,'CreatePaymentplan',DetailView.record.value,0)">{'CREATEOPEN'|@getFixedLabel} {'PaymentPlan'|@getTranstab}</a>
            </div>
        </td>
      </tr>
    </table>
    </form>
</div>