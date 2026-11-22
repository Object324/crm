<!--修改编码格式:统一编码：UTF-8-->
<table class="ReportLogTab" cellspacing="0" cellpadding="0" width="100%">
    <thead>
        <tr>
            <th bgcolor="#F5F3EF" rowspan="2" width="5%">{'Name'|@getFixedLabel}</th>
            {foreach item=data from=$DAILYHEAD.day}
            <th>{$data}</th>
            {/foreach}
        </tr>
        <tr>   
        {foreach item=data from=$DAILYHEAD.week}            
             <th>{$data|@getFixedLabel}</th>
            {/foreach}
        </tr>            
    </thead>
    <tbody> 
    {foreach item=userinfo from=$DAILYCONTENT}    
        <tr>
        <td><span title="{$userinfo.0}">{$userinfo.0}</span></td>
        {foreach item=data from=$userinfo.1}        
        <td align="center" class="t-c">{$data}</td>       
        {/foreach}
        </tr>   
    {/foreach}
    </tbody>
</table>