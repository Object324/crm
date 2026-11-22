{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->

<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
{if $EMAILCONFIG_MODE neq 'edit'}
	<form action="index.php" method="post" name="MailServer" id="form" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="emailconfig_mode">
{else}
	{literal}
	<form action="index.php" method="post" name="MailServer" id="form" onsubmit="if(validate_mail_server(MailServer)){ puyoungJS_DialogBox.block(); return true; } else { return false; }">
	{/literal}
	<input type="hidden" name="server_type" value="email"/>
{/if}
<input type="hidden" id="module" name="module" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="return_module" value="Settings"/>
<input type="hidden" name="return_action" value="EmailConfig"/>
<input type="hidden" name="confirmMsg" value="{'SUREMAILSERVERDEFAULT'|@getFixedLabel}" id="confirmMsg"/>
<input type="hidden" name="defaultMsg" value="{'HAVEMAILSEVERDEFAULT'|@getFixedLabel}" id="defaultMsg"/>
<input type="hidden" name="mode"/>
<input type="hidden" id="server" value="{$MAILSERVER}"/>
<input type="hidden" id="server_username" value="{$USERNAME}"/>
<input type="hidden" id="server_password" value="{$PASSWORD}"/>
<input type="hidden" id="from_email_field" value="{$FROM_EMAIL_FIELD}"/>
<input type="hidden" id="smtp_auth" value="{$SMTP_AUTH}"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
{if $EMAILCONFIG_MODE neq 'edit'}
	<div class="main_grid_top">
	    <div class="grid-view-title lfloat overflow-hidden">
	        <span class="grid-view-name dinline-block lfloat">
	            {'LBL_MAIL_SERVER_SETTINGS'|@getFixedLabel}{if $HelpHtml.EmailConfig neq '' }{$HelpHtml.EmailConfig}{/if}
	        </span>
	    </div>
	    <div class="grid_tool">
	        <div class="displayflex">
	            <a href="javascript:;" class="ld-button ld-button-primary" onclick="editEmailConfig()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
				<a href="javascript:;" class="ld-button" onclick="deleteEmailConfig()" title="{'LOGOUTS'|@getFixedLabel}">{'LOGOUTS'|@getFixedLabel}</a>
	        </div>
	    </div>
	</div>
{/if}
{if $EMAILCONFIG_MODE neq 'edit'}
	<div class="main_grid_box">
		<div class="grid-analysis-box">
			<div class="grid-analysis-header">
			</div>
			<div class="cont_wrap clear_float">
				<table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
					<tr>
						<th colspan="2">
							{'MAILSERVERSET'|@getFixedLabel}{if $ERROR_MSG neq ''}{$ERROR_MSG}{/if}
						</th>
					</tr>
					<tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
						<td width="20%">{'MAILSERVERNAME'|@getFixedLabel}</td>
						<td width="80%">{$MAILSERVER}</td>
					</tr>
					<tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
						<td>{'USERNAME'|@getFixedLabel}</td>
						<td>{$USERNAME}</td>
					</tr>
					<tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
						<td>{'PASWD'|@getFixedLabel}</td>
						<td>
							{if $PASSWORD neq ''}
							******
							{/if}
						</td>
					</tr>
					<tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
						<td>{'FROMEMAIL'|@getFixedLabel}</td>
						<td>{$FROM_EMAIL_FIELD}</td>
					</tr>
                    <tr id="setting_5" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
						<td>SSL{'port'|@getFixedLabel}</td>
						<td>
							<input type="checkbox" onclick="change_tablefield_presence(this,'email','systems_smtp_ssl')" mailserver='{$MAILSERVER}' class="second_switch"  
                            {if $smtp_ssl eq 'yes'}checked=""{/if}/>
							{if $smtp_ssl eq 'yes'}
								<span id='smtp_port' style="padding-left:5px">465</span>
							{else}
								<span id='smtp_port' style="padding-left:5px">25</span>
							{/if}
						</td>
					</tr>
					<tr id="setting_6" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
						<td>{'REQIREAUTHEN'|@getFixedLabel}</td>
						<td>
							<input type="checkbox" onclick="change_tablefield_presence(this,'email','systems_smtp_auth')" mailserver='{$MAILSERVER}' class="second_switch"  
                            {if $SMTP_AUTH eq 'checked'}checked=""{/if}/>
						</td>
					</tr>
				</table>
			</div>
		</div>
	</div>
{else}
	<div class="divPopOverflow">
	<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'MAILSERVERNAME'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input type="text" class="ld-input-inner" tag="{'MAILSERVERNOTEMPTY'|@getFixedLabel}" name="server" value="{$MAILSERVER}" id="serversmtp">
			</td>
		</tr>
		<tr >
			<td class="ld-form-item-label">{'USERNAME'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input type="text" class="ld-input-inner" value="{$USERNAME}" name="server_username" id="server_username">
			</td>
		</tr>
		<tr>
			<td class="ld-form-item-label">{'PASWD'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input type="password" class="ld-input-inner" value="{$PASSWORD}" name="server_password" id="server_password">
			</td>
		</tr>
		<tr>
			<td class="ld-form-item-label">{'FROMEMAIL'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input type="text" class="ld-input-inner" value="{$FROM_EMAIL_FIELD}" name="from_email_field" id="from_email_field"/>
			</td>
		</tr>
        <tr>
			<td class="ld-form-item-label"> SSL{'port'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
            {if $smtp_ssl eq 'yes'}
		      	<input type="checkbox" class="second_switch" name="smtp_ssl" id="smtp_ssl" onchange="smtpcheckclick(ld(this))" checked>
                <span name='smtp_port' style="padding-left:5px">465</span>
             {else}
                <input type="checkbox" class="second_switch" name="smtp_ssl" id="smtp_ssl" onchange="smtpcheckclick(ld(this))" >
                <span name='smtp_port' style="padding-left:5px">25</span>
             {/if}  
             
			</td>
		</tr>
		<tr>
			<td class="ld-form-item-label">{'REQIREAUTHEN'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input type="checkbox" class="second_switch" name="smtp_auth" id="smtp_auth" {$SMTP_AUTH}/>
			</td>
		</tr>
	</table>
	</div>
{/if}
</form>