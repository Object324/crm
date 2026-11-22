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
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/CronTasks/CronTasks.js"></script><br>
<table align="center" border="0" cellpadding="0" cellspacing="0" width="98%">
<tbody><tr>
        <td valign="top"><img src="{'showPanelTopLeft.gif'|@lingdang_imageurl:$THEME}"></td>
        <td class="showPanelBg" style="padding: 10px;" valign="top" width="100%">
		<br>
		<div align=center>
			{include file='SetMenu.tpl'}
			<!-- DISPLAY -->
			<table border=0 cellspacing=0 cellpadding=5 width=100% class="settingsSelUITopLine">
			<tr>
				<td width="50" rowspan="2" valign="top"><img src="{'Cron.png'|@lingdang_imageurl:$THEME}" width="48" height="48" border="0" /></td>
				<td colspan="2" class="heading2" valign=bottom align="left"><b><a href="index.php?module=Settings&action=index&parenttab=Settings">{$MOD.LBL_SETTINGS}</a> > {$MOD.LBL_SCHEDULER} </b></td>
				<td rowspan=2 class="small" align=right>&nbsp;</td>
			</tr>
			<tr>
				<td valign=top class="small" align="left">{$MOD.LBL_SCHEDULER}</td>
			</tr>
			</table>
			<table border=0 cellspacing=0 cellpadding=5 width=100% class="tableHeading">
				<tr><td>&nbsp;</td></tr>
			</table>
			<table width="100%" border="0" cellpadding="5" cellspacing="0" class="listTableTopButtons">
                <tr >
                    <td  style="padding-left:5px;" class="big">{$MOD.LBL_SCHEDULER}</td>
                    <td align="right">&nbsp;</td>
                </tr>
			  </table>

	<div id="notifycontents">
	{include file='modules/CronTasks/CronContents.tpl'}
	</div>
	</td>
	</tr>
	</table>
	</td>
	</tr>
	</table>
	</td>
	</tr>
	</table>

	</div>

</td>
        <td valign="top"><img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}"></td>
   </tr>
</tbody>
</table>
	<div id="editdiv" style="display:none;position:absolute;width:450px;"></div>