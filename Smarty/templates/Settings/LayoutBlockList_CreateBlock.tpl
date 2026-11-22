<table class="ld-public-content-paddingright padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr id="editfield_{$ID}heading" >
        <td class="ld-form-item-label">
            <font color="red">*</font>{'CNTAG'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <input id="blocklabel" value="" type="text" class="ld-input-inner"/>
        </td>
    </tr>
    <tr id="editfield_{$ID}heading" >
        <td class="ld-form-item-label">
            <font color="red">*</font>{'ENTAG'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <input id="blocklabel2" value="" type="text" class="ld-input-inner"/>
        </td>
    </tr>
    <tr id="editfield_{$ID}heading" >
        <td class="ld-form-item-label">
            {'After'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <select id="after_blockid" name="after_blockid" class="ld-select-inner">
                {foreach key=blockid item=blockname from=$SETTINGBLOCKS}
                <option value = {$blockid}> {$blockname} </option>
                {/foreach}
            </select>
        </td>
    </tr>
</table>