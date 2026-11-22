<!--**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************-->
<!--修改编码格式:统一编码：UTF-8-->
<form action="javascript:void(0);" method="POST" style="display:inline;" name="webmail">
<div class="setHeardDiv" id="settings_mail_fldrname">{'SETTINGS'|@getFixedLabel}</div>
<div id="settings_email_con" class="setEmailcon" name="settings_email_con">
    <input type="hidden" id="selected_servername" value="{$SERVERNAME}" />
    <table width="100%" cellpadding=5 cellspacing=0 border=0>
        <tr>
            <td width="12%" class="paddL25">{'LBL_SELECT_ACCOUNT_TYPE'|@getFixedLabel}</td>
            <td><select id="_mbox_helper" name="_mbox_helper" onchange="MailManager.handle_settings_confighelper(this);">
                    <option value=''>{'JSLBL_Choose_Server_Type'|@getFixedLabel}</option>
                    <!--
                    AUTHOR:BY LD KEVIN
                    DATE:20130417
                    DESPRITION:BUG3775
                    -->
                    
                    {if $SERVERNAME eq ''}
                    <option value='other' selected>{'othercc'|@getFixedLabel}</option>
                    {*
                    /**
                     *@edit:andy 
                     *@date:
                     *@reason:0011835: 工作台->邮件管理->账户设置：如图所示，希望“账户类型”默认为“其他
                     *@version:
                     */
                    *}                                        
                    {*<option value='gmail' selected>Gmail</option>*}
                    {/if}
                    <option value='gmail' {if $SERVERNAME eq 'gmail'} selected {/if}>Gmail</option>
                    <option value='yahoo' {if $SERVERNAME eq 'yahoo'} selected {/if}>Yahoo</option>
                    <option value='fastmail' {if $SERVERNAME eq 'fastmail'} selected {/if}>Fastmail</option>
                    {if $SERVERNAME neq ''}<option value='other' {if $SERVERNAME eq 'other'} selected {/if}>{'othercc'|@getFixedLabel}</option>{/if}
                </select>
            </td>
                <script>
                //MailManager.handle_settings_confighelper(_mbox_helper); edit:kevin date:2013-06-14 reason:3876
                MailManager.handle_settings_confighelper(webmail);
                </script>
        </tr>
    </table>
    
    <div id="settings_details" {if $SERVERNAME neq ''} style="display:block;" {else} style="display:none;"{/if}>
        <table width="100%" cellpadding="5" cellspacing="0" border="0">
            <tr>
                <td width="12%" class="paddL25" nowrap="nowrap"><font color="red">*</font>{'LBL_Mail_Server'|@getFixedLabel}</td>
                <td>
                    <input class="txtInput" name="_mbox_server" value="{$MAILBOX->server()}" type="text" onfocus="this.className='txtInputOn'" onblur="this.className='txtInput'"/>
                    <span class="mm_blur">{'FOREXAMPLE'|@getFixedLabel}imap.qq.com or 192.168.1.103</span>
                </td>
            </tr>

            <tr>
                <td width="12%" class="paddL25" nowrap="nowrap"><font color="red">*</font>{'USERNAME'|@getFixedLabel}</td>
                <td>
                    <input class="txtInput" type="text"  name="_mbox_user" id="_mbox_user" value="{$MAILBOX->username()}"  onfocus="this.className='txtInputOn'" onblur="this.className='txtInput'"/>
                    <span class="mm_blur">{'LBL_Your_Mailbox_Account'|@getFixedLabel}</span>
                </td>
            </tr>

            <tr>
                <td width="12%" class="paddL25" nowrap="nowrap"><font color="red">*</font>{'PASWD'|@getFixedLabel}</td>
                <td>
                    <input class="txtInput" name="_mbox_pwd" id="_mbox_pwd" value="{$MAILBOX->password()}" type="password" onfocus="this.className='txtInputOn'" onblur="this.className='txtInput'"/>
                   <span class="mm_blur">{'LBL_Account_Password'|@getFixedLabel}</span>
                </td>
            </tr>
        </table>
        
        <div id="additional_settings" {if $SERVERNAME eq 'other'} style="display:block;"{else} style="display:none;" {/if}>
        <table width="100%" cellpadding="5" cellspacing="0" border="0">
            <tr>
                <td width="12%" class="paddL25" nowrap="nowrap">{'LBL_Protocol'|@getFixedLabel}</td>
                <td>
                    <input type="radio" name="_mbox_protocol" value="IMAP2" {if strcasecmp($MAILBOX->protocol(), 'imap2')===0}checked=true{/if}> Imap2
                    <input type="radio" name="_mbox_protocol" value="IMAP4" {if strcasecmp($MAILBOX->protocol(), 'imap4')===0}checked=true{/if}> Imap4
                </td>
            </tr>

            <tr>
                <td width="12%" class="paddL25" nowrap="nowrap">{'LBL_SSL_Options'|@getFixedLabel}</td>
                <td>
                    <input type="radio" name="_mbox_ssltype" value="notls" {if strcasecmp($MAILBOX->ssltype(), 'notls')===0}checked=true{/if}> No TLS
                    <input type="radio" name="_mbox_ssltype" value="tls" {if strcasecmp($MAILBOX->ssltype(), 'tls')===0}checked=true{/if}> TLS
                    <input type="radio"name="_mbox_ssltype" value="ssl" {if strcasecmp($MAILBOX->ssltype(), 'ssl')===0}checked=true{/if}> SSL
                </td>
            </tr>

            <tr>
                <td width="12%" class="paddL25" nowrap="nowrap">{'LBL_Certificate_Validations'|@getFixedLabel}</td>
                <td>
                    <input type="radio" name="_mbox_certvalidate" value="validate-cert" {if strcasecmp($MAILBOX->certvalidate(), 'validate-cert')===0}checked=true{/if} > {'LBL_Validate_Cert'|@getFixedLabel}
                    <input type="radio" name="_mbox_certvalidate" value="novalidate-cert" {if strcasecmp($MAILBOX->certvalidate(), 'novalidate-cert')===0}checked=true{/if}> {'LBL_Do_Not_Validate_Cert'|@getFixedLabel}
                </td>
            </tr>
            </table>
        </div>
        <table width="100%" cellpadding="5" cellspacing="0" border="0">
            <tr>
                <td width="12%" class="paddL25" nowrap="nowrap">{'LBL_REFRESH_TIME'|@getFixedLabel}</td>
                <td>
                    <select name="_mbox_refresh_timeout">
                        <option value="" {if $MAILBOX->refreshTimeOut() eq ''}selected{/if}>{'NOTTOEXIST'|@getFixedLabel}</option>
                        <option value="300000" {if strcasecmp($MAILBOX->refreshTimeOut(), '300000')==0}selected{/if}>5{'MINUTE'|@getFixedLabel}</option>
                        <option value="600000" {if strcasecmp($MAILBOX->refreshTimeOut(), '600000')==0}selected{/if}>10{'MINUTE'|@getFixedLabel}</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td width="12%">&nbsp;</td>
                <td colspan=2>
                    <input type="button" class="saveauto" value="{'SAVE'|@getFixedLabel}" onclick="MailManager.save_settings(this.form);" >
                    {if $MAILBOX && $MAILBOX->exists()}
                        <input type="button" class="cancelauto" onclick="MailManager.close_settings();" value="{'CANCEL'|@getFixedLabel}" >
                        <input type="button" class="deleteauto" onclick="MailManager.remove_settings(this.form);" value="{'DELETE'|@getFixedLabel}" style="margin-left:10px">
					{else}
						<input type="button" class="cancelauto" onclick="MailManager.close_settings();" value="{'CANCEL'|@getFixedLabel}" >
                    {/if}
                </td>
            </tr>
        </table>
    </div>
</form>
</div>