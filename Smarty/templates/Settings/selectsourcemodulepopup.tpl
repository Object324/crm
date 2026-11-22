<div class="marB10">
	<table class="D_pop_bod" border="0" cellpadding="1" cellspacing="1">
		<tr id="">
            <td width="160" align="right" >
                {'RelateChoiceModule'|@getFixedLabel}
            </td>
            <td align="left">
                <select name="optionmodule"  onchange="changeOptionModule(this)" class="commonSelectPop" style="width: 90%;">
                {foreach from=$waitingselectmodules item=selectmodule}
                    <option value='{$selectmodule.tabid}'>{$selectmodule.label}</option>
                {/foreach}
                </select>
				<input type="hidden" id="referencemodule_1" name="referencemodule_1" value="{$waitingselectmodules[0]['tabid']}"/>
            </td>
		</tr>
        <tr>
			<td align="right">
				&nbsp;{'ALLOWDataRange'|@getFixedLabel}
			</td>
			<td>
				<select name="datarang" class="commonSelectPop detailedViewSelect">
					<option value="all" {if $optionvalues.datarang eq 'all'}selected{/if}>{'ALL'|@getFixedLabel}</option>
					<option value="permit" {if $optionvalues.datarang eq 'permit'}selected{/if}>{'ALLOWINQUIRE'|@getFixedLabel}</option>
				</select>
			</td>
		</tr>
		{if $optionvalues.approve_status != '-1'}
			<tr>
				<td align="right">
					&nbsp;{'APPROVEDEMAND'|@getFixedLabel}
				</td>
				<td>
					<span style="width: 50%;display: inline-block;">
						<select name="approve" class="commonSelectPop" style="width: 100%;">
							<option value="0" {if $optionvalues.approve_demand eq '0'}selected{/if}>{'NONE'|@getFixedLabel}</option>
							<option value="1" {if $optionvalues.approve_demand eq '1'}selected{/if}>{'Approved'|@getFixedLabel}</option>
						</select>
					</span>
					{*@edit:chj,2022/6/20,reason:ID1000927/ҳ�����ã�ѡ��Դ����������������������ѡ��Դ����������*}
					<div style="display: inline-block;margin-left:5px;" name="approve_condition_set" id="approve_condition_set" >
						<a onclick="create_effective_condition('approve')">{'OtherConditions'|getFixedLabel}</a>
						<input name="approve_advft_criteria_groups" type="hidden" value="" />
						<input name="approve_advft_criteria" type="hidden" value="" />
					</div>
				</td>
			</tr>
		{else}
			<input type="hidden" value="0"  name="option_approve" />
		{/if}
        <tr>
			<td align="right">
				&nbsp;{'MaxRowsShow'|@getFixedLabel}
			</td>
			<td>
				<select name="maxrowsshow" class="commonSelectPop detailedViewSelect">
                    <option value="1">1</option>
					<option value="5" selected>5</option>
					<option value="10">10</option>
                    <option value="15">15</option>
                    <option value="20">20</option>
                    <option value="50">50</option>
                    <option value="100">100</option>
				</select>
			</td>
		</tr>

		{if $frommodule eq 'Singin'}
			<tr>
				<td align="right">
					&nbsp;{'VisitingAddressMappingRule'|@getFixedLabel}
				</td>
				<td>
					<select name="signmappingrule" class="commonSelectPop detailedViewSelect" onchange="changeSigninMappingRule(this)">
						<option value="field">{'ChooseModuleFields'|@getFixedLabel}</option>
						<option value="sql" >{'SQLQUERY'|@getFixedLabel}</option>
					</select>
				</td>
			</tr>
			<tr name="signmappingsql_tr" style="display: none;" >
				<td align="right">
					<b id="showsqlwildcard" style="margin:0 5px;" data-status="hidden" data-childid="sqlwildcard" onclick="showSigninMappingSQLCard()" 
						data-tip="
							{'INSTRUCTIONSWILDCARDCHARACTERS'|@getFixedLabel}：<br>
							1. {'SelectModuleRecordID'|@getFixedLabel}<br>
							2. {'QUERYRESULTRENAMED'|@getFixedLabel}" data-direction="top" data-type="position" data-tiptype="remain"
						class="icon-homeimg icon-askgrey-help tip-items-list">
					</b>
					{'VisitingAddressMappingSQL'|@getFixedLabel}
				</td>
				<td>
					{*wym 240509 屏幕放不下*}
					<textarea name="signmappingsql" class="ld-textarea-inner" {*style="min-height: 100px;"*}></textarea>
				</td>
				
			</tr>
			<tr id="signinsqlwildcard" style="display: none;color:#888;">
				<td align="right">{'INSTRUCTIONSWILDCARDCHARACTERS'|@getFixedLabel}</td>
				<td>1. {'SelectModuleRecordID'|@getFixedLabel}<br>2. {'QUERYRESULTRENAMED'|@getFixedLabel}</td>
			</tr>
			<tr name="signmappingfields_tr" >
				<td align="right">
					<b id="mappingfields_tips" style="margin:0 5px;" data-status="hidden" onclick="" 
						data-tip="{'VisitAddressMustInclude'|@getFixedLabel}" data-direction="top" data-type="position" data-tiptype="remain"
						class="icon-homeimg icon-askgrey-help tip-items-list">
					</b>
					{'VisitingAddressMappingFields'|@getFixedLabel}
				</td>
				<td>
					<input readonly="readonly" name="signmappingfields" class="advanceTextBox gwidth85 bgwhite ld-input-inner" type="text" value="" onclick="setSigninMappingFields()" style="cursor: pointer;">
					<b onclick="setSigninMappingFields()" data-tip="{'SETTINGS'|@getFixedLabel}" data-direction="top" data-type="position" class="ld-icon-set tip-items-list" style="cursor:pointer;"></b>
				</td>
			</tr>
		{/if}

        <tr>
            <td align="right">
                <input name="presence" class="inputBornone second_switch" type="checkbox" checked >
            </td>
            	<td align="left">
				&nbsp;{'ACTIVATE'|@getFixedLabel}
			</td>
		</tr>
        <tr>
			
            <td align="right">
                <input name="default" class="inputBornone second_switch" type="checkbox" {if $optionvalues.default eq '1'} checked {/if}>
            </td>
            <td align="left">
				&nbsp;{'Set_Default'|@getFixedLabel}
			</td>
		</tr>
        
        {* edit: xll 2023/05/08 XUQIU1001203 选择源单 增加“显示超链接”字段属性 *}
        <tr>
            <td align="right">
                <input name="ShowHyperlinks" class="inputBornone second_switch" type="checkbox" >
            </td>
            <td align="left">
				&nbsp;{'SHOWHYPERLINKS'|@getFixedLabel}
			</td>
		</tr>
        
        <tr {if $productDetailModule eq 'no'} style="display:none"{/if}>
            <td align="right">
                <input name="withdetail" class="inputBornone second_switch" type="checkbox" checked onclick="SourceBillWithDetail(ld(this))" >
            </td>
            <td align="left">
				<span style="float: left;">&nbsp;{'AutoWithProductDetail'|@getFixedLabel}</span>
				<div style="float: left;margin-left:5px;" name="withdetail_condition_set" id="withdetail_condition_set" >
					<a onclick="create_effective_condition('withdetail')">{'SetTheSourceEntryDetailsRange'|@getFixedLabel}</a>
					<input name="withdetail_advft_criteria_groups" type="hidden" value="" />
					<input name="withdetail_advft_criteria" type="hidden" value="" />
				</div>
            </td>
        </tr>
        <tr {if $productDetailModule eq 'no'} style="display:none"{/if} tag="tr_autobalancecolumn">
            <td align="right">
                <input name="autobalancecolumn" class="inputBornone second_switch" type="checkbox" checked  >
            </td>
            <td align="left">
				&nbsp;{'AutoGivenBillSourceBalance'|@getFixedLabel}
                <select name="balancecolumn" class="commonSelectPop">
                {foreach from=$BalacenColumn_arr  item=$balanceinfo}
                <option value="{$balanceinfo.columnname}"> {$balanceinfo.fieldlabel} </option>
                {/foreach}
                </select>
            </td>
        </tr>
        {foreach from =$StrictSourceBillColumn_arr item=$info}
            <tr tag="tr_StrictSourceBillColumn" columnname="{$info.columnname}">
                <td align="right">
                    <input name="{$info.columnname}" tag="strictsourcechk" class="inputBornone second_switch" type="checkbox" onclick="change_effective_condition(this);" />
                </td>
                <td align="left">
    				<span style="float: left;">&nbsp;{$info.label}</span>
                    <div style="float: left;margin-left:5px;display:none;" name="{$info.columnname}_condition_set" id="{$info.columnname}_condition_set" >
                        <a onclick="create_effective_condition('{$info.columnname}')">{'SETEFFECTIVECONDITIONS'|getFixedLabel}</a>
                        <input name="{$info.columnname}_advft_criteria_groups" type="hidden" value="" />
                        <input name="{$info.columnname}_advft_criteria" type="hidden" value="" />
                    </div>
                    <span>
            			<b id="askgreyHelp" style="margin:-6px 0 -4px 0;" class="icon-homeimg icon-askgrey-help">
            			<span id="tip_info">{'CONTROLEFFECTIVECONDITIONS'|@getfixedlabel}</span>
            			</b><font color="red"></font>
            		</span>
		      	</td>
            </tr>
        {/foreach}
		{*选择源单 不允许重复*}
		<tr {if $productDetailModule eq 'no' } style="display:none"{/if}>

			<td align="right">
				<input name="unallowrepeat" class="second_switch" type="checkbox"
			</td>
			<td align="left">
				<span name="unallowrepeat_span"  style="float: left;">&nbsp;{'UnallowRepeatLabelWithDetail'|@getFixedLabel}</span>
				<span>
                        <b id="askgreyHelp" style="margin:-6px 0 -4px 0;" class="icon-homeimg icon-askgrey-help">
                            <span id="tip_info">{'UnallowRepeatTip'|@getfixedlabel}</span>
                        </b><font color="red"></font>
                    </span>
			</td>
		</tr>
		{if $frommodule eq 'Singin'}
			<tr>
				<td style="text-align: right;">
					<input id="uploadwatermark" name="uploadwatermark" class="second_switch" type="checkbox">
				</td>
				<td align="left">
					{'UploadWatermark'|@getFixedLabel}
				</td>
				
			</tr>
			
			<tr>
				<td style="text-align: right;">
					<input id="no_signin" name="no_signin" class="second_switch" type="checkbox">
				</td>
				<td align="left" style="align-items: center;display: flex;">
					{'ExceedErrorRangeNotAllowSign'|@getFixedLabel}{if 'Signout'|@vtlib_isModuleActive eq 1}/{'SIGNOUT2'|@getFixedLabel}{/if}，{'TheErrorIsAllowed'|@getFixedLabel}
					<select class="btn-radius-system marL10" name="allowable_distance" id="allowable_distance" style="width: 70px;" onchange="changeSignAllowCustomDistance(this)">
						<option value="100" >100{'metre'|@getFixedLabel}</option>
						<option value="200" >200{'metre'|@getFixedLabel}</option>
						<option value="300" >300{'metre'|@getFixedLabel}</option>
						<option value="500" >500{'metre'|@getFixedLabel}</option>
						<option value="800" >800{'metre'|@getFixedLabel}</option>
						<option value="1000" >1000{'metre'|@getFixedLabel}</option>
						<option value="2000" >2000{'metre'|@getFixedLabel}</option>
						<option value="3000" >3000{'metre'|@getFixedLabel}</option>
						<option value="5000" >5000{'metre'|@getFixedLabel}</option>
						<option value="custom" >{'custom'|@getFixedLabel}</option>
					</select>
					&nbsp;&nbsp;	
					<input style="width: 50px;display:none;height: 30px;" type="text" name="custom_allowable_distance" class="detailedViewTextBox" id="custom_allowable_distance" value="{$optionvalues.allowable_distance}" style="width: 50px;">
				</td>
				
			</tr>
			{if 'Signout'|@vtlib_isModuleActive eq 1}
			{* 当天有未签退的外勤时，不允许继续签到 *}
				<tr>
					<td style="text-align: right;">
						<input id="nosignout_cantsignin" name="nosignout_cantsignin" class="second_switch" type="checkbox">
					</td>
					<td align="left">
						{'NoSignoutNotAllowSignin'|@getFixedLabel}
					</td>
					
				</tr>
				{* 签退是否允许补签 *}
				<tr>
					<td style="text-align: right;">
						<input id="allowsupsignout" name="allowsupsignout" class="second_switch" type="checkbox">
					</td>
					<td align="left">
						{'IsAllowSupplementarySignout'|@getFixedLabel}
					</td>
					
				</tr>
			{/if}
		{/if}
    </table>
</div>