{*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************}
<!--修改编码格式:统一编码：UTF-8-->
{include file="Buttons_List1.tpl"}

<table border=0 cellspacing=0 cellpadding=0 width=98% align=center>
<tr>
	<td valign=top align=right width=8><img src="{'showPanelTopLeft.gif'|@lingdang_imageurl:$THEME}"></td>
	<td class="showPanelBg" valign="top" width="100%" align=center >
	<br><br>
		<table border="0" cellpadding="0" cellspacing="0" width="98%" align="center" class="mailClient mailClientBg">
		<tr>
		<td colspan="4">
			<div style="padding: 20px 10px">
				<table border=0 cellspacing=1 cellpadding=5 width=100% class="lvt small">
				<tr bgcolor=white valign=center>
					<td class="lvtCol commonCol" width="10%"><img src="modules/Integration/res/images/gmail.gif"/></td>
					<td class="lvtColData" width="15%"><a href='{$GMAIL_BOOKMARKLET}'>{$APP.LBL_GMAIL} {$APP.LBL_BOOKMARKLET}</a></td>
					<td class="lvtColData">
						<a href="http://wiki.lingdang.com/index.php/Gmail_Bookmarklet" target="_blank">{$MOD.LBL_HOW_TO_USE} {$APP.LBL_GMAIL} {$APP.LBL_BOOKMARKLET}?</a>
					</td>
				</tr>
				</table>
		</td>
		</tr>
		</table>
	</td>
	<td valign=top align=right width=8><img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}"></td>
</tr>
</table>