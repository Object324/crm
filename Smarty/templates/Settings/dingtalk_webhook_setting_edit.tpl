{*@edit:liushuai,2020-08-21,reason:【ID1001020】钉钉接口参数设置增加参数“钉钉群消息推送设置”*}
<div class="divPopOverflow">
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="record" value="{$record}"/>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'dingtalk_webhook_setting'|@getFixedLabel}<font><span class="greyFont9">（{'dingtalk_webhook_tips3'|@getFixedLabel}）</span></font></div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'suoshumodule'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                {*wym 下面的id为tabField的元素触发change事件后name会被修改成SelectField,会和这里有重复,所以改名了*}
                {if $TYPE eq 'edit'}
                    <select disabled="disabled" onchange="moduleSel(this)" id="pick_module_edit" name="SelectModule" class="ld-select-inner width150">
                        {foreach item=tablabel key=tabid from=$PRINTTABS}
                            <option value="{$tabid}"{if $tabid eq $TABID}selected{/if}>{$tablabel}</option>
                        {/foreach}
                    </select>
                {else}
                    <select onchange="moduleSel(this)" id="pick_module_edit" name="SelectModule" class="ld-select-inner width150">
                        {foreach item=tablabel key=tabid from=$PRINTTABS}
                            <option value="{$tabid}"{if $tabid eq $TABID}selected{/if}>{$tablabel}</option>
                        {/foreach}
                    </select>
                {/if}
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'dingtalk_keywords'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="100" style="width:40%" name="keywords" value="{$keywords}" placeholder="签单提醒" class="ld-input-inner"><font><span class="greyFont9">（{'dingtalk_webhook_tips1'|@getFixedLabel}）</span></font>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>Webhook {'COMPANYADDRESS'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" size="100" name="webhook" value="{$webhook}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'WHETHERTOENABLE'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="checkbox" class="second_switch" name="is_enable" value="{$is_enable}" {if $is_enable eq 'yes'}checked{/if}>
            </td>
        </tr>
    </table>
    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'reminder_content_settings'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'VARIABLEINFORMATION'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                {'PLEASEPASSTHEFOLLOWINGOPTIONS'|@getFixedLabel}
                <table border="0" cellspacing=0 cellpadding=0 class="padT10">
                    <tr>
                        <td class="padR10">
                            <div id="tabField">
                                {foreach item=tablabel key=tabid from=$PRINTFIELD}
                                    <option value="{$tabid}"></option>
                                {/foreach}
                            </div>
                        </td>
                        <td class="padR10">
                            <input type="text" name="selField" id="selField" class="ld-input-inner" />
                        </td>
                        <td>
                            <input type="button" class="ld-button ld-button-primary" value="{'INSERTEDINTOTHECONTENTTEMPLATE'|@getFixedLabel}" onclick="InsertRemindField(this)"/>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'ACONTENTTEMPLATE'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <textarea id="templateTextArea" cols="90" rows="5" class="ld-textarea-inner" name="CKcontent" style="resize:vertical;">{$content}</textarea><br>
                <span class="greyFont9">{$WILDCARD}</span>
            </td>
        </tr>
    </table>
</form>
</div>