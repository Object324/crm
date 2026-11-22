<!--修改编码格式:统一编码：UTF-8-->
<div class="divPopOverflow">
<input type="hidden" id="fromview" value=""/>
<input type="hidden" name="is_send" value="{$IS_SEND}" />
<input type="hidden" name="record" value="{$RESID}" />
<table class="ld-public-content-small" width="100%" cellspacing="0" cellpadding="0" border="0">
  <tr>
	<td class="ld-form-item-content padL0">
		<div>
			{'THERECIPIENTINFORMATION'|@getFixedLabel}{if $IS_SEND neq 2}：每行一个手机号码，格式&nbsp;&nbsp; <span style="color:red">13166331111<张先生></span>{/if}
		</div>
		<div>
			<a href="javascript:void(0);" title="'selectothercontacts'|@getFixedLabel}" onclick="selectOtherContacts('{$CONTACTID}','{$ACCOUNTID}')">{'selectothercontacts'|@getFixedLabel}{if $IS_SEND eq 2}{'EMAIL'|@getFixedLabel}{else}{'Mobile'|@getFixedLabel}{/if}</a>
		</div>
		<div class="divTextRecipient">
			<textarea class="ld-textarea-inner" id="textRecipient" name="textRecipient">{$ACCINFO}</textarea>
		</div>
		<input type="hidden" name="platform" value="{$PlatForm}" />
		{if $IS_SEND eq 1 && $PlatForm eq 'aliyun'}
		{else}
			<div>
				{if $IS_SEND eq 2}{'EMAILINFO'|@getFixedLabel}{else}{'SMS_content'|@getFixedLabel}{/if}&nbsp;&nbsp;
				{if $IS_SEND eq 2}
					<a href="javascript:;" id="divSendInform_content_id" onclick="CreateSendInformContent('HelpDesk',{$TABID});">
						{'setmailformat'|@getFixedLabel}
					</a>
				{else}
					<a href="javascript:;" id="divSendInform_content_id" onclick="CreateSendInformContent('HelpDesk',{$TABID});">
						{'SETHEMESSAGEFORMAT'|@getFixedLabel}
					</a>
				{/if}
			</div>
			<div class="divTextRecipient">
				<textarea class="ld-textarea-inner" id="textContext" name="textContext">{$CONTENT}</textarea>
			</div>
		{/if}

	</td>
  </tr>
</table>
{if $IS_SEND eq 1 && $PlatForm eq 'aliyun'}
	{*短信通知且为aliyun时*}
	{include file="SmsRemindContent.tpl"}
	<div class="ld-pop-container padT0 greyFont9">{$WILDCARD}</div>
{/if}
</div>