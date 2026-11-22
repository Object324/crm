<table border=0 cellspacing=0 cellpadding="0" width="100%" class="">
    <thead>
        <tr>
            <th>{'operatoroer'|@getFixedLabel}</th>
            <th>{'operatoroertime'|@getFixedLabel}</th>
            <th width="100">{'OperationTotalNumber'|@getFixedLabel}</th>
        </tr>
    </thead>
    <tbody>
        {if $LOGS neq ''}
            {foreach key=operator item=operation_logs from=$LOGS}
                {foreach key=index item=log from=$operation_logs}
                    {if $index eq 0}
                        <tr>
                            <td>{$log.username}</td>
                            <td>{$log.operating_time}</td>
                            <td><a href="javascript:void(0);"><span style="margin-right: 10px;" onclick="toggleLogShowHide({$log.operator})">{$log.times}</span></a></td>
                        </tr>
                    {else}
                        <tr name="fileoperationlog_{$operator}" style="display: none;">
                            <td></td>
                            <td>{$log.operating_time}</td>
                            <td></td>
                        </tr>
                    {/if}
                {/foreach}
            {/foreach}
        {else}
            <tr>
                <td colspan='3' style="ctextalign">{'NONE'|@getFixedLabel}</td>
            </tr>
        {/if}
    </tbody>
</table>