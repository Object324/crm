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
<div id="ListViewContents" class="overflowauto">
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
    <script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script>
    <input type="hidden" name="accountid_chose" id="accountid_chose" value=""/>
    <input type="hidden" name="row_of_checkbox_account" id="row_of_checkbox_account" value="{$num_rows}"/> 
    <form id="sendSMS" name="sendSMS" method="post" onsubmit="puyoungJS_DialogBox.block()" ENCTYPE="multipart/form-data" action="index.php" style="margin:0px">
        <input type='hidden' name="module" value="MassSMS" id="curmodule"/>
        <input type='hidden' name="action" value="index"/>
        <table class="ld-public-content-small" width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr>
                <td class="ld-form-item-label">{'Recipient_phone'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <i>
                        <select class="ld-select-inner width120" name="parent_type">
                            {if 'Contacts'|vtlib_isModuleActive}
                            <option value="Contacts">{'Contacts'|@getTranstab}</option>
                            {/if}
                            {if 'Accounts'|vtlib_isModuleActive}
                            <option value="Accounts">{'Accounts'|@getTranstab}</option>
                            {/if}
                            {*2022-0222 duan 东贸-区分下游客户和大巴车*}
                            {if 'ServiceCharge'|vtlib_isModuleActive && $version_account=='dongmao'}
                                {foreach item = info from = $LINKMODULEINFO}
                                    <option value="{$info.module}" cvid="{$info.linkcvid}" >{$info.label}</option>
                                {/foreach}
                            {/if}
                            {*2021-0908 zxm 阳光创信 发送给销售负责人短信*}
                            {if $iskehu001 == 'no'||$version_account=='ygchuangxin'}
                                <option value="Users">{'Users'|@getTranstab}</option>
                            {/if}
                        </select>
                        <a href="javascript:;" class="icon-homeimg icon-add" onclick="MassSmsPopupBind.selectModuleForByPhone()"></a>
                        <a class="Anu3_a" href="javascript:void(0);" id="btn_import" onclick="MassSmsPopupBind.addManualAddPhone()" style="font-style: initial;position: relative;top: -2px;">{'Manualaddition'|@getFixedLabel}</a>
                    </i>
					{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" style="margin: 9px 0;" href="javascript:;" onclick="getLinksUrl('{$TABID}','Module','sendsmshelp');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"></td>
                <td class="ld-form-item-content">
                    <textarea tag="{'Recipient_phone'|@getFixedLabel}" class="ld-textarea-inner" style="resize: none;height:100px;" wrap="physical" name="receivephone" cols="" rows=""></textarea>
                </td>
            </tr>

            <input type="hidden" name="platform" value="{$PlatForm}" />
            {if $PlatForm eq 'aliyun'}
                {include file="SmsRemindContent.tpl"}

                <div style="padding-top:8px;text-align: left;white-space: normal;margin-left: 10px">
                    <span style="color:gray;">
                    {'WILDCARDCUSTNAME'|@getFixedLabel}{ldelim}comname{rdelim}；{'CustomerTelephone'|@getFixedLabel}{ldelim}comphone{rdelim}；{'CONTACTNAME'|@getFixedLabel}{ldelim}name{rdelim}；{'CONTACTAPPELLATION'|@getFixedLabel}{ldelim}app{rdelim}；{'SalesManName'|@getFixedLabel}{ldelim}salesman{rdelim}；{'SalesManMobile'|@getFixedLabel}{ldelim}salesmanmobile{rdelim}
                    </span>
                </div>
            {else}
            {*zxm 202-0909 语音短信不需要短信内容*}
            <tr>
                <td class="ld-form-item-label">{if $SMStype=="SMS_VOICE"}{'VOICE'|@getFixedLabel}{'TEMPLATE'|@getFixedLabel}{else}{'SMS_content'|@getFixedLabel}{/if}</td>
                <td class="ld-form-item-content">
                    <select class="ld-select-inner width200" style="margin-top: 1px;float:unset;" onchange="MassSmsPopupBind.SelectMassSmsTemplate()" name="receivetem">
                        {if $SMStype!="SMS_VOICE"}
                            <option value="-1">— —{'SMS_templates'|@getFixedLabel}— —</option>
                        {/if}
                        {foreach name=emailtemplate item=template from=$TEMPLATES}
                            <option value="{$template.TemplateID}" tag="{$template.template_type}">
                                {$template.TemplateName}
                            </option>
                        {/foreach}
                    </select>
                    <!-- {if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" style="margin: 9px 0;" href="javascript:;" onclick="getLinksUrl('{$TABID}','Module','sendsmshelp');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if} -->
                </td>
            </tr>
            <tr {if $SMStype=="SMS_VOICE"}style="display:none;"{/if}>
                <td class="ld-form-item-label"></td>
                <td class="ld-form-item-content">
                <textarea tag="{'SMS_content'|@getFixedLabel}" class="ld-textarea-inner" style="resize: none;height:100px;" wrap="physical" name="receivecontent" cols="" rows=""
                          onkeydown="MassSmsPopupBind.countChar();"
                          onkeyup="MassSmsPopupBind.countChar();"
                          onpaste="MassSmsPopupBind.countChar();"></textarea>
                    <div style="padding-top:8px;color:#ED7403;text-align: left;margin-left: 10px">
                        {'Currentinput'|@getFixedLabel}<span name="now_counter">0</span>{'Word'|@getFixedLabel}<span name="signature_counter">0</span>{'Word2'|@getFixedLabel}{'Totalcontentofthemessage'|@getFixedLabel}<span name="all_counter">0</span>{'Word2'|@getFixedLabel}。
                    </div>
                    <div style="padding-top:8px;text-align: left;white-space: normal;margin-left: 10px">
                    <span style="color:gray;">
                    {'WILDCARDCUSTNAME'|@getFixedLabel}{ldelim}comname{rdelim}；{'CustomerTelephone'|@getFixedLabel}{ldelim}comphone{rdelim}；{'CONTACTNAME'|@getFixedLabel}{ldelim}name{rdelim}；{'CONTACTAPPELLATION'|@getFixedLabel}{ldelim}app{rdelim}；{'SalesManName'|@getFixedLabel}{ldelim}salesman{rdelim}；{'SalesManMobile'|@getFixedLabel}{ldelim}salesmanmobile{rdelim}
                    </span>
                    </div>
                    <div style="padding-top:8px;text-align: left;margin-left: 10px">
                    <span style="color:gray;">
                    <input type="hidden" name="hidden_autograph" value="{$accountautograph}" />
                    {'SMS_Signature'|@getFixedLabel}：{$accountautograph}
                    </span>
                    </div>
                </td>
            </tr>
            {/if}

        </table>
    </form>
</div>