{*统计维度设置*}
<tr>
    <td colspan="4" class="editrelhead">
        <b id="groupBySetTitle">{'Xaxiscategory'|@getFixedLabel}</b>
    </td>
</tr>
<tr>
    <td class="DetailedTd1Label" align="right">
        <font color="red">*</font>{'StatisticsModule'|@getFixedLabel}
    </td>
    <td>
        <select  fieldtype="selecttype" name="mainmodule" id="mainmodule" class="detailedViewTextBox input-width-70 custom-select js-example-basic-single">
            {foreach item=modulename key=i from=$module_arr}
                <option {if $chart_info['mainmodule']==$modulename['modulename']}selected{/if} value="{$modulename['modulename']}">{$modulename['name']}</option>
            {/foreach}
        </select>
    </td>
    <td></td>
    <td></td>
</tr>
<tr id="groupbytr">
    <td class="DetailedTd1Label" align="right">
        <div class="style-set-label"><font color="red">*</font>{'StatisticalDimension'|@getFixedLabel}</div>
    </td>
    <td>
        <div class="style-set-input">
            <div id="groupby_div">
                <select fieldtype="selecttype" name="groupby" id="groupby" class="detailedViewTextBox {if $chart_info['groupInfo'][0]['groupbytype']!='byField'}input-width-35{else}input-width-70{/if}" onchange="CustomEchartsCreateObj.changeGroupBy(this)">
                </select>
            </div>
            <div id="groupbytype_div" {if $Show_time_group_type=='no'} style="display:none;" {/if}>
                <select fieldtype="selecttype" name="groupbytype" id="groupbytype" class="detailedViewTextBox input-width-35 custom-select">
                    <option value="byField">{'Pleaseselectthetimestatisticsmethod'|@getFixedLabel}</option>
                    {foreach item=timeFormat key=timeFormatKey from=$timeFormatType}
                        <option {if $chart_info['groupInfo'][0]['groupbytype']==$timeFormatKey} selected {/if}  value="{$timeFormatKey}">{$timeFormat}</option>
                    {/foreach}
                </select>
            </div>
        </div>
    </td>
    <td>
        <div class="style-set-label">
            <input type="checkbox" id="groupby_secondcheck" name="groupby_secondcheck" class="" {if $chart_info['groupInfo'][1]}checked{/if}>
            <label id="groupby_secondlabel">{'Seconddimension'|@getFixedLabel}</label>
        </div>
    </td>
    <td>
        <div class="style-set-input">
            <div id="groupby_second_div">
                <select fieldtype="selecttype" name="groupby_second" id="groupby_second" class="detailedViewTextBox {if $chart_info['groupInfo'][1]&&$chart_info['groupInfo'][1]['groupbytype']!='byField'}input-width-35{else}input-width-70{/if}"  onchange="CustomEchartsCreateObj.changeGroupBy(this)">
                </select>
            </div>
            <div id="groupbytype_second_div" style="display:none;">
                <select fieldtype="selecttype" name="groupbytype_second" id="groupbytype_second" class="detailedViewTextBox input-width-35">
                    <option value="byField">{'Pleaseselectthetimestatisticsmethod'|@getFixedLabel}</option>
                    {foreach item=timeFormat key=timeFormatKey from=$timeFormatType}
                        <option {if $chart_info['groupInfo'][1]&&$chart_info['groupInfo'][1]['groupbytype']==$timeFormatKey} selected {/if} value="{$timeFormatKey}">{$timeFormat}</option>
                    {/foreach}
                </select>
            </div>
        </div>
    </td>
</tr>
