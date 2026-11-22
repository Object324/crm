<table class="ld-public-content-paddingright padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr class="ld-form-item">
        <td class="ld-form-item-label">
            <font color="red">*</font>{'RULENAME'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <input type="text" class="ld-input-inner" name="rulename" value="{$rulename}"/>
        </td>
    </tr>
    <tr class="ld-form-item">
        <td class="ld-form-item-label">
            <font color="red">*</font>{'TriggerField'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content" style="overflow: inherit;">
            <select name="triggerfield"></select>
        </td>
    </tr>
</table>
<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
        <th>
            {'LayoutRules'|@getFixedLabel}
        </th>
        <th>
            <input class="ld-button ld-button-primary" name="btn_addlayoutrule" type="button" name="New" value="{'CreateLayoutRules'|@getFixedLabel}" style="float: right;" />
        </th>
    </tr>
</table>
<table name="tablerulecondition" class="settingPopTable" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
        <td style="text-align:center; width:4%">#</td>
        <td style="text-align:center; width:30%"><font color="red">*</font>{'TriggerFieldCondition'|@getFixedLabel}</td>
        <td style="text-align:center; width:30%">{'OtherCondition'|@getFixedLabel}</td>
        <td style="text-align:center; width:36%"><font color="red">*</font>{'Triggeredoperation'|@getFixedLabel}</td>
    </tr>
</table>