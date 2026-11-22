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
<!--修改编码格式:统一编码：UTF-8-->>
<script language="JavaScript" type="text/javascript" src="include/calculator/calc.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>

<script type="text/javascript">
	var rel_fields = {$REL_FIELDS};
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

{$BLOCKJS_STD}

<table width="100%" border="0" cellpadding="9" cellspacing="0">
	<tr bgcolor="#F6F6F6">
		<td colspan="2" class="TabLeftHeard">
			<span>{$MOD.LBL_FILTERS}</span>
			{$MOD.LBL_SELECT_FILTERS_TO_STREAMLINE_REPORT_DATA}
		</td>
	</tr>
	<tr id='std_filter_div_show' name='std_filter_div_show'>
		<td colspan="2" align="left" valign="top">
			<a href="###" onclick="showHideDivs('std_filter_div','std_filter_div_show');"><b>{$MOD.LBL_SHOW_STANDARD_FILTERS}</b></a>
		</td>
	</tr>
	<tr id='std_filter_div' name='std_filter_div' style="display:none;">
		<td colspan="2" valign="top">
			<div>
                <a href="###" onclick="showHideDivs('std_filter_div_show','std_filter_div');"><b>{$MOD.LBL_STANDARD_FILTER}</b></a>
				
                <table style="margin-top:15px;" class="listEntries" border="0" cellpadding="0" cellspacing="1" width="100%">
					<tr>
						<th width="30%">{$MOD.LBL_SF_COLUMNS}</th>
						<th width="30%">&nbsp;</th>
						<th width="20%">{$MOD.LBL_SF_STARTDATE}</th>
						<th width="20%">{$MOD.LBL_SF_ENDDATE}</th>
					</tr>
					<tr bgcolor="white">
						<td>
							<select name="stdDateFilterField" class="detailedViewTextBox" onchange='standardFilterDisplay();'>
							{$BLOCK1_STD}
							</select>
						</td>
						<td>
							<select name="stdDateFilter" id="stdDateFilter" onchange='showDateRange( this.options[ this.selectedIndex ].value )' class="width150 commonSelectPop">
							{$BLOCKCRITERIA_STD}
							</select>
						</td>
						<td>
							<input name="startdate" id="jscal_field_date_start" style="border: 1px solid rgb(186, 186, 186);" size="15" class="Wdate" maxlength="10" value="{$STARTDATE_STD}" type="text" onClick="WdatePicker()"><br>
							<!--<img src="{$IMAGE_PATH}btnL3Calendar.gif" id="jscal_trigger_date_start" >-->
							<font size="1"><em old="(yyyy-mm-dd)">({$DATEFORMAT})</em></font>
							<!--<script type="text/javascript">
                                Calendar.setup ({ldelim}
                                inputField : "jscal_field_date_start", ifFormat : "{$JS_DATEFORMAT}", showsTime : false, button : "jscal_trigger_date_start", singleClick : true, step : 1
                                {rdelim})
							</script>-->
						</td>
						<td>
							<input name="enddate" id="jscal_field_date_end" style="border: 1px solid rgb(186, 186, 186);" size="15" maxlength="10" value="{$ENDDATE_STD}" type="text" onClick="WdatePicker()" class="Wdate"><br>
							<!--<img src="{$IMAGE_PATH}btnL3Calendar.gif" id="jscal_trigger_date_end" >-->
							<font size="1"><em old="(yyyy-mm-dd)">({$DATEFORMAT})</em></font>
			                <!--<script type="text/javascript">
                                Calendar.setup ({ldelim}
                                inputField : "jscal_field_date_end", ifFormat : "{$JS_DATEFORMAT}", showsTime : false, button : "jscal_trigger_date_end", singleClick : true, step : 1
                                {rdelim})
			                </script>-->
						</td>
					</tr>					
					
				</table>
			</div>
		</td>
	</tr>
	<tr>
		<td colspan="2" valign="top">
			{include file='AdvanceFilter.tpl' SOURCE='reports'}
		</td>
	</tr>
</table>