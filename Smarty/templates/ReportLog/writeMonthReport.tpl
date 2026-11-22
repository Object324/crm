<!--修改编码格式:统一编码：UTF-8-->
    <link href="themes/softed/writeDaily.css" rel="stylesheet" type="text/css" />
    <div  class="yb">
    <!--写月报 头部-->
    <div class="WD_top">
    	<ul style="margin:0;padding:0;">
        	<li class="Name">{if $REPORTTYPE eq 'write'}{'WRITE_MONTLY'|@getFixedLabel}{else}{'Look_Monthly'|@getFixedLabel}{/if}：</li>
            <li>{$USERNAME} </li>
            <li>
                {if $REPORTLOGID eq -1}<font>{'Not_write'|@getFixedLabel}</font>
                {elseif $STATUS eq 0}<font>{'Temporary_unpaid'|@getFixedLabel}</font>
                {elseif $STATUS eq 1}<font>{'HAVETOPAY'|@getFixedLabel}</font>
                {/if}
            </li>
        </ul>
		{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="rfloat" href="javascript:;" style="margin-right: 15px;" onclick="getLinksUrl('ReportLog','ReportLog','writeReportLog');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>{/if}
    </div> 
    <!--写月报 内容 begin -->    
    <div class="WD_Center">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="WD_CenterBox">
    <tr>
    <td class="TdLeft" valign="top" width="306">
        <form action="index.php" method="post" name="ReportLogHref">
        {include file="ReportLog/ReportLogHidden.tpl"}
        <input type="hidden" name="AHref" value="prev"/>       
        <input type="hidden" name="MonthDays" value="{$MONTHDAYS}"/>
    	<div class="DivL">
        	<div class="Title">
               <span style="width:100%;">{if $STARTDATE neq "2000-01-01"}
                       <a href="javascript:ReportLogHref(document.getElementById('prev'),2)"  id="prev" style="display:inline;border-bottom:none;">
                            <b>&lt;&lt;</b>
                        </a>
                    {/if} 
                    <select onchange="YearChange(this)" name="yearOpt" id="yearOpt" style="font-size:16px">
                       {foreach key=k item=content from=$YEAROPTIONS}
                        {if $k eq $YEARBOL}
                            <option value="{$k}" selected="true">{$content}</option>
                        {else}
                            <option value="{$k}">{$content}</option>
                        {/if}
                        
                        {/foreach}
                    </select>
                    <select onchange="MonthChange(this)" id="monthOpt" name="monthOpt" style="font-size:16px">
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
                              <b>&gt;&gt;</b>
                      </a>
                     {/if}
                
              </span><input type="hidden" name="monthOpt" value="{$MONTHOFYEAR}">
			  <!--<span><b>{$NOWDATE}</b><input type="hidden" name="yearOpt" value="{$YEARBOL}"><input type="hidden" name="monthOpt" value="{$MONTHOFYEAR}"></span>-->
			  </div>
            <ul class="Ui0" style="margin:0px;padding:0px;">                
                <li class="C">
                    {if $REPORTTYPE eq 'write'}
                    <a href="index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&reporttype=write&parenttab=My Home Page">{'WRITE_DAILY'|@getFixedLabel}</a>
                    <a href="index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&reporttype=write&parenttab=My Home Page" class="Org">{'WRITE_WEEKLY'|@getFixedLabel}</a>
                    {else}
                    <a href="index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&look=look&parenttab=My Home Page">{'Daily_Look'|@getFixedLabel}</a>
                    <a href="index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&Look=look&parenttab=My Home Page" class="Org">{'Look_Weekly'|@getFixedLabel}</a>
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
            <!--本月总结-->
            <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('MonthSummary','aid本月总结');">
                <span id="aid本月总结">{'This_month_summary'|@getFixedLabel}</span>
            </div>
            <div class="DivCEdit" id="MonthSummary" style="display:block;">
            	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                  <tr>
                    <td class="EditBox">
                    <!--添加月报设置模版按钮。 日期：20150427 editor：cxl--> 
                     {if $STATUS neq 1}
                     <input class="createauto" type="button" value="{'DEFINEATEMPLATE'|@getFixedLabel}" onclick="setReportContent(this,ReportLog)" />
                    <span>{'EACHUSERCANSETTHEIROWNTEMPLATES'|@getFixedLabel}</span>
                      {/if}
                     <script id="WorkSummary" name="WorkSummary" type="text/plain" style="width:730px;height:100px;">{$WORKSUMMARY}</script>
                     <script type="text/javascript">
                        var workSummaryEditor = UE.getEditor('WorkSummary');
                     </script>
                    
                      </script>    
                    </td>
                  </tr>
                </table>
            </div>
            <!--下月计划-->
            <div class="DivCName DivCNamehover BorTop" onclick="showHideStatus('MonthNext','aid下月计划');">
                <span id="aid下月计划">{'Plan_next_month'|@getFixedLabel}&nbsp;&nbsp;{'Action_Plan_Reference'|@getFixedLabel}</span>
            </div>
            <div class="DivCEdit" id="MonthNext" style="display:block;">
            	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                  <tr>
                    <td class="EditBox">
                   	    <script id="NextMonthPlan" name="NextMonthPlan" type="text/plain" style="width:730px;height:100px;">{$NEXTMONTHPLAN}</script>
                         <script type="text/javascript">
                            var nextMonthEditor = UE.getEditor('NextMonthPlan');
                         </script>
                                           
                    </td>
                  </tr>
                </table>
            </div>        
            <div class="Button">
            	<div class="F_l">
                {if $STATUS neq 1}                    
                    <input type="button" value="{'TEMPORARY'|@getFixedLabel}" class="Button_saveGreenD border0" name="btnTmpSave" onclick="return btntmpSave(this,2)"/>
                    <input type="button" value="{'SUBMIT'|@getFixedLabel}" class="Button_backOrgD border0 mr_l15" name="btnSubmitSave" onclick="btnSubmit(this,2)"/>
                {/if}
                </div> 
            </div>            
        </div>
       
    </td>
  </tr>
</table>
</div>
<div id="LookReportLog" style="clear:both;padding:10px 0px 10px 15px;">
    {include file="ReportLog/MonthReportList.tpl"}
</div>
</form>
 </div>
<!--设置月报模板的弹出层。 日期：20150427 editor：cxl--> 
<div id="reporttemplet_div" class="D_pop_box LdPopWidth3500px" style="display:none; bgcolor:#fffa;">
<div class="D_pop_tit">
      <strong class="D_ptita" id="titlename">{'DEFINEATEMPLATE'|@getFixedLabel} > {'MONTHREPORT'|@getFixedLabel}</strong>
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
<div class="D_pbtn"><input class="D_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" type="button" name="btnSubmitSave" onclick="reporttypeSubmit(this,2)"><span>&nbsp;</span>
<input class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" type="button" onclick="fninvshnew('reporttemplet_div');"></div>                
</div> 
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
/**
 * 设置模板事件
 * @author cxl 2015-4-23
 */
function setReportContent(obj,reporttype){
    fnvshobj(obj, 'reporttemplet_div');  
}

{/literal}
</script>
  