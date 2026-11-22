{if $type neq 'add'}
{*    table直接追加非tr td开头的html tr td会被过滤*}
<input type="hidden" name="customFieldsNum" value="{$customFieldsNum}">
{/if}
{foreach key=key item=field from=$customFields}
    <tr>
        {if $type eq 'add'}
            {assign var ='key' value=$customFieldsNum+$key}
        {/if}

        <input type="hidden" name="fs_bigtype_{$key+1}"  value="{$field['bigtype']}">
        <input type="hidden" name="fs_typeofdata_{$key+1}" value="{$field['typeofdata']}">
        <input type="hidden" name="fs_isfixedtable_{$key+1}" value="{$field['isfixedtable']}">
        <input type="hidden" name="fs_module_{$key+1}" value="{$field['module']}">
        {if $field['pickListValue']}
        <input type="hidden" name="fs_pickListValue_{$key+1}" value="{$field['pickListValue']|implode:';'}">
        {/if}
        <td >{$field['fieldlabel']}<input type="hidden"  name="fs_columnname_{$key+1}" value="{$field['columnname']}"></td>
        <td name="td_fieldlabel"><input type="text" name="fs_fieldlabel_{$key+1}" columnname="{$field['columnname']}" class="ld-input-inner" value="{$field['fieldlabel']}"   /></td>
        <td name="td_required"><input type="checkbox" name="fs_required_{$key+1}" value="1" columnname="{$field['columnname']}" {if $field['required'] eq 1}checked{/if} {if $field['disabled'] eq 1}onclick="return false" {/if}/></td>
        {if $field['disabled'] eq 1}
            <input type="hidden" name="fs_disabled_{$key+1}" value="1">
        {/if}
        <td name="td_only"><input type="checkbox" name="fs_only_{$key+1}" value="1" {if $field['only'] eq 1}checked{/if}/></td>
        <td name="td_operation">
            <span class=" icon-up" name="moveUp" {if $key ==0} style="display: none"{/if}></span>
            <span class="icon-down" name="moveDown"></span>
            {if $field['disabled'] neq 1}
                <span class="icon-delete" name="delete"></span>
            {/if}
        </td>
    </tr>
{/foreach}