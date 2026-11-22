{****************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License.txt"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ******************************************************************************
*}
<!--修改编码格式:统一编码：UTF-8-->
<div id="lingdangHelpWelcomePopupLay" style="display:none;width:700px;box-shadow: 5px 8px 10px #777777;" class="lingdangHelpWelcomePopupLay">
	<table class="layerHeadingULine hdrTabBg" width="100%" cellpadding="5" cellspacing="0" width="100%" border="0" >
	<tr valign="top">
		<td class="genHeaderSmall">
			Getting started
		</td>
		<td align="right">
			<a href="javascript:;" onclick='$("lingdangHelpWelcomePopupLay").style.display="none";puyoungJS_DialogBox.unblock();'><img src="{'help_close_black.png'|@lingdang_imageurl:$THEME}" border="0" align="absmiddle" width="13px" heigth="13px" style="padding-right:2px;"></a>
		</td>
	</tr>
	</table>
	<table width="100%" cellpadding="5" cellspacing="0" border="0">
	<tr>
		<td colspan="2">
			<div id="lingdangHelpWelcomePopupContent" class="lingdangHelpPopupLay">
				<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}">
			</div>
		</td>
	</table>
        <div id="lingdangHelpWelcomeGTranslateEl"></div>
</div>

{literal}
<script type="text/javascript">
Event.observe(window, 'load', function(){
	if (typeof lingdang_help_welcome == 'function') {
		lingdang_help_welcome($('lingdangHelpWelcomePopupLay'), $('lingdangHelpWelcomePopupContent'));
	}
});
</script>
{/literal}
