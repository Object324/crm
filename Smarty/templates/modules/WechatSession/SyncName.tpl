<input type="hidden" id="isAppMarket" name="isAppMarket" value="{if $isAppMarket}true{else}false{/if}">
<div>
    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="line-height: 30px;">
        <tbody>
{*        {if !$isAppMarket}*}
        <tr>
            <td align="right"><font color="red">*</font>Secret</td>
            <td align="left"><input type="text" id="secret" name="secret" class="detailedViewTextBox" value="{$Secret}"></td>
        </tr>
{*        {/if}*}
        <tr>
            <td align="right">
                <input type="checkbox" checked="checked" id="sync_external_contact" name="sync_external_contact" class="" value="">
            </td>
            <td align="left">{'SyncExternalContactName'|@getFixedLabel}</td>
        </tr>
        <tr>
            <td align="right">
                <input type="checkbox" checked="checked" id="sync_group_name" name="sync_group_name" class="" value="" onclick="WechatSessionobj.ChatSessionListobj.syncNameEvent(this)">
            </td>
            <td align="left">{'SyncGroupName'|@getFixedLabel}</td>
        </tr>
        <tr>
            <td align="right">
                {*@edit:liushuai,2021-07-21,reason:46290: 会话存档->会话列表，同步“同步联系人姓名/群名”的时候，导入外部联系人参数默认不勾选*}
                <input type="checkbox" id="import_external_contact" name="import_external_contact" class="" value="">
            </td>
            <td align="left">{'ImportExternalContacts'|@getFixedLabel}</td>
        </tr>
        </tbody>
    </table>

</div>