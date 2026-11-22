<!--列表信息-->
<table border=0 cellspacing=0 cellpadding=0 width=100% class="settingPopTable lasttdbordernon" name="SourceListTable">
    <tr style="position: sticky;top: 0;background-color: #fff;z-index: 10;">
        <td style="width: 3%;">#</td>
        <td align="center" style="width: 15%;" title="{$LIST_HEADER.0}" class="tdLinefeed">{$LIST_HEADER.0}</td>
        <td align="center" style="width: 15%;" title="{$LIST_HEADER.1}" class="tdLinefeed">{$LIST_HEADER.1}</td>
        <td align="center" style="width: 15%;" title="{$LIST_HEADER.2}" class="tdLinefeed">{$LIST_HEADER.2}</td>
        <td align="center" style="width: 20%;" title="{$LIST_HEADER.3}" class="tdLinefeed">{$LIST_HEADER.3}</td>
        <td align="center" style="width: 15%;" title="{$LIST_HEADER.4}" class="tdLinefeed">{$LIST_HEADER.4}</td>
        <td align="center" style="width: 10%;">{'OPERATING'|@getFixedLabel}</td>
        <td style="width: 6%;"></td>
    </tr>
    {assign var="i" value=0}
   
	{foreach name=optionlist key=k item=optionvalues from=$LIST_ENTRIES}
        {assign var="j" value=$i++}
        <tr class="ld-category-draggable" selectmodule="{$optionvalues.module}">
            <td>{$i}</td>
            <td align="center">
                <span title="{$optionvalues.modulelabel}">{$optionvalues.modulelabel}</span>
            </td>
            <!-- BUG0067244  yujun 2023-6-1 -->
            <td align="center">
                <input name="{$MODULE}_{$optionvalues.module}_presence" type="checkbox" class="second_switch" {if $optionvalues.presence eq 0}checked{/if}  onchange="enable_deflaut_checkbox('presence',this,'{$MODULE}','{$optionvalues.module}')">
            </td>
            <td align="center" class="td_second">
                <input id="checkbox_first" name="{$MODULE}_{$optionvalues.module}_default" type="checkbox" {if $optionvalues.default eq '0'} {else}checked{/if} tag="is_default" class="second_switch" onchange="enable_deflaut_checkbox('default',this,'{$MODULE}','{$optionvalues.module}')">
            </td>
            <td align="center">
                {if $optionvalues.datarang eq 'all'}
                    <span title="{'ALL'|@getFixedLabel}">{'ALL'|@getFixedLabel}</span>
                {else}
                    <span title="{'ALLOWINQUIRE'|@getFixedLabel}">{'ALLOWINQUIRE'|@getFixedLabel}</span>
                {/if}
            </td>
            <td align="center">
                {if $optionvalues.approve_demand eq '0' || $optionvalues.approve_status eq '-1'}
                    <span title="{'NONE'|@getFixedLabel}">{'NONE'|@getFixedLabel}</span>
                {else}
                    <span title="{'Approved'|@getFixedLabel}">{'Approved'|@getFixedLabel}</span>
                {/if}
            </td>
            <td align="center">
                <a class="Anu3_a" onclick="editSourceSetting('{$MODULE}','{$value.fieldid}','{$optionvalues.module}')">{'EDIT'|@getFixedLabel}</a>
            </td>
            <td>
                <a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}" data-direction="left" data-type="position" style="display:none;cursor:move;"></a>
            </td>
        </tr>
    {/foreach}
</table>