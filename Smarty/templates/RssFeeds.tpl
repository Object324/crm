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
<table width="100%"  border="0" cellspacing="0" cellpadding="0" >
	<tr><td colspan="2" class="mailSubHeader" height=25><b>{$MOD.LBL_FEEDS_LIST} {$TITLE}</b></td></tr>
	<tr class="hdrNameBg">
		<td valign=top height=25><input type="button" name="delete" value=" {$MOD.LBL_DELETE_BUTTON} " class="delete" onClick="DeleteRssFeeds('{$ID}');"/></td>
		<td align="right"><input type="button" name="setdefault" value=" {$MOD.LBL_SET_DEFAULT_BUTTON}  " class="create" onClick="makedefaultRss('{$ID}');"/>
		</td>
	</tr>
	<tr><td colspan="2" align="left"><div id="rssScroll">{$RSSDETAILS}</div></td></tr>
</table>