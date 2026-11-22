<!--修改编码格式:统一编码：UTF-8-->
<script>
{literal}
function showHideStatus(sId,anchorImgId)
{
    oObj = eval(document.getElementById(sId));
	if(oObj.style.display == 'block')
	{
	   	oObj.style.display = 'none';
		if(anchorImgId !=null){
		      document.getElementById(anchorImgId).className = 'On '
		}
	}
	else
	{
	   	oObj.style.display = 'block';
		if(anchorImgId !=null){
			document.getElementById(anchorImgId).className = '';
		}
	}
}
{/literal}
</script>
<link href="themes/softed/writeDaily.css" rel="stylesheet" type="text/css" />
<div id="LookReportLog" class="yb">
<form action="index.php" method="post" name="ReportLogHref">
    {include file="ReportLog/ReportLogHidden.tpl"}                 
   <input type="hidden" name="SearchScope" value="{$SelectedOwner2}"/>
   <input type="hidden" name="Look" value="{$LOOK}"/>
   <!--看月报 头部-->
   <div class="WD_top">
	<ul style="margin:0;padding:0;">
    	<li class="Name" >{if $REPORTTYPE eq 'write'}{'WRITE_MONTLY'|@getFixedLabel}{else}{'Look_Monthly'|@getFixedLabel}{/if}：</li>
        <li>  {$USERNAME}  </li>
        <li>
            {if $REPORTLOGID eq -1}<font>{'Not_write'|@getFixedLabel}</font>
            {elseif $STATUS eq 0}<font>{'Temporary_unpaid'|@getFixedLabel}</font>
            {elseif $STATUS eq 1}<font>{'HAVETOPAY'|@getFixedLabel}</font>
            {/if}
        </li>
        <li>
        {include file='ReportLogOwner.tpl'}
        </li>
    </ul>
	{if $DELSTATUS eq 'yes'}
		&nbsp;&nbsp;<input id="mobile_menu_create" class="deleteauto createauto marT2"  name="New" value="删除" type="button" onclick="delReportLog('month','{$REPORTLOGID}')">
	{/if}
	{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" href="javascript:;" style="margin-right: 15px;" onclick="getLinksUrl('ReportLog','ReportLog','lookReportLog');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
   </div>
     <!-- 中间内容 -->
    <div class="WD_Center">
    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="WD_CenterBox">
      <tr>
        <td class="TdLeft" valign="top" width="306">
        	<div class="DivL">
            	<div class="Title"><span style="width:100%;">
                    {if $STARTDATE neq "2000-01-01"}
                    <a  id="prev" href="javascript:ReportLogHref(document.getElementById('prev'),2)" style="display:inline;border-bottom:none;">
                    &lt;&lt;</a>
                    {/if}
                    <select onchange="YearChange(this)" name="yearOpt" id="yearOpt" style="font-size:16px;">
                       {foreach key=k item=content from=$YEAROPTIONS}
                        {if $k eq $YEARBOL}
                            <option value="{$k}" selected="true">{$content}</option>
                        {else}
                            <option value="{$k}">{$content}</option>
                        {/if}
                        
                        {/foreach}
                    </select>
                    <select onchange="MonthChange(this)" id="monthOpt" name="monthOpt" style="font-size:16px;" >
                       {foreach key=k item=content from=$MONTHOPTIONS}
                        {if $k eq $MONTHOFYEAR}
                            <option value="{$k}" selected="true">{$content}</option>
                        {else}
                            <option value="{$k}">{$content}</option>
                        {/if}
                        
                        {/foreach}
                    </select>
                    {if $NOWDATE neq $YEARMONTH}
                    <a href="javascript:ReportLogHref(document.getElementById('next'),2)" id="next" style="display:inline;border-bottom:none;">
                     &gt;&gt;</a>
                     {/if}
                </span></div>
                <ul class="Ui0" style="margin:0px;padding:0px;">
                    <li class="B"><span>{$WRITEHTML}</span></li>                       
                    <li class="C">
                        {if $REPORTTYPE eq 'write'}
                        <a href="index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&reporttype=write&parenttab=My Home Page">{'WRITE_DAILY'|@getFixedLabel}</a>
                        <a href="index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&reporttype=write&parenttab=My Home Page" class="Org">{'WRITE_WEEKLY'|@getFixedLabel}</a>
                        {else}
                        <a href="javascript:;" onclick="getReportLookUrl('Daily')">{'Daily_Look'|@getFixedLabel}</a>
                        <a href="javascript:;" onclick="getReportLookUrl('Week')" class="Org">{'Look_Weekly'|@getFixedLabel}</a>
                        {/if}
                    </li>
                </ul>
            </div>
        </td>
        <td class="Tdcenter" valign="top">
        	<div class="DivC">                	
                <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('MonthSummary','aid本月总结');">
                    <span id="aid本月总结">{'This_month_summary'|@getFixedLabel}</span>
                </div>
                <div class="DivCEdit" id="MonthSummary" style="display:block;">
                	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                      <tr>
                        <td class="EditBox">
                        	{$WORKSUMMARY}
                        </td>
                      </tr>
                    </table>
                </div>
                <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('MonthNext','aid下月计划');">
                    <span id="aid下月计划">{'Plan_next_month'|@getFixedLabel}</span>
                </div>
                <div class="DivCEdit" id="MonthNext" style="display:block;">
                	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                      <tr>
                        <td class="EditBox">
                        	{$NEXTMONTHPLAN}
                        </td>
                      </tr>
                    </table>
                </div>
                <div style="clear:both;">
                 {include file="ReportLog/ModComment.tpl"} 
                </div>
            </div>                
        </td>
      </tr>
    </table>        
    </div>                
</form>
<form action="index.php" method="post"  name="ReportLog">
    <div style="clear:both;padding:10px 5px 10px;">
    {include file="ReportLog/ReportLogHidden.tpl"}
    {include file="ReportLog/MonthReportList.tpl"}
    </div>
</form>
<script type="text/javascript">
   gbmode="ajax";
</script>
</div>

