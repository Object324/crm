<!--修改编码格式:统一编码：UTF-8-->
{literal}
<style>
html{overflow-x:scroll !important;}
body{width:1600px!important; overflow-x:visible !important;}
</style>
<link href="themes/softed/writeDaily.css" rel="stylesheet" type="text/css" />
{/literal}
<div class="ReportViewState">
    <div class="Topinfo">
    <div>
        <a href="index.php?pageto_module=ReportLog&pageto_action={$ACTIONLINK.1.action}">{$ACTIONLINK.1.item|@getFixedLabel}</a>　
        <a href="index.php?pageto_module=ReportLog&pageto_action={$ACTIONLINK.2.action}">{$ACTIONLINK.2.item|@getFixedLabel}</a>
    </div>
    {if $REPORTLOGTYPE eq 0}
    {assign var=name value='DAILYREPORT'}
    {assign var=ym value='MONTH'}
    {assign var=date value='Day'}
    {elseif $REPORTLOGTYPE eq 1}
    {assign var=name value='WEEKREPORT'}
    {assign var=ym value='YEAR'}
    {assign var=date value='Week'}
    {elseif $REPORTLOGTYPE eq 2}
    {assign var=name value='MONTHREPORT'}
    {assign var=ym value='YEAR'}
    {assign var=date value='MONTH'}
    {/if}
    <div class="Note">
        <b>{$name|@getFixedLabel}·{$NOWMONTH}{$ym|@getFixedLabel}{'STATUS'|@getFixedLabel}  </b>
        &nbsp;<a href="javascript:void(0);" onclick="viewReportLogSubmit('{$ACTIONLINK.0.action}','&date={$LAST.last}')">
        <b>&lt;&lt;</b>
        {$LAST.lastname|@getFixedLabel}
        </a>　
        {if $NEXT neq ''}
        &nbsp;<a href="javascript:void(0);" onclick="viewReportLogSubmit('{$ACTIONLINK.0.action}','&date={$NEXT.next}')"> 
        {$NEXT.nextname|@getFixedLabel}   
        <b>&gt;&gt;</b>
        </a>
        {/if}
    
    
        <font color="#808080">{'Status_Description'|@getFixedLabel}</font>&nbsp;&nbsp;{'Blank'|@getFixedLabel}：&nbsp;{'Not_write'|@getFixedLabel}{$name|@getFixedLabel}；&nbsp;&nbsp;+n：&nbsp;{'n_days_turned'|@getFixedLabel}{$name|@getFixedLabel}；  &nbsp;&nbsp;    
        <font color="#44cc00">
        <b>√</b>
        </font>
        ：&nbsp;{'When'|@getFixedLabel} {$date|@getFixedLabel} {'Pay'|@getFixedLabel} {$name|@getFixedLabel}
    </div>
</div>
<div class="TabDiv">
{if $REPORTLOGTYPE eq 0}
    {include file='ReportLog/DailyReportLogSubmit.tpl'}
    {elseif $REPORTLOGTYPE eq 1}
    {include file='ReportLog/WeekReportLogSubmit.tpl'}
    {elseif $REPORTLOGTYPE eq 2}
    {include file='ReportLog/MonthReportLogSubmit.tpl'}
    {/if}
    
</div>
<p align="center">　-end-</p>
</div>
