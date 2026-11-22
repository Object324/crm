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
<link rel="stylesheet" type="text/css" href="{$CSSURL}themes/softed/style.css">
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}modules/{$MODULE}/{$MODULE}.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js"></script>

{*{include file='Buttons_List1.tpl'}*}

{*<!-- Contents -->*}
<table border=0 cellspacing=0 cellpadding=0 width=98% align=center>
     <tr>
        <td valign=top><img src="{'showPanelTopLeft.gif'|@lingdang_imageurl:$THEME}"></td>

	<td class="showPanelBg" valign="top" width=100% style="padding:10px;">
			<table width="100%" border="0" cellpadding="5" cellspacing="0">
				<tr>
					<td class="moduleName" >{'ONTHELOWERLEVEL'|@getFixedLabel}</td>
					<td align="right"><input type="button" class="cancel" onclick="location.href='index.php?action=DetailView&module=Contacts&SearchScope=&parenttab=Parent Accounts&record={$CONTACTID}'" value="{'ASTEP'|@getFixedLabel}" /></td>
				</tr>
			</table>
			
			<div id="ListViewContents">				
			{foreach key=header item=detail from=$CONTACTID_HIERARCHY}
				{if $header eq 'header'}
				<table border=0 cellspacing=1 cellpadding=3 width=100% style="background-color:#eaeaea;" class="small">
					<tr style="height:25px" bgcolor=white>
					{foreach key=header item=headerfields from=$detail}
						<td class="lvtCol commonCol">{$headerfields}</td>
					{/foreach}
					</tr>
				{elseif $header eq 'entries'}
					{foreach key=header item=details from=$detail}
					<tr bgcolor=white>
						{foreach key=header item=listfields from=$details}
						<td>{$listfields}</td>
						{/foreach}
					</tr>
					{/foreach}
				</table>
				{/if}
			{/foreach}
			</div>

     </td>
        <td valign=top><img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}"></td>
   </tr>
</table>