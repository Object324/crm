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
<script type="text/javascript">
	var rel_fields = {$REL_FIELDS};
</script>
<script language="JavaScript" type="text/JavaScript">
var fLabels = new Array();
fLabels['e'] = '{'EQ'|@getFixedLabel}';
fLabels['n'] = '{'NEQ'|@getFixedLabel}';
fLabels['c'] = '{'IN'|@getFixedLabel}';
fLabels['k'] = '{'NOT_IN'|@getFixedLabel}';
fLabels['l'] = '{'LT'|@getFixedLabel}';
fLabels['g'] = '{'GT'|@getFixedLabel}';
fLabels['m'] = '{'LE'|@getFixedLabel}';;
fLabels['h'] = '{'GE'|@getFixedLabel}';
fLabels['bw'] = '{'Interval'|@getFixedLabel}';
fLabels['b'] = '{'Before'|@getFixedLabel}';
fLabels['a'] = '{'After'|@getFixedLabel}';
fLabels['isnull'] = '{'ISNULL'|@getFixedLabel}';
fLabels['isnotnull'] = '{'ISNOTNULL'|@getFixedLabel}';
</script>
<script language="JavaScript" type="text/javascript" src="modules/Reports/Reports.js"></script>
<!--
/*
*AUTHOR:BY LD KEVIN
*DATE:20130129
*DESCRIPTION:修改bug3130
*calendar-en.js 改为calendar-zh.js
*/
-->
<script language="JavaScript" type="text/javascript" src="include/calculator/calc.js"></script>
<input type="hidden" id="isDefaultReport" value="{$defaultreport}"/>
<div class="CustomReportDetail">
    	
<table class="customTabHead" align="center" border="0" cellpadding="10" cellspacing="0" width="100%">
	<form name="NewReport" action="index.php" method="POST" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="booleanoperator" value="5"/>
    <input type="hidden" name="record" value="{$REPORTID}"/>
    <input type="hidden" name="reload" value=""/>    
    <input type="hidden" name="module" value="Reports"/>
    <input type="hidden" name="action" value="SaveAndRun"/>
    <input type="hidden" name="dlgType" value="saveAs"/>
    <input type="hidden" name="reportName"/>
    <input type="hidden" name="folderid" value="{$FOLDERID}"/>
    <input type="hidden" name="reportDesc"/>
    <input type="hidden" name="folder"/>

	<tbody>
	<tr>
	<td width="70%" style="padding-left:15px;border-right:1px solid #ddd;">
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
		</span>&nbsp;&nbsp;
		{if $IS_EDITABLE eq 'true'&& $defaultreport eq ''}
		<input type="button" name="custReport" value="{$MOD.LBL_CUSTOMIZE_REPORT}" class="edit" onClick="editReport('{$REPORTID}');">
		{/if}
		<a href="index.php?module=Reports&action=ListView" style="font-size:12px;font-weight:normal;">&lt;{$MOD.LBL_BACK_TO_REPORTS}</a>
	</td>
	<td width="30%">
		<b>{$MOD.LBL_SELECT_ANOTHER_REPORT} </b>&nbsp;
		<select name="another_report" class="borderALL" onChange="selectReport()">
		{foreach key=report_in_fld_id item=report_in_fld_name from=$REPINFOLDER}
		{if $MOD.$report_in_fld_name neq ''} 
			{if $report_in_fld_id neq $REPORTID}
				<option value={$report_in_fld_id}>{$MOD.$report_in_fld_name}</option>
			{else}	
				<option value={$report_in_fld_id} selected>{$MOD.$report_in_fld_name}</option>
			{/if}
		{else}
			{if $report_in_fld_id neq $REPORTID}
				<option value={$report_in_fld_id}>{$report_in_fld_name}</option>
			{else}	
				<option value={$report_in_fld_id} selected>{$report_in_fld_name}</option>
			{/if}
		{/if}
		{/foreach}
		</select>
	</td>
	</tr>
	</tbody>
</table>

<!-- Generate Report UI Filter -->
<table class="customConditionsTab" align="center" cellpadding="5" cellspacing="0" width="100%" border=0>
	<tr>
		<td align="left" style="padding:5px" width="80%">
			{include file='AdvanceFilter.tpl' SOURCE='reports'}
		</td>
	</tr>
	<tr>
		<td align="center" style="border-top:1px solid #ccc;padding:12px;">
			<input type="button" class="createauto" onclick="generateReport({$REPORTID});" value="{$MOD.LBL_GENERATE_NOW}" title="{$MOD.LBL_GENERATE_NOW}" />
			<input type="button" class="createauto" value="{'NEWCOMBINATION'|@getFixedLabel}" onclick="addNewConditionGroup('adv_filter_div')" />
			<input type="button" class="editauto" onclick="saveReportAdvFilter({$REPORTID});" value="  {$MOD.LBL_SAVE_REPORT}  " title="{$MOD.LBL_SAVE_REPORT}" />
		</td>
	</tr>
</table>

<table class="mailClientBg" align="center" border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td align="right" valign="bottom" style="padding:5px">
			<a href="javascript:void(0);" onclick="location.href='index.php?module=Reports&action=SaveAndRun&record={$REPORTID}&folderid={$FOLDERID}{$defaultreport}'"><img src="{'revert.png'|@lingdang_imageurl:$THEME}" align="abmiddle" alt="{$MOD.LBL_RELOAD_REPORT}" title="{$MOD.LBL_RELOAD_REPORT}" border="0"></a>
			&nbsp;
			<a href="javascript:void(0);" onclick="saveReportAs(this,'duplicateReportLayout');"><img src="{'saveas.png'|@lingdang_imageurl:$THEME}" align="abmiddle" alt="{'SAVEREPORT'|getFixedLabel}" title="{'SAVEREPORT'|getFixedLabel}" border="0"></a>
			&nbsp;
			<a href="javascript:void(0);" onclick="goToURL(CrearEnlace('CreatePDF',{$REPORTID}));"><img src="{'pdf-file.jpg'|@lingdang_imageurl:$THEME}" align="abmiddle" alt="{$MOD.LBL_EXPORTPDF_BUTTON}" title="{$MOD.LBL_EXPORTPDF_BUTTON}" border="0"></a>
			&nbsp;
			<a href="javascript:void(0);" onclick="goToURL(CrearEnlace('CreateXL',{$REPORTID}));"><img src="{'xls-file.jpg'|@lingdang_imageurl:$THEME}" align="abmiddle" alt="{$MOD.LBL_EXPORTXL_BUTTON}" title="{$MOD.LBL_EXPORTXL_BUTTON}" border="0"></a>
			&nbsp;
			<a href="javascript:void(0);" onclick="goToPrintReport({$REPORTID});"><img src="{'fileprint.png'|@lingdang_imageurl:$THEME}" align="abmiddle" alt="{$MOD.LBL_PRINT_REPORT}" title="{$MOD.LBL_PRINT_REPORT}" border="0"></a>
		</td>
	</tr>
</table>


<div style="display: block;" id="Generate" align="center">
	{include file="ReportRunContents.tpl"}
</div>


</div>


<!-- Save Report As.. UI -->

<div id="duplicateReportLayout" style="display:none;" class="D_pop_box LdPopWidth350px">

    <div class="D_pop_tit">
    	<strong class="D_ptita">{$MOD.LBL_SAVE_REPORT_AS}</strong>
        <a href="javascript:fninvshnew('duplicateReportLayout');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>		
	<table class="D_pop_bod" cellspacing="1" cellpadding="0" border="0">
      <tr>
        <td>
    		<ul class="LdPop_ul9">
        		<li><span>{$MOD.LBL_REPORT_NAME}：</span></li>            
        		<li>
					<input type="text" name="newreportname" id="newreportname" value="" />
				</li>   
        	</ul>
			<ul class="LdPop_ul9">
        		<li><span>{$MOD.LBL_REP_FOLDER}：</span></li>
        		<li>
					<select name="reportfolder" id="reportfolder">
						{foreach item=folder from=$REP_FOLDERS}
						{if $FOLDERID eq $folder.id}
							<option value="{$folder.id}" selected>{$folder.name}</option>
						{else}
							<option value="{$folder.id}">{$folder.name}</option>
						{/if}
						{/foreach}
					</select>
				</li>   
        	</ul>
			<ul class="LdPop_ul9">
			<li><span>{$MOD.LBL_DESCRIPTION}：</span></li>
			<li><textarea name="newreportdescription"  id="newreportdescription" rows="5">{$REPORTDESC}</textarea></li>
			</ul>
        </td>
      </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{$APP.LBL_SAVE_BUTTON_LABEL}" onclick="duplicateReport({$REPORTID});"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('duplicateReportLayout');"/>
    </div>
</div>

{literal}

<script type="text/javascript">
var isDefaultReport=$('isDefaultReport').value;
function CrearEnlace(tipo,id){

	if(!checkAdvancedFilter()) return false;
	var advft_criteria = $('advft_criteria').value;
	var advft_criteria_groups = $('advft_criteria_groups').value;

	return "index.php?module=Reports&action="+tipo+"&record="+id+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+isDefaultReport;

}

function goToURL(url) {
    if(url==false){
        exit();
    }else{
        document.location.href = url;
    }
    
}

function saveReportAs(oLoc,divid) {
	$('newreportname').value = '';
	$('newreportdescription').value = '';
	fnvshobj(oLoc,divid);
}

function duplicateReport(id) {

	puyoungJS_DialogBox.block();
	
	var newreportname = $('newreportname').value;
	if (trim(newreportname) == "") {
		puyoungJS_DialogBox.unblock();
		alert(alert_arr.MISSING_REPORT_NAME);
		return false;
	} else {
		new Ajax.Request(
				'index.php',
				{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody: 'action=ReportsAjax&mode=ajax&file=CheckReport&module=Reports&check=reportCheck&reportName='+encodeURIComponent(newreportname),
				onComplete: function(response) {
					if(response.responseText != 0) {
						puyoungJS_DialogBox.unblock();
						alert(alert_arr.REPORT_NAME_EXISTS);
						return false;
					} else {
						createDuplicateReport(id);
					}
				}
				}
		);
	}
}

function createDuplicateReport(id) {
	
	var newreportname = $('newreportname').value;
	var newreportdescription = $('newreportdescription').value;
	var newreportfolder = $('reportfolder').value;
	
	if(!checkAdvancedFilter()) return false;

	var advft_criteria = $('advft_criteria').value;
	var advft_criteria_groups = $('advft_criteria_groups').value;
	
	new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'action=ReportsAjax&file=DuplicateReport&mode=ajax&module=Reports&record='+id+'&newreportname='+encodeURIComponent(newreportname)+'&newreportdescription='+encodeURIComponent(newreportdescription)+'&newreportfolder='+newreportfolder+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups,
                        onComplete: function(response) {
							var responseArray = JSON.parse(response.responseText);
							if(trim(responseArray['errormessage']) != '') {
								puyoungJS_DialogBox.unblock();
								alert(resonseArray['errormessage']);								
							}
							var reportid = responseArray['reportid'];
							var folderid = responseArray['folderid'];
							var url ='index.php?action=SaveAndRun&module=Reports&record='+reportid+'&folderid='+folderid;
							goToURL(url);
                        }
                }
        );
}

function generateReport(id) {

	if(!checkAdvancedFilter()) return false;

	puyoungJS_DialogBox.block();
	
	var advft_criteria = $('advft_criteria').value;
	var advft_criteria_groups = $('advft_criteria_groups').value;

	new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'action=ReportsAjax&file=SaveAndRun&mode=ajax&module=Reports&submode=generateReport&record='+id+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+isDefaultReport,
                        onComplete: function(response) {
							getObj('Generate').innerHTML = response.responseText;
							// Performance Optimization: To update record count of the report result 
							var __reportrun_directoutput_recordcount_scriptnode = $('__reportrun_directoutput_recordcount_script');
							if(__reportrun_directoutput_recordcount_scriptnode) { eval(__reportrun_directoutput_recordcount_scriptnode.innerHTML); }
							// END
							puyoungJS_DialogBox.unblock();
                        }
                }
        );
}


function saveReportAdvFilter(id) {

	if(!checkAdvancedFilter()) return false;

	puyoungJS_DialogBox.block();
	
	var advft_criteria = $('advft_criteria').value;
	var advft_criteria_groups = $('advft_criteria_groups').value;

	new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'action=ReportsAjax&file=SaveAndRun&mode=ajax&module=Reports&submode=saveCriteria&record='+id+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+isDefaultReport,
                        onComplete: function(response) {
							getObj('Generate').innerHTML = response.responseText;
							// Performance Optimization: To update record count of the report result 
							var __reportrun_directoutput_recordcount_scriptnode = $('__reportrun_directoutput_recordcount_script');
							if(__reportrun_directoutput_recordcount_scriptnode) { eval(__reportrun_directoutput_recordcount_scriptnode.innerHTML); }
							// END
							puyoungJS_DialogBox.unblock();
                        }
                }
        );
}

function selectReport() {
	var id = document.NewReport.another_report.options  [document.NewReport.another_report.selectedIndex].value;
	var folderid = getObj('folderid').value;
	url ='index.php?action=SaveAndRun&module=Reports&record='+id+'&folderid='+folderid;
	goToURL(url);
}

{/literal}

function goToPrintReport(id) {ldelim}

	if(!checkAdvancedFilter()) return false;
	var advft_criteria = $('advft_criteria').value;
	var advft_criteria_groups = $('advft_criteria_groups').value;
	
	window.open("index.php?module=Reports&action=ReportsAjax&file=PrintReport&record="+id+'&advft_criteria='+advft_criteria+'&advft_criteria_groups='+advft_criteria_groups+isDefaultReport,"{$MOD.LBL_Print_REPORT}","width=840,height=650,resizable=1,scrollbars=1,left=100");
{rdelim}

</script>