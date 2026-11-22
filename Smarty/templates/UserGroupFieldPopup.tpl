<div id="setUserGroupField_content" style="width:100%;">
    <table class="ld-public-content-paddingright padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr class="ld-form-item">
            <td class="ld-form-item-label">
                {'GROUPNO'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                {*部门编号字段启用*}
                {if $ISDEPARTMENTNUMBER neq 'no'}
                <input type="checkbox" id="departmentNumber" name="departmentNumber" class="second_switch" value="" checked>
                {else}
                {*部门编号字段不启用*}
                <input type="checkbox" id="departmentNumber" name="departmentNumber" class="second_switch" value="">
                {/if}
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                {'REMARK'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                {*备注字段启用*}
                {if $ISDEPARTMENTREMARK neq 'no'}
                    <input type="checkbox" id="departmentRemark" name="departmentRemark" class="second_switch" value="" checked>
                {else}
                {*备注字段不启用*}
                    <input type="checkbox" id="departmentRemark" name="departmentRemark" class="second_switch" value="">
                {/if}
            </td>
        </tr>
    </table>
</div>
<!-- <div id="setUserGroupField_content" style="width:100%;">
    <div name="field_table_header" style="width:100%;">
        <table border=0 cellspacing=0 cellpadding=0 width=100% class="settingPopTable fir-center field_table_header_table" >
            <tr class="ld-form-item">
                <td class="ld-form-item-label" title="{'LBL_FIELDNAME'|@getFixedLabel}">{'LBL_FIELDNAME'|@getFixedLabel}</td>
                <td class="ld-form-item-content" title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</td>
            </tr>
        </table>
    </div>
    <div name="field_table_body" style="width:100%;">
        <table class="settingPopTable lasttdbordernon field_table_body_table" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr class="ld-form-item">
                <td class="ld-form-item-label">
                    {'GROUPNO'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    {*部门编号字段启用*}
                    {if $ISDEPARTMENTNUMBER neq 'no'}
                    <input type="checkbox" id="departmentNumber" name="departmentNumber" class="second_switch" value="" checked>
                    {else}
                    {*部门编号字段不启用*}
                    <input type="checkbox" id="departmentNumber" name="departmentNumber" class="second_switch" value="">
                    {/if}
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    {'REMARK'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    {*备注字段启用*}
                    {if $ISDEPARTMENTREMARK neq 'no'}
                        <input type="checkbox" id="departmentRemark" name="departmentRemark" class="second_switch" value="" checked>
                    {else}
                    {*备注字段不启用*}
                        <input type="checkbox" id="departmentRemark" name="departmentRemark" class="second_switch" value="">
                    {/if}
                </td>
            </tr>
        </table>
    </div>
</div> -->