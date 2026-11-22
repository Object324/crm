
<table class="ld-public-content-small" id="sms_reminds_content_table" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
        <td colspan="2">
            <div class="ld-pop-contnet-title-items">
                <div class="ld-pop-contnet-title-item">
                    {'REMINDSCONTENT'|@getFixedLabel}
                </div>
            </div>
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label"><font color="red">*</font>{'SELECT'|@getFixedLabel}{'SMS_templates'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            {if $SmsScene eq 'MassSms'}
                <select id="smstemplatelist" name="smstemplatelist" onchange="SmsContentSetting.getInstance().ShowMassSmsTemplateEvent(this);" class="ld-select-inner">
                    <option value="">— —{'SMS_templates'|@getFixedLabel}— —</option>
                    {foreach item=item from=$SmsTemplateList}
                        <option value="{$item.templateid}">{$item.templatename}</option>
                    {/foreach}
                </select>
            {else}
                <select id="smstemplatelist" name="smstemplatelist" onchange="SmsContentSetting.getInstance().ShowSmsTemplateEvent();" class="ld-select-inner">
                    {*                <option value=""></option>*}
                    {foreach item=item from=$SmsTemplateList}
                        <option value="{$item.templateid}" {if isset($SmsRelatedArr.template_id) && $item.templateid eq $SmsRelatedArr.template_id}selected{/if}>{$item.templatename}</option>
                    {/foreach}
                </select>
            {/if}

        </td>
    </tr>

    <tr>
        <td class="ld-form-item-label">{'REMINDSCONTENT'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <span name="smstemplate_content">{if isset($SmsRelatedArr.templatecontent)} {$SmsRelatedArr.templatecontent} {/if}</span>
        </td>
    </tr>

    {if $SmsScene neq 'MassSms'}{*群发短信 不需要设置变量信息行*}
    <tr name="variable_information">
        <td class="ld-form-item-label">{'VARIABLEINFORMATION'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
{*            {'PLEASEPASSTHEFOLLOWINGOPTIONS'|@getFixedLabel}*}
            <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td width="25%">
                        <select name="moduleselect" onchange="moduleSel(this)" class="commonSelectPop">
{*                        <select name="moduleselect" onchange="SmsContentSetting.getInstance().moduleSel(this)" class="commonSelectPop" >*}
                            {foreach item=tablabel key=tabid from=$PRINTTABS}
                                <option value="{$tabid}" {if $TABID eq $tabid}selected{/if}>{$tablabel}</option>
                            {/foreach}
                        </select>
                    </td>
                    <td width="25%">
                        <div id="tabField">
                            <select onchange="fieldSel(this)" class="commonSelectPop" style="width: 100%;">
                            </select>
                        </div>
                    </td>
                    <td width="25%">
                        <input type="text" name="selField" id="selField" class="commonTextBoxPop" />
                    </td>
                    <td width="25%">
                        <b  data-module="" data-record="" href="javascript:;" style="margin:0 10px;cursor:pointer;" data-tip="copy" data-direction="bottom" data-type="position" class="restore-default-icon restore-default-icon-copy tip-items-list" onclick="SmsContentSetting.getInstance().CopySelField(this)" ></b>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    {/if}

    <tr name="set_variable_information">
        <td class="ld-form-item-label">{'InputVar'|@getFixedLabel}</td>
        <td class="ld-form-item-content">

            <table  border="0" cellpadding="0" cellspacing="0" width="100%" name="smstemplateparam_table">
                <thead>
                <tr>
                    <td width="20%">{'TEMPLATE'|@getFixedLabel}{'VAR'|@getFixedLabel}</td>
                    <td width="20%">CRM{'VAR'|@getFixedLabel}</td>
                </tr>
                </thead>
                <tbody>
                {*{if $SmsRelatedArr.templateparamconf_arr|@is_array && $SmsRelatedArr.templateparamconf_arr|@count > 0}
                    {foreach item=crmvarname key=varname from=$SmsRelatedArr.templateparamconf_arr}
                        <tr>
                            <td class="padT16">{$varname}</td>
                            <td class="padT16"><input class="ld-input-inner gwidth90" type="text" name="{$varname}" value="{$crmvarname}" /></td>
                        </tr>
                    {/foreach}
                {/if}*}
                </tbody>
            </table>
        </td>
    </tr>

</table>
