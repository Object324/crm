<input type="hidden" name="blockid" id="blockid" value="{$BLOCK_ID}">
<input type="hidden" name="blocktype" id="blocktype" value="{$BLOCK_TYPE}">
<table class="ld-createedit-tablecontent" style="padding-right: 80px;" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr class="ld-form-item" >
        <td class="ld-form-item-label" >
            <font color="red">*</font>{'BlockName'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content" align="left">
            {if $BLOCK_TYPE == 'virtual'}
                <input id="block_name" name="block_name" value="{'Virtual_block'|@getFixedLabel}" type="text" disabled class="ld-input-inner"/>
            {else}
                <input id="block_name" name="block_name" value="{$BLOCK_NAME}" type="text"  class="ld-input-inner"/>
            {/if}
        </td>
    </tr>
    {if $BLOCK_TYPE != 'virtual'}
        <tr class="ld-form-item" id="">
            <td class="ld-form-item-label">
                {'After'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content" >
                <select id="after_blockid" name="after_blockid" class="ld-select-inner" >
                    {foreach key=blockid item=blockname from=$BLOCKLIST}
                        {if $blockname == 'virtual'}
                            <option value="{$blockid}" {if $AFTERBLOCKID == $blockid}selected{/if}>{'Virtual_block'|@getFixedLabel}</option>
                        {else}
                            {if $BLOCK_ID != $blockid}
                                <option value="{$blockid}" {if $AFTERBLOCKID == $blockid}selected{/if}>{$blockname}</option>
                            {/if}
                        {/if}
                    {/foreach}
                </select>
            </td>
        </tr>
    {/if}
    <tr class="ld-form-item" >
        <td class="ld-form-item-label" >
            {'automatic_number'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content" align="left">
            {if $BLOCK_ID > 0}
                <input id="automatic_number" type="checkbox" class="second_switch" {if $AUTONUMBER == 'yes'}checked{/if}>
            {else}
                <input id="automatic_number" type="checkbox" class="second_switch">
            {/if}
        </td>
    </tr>
    <tr class="ld-form-item" id="automatic_number_style_tr" {if $AUTONUMBER == 'yes'}{else}style="display: none;"{/if}>
        <td class="ld-form-item-label">
            {'Automatic_number_style'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content" >
            <select id="automatic_number_style" name="" class="ld-select-inner">
                <option value = ',' {if $NUMBERSTYLE == ','}selected{/if}>1, 2, 3 …</option>
                <option value = 'O,' {if $NUMBERSTYLE == 'O,'}selected{/if}>①, ②, ③ …</option>
                <option value = '),' {if $NUMBERSTYLE == '),'}selected{/if}>1), 2), 3) …</option>
                <option value = '(),' {if $NUMBERSTYLE == '(),'}selected{/if}>(1), (2), (3) …</option>
            </select>
        </td>
    </tr>
    <tr class="ld-form-item" id="automatic_number_postfix_tr" {if $AUTONUMBER == 'yes'}{else}style="display: none;"{/if}>
        <td class="ld-form-item-label" >
            {'Automatic_number_postfix'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content" >
            <select id="automatic_number_postfix" name="" class="ld-select-inner" >
                <option value = '' {if $NUMBERSUFFIX == ''}selected{/if}></option>
                <option value = '、' {if $NUMBERSUFFIX == '、'}selected{/if}>、</option>
                <option value = '.' {if $NUMBERSUFFIX == '.'}selected{/if}>.</option>
            </select>
        </td>
    </tr>
</table>
