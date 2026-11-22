<div class="searchbatchtext">
    <table class="listEntries" width="100%" cellpadding="0" cellspacing="1" border="0">
        <tr>
            <th>批号</th>
            <th>数量</th>
            <th>仓库</th>
        </tr>

        {if !empty($TMPARR)}
        {foreach from=$TMPARR item=item}
            <tr>
                <td>{if $item.sf3080 eq ''}
                        <a href="javascript:;" onclick="fun_selectproduct.prototype.setbatchtextYitan('','{$item.quantity}','{$item.wareid}','{$item.warehousename}')">--</a>
                    {else}
                        <a href="javascript:;" onclick="fun_selectproduct.prototype.setbatchtextYitan('{$item.sf3080}','{$item.quantity}','{$item.wareid}','{$item.warehousename}')">{$item.sf3080}</a>
                    {/if}

                </td>
                <td>{$item.quantity}</td>
                <td>{$item.warehousename}</td>
            </tr>
        {/foreach}
        {else}
            <tr height="120px" valign="center">
                <td align="center" colspan="3">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
            </tr>
        {/if}
		

		
    </table>
</div>