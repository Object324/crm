<div class="ld-pop-container ld-table-container ld-table-container-lines">
<div class="divPopOverflow">
<form id="sortSetList">
    <input type="hidden" name="report_id" value="{$report_id}">
<table border="0" cellspacing="0" cellpadding="0" width="100%" class="">
    <thead>
    <tr>
        <th width="30%">{'SERVICECONTRACTSTYPE'|@getFixedLabel}</th>
        <th width="30%">{'FIELDS'|@getFixedLabel}</th>
        <th width="30%">{'METHOD'|@getFixedLabel}</th>
        <th width="10%">{'OPERATING'|@getFixedLabel}</th>
    </tr>
    </thead>
    <tbody>
    <tr tag="trSortColumnList" rowindex="0" style="display:none;">
        <td>
            <select class="ld-select-inner" name="sorttype[]" tag="sorttype_change">
                <option value="bycolumnname">{'ColumnNameByReport'|@getFixedLabel}</option>
                {if $show_detail neq 'yes'}<option value="byresult">{'StatisticsResultValueByGroup'|@getFixedLabel}</option>{/if}
            </select>
        </td>
        <td>
            <select class="ld-select-inner" name="columns[]" tag="columns">
                {foreach $columns_list as $columns}
                    <option sorttype="{$columns.sorttype}" value="{$columns.columnmodule_columns}">{$columns.tdheader_label}</option>
                {/foreach}
            </select>
        </td>
        <td>
            <select class="ld-select-inner" name="sortmethod[]" tag="sortmethod">
                <option value="asc">{'ASCENDINGORDER'|@getFixedLabel}</option>
                <option value="desc">{'DESCENDINGORDER'|@getFixedLabel}</option>
            </select>
        </td>
        <td><i class="ld-fonticon ld-fonticon-del" tag="deleted_sort"></i></td>
    </tr>
    {foreach $sorting_list as $sortinfo}
        <tr tag="trSortColumnList" rowindex="1">
            <td>
                <select class="commonSelectPop commonTextBoxPop" name="sorttype[]" tag="sorttype_change" {if $sortinfo.is_default=='yes'}disabled="disabled"{/if}>
                    <option {if $sortinfo.sorttype=='bycolumnname'}selected {/if} value="bycolumnname">{'ColumnNameByReport'|@getFixedLabel}</option>
                    {if $show_detail neq 'yes'}<option {if $sortinfo.sorttype=='byresult'}selected {/if} value="byresult">{'StatisticsResultValueByGroup'|@getFixedLabel}</option>{/if}
                </select>
            </td>
            <td>
                <select class="commonSelectPop commonTextBoxPop" name="columns[]" tag="columns" {if $sortinfo.is_default=='yes'}disabled="disabled"{/if}>
                    {foreach $columns_list as $columns}
                    <option sorttype="{$columns.sorttype}" {if $sortinfo.columnmodule_columns==$columns.columnmodule_columns}selected {/if} value="{$columns.columnmodule_columns}">{$columns.tdheader_label}</option>
                    {/foreach}
                </select></td>
            <td>
                <select class="commonSelectPop commonTextBoxPop" name="sortmethod[]" tag="sortmethod">
                    <option  {if $sortinfo.sortmethod=='asc'}selected {/if} value="asc">{'ASCENDINGORDER'|@getFixedLabel}</option>
                    <option  {if $sortinfo.sortmethod=='desc'}selected {/if}value="desc">{'DESCENDINGORDER'|@getFixedLabel}</option>
                </select>
            </td>
            <td>{if $sortinfo.is_default=='no'}<i class="ld-fonticon ld-fonticon-del" tag="deleted_sort"></i>{/if}</td>
        </tr>
    {/foreach}
    </tbody>
</table>
</form>
</div>
    <div class="padT16">
        <a href="javascript:;" tag="add_sort">+{'NEW'|@getFixedLabel}</a>
    </div>
    <div class="padT16">
        <span style="line-height:20px;height:20px;display:block;">1.分组字段排序优先，顺序不可调整，仅可调整排序方式；</span>
        <span style="line-height:20px;height:20px;display:block;">2.显示明细  仅按报表列名排序设置生效。</span>
    </div>
</div>