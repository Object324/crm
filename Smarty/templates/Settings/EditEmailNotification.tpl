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
{if $NOTIFY_DETAILS.type eq "select"}
<div id="orgLay" class="layerPopup">
<table border=0 cellspacing=0 cellpadding=5 width=100% class=layerHeadingULine>
<tr>
	<td class="layerPopupHeading" align="left">{$NOTIFY_DETAILS.name}</td>
	<td align="right"><a class="icon-homeimg icon-close" href="javascript:hide('editdiv');"></a></td>
</tr>
</table>
<table border=0 cellspacing=0 cellpadding=5 width=95% align=center> 
<tr>
	<td class="small">
	<table border=0 celspacing=0 cellpadding=5 width=100% align=center bgcolor=white>
	<tr>
	<td align="right"  class="cellLabel small" width="40%"><b>{$MOD.LBL_STATUS} :</b></td>
	<td align="left"  class="cellText small" width="60%">
		<select class="small" id="notify_status" disabled>
	{if $NOTIFY_DETAILS.active eq 1}
		<option value="1" "selected">{$MOD.LBL_ACTIVE}</option>
		<option value="0">{$MOD.LBL_INACTIVE}</option>
	{else}
		<option value="1">{$MOD.LBL_ACTIVE}</option>
		<option value="0" "selected">{$MOD.LBL_INACTIVE}</option>
	{/if}
	</select>
</td>
</tr>
<tr><td colspan="2" class="dvInnerHeader"><b>{$MOD.LBL_SELECT_EMAIL_TEMPLATE_FOR}  {$NOTIFY_DETAILS.name}</b></td></tr>
<tr>
<td align="right" class="cellLabel small"><b>{$MOD.LBL_TEMPLATE} : </b></td>
<td align="left"  class="cellText small">
<input type="hidden" id="notifysubject" value="aaaa">
	<select class="small" id="notifybody">

	{foreach from=$VALUES key=k item=v}
		{if $k eq $SEL_ID}
		<option value="{$k}" "selected">{$v}</option>
		{else}
		<option value="{$k}">{$v}</option>
		{/if}
	{/foreach}

	</select>

</td>
</tr>
</table>
</td>
</tr>
</table>
<table border=0 cellspacing=0 cellpadding=5 width=100% class="layerPopupTransport">
<tr>
<td class="small" align="center">
	<input name="save" value=" {$APP.LBL_SAVE_BUTTON_LABEL} " class="save" type="button" onClick="fetchSaveNotify('{$NOTIFY_DETAILS.id}')">
	<input name="cancel" value=" {$APP.LBL_CANCEL_BUTTON_LABEL} " class="cancel" type="button" onClick="hide('editdiv');">
</td>
</tr>
</table>
</div>


	{else}



<div id="orgLay" class="layerPopup">
<table border=0 cellspacing=0 cellpadding=5 width=100% class=layerHeadingULine>
<tr>
	<td class="layerPopupHeading" align="left">{$NOTIFY_DETAILS.name}</td>
	<td align="right"><a class="icon-homeimg icon-close" href="javascript:hide('editdiv');"></a></td>
</tr>
</table>
<table border=0 cellspacing=0 cellpadding=5 width=95% align=center> 
<tr>
	<td class="small">
	<table border=0 celspacing=0 cellpadding=5 width=100% align=center bgcolor=white>
	<tr>
	<td align="right"  class="cellLabel small" width="40%"><b>{$MOD.LBL_STATUS} :</b></td>
	<td align="left"  class="cellText small" width="60%">
	{if $NOTIFY_DETAILS.id neq 7}
		<select class="small" id="notify_status">
	{else}	
		<select class="small" disabled id="notify_status">
	{/if}
	{if $NOTIFY_DETAILS.active eq 1}
		<option value="1" "selected">{$MOD.LBL_ACTIVE}</option>
		<option value="0">{$MOD.LBL_INACTIVE}</option>
	{else}
		<option value="1">{$MOD.LBL_ACTIVE}</option>
		<option value="0" "selected">{$MOD.LBL_INACTIVE}</option>
	{/if}
	</select>
</td>
</tr>
<tr><td colspan="2" class="dvInnerHeader"><b>{$MOD.LBL_EMAIL_CONTENTS}</b></td></tr>
<tr>
<td align="right" class="cellLabel small"><b>{$MOD.LBL_SUBJECT} : </b></td>
<td align="left"  class="cellText small"><input class="txtBox" id="notifysubject" name="notifysubject" value="{$NOTIFY_DETAILS.subject}" size="40" type="text"></td>
</tr>
<tr>
<td align="right"  class="cellLabel small" valign="top"><b>{$MOD.LBL_MESSAGE} : </b></td>
<td align="left"  class="cellText small"><textarea id="notifybody" name="notifybody" class="txtBox" rows="5" cols="40">{$NOTIFY_DETAILS.body}</textarea></td>
</tr>
</table>
</td>
</tr>
</table>
<table border=0 cellspacing=0 cellpadding=5 width=100% class="layerPopupTransport">
<tr>
<td class="small" align="center">
	<input name="save" value=" {$APP.LBL_SAVE_BUTTON_LABEL} " class="save" type="button" onClick="fetchSaveNotify('{$NOTIFY_DETAILS.id}')">
	<input name="cancel" value=" {$APP.LBL_CANCEL_BUTTON_LABEL} " class="cancel" type="button" onClick="hide('editdiv');">
</td>
</tr>
</table>
</div>

{/if}