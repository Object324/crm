<div class="grid-analysis-header">
</div>
<div class="cont_wrap clear_float">
    <table class="settingTable" width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
        <tr>
            <th colspan="3">
                {'Dealer_channel'|@getFixedLabel}{'prm_web_customization'|@getFixedLabel}
            </th>
        </tr>
        <tr class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            <td width="20%">{'Dealer_channel'|@getFixedLabel}{'home_settings'|@getFixedLabel}</td>
            <td width="60%">{$boardAllStuffNameStr}</td>
            <td width="20%"><a class="Anu3_a" href="javascript:void(0)" onclick="editHomeboard({$boardid},'prmHome')">{'home_settings'|@getFixedLabel}</a></td>
        </tr>
        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            <td>{'Dealer_channel'|@getFixedLabel}{'menu_settings'|@getFixedLabel}</td>
            <td>{$childtabs_str}</td>
            <td><a class="Anu3_a" href="javascript:void(0)" onclick="prmsettings.prmMenuSettings();">{'menu_settings'|@getFixedLabel}</a></td>
        </tr>
        <tr class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            <td>{'Dealer_channel'|@getFixedLabel}{'logo_settings'|@getFixedLabel}</td>
            <td>
                <img id="prm_LOGO_name" name="LOGO_name" src="dataCache/test/logo/{$prmlogoname}" class="Logo" tag="prm-logo-pic" style="width: 130px;height: 36px;">
            </td>
            <td><a class="Anu3_a" href="javascript:void(0)" onclick="prmsettings.logosettings();">{'logo_settings'|@getFixedLabel}</a></td>
        </tr>
        </tbody>
    </table>
</div>