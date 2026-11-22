<!--修改编码格式:统一编码：UTF-8-->


    <form name="frmsendpaymemt" method="post" action="index.php" >
    <input type="hidden"  name="module"  value="SendPayment"/>
    <input  type="hidden" name="action" value="MassAdd"/>
    <input type="hidden" name="parenttab" value="Finical">
    <input  type="hidden" name="record" value="{$PURCHASEORDERID}"/>
    <input type="hidden" name="cust" value="{$VENDORID}"/>
    <input  type="hidden" name="MassSendPayment" value="yes"/>
    <input type="hidden" name="amount1" value="{$PURCHASEORDERAMOUNT}"/>
    <input type="hidden" name="periodtime1" value="1"/>
    <input type="hidden" name="SmOwnerSearchScope" value="{$CURUSERID}"/>
    <input type="hidden" name="autocreate"/>
    <input type="hidden" name="DeployValue" id="DeployValue" value="2" />

    <div class="D_pop_tit">
    	<strong class="D_ptita">{'CREATE'|@getFixedLabel} {'SendPayment'|@getTranstab}</strong>
        <a href="javascript:fninvshnew('CreateSendPayment');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod D_pop_bod_line" cellspacing="0" cellpadding="1" border="0">
        <tr>
           <td>    
            <div class="skxx10_t">①{'AUTOCREATE'|@getFixedLabel} {$MODULE|@getTranstab}</div>
            <div class="skxx10_n">
        
               {'SCHEDULEPAYDATE'|@getFixedLabel}: <input type="text" readonly="true" name="plandate1" id="plandate" style="border:1px #ddd solid;" value="{$PLANDATE}" onClick="WdatePicker()" class="Wdate"/>
                <!--<img   src='themes/softed/images/btnL3Calendar.gif' 
                onclick='showCalendar("plandate","%Y-%m-%d",true,"12",this)' class="popimg"/>-->
                {'AMOUNTPAYABLE'|@getFixedLabel}:{$PURCHASEORDERAMOUNT}<br />
                {assign var=modulelabel value=$MODULE|@getTranstab}
                <span style="color:red;">{'ONCEAUTOPERIODONEPAY'|@getVarFixedLabel:$modulelabel},<br/>{'Person_in_charge'|@getFixedLabel}、{'Vendors'|@getTranstab} {'CONSISTENWITHCURORDERINFO'|@getFixedLabel} </span>
                
               <div class="D_pbtn">
                	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveSendPayment(this,'frmsendpaymemt')"/><span>&nbsp;</span>
                    <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('CreateSendPayment');"/>   
               </div>
               <div class="clear"></div>
            </div>
           <div class="skxx10_t">②{'MANUALCREATE'|@getFixedLabel} {$MODULE|@getTranstab}</div>
            <div class="skxx10_n">
            <!--Manual_CreatePaymentPlan();return false-->
            	<a href="#" style="text-decoration:underline;" onclick="NewSendPayment(this,'CreateSendPayment',DetailView.record.value,0)">{'CREATEOPEN'|@getFixedLabel} {$MODULE|@getTranstab}</a>
            </div>
         </td>
      </tr>        
    </table>
    </form>