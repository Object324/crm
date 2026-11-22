<tr id="sortingsetHeader">
    <td colspan="4" class="editrelhead">
        <b id="sortSetTitle">{'Setup'|@getFixedLabel}{'SORT'|@getFixedLabel}</b>
    </td>
</tr>
<tr>
<td id="sortingset" colspan="4">
    <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
        <thead>
        <tr>
            <td class="DetailedTd1Label" width="8%" align="right" >行</td>
            <td width="25%" align="left" >{'SORT'|@getFixedLabel}{'SERVICECONTRACTSTYPE'|@getFixedLabel}</td>
            <td width="25%" align="center">{'SORT'|@getFixedLabel}{'FIELDS'|@getFixedLabel}</td>
            <td width="29.4%"align="center">{'SORT'|@getFixedLabel}{'METHOD'|@getFixedLabel}</td>
            <td width="12.6%" align="left">{'OPERATING'|@getFixedLabel}</td>
        </tr>
        </thead>
        <tbody tag="sortColumnList">
        {foreach $sorting_list as $sortinfo}
            <tr tag="trSortColumnList" rowindex="1">
                <td>#</td>
                <td>
                    <select class="commonTextBoxPop" name="sorttype[]" tag="sorttype_change" {if $sortinfo.is_default=='yes'}disabled="disabled"{/if}>
                        <option {if $sortinfo.sorttype=='bycolumnname'}selected {/if} value="bycolumnname">{'ColumnNameByReport'|@getFixedLabel}</option>
                        {if $show_detail neq 'yes'}<option {if $sortinfo.sorttype=='byresult'}selected {/if} value="byresult">{'StatisticsResultValueByGroup'|@getFixedLabel}</option>{/if}
                    </select>
                </td>
                <td>
                    <select class="commonTextBoxPop" name="columns[]" tag="columns" {if $sortinfo.is_default=='yes'}disabled="disabled"{/if}>
                        {foreach $columns_list as $columns}
                            <option sorttype="{$columns.sorttype}" {if $sortinfo.columnmodule_columns==$columns.columnmodule_columns}selected {/if} value="{$columns.columnmodule_columns}">{$columns.tdheader_label}</option>
                        {/foreach}
                    </select></td>
                <td>
                    <select class="commonTextBoxPop" name="sortmethod[]" tag="sortmethod">
                        <option  {if $sortinfo.sortmethod=='asc'}selected {/if} value="asc">{'ASCENDINGORDER'|@getFixedLabel}</option>
                        <option  {if $sortinfo.sortmethod=='desc'}selected {/if}value="desc">{'DESCENDINGORDER'|@getFixedLabel}</option>
                    </select>
                </td>
                <td>{if $sortinfo.is_default=='no'}<a href="javascript:;" tag="deleted_sort">{'DELETE'|@getFixedLabel}</a>{/if}</td>
            </tr>
        {/foreach}

        </tbody>
    </table>
</td>
</tr>