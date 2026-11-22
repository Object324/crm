{*<!--
/*+*******************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>

<table width="100%" border="0" cellpadding="9" cellspacing="0">
    <tr bgcolor="#F6F6F6">
    	<td colspan="2" class="TabLeftHeard">
			<span>{$MOD.LBL_SCHEDULE_EMAIL}</span>
			{$MOD.LBL_SCHEDULE_EMAIL_DESCRIPTION}
		</td>
	</tr>
	<tr valign="top">
		<td>
			<div>
				<table border="0" cellpadding="5" cellspacing="1" width="100%">
					<tr valign="top">						
						<td width="8%">
						      <strong>{$MOD.LBL_SCHEDULE_REPORT}</strong>
						</td>
						<td>
                            <input type="checkbox" name="isReportScheduled" id="isReportScheduled"
    							{if $IS_SCHEDULED eq 'true'} checked="checked" {/if}/>
                        </td>
					</tr>
                    <tr align="left" valign="top">
						<td valign="top" colspan="2">
                        <strong>{$MOD.LBL_SCHEDULE_FREQUENCY}</strong>
							<span id="scheduledTypeSpan">
								<select name="scheduledType" id="scheduledType" onchange="javascript: setScheduleOptions();">
									<!-- Hourly doesn't make sense on OD as the cron job is running once in 2 hours -->
									<!-- option id="schtype_1" value="1" {if $schtypeid eq 1}selected{/if}>{$MOD.Hourly}</option -->
									<option id="schtype_2" value="2" {if $schtypeid eq 2}selected{/if}>{$MOD.Daily}</option>
									<option id="schtype_3" value="3" {if $schtypeid eq 3}selected{/if}>{$MOD.Weekly}</option>
									<option id="schtype_4" value="4" {if $schtypeid eq 4}selected{/if}>{$MOD.BiWeekly}</option>
									<option id="schtype_5" value="5" {if $schtypeid eq 5}selected{/if}>{$MOD.Monthly}</option>
									<option id="schtype_6" value="6" {if $schtypeid eq 6}selected{/if}>{$MOD.Annually}</option>
								</select>
							</span>
							<span id="scheduledMonthSpan" style="display: {if $schtypeid eq 6}inline{else}none{/if};">&nbsp;<strong>{$MOD.LBL_SCHEDULE_EMAIL_MONTH}</strong>
								<select name="scheduledMonth" id="scheduledMonth">
									{assign var="MONTH_STRINGS" value='MONTH_STRINGS'|@getTranslatedString:'Reports'}
									{foreach key=mid item=month from=$MONTH_STRINGS}
									<option value="{$mid}" {if $schmonth eq $mid}selected{/if}>{$month}</option>
									{/foreach}
								</select>
							</span>

							<!-- day of month (monthly, annually) -->
							<span id="scheduledDOMSpan" style="display: {if $schtypeid eq 5 || $schtypeid eq 6}inline{else}none{/if};">&nbsp;<strong>{$MOD.LBL_SCHEDULE_EMAIL_DAY}</strong>:
								<select name="scheduledDOM" id="scheduledDOM">
									{section name=day start=1 loop=32}
									<option value="{$smarty.section.day.iteration}" {if $schday eq $smarty.section.day.iteration}selected{/if}>{$smarty.section.day.iteration}</option>
									{/section}
								</select>
							</span>

							<!-- day of week (weekly/bi-weekly) -->
							<span id="scheduledDOWSpan" style="display: {if $schtypeid eq 3 || $schtypeid eq 4}inline{else}none{/if};">&nbsp;<strong>{$MOD.LBL_SCHEDULE_EMAIL_DOW}</strong>:
								<select name="scheduledDOW" id="scheduledDOW">
									{assign var="WEEKDAY_STRINGS" value='WEEKDAY_STRINGS'|@getTranslatedString:'Reports'}
									{foreach key=wid item=week from=$WEEKDAY_STRINGS}
									<option value="{$wid}" {if $schweek eq $wid}selected{/if}>{$week}</option>
									{/foreach}
								</select>
							</span>

							<!-- time (daily, weekly, bi-weekly, monthly, annully) -->
							<span id="scheduledTimeSpan" style="display: {if $schtypeid > 1}inline{else}none{/if};">&nbsp;<strong>{$MOD.LBL_SCHEDULE_EMAIL_TIME}</strong>:
								<input type="text" name="scheduledTime" id="scheduledTime" value="{$schtime}" size="5" maxlength="5" /> {$MOD.LBL_TIME_FORMAT_MSG}
							</span>

							<input type="hidden" name="scheduledIntervalString" value="" />
						</td>
					</tr>
                    <tr align="left" valign="top">
						<td colspan="2"><strong>{$MOD.LBL_REPORT_FORMAT}</strong>:</td>
					</tr>
					<tr align="left" valign="top">
						<td valign="top" colspan="2">
							{$MOD.LBL_SELECT}:&nbsp;
							<select id="scheduledReportFormat" name="scheduledReportFormat" class="small">
								<option value="pdf" {if $REPORT_FORMAT eq 'pdf'} selected {/if}>{$MOD.LBL_REPORT_FORMAT_PDF}</option>
								<option value="excel" {if $REPORT_FORMAT eq 'excel'} selected {/if}>{$MOD.LBL_REPORT_FORMAT_EXCEL}</option>
								<option value="both" {if $REPORT_FORMAT eq 'both'} selected {/if}>{$MOD.LBL_REPORT_FORMAT_BOTH}</option>
							</select>
						</td>
					</tr>
                    <tr align="left" valign="top">
						<td valign="top" colspan="2"><strong>{$MOD.LBL_USERS_AVAILABEL}</strong></td>
					</tr>
        			<tr align="left" valign="top">
						<td colspan="2">
							<table width="100%">
								<tr>
									<td width="45%" valign="top">
										{$MOD.LBL_SELECT}:&nbsp;
										<select id="recipient_type" name="recipient_type" class="small" onChange="showRecipientsOptions()">
											<option value="users">{$MOD.LBL_USERS}</option>
											<option value="groups">{$MOD.LBL_GROUPS}</option>
											<option value="roles">{$MOD.LBL_ROLES}</option>
											<option value="rs">{$MOD.LBL_ROLES_SUBORDINATES}</option>
										</select>
										<input type="hidden" name="findStr1" class="small">&nbsp;
									</td>
									<td width="10%">&nbsp;</td>
									<td width="45%"><strong>{$MOD.LBL_USERS_SELECTED}</strong></td>
								</tr>

								<tr>
									<td valign=top>
										<div id="availableRecipientsWrapper">
										</div>
									</td>
									<td align="left">
										<div style="padding-left:10px;">
											<a class="icon-homearr icon-mright" href="javascript:;" onclick=" copySelectedOptionsCustomviewModule('availableRecipients','selectedRecipients');return false;" ></a><br /><br />
											<a class="icon-homearr icon-mleft" href="javascript:;" onclick="copySelectedOptionsCustomviewModule('selectedRecipients','availableRecipients');return false;" ></a>
        								</div>
									</td>
									<td valign="top">
										<select id="selectedRecipients" name="selectedRecipients" multiple size="10" class="crmFormList" ondblclick='addColumnCustomviewModule("selectedRecipients","availableRecipients")'>
										{$SELECTED_RECIPIENTS}
										</select>
										<input type="hidden" name="selectedRecipientsString"/>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					
				</table>
			</div>
		</td>
	</tr>
</table>

<script language="JavaScript" type="text/JavaScript">

function showRecipientsOptions()
{ldelim}
	var option;
	var selectedOption=document.NewReport.recipient_type;

	for(var i=0; i<selectedOption.options.length; i++) {ldelim}
		if (selectedOption.options[i].selected==true) {ldelim}
			option=selectedOption.value;
			break;
		{rdelim}
	{rdelim}

	var availableRecipientsWrapper = document.getElementById('availableRecipientsWrapper');

	if(option == 'users') {ldelim}
		availableRecipientsWrapper.innerHTML = '{$AVAILABLE_USERS}';
	{rdelim} else if(option == 'roles') {ldelim}
		availableRecipientsWrapper.innerHTML = '{$AVAILABLE_ROLES}';
	{rdelim} else if(option == 'rs') {ldelim}
		availableRecipientsWrapper.innerHTML = '{$AVAILABLE_ROLESANDSUB}';
	{rdelim} else if(option == 'groups') {ldelim}
		availableRecipientsWrapper.innerHTML = '{$AVAILABLE_GROUPS}';
	{rdelim}
{rdelim}

function addOption() {ldelim}

	var availableRecipientsObj=getObj("availableRecipients");
	var selectedRecipientsObj=getObj("selectedRecipients");
	
	for (i=0;i<selectedRecipientsObj.length;i++) {ldelim}
		selectedRecipientsObj.options[i].selected=false
	{rdelim}

	for (i=0;i<availableRecipientsObj.length;i++) {ldelim}

		if (availableRecipientsObj.options[i].selected==true) {ldelim}
			var rowFound=false;
			var existingObj=null;
			for (j=0;j<selectedRecipientsObj.length;j++) {ldelim}
				if (selectedRecipientsObj.options[j].value==availableRecipientsObj.options[i].value)
				{ldelim}
					rowFound=true
					existingObj=selectedRecipientsObj.options[j]
					break
				{rdelim}
			{rdelim}

			if (rowFound!=true) {ldelim}
				var newColObj=document.createElement("OPTION")
				newColObj.value=availableRecipientsObj.options[i].value
				if (browser_ie) newColObj.innerText=availableRecipientsObj.options[i].innerText
				else if (browser_nn4 || browser_nn6) newColObj.text=availableRecipientsObj.options[i].text
				selectedRecipientsObj.appendChild(newColObj)
				availableRecipientsObj.options[i].selected=false
				newColObj.selected=true
				rowFound=false
			{rdelim}
			else {ldelim}
				if(existingObj != null) existingObj.selected=true
			{rdelim}
		{rdelim}
	{rdelim}
    return false;
{rdelim}

function delOption() {ldelim}
	var selectedRecipientsObj=getObj("selectedRecipients");
	for (var i=selectedRecipientsObj.options.length; i>0; i--) {ldelim}
			if (selectedRecipientsObj.options.selectedIndex>=0)
				selectedRecipientsObj.remove(selectedRecipientsObj.options.selectedIndex)
	{rdelim}
    return false;
{rdelim}

showRecipientsOptions();
setScheduleOptions();
</script>