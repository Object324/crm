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
<div  class="yb">
<!--写周报 头部-->
    <div class="WD_top">
    	<ul style="margin:0;padding:0;">
        	<li class="Name">{if $REPORTTYPE eq 'write'}{'WRITE_WEEKLY'|@getFixedLabel}{else}{'Look_Weekly'|@getFixedLabel}{/if}：</li>
            <li>{$USERNAME} &nbsp;{$WEEKRANGE}</li>
            <li>
                {if $REPORTLOGID eq -1}<font>{'Not_write'|@getFixedLabel}</font>
                {elseif $STATUS eq 0}<font>{'Temporary_unpaid'|@getFixedLabel}</font>
                {elseif $STATUS eq 1}<font>{'HAVETOPAY'|@getFixedLabel}</font>
                {/if}
            </li>
        </ul>
		{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" href="javascript:;" style="margin-right: 15px;" onclick="getLinksUrl('ReportLog','ReportLog','writeReportLog');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
    </div>
 <!--写周报 内容 begin -->   
    <div class="WD_Center">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="WD_CenterBox">
    <tr>
    <td class="TdLeft" valign="top" width="306">
        <form action="index.php" method="post" name="ReportLogHref" class="week_ajax_form">
        {include file="ReportLog/ReportLogHidden.tpl"}
        <input type="hidden" name="AHref"/>
    	<div class="DivL">
        	<div class="Title">
                <span style="width:100%;"><a href="javascript:void(0)" onclick="WeekReportLogHref(document.getElementById('prev'),1)"   id="prev" style="display:inline;">
                <b>&lt;&lt;</b></a>({'VARWEEK'|@getVarFixedLabel:$PREVWEEKOFYEAR}){'WEEKREPORT'|@getFixedLabel}
                {if $NOWDATE neq $ENDDATE}
                    <a href="javascript:void(0)" onclick="WeekReportLogHref(document.getElementById('next'),1)"  id="next" style="display:inline;">
                   <b>&gt;&gt;</b></a>
                {/if}</span>
            </div>
            <ul class="Ui0" style="margin:0px;padding:0px;">                
                <li class="C">
                    {if $REPORTTYPE eq 'write'}
                    <a href="index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&reporttype=write&parenttab=My Home Page">{'WRITE_DAILY'|@getFixedLabel}</a>
                    <a href="index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&reporttype=write&parenttab=My Home Page" class="Org">{'WRITE_MONTLY'|@getFixedLabel}</a>
                    {else}
                    <a href="index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&look=look&parenttab=My Home Page">{'Daily_Look'|@getFixedLabel}</a>
                    <a href="index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&Look=look&parenttab=My Home Page" class="Org">{'Look_Monthly'|@getFixedLabel}</a>
                    {/if}
                </li>
            </ul>
        </div>
        </form>
    </td>
    <!--右边内容 begin-->
    <td class="Tdcenter" valign="top">
        <form action="index.php" method="post"  name="ReportLog" class="ajax_form">
        {include file="ReportLog/ReportLogHidden.tpl"}
    	<div class="DivC">                
            <!--本周总结-->
            <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('WeekSummary','aid本周总结');">
                <span id="aid本周总结">{'Week_Summary'|@getFixedLabel}</span>
            </div>
            <div class="DivCEdit" id="WeekSummary" style="display:block;">
            	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                  <tr>
                    <td class="EditBox">
                    <!--添加设置周报按钮。 日期：20150427 editor：cxl--> 
                    {if $STATUS neq 1}
                    <input class="createauto" type="button" value="{'DEFINEATEMPLATE'|@getFixedLabel}" onclick="setReportContent(this,ReportLog)" />
                    <span>{'EACHUSERCANSETTHEIROWNTEMPLATES'|@getFixedLabel}</span>                  
           	        {/if}
                    <script id="WorkSummary" name="WorkSummary" type="text/plain" style="width:730px;height:100px;">{$WORKSUMMARY}</script>
                    <script type="text/javascript">
                        var workSummaryEditor = UE.getEditor('WorkSummary');
                    </script>
                                    
                    </td>
                  </tr>
                </table>
            </div>
            <!--下周计划-->
            <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('WeekNext','aid下周计划');">
                <span id="aid下周计划">{'Plan_next_week'|@getFixedLabel}</span>
            </div>
            <div class="DivCEdit" id="WeekNext" style="display:block;">
            	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                  <tr>
                    <td class="EditBox">
                   	<script id="NextWeekPlan" name="NextWeekPlan" type="text/plain" style="width:730px;height:100px;">{$NEXTWEEKPLAN}</script>
                     
                    <script type="text/javascript">
                        var nextWeekEditor = UE.getEditor('NextWeekPlan');
                    </script>
                                 
                    </td>
                  </tr>
                </table>
            </div>
            <div class="Button">
            	<div class="F_l">
                {if $STATUS neq 1}                    
                    <input type="button" value="{'TEMPORARY'|@getFixedLabel}" class="Button_saveGreenD border0" name="btnTmpSave" onclick="return btntmpSave(this,1)"/>
                    <input type="button" value="{'SUBMIT'|@getFixedLabel}" class="Button_backOrgD border0 mr_l15" name="btnSubmitSave" onclick="btnSubmit(this,1)"/>
                {/if}
                </div> 
            </div>
        </div>
      
    </td>
  </tr>
</table>
</div>
<div id="LookReportLog" style="clear:both;padding:10px 0px 10px 15px;">
                {include file="ReportLog/WeekReportList.tpl"}
</div>
     </form>
</div> 
<!--设置周报模板的弹出层。 日期：20150427 editor：cxl--> 
<div id="reporttemplet_div" class="D_pop_box LdPopWidth3500px" style="display:none; bgcolor:#fffa;">
<div class="D_pop_tit">
      <strong class="D_ptita" id="titlename">{'DEFINEATEMPLATE'|@getFixedLabel} > {'WEEKREPORT'|@getFixedLabel}</strong>
    <a href="javascript:fninvshnew('reporttemplet_div');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="" title="" >
    </a>
</div>
<div id="content" style="max-height:350px;overflow-y:auto;height:288px; width:733px;" class="D_pop_bod">           
    <script id="reporttemplet" name="reporttemplet" type="text/plain" style="width:730px;height:100px;">{$WORKSUMMARY}</script>
    <script type="text/javascript">
        var reporttypeEditor = UE.getEditor('reporttemplet');
    </script> 
</div>
<div class="D_pbtn"><input class="D_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" type="button" name="btnSubmitSave" onclick="reporttypeSubmit(this,1)"><span>&nbsp;</span>
<input class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" type="button" onclick="fninvshnew('reporttemplet_div');"></div>                
</div>

<script type="text/javascript">
{literal}
/**
 * 设置模板事件
 * @author cxl 2015-4-23
 */
function setReportContent(obj,reporttype){
    fnvshobj(obj, 'reporttemplet_div');  
}

{/literal}
</script>












 