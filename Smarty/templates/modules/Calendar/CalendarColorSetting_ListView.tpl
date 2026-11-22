<table class="settingTable fir-center SensitiveTable" cellspacing="0" cellpadding="0" border="0" width="100%">
    <tr>
        <th>#</th>
        <th style="min-width: 100px" title="{'RULENAME'|@getFixedLabel}">{'RULENAME'|@getFixedLabel}</th>
        <th title="{'Priority'|@getFixedLabel}">{'Priority'|@getFixedLabel}</th>
        <th title="{'Backgroundcolor'|@getFixedLabel}">{'Backgroundcolor'|@getFixedLabel}</th>
        <th title="{'FontColor'|@getFixedLabel}">{'FontColor'|@getFixedLabel}</th>
        <th title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
        <th style="width: 120px" title="{'Operation2'|@getFixedLabel}">{'Operation2'|@getFixedLabel}</th>
    </tr>
    {foreach key=key item=item from=$rulesInfoarr}
        {if $key mod 2 eq '0'}
            <tr id="setting_{$item.id}" class="lvtColData ld-calendar-colorsetting" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" ruleid="{$item.id}">
        {else}
            <tr id="setting_{$item.id}" class="lvtColDataBj ld-calendar-colorsetting" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" ruleid="{$item.id}">
        {/if}
            <td>{$key+1}</td>
            <td>{$item.name}</td>
            <td>{$item.sequence}</td>
            <td>
                <div name="backgroundcolor" class="calendar-color-setting" style="background: {$item.backgroundcolor};"
                     color="{$item.backgroundcolor}" onclick="CalendarColorSettings.getInstance().changeColor(this,{$item.id},'backgroundcolor');"></div>
            </td>
            <td>
                <div name="textcolor" class="calendar-color-setting" style="background: {$item.textcolor};"
                     color="{$item.textcolor}" onclick="CalendarColorSettings.getInstance().changeColor(this,{$item.id},'textcolor')"></div>
            </td>
            <td><input class="second_switch"  type="checkbox" name="ruleStatus" {if $item.status eq 'yes'}checked{/if} onclick="CalendarColorSettings.getInstance().changeStatus(this,{$item.id})"></td>
            <td>
                <a class="Anu3_a" href="javascript:void(0);" onclick="CalendarColorSettings.getInstance().edit({$item.id})" ruleid="{$item.id}" tag="edit"><i class="ld-fonticon ld-fonticon-edit"></i></a>
                <a class="Anu3_a redFont" href="javascript:void(0);" onclick="CalendarColorSettings.getInstance().delete({$item.id})" ruleid="{$item.id}" tag="delete"><i class="ld-fonticon ld-fonticon-del"></i></a>
                <a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}" data-direction="right" data-type="position" style="cursor: move; margin-right: 18px; display: none;" tag="dragsort"></a>
            </td>
        </tr>
    {/foreach}
</table>