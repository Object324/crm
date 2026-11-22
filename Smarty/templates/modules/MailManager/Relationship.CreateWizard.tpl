<!--*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ('License'); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************-->
<!--修改编码格式:统一编码：UTF-8-->
{strip}
{include file='QuickCreateHidden.tpl'}

<div class="Title">
    <img class="Logo" src="themes/softed/tier/icon_loto.png"><span class="Name">{'NEW'|getFixedLabel} {$QCMODULE|@getTranstab}</span>
	<a href="javascript:fninvshnew('_relationpopupdiv_');">
		<img class="Close" src="themes/softed/tier/icon_close.png">
	</a>
</div>
<div class="Content_div">
   <table width="100%" cellspacing="0" cellpadding="0" border="0">
      <tbody><tr>
    	<td class="Note">
            <table border="0" cellspacing="0" cellpadding="5" width="100%" >
        	{assign var="fromlink" value="qcreate"}
        	{foreach item=subdata from=$QUICKCREATE}
        		<tr>
        			{foreach key=mainlabel item=maindata from=$subdata}
        				{include file='EditViewUI.tpl'}
        			{/foreach}
        		</tr>
        	{/foreach}
        	</table>
        </td>
      </tr></tbody>
    </table>
</div>
<div class="Bottom">
    <div class="Bottom_div width145">
        {if $MODULE eq 'Accounts'}
			<input accessKey="{'SAVE'|getTranslatedString}" class="Button_saveGreen width60"
				   onclick="if(getFormValidate()) MailManager.AjaxDuplicateValidate('Accounts', 'accountname', this.form).done(function(form) {ldelim} MailManager.mail_associate_create(form);{rdelim} );" type="button" name="button" value="{'SAVE'|getFixedLabel}">
		{else}
			<input type="button" class="Button_saveGreen width60" value="{'SAVE'|getFixedLabel}" onclick="if(getFormValidate()) MailManager.mail_associate_create(this.form);">
		{/if}
        <span>&nbsp;</span>
        <a class="Button_backOrg width60" onclick="fninvshnew('_relationpopupdiv_');">{'CANCEL'|getFixedLabel}</a>
    </div>
</div>

{if $MODULE eq 'Calendar'}
<script id="qcvalidate">
	var qcfieldname = new Array('subject','date_start','time_start','taskstatus');
        var qcfieldlabel = new Array('Subject','Start Date & Time','Start Date & Time','Status');
        var qcfielddatatype = new Array('V~M','DT~M~time_start','T~O','V~O');
</script>
{else}
<script id="qcvalidate">
        var qcfieldname = new Array({$VALIDATION_DATA_FIELDNAME});
        var qcfieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL});
        var qcfielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE});
</script>
{/if}
	<input type="hidden" class="small" name="_folder" value="{$FOLDER}">
	<input type="hidden" class="small" name="_msgno" value="{$MSGNO}">
	<input type="hidden" class="small" name="_mlinktotype" value="{$MODULE}">
	<input type="hidden" class="small" name="_mlinkto" value="{$PARENT}">
</form>
{/strip}