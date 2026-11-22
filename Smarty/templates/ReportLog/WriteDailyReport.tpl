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
{/literal}
</script>

{*
edit:andrew
修正写日报后，看日报【已提交】显示为写日报【已提交】
*}
   
<link href="themes/softed/writeDaily.css" rel="stylesheet" type="text/css" />
<div id="LookReportLog"  class="yb">
    <form action="index.php" method="post" name="ReportLog" class="ajax_form">
    {include file="ReportLog/ReportLogHidden.tpl"}
<!--写日报 头部-->

<div class="WD_top">
	<ul style="margin:0;padding:0;">
    	<li class="Name">{if $REPORTTYPE eq 'write'}{'WRITE_DAILY'|@getFixedLabel}{else}{'Daily_Look'|@getFixedLabel}{/if}：</li>
        <li>
			{$USERNAME}  
			<a href="javascript:updatedayLog('suchday');"><b >&lt;&lt;</b></a>
			&nbsp;&nbsp;{$STARTDATE}&nbsp;&nbsp;
			{if $NOWDATE > $SDATE}
            <a href="javascript:updatedayLog('tsuchday');"><b >&gt;&gt;</b></a>
            {/if}
			<input type="hidden" name="date_only" id="jscal_field_date"  size="15" maxlength="10" value="{$STARTDATE}" onchange="changeDayLog(this);" onClick="WdatePicker()" class="Wdate"/>
            <!--<img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_date" style="vertical-align:middle;"/>
             <script type="text/javascript" id='massedit_calendar_date'>
				Calendar.setup ({ldelim}
					inputField : "jscal_field_date", ifFormat : "%Y-%m-%d", showsTime : false, button : "jscal_trigger_date", singleClick : true, step : 1
				{rdelim})
			</script>-->
            &nbsp;&nbsp;
		
		({$WEEK})  {'DAILYREPORT'|@getFixedLabel}</li>
        <li>{if $STATUS!==1}<font>{/if}{$DAILYREPORTSTATU}{if $STATUS!==1}</font>{/if}</li>
    </ul>
	{if $LOOK eq 'look'}
		<div style="padding-top: 3px;">
		{include file='ReportLogOwner.tpl'}
		</div>
	{/if}
	{if $STATUS eq 1}
		&nbsp;&nbsp;<input id="mobile_menu_create" class="deleteauto createauto marT2"  name="New" value="删除" type="button" onclick="delReportLog('daily','{$REPORTLOGID}')">
	{/if}
	{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" href="javascript:;" style="margin-right: 15px; " onclick="getLinksUrl('ReportLog','ReportLog','writeReportLog');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
</div>
<!--中间-->
<div class="WD_Center">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="WD_CenterBox">
  <tr>
    <td class="TdLeft" valign="top" width="306">
    	<div class="DivL">
        	<div class="Title"><span style="width:100%;">{'PAST_FIVE_DAYS'|@getFixedLabel}{'RECORDS'|@getFixedLabel}</span></div>
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
                            <a style="text-decoration:none;" onclick="changedate('{$data.longdaily}','{$data.look}')" href="javascript::void(0)">
                                {$data.shortdaily}<br /><font>{$data.shortweek}</font></a></td>                        
                        {/foreach}                        
                      </tr>
                    </table>
                </li>
                <li class="B" style="display:none;"><span class="Bj0">0</span><span>已写周报</span><span class="Bj1">1</span><span>已交周报</span></li>
                <li class="C">
                    {if $REPORTTYPE eq 'write'}
                    <a href="index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&reporttype=write&parenttab=My Home Page">{'WRITE_WEEKLY'|@getFixedLabel}</a>
                    <a href="index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&reporttype=write&parenttab=My Home Page" class="Org">{'WRITE_MONTLY'|@getFixedLabel}</a>
                    {else}
                    <a href="index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&Look=look&parenttab=My Home Page">{'Look_Weekly'|@getFixedLabel}</a>
                    <a href="index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&Look=look&parenttab=My Home Page" class="Org">{'Look_Monthly'|@getFixedLabel}</a>
                    {/if}
                </li>
            </ul>
        </div>
    </td>
    <!--右边内容 begin-->
    <td class="Tdcenter" valign="top">
    	<div class="DivC">
        	<div class="DivCName DivCNamehover" onclick="showHideStatus('CurWeekPlan','aid当日数据参考');">
                <span class="On" id="aid当日数据参考">{'REFERENCE_DATA'|@getFixedLabel}<font>（{'EDITORISREFERENCE'|@getFixedLabel}）</font></span>
            </div>
            <div class="DivCNotice" id="CurWeekPlan" style="display:none;">
                {include file="ReportLog/DailyReferenceData.tpl"}
            </div>
            <!--查看今日计划-->
            <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('TodayPlan','aid今日计划');">
                <span id="aid今日计划">{'VIEWTODAYPROGRAMWRITESUMMARY'|@getFixedLabel}</span>
            </div>
            <div class="DivCEdit" id="TodayPlan" style="display:block;">
            	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="word-break: break-all;word-wrap: break-word;">
                  <tr>
                      <td  class="dvtCellLabel" align="left" colspan="2">
                        <!--添加设置模板按钮。 日期：20150427 editor：cxl--> 
                        {if $STATUS neq 1}
                        <input class="createauto" type="button" value="{'DEFINEATEMPLATE'|@getFixedLabel}" onclick="setReportContent(this,ReportLog)" />
                        <span>{'EACHUSERCANSETTHEIROWNTEMPLATES'|@getFixedLabel}</span>
                        {/if}
                      </td>
                  </tr>
                  <tr>
                    <td class="EditBox">
                   <!--  <div style="display:none"></div> -->
                   	{if $STATUS eq 1}
                     {$DAILYCONTENT.worksummary}
                    {else}
                    <script id="DailySummary" name="DailySummary" type="text/plain" style="width:730px;height:100px;">{$DAILYCONTENT.worksummary}</script>
                    <script type="text/javascript">
                        var dailySummaryEditor = UE.getEditor('DailySummary');
                    </script>
                    {/if}
                    </td>
                  </tr>
                </table>
            </div>
            <!--撰写明日计划-->
            <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('TomorrowPlan','aid明日计划');">
            <span id="aid明日计划">{'WRITE_TOMORROW_PLAN'|@getFixedLabel}</span></div>
            <div class="DivCEdit" id="TomorrowPlan" style="display:block;">
            	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                  <tr>
                    <td class="dvtCellLabel" align="left" colspan="2">
                        <input type="button" class="createauto" value="{'TRANSTOMORROWSCHEDULE'|@getFixedLabel}" onclick="getTomorrowCalendar();"/>
                        <span>{'TOMOEEOW_SCHEDULE'|@getFixedLabel}</a></span>
                    </td>                    
                  </tr>
                  <tr>
                    <td class="EditBox">
					{if $STATUS eq 1}
                    {$DAILYCONTENT.tomorrowplan}
                    {else}
                    <script id="TomrrowPlan" name="TomrrowPlan" type="text/plain" style="width:730px;height:100px;">{$DAILYCONTENT.tomorrowplan}</script>
                    <script type="text/javascript">
                        var tomrrowPlanEditor = UE.getEditor('TomrrowPlan');
                           
                    </script>
                    
                    {/if} 
                    </td>
                  </tr>
                </table>
            </div>
            <div class="Button">
            	<div class="F_l">
                {if $STATUS neq 1}                    
                    <input type="button" value="{'TEMPORARY'|@getFixedLabel}"  class="Button_saveGreenD border0" name="btnTmpSave" onclick="btntmpSave(this,0)"/>                    
                    <input type="button" value="{'SUBMIT'|@getFixedLabel}" class="Button_backOrgD border0 mr_l15" name="btnSubmitSave" onclick="btnSubmit(this,0)"/>
                {/if}
                </div> 
            </div>
        </div>
    </td>
  </tr>
</table>
</div>

    </form>
	</div>
<!--设置日报模板的弹出层。 日期：20150427 editor：cxl--> 
<div id="reporttemplet_div" class="D_pop_box LdPopWidth3500px" style="display:none; bgcolor:#fffa;">
<div class="D_pop_tit">
    <strong class="D_ptita" id="titlename">{'DEFINEATEMPLATE'|@getFixedLabel} > {'DAILYREPORT'|@getFixedLabel}</strong>
      <a href="javascript:fninvshnew('reporttemplet_div');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="" title="" >
    </a>
</div>
<div id="content" style="max-height:350px;overflow-y:auto;height:288px; width:733px;" class="D_pop_bod">
    <script id="reporttemplet" name="reporttemplet" type="text/plain" style="width:730px;height:100px;">{$DAILYCONTENT.worksummary}</script>
    <script type="text/javascript">
        var reporttypeEditor = UE.getEditor('reporttemplet');
    </script> 
</div>
<div class="D_pbtn"><input class="D_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" type="button" name="btnSubmitSave" onclick="reporttypeSubmit(this,0)"><span>&nbsp;</span>
<input class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" type="button" onclick="fninvshnew('reporttemplet_div');"></div>                
</div>

<script type="text/javascript">
{literal}
function getId(idval){
	return document.getElementById(idval);
}
/**
 * 上一天、下一天
 * @author Tujt 2014-08-27
 */
function updatedayLog(modetype){
	var startdate = getId('jscal_field_date').value;
	location.href = 'index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&modetype='+modetype+'&reporttype=write&StartDate='+startdate;
	//new Ajax.Request('index.php',{
		//queue: {position: 'end',scope: 'command'},
		//method: 'post',
		////async:"false",
		//postBody:"module=ReportLog&action=DailyReportLog&mode=ajax&modetype="+modetype+"&reporttype=write&StartDate="+startdate,
		//onComplete: function(response) {
			//$("status").style.display="none";
			//var result = response.responseText.split("#####Success:::");
			//var ret = result[1];
			//$("LookReportLog").update(ret);
		//}
	//});
}

/**
 * 变更时间事件
 * @author Tujt 2014-08-27
 */
function changeDayLog(obj){
	var startdate = obj.value;
	location.href = 'index.php?module=ReportLog&action=DailyReportLog&reporttype=write&StartDate='+startdate;
	//new Ajax.Request('index.php',{
		//queue: {position: 'end',scope: 'command'},
		//method: 'post',
		//postBody:"module=ReportLog&action=DailyReportLog&mode=ajax&reporttype=write&StartDate="+startdate,
		//onComplete: function(response) {
			//$("status").style.display="none";
			//var result = response.responseText.split("#####Success:::");
			//var ret=result[1];
			//$("LookReportLog").update(ret);

		//}
	//});
}
/**
 * 设置模板事件
 * @author cxl 2015-4-23
 */
function setReportContent(obj,reporttype){
    fnvshobj(obj, 'reporttemplet_div');
    ld('#edui1').css('z-index','99999')
}
var Listpagepopupobj=new CrmPopup();
Listpagepopupobj.type="listpage";
Listpagepopupobj.refreshpage='no';

Listpagepopupobj.module='WriteDailyReport';
CrmPopup.global_listPopupObj.push(Listpagepopupobj);
{/literal}
</script>
