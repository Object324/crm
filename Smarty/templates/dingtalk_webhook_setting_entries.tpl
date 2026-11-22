<table class="settingTable fir-center" id="dingtalklisttable" border=0 cellspacing=0 cellpadding=0 width="100%">
    <tr>
        <th>#</th>
        <th align="left" width="120" title="{'suoshumodule'|@getFixedLabel}">{'suoshumodule'|@getFixedLabel}</th>
        <th align="left" width="170" title="">{'dingtalk_keywords'|@getFixedLabel}</th>
        <th align="left" title="">{'ACONTENTTEMPLATE'|@getFixedLabel}</th>
        <th align="left" width="70" title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
        {if $LANGUAGETYPE eq 'en'}
            <th width="240">{'OPERATING'|@getFixedLabel}</th>
        {else}
            <th width="190">{'OPERATING'|@getFixedLabel}</th>
        {/if}
    </tr>
    {if $DINGTALK|@count gte 1}
        {assign var="i" value=0}
        {foreach key=value item=dingtalk from=$DINGTALK}
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
                <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
            <td>{$value+1}</td>
            <td align="left">{$dingtalk.modulename}</td>
            <td align="left">{$dingtalk.keywords}</td>
            <td><pre style="background-color: rgba(0,0,0,0);border:none;">{$dingtalk.content}</pre></td>
            <td align="left">
                <input type="checkbox" class="second_switch" {if $dingtalk.is_enable eq 'yes'}checked{/if} onclick="dingtalk_webhook_setting_by_type('{$dingtalk.id}',this.checked,'enable')" />
            </td>

            <td align="left">
                <a class="Anu3_a" href="javascript:void(0);" onclick="dingtalk_webhook_setting_create_or_edit('{$dingtalk.id}','{$dingtalk.tabid}','edit');">{'EDIT'|@getFixedLabel}</a>
                <a class="Anu3_a" href="javascript:void(0);" onclick="dingtalk_webhook_setting_create_or_edit('{$dingtalk.id}','','copy');">{'COPY'|@getFixedLabel}</a>
                <a class="Anu3_a redFont" href="javascript:void(0);" onclick="dingtalk_webhook_setting_by_type('{$dingtalk.id}','','delete')">{'DELETE'|@getFixedLabel}</a>
            </td>
        </tr>
        {/foreach}
    {else}
        <tr class="lvtColData">
            <td colspan="6" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
        </tr>
    {/if}
</table>