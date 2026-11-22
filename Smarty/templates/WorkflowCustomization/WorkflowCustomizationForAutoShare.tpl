<input type="hidden" value="{$MODULE}" id="autoshare_module">
<input type="hidden" name="workflow_aciton_type" value="AutoShare" />
<input type="hidden" name="workflow_actionid" value='{$workflow_actionid}' />
<input type="hidden" name="workflow_id" value='{$workflow_id}' />
<table class="ld-public-content-small" width="100%" cellspacing="0" cellpadding="0" border="0">
    <tbody>
    <tr>
        <td class="ld-form-item-label">
            <font color="red">*</font>{'ActionTitle'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <input class="ld-input-inner" type="text" name="action_title" tag="{'ActionTitle'|@getFixedLabel}" value="{$action_title}">
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">
            <font color="red">*</font>{'Sharingmethod'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <select class="ld-select-inner width150" name="Action_autoshare_type">
                <option value="User" {if $autoshare_type == 'User'}selected{/if}>{'SPECIFYUSER'|@getFixedLabel}</option>
                <option value="UserField" {if $autoshare_type == 'UserField'}selected{/if}>{'SPECIFYFIELDS'|@getFixedLabel}</option>
            </select>
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">
        </td>
        <td class="ld-form-item-content">
            <div name="Action_autoshare_User" data-selectlabel="{'SelectMultiUser'|@getFixedLabel}" {if $autoshare_type == 'User'}{else}style="display: none;"{/if}>
                <div class="ld-input-inner ld-input-inner-add" id="Action_autoshare_User_div" name="Action_autoshare_User_div" style="padding-left: 8px;overflow: hidden;text-overflow: ellipsis;height: 30px;line-height: 30px;">{$share_setvalue_username}</div>
                <a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" id="Action_autoshare_User_select" draggable="false">+</a>
                <a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" id="Action_autoshare_User_clear" draggable="false">+</a>
                <input type="hidden" value="{$share_setvalue_user}" id="Action_autoshare_User_value">
            </div>
            <select class="ld-select-inner width150" name="Action_autoshare_UserField" style="{if $autoshare_type == 'UserField'}{else}display: none;{/if}">
                {foreach key=columname item=fieldlabel from=$USERS_FIELD_ARR}2023
                    <option value="{$columname}" {if $share_setvalue_field == $columname}selected{/if}>{$fieldlabel}</option>
                {/foreach}
            </select>
        </td>
    </tr>
    </tbody>
</table>