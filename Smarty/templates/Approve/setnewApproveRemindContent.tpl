<!--修改编码格式:统一编码：UTF-8-->
{if $PlatForm eq "aliyun" && $RemindMethod eq 'sms'}
    {include file="SmsRemindContent.tpl"}

    <tr>
        <td class="ld-form-item-label"></td>
        <td class="ld-form-item-content">
            <span class="greyFont9" style="display: inline-block;white-space: pre-wrap;padding-top: 5px">{$WILDCARD}</span>
        </td>
    </tr>
{else}
    <form name="frmsendInfoContent" method="post" action="index.php">
        <input type="hidden"  name="module"  value="MassSMS"/>
        <input type="hidden" name="action" value="SendInform"/>
        <input type="hidden" name="parenttab" value="Marketing">
        <input type="hidden" name="contenttype" id="contenttype" value="{$CONTENTTYPE}">
        <input type="hidden" id="out_id" name="out_id" value="{$OUT_ID}">
        <input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}">
        <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr style="display:none;" name="approveRemindtitle_tr">
                <td class="ld-form-item-label">
                    <font color="red">*</font>{'ReminderTitle'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    <input  type="text" name="approveRemindtitle" class="detailedViewTextBox gwidth40" value=""/>{'MobileReminderContenttitle'|@getFixedLabel}
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label padT0">{'VARIABLEINFORMATION'|@getFixedLabel}</td>
                <td class="ld-form-item-content padT0">
                    {'PLEASEPASSTHEFOLLOWINGOPTIONS'|@getFixedLabel}
                    <table border="0" cellspacing=0 cellpadding=0 class="small" >
                        <tr>
                            <td width="25%" style="padding: 5px 8px 0 0;">
                                <select onchange="moduleSel(this)" class="ld-select-inner" disabled>
                                    <!--<option value="0">请选择相关模块</option>-->
                                    {foreach item=tablabel key=tabid from=$PRINTTABS}
                                        <option value="{$tabid}"{if $TABID eq $tabid}selected{/if}>{$tablabel}</option>
                                    {/foreach}
                                </select>
                            </td>
                            <td width="25%" style="padding: 5px 8px 0 0;">
                                <div id="tabField">
                                    <select onchange="fieldSel(this)" class="ld-select-inner" style="width: 100%;">
                                        {*                                    <option>{'PLEASESELECTFIELD'|@getFixedLabel}</option>*}
                                    </select>
                                </div>
                            </td>
                            <td width="25%" style="padding: 5px 8px 0 0;">
                                <input type="text" class="ld-input-inner" name="selField" id="selField" class="detailedViewTextBox" />
                            </td>
                            <td width="25%" style="padding: 5px 0 0 0;">
                                <input type="button" class="ld-button ld-button-primary" value="{'INSERTEDINTOTHECONTENTTEMPLATE'|@getFixedLabel}" onclick="InsertRemindField(this)"/>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">{'ACONTENTTEMPLATE'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <textarea cols="90" rows="5" name="CKcontent" class="ld-textarea-inner" style="resize:vertical;">{$CONTENT}</textarea><br>
                    <span class="greyFont9" style="display: inline-block;white-space: pre-wrap;padding-top: 5px">{$WILDCARD}</span>
                </td>
            </tr>
        </table>
    </form>
{/if}
