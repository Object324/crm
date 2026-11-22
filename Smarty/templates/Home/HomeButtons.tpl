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

{*<!-- buttons for the home page -->*}
<!--修改编码格式:统一编码：UTF-8-->

<div class="Ncon_top">
    <!--<strong><a href="index.php?action=index&module={$MODULE}">{$MODULE|@getTranstab}</a></strong>-->
    
    <!--
    {if $CHECK.Calendar eq 'yes' && $CALENDAR_ACTIVE eq 'yes' && $CALENDAR_DISPLAY eq 'true'}
	    <a class="A_anu_a" title="{'CANENDAR'|@getFixedLabel}" href="javascript:;" onclick='fnvshobj(this,"miniCal");getMiniCal("parenttab=My Home Page");'>
        <img src="themes/softed/button/icon_calendar.png" /><span>{'CANENDAR'|@getFixedLabel}</span></a>
	{/if}
    {if $WORLD_CLOCK_DISPLAY eq 'true' }
    	<a class="A_anu_a" onclick="fnvshobj(this,'wclock');" title="{'CLOCK'|@getFixedLabel}">
        <img src="themes/softed/button/icon_clock.png" /><span>{'CLOCK'|@getFixedLabel}</span></a>
    {/if}
    {if $CALCULATOR_DISPLAY eq 'true' }
        <a class="A_anu_a" onclick="fnvshobj(this,'calculator_cont');fetch_calc();" title="{'CALCULATORS'|@getFixedLabel}">
        <img src="themes/softed/button/icon_calculator.png" /><span>{'CALCULATORS'|@getFixedLabel}</span></a>
    {/if}
    {if $CHAT_DISPLAY eq 'true' }
		<a class="A_anu_a" onclick='return window.open("index.php?module=Home&action=vtchat","Chat","width=600,height=450,resizable=1,scrollbars=1");' title="{'CHAT'|@getFixedLabel}">
        <img src="themes/softed/button/icon_say.png" /><span>{'CHAT'|@getFixedLabel}</span></a>
    {/if}
    {if $LAST_READ eq 'true'}
        <a class="A_anu_a" onclick="fnvshobj(this,'tracker');" title="{'READEN'|@getFixedLabel}">
        <img src="themes/softed/button/icon_see.png" /><span>{'READEN'|@getFixedLabel}</span></a>
    {/if}
	-->
    <!--AUTHOR: BY LD KEVIN 变更面板-->
	<!--
    <a class="A_anu_a" href="javascript:;" onclick='showOptions(this,"changeLayoutDiv");' title="{'LAYOUT'|@getFixedLabel}">
    <img src="themes/softed/button/icon_layout.png" /><span>{'LAYOUT'|@getFixedLabel}</span></a>
	-->
    <!--AUTHOR: BY LD chj 首页组件查看范围-->
    <form name="UnifiedScope" method="post" action="index.php?action=index&module=Home&scope=true">
		<input type="hidden" value="" id="hiddenscope" name="hiddenscope"  />
        <input type="hidden" value="" id="selectuid" name="selectuid" value="{$SENIORUSERIDSS}" />
		<input type="hidden" id="homecontrol" name="homecontrol" value='{$HOMECONTROL}'/>
		
    </form>
</div>

{*<!--button related stuff -->*}
<form name="Homestuff" id="formStuff" style="display: inline;">
	<input type="hidden" name="action" value="homestuff">
	<input type="hidden" name="module" value="Home">
	<div id='addWidgetDropDown' style='background-color: #fff; display:none;' onmouseover='fnShowWindow()' onmouseout='fnRemoveWindow()'>
		<ul class="widgetDropDownList">
		<li>
			<a href='javascript:;' class='drop_down' id="addmodule">
				{$MOD.LBL_HOME_MODULE}
			</a>
		</li>
{if $ALLOW_RSS eq "yes"}
		<li>
			<a href='javascript:;' class='drop_down' id="addrss">
				{$MOD.LBL_HOME_RSS}
			</a>
		</li>
{/if}	
{if $ALLOW_DASH eq "yes"}
		<li>
			<a href='javascript:;' class='drop_down' id="adddash">
				{$MOD.LBL_HOME_DASHBOARD}
			</a>
		</li>
{/if}
		<li>
			<a href='javascript:;' class='drop_down' id="addNotebook">
				{$MOD.LBL_NOTEBOOK}
			</a>
               </li>

{if $ALLOW_REPORT eq "yes"}
		<li>
			<a href='javascript:;' class='drop_down' id="addReportCharts">
				{'LBL_REPORTCHARTS'|@getTranslatedString:$MODULE}
			</a>
		</li>
{/if}
        <li>
			<a href='javascript:;' class='drop_down' id="defaultwidget">
				{'LBL_DEFAULT_WIDGET'|@getTranslatedString:$MODULE}
			</a>
		</li>
		{*<!-- this has been commented as some websites are opening up in full page (they have a target="_top")
		<li>
			<a href='javascript:;' class='drop_down' id="addURL">
				{$MOD.LBL_URL}
			</a>
		</li>
		-->*}
	</div>

	{*<!-- the following div is used to display the contents for the add widget window -->*}
	<div id="addWidgetsDiv" class="layerPopup" style="z-index:2000; display:none; width:400px;">
		<input type="hidden" name="stufftype" id="stufftype_id">
		<table width="100%" border="0" cellpadding="5" cellspacing="0" class="layerHeadingULine">
		<tr>
			<td class="layerPopupHeading" align="left" id="divHeader"></td>
			<td align="right"><a class="icon-homeimg icon-close" href="javascript:;" onclick="fnhide('addWidgetsDiv');$('stufftitle_id').value='';"></a></td>
		</tr>
		</table>
		<table border=0 cellspacing=0 cellpadding=5 width=95% align=center>
		<tr>
			<td class=small >
			{*<!-- popup specific content fill in starts -->*}
			<table border="0" cellspacing="0" cellpadding="3" width="100%" align="center" bgcolor="white">
			<tr id="StuffTitleId" style="display:block;">
				<td class="dvtCellLabel"  width="110" align="right">
					{$MOD.LBL_HOME_STUFFTITLE}
					<font color='red'>*</font>
				</td>
				<td class="dvtCellInfo" colspan="2" width="300">
					<input type="text" name="stufftitle" id="stufftitle_id" class="detailedViewTextBox" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onblur="this.className='detailedViewTextBox'" style="width:57%">
				</td>
			</tr>
			{*<!--
			<tr id="homeURLField" style="display:block;">
				<td class="dvtCellLabel"  width="110" align="right">
					{$MOD.LBL_URL}
					<font color='red'>*</font>
				</td>
				<td class="dvtCellInfo" colspan="2" width="300">
					<input type="text" name="url" id="url_id" class="detailedViewTextBox" onfocus="this.className='detailedViewTextBoxOn'" onblur="this.className='detailedViewTextBox'" style="width:57%">
				</td>
			</tr>
			-->*}
			<tr id="showrow">
				<td class="dvtCellLabel"  width="110" align="right">{$MOD.LBL_HOME_SHOW}</td>
				<td class="dvtCellInfo" width="300" colspan="2">
					<select name="maxentries" id="maxentryid" class="detailedViewTextBox" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onblur="this.className='detailedViewTextBox'" style="width:60%">
						{section name=iter start=1 loop=13 step=1}
						<option value="{$smarty.section.iter.index}">{$smarty.section.iter.index}</option>
						{/section}
					</select>&nbsp;&nbsp;{$MOD.LBL_HOME_ITEMS}
				</td>
			</tr>
			<tr id="moduleNameRow" style="display:block">
				<td class="dvtCellLabel"  width="110" align="right">{$MOD.LBL_HOME_MODULE}</td>
				<td width="300" class="dvtCellInfo" colspan="2">
					<select name="selmodule" id="selmodule_id" onchange="setFilter(this)" class="detailedViewTextBox" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onblur="this.className='detailedViewTextBox'" style="width:60%">
						{foreach item=arr from=$MODULE_NAME}
							{assign var="MODULE_LABEL" value=$arr.1|getTranslatedString:$arr.1}
							<option value="{$arr.1}">{$MODULE_LABEL}</option>
						{/foreach}
					</select>
					<input type="hidden" name="fldname">
				</td>
			</tr>
			<tr id="moduleFilterRow" style="display:block">
				<td class="dvtCellLabel" align="right" width="110" >{$MOD.LBL_HOME_FILTERBY}</td>
				<td id="selModFilter_id" colspan="2" class="dvtCellInfo" width="300">
				</td>
			</tr>
			<tr id="modulePrimeRow" style="display:block">
				<td class="dvtCellLabel" width="110" align="right" valign="top">{$MOD.LBL_HOME_Fields}</td>
				<td id="selModPrime_id" colspan="2" class="dvtCellInfo" width="300">
				</td>
			</tr>
			<tr id="rssRow" style="display:none">
				<td class="dvtCellLabel"  width="110" align="right">{$MOD.LBL_HOME_RSSURL}<font color='red'>*</font></td>
				<td width="300" colspan="2" class="dvtCellInfo"><input type="text" name="txtRss" id="txtRss_id" class="detailedViewTextBox" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onblur="this.className='detailedViewTextBox'" style="width:58%"></td>
			</tr>
			<tr id="dashNameRow" style="display:none">
				<td class="dvtCellLabel"  width="110" align="right">{$MOD.LBL_HOME_DASHBOARD_NAME}</td>
				<td id="selDashName" class="dvtCellInfo" colspan="2" width="300"></td>
			</tr>
			<tr id="homewidget" style="display:none">
				<td id="home" class="dvtCellInfo" colspan="2" width="300"></td>
			</tr>
			<tr id="dashTypeRow" style="display:none">
				<td class="dvtCellLabel" align="right" width="110">{$MOD.LBL_HOME_DASHBOARD_TYPE}</td>
				<td id="selDashType" class="dvtCellInfo" width="300" colspan="2">
					<select name="seldashtype" id="seldashtype_id" class="detailedViewTextBox" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onblur="this.className='detailedViewTextBox'" style="width:60%">
						<option value="horizontalbarchart">{$MOD.LBL_HOME_HORIZONTAL_BARCHART}</option>
						<option value="verticalbarchart">{$MOD.LBL_HOME_VERTICAL_BARCHART}</option>
						<option value="piechart">{$MOD.LBL_HOME_PIE_CHART}</option>
					</select>
				</td>
			</tr>
			<tr id="reportNameRow" style="display:none">
				<td class="dvtCellLabel"  width="110" align="right">{'LBL_HOME_REPORT_NAME'|@getTranslatedString:$MODULE}</td>
				<td id="selReportName" class="dvtCellInfo" colspan="2" width="300"></td>
			</tr>
			<tr id="reportTypeRow" style="display:none">
				<td class="dvtCellLabel" align="right" width="110">{'LBL_HOME_REPORT_TYPE'|@getTranslatedString:$MODULE}</td>
				<td id="selReportType" class="dvtCellInfo" width="300" colspan="2">
					<select name="selreporttype" id="selreportcharttype_id" class="detailedViewTextBox" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onblur="this.className='detailedViewTextBox'" style="width:60%">
						<option value="horizontalbarchart">{$MOD.LBL_HOME_HORIZONTAL_BARCHART}</option>
						<option value="verticalbarchart">{$MOD.LBL_HOME_VERTICAL_BARCHART}</option>
						<option value="piechart">{$MOD.LBL_HOME_PIE_CHART}</option>
					</select>
				</td>
			</tr>
		</table>
			{*<!-- popup specific content fill in ends -->*}
			</td>
		</tr>
		</table>

		<table border=0 cellspacing=0 cellpadding=5 width=95% align="center">
			<tr>
				<td align="right">
					<input type="button" name="save" value="{'SAVE'|@getFixedLabel} " id="savebtn" class="save" onclick="frmValidate()">
                </td>
				<td align="left">
                    <input type="button" name="cancel" value="{'CANCEL'|@getFixedLabel} " class="cancel" onclick="fnhide('addWidgetsDiv');$('stufftitle_id').value='';">
				</td>
			</tr>
		</table>
	</div>
</form>
{*<!-- add widget code ends -->*}

<div id="seqSettings" style="background-color:#E0ECFF;z-index:6000000;display:none;">
</div>

<div id="changeLayoutDiv" class="D_pop_box LdPopWidth350px" style="display:none;">
	<div class="D_pop_tit">
    	<strong class="D_ptita">{'CHANGELAYOUT'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('changeLayoutDiv');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    <table class="D_pop_bod" border="0" cellpadding="1" cellspacing="1">
        <tr style="height:40px;">
        	<td width="20%" class="cola">
            	{'NUMBEROFCOLUMNS'|@getFixedLabel}:
            </td>
            <td width="30%">
                <select id="layoutSelect" style="width:90px;height:23px;">
    				<option value="2">
    					{'TWO'|@getFixedLabel}
    				</option>
    				<option value="3">
    					{'THREE'|@getFixedLabel}
    				</option>
    			</select>
            </td>
        </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="saveLayout()"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="hideOptions('changeLayoutDiv');lingdangJS_DialogBox.unblock();"/>
        <!--<a class="D_pbtncancel_a" onclick="hideOptions('changeLayoutDiv');lingdangJS_DialogBox.unblock();" >{'CANCEL'|@getFixedLabel}</a>-->   
    </div>
</div>