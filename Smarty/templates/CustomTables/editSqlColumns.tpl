<table border="0" cellspacing="0" cellpadding="0" width="600" class="ld-public-content-paddingright padTB10">
    <tr>
        <td class="ld-form-item-label">
{*            字段名称*}
            <font color="red">*</font>{'LBL_FIELDNAME'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <input type="hidden" class="ld-input-inner" name="report_id" id="report_id" value="{$columnInfo['report_id']}">
            <input type="hidden" class="ld-input-inner" name="columnid" id="columnid" value="{$columnInfo['id']}">
            {*编辑的时候用来传值的*}
            {$columnInfo['columns']}
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">
            <font color="red">*</font>{'DISPLAYNAME'|@getFixedLabel}
{*            显示名称*}
        </td>
        <td class="ld-form-item-content">
            <input type="text" class="ld-input-inner" name="tdheader_label" id="tdheader_label" value="{$columnInfo['tdheader_label']}">
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">
            {'fieldtype'|@getFixedLabel}
{*            字段类型*}
        </td>
        <td class="ld-form-item-content">
            {*date  datetime  number percent string*}
            <select name="fieldtype" id="fieldtype" class="ld-select-inner" >
                <option {if $columnInfo['fieldtype']=='string'}selected{/if} value="string">{'CHARACTER'|@getFixedLabel}</option>
                <option {if $columnInfo['fieldtype']=='date'}selected{/if} value="date">{'DATE'|@getFixedLabel}</option>
                <option {if $columnInfo['fieldtype']=='datetime'}selected{/if} value="datetime">{'DateTime'|@getFixedLabel}</option>
                <option {if $columnInfo['fieldtype']=='number'}selected{/if} value="number">{'Numberc'|@getFixedLabel}</option>
                <option {if $columnInfo['fieldtype']=='percent'}selected{/if} value="percent">{'Percents'|@getFixedLabel}</option>
            </select>
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">
            {'Penetration'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <input class="second_switch"  type="checkbox" tag="isset_linkurl" id="isset_linkurl" name="isset_linkurl" {if $columnInfo['isset_linkurl']=='yes'}checked{/if}>
        </td>
    </tr>
    <tr tag="linktype_td" {if $columnInfo['isset_linkurl']!='yes'}style="display:none"{/if}>
        <td class="ld-form-item-label">
            {'PenetrationType'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <select name="linktype" id="linktype" class="ld-select-inner" >
                <option {if is_array($columnInfo['linkurl']) && $columnInfo['linkurl']['linktype']=='detailview'}selected{/if} value="detailview">{'BIll'|@getFixedLabel}{'details1'|@getFixedLabel}</option>
                {*<option {if $report_info['linktype']=='outlink'}selected{/if} value="outlink">外部链接</option>*}
            </select>
        </td>
    </tr>
    <tr tag="primarykey_field_td" {if $columnInfo['isset_linkurl']!='yes'}style="display:none"{/if}>
        <td class="ld-form-item-label">
            {'SELECT'|@getFixedLabel}{'Primarykey'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <select name="primarykey_field" id="primarykey_field" class="ld-select-inner" >
                {foreach $columnsArr as $column_line}
                <option {if is_array($columnInfo['linkurl']) && $columnInfo['linkurl']['recordfield']==$column_line.columns}selected{/if} value="{$column_line.columns}">{$column_line.tdheader_label}</option>
                {/foreach}
            </select>
        </td>
    </tr>
</table>