<table border="0" cellspacing="0" cellpadding="0" width="600" class="ld-public-content-paddingright padTB10">
    <tr>
        <td class="ld-form-item-label">
            {*字段名称*}
            <font color="red">*</font>{'LBL_FIELDNAME'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <input type="hidden" name="report_id" id="report_id" value="{$columnInfo['report_id']}">
            <input type="hidden" name="columnid" id="columnid" value="{$columnInfo['id']}">
            {*编辑的时候用来传值的*}
            {$columnInfo['columns']}
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">
            <font color="red">*</font>{'DISPLAYNAME'|@getFixedLabel}
            {*显示名称*}
        </td>
        <td class="ld-form-item-content">
            <input type="text" class="ld-input-inner" name="column_label" id="column_label" value="{$columnInfo['column_label']}">
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">
            {'fieldtype'|@getFixedLabel}
            {*字段类型*}
        </td>
        <td class="ld-form-item-content">
            {*date  datetime  number percent string*}
            <select name="fieldtype" id="fieldtype" class="ld-select-inner" >
                <option {if $columnInfo['fieldtype']=='string'}selected{/if} value="string">{'CHARACTER'|@getFixedLabel}</option>
                <option {if $columnInfo['fieldtype']=='date'}selected{/if} value="date">{'DATE'|@getFixedLabel}</option>
                <option {if $columnInfo['fieldtype']=='datetime'}selected{/if} value="datetime">{'DateTime'|@getFixedLabel}</option>
                <option {if $columnInfo['fieldtype']=='number'}selected{/if} value="number">{'Numberc'|@getFixedLabel}</option>
                <option {if $columnInfo['fieldtype']=='currency'}selected{/if} value="currency">{'AMOUNT'|@getFixedLabel}</option>
                <option {if $columnInfo['fieldtype']=='percent'}selected{/if} value="percent">{'Percents'|@getFixedLabel}</option>
            </select>
        </td>
    </tr>
</table>