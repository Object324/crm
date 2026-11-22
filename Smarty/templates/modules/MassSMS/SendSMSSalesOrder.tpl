<!--修改编码格式:统一编码：UTF-8-->
<form name="sendSalesorderForm" method="post" action="index.php">
    <input type="hidden" name="module" value="MassSMS"/>
    <input type="hidden" name="action" value="SaveSendSMSSalesOrder"/>
    <input type="hidden" name="parenttab" value="Marketing">
    <input type="hidden" id="salesorderid" name="salesorderid" value="{$SALESORDERID}">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'SENDTEXTMESSAGESTOINFORM'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('divSendSMSSalesOrder');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod_SMS" cellspacing="1" cellpadding="1" border="0">
      <tr>
        <td class="Note">
        <div class="Logscroll">
            <!--短信1-->
            <div class="divRecipientTitle">
                <input id="smsFirst" name="smsFirst" type="checkbox"/>
                {'SMS'|@getFixedLabel}1（{'SMSSENDINSTANT'|@getFixedLabel}）
            </div>
    		<div class="divRecipientInfo">
                {'THERECIPIENTINFORMATION'|@getFixedLabel}（{'MOBILEPHONEFROMPRODUCTORDER'|@getFixedLabel}）
                <a id="smsPhoneFirst" name="smsPhoneFirst" href="javascript:chooseSalesOrderSMSPhone(this,'divSendSMSSalesOrder_Phone','divSendSMSSalesOrder',{$SALESORDERID},'smsFirst');">
                    {'SETRECEIVERMOBILE'|@getFixedLabel}
                </a>
            </div>
            <div class="divRecipientContent">
                <textarea id="textRecipientFirst" name="textRecipientFirst" readonly="readonly">{$PHONEFIRST}</textarea>
            </div>
            <div class="divRecipientInfo">
                {'SMS_content'|@getFixedLabel}&nbsp;&nbsp;
                <a id="smsContentFirst" name="smsContentFirst" href="javascript:chooseSalesOrderSMSContent(this,'divSendSMSSalesOrder_SMSContent','divSendSMSSalesOrder',{$SALESORDERID},'smsFirst');">
                    {'SETSMSCONTENTTEMPLATE'|@getFixedLabel}
                </a>
            </div>
            <div class="divRecipientContent">
                <textarea id="textContextFirst" name="textContextFirst">{$CONTENTFIRST}</textarea>
            </div>
            
            <!--短信2-->
            <div class="divRecipientTitle">
                <input id="smsSecond" name="smsSecond" type="checkbox" />
                {'SMS'|@getFixedLabel}2（{'Regularly_sent'|@getFixedLabel}）
                <a id="smsPhoneSecond" name="smsPhoneSecond" href="javascript:chooseSalesOrderSMSTime(this,'divSendSMSSalesOrder_Time','divSendSMSSalesOrder',{$SALESORDERID},'smsSecond');">
                    {'SETTIMINGRULES'|@getFixedLabel}
                </a>
            </div>
    		<div class="divRecipientInfo">
                {'THERECIPIENTINFORMATION'|@getFixedLabel}（{'MOBILEPHONEFROMPRODUCTORDER'|@getFixedLabel}）
                <a id="smsPhoneSecond" name="smsPhoneSecond" href="javascript:chooseSalesOrderSMSPhone(this,'divSendSMSSalesOrder_Phone','divSendSMSSalesOrder',{$SALESORDERID},'smsSecond');">
                    {'SETRECEIVERMOBILE'|@getFixedLabel}
                </a>
            </div>
            <div class="divRecipientContent">
                <textarea id="textRecipientSecond" name="textRecipientSecond" readonly="readonly">{$PHONESECOND}</textarea>
            </div>
            <div class="divRecipientInfo">
                {'SMS_content'|@getFixedLabel}&nbsp;&nbsp;
                <a id="smsContentSecond" name="smsContentSecond" href="javascript:chooseSalesOrderSMSContent(this,'divSendSMSSalesOrder_SMSContent','divSendSMSSalesOrder',{$SALESORDERID},'smsSecond');">
                    {'SETSMSCONTENTTEMPLATE'|@getFixedLabel}
                </a>
            </div>
            <div class="divRecipientContent">
                <textarea id="textContextSecond" name="textContextSecond">{$CONTENTSECOND}</textarea>
            </div>
            
            <!--短信3-->
            <div class="divRecipientTitle">
                <input id="smsThird" name="smsThird" type="checkbox" />
                {'SMS'|@getFixedLabel}3（{'Regularly_sent'|@getFixedLabel}）
                <a id="smsPhoneThird" name="smsPhoneThird" href="javascript:chooseSalesOrderSMSTime(this,'divSendSMSSalesOrder_Time','divSendSMSSalesOrder',{$SALESORDERID},'smsThird');">
                    {'SETTIMINGRULES'|@getFixedLabel}
                </a>
            </div>
    		<div class="divRecipientInfo">
                {'THERECIPIENTINFORMATION'|@getFixedLabel}（{'PHONEFROMCUSTOMERSCONTACT'|@getFixedLabel}）
                <a id="smsPhoneThird" name="smsPhoneThird" href="javascript:chooseSalesOrderSMSPhone(this,'divSendSMSSalesOrder_Phone','divSendSMSSalesOrder',{$SALESORDERID},'smsThird');">
                    {'SETRECEIVERMOBILE'|@getFixedLabel}
                </a>
            </div>
            <div class="divRecipientContent">
                <textarea id="textRecipientThird" name="textRecipientThird" readonly="readonly">{$PHONETHIRD}</textarea>
            </div>
            <div class="divRecipientInfo">
                {'SMS_content'|@getFixedLabel}&nbsp;&nbsp;
                <a id="smsContentThird" name="smsContentThird" href="javascript:chooseSalesOrderSMSContent(this,'divSendSMSSalesOrder_SMSContent','divSendSMSSalesOrder',{$SALESORDERID},'smsThird');">
                    {'SETSMSCONTENTTEMPLATE'|@getFixedLabel}
                </a>
            </div>
            <div class="divRecipientContent">
                <textarea id="textContextThird" name="textContextThird">{$CONTENTTHIRD}</textarea>
            </div>
        </div>    
        </td>
      </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'Send_SMS'|@getFixedLabel}" onclick="SaveSendSMSSalesOrder(this)"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('divSendSMSSalesOrder');"/>   
    </div>
</form>