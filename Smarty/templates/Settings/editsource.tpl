	<input type="hidden" id="referencemodule_1" name="referencemodule_1" value="{$SELECTMODULE}"/>
    <div class="marB10">
    	<table class="D_pop_bod" border="0" cellpadding="1" cellspacing="1">
    		<tr id="">
                <td width="160" align="right" >
                    {'RelateChoiceModule'|@getFixedLabel}
                </td>
                <td align="left">
                <input  type="hidden" name="optionmodule" value="{$SELECTMODULE}"/>
                    <input type="text" class="detailedViewTextBox" style="height: 30px;" name="fieldlabels" disabled="" id="" value="{$SELECTMODULE|@getTranstab}" />
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
                        <select name="approve" class="commonSelectPop detailedViewSelect" style="display: inline-block;">
                            <option value="0" {if $optionvalues.approve_demand eq '0'}selected{/if}>{'NONE'|@getFixedLabel}</option>
                            <option value="1" {if $optionvalues.approve_demand eq '1'}selected{/if}>{'Approved'|@getFixedLabel}</option>
                        </select>
						{*@edit:chj,2022/6/20,reason:ID1000927/页面设置，选择源单增加其他条件，可设置选择源单过滤条件*}
						<div style="margin-left:5px;display: inline-block;" name="approve_condition_set" id="approve_condition_set" >
							<a onclick="get_effective_condition('approve','{$SELECTMODULE}')">{'OtherConditions'|getFixedLabel}</a>
							<input name="approve_advft_criteria_groups" type="hidden" value="{$effectivecondition_arr.approve.advft_criteria_groups}" />
							<input name="approve_advft_criteria" type="hidden" value="{$effectivecondition_arr.approve.advft_criteria}" />
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
                        <option value="1" {if $optionvalues.maxrowsshow eq '1'}selected{/if}>1</option>
                        <option value="5" {if $optionvalues.maxrowsshow eq '5'}selected{/if}>5</option>
                        <option value="10" {if $optionvalues.maxrowsshow eq '10'}selected{/if}>10</option>
                        <option value="15" {if $optionvalues.maxrowsshow eq '15'}selected{/if}>15</option>
                        <option value="20" {if $optionvalues.maxrowsshow eq '20'}selected{/if}>20</option>
                        <option value="50" {if $optionvalues.maxrowsshow eq '50'}selected{/if}>50</option>
                        <option value="100" {if $optionvalues.maxrowsshow eq '100'}selected{/if}>100</option>
                    </select>
                </td>
            </tr>
            {if $FORMMODULE eq 'Singin'}
                <tr>
                    <td align="right">
                        &nbsp;{'VisitingAddressMappingRule'|@getFixedLabel}
                    </td>
                    <td>
                        <select name="signmappingrule" class="commonSelectPop detailedViewSelect" onchange="changeSigninMappingRule(this)">
                            <option value="field" {if $optionvalues.signinmappingrule eq 'field'}selected{/if}>{'ChooseModuleFields'|@getFixedLabel}</option>
                            <option value="sql" {if $optionvalues.signinmappingrule eq 'sql'}selected{/if}>{'SQLQUERY'|@getFixedLabel}</option>
                        </select>
                    </td>
                </tr>
                <tr name="signmappingsql_tr" {if $optionvalues.signinmappingrule neq 'sql'}style="display: none;"{/if} >
                    <td align="right">
                        <b id="showsqlwildcard" style="margin:0 5px;" data-status="hidden" data-childid="sqlwildcard" onclick="showSigninMappingSQLCard()" 
                            data-tip="
                                {'INSTRUCTIONSWILDCARDCHARACTERS'|@getFixedLabel}：<br>
                                1. {'SelectModuleRecordID'|@getFixedLabel}<br>
                                2. {'VisitAddressGetFirstOne'|@getFixedLabel}" data-direction="top" data-type="position" data-tiptype="remain"
                            class="icon-homeimg icon-askgrey-help tip-items-list">
                        </b>
                        {'VisitingAddressMappingSQL'|@getFixedLabel}
                    </td>
                    <td>
                        <textarea name="signmappingsql" class="ld-textarea-inner" style="min-height: 100px;">{if $optionvalues.signinmappingrule eq 'sql'}{$optionvalues.signinmappingcontent}{/if}</textarea>
                    </td>
                </tr>
                <tr id="signinsqlwildcard" style="display: none;color:#888;">
                    <td align="right">{'INSTRUCTIONSWILDCARDCHARACTERS'|@getFixedLabel}</td>
                    <td>1. {'SelectModuleRecordID'|@getFixedLabel}<br>2. {'VisitAddressGetFirstOne'|@getFixedLabel}</td>
                </tr>
                <tr name="signmappingfields_tr" {if $optionvalues.signinmappingrule neq 'field'}style="display: none;"{/if} >
                    <td align="right">
                        <b id="mappingfields_tips" style="margin:0 5px;" data-status="hidden" onclick="" 
                            data-tip="{'VisitAddressMustInclude'|@getFixedLabel}" data-direction="top" data-type="position" data-tiptype="remain"
                            class="icon-homeimg icon-askgrey-help tip-items-list">
                        </b>
                        {'VisitingAddressMappingFields'|@getFixedLabel}
                    </td>
                    <td>
                        <input readonly="readonly" name="signmappingfields" class="advanceTextBox gwidth85 bgwhite ld-input-inner" type="text"
                            {if $optionvalues.signinmappingrule eq 'field'}value="{$optionvalues.signinmappingcontent}"{/if} onclick="setSigninMappingFields()" style="cursor: pointer;">
                        <b onclick="setSigninMappingFields()" data-tip="{'SETTINGS'|@getFixedLabel}" data-direction="top" data-type="position" class="ld-icon-set tip-items-list" style="cursor:pointer;"></b>
                    </td>
                </tr>
            {/if}
            <tr>
    			
                <td align="right">
                    <input name="presence" class="second_switch" type="checkbox"
                        {if $optionvalues.presence eq '0'}
                        checked                          
                        {/if}
                    >
                </td>
                <td align="left">
    				&nbsp;{'ACTIVATE'|@getFixedLabel}
    			</td>
    		</tr>
            
            <tr>						
    			
                <td align="right">
                    <input name="default" class="second_switch" type="checkbox"
                        {if $optionvalues.default eq '1'}
                        checked
                        {/if}
                    >
                </td>
                <td align="left">
    				&nbsp;{'Set_Default'|@getFixedLabel}
    			</td>
    		</tr>
            {* edit: xll 2023/05/08 XUQIU1001203 选择源单 增加“显示超链接”字段属性 *}
            <tr>						
    			
                <td align="right">
                    <input name="ShowHyperlinks" class="second_switch" type="checkbox"
                        {if $optionvalues.ShowHyperlinks eq 'yes'}
                            checked
                        {/if}
                    >
                </td>
                <td align="left">
    				&nbsp;{'SHOWHYPERLINKS'|@getFixedLabel}
    			</td>
    		</tr>
            {if $FORMMODULE eq 'Singin'}
                <tr>
                    <td style="text-align: right;">
                        <input id="uploadwatermark" name="uploadwatermark" class="second_switch" type="checkbox"
                                {if $optionvalues.uploadwatermark eq 'yes'}
                                    checked
                                {/if}
                        >
                    </td>
                    <td align="left">
                        {'UploadWatermark'|@getFixedLabel}
                    </td>
                    
                </tr>
                
                <tr>
                    <td style="text-align: right;">
                        <input id="no_signin" name="no_signin" class="second_switch" type="checkbox"
                                {if $optionvalues.no_signin eq 'yes'}
                                    checked
                                {/if}
                        >
                    </td>
                    <td align="left">
                        {'ExceedErrorRangeNotAllowSign'|@getFixedLabel}{if 'Signout'|@vtlib_isModuleActive eq 1}/{'SIGNOUT2'|@getFixedLabel}{/if}，{'TheErrorIsAllowed'|@getFixedLabel}
                        <select class="btn-radius-system marL10" name="allowable_distance" id="allowable_distance" style="width: 70px;" >
                            <option value="100" {if $optionvalues.allowable_distance eq 100}selected{/if}>100{'metre'|@getFixedLabel}</option>
                            <option value="200" {if $optionvalues.allowable_distance eq 200 || $optionvalues.no_signin eq 'no'}selected{/if}>200{'metre'|@getFixedLabel}</option>
                            <option value="300" {if $optionvalues.allowable_distance eq 300}selected{/if}>300{'metre'|@getFixedLabel}</option>
                            <option value="500" {if $optionvalues.allowable_distance eq 500}selected{/if}>500{'metre'|@getFixedLabel}</option>
                            <option value="800" {if $optionvalues.allowable_distance eq 800}selected{/if}>800{'metre'|@getFixedLabel}</option>
                            <option value="1000" {if $optionvalues.allowable_distance eq 1000}selected{/if}>1000{'metre'|@getFixedLabel}</option>
                            <option value="2000" {if $optionvalues.allowable_distance eq 2000}selected{/if}>2000{'metre'|@getFixedLabel}</option>
                            <option value="3000" {if $optionvalues.allowable_distance eq 3000}selected{/if}>3000{'metre'|@getFixedLabel}</option>
                            <option value="5000" {if $optionvalues.allowable_distance eq 5000}selected{/if}>5000{'metre'|@getFixedLabel}</option>
                            <option value="custom" {if $optionvalues.no_signin eq 'yes' && $optionvalues.allowable_distance neq '100' && $optionvalues.allowable_distance neq '200' && $optionvalues.allowable_distance neq '300' && $optionvalues.allowable_distance neq '500' && $optionvalues.allowable_distance neq '800' && $optionvalues.allowable_distance neq '1000' && $optionvalues.allowable_distance neq '2000' && $optionvalues.allowable_distance neq '3000' && $optionvalues.allowable_distance neq '5000'}selected{/if}>{'custom'|@getFixedLabel}</option>
                        </select>
                                
                        <input {if $optionvalues.allowable_distance neq '100' && $optionvalues.allowable_distance neq '200' && $optionvalues.allowable_distance neq '300' && $optionvalues.allowable_distance neq '500' && $optionvalues.allowable_distance neq '800' && $optionvalues.allowable_distance neq '1000' && $optionvalues.allowable_distance neq '2000' && $optionvalues.allowable_distance neq '3000' && $optionvalues.allowable_distance neq '5000' && $optionvalues.no_signin eq 'yes'}style="width: 50px;height: 30px;"{else}style="width: 50px;display:none;height: 30px;"{/if} type="text" name="custom_allowable_distance" class="detailedViewTextBox" id="custom_allowable_distance" value="{$optionvalues.allowable_distance}" style="width: 50px;">
                    </td>
                    
                </tr>
                {if 'Signout'|@vtlib_isModuleActive eq 1}
                {* 当天有未签退的外勤时，不允许继续签到 *}
                    <tr>
                        <td style="text-align: right;">
                            <input id="nosignout_cantsignin" name="nosignout_cantsignin" class="second_switch" type="checkbox"
                                    {if $optionvalues.nosignout_cantsignin eq 'yes'}
                                        checked
                                    {/if}
                            >
                        </td>
                        <td align="left">
                            {'NoSignoutNotAllowSignin'|@getFixedLabel}
                        </td>
                        
                    </tr>
                    {* 签退是否允许补签 *}
                    <tr>
                        <td style="text-align: right;">
                            <input id="allowsupsignout" name="allowsupsignout" class="second_switch" type="checkbox"
                                    {if $optionvalues.allowsupsignout eq 'yes'}
                                        checked
                                    {/if}
                            >
                        </td>
                        <td align="left">
                            {'IsAllowSupplementarySignout'|@getFixedLabel}
                        </td>
                        
                    </tr>
                {/if}
            {/if}
            <tr {if $productDetailModule eq 'no' } style="display:none"{/if}>
                    
                <td align="right">
                    <input name="withdetail" class="second_switch" type="checkbox" 
                        {if $optionvalues.withdetail eq 'yes'}
                        checked
                        {/if}
                   onclick="SourceBillWithDetail(ld(this))" >
                </td>
                <td align="left">
    				<span style="float: left;">&nbsp;{'AutoWithProductDetail'|@getFixedLabel}</span>
    				<div style="float: left;margin-left:5px;{if $optionvalues.withdetail neq 'yes'}display:none;{/if}" name="withdetail_condition_set" id="withdetail_condition_set" >
						<a onclick="get_effective_condition('withdetail','{$SELECTMODULE}')">{'SetTheSourceEntryDetailsRange'|@getFixedLabel}</a>
						<input name="withdetail_advft_criteria_groups" type="hidden" value="{$effectivecondition_arr.withdetail.advft_criteria_groups}" />
						<input name="withdetail_advft_criteria" type="hidden" value="{$effectivecondition_arr.withdetail.advft_criteria}" />
					</div>
				</td>
            </tr>
            <tr {if $productDetailModule eq 'no' ||$optionvalues.withdetail eq 'no'} style="display:none"{/if} tag="tr_autobalancecolumn">
            <td align="right">
                <input name="autobalancecolumn" class="second_switch" type="checkbox" {if $optionvalues.autobalancevalue neq ''} checked {/if}
                       {if $WithBalanceQtyCondition neq ''}onclick="SourceBillWithBalanceColumn(ld(this))"{/if}>
            </td>
            <td align="left">
				&nbsp;{'AutoGivenBillSourceBalance'|@getFixedLabel}
                <select name="balancecolumn" class="commonSelectPop" {if $WithBalanceQtyCondition neq ''}onchange="WhenSourceSelectQuantity(ld(this));"{/if}>
                {foreach from=$BalacenColumn_arr  item=$balanceinfo}
                <option value="{$balanceinfo.columnname}" {if $balanceinfo.selected eq 'yes'}
                                        selected
                                        {/if}> {$balanceinfo.fieldlabel} </option>
                {/foreach}
                </select>
            </td>
            </tr>

{*            @edit:liushuai,2021-06-05,reason:【ID1001679】带产品分录的表单，选择源单字段->源单类型定制中增加字段属性参数“剩余数量为0时自动带出*}
            {if $WithBalanceQtyCondition neq ''}
            <tr {if $productDetailModule eq 'no' ||$optionvalues.withdetail eq 'no' || $optionvalues.autobalancevalue neq 'quantity' || 1 eq 1} style="display:none"{/if} tag="tr_withbalanceqtycondition2">
                <td align="right">
                    <input name="withbalanceqtycondition" class="second_switch" type="checkbox" {if $optionvalues.withbalanceqtycondition gt 0}checked{/if}  >{*ge 大于等于 gt大于*}
                </td>
                <td align="left">
                    {$WithBalanceQtyCondition}
                </td>
            </tr>
            {/if}

                {foreach from =$StrictSourceBillColumn_arr item=$info}
                    <tr tag="tr_StrictSourceBillColumn" columnname="{$info.columnname}"  {if $optionvalues.withdetail neq 'yes'}  style="display:none"{/if}>
                        
                        <td align="right">
                         <input name="{$info.columnname}" tag="strictsourcechk" class="second_switch" type="checkbox" onclick="change_effective_condition(this)"
                                    {if $optionvalues.withdetail neq 'yes'}
                                    disabled=""
                                    {else}
                                        {if $info.selected eq 'yes'}
                                        checked
                                        {/if}
                                    {/if}
                                >
                        </td>
                        <td align="left">
        				<span style="float: left;">&nbsp;{$info.label}</span>
                        <div style="float: left;margin-left:5px;{if $info.selected neq 'yes'}display:none;{/if}" name="{$info.columnname}_condition_set" id="{$info.columnname}_condition_set" >
                            <a onclick="get_effective_condition('{$info.columnname}','{$SELECTMODULE}')">{'SETEFFECTIVECONDITIONS'|getFixedLabel}</a>
                            <input name="{$info.columnname}_advft_criteria_groups" type="hidden" value="{$info.search_info.advft_criteria_groups}" />
                            <input name="{$info.columnname}_advft_criteria" type="hidden" value="{$info.search_info.advft_criteria}" />
                            
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
                            {if $optionvalues.unallowrepeat eq 'yes'}checked {/if}>
                </td>
                <td align="left">
                    <span name="unallowrepeat_span" style="float: left;">&nbsp;{if $optionvalues.withdetail eq 'yes'}{'UnallowRepeatLabelWithDetail'|@getFixedLabel}{else}{'UnallowRepeatLabelWithNoDetail'|@getFixedLabel}{/if}</span>
                    <span>
                        <b id="askgreyHelp" style="margin:-6px 0 -4px 0;" class="icon-homeimg icon-askgrey-help">
                            <span id="tip_info">{'UnallowRepeatTip'|@getfixedlabel}</span>
                        </b><font color="red"></font>
                    </span>
                </td>
            </tr>
          
        </table>
    </div>
