<!--修改编码格式:统一编码：UTF-8-->
{*
edit:cdw
date:20130823
reason:0004829: "写日报、看日报"界面"当日参考数据"的工具栏上需要增加“三角形”图标按钮，默认不展开，点击后可以展开“当日参考数据”，
*}
<script>
{literal}
function showHideStatus(sId,anchorImgId)
{
    oObj = eval(document.getElementById(sId));
	if(oObj.style.display == 'block')
	{
	   	oObj.style.display = 'none';
		if(anchorImgId !=null){
		      document.getElementById(anchorImgId).className = 'On Name'
		}
	}
	else
	{
	   	oObj.style.display = 'block';
		if(anchorImgId !=null){
			document.getElementById(anchorImgId).className = 'Name';
		}
	}
}
function updatedayLog(modetype){
	var startdate = getId('jscal_field_date').value;
	var searchOwner = ld('#searchOwner').val();
	location.href = 'index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&modetype='+modetype+'&mode=look&look=look&StartDate='+startdate+'&SearchScope='+searchOwner;
}
{/literal}
</script>
<link href="themes/softed/writeDaily.css" rel="stylesheet" type="text/css" />
<div id="LookReportLog"  class="yb">
<form action="index.php" method="post" name="ReportLogHref">
{include file="ReportLog/ReportLogHidden.tpl"}
<input type="hidden" name="SearchScope"/>    
<input type="hidden" name="Look" value="{$LOOK}"/>
<!--看日报 头部-->

<div class="WD_top">
	<ul>
    	<li class="Name">{if $REPORTTYPE eq 'write'}{'WRITE_DAILY'|@getFixedLabel}{else}{'Daily_Look'|@getFixedLabel}{/if}：</li>
        <li> 
            {$USERNAME}&nbsp;&nbsp;
            <a href="javascript:updatedayLog('suchday')"><b >&lt;&lt;</b></a>
            &nbsp;&nbsp;{$STARTDATE}&nbsp;&nbsp;
            {if $NOWDATE > $SDATE}
            <a href="javascript:updatedayLog('tsuchday')"><b >&gt;&gt;</b></a>
            {/if} 
            <input type="hidden" name="date_only" id="jscal_field_date"  size="15" maxlength="10" value="{$STARTDATE}" onchange="ChangeDateContorl(this,0);" onClick="WdatePicker()" class="Wdate"/>
            <!--<img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_date" style="vertical-align:middle;"/>
             <script type="text/javascript" id='massedit_calendar_date'>
				Calendar.setup ({ldelim}
					inputField : "jscal_field_date", ifFormat : "%Y-%m-%d", showsTime : false, button : "jscal_trigger_date", singleClick : true, step : 1
				{rdelim})
			</script>-->
            &nbsp;&nbsp;({$WEEK})&nbsp;&nbsp;{'DAILYREPORT'|@getFixedLabel}
        </li>
        <li><font>[{$DAILYREPORTSTATU}]</font></li>
    </ul>
    <div>
    {include file='ReportLogOwner.tpl'}
    </div>
	{if $DELSTATUS eq 'yes'}
		&nbsp;&nbsp;<input id="mobile_menu_create" class="deleteauto createauto marT2"  name="New" value="删除" type="button" onclick="delReportLog('daily','{$REPORTLOGID}')">
	{/if}
	{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" href="javascript:;" style="margin-right: 15px;" onclick="getLinksUrl('ReportLog','ReportLog','lookReportLog');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
</div>
<!--看日报 内容-->
<div class="WD_Center">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="WD_CenterBox">
  <tr>
    <td class="TdLeft" valign="top" width="306">
    	<div class="DivL">
        	<div class="Title"><span>{'PAST_FIVE_DAYS'|@getFixedLabel}{'RECORDS'|@getFixedLabel}</span></div>
            <ul class="Ui0" style="margin:0px;padding:0px;">
            	<li class="A" style="padding-bottom:0px;padding-top:0px;">
                	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                      <tr>
                        {foreach item=data from=$DAILY}
                            {if $data.dailystatu == '看' || $data.dailystatu == 'look'}
                                <td class="BjOrg">
                            {else}
                                <td>
                            {/if}
                            <a style="text-decoration:none;" onclick="changedate('{$data.longdaily}','{$REPORTTYPE}')" href="javascript:;">
                                {$data.shortdaily}<br /><font>{$data.shortweek}</font></a></td>                        
                        {/foreach}                        
                      </tr>
                    </table>
                </li>
                <li class="B"><span><a class="text" href="index.php?module=ReportLog&action=AllUsersDailySummary&date={$STARTDATE}">{'QUICKVIEW'|@getFixedLabel}</a> </span></li>
                <li class="C">
                    {if $REPORTTYPE eq 'write'}
                    <a href="index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&reporttype=write">{'WRITE_WEEKLY'|@getFixedLabel}</a>
                    <a href="index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&reporttype=write" class="Org">{'WRITE_MONTLY'|@getFixedLabel}</a>
                    {else}
                    <a href="javascript:;" onclick="getReportLookUrl('Week')">{'Look_Weekly'|@getFixedLabel}</a>
                    <a href="javascript:;" onclick="getReportLookUrl('Month')" class="Org">{'Look_Monthly'|@getFixedLabel}</a>
                    {/if}
                </li>
            </ul>
        </div>
    </td>
    <!--右边内容 begin-->
    <td class="Tdcenter" valign="top">
    	<div class="DivC">
        	<div class="DivCName DivCNamehover" onclick="showHideStatus('CurWeekPlan','aid当日数据参考');">
            <span class="On" id="aid当日数据参考">{'REFERENCE_DATA'|@getFixedLabel}<font>（{'EDITORISREFERENCE'|@getFixedLabel}）</font></span></div>
            <div class="DivCNotice" id="CurWeekPlan" style="display:none;">
            	{include file="ReportLog/DailyReferenceData.tpl"}
            </div>
            <!--查看今日计划-->
            <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('TodayPlan','aid今日计划');">
            <span id="aid今日计划">{'VIEWTODAYPROGRAMWRITESUMMARY'|@getFixedLabel}</span></div>
            <div class="DivCEdit" id="TodayPlan" style="display:block;">
            	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="word-break: break-all;word-wrap: break-word;table-layout: fixed;">
                  <tr>
                    <td class="EditBox">                  	 
                     <div>{$DAILYCONTENT.worksummary}</div>
                    </td>                                       
                  </tr>
                </table>
            </div>
            <!--撰写明日计划-->
            <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('TomorrowPlan','aid明日计划');"><span id="aid明日计划">{'WRITE_TOMORROW_PLAN'|@getFixedLabel}</span></div>
            <div class="DivCEdit" id="TomorrowPlan" >
            	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="word-break: break-all;word-wrap: break-word;table-layout: fixed;">                  
                  <tr>
                    <td class="EditBox">
                   	<div> {$DAILYCONTENT.tomorrowplan} </div>
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
</div>