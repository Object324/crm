{*ls  241031 XUQIU20240918-09 增加会话存档接口配置参数*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/WechatSessionSetting.js?v={$GLOBALMINVERSION}"></script>
{if $mode eq 'edit'}
    <form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
        <input type="hidden" name="module" value="Settings"/>
        <input type="hidden" name="parenttab" value="Settings"/>
        <input type="hidden" name="ajax" value="save"/>
        <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td colspan="2">
                    <div class="ld-pop-contnet-title-items">
                        <div class="ld-pop-contnet-title-item">{'LBL_INTERFACE_SETTINGS'|@getFixedLabel}</div>
                    </div>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>{'Wechatsession'|@getFixedLabel} Secret</td>
                <td class="ld-form-item-content">
                    <input tag="required" label="{'Wechatsession'|@getFixedLabel} Secret" type="text" size="50" name="secret" id="secret" value="{$secret}" class="ld-input-inner">
                </td>
            </tr>
        </table>
        <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td colspan="2">
                    <div class="ld-pop-contnet-title-items">
                        <div class="ld-pop-contnet-title-item">{'SessionBasicSettings'|@getFixedLabel}</div>
                    </div>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>{'FileStorageMode'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <select name="upload_way" class="ld-select-inner">
                        <option value="local">{'LocalServer'|@getFixedLabel}</option>
                        <option value="cos" {if $upload_way eq 'cos'}selected{/if}>{'TencentCloud'|@getFixedLabel} COS</option>
                    </select>
                </td>
            </tr>
            <tr style="display: none;">
                <td class="ld-form-item-label"><font color="red">*</font>SecretiId</td>
                <td class="ld-form-item-content">
                    <input tag="required" label="SecretId" type="text" size="100" name="secretid" value="{$secretid}" class="ld-input-inner">
                </td>
            </tr>
            <tr style="display: none;">
                <td class="ld-form-item-label"><font color="red">*</font>SecretKey</td>
                <td class="ld-form-item-content">
                    <input tag="required" label="SecretKey" type="password" size="100" name="secretkey" id="secretkey" value="{$secretkey}" class="ld-input-inner">
                </td>
            </tr>
            <tr style="display: none;">
                <td class="ld-form-item-label"><font color="red">*</font>{'Bucketname'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <input tag="required" label="{'Bucketname'|@getFixedLabel}" type="text" size="100" name="bucketname" id="bucketname" value="{$bucketname}" class="ld-input-inner">
                </td>
            </tr>
            <tr style="display: none;">
                <td class="ld-form-item-label"><font color="red">*</font>{'Region'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <input tag="required" label="{'Region'|@getFixedLabel}" type="text" size="100" name="region" id="region" value="{$region}" class="ld-input-inner">
                </td>
            </tr>
        </table>
        <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td colspan="2">
                    <div class="ld-pop-contnet-title-items">
                        <div class="ld-pop-contnet-title-item">{'msgExceptionRemindSet'|@getFixedLabel}</div>
                    </div>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">{'SessionNotUpdateSendMsg'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <input tag="required" type="checkbox" size="100" name="enable_remind" class="second_switch" {if $enable_remind eq 'yes'}checked{/if}>
                </td>
            </tr>
            <tr id="tr_specify_reminder" {if $enable_remind neq 'yes'}style="display: none;"{/if}>
                <td class="ld-form-item-label"><font color="red">*</font>{'REMINDERPEOPLE'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <div id="dv_specify_reminder">
                        <div class="ld-input-inner-div ld-input-inner-add" id="receiverids_name" name="receiverids_name">{$receiverids_name}</div>
                        <a class="{*ld-text-select*} icon-range" style="top: 20px;" href="javascript:;" title="选择" onclick="WechatSessionSetting.getInstance().getSessionRemindsUserIds();"></a>
                        <a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="ld('#receiverids').val('');ld('#receiverids_name').text('');return false;">+</a>
                        <input label="{'REMINDERPEOPLE'|@getFixedLabel}" name="receiverids" id="receiverids" value="{if $receiverids neq ''}{$receiverids}{/if}" type="hidden">
                    </div>
                </td>
            </tr>
            <tr {if $enable_remind neq 'yes'}style="display: none;"{/if}>
                <td class="ld-form-item-label"><font color="red">*</font>{'REMINDSCONTENT'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <textarea class="ld-textarea-inner" tag="required" label="{'REMINDSCONTENT'|@getFixedLabel}" name="remind_content" id="remind_content">{$remind_content}</textarea>
                </td>
            </tr>
        </table>
    </form>
{else} {*列表页面*}
    <form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
        <input type="hidden" name="module" value="Settings"/>
        <input type="hidden" name="parenttab" value="Settings"/>
        <input type="hidden" name="action"/>
        <div class="main_grid_top">
            <div class="grid-view-title lfloat overflow-hidden">
                <span class="grid-view-name dinline-block lfloat">
                    {'LBL_WECHATSESSION_SETTINGS'|@getFixedLabel}
                </span>
            </div>
            <div class="grid_tool">
                <div class="displayflex">
                    <a href="javascript:;" class="ld-button ld-button-primary" onclick="WechatSessionSetting.getInstance().edit()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
                    <a href="javascript:;" class="ld-button" onclick="WechatSessionSetting.getInstance().logout()" title="{'LOGOUTS'|@getFixedLabel}">{'LOGOUTS'|@getFixedLabel}</a>
                </div>
            </div>
        </div>
        <div class="main_grid_box">
            <div class="grid-analysis-box">
                <div class="grid-analysis-header">
                </div>
                <div class="cont_wrap clear_float">
                    <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <th colspan="2">{'LBL_INTERFACE_SETTINGS'|@getFixedLabel}</th>
                        </tr>
                        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                            <td width="20%">{'Wechatsession'|@getFixedLabel} Secret</td>
                            <td>{$secret}</td>
                        </tr>
                    </table>
                    <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <th colspan="2">{'SessionBasicSettings'|@getFixedLabel}</th>
                        </tr>
                        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                            <td width="20%">{'FileStorageMode'|@getFixedLabel}</td>
                            <td>{if $upload_way eq 'cos'}{'TencentCloud'|@getFixedLabel} COS{else}{'LocalServer'|@getFixedLabel}{/if}</td>
                        </tr>
                        {if $upload_way eq 'cos'}
                        <tr class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                            <td>SecretId</td>
                            <td>{$secretid}</td>
                        </tr>
                        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                            <td>SecretKey</td>
                            <td>{if $secretkey neq ''}<span title="******">******</span>{/if}</td>
                        </tr>
                        <tr class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                            <td>{'Bucketname'|@getFixedLabel}</td>
                            <td>{$bucketname}</td>
                        </tr>
                        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                            <td>{'Region'|@getFixedLabel}</td>
                            <td>{$region}</td>
                        </tr>
                        {/if}
                    </table>
                    <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <th colspan="2">{'msgExceptionRemindSet'|@getFixedLabel}</th>
                        </tr>
                        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                            <td width="20%">{'SessionNotUpdateSendMsg'|@getFixedLabel}</td>
                            <td>{if $enable_remind eq 'yes'}{'YES'|@getFixedLabel}{else}{'NO'|@getFixedLabel}{/if}</td>
                        </tr>
                        {if $enable_remind eq 'yes'}
                        <tr class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                            <td>{'REMINDERPEOPLE'|@getFixedLabel}</td>
                            <td>{$receiverids_name}</td>
                        </tr>
                        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                            <td>{'REMINDSCONTENT'|@getFixedLabel}</td>
                            <td>{$remind_content}</td>
                        </tr>
                        {/if}
                    </table>
                </div>
            </div>
        </div>
    </form>
{/if}