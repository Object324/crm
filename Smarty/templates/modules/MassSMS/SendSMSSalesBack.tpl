<!--修改编码格式:统一编码：UTF-8-->
<form name="sendSalesBackForm" method="post" action="index.php">
    <input type="hidden" name="module" value="MassSMS"/>
    <input type="hidden" name="action" value="SaveSendSMSSalesBack"/>
    <input type="hidden" name="parenttab" value="Marketing">
    <input type="hidden" id="salesbackid" name="salesbackid" value="{$SALESBACKID}">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'SENDTEXTMESSAGESTOINFORM'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('divSendSMSSalesBack');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod_SMS" cellspacing="1" cellpadding="1" border="0">
      <tr>
        <td class="Note">
        <div class="Logscroll">
            <!--短信1-->
            <div class="divRecipientTitle">
                <input id="smsFirst" name="smsFirst" type="checkbox" onclick="chooseSalesBackSMS('smsFirst')" />
                {'SMS'|@getFixedLabel}1（{'SMSSENDINSTANT'|@getFixedLabel}）
            </div>
    		<div class="divRecipientInfo">
                {'THERECIPIENTINFORMATION'|@getFixedLabel}（{'MOBILEPHONEFROMPRODUCTORDER'|@getFixedLabel}）
                <a id="smsPhoneFirst" name="smsPhoneFirst" href="javascript:chooseSalesBackSMSPhone(this,'divSendSMSSalesBack_Phone','divSendSMSSalesBack',{$SALESBACKID},'smsFirst');">
                    {'SETRECEIVERMOBILE'|@getFixedLabel}
                </a>
            </div>
            <div class="divRecipientContent">
                <textarea id="textRecipientFirst" name="textRecipientFirst" readonly="readonly">{$PHONEFIRST}</textarea>
            </div>
            <div class="divRecipientInfo">
                {'SMS_content'|@getFixedLabel}&nbsp;&nbsp;
                <a id="smsContentFirst" name="smsContentFirst" href="javascript:chooseSalesBackSMSContent(this,'divSendSMSSalesBack_SMSContent','divSendSMSSalesBack',{$SALESBACKID},'smsFirst');">
                    {'SETSMSCONTENTTEMPLATE'|@getFixedLabel}
                </a>
            </div>
            <div class="divRecipientContent">
                <textarea id="textContextFirst" name="textContextFirst">{$CONTENTFIRST}</textarea>
            </div>
            <!--短信2-->
            <div class="divRecipientTitle">
                <input id="smsSecond" name="smsSecond" type="checkbox" onclick="chooseSalesBackSMS('smsSecond')" />
                {'SMS'|@getFixedLabel}2（{'SMSSENDINSTANT'|@getFixedLabel}）
            </div>
    		<div class="divRecipientInfo">
                {'THERECIPIENTINFORMATION'|@getFixedLabel}（{'PHONEFROMCUSTOMERSCONTACT'|@getFixedLabel}）
                <a id="smsPhoneSecond" name="smsPhoneSecond" href="javascript:chooseSalesBackSMSPhone(this,'divSendSMSSalesBack_Phone','divSendSMSSalesBack',{$SALESBACKID},'smsSecond');">
                    {'SETRECEIVERMOBILE'|@getFixedLabel}
                </a>
            </div>
            <div class="divRecipientContent">
                <textarea id="textRecipientSecond" name="textRecipientSecond" readonly="readonly">{$PHONESECOND}</textarea>
            </div>
            <div class="divRecipientInfo">
                {'SMS_content'|@getFixedLabel}&nbsp;&nbsp;
                <a id="smsContentSecond" name="smsContentSecond" href="javascript:chooseSalesBackSMSContent(this,'divSendSMSSalesBack_SMSContent','divSendSMSSalesBack',{$SALESBACKID},'smsSecond');">
                    {'SETSMSCONTENTTEMPLATE'|@getFixedLabel}
                </a>
            </div>
            <div class="divRecipientContent">
                <textarea id="textContextSecond" name="textContextSecond">{$CONTENTSECOND}</textarea>
            </div>
        </div>    
        </td>
      </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'Send_SMS'|@getFixedLabel}" onclick="SaveSendSMSSalesBack(this)"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('divSendSMSSalesBack');"/>   
    </div>
</form>