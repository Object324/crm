{*//表单推广 统计数据页面  ajax 请求页面*}
<table class="rptTable TableOften" width="100%"  cellspacing="0" cellpadding ='0'>
    <tr>
        {foreach key=index item=item from=$colTitle}
            <th width="20%">{$item}</th>
        {/foreach}
    </tr>

    {foreach key=index item=item from=$reportArr name=report}
        <tr id="report_{$smarty.foreach.report.iteration}" class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),'on')">
            {foreach key=key item=value from=$item}
                <td>{$value}</td>
            {/foreach}
        </tr>
    {/foreach}
</table>