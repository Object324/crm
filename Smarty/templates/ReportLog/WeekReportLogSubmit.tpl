<!--修改编码格式:统一编码：UTF-8-->
<table class="ReportLogTab" cellspacing="0" cellpadding="0" width="170%">
    <thead>
        <tr>
            <th bgcolor="#F5F3EF" rowspan="2" width="3%">{'Name'|@getFixedLabel}</th>
            {foreach item=data from=$MONTHHEAD}
            <th colspan="{$data.week}">{$data.month}</th>
            {/foreach}
        </tr>
        <tr>   
        {foreach item=data from=$WEEKHEAD}
            <th>{'VARWEEK'|@getVarFixedLabel:$data.week}</th>
        {/foreach}
        </tr>            
    </thead>
    <tbody>       
        {foreach item=userinfo from=$WEEKCONTENT}    
        <tr>
        <td><span title="{$userinfo.0}">{$userinfo.0}</span></td>
        {foreach item=data from=$userinfo.1}        
        <td class="t-c" align="center">{$data}</td>       
        {/foreach}
        </tr>   
    {/foreach}
    </tbody>
</table>