{*基本信息设置  都是一样的  包含图表类型 图表名称 图表文件夹 图表描述四项*}
<tr>
    <td colspan="4" class="editrelhead">
        <b>{'BASICINFO'|@getFixedLabel}</b>
    </td>
</tr>
<tr>
    <td width="8%" class="DetailedTd1Label tdminwidth150" align="right">
        <font color="red">*</font>{'chartType'|@getFixedLabel}
    </td>
    <td width="42%" id="chart_type_label">
        {$chart_info['chart_type_name']}
    </td>
    <td width="8%" class="DetailedTd1Label tdminwidth150" align="right">
        <font color="red">*</font>{'SELECT'|@getFixedLabel}{'MAILFOLDER'|@getFixedLabel}
    </td>
    <td width="42%">
        <select name="analysisfolder_id" id="analysisfolder_id" tag="所属文件夹" class="detailedViewTextBox input-width-70" style="width:90%">
            {$folderOptions}
        </select>
    </td>
</tr>
<tr>
    <td class="DetailedTd1Label" align="right">
        <font color="red">*</font>{'chartName'|@getFixedLabel}
    </td>
    <td>
        <input type="hidden" name="report_id" id="report_id" value="{$chart_info['report_id']}">
        <input type="hidden" name="report_type" id="report_type" value="chart">
        <input type="hidden" name="chart_type" id="chart_type" value="{$chart_info['chart_type']}">
        <input type="text" name="report_name" id="report_name" placeholder="{'chartName'|@getFixedLabel}" value="{$chart_info['report_name']}" class="detailedViewTextBox  input-width-70" autocomplete="off" required>
    </td>
    <td class="DetailedTd1Label" align="right">
        {'CAMCARDCAPTION'|@getFixedLabel}
    </td>
    <td>
        <textarea class="detailedViewTextBox input-width-70" name="report_desc" style="margin-top: 3px; overflow: hidden; overflow-wrap: break-word; resize: horizontal; height: 52px;" id="report_desc"  aria-label="{'CAMCARDCAPTION'|@getFixedLabel}">{$chart_info['report_desc']}</textarea>
    </td>
</tr>
<tr>
    <td width="8%" class="DetailedTd1Label tdminwidth150" align="right">
        选择主题
    </td>
    <td width="42%">
        <select name="themename" id="themename" tag="主题" class="detailedViewTextBox input-width-70">
            {foreach item=themeinfo key=themekey from=$themeArr}
                <option {if $chart_info['themename'] == $themekey }selected{/if} value="{$themekey}">{$themeinfo.themeLabel}</option>
            {/foreach}
        </select>
    </td>
    <td width="8%"></td>
    <td width="42%"></td>
</tr>
