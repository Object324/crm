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
<table width="100%" border="0" cellpadding="9" cellspacing="0">
	<tbody>
    <tr bgcolor="#F6F6F6">
		<td colspan="2" class="TabLeftHeard">
			<span>{$MOD.LBL_REPORT_TYPE}</span>
			{$MOD.LBL_SELECT_REPORT_TYPE_BELOW}
		</td>
	</tr>
	<tr>
    	<td rowspan="2" align="right" width="25%">
    	   <img src="{'tabular.gif'|@lingdang_imageurl:$THEME}" align="absmiddle">
    	</td>
    	<td align="left" height="50" valign="bottom" width="75%">
        	{if $REPORT_TYPE eq 'tabular'}
        	<input checked type="radio" name="reportType" id="reportType" value="tabular" onChange="hideTabs()">
        	{else}
        	<input type="radio" name="reportType" id="reportType" value="tabular" onChange="hideTabs()">
        	{/if}
        	<b> {$MOD.LBL_TABULAR_FORMAT}</b>
        </td>
	</tr>
    <tr>
        <td align="left" valign="top" width="75%">
    	 {$MOD.LBL_TABULAR_REPORTS_ARE_SIMPLEST}	
    	</td>
	</tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr>
    	<td rowspan="2" align="right" width="25%">
        	<img src="{'summarize.gif'|@lingdang_imageurl:$THEME}" align="absmiddle">
        	</td>
        	<td style="padding-left: 5px;" align="left" height="50" valign="bottom" width="75%">
        	{if $REPORT_TYPE eq 'summary'}
        	<input type="radio" checked name="reportType" value="summary" onclick="hideTabs()">
        	{else}
        	<input type="radio" name="reportType" value="summary" onclick="hideTabs()">
        	{/if}
        	<b> {$MOD.LBL_SUMMARY_REPORT}</b>
        </td>
	</tr>
    <tr>
        <td align="left" valign="top" width="75%">
    	 {$MOD.LBL_SUMMARY_REPORT_VIEW_DATA_WITH_SUBTOTALS}
    	</td>
	</tr>
	</tbody>
</table>