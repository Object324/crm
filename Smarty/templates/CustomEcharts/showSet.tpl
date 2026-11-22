{*显示设置 公共的 所有图表类型都一样*}
<tr>
    <td colspan="4" class="editrelhead">
        <b>{'SHOWINGRECORDS'|@getFixedLabel}{'Setup'|@getFixedLabel}</b>
    </td>
</tr>
<tr>
    <td align="right" class="DetailedTd1Label select-input tdwidth150">
        <input type="checkbox" class="second_switch" id="linkmodulecheck" name="linkmodulecheck"{if $chart_info['linkmodulecheck']==yes}checked{/if}>
    </td>
    <td align="left">
        <label>{'SETASLINKMODULE'|getFixedLabel}</label>
    </td>
</tr>
<tr>
    <td align="right" class="DetailedTd1Label select-input tdwidth150">
        <input type="checkbox" class="second_switch" id="show_athome" name="show_athome" {if $chart_info['show_athome']==yes}checked{/if}>
    </td>
    <td><label>{'showAtPcHome'|getFixedLabel}</label></td>
</tr>
{*
<tr id="show_athome_person_tr" {if $chart_info['show_athome']!='yes'}style="display:none;"{/if}>
    <td align="right" class="DetailedTd1Label select-input padL30">
        <input id="show_athome_person" class="second_switch" name="show_athome_person" type="checkbox" {if isset($chart_info['show_athome_info']['person'])&&$chart_info['show_athome_info']['person']=='yes'}checked{/if}>

    </td>
    <td>
        <label>{'showAtPcHomeOfScope'|getFixedLabel}</label>
    </td>
</tr>
<tr id="show_athome_timecheck_tr" {if $chart_info['show_athome']!='yes'}style="display:none;"{/if}>
    <td  align="right" class="DetailedTd1Label select-input padL30 tdwidth150">
        <input id="show_athome_timecheck" class="second_switch" name="show_athome_timecheck" type="checkbox" {if isset($chart_info['show_athome_info']['timecheck'])&&$chart_info['show_athome_info']['timecheck']=='yes'}checked{/if}>
    </td>
    <td>
        <label>{'showAtPcHomeOfTime'|getFixedLabel}</label>
        <select style="width:100px;" name="show_athome_time" id="show_athome_time" class="detailedViewTextBox">
        </select>
    </td>
</tr>
<tr id="show_athome_approve_tr" {if $chart_info['show_athome']!='yes'}style="display:none;"{/if}>
    <td align="right" class="DetailedTd1Label select-input padL30 tdwidth150">
        <input id="show_athome_approve" class="second_switch" name="show_athome_approve" type="checkbox" {if isset($chart_info['show_athome_info']['approve'])&&$chart_info['show_athome_info']['approve']=='yes'}checked{/if}>
    </td>
    <td>
        <label>{'showAtPcHomeOfApprove'|getFixedLabel}</label>
    </td>
</tr>*}
