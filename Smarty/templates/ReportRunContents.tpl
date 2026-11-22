{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="javascript" type="text/javascript" src="include/scriptaculous/effects.js"></script>
<script type='text/javascript' src='include/jquery/jquery.min.js'></script>
<script type="text/javascript">
  jQuery.noConflict();
</script>
{literal}
<style>
html{overflow-x:scroll !important;}
body{overflow-x:visible !important;}
</style>
{/literal}
<table align="center" border="0" cellpadding="5" cellspacing="0" width="100%" >
	<tbody><tr>
	{if $SHOWCHARTS eq 'true'}
		<td align="right"  width="100%"><input class="create" style="background:#E85313" id="viewcharts1" name="viewcharts1" value="{'LBL_VIEW_CHARTS'|@getTranslatedString_temp:$MODULE}" type="button" onClick="window.location.href = '#viewcharts'" title="{'LBL_VIEW_CHARTS'|@getTranslatedString_temp:$MODULE}"></td>
	{/if}
	</tr>
	</tbody>
</table>

<table align="center" cellpadding="0" cellspacing="0" width="100%">
	<tbody><tr>
	<td style="padding: 5px;" valign="top">
	<table cellpadding="0" cellspacing="0" width="100%">
		<tbody>
        <tr><td colspan="2">&nbsp;</td></tr>
        <tr style="color: #555;font-size: 14px;font-weight: bold;">
		<td align="left" width="75%" style=" padding-left:15px;">
		<span>
		{if $MOD.$REPORTNAME neq ''}
			{$MOD.$REPORTNAME}
		{else}
            {if $REPORTNAME eq '销售订单跟踪表'}
            合同订单跟踪表
            {else}
            {$REPORTNAME}
            {/if}
			
		{/if}
		</span>
		</td>
		<td align="right" width="25%" style=" padding-right:15px;">
		<span>{$APP.LBL_TOTAL} : <span id='_reportrun_total'>{$REPORTHTML.1}</span>  {$APP.LBL_RECORDS}</span>
		</td>
		</tr>
		<tr><td id="report_info" align="left" colspan="2">&nbsp;</td></tr>
		<tr>
		<td colspan="2">
		{* Performance Optimization: Direct result output *}
		{if $DIRECT_OUTPUT eq true}		
			{if isset($__REPORT_RUN_INSTANCE)}
				{php}
					$__oReportRun = $this->_tpl_vars['__REPORT_RUN_INSTANCE'];
					$__filterSql = $this->_tpl_vars['__REPORT_RUN_FILTER_SQL'];
					$__oReportRunReturnValue = $__oReportRun->GenerateReport("HTML", $__filterSql, true);
				{/php}
			{/if}		
		{elseif $ERROR_MSG eq ''}
			{$REPORTHTML.0}
		{else}
			{$ERROR_MSG}
		{/if}
		{* END *}
		</td>
		</tr>
		<tr><td colspan="2">
		{* Performance Optimization: Direct result output *}
		{if $DIRECT_OUTPUT eq true}
			{php}
				if(is_array($__oReportRunReturnValue)) { $__oReportRun->GenerateReport("TOTALHTML", $__filterSql, true); }
			{/php}
		{else}			
			{$REPORTTOTHTML}
		{/if}
		{* END *}
		</td></tr>
		</tbody>
	</table>
	</td>
	
	</tr>

	</tbody>
</table>
<br>
{if $SHOWCHARTS eq 'true'&& $ChartsHtml}
<div name="viewcharts" id="viewcharts">
{foreach item=Charts  from=$ChartsHtml}
<table style="border: 1px solid rgb(0, 0, 0);" align="center" cellpadding="0" cellspacing="0" width="100%">
	<tbody>
		<tr>
			<td style="background-repeat: repeat-y;" background="{'report_btn.gif'|@lingdang_imageurl:$THEME}" width="16"></td>
			<td>
				<table border=0 cellspacing=1 cellpadding=0 width="100%" class="lvtBg">
                    <tr>
                        <td colspan="2" align="left" style="padding:10px;" class="font14 lineheight16 greyFont8 fontbold">
                        <b>{$Charts.0|@getTranslatedString_temp:$module}</b>
                        </td>
                    </tr>
                    <tr>
						<td> {$Charts.1} </td>
						<td> {$Charts.2} </td>
					</tr>
				</table>
			</td>
			<td style="background-repeat: repeat-y;" background="{'report_btn.gif'|@lingdang_imageurl:$THEME}" width="16"></td>
		</tr>
	</tbody>
</table>
<!--
<table align="center" border="0" cellpadding="5" cellspacing="0" width="100%" class="mailSubHeader">
	<tbody><tr>
		<td align="right"  width="100%"><input class="create" style="background:#E85313" id="addChartstodashboard" name="addChartstodashboard" value="{'LBL_ADD_CHARTS'|@getTranslatedString_temp:$MODULE}" type="button" onClick="showAddChartPopup();" title="{'LBL_ADD_CHARTS'|@getTranslatedString_temp:$MODULE}"></td>	
	</tr>
	</tbody>
</table>
-->
{/foreach}
</div>
{/if}


<div id="addcharttoHomepage"  class="layerPopup" style="z-index:2000; display:none; width: 400px;">
<table width="100%" border="0" cellpadding="5" cellspacing="0" class="layerHeadingULine">
    <tr>
        <td align="left" id="divHeader" class="layerPopupHeading" width="80%"><b>添加报表视图</b></td>
        <td align="right">
                <a class="icon-homeimg icon-close" onclick="fnhide('addcharttoHomepage');" href="javascript:;">
                </a>
        </td>
    </tr>
</table>
<table border=0 cellspacing=0 cellpadding=5 width=95% align=center>
<tr>
    <td class="small">
        <table border="0" cellspacing="0" cellpadding="3" width="100%" align="center" bgcolor="white">
            <tr>
                <td class="dvtCellLabel"  width="110" align="right">{'LBL_HOME_WINDOW_TITLE'|@getTranslatedString_temp:$MODULE}<font color='red'>*</font></td>
                <td class="dvtCellInfo" colspan="2" width="300" align="left"><input type="text" name="windowtitle" id="windowtitle_id" class="detailedViewTextBox" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onblur="this.className='detailedViewTextBox'" style="width:57%"></td>
            </tr>
            <tr>
                <td class="dvtCellLabel"  width="110" align="right">{'LBL_HOME_REPORT_NAME'|@getTranslatedString_temp:$MODULE}</td>
                <td id="selReportName" class="dvtCellInfo" colspan="2" width="300" align="left">{$REPORTNAME}</td>
            </tr>
            <tr>
                <td class="dvtCellLabel"  width="110" align="right">{'LBL_HOME_REPORT_TYPE'|@getTranslatedString_temp:$MODULE}</td>
                <td id="selReportType" class="dvtCellInfo" width="300" colspan="2" align="left">
                        <select name="selreporttype" id="selreportcharttype_id" class="detailedViewTextBox" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onblur="this.className='detailedViewTextBox'" style="width:60%">
                                <option value="horizontalbarchart">{'LBL_HOME_HORIZONTAL_BARCHART'|@getTranslatedString_temp:$MODULE}</option>
                                <option value="verticalbarchart">{'LBL_HOME_VERTICAL_BARCHART'|@getTranslatedString_temp:$MODULE}</option>
                                <option value="piechart">{'LBL_HOME_PIE_CHART'|@getTranslatedString_temp:$MODULE}</option>
                        </select>
                </td>
            </tr>
        </table>
      </td>
</tr>
</table>
<table border=0 cellspacing=0 cellpadding=5 width=95% align="center">
    <tr>
        <td align="right">
            <input type="button" name="save" value=" &nbsp;{$APP.LBL_SAVE_BUTTON_LABEL}&nbsp; " id="savebtn" class="save" onclick="addChartsToHomepage({$REPORTID})"></td>
            <td align="left"><input type="button" name="cancel" value="{$APP.LBL_CANCEL_BUTTON_LABEL}" class="cancel" onclick="fnhide('addcharttoHomepage');">
        </td>
    </tr>
 </table>
</div>

<div name="widgetmessage" id="widgetsuccess" style="display:none;background-color:#E0ECFF;width:150px;top:600px;right:481px;position:absolute">
    <table cellpadding="10" cellspacing="0" border="0" width="100%" class="vtResultPop small">
        <tr>
            <td align="center">
               {'LBL_WIDGET_ADDED'|@getTranslatedString_temp:$MODULE}
            </td>
        </tr>
    </table>
</div>