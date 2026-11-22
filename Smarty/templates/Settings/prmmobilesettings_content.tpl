<div class="grid-analysis-header">
    <input type="hidden" id="setting_position" value="">
</div>
<div class="cont_wrap clear_float">
    <table class="settingTable" width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
        <tr>
            <th colspan="3">
                {'Dealer_channel'|@getFixedLabel}{'prm_mobile_customization'|@getFixedLabel}
            </th>
        </tr>
        <tr class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            <td width="20%">{'Dealer_channel'|@getFixedLabel}{'home_settings'|@getFixedLabel}</td>
            <td width="60%">{$boardAllStuffNameStr}</td>
            <td width="20%"><a class="Anu3_a" href="javascript:void(0)" onclick="editHomeboard({$boardid},'prmMobileHome')">{'home_settings'|@getFixedLabel}</a></td>
        </tr>
        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            <td>{'Dealer_channel'|@getFixedLabel}{'function_menu_customization'|@getFixedLabel}</td>
            <td id="prm_module_name_str">{$module_name_str}</td>
            <td><a class="Anu3_a" href="javascript:void(0)" btn="editBtn" record="{$moduleblockid}" onclick="fun_mobile_list.getInstance('{$moduleblockid}').MobileBlock_edit()">{'menu_settings'|@getFixedLabel}</a></td>
        </tr>
        <tr class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            <td>{'Dealer_channel'|@getFixedLabel}{'report_menu_customization1'|@getFixedLabel}</td>
            <td id="prm_report_name_str">
                {$report_name_str}
            </td>
            <td><a class="Anu3_a" href="javascript:void(0)" btn="editBtn" record="{$reportblockid}" onclick="fun_mobile_list.getInstance('{$reportblockid}').MobileReportBlockEdit()">{'menu_settings'|@getFixedLabel}</a></td>
        </tr>
        </tbody>
    </table>
</div>