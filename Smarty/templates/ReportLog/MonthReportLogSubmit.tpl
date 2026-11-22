<!--修改编码格式:统一编码：UTF-8-->
<table class="ReportLogTab" cellspacing="0" cellpadding="0" width="100%">
    <thead>
        <tr>
            <th bgcolor="#F5F3EF" width="5%">{'Name'|@getFixedLabel}</th>
            {foreach item=data from=$MONTHHEAD}
            <th>{$data}</th>
            {/foreach}
        </tr>         
    </thead>
    <tbody>
    {foreach item=userinfo from=$MONTHCONTENT}    
        <tr>
        <td><span title="{$userinfo.0}">{$userinfo.0}</span></td>
        {foreach item=data from=$userinfo.1}        
        <td class="t-c" align="center">{$data}</td>       
        {/foreach}
        </tr>   
    {/foreach}
    </tbody>
</table>