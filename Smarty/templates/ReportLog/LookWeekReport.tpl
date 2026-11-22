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
       <input type="hidden" name="AHref" value="prev"/>
       <input type="hidden" name="SearchScope" value="{$SelectedOwner2}"/>
       <input type="hidden" name="Look" value="{$LOOK}"/>
       
       <!--看周报 头部-->
        <div class="WD_top">
        	<ul style="margin:0;padding:0;">
            	<li class="Name">{if $REPORTTYPE eq 'write'}{'WRITE_WEEKLY'|@getFixedLabel}{else}{'Look_Weekly'|@getFixedLabel}{/if}：</li>
                <li> {$USERNAME}&nbsp;&nbsp;{$WEEKRANGE}&nbsp;&nbsp;                                                   
                </li>
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
				&nbsp;&nbsp;<input id="mobile_menu_create createauto" class="deleteauto createauto marT2"  name="New" value="删除" type="button" onclick="delReportLog('week','{$REPORTLOGID}')">
			{/if}
			{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" href="javascript:;" style="margin-right: 15px;" onclick="getLinksUrl('ReportLog','ReportLog','lookReportLog');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
        </div>
        <!-- 中间内容 -->
        <div class="WD_Center">
        <table width="100%" border="0" cellspacing="0" cellpadding="0" class="WD_CenterBox">
          <tr>
            <td class="TdLeft" valign="top" width="306">
            	<div class="DivL">
                	<div class="Title"><span style="width:100%;"><a href="javascript:void(0)" onclick="WeekReportLogHref(document.getElementById('prev'),1)" id="prev" style="display:inline;">
                    <b>&lt;&lt;</b></a>({'VARWEEK'|@getVarFixedLabel:$PREVWEEKOFYEAR})  {'WEEKREPORT'|@getFixedLabel}
                    {if $NOWDATE neq $ENDDATE}
                        <a href="javascript:void(0)" onclick="WeekReportLogHref(document.getElementById('next'),1)" id="next" style="display:inline;">
                        <b>&gt;&gt;</b></a>
                    {/if}   </span>
                    </div>
                    <ul class="Ui0" style="margin:0px;padding:0px;">
                        <li class="B"><span>{$WRITEHTML}</span></li>                        
                        <li class="C">
                            {if $REPORTTYPE eq 'write'}
                            <a href="index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&reporttype=write&parenttab=My Home Page">{'WRITE_DAILY'|@getFixedLabel}</a>
                            <a href="index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&reporttype=write&parenttab=My Home Page" class="Org">{'WRITE_MONTLY'|@getFixedLabel}</a>
                            {else}
                            <a href="javascript:;" onclick="getReportLookUrl('Daily')">{'Daily_Look'|@getFixedLabel}</a>
                            <a href="javascript:;" onclick="getReportLookUrl('Month')" class="Org">{'Look_Monthly'|@getFixedLabel}</a>
                            {/if}
                        </li>
                    </ul>
                </div>
            </td>
            <td class="Tdcenter" valign="top">
            	<div class="DivC">                	
                    <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('WeekSummary','aid本周总结');">
                        <span id="aid本周总结">{'Week_Summary'|@getFixedLabel}</span>
                    </div>
                    <div class="DivCEdit" id="WeekSummary" style="display:block;">
                    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                          <tr>
                            <td class="EditBox">
                            	{$WORKSUMMARY}
                            </td>
                          </tr>
                        </table>
                    </div>
                    <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('WeekNext','aid下周计划');">
                        <span id="aid下周计划">{'Plan_next_week'|@getFixedLabel}</span>
                    </div>
                    <div class="DivCEdit" id="WeekNext" style="display:block;">
                    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                          <tr>
                            <td class="EditBox">
                            	{$NEXTWEEKPLAN}
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
            {include file="ReportLog/WeekReportList.tpl"}
        </div>
    </form>
    
    <script type="text/javascript">
       gbmode="ajax";
    </script>
     
</div>

