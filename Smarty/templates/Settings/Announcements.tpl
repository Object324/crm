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
{literal}
<script>
function Announcement()
{
	$("an_busy").style.display="inline";
	var announcement=$("announcement").value;

	//Replace & with ##$## and do vice versa in modules/Settings/SettingsAjax.php. if we pass as it is, request of announcement will be skipped after &
	announcement = announcement.replace(/&/g,"##$##");//replace('&','##$##');

	new Ajax.Request(
	'index.php',
        {queue: {position: 'end', scope: 'command'},
       		method: 'post',
	        postBody: 'module=Settings&action=SettingsAjax&announcement='+announcement+'&announce_save=yes',
	        onComplete: function(response) {
					$("announcement").value=trim(response.responseText);
					$("an_busy").style.display="none";
                        	}
	        }
	);
}
</script>
{/literal}

<br>
<table align="center" border="0" cellpadding="0" cellspacing="0" width="98%">
<tbody><tr>
        <td valign="top"><img src="{'showPanelTopLeft.gif'|@lingdang_imageurl:$THEME}"></td>
        <td class="showPanelBg" style="padding: 10px;" valign="top" width="100%">
<br>
	<div align=center>
	
			
				<!-- DISPLAY -->
				<table border=0 cellspacing=0 cellpadding=5 width=100% class="settingsSelUITopLine">
				<tr>
					<td width=50 rowspan=2 valign=top><img src="{'announ.gif'|@lingdang_imageurl:$THEME}" width="48" height="48" border=0></td>
					<td class=heading2 valign=bottom><b><a href="index.php?module=Settings&action=index&parenttab=Settings">{'CONTROLPANEL'|@getFixedLabel}</a> > {'LBL_ANNOUNCEMENT'|@getFixedLabel} </b><div id="an_busy" style="display:none;float:left;position:relative;"><img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" align="right"></div></td>
				</tr>
				<tr>
					<td valign=top class="small">{'LBL_ANNOUNCEMENT_DESCRIPTION'|@getFixedLabel}</td>
				</tr>
				</table>
				
				<br>
				<table border=0 cellspacing=0 cellpadding=10 width=100% >
				<tr>
				<td>
				
					<table border=0 cellspacing=0 cellpadding=5 width=100% class="tableHeading">
					<tr>
						<td class="big"><strong>{'LBL_ANNOUNCEMENT'|@getFixedLabel} </strong></td>
						<td class="small" align=right><input type="button" class="saveauto" value="{'UPDATE'|@getFixedLabel}" onclick="javascript:Announcement();"></td>
					</tr>
					</table>
					
					<table border=0 cellspacing=0 cellpadding=5 width=100% class="listTable">
					<tr>
						<td class="colHeader small" valign=top>{'CLICK_UPDATEBUTTON'|@getFixedLabel}</td>
					  </tr>
					<tr>
						<td>
                        <textarea class=small width=90% height=100px id="announcement" name="announcement">{$ANNOUNCE}</textarea>                        
                        </td>
					  </tr>
					</table>
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
{literal}
<script>
function validate() {
	if (!emptyCheck("server","ftp Server Name","text")) return false
		if (!emptyCheck("server_username","ftp User Name","text")) return false
			return true;

}
</script>
{/literal}