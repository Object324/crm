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
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<link href="{$THEME_PATH}style.css" rel="stylesheet" type="text/css"/>
    <link href="{$THEME_PATH}global.css" rel="stylesheet" type="text/css"/>
	<script language="JavaScript" type="text/javascript" src="include/js/json.js"></script>
	<script language="JavaScript" type="text/javascript" src="include/js/general.js"></script>
	<script language="JavaScript" type="text/javascript" src="include/js/{php} echo $_SESSION['authenticated_user_language'];{/php}.lang.js?{php} echo $_SESSION['lingdang_version'];{/php}"></script>
	<script language="javascript" type="text/javascript" src="include/scriptaculous/prototype.js"></script>
	<script language="JavaScript" type="text/javascript" src="modules/Reports/Reports.js"></script>
	<script type="text/javascript" src="modules/CustomView/CustomView.js"></script>
	<script type="text/javascript">
		var userDateFormat = "{$USER_DATE_FORMAT}";
		var userCurrencySeparator = "{$USER_CURRENCY_SEPARATOR}";
		var userDecimalSeparator = "{$USER_DECIMAL_FORMAT}";
	</script>
</head>
<body topmargin="0" leftmargin="0" marginheight="0" marginwidth="0">
<!-- Master Table -->

<form name="NewReport" method="POST" ENCTYPE="multipart/form-data" action="index.php" style="margin:0px" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name='modulesString' value=''/>
	<input type="hidden" name='primarymodule' value="{$PRI_MODULE}"/>
	<input type="hidden" name='secondarymodule' value="{$SEC_MODULE}"/>
	<input type="hidden" name='record' value="{$REPORT_ID}"/>
	<input type="hidden" name='module' value='Reports'/>
	<input type="hidden" name='reload' value='true'/>
	<input type="hidden" name='action' value='Save'/>
	<input type="hidden" name='file' value=''/>
	<input type="hidden" name='reportName' value="{$REPORT_NAME}"/>
	<input type="hidden" name='reportDesc' value="{$REPORT_DESC}"/>
	<input type="hidden" name='folder' value="{$FOLDERID}"/>
		<!-- Heading -->
	<table class="CustomTabTop" width="100%" border="0" cellspacing="0" cellpadding="5" >
		<tr>
			<td  width="80%" style="padding-left:20px;">{$MOD.LBL_CREATE_REPORT} </td>
			<td  width="30%" nowrap="nowrap" align="right" style="color:#1E6599;">{$MOD.LBL_CUSTOM_REPORTS}</td>
		</tr>
	</table>

	
	<table class="CustomTabCenter" width="100%" border="0" cellspacing="0" cellpadding="0" >
	<tr>
	<td width="25%" valign="top">
	    <table class="CustomTabMenu" width="100%" border="0" cellpadding="5" cellspacing="1">
			<tr bgcolor="#F6F6F6"><td>1. {$MOD.LBL_REPORT_DETAILS}</td></tr>
			<tr bgcolor="#F6F6F6"><td>2. {$MOD.LBL_RELATIVE_MODULE} </td></tr>
			<tr bgcolor="#F6F6F6"><td id="step1label" class="customTabSelected">3. {$MOD.LBL_REPORT_TYPE} </td></tr>
			<tr bgcolor="#F6F6F6"><td id="step2label">4. {$MOD.LBL_SELECT_COLUMNS}</td></tr>
			<tr bgcolor="#F6F6F6"><td id="step3label">5. {$MOD.LBL_SPECIFY_GROUPING}</td></tr>
			<tr bgcolor="#F6F6F6"><td id="step4label">6. {$MOD.LBL_CALCULATIONS}</td></tr>
			<tr bgcolor="#F6F6F6"><td id="step5label">7. {$MOD.LBL_FILTERS} </td></tr>
			<tr bgcolor="#F6F6F6"><td id="step6label">8. {$MOD.LBL_SHARING} </td></tr>
			<tr bgcolor="#F6F6F6"><td id="step7label">9. {$MOD.LBL_SCHEDULE_EMAIL} </td></tr>
		</table>
	</td>
	<td width="75%" valign="top">
		<!-- Step 1 -->
		<div id="step1" style="display:block;">
		
		  {php}include("modules/Reports/ReportType.php");{/php}
		
		</div>

		<!-- Step 2 -->
		<div id="step2" style="display:none;">
		
		  {php}include("modules/Reports/ReportColumns.php");{/php}
			
		</div>

		<!-- Step 3 -->
		<div id="step3" style="display:none;">
		
		  {php}include("modules/Reports/ReportGrouping.php");{/php}
			
		</div>

		<!-- Step 4 -->
		<div id="step4" style="display:none;">
		
		  {php}include("modules/Reports/ReportColumnsTotal.php");{/php}
			
		</div>

		<!-- Step 5 -->
		<div id="step5" style="display:none;">
		
		  {php}include("modules/Reports/ReportFilters.php");{/php}
			
		</div>
        <!-- Step 6 -->
		<div id="step6" style="display:none;">
		
		  {php}include("modules/Reports/ReportSharing.php");{/php}
			
		</div>

		<!-- Step 7 -->
		<div id="step7" style="display:none;">
		
		  {php}include("modules/Reports/ReportsScheduleEmail.php");{/php}
			
		</div>

	</td>
	</tr>
	</table>

					
	<br />
    <br />	
    <table width="100%" cellspacing="10" cellpadding="0" class="CustomTabBottom">
    	<tr>
    		<td align="right" style="padding-right:20px;" >
    		<!--
            edit:cdw
            date:20130801
            reason:0004540: 创建报表界面：按钮“<上一步”和“下一步＞”中的单括号“<”和“＞”格式不一致，望修正
            -->
            
            <input type="button" id="back_rep" name="back_rep" value="{$APP.LBL_BACK}" class="cancelauto" style="margin-right:10px;" onClick="changeStepsback1();"/>
    		<input type="button" id="next" name="next" value="{$APP.LNK_LIST_NEXT}" class="saveauto" onClick="changeSteps1();"/>
    		<input type="button" name="cancel" value="{$APP.LBL_CANCEL_BUTTON_LABEL}" class="cancelauto" onClick="self.close();"/>
    		</td>
    	</tr>
	</table>
</form>

</body>
</html>
<script>
var finish_text = '  {$APP.LBL_FINISH}   '
var next_text = '  {$APP.LNK_LIST_NEXT}  ';
{literal}
setObjects();
hideTabs();
</script>
{/literal}
<script>
{if $BACK_WALK neq 'true'}
	document.getElementById('back_rep').disabled = true;
	var backwalk_flag = false;
{else}
	var backwalk_flag = true;
{/if}
</script>