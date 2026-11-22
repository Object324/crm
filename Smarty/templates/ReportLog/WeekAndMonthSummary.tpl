<!--修改编码格式:统一编码：UTF-8-->
<link href="themes/softed/writeDaily.css" rel="stylesheet" type="text/css" />

<div  class="weekMonthSummary">
    <form action="index.php" method="post" name="WeekAndMonthSummary">
        <input type="hidden" name="module" value="ReportLog"/>
        <input type="hidden" name="action" value="WeekAndMonthSummary"/>
        <input type="hidden" name="userid" value="{$USERIDS}"/>
        <input type="hidden" name="type" value="{$TYPE}"/>
        
    <div class="totalTitle">
        {'View_week_Monthly_Summary'|@getFixedLabel}
    </div>
    {if $TYPE eq 1}
    {assign var=week value=checked}
    {assign var=month value=''}
    {else}
    {assign var=week value=''}
    {assign var=month value=checked}
    {/if}
    <div class="Choose">
        <input id="week" style="margin:0px 5px 0px 0px;" type="radio" {$week} value="1" name="week" onclick="selectType(week,month)">
        {'WEEKREPORT'|@getFixedLabel}
        <input id="month" style="margin:0px 5px;" type="radio" value="2" name="month" {$month} onclick="selectType(month,week)">
        {'MONTHREPORT'|@getFixedLabel}
        <div class="Staff">
        <table class="RoleTab" width="100%" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td style="font-weight: bold;">{'Staff'|@getFixedLabel}{'SELECT'|@getFixedLabel}：</td>
            </tr>
            {foreach item=userinfo from=$USERINFO}  
                <tr> 
                    {if $userinfo.2 neq 0}
                        <td width="100%" class="borDot">        
                            {foreach item=user from=$userinfo.1}
                            <span>        
                            <input id="{$user.userid}" type="checkbox" value="{$user.userid}" name="owners[]" class="StepUserClass" groupname="{$user.rolename}">
                            <label style="font-weight: normal;" for="M1">{$user.username}</label>       
                            </span> 
                            {/foreach}
                        </td>
                    {else}
                        <td></td>
                    {/if}
                </tr>
            {/foreach}
            <tr>
                <td width="100%">
                    <a href="javascript:void(0)" style="color:#999999">>></a>
                    <div id="lz" style="display:none">
                        <span style="white-space:nowrap">
                        <input id="U5" type="checkbox" value="U5" name="owners[]">
                        </span>
                    </div>
                </td>
            </tr>
            <tr>
                <td style="font-weight: bold;">{'LBL_ROLES'|@getFixedLabel}：</td>
            </tr>
            <tr>
                <td width="100%" style="border-bottom: 1px dotted #C3C3C3;">
                {foreach item=roleinfo from=$ROLEINFO}
                    <input id="{$userinfo.0.profileid}" type="checkbox" value="" onclick="select_all(this,'{$roleinfo.profilename}');">
                    <label style="font-weight: normal;" for="group1">{$roleinfo.profilename}</label>      
                {/foreach}
                </td>
            </tr>
        </table>
        </div>
        <input class="editauto" type="button" value='{'VIEWSUMMARY'|@getFixedLabel}' onclick="chkSubmit();"/>
    </div>

    {if $TYPE eq 1}
    {assign var=week value=block}
    {assign var=month value=none}
    {else}
    {assign var=week value=none}
    {assign var=month value=block}
    {/if}
    <div id="WeekSummaryDetail" class="WeekSumDetail" style="display:{$week};">
    {include file="ReportLog/WeekSummaryDetail.tpl"}
    </div>
    
    <div id="MonthSummaryDetail" class="MonthSumDetail" style="display:{$month};">
    {include file="ReportLog/MonthSummaryDetail.tpl"}
    </div>

</form>
</div> 