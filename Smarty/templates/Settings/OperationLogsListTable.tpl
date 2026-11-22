<table class="ld-operationlog-list-table settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
    {if $DataLength gte 1}
        {assign var="i" value=0}
        {foreach key=index item=arr from=$ListData}
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
                <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
                {* 导入导出日志 , 通话记录日志 *}
                {if $LogType eq 'ImportExport' || $LogType eq 'CallRecord'}
                    {assign var="m" value=0}
                    {foreach key=key item=item from=$arr}
                        {assign var="n" value=$m++}
                            <td value="{$key}" style="{$HeaderWidth[$n]}">{$item}</td>
                    {/foreach}
                {else}
                    <td style="{$HeaderWidth[0]}">{$arr.user}</td>
                    <td style="{$HeaderWidth[1]}">{$arr.operationtime}</td>
                    <td style="{$HeaderWidth[2]}">{$arr.action|@getFixedLabel}</td>
                    <td style="{$HeaderWidth[3]}">{$arr.module|@getTranstab}</td>
                    <td style="{$HeaderWidth[4]}">{$arr.record}</td>
                    <td style="{$HeaderWidth[5]}">{$arr.operationdetails}</td>
                {/if}
            </tr>
        {/foreach}
    {else}
        <tr class="lvtColData">
            <td colspan="8" align="center" style="height: 0px;">
                {* {'NOTFOUNDANYRECORD'|@getFixedLabel} *}
                {if $DataLength eq 0}
                    {include file="NoRecords.tpl"}
                {else}
                    {include file="NoRecords.tpl" NoRecords_CONTENT={'PleaseSelectConsClickQuery'|@getFixedLabel}}
                {/if}
            </td>
        </tr>
    {/if}
</table>