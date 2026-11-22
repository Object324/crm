<div class="gwidth100">
    <div class="pad8 font13">{'ISREPLACEHISTORYDATA'|@getFixedLabel}</div>
    <table class="D_pop_bod font13" cellspacing="1" cellpadding="0" border="0" style="margin: 0px auto;table-layout: fixed;">
        <tr>
            <td class="editrelhead font13 gwidth40" align="center">{'LBL_Earlier'|@getFixedLabel}</td>
            <td class="editrelhead font13 gwidth40" align="center">{'LBL_Present'|@getFixedLabel}</td>
            <td class="editrelhead font13" align="center"><input name='chkall' type="checkbox" checked="true"/></td>
        </tr>
        {foreach from=$CHANGEDCOMBOXS item=info}
            <tr>
                <td align="center" class="overflow-space" title="{$info.oldval}">{$info.oldval}</td>
                <td align="center" class="overflow-space" title="{$info.value}">{$info.value}</td>
                <td align="center"><input oldvalue="{$info.oldval}" newvalue="{$info.value}" type="checkbox" checked="" name="chk_operate"/></td>
            </tr>
        {/foreach}
    </table>
</div>