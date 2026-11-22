<!--修改编码格式:统一编码：UTF-8-->
<form name="frmsendInfo" method="post" action="index.php">
<input type="hidden"  name="module"  value="MassSMS"/>
<input type="hidden" name="action" value="SaveSendInfo"/>
<input type="hidden" name="parenttab" value="Marketing">
<input type="hidden" id="sendaccount" name="sendaccount" value="{$SENDACCOUNTTYPE}">
<input type="hidden" id="accountname" name="accountname" value="{$ACCOUNTNAME}">
<input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}">
<input type="hidden" id="outid" name="outid" value="{$OUTID}">
<input type="hidden" name="is_send" value="{$IS_SEND}" />
	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
      <tr>
        <td class="Note">
    		<div>
                {'THERECIPIENTINFORMATION'|@getFixedLabel}{if $IS_SEND neq 2}：每行一个手机号码，格式&nbsp;&nbsp; <span style="color:red">13166331111<张先生></span>{/if}
            </div>
            <div class="divTextRecipient">
                <textarea class="ld-textarea-inner" id="textRecipient" name="textRecipient">{$ACCINFO}</textarea>
            </div>
            <div>
                {if $IS_SEND eq 2}{'EMAILINFO'|@getFixedLabel}{else}{'SMS_content'|@getFixedLabel}{/if}&nbsp;&nbsp;{if $settype neq 'no'}
                <a href="javascript:;" id="divSendInform_content_id" onclick="CreateSendInformContent('{$FROMMODULE}',document.getElementById('divSendInform_content_id'),'divSendInform_content','divSendInform',{$OUTID},{$TABID});">
                    {'SETHEMESSAGEFORMAT'|@getFixedLabel}
                </a>{/if}
            </div>
            <div class="divTextRecipient">
                <textarea class="ld-textarea-inner" id="textContext" name="textContext">{$CONTENT}</textarea>
            </div>
        </td>
      </tr>
    </table>
</form>