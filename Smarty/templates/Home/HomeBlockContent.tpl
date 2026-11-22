{if is_array($HOME_STUFF.Details.Entries) && $HOME_STUFF.Details.Entries|@count > 0}
    {assign var="i" value=0}

    {assign var="m" value=0}
    {foreach item=row key=crmid from=$HOME_STUFF.Details.Entries name=entitylist}
        {if $m mod 2 eq '0'}
            <tr class="lvtColData" onmouseover="listOnMouseOver(ld(this),'On')"  onmouseout="listOnMouseOut(ld(this))" record="{$crmid}">
                {else}
            <tr class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),'On')" record="{$crmid}">
        {/if}
        {*BUG20240516-05 zxm 20240521 查看范围切换到不同角色时，小组及个人本月销售数据的位置会发生变化 可以拿通用账套的 MIA、销售总监和系统管理员对比*}
        {if is_array($row)}
            {assign var="width" value=100/($row|@count)}
            {foreach item=element from=$row}
                <td align="left" style="width:{$width}%">{$element}</td>
            {/foreach}
        {/if}
        </tr>
        {$m=$m+1}
    {/foreach}
{/if}