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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>{'EMAIL'|@getFixedLabel}</title>
<!-- diony_ico 2012-12-03   
<link REL="SHORTCUT ICON" HREF="include/images/lingdangcrm_icon.ico">
-->
<style type="text/css">@import url("themes/{$THEME}/style.css");</style>
	<body  onLoad=window.print()>
		<table>
			<tr>
				<td class="lvtCol commonCol" width="15%" height="10px" style="padding: 1px;" align="left"><b>{'FROMMAIL'|@getFixedLabel}:</b></td>
				<td class="dvtCellLabel" style="padding: 1px;">&nbsp;{$FROM_MAIL}</td>
			</tr>
			<tr>
				<td class="lvtCol commonCol" width="15%" height="10px" style="padding: 1px;" align="left"><b>{'TOMAIL'|@getFixedLabel}:</b></td>
				<td class="dvtCellLabel" style="padding: 1px;">&nbsp;{$TO_MAIL}</td>
				
			</tr>
			<tr>
				<td class="lvtCol commonCol" width="15%" height="10px" style="padding: 1px;" align="left"><b>{'CCMAIL'|@getFixedLabel}:</b></td>
				<td class="dvtCellLabel" style="padding: 1px;">&nbsp;{$CC_MAIL}</td>
			</tr>
			   <tr>
				<td class="lvtCol commonCol" style="padding: 1px;" align="left"><b>{'BCCMAIL'|@getFixedLabel}:</b></td>
				<td class="dvtCellLabel" style="padding: 1px;">&nbsp;{$BCC_MAIL}</td>
			</tr>
			<tr>
				<td class="lvtCol commonCol" style="padding: 1px;" align="left"><b>{'MAILTITLE'|@getFixedLabel}:</b></td>
				<td class="dvtCellLabel" style="padding:1px;">&nbsp;{$SUBJECT}</td>
			</tr>
			<tr>
				<td colspan="2" class="dvtCellLabel" style="padding:1px;">&nbsp;{$DESCRIPTION}</td>
			</tr>
	
		</table>
	</body>
</html>