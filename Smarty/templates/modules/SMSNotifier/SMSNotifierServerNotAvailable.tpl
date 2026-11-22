{*<!--
/*+*******************************************************************************
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  *
  *******************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<div style="width: 400px;">

	<form method="POST" action="javascript:void(0);">

	<table width="100%" cellpadding="5" cellspacing="0" border="0" class="layerHeadingULine">
	<tr>
		<td class="genHeaderSmall" width="90%" align="left">Server Not Configured?</td>
		<td width="10%" align="right">
			<a class="icon-homeimg icon-close" href="javascript:;" onclick="SMSNotifierCommon.hideSelectWizard();"></a>
		</td>
	</table>
	
	<table width="95%" cellpadding="5" cellspacing="0" border="0" align="center">
	<tr>
		<td>
		
			<table width="100%" cellpadding="5" cellspacing="0" border="0" align="center" bgcolor="white">
			<tr>
				<td align="left"><strong>We could not find any active server configuration.</strong><br/><br/>
				
					{if $IS_ADMIN}Please review under {$MODULE} Settings.{else}Please contact your administrator.{/if}
									
				</td>			
			</tr>			
			</table>			
		
		</td>
	</tr>
	</table>
	
	<table width="100%" cellpadding="5" cellspacing="0" border="0" class="layerPopupTransport">
	<tr>
		<td class="small" align="center">
			<input type="button" class="cancel" onclick="SMSNotifierCommon.hideSelectWizard();" value="{$APP.LBL_CANCEL_BUTTON_LABEL}"/>
		</td>
	</tr>
	</table>
	
	</form>

</div>