<table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
    <tbody>
    <tr>
        <td colspan="4" class="editrelhead">
            <b>{'StyleSettings'|@getFixedLabel}</b>
        </td>
    </tr>
    <tr>
        <td width="15%" class="DetailedTd1Label" align="right">
            {'TotalPosition'|@getFixedLabel}
        </td>
        <td width="35%">
            <select name="total_position" id="total_position" class="ld-select-inner">
                <option {if $report_info['total_position']=='bottom'} selected {/if} value="bottom">{'Bottom'|@getFixedLabel}</option>
                <option {if $report_info['total_position']=='top'}selected{/if} value="top">{'Top'|@getFixedLabel}</option>
            </select>
        </td>
        <td width="15%" class="DetailedTd1Label" align="right">
            {'SetLink'|@getFixedLabel}
        </td>
        <td width="35%">
            <input class="second_switch" type="checkbox" id="linkmodulecheck" name="linkmodulecheck" {if $report_info['linkmodulecheck']=='yes'}checked{/if}>
        </td>
       {* <td width="15%" class="DetailedTd1Label" align="right">
             {'Showdetails'|@getFixedLabel}
        </td>
        <td width="35%">
            <input type="checkbox" id="show_detail" name="show_detail" {if !$report_info || $report_info['show_detail']=='yes'}checked{/if}>
        </td>*}
    </tr>
    <tr>
        <td width="15%" class="DetailedTd1Label" align="right">
            {'showAtPcHome'|@getFixedLabel}
        </td>
        <td width="35%">
            <input class="second_switch" type="checkbox" id="show_athome" name="show_athome" {if $report_info['show_athome']=='yes'}checked{/if}>
        </td>
        <td width="15%" class="DetailedTd1Label" align="right">
            {'OFTENUSEREPORTWORD'|@getFixedLabel}{'CAMCARDCAPTION'|@getFixedLabel}
        </td>
        <td width="35%">
            <textarea class="ld-textarea-inner" name="description" id="description"  aria-label="{'OFTENUSEREPORTWORD'|@getFixedLabel}{'CAMCARDCAPTION'|@getFixedLabel}">{$report_info['description']}</textarea>
        </td>
    </tr>
    <tr>
        <td colspan="4" class="editrelhead">
            <b> {'ConditionSetting'|@getFixedLabel}</b>
        </td>
    </tr>
    <tr>
        <td colspan="4" style="padding:0 10px;">
            <div style="width:80%;margin:20px auto;background-color: #transparent;padding: 10px;">
                <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed" id="conditionColumnList">
                    <thead>
                    <tr tag="">
                        <td align="right" colspan="5" style="border-bottom: none;">
                            <a title="{'NEWCOMBINATION'|@getFixedLabel}" class="ld-button ld-button-primary" data-groupid="1" tag="addgroupcondition">
                                <span>{'NEWCOMBINATION'|@getFixedLabel}</span>
                            </a>
                            <a style="margin-right:10px;"  title="{'CLEAR'|@getFixedLabel}" class="ld-button ld-button-primary" tag="clearAll">
                                <span>{'CLEAR'|@getFixedLabel}</span>
                            </a>
                        </td>
                    </tr>
                    <tr>
                        <td width="20%" align="center">{'SelectField'|@getFixedLabel}</td>
                        <td width="20%" align="center">{'SelectCon'|@getFixedLabel}</td>
                        <td width="40%" align="center">{'Keyword2'|@getFixedLabel}</td>
                        <td width="10%" align="center">{'SELECT'|@getFixedLabel}{'relationship'|@getFixedLabel}</td>
                        <td width="10%" align="center">{'Operation2'|@getFixedLabel}</td>
                    </tr>
                    </thead>
                    <tbody id="conditionColumnBody">
                    </tbody>
                </table>
            </div>
        </td>
    </tr>
    </tbody>
</table>