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
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset={$APP.LBL_CHARSET}">
	<title>{$MOD.TITLE_LINGDANGCRM_CREATE_REPORT}</title>
	<link href="{$THEME_PATH}style.css" rel="stylesheet" type="text/css"/>
    <link href="{$THEME_PATH}global.css" rel="stylesheet" type="text/css"/>
	<script language="JavaScript" type="text/javascript" src="include/js/general.js"></script>
	<script language="JavaScript" type="text/javascript" src="include/js/{php} echo $_SESSION['authenticated_user_language'];{/php}.lang.js?{php} echo $_SESSION['lingdang_version'];{/php}"></script>
	<script language="javascript" type="text/javascript" src="include/scriptaculous/prototype.js"></script>
	<script language="JavaScript" type="text/javascript" src="modules/Reports/Reports.js"></script>
</head>
<body topmargin="0" leftmargin="0" marginheight="0" marginwidth="0">
<form name="NewRep" method="POST" ENCTYPE="multipart/form-data" action="index.php" style="margin:0px" onSubmit="return changeSteps();">
	<input type="hidden" name="module" value="Reports">
	<input type="hidden" name="primarymodule" value="{$REP_MODULE}">
	<input type="hidden" name="record" value="{$RECORDID}">
	<input type="hidden" name="file" value="NewReport1">
	<input type="hidden" name="action" value="ReportsAjax">

	<table class="CustomTabTop" width="100%" border="0" cellspacing="0" cellpadding="5" >
		<tr>
			<td  width="80%" style="padding-left:20px;">{$MOD.LBL_CREATE_REPORT} </td>
			<td  width="30%" nowrap="nowrap" align="right" style="color:#1E6599;">{$MOD.LBL_CUSTOM_REPORTS}</td>
		</tr>
	</table>
	<table class="CustomTabCenter" width="100%" border="0" cellspacing="0" cellpadding="0" >
		<tr>
			<td width="25%" valign="top" >
				<table class="CustomTabMenu" width="100%" border="0" cellpadding="5" cellspacing="1">
					<tr bgcolor="#F6F6F6"><td id="step1label" class="customTabSelected">1. {$MOD.LBL_REPORT_DETAILS}</td></tr>
					<tr bgcolor="#F6F6F6"><td id="step2label">2. {$MOD.LBL_RELATIVE_MODULE} </td></tr>
					<tr bgcolor="#F6F6F6"><td>3. {$MOD.LBL_REPORT_TYPE} </td></tr>
					<tr bgcolor="#F6F6F6"><td>4. {$MOD.LBL_SELECT_COLUMNS}</td></tr>
					<tr bgcolor="#F6F6F6"><td>5. {$MOD.LBL_SPECIFY_GROUPING}</td></tr>
					<tr bgcolor="#F6F6F6"><td>6. {$MOD.LBL_CALCULATIONS}</td></tr>
					<tr bgcolor="#F6F6F6"><td>7. {$MOD.LBL_FILTERS} </td></tr>
					<tr bgcolor="#F6F6F6"><td>8. {$MOD.LBL_SHARING} </td></tr>
					<tr bgcolor="#F6F6F6"><td>9. {$MOD.LBL_SCHEDULE_EMAIL} </td></tr>
				</table>
			</td>
			<td width="75%" valign="top" >
				<!-- STEP 1 -->
				<div id="step1" style="display:block;">
					<table width="100%" border="0" cellpadding="9" cellspacing="0">
						<tr bgcolor="#F6F6F6">
							<td colspan="2" class="TabLeftHeard">
								<span>{$MOD.LBL_REPORT_DETAILS}</span>
								{$MOD.LBL_TYPE_THE_NAME} &amp; {$MOD.LBL_DESCRIPTION_FOR_REPORT}
							</td>
						</tr>
                        <tr><td></td></tr>
						<tr>
							<td width="25%" align="right"><font style="color:red;">*</font>&nbsp;<b>{$MOD.LBL_REPORT_NAME}  </b></td>
							<td width="75%" align="left"><input type="text" name="reportname" class="txtBoxBor" value="{$REPORTNAME}"></td>
						</tr>
						<tr>
							<td width="25%" align="right"><b>{$MOD.LBL_REP_FOLDER} </b></td>
							<td width="75%" align="left">
								<select name="reportfolder">
								{foreach item=folder from=$REP_FOLDERS}
								{if $FOLDERID eq $folder.id}
									<option value="{$folder.id}" selected>{$folder.name}</option>
								{else}
									<option value="{$folder.id}">{$folder.name}</option>
								{/if}
								{/foreach}
								</select>
							</td>
						</tr>
						<tr>
							<td align="right"valign="top"><b>{$MOD.LBL_DESCRIPTION}</b></td>
							<td align="left"><textarea name="reportdes" class="txtBoxBor" rows="5">{$REPORTDESC}</textarea></td>
						</tr>
					
					</table>
				</div>
				<!-- STEP 2 -->
				<div id="step2" style="display:none;">
					<table border="0" cellpadding="9" cellspacing="0"  width="100%">
						<tr bgcolor="#F6F6F6">
    						<td colspan="2" class="TabLeftHeard">
    							<span>{$MOD.LBL_RELATIVE_MODULE}</span>
    							{$MOD.LBL_SELECT_RELATIVE_MODULE_FOR_REPORT}
    						</td>
						</tr>
						<tr><td colspan="2">{if $RESTRICTEDMODULES neq ''} <div class='dvtCellInfo' style='margin-left: 10px;'>{$MOD.LBL_NOT_ACTIVE}<font color="red"><b> {$RESTRICTEDMODULES} </b></font> </div>{/if}</td>
						</tr>
						<tr valign="top">
							{if $RELATEDMODULES|@count > 0}
								<td align="right" nowrap="nowrap" width="15%"><b>{$MOD.LBL_NEW_REP0_HDR2}</b></td>
								<td align="left">
									<!--select name="secondarymodule" class="txtBoxBor">
									<option value="">--None--</option -->
									<table>
									{foreach name=relmodname item=relmod from=$RELATEDMODULES}
										{if $SEC_MODULE.$relmod eq 1}
											<tr valign='top'>
                                                <td>
                                                <input type='checkbox' name="secondarymodule_{$relmod}" checked value="{$relmod}" />
    												{$relmod|@getTranstab:$relmod}
    											</td>
                                            </tr>
										{else}
                                            <tr valign='top'>
                                                <td>
                                                <input type='checkbox' name="secondarymodule_{$relmod}" value="{$relmod}" />
    												{$relmod|@getTranstab:$relmod}
    											</td>
                                            {if $smarty.foreach.relmodname.iteration mod 3 eq 0}
                                            </tr><tr>
                                            {/if}
                                           
										{/if}
									{/foreach}
									</table>
									<!--/select-->
								</td>
							{else}
								<td align="left" nowrap="nowrap" width="25%"><b>{$MOD.NO_REL_MODULES}</b></td>
							{/if}
						</tr>
						
					</table>
    			</div>
    		</td>
    	</tr>
    </table>

    <br />
    <br />
	<table width="100%" border="0" cellpadding="0" cellspacing="10" class="CustomTabBottom">
		<tr>
			<td align="right" style="padding-right:20px;">
			<input type="button" name="back_rep" id="back_rep" value="{$APP.LBL_BACK}" disabled="disabled" class="cancelauto" style="margin-right:10px;" onClick="changeStepsback();"/>
			<input type="button" name="next" id="next" value="{$APP.LNK_LIST_NEXT}" onClick="changeSteps();" class="saveauto"/>
			<input type="button" name="cancel" value="{$APP.LBL_CANCEL_BUTTON_LABEL}" class="cancelauto" onClick="self.close();"/>
			</td>
		</tr>
	</table>
</form>

</body>
</html>
{if $BACK_WALK eq 'true'}
{literal}
<script>
	hide('step1');
	show('step2');
	document.getElementById('back_rep').disabled = false;
	getObj('step1label').className = 'customTabList';
	getObj('step2label').className = 'customTabSelected';
</script>
{/literal}
{/if}
{if $BACK eq 'false'}
{literal}
<script>
	hide('step1');
	show('step2');
	document.getElementById('back_rep').disabled = true;
	getObj('step1label').className = 'settingsTabList';
	getObj('step2label').className = 'settingsTabSelected';
</script>
{/literal}
{/if}