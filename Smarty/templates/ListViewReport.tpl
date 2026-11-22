<div class="ld-pop-container ld-table-container ld-table-container-lines">
    {if $style eq 'cols' }
        <table class="" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin-bottom:40px">
            <thead>
                <tr>
                    <th></th>
                    {foreach from=$listViewReportArr['lineName'] key=k item =v}
                        <th>{$v}</th>
                    {/foreach}
                    <th>{$listViewReportArr['total']}</th>
                    <th>{$listViewReportArr['ratios']}</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$listViewReportArr['fieldName'] key=k item=name}
                    <tr>
                        <td>{$name}</td>
                        {for $i=0 to $lineNameLength-1}
                            <td>
                                {$listViewReportArr["fieldValue$i"][$k]}
                            </td>
                        {/for}
                        <td>
                            {$listViewReportArr["lineCount"][$k]}
                        </td>
                        <td>{$listViewReportArr['proportion'][$k]}%</td>
                    </tr>
                {/foreach}
                <tr>
                    <td>{$listViewReportArr['total']}</td>
                    {for $i=0 to $lineNameLength-1}
                        <td>{$listViewReportArr["colCount"][$i]}</td>
                    {/for}
                    <td>{$listViewReportArr['allCount']}</td>
                    <td></td>
                </tr>
            </tbody>
        </table>
    {elseif $style eq 'line'}
        <table class="" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin-bottom:40px">
            <thead>
                <tr>
                    <th>{'Project'|@getFixedLabel}</th>
                    {foreach from=$listViewReportArr['fieldName'] item=v}
                        <th>{$v}</th>
                    {/foreach}
                    <th>{$listViewReportArr['total']}</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>{$QUNANTITYUNIT}</td>
                    {foreach from=$listViewReportArr['fieldValue'] item=v}
                        <td style="text-align: right">{$v}</td>
                    {/foreach}
                    <td style="text-align: right">{$listViewReportArr['allCount']}</td>
                </tr>
                <tr>
                    <td>{$listViewReportArr['ratios']}</td>
                    {foreach from=$listViewReportArr['proportion'] item=v}
                        <td style="text-align: right">{$v}%</td>
                    {/foreach}
                    <td></td>
                </tr>
            </tbody>
        </table>
    {else}
        {*wyt 221008 BUG0057239 客户-”销售负责人分布统计”，“收款金额TOP10”，中的图表没有居中显示，（其它图正常）*}
        <table class="" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin-bottom:40px">
            <thead>
                <tr>
                    <th>{'Project'|@getFixedLabel}</th>
                    <th>{$QUNANTITYUNIT}</th>
                    <th>{$listViewReportArr['ratios']}</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$listViewReportArr['fieldName'] key=k item=name}
                    <tr>
                        <td>{$name}</td>
                        <td>{$listViewReportArr['fieldValue2'][$k]}</td>
                        <td>{$listViewReportArr['proportion'][$k]}%</td>
                    </tr>
                {/foreach}
                <tr>
                    <td>{$listViewReportArr['total']}</td>
                    <td>{$listViewReportArr['allCount']}</td>
                    <td></td>
                </tr>
            </tbody>
        </table>
    {/if}
</div>

<div id="container_listview" style="width: 752px; height: 350px; margin: 10px auto"></div>