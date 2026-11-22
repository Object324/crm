<form action="index.php" method="post" name="stepform" id="stepform" onsubmit="return validate_approvestep();puyoungJS_DialogBox.block();">
	<input type="hidden" name="action" value="SaveApproveStep"/>
	<input type="hidden" name="module" value="Settings"/>
	<input type="hidden" name="blockid" value="{$BLOCKID}"/>
    <input type="hidden" name="tabid" value="{$TABID}"/>
	<input type="hidden" name="record" value="{$RECORD}"/>
	<input type="hidden" name="stepid" value="{$STEPID}"/>
	<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
	<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>    
    <input type="hidden" name="advft_criteria_groups"/>
    <input type="hidden" name="advft_criteria"/>
    <div class="ld-ui-tabs">
        <ul class="ld-ui-tabs-nav">
            <li id="thetab1" class="ld-ui-tabs-active" onclick="clicktab(1)">
            	<a href="javascript:;">{'BASICINFO'|@getFixedLabel}</a>
            </li>
			{if $editprofile neq 'no'}
			 <li id="thetab4" onclick="clicktab(4)">
            	<a href="javascript:;">{'approvalrequired'|@getFixedLabel}</a>
            </li>
			{/if}
            <li id="thetab3" onclick="clicktab(3)">
            	<a href="javascript:;">{'APPROVEREMINDS'|@getFixedLabel}</a>
            </li>
			{if $editprofile neq 'no'}
            <li id="thetab2" onclick="clicktab(2)">
            	<a href="javascript:;">{'ADVFEATURES'|@getFixedLabel}</a>
            </li>
			{/if}
        </ul>
        {if 'oem_crm'|@getCommonVersion eq 'no'}
			<a href="javascript:;"  onclick="getLinksUrl('','Settings','EditApproveStep');" style="line-height: 48px;float: right;padding-right: 10px;" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
		{/if}
    </div>
	<div id="countrycontainer1" style="max-height: 450px;">
		<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<th colspan="4">
					{'BASICINFO'|@getFixedLabel}
                    {if $ISUSED eq 'yes'}
                    	<span style="font-size:12px">&nbsp;&nbsp;<font color="red">（{'NOEDITAPPROVESTEP'|@getFixedLabel}）</font></span>
                    {/if}
				</th>
			</tr>
			<tr>
				<td align="right">
				<font color="red">*</font>{'STEPNAME'|@getFixedLabel}  
				</td>
				<td colspan="3" align="left">
					<input type="text" name="stepname" class="detailedViewTextBox" value="{$NAME}" {if $ISUSED eq 'yes'} readonly="" style="background-color:#efefef;"{/if}/>
				</td>
			</tr>
            <tr>
				{if $editprofile neq 'no'}
            	<td align="right">{'CURAPPROVESTEPALLOWEDIT'|@getFixedLabel}</td>
				<td width="30%" align="left">
                    <input name="alloweditbill" class="second_switch" type="checkbox" {if $ALLOWEDITBILL eq 'yes'}checked{/if}
                        {if $ISUSED eq 'yes'} disabled="true" {/if} />
				</td>
				{/if}
				{if $concurrentstepid<=0}
					<td align="right">{'WHETHERAPPROVALPROCESS'|@getFixedLabel}</td>
					<td width="30%" align="left">
						<input name="ended" class="second_switch" type="checkbox" ss="{$ENDED}" {if $ENDED eq 0}checked{/if}
								{if $ISUSED eq 'yes'} disabled="true" {/if} />
					</td>
				{else}
					<td align="right"></td>
					<td width="30%" align="left">
						<input name="ended" type='hidden' value="1">

					</td>
				{/if}
				{if $editprofile eq 'no'}
				<td ></td>
				<td width="30%"></td>
				{/if}
                <tr>
            	<td align="right">{'APPROVEDEFAULTVALUEONAPPROVEREQUIRE'|@getFixedLabel}</td>
				<td width="30%" align="left">
                    <input name="approveremarkrequire" class="second_switch" type="checkbox" {if $approveremarkrequire eq 'yes'}checked{/if} 
                        {if $ISUSED eq 'yes'} disabled="true" {/if}/>
				</td>
                </tr>
			
			<tr>
				<td align="right">
					{'REMARK'|@getFixedLabel}
				</td>
				<td colspan="3">
					<textarea class="txt-cell max-wid" name="description" cols="1" {if $ISUSED eq 'yes'} readonly="" style="background-color:#efefef;"{/if}>{$DESCRIPTION}</textarea>
				</td>
			</tr>
		</table>
        <div id="mnuTab2" class="" style="display: block;">
            {include file="AdvanceFilterCustViewPopup.tpl"}
    	</div>
		<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<th colspan="2">
					{'APPROVERINFO'|@getFixedLabel}
				</th>
			</tr>
			<tr>
				<input type='hidden' name="approve_type" value="{$APPROVETYPE}"/>
				<td align="right" style="width:100px;">{'APPROVERTYPE'|@getFixedLabel}</td>
				<td align="left">
					<select name="approvetype" class="btn-radius-system" {if $ISUSED eq 'yes'} disabled="" style="width:50%;background-color:#efefef;"{else}style="width:50%;"{/if} onchange="getChangeApproveType(this);">
						<option value="0">{'SPECIFYUSER'|@getFixedLabel}</option>
						<option value="1" {if $APPROVETYPE eq 1}selected{/if}>{'SPECIFYROLE'|@getFixedLabel}</option>
						<option value="5" {if $APPROVETYPE eq 5}selected{/if}>{'DATACREATOR'|@getFixedLabel}</option>
						<option value="6" {if $APPROVETYPE eq 6}selected{/if}>{'DATASSIGNEDTO'|@getFixedLabel}</option>
						{foreach key=fieldid item=fieldlabel from=$SELECT_APPRIVE_TYPE}
							<option value="{$fieldid}" uitype="{$SELECT_UITYPE.$fieldid}" {if $APPROVETYPE eq $fieldid}selected{/if}>{'BIll'|@getFixedLabel}{$fieldlabel}</option>
						{/foreach}
						<option value="2" {if $APPROVETYPE eq 2}selected{/if}>{'SPECIFYPROMOTERDEP'|@getFixedLabel}</option>
						<option value="3" {if $APPROVETYPE eq 3}selected{/if}>{'LBL_POSITIONLEVEL'|@getFixedLabel}</option>
						<option value="4" {if $APPROVETYPE eq 4}selected{/if}>{'LBL_POSITIONDEPARTMENT'|@getFixedLabel}</option>
					</select>
				</td>
			</tr>
			{if $APPROVETYPE eq 0}
				{assign var=username_tr value=''}
				{assign var=role_name_tr value='style="display:none;"'}
				{assign var=position_tr value='style="display:none;"'}
				{assign var=positionlevel_tr value='style="display:none;"'}
				{assign var=positiondepartment_tr value='style="display:none;"'}
				{assign var=uservalue value=$APPROVEVALUE}
				{assign var=userid value=$APPROVEBY}
			{elseif $APPROVETYPE eq 1}
				{assign var=username_tr value='style="display:none;"'}
				
				{assign var=role_name_tr value=''}
				{assign var=position_tr value='style="display:none;"'}
				{assign var=positionlevel_tr value='style="display:none;"'}
				{assign var=positiondepartment_tr value='style="display:none;"'}
				{assign var=rolevalue value=$APPROVEVALUE}
				{assign var=roleid value=$APPROVEBY}
			{elseif $APPROVETYPE eq 2}
				{assign var=username_tr value='style="display:none;"'}
				{assign var=role_name_tr value='style="display:none;"'}
				{assign var=position_tr value=''}
				{assign var=positionlevel_tr value='style="display:none;"'}
				{assign var=positiondepartment_tr value='style="display:none;"'}
			{elseif $APPROVETYPE eq 3}
				{assign var=username_tr value='style="display:none;"'}
				{assign var=role_name_tr value='style="display:none;"'}
				{assign var=position_tr value='style="display:none;"'}
				{assign var=positionlevel_tr value=''}
				{assign var=positiondepartment_tr value='style="display:none;"'}
			{else if $APPROVETYPE eq 5 || $APPROVETYPE eq 6 || $APPROVETYPE gt 6}
				{assign var=username_tr value='style="display:none;"'}
				{assign var=role_name_tr value='style="display:none;"'}
				{assign var=position_tr value='style="display:none;"'}
				{assign var=positionlevel_tr value='style="display:none;"'}
				{assign var=positiondepartment_tr value='style="display:none;"'}
			{else}
				{assign var=username_tr value='style="display:none;"'}
				{assign var=role_name_tr value='style="display:none;"'}
				{assign var=position_tr value='style="display:none;"'}
				{assign var=positionlevel_tr value='style="display:none;"'}
				{assign var=positiondepartment_tr value=''}
			{/if}
			<tr id="username_tr" {$username_tr} class="ChangeApprove">
				<td align="right"><font color="red">*</font>{'USERS'|@getFixedLabel}</td>
				<td align="left"><div style="position:relative;">
				<!-- <input type="text" id="userid_name" name="userid_name" readonly="true" value="{$uservalue}" {if $ISUSED eq 'yes'}style="width:50%;background-color:#efefef;"{else} style="width:50%" onclick="approve_selectuser();" {/if}/> -->
				<div id="userid_name" name="userid_name" class="commonTextBoxPop lfloat" style="line-height:29px;padding-left:8px;width:140px;display:-webkit-inline-box;text-overflow:ellipsis;overflow:hidden;">{$uservalue}</div>
				<a class="icon-homeimg icon-select lfloat" href="javascript:;" {if $ISUSED eq 'yes'} style="display:none;"{else} style="margin-top: 7px;"{/if} title="{'SELECT'|@getFixedLabel}" onclick="approve_selectuser();"></a>
				<input type="hidden" name="userid" id="userid" value="{$userid}"/>
					<div id="div_select_user" class="selectUser" style="display:none;position:absolute;left:0px; top:15px;z-index:9999999;width:350px;">
						<div width="100%" cellpadding="0" border="0" cellspacing="0" style="overflow-y:auto;overflow-x: hidden;height:100px;border:1px #ccc solid;background:white;">
							{assign var=count_num value=0}
							{assign var=colum_num value=2}
							<ul style="width:100%;">
							{foreach key=key_one item=arr from=$users_combo}
								{foreach key=sel_value item=value from=$arr}
								   <li style="float:left;width:50%;">
									   <table width="100%" cellspacing="0" cellpadding="0" border="0">
										   <tr>
											<td width="10%">
												{if $value eq 'selected'}
												<input checked="" type="checkbox" name="cb_select_user" onclick="getSelected('userid')" style="border:none;"/>
												{else}
												<input type="checkbox" name="cb_select_user" onclick="getSelected('userid')" style="border:none;" />
												{/if}
											</td>
											<td>
												<span id="sp_user_{$count_num}" style="text-aligna:left;">{$sel_value}</span>
												<input id="txt_user_{$count_num++}" type="hidden" value="{$key_one}"/>
											</td>
										   </tr>
									   </table>
								   </li>                         
								{/foreach}
							{/foreach}
							</ul>
						</div>
					</div>
					{*end*} 
					</div>        
				</td>
			</tr>
          
		
			<tr id="position_tr" {$position_tr} class="ChangeApprove">
				<td align="right"><font color="red">*</font>{'POSITIONLEVEL'|@getFixedLabel}</td>
				<td align="left">
					<select name="position" class="btn-radius-system">
						{foreach key=key item=item from=$USERLEVELARR}
							<option value="{$key}" {if $APPROVEVALUE == $key} selected{/if}
							>{$item}</option>
						{/foreach}
					</select>
					<span class="greyFont9">{'MANAGEMENTPOSITIONLEVEL'|@getFixedLabel}</span>
				</td>
			</tr>
  	         <tr id="role_name_tr" {$role_name_tr} class="ChangeApprove">
				<td align="right" style="width:100px;"><font color="red">*</font>{'ROLES'|@getFixedLabel}</td>
				<td align="left">
					<input type="text" name="role_name" id="role_name" readonly="true" style="width:50%" value="{$rolevalue}" onclick="selectPopupProfile('user_role','{'ROLES'|@getFixedLabel}')"/>
					<input type="hidden" name="user_role" id="user_role" value="{$roleid}"/>
					<a class="icon-homeimg icon-select" href="javascript:selectPopupProfile('user_role','{'ROLES'|@getFixedLabel}');"></a>
				</td>
			</tr>
			<tr id="positionlevel_tr" {$positionlevel_tr} class="ChangeApprove">
				<td align="right"><font color="red">*</font>{'POSITIONLEVEL'|@getFixedLabel}</td>
				<td align="left">
					<select name="positionlevel" class="btn-radius-system">
						{foreach key=key item=item from=$USERLEVELARR}
							<option value="{$key}" {if $APPROVEVALUE == $key} selected{/if}
							>{$item}</option>
						{/foreach}
					</select>
					<span class="greyFont9">{'MANAGEMENTPOSITIONLEVEL'|@getFixedLabel}</span>
				</td>
			</tr>
			<tr id="positiondepartment_tr1" {$positiondepartment_tr} class="ChangeApprove">
				<td align="right"><font color="red">*</font>{'Sector'|@getFixedLabel}</td>
				<td align="left">
					
                    <input  type="hidden" name="positiondepartment1" value="{$APPROVEARRAY[0]}"/>
				</td>
			</tr>
			<tr id="positiondepartment_tr2" {$positiondepartment_tr} class="ChangeApprove">
				<td align="right"><font color="red">*</font>{'POSITIONLEVEL'|@getFixedLabel}</td>
				<td align="left">
					<select name="positiondepartment2" class="btn-radius-system">
						{foreach key=key item=item from=$USERLEVELARR}
                            {if $APPROVEARRAY[1]|@is_string neq false && $APPROVEARRAY[1]|@html_entity_decode eq $key|@html_entity_decode}
    							<option value="{$key}" selected="">{$item}</option>
                            {else}
                                <option value="{$key}">{$item}</option>
                            {/if}
						{/foreach}
					</select>
					<span class="greyFont9">{'MANAGEMENTPOSITIONLEVEL'|@getFixedLabel}</span>
				</td>
			</tr>
            <tr name='when_approver_empty' {if $SHOWEMPTYSET neq 'yes'}style="display:none;"{/if}>
                <td align="right">{'WHENAPPROVERISEMPTY'|@getFixedLabel}</td>
                <td align="left" style="line-height: 180%;padding:5px 10px;">
                    <div style="font-size:14px;"><input  type="radio" onclick="emptyapproverdeal(this,event)" name="autopass" tag='emptyapproverdeal' id="AUTOMATICPASS" {if $EMPTYAPPROVERDEAL eq 'autopass'}checked=""{/if} {if $ISUSED eq 'yes'} disabled=""{/if} />
						<label for="AUTOMATICPASS">{'AUTOMATICPASS'|@getFixedLabel}</label><b class="icon-homeimg icon-askgrey-help" style="margin-left: 5px;" title="{'AUTOMATICPASSDESC'|@getFixedLabel}"></b></div>
                    <div style="font-size:14px;"><input  type="radio" onclick="emptyapproverdeal(this,event)" name="transfertomanager" tag='emptyapproverdeal' id="AUTPFORWARDTOADMIN" {if $EMPTYAPPROVERDEAL eq 'transfertomanager'||$EMPTYAPPROVERDEAL eq ''}checked=""{/if} {if $ISUSED eq 'yes'} disabled=""{/if} />
						<label for="AUTPFORWARDTOADMIN">{'AUTPFORWARDTOADMIN'|@getFixedLabel}</label><b class="icon-homeimg icon-askgrey-help" style="margin-left: 5px;" title="{'AUTPFORWARDTOADMINDESC'|@getFixedLabel}"></b></div>
                    <div style="font-size:14px;"><input  type="radio" onclick="emptyapproverdeal(this,event)" name="transfertouser" tag='emptyapproverdeal' id="SPECIFYUSER" {if $EMPTYAPPROVERDEAL eq 'transfertouser'}checked=""{/if} {if $ISUSED eq 'yes'} disabled=""{/if} />
						<label for="SPECIFYUSER">{'SPECIFYUSER'|@getFixedLabel}</label>{'APPROVAL'|@getFixedLabel}<b class="icon-homeimg icon-askgrey-help" style="margin-left: 5px;" title="{'AUTPFORWARDTOUSERDESC'|@getFixedLabel}"></b></div>
                </td>
            </tr>
            <tr name="transferusername_tr" class="ChangeApprove" {if $SHOWEMPTYSET eq 'yes' && $EMPTYAPPROVERDEAL eq 'transfertouser'}{else}style="display:none;"{/if} >
				<td align="right"><font color="red">*</font>{'USERS'|@getFixedLabel}</td>
				<td align="left"><div style="position:relative;">
				<div id="transfer_userid_name" name="transfer_userid_name" class="commonTextBoxPop lfloat" style="line-height:29px;padding-left:8px;width:140px;display:-webkit-inline-box;text-overflow:ellipsis;overflow:hidden;">{$TRANSFERUSERVALUES}</div>
				<a class="icon-homeimg icon-select lfloat" href="javascript:;" {if $ISUSED eq 'yes'} style="display:none;"{else} style="margin-top: 7px;"{/if} title="{'SELECT'|@getFixedLabel}" onclick="transfer_approve_selectuser();"></a>
				<input type="hidden" name="transfer_userid" id="transfer_userid" value="{$TRANSFERUSERIDS}"/>
					<div id="div_select_user" class="selectUser" style="display:none;position:absolute;left:0px; top:15px;z-index:9999999;width:350px;">
						<div width="100%" cellpadding="0" border="0" cellspacing="0" style="overflow-y:auto;overflow-x: hidden;height:100px;border:1px #ccc solid;background:white;">
							{assign var=count_num value=0}
							{assign var=colum_num value=2}
							<ul style="width:100%;">
							{foreach key=key_one item=arr from=$TRANSFERUSERINFO}
								{foreach key=sel_value item=value from=$arr}
								   <li style="float:left;width:50%;">
									   <table width="100%" cellspacing="0" cellpadding="0" border="0">
										   <tr>
											<td width="10%">
												{if $value eq 'selected'}
												<input checked="" type="checkbox" name="cb_select_user" onclick="getSelected('userid')" style="border:none;"/>
												{else}
												<input type="checkbox" name="cb_select_user" onclick="getSelected('userid')" style="border:none;" />
												{/if}
											</td>
											<td>
												<span id="sp_user_{$count_num}" style="text-aligna:left;">{$sel_value}</span>
												<input id="txt_user_{$count_num++}" type="hidden" value="{$key_one}"/>
											</td>
										   </tr>
									   </table>
								   </li>                         
								{/foreach}
							{/foreach}
							</ul>
						</div>
					</div>
					{*end*} 
					</div>        
				</td>
			</tr>
              <tr name="tr_countersigner" {if $APPROVETYPE eq '5'||$APPROVETYPE eq '6'||($APPROVETYPE gt '6' && $SELECT_UITYPE.$APPROVETYPE !=154)||$RECORD<=0||($ApproveValuelength<=1&&$APPROVETYPE eq 0)} style="display:none"{/if}>
              <td align="right" style="width:100px;"></td>
                <td align="left" style="line-height: 150%;padding:5px 10px;">
               
					<div><input  type="radio" onclick="countersignerclick(ld(this),event)"  {if $ISUSED eq 'yes'} disabled=""{/if} value="no" name="countersigner" {if $countersigner eq 'no'} checked=""{/if} id="countersigner_one"/><label for="countersigner_one">{'MultipleapproversOne'|@getFixedLabel}</label></div>
					<div><input  type="radio" onclick="countersignerclick(ld(this),event)"  {if $ISUSED eq 'yes'} disabled=""{/if} value="yes" name="countersigner" {if $countersigner eq 'yes'} checked=""{/if} id="countersigner_ature"/><label for="countersigner_ature">{'MultipleCountersignature'|@getFixedLabel}</label></div>
                </td>
            
            </tr>
            <tr id="username_tr2" class="ChangeApprove" >
				<td align="right">{'specifytheapproval'|@getFixedLabel}</td>
				<td align="left">
                    <input name="selectapproveuser" class="second_switch" type="checkbox" {if $SPECIFYAPPROVERID eq 1 || $SPECIFYAPPROVERID eq ''}{else}checked{/if} 
                        {if $ISUSED eq 'yes'} disabled="true" {/if} />
				</td>
			</tr>
			<tr id="addapprovers_tr2" class="ChangeApprove" >
				<td align="right">{'Isitallowedtoaddapproversincurrentstep'|@getFixedLabel}</td>
				<td align="left">
                    <input name="is_augmentsinger" class="second_switch" type="checkbox" {if $augmentsinger eq ''}{else}checked{/if} 
                        onclick="augmentsingerclick(ld(this),event)" {if $ISUSED eq 'yes'} disabled="true" {/if}/>
				</td>
			</tr>
			<tr name="tr_augmentsinger" {if $augmentsinger neq 'yes' && $augmentsinger neq 'no'} style="display:none"{/if}>
              <td align="right" style="width:100px;"></td>
                <td align="left" style="line-height: 150%;padding:5px 10px;">
					<div><input  type="radio"  {if $ISUSED eq 'yes'} disabled=""{/if} value="no" name="augmentsinger" {if $augmentsinger eq 'no' || $augmentsinger eq ''} checked=""{/if} id="augmentsinger_one" /><label for="augmentsinger_one">{'MultipleapproversOne'|@getFixedLabel}</label></div>
					<div><input  type="radio"  {if $ISUSED eq 'yes'} disabled=""{/if} value="yes" name="augmentsinger" {if $augmentsinger eq 'yes'} checked=""{/if} id="augmentsinger_ature" /><label for="augmentsinger_ature">{'MultipleCountersignature'|@getFixedLabel}</label></div>
                </td>
            
            </tr>
		</table>
		<table class="settingPopTable lasttdbordernon" name="table_nextstep" {if $concurrentstepid>0} style="display:none"{/if} border="0" cellpadding="0" cellspacing="0" width="100%" {if $countersigner eq 'yes'} style="display:none"{/if}>
			<tr>
				<th colspan="2">
					{'NEXTEXAMINATIONANDAPPROVALCONTROL'|@getFixedLabel}
				</th>
			</tr>
            
			<tr>
				<td width="30%" align="right">
					{'editingprocessd'|@getFixedLabel}
				</td>
				<td width="70%" align="left">
					<input name="step" class="second_switch" type="checkbox" {if $STEP eq 0}checked{/if} {if $ISUSED eq 'yes'||$concurrentstepid>0} disabled="true" {/if} />
				</td>
			</tr>
			
		</table>
	</div>
	{*editor:gyq_05  reason:新增审批通知  date:2016 2 23*}
	<div id="countrycontainer3" style="max-height: 450px;display:none;">
		{$REMINDHTML}
	</div>
	<div id="countrycontainer2" style="max-height: 450px;display:none;">
	   <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<th colspan="2">
					{'DYNAMICASSIGNMENT'|@getFixedLabel}
				</th>
			</tr>
			<tr>
				<td align="right" width="100">
					{'PASS'|@getFixedLabel}
				</td>
				<td align="left">
                	<input type='hidden' value='{$PASS.0.modulestatus}' id="hiddenpassvalue"/> 
					<select id="pass" name="pass" class="btn-radius-system" onchange="passStatus(this,'{$BLOCKNAME}')">
						<option value="">{'NONE'|@getFixedLabel}</option>
						{foreach from=$PICKLIST  item=transname key=columnname }
	                        {if $PASS.0.pickcolumnname eq $columnname}
	                            <option  value='{$columnname}' selected="">{$transname}</option>
	                        {else}
							    <option  value='{$columnname}'>{$transname}</option>
	                        {/if}
						{/foreach}
					</select>
					   = 
					<select name="passvalue" id="passvalue" class="btn-radius-system">
					
					</select>
				</td>
			</tr>
		    <tr>
				<td align="right">
					{'NOTPASS'|@getFixedLabel}
				</td>
				<td align="left">
	                <input type='hidden' value='{$PASS.1.modulestatus}' id="hiddennopassvalue"/> 
					<select id="nopass" name="nopass" class="btn-radius-system" onchange="passStatus(this,'{$BLOCKNAME}');">
						<option value="">{'NONE'|@getFixedLabel}</option>
						{foreach from=$PICKLIST  item=transname key=columnname  }
							 {if $PASS.1.pickcolumnname eq $columnname}
	                            <option  value='{$columnname}' selected="">{$transname}</option>
	                        {else}
							    <option  value='{$columnname}'>{$transname}</option>
	                        {/if}
						{/foreach}  
					</select>
					   = 
					<select name="nopassvalue" id="nopassvalue" class="btn-radius-system">
						
					</select>
				</td>
			</tr>             
		</table>               
   </div>
	<div id="countrycontainer4" style="max-height: 450px;display:none;min-height: 400px;">
		{*
		<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<th colspan="4">
					{'settherequiredfieldsofapprover'|@getFixedLabel}
				</th>
			</tr>
			{foreach from=$ALL_MODULE_FIELDS  item=fieldarray}
			 <tr>
				{foreach from=$fieldarray  item=fieldinfo}
					{assign var="kk" value=0}
					{foreach item=fldname from=$MODULE_FIELDS}
						{if $fldname eq $fieldinfo.fieldname}
								{assign var="kk" value=1}
						{/if}
					{/foreach}
					<td align="left"><input type="checkbox" name="module_fldname" value="{$fieldinfo.fieldname}" id="{$fieldinfo.fieldname}" {if $kk eq 1}checked{/if}>&nbsp;&nbsp;<label for="{$fieldinfo.fieldname}">{$fieldinfo.fieldlabel}</label></td>
				{/foreach}
			</tr>
			{/foreach}
		</table>
		*}
	</div>
   
</form>