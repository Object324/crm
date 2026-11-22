{*统计维度设置*}
<tr>
    <td colspan="4" class="editrelhead">
        <b id="groupBySetTitle">{'Xaxiscategory'|@getFixedLabel}</b>
    </td>
</tr>
<tr id="groupbytr">
    <td class="DetailedTd1Label tdminwidth150" align="right">
        <div class="style-set-label">{'StatisticalDimension'|@getFixedLabel}</div>
    </td>
    <td>
        <div class="style-set-input">
            <select name="groupby" id="groupby" class="detailedViewTextBox input-width-70">
                {foreach item=columnstd key=j from=$sqlColumnsArr}
                    <option {if $groupInfo[0]['columns'] == $columnstd.id }selected{/if} value="{$columnstd.id}">{$columnstd.column_label}</option>
                {/foreach}
            </select>
        </div>
    </td>
    <td class="DetailedTd1Label tdminwidth150"  align="right">
        <div class="style-set-label">
            <input type="checkbox" id="groupby_secondcheck" name="groupby_secondcheck" class="" {if $groupInfo[1]}checked{/if}>
            <label id="groupby_secondlabel">{'Seconddimension'|@getFixedLabel}</label>
        </div>
    </td>
    <td>
        <div class="style-set-input">
            <select name="groupby_second" id="groupby_second" class="detailedViewTextBox input-width-70">
                {foreach item=columnstd key=j from=$sqlColumnsArr}
                    <option {if $groupInfo[1]['columns'] == $columnstd.id }selected{/if} value="{$columnstd.id}">{$columnstd.column_label}</option>
                {/foreach}
            </select>
        </div>
    </td>
</tr>