<link type="text/css" href="{$CSSURL}themes/softed/coordination.css" rel="stylesheet" />
{literal}
<style type="text/css">
.pad{
	padding-left:10px;
}
.select2-container{
    display:inline;
}
.select2-container .select2-selection--multiple{
    height:36px;
    min-width:150px;
}
.select2-container--default .select2-selection--multiple .select2-selection__choice{
  margin: 3px;
}
.select2-container--open .select2-dropdown--below{
  width: 150px !important;
}
.select2-container {
  position: relative !important;
  top: 0px !important;
  left: 8px !important; 
}
</style>

{/literal}

<form action="index.php" method="post" name="save_public_account" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Leads"/>
	<input type="hidden" name="action" value="LeadsAjax"/>
	<input type="hidden" name="file" value="savePublicLeads"/>
	<input type="hidden" name="advft_criteria_groups"/>
	<input type="hidden" name="advft_criteria"/>
	<input type="hidden" name="before_status" value ="{$BEFORE_STATUS}"/>

	{*	//ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（弹窗页面）*}
	<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
			<td class="PublicTitle" width="100%">{'maximumnumberofleads'|@getFixedLabel}</td>
		</tr>
		<tr>
			<td class="pad paddT10" width="40%">
				<div style="margin-top: 15px;margin-left: 20px;margin-bottom: 20px;">
					<label><input type="radio" style="margin-top: -3px;" class="inputBornone" name="limit_type" {if $DATA.limit_type eq ''} checked="checked" {/if} value=""/>
					{'NOLIMITS'|@getFixedLabel}</label>
				</div>

				<div style="margin-top: 15px;margin-left: 20px;margin-bottom: 20px;">
					<label><input type="radio" style="margin-top: -3px;" class="inputBornone" name="limit_type" {if $DATA.limit_type eq 'user'} checked="checked" {/if} value="user"/>
					{'Accordingtotheusercontrol'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'Eachuser'|@getFixedLabel}&nbsp;</label>
					<input id='limit_count' type="text"  class="btn-radius-system input-btn-align" {if $DATA.limit_type eq 'user'}{else}disabled = true{/if} name="limit_count" label="{'Leads'|getTranstab}" style="width:50px;text-align:center;" value="{$DATA.limit_count}"/>
				</div>

				<div style="margin-top: 15px;margin-left: 20px;margin-bottom: 20px;">
					<label><input type="radio" style="margin-top: -3px;" class="inputBornone" name="limit_type" {if $DATA.limit_type eq 'role'} checked="checked" {/if} value="role"/> {'Accordingtotherolcontrol'|@getFixedLabel}</label>
				</div>
				<div style="margin-top: 15px;margin-left: 20px;margin-bottom: 20px;padding-left:10px;display:{if $DATA.limit_type eq 'role'}{else}none{/if}" name='select_limit_type_role' >
					<table class='ControlTable1 listEntries' border=0 cellspacing=1 cellpadding=5 width=100%>
						<tr>
							<th width='70%' title="{'ROLES'|@getFixedLabel}">{'ROLES'|@getFixedLabel}</th>
							<th width='30%' title="{'Themaximumnumberofleads'|@getFixedLabel}">{'Themaximumnumberofleads'|@getFixedLabel}</th>
						</tr>
						{foreach key=role_id item=role_info from=$COMMONACCOUNBT_ROLE_LIMITCOUNT}
							<tr bgcolor='white'>
								<td nowrap><span title='{$role_info.role_name}'>{$role_info.role_name}</span></td>
								<td>
									<input  name="txtbox_role_count[]" roleid={$role_id} class="detailedViewTextBox" style="width:150px;float:left;" type="text" value="{$role_info.limit_count}" maxlength="100">
									<input name="txtbox_roleid[]" value="{$role_id}" type="hidden" />
								</td>
							</tr>
						{/foreach}
					</table>
				</div>
			</td>
		</tr>
		<tr>
			<td class="pad paddT10">
				<p style="margin-left: 10px;margin-bottom: 10px;color: red;">{'CreateMaximumnumberofLeadsTip'|@getFixedLabel}</p>
			</td>
		</tr>
		</tbody>
	</table>

	<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>
			<tr>
				<td class="PublicTitle" width="100%"> {'PUBLICCUSTOMERSET'|@getFixedLabel}</td>
			</tr>
			<tr>
				<td class="pad paddT10" width="40%">
					<div style="margin-top: 15px;margin-left: 20px;margin-bottom: 20px;">
						<label><input type="checkbox" name="status" {if $DATA['status'] eq 'yes'}checked{/if} >&nbsp;&nbsp;{'ACTIVATEPUBLICCUST'|@getFixedLabel}</label>
					</div>
					<div {if $DATA['status'] neq 'yes'}style="margin-bottom: 20px;margin-left: 20px;display:none;"{else}style="margin-bottom: 20px;margin-left: 20px;"{/if} name="div_show_publicaccount_tab">
						<label><input type="checkbox" name="show_publicaccount_tab" {if $DATA['show_publicaccount_tab'] eq 'yes'}checked{/if} >&nbsp;&nbsp;{'Showtheallincludeunassignedtab'|@getFixedLabel}</label>
					</div>
					<!--
					<div {if $DATA['show_publicaccount_tab'] neq 'yes'}style="margin-bottom: 15px;margin-left: 20px;display:none;"{else}style="margin-bottom: 15px;margin-left: 20px;"{/if} name="div_default_publicaccount_tab">
						<input type="checkbox" name="default_publicaccount_tab"  {if $DATA['default_publicaccount_tab'] eq 'yes'}checked{/if} >&nbsp;&nbsp;{'Setthedefaulttabasallincludeunassigned'|@getFixedLabel}
					</div>
					-->
					<div {if $DATA['status'] neq 'yes'}style="margin-bottom: 15px;margin-left: 20px;display:none;"{else}style="margin-bottom: 15px;margin-left: 20px;"{/if} name="div_show_commonaccount_tab">
						<label><input type="checkbox" name="show_commonaccount_tab"  {if $DATA['show_commonaccount_tab'] neq 'no'}checked{/if} >&nbsp;&nbsp;{'Showtheallincludecommonaccounttab'|@getFixedLabel}</label>
					</div>
					<div {if $DATA['status'] neq 'yes'}style="margin-bottom: 15px;margin-left: 20px;display:none;"{else}style="margin-bottom: 15px;margin-left: 20px;"{/if} name="div_is_commonaccount_create">
						<label><input type="checkbox" name="is_commonaccount_create"  {if $DATA['is_commonaccount_create'] neq 'no'}checked{/if} >&nbsp;&nbsp;{'AllowNewCommonLead'|@getFixedLabel}</label>
					</div>
{*					ls 2021-09-06 【ID1001938】销售线索和客户模块，多公海“全部”页签增加默认值显示*}
					<div {if $DATA['status'] neq 'yes'}style="margin-bottom: 15px;margin-left: 20px;display:none;"{else}style="margin-bottom: 15px;margin-left: 20px;"{/if} name="div_show_default_tab">
						{'SetDefaultTab'|@getFixedLabel}&nbsp;&nbsp;
						<select name="set_default_tab" class="commonSelectPop" style="width: 180px;">
							{foreach key=account_type item=account_type_name from=$ALL_ACCOUNT_TYPE}
								<option value={$account_type} {if $account_type eq {$DATA['set_default_tab']}}selected{/if}>{$account_type_name}</option>
							{/foreach}
						</select>
					</div>
				</td>
			</tr>
		</tbody>
	</table>
	<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>
			<tr>
				<td class="PublicTitle" width="100%">{'Highseassuperadministratorsettings'|@getFixedLabel}</td>
			</tr>
			<tr>
				<td class="pad paddT10" style="padding-right: 10px;" width="40%">
					<input type="hidden" name="select_administrators_id" value="{$DATA['administrators']}" />
					
					<div class="pubclear pubEnd" id="sendLogFoot" style="margin-top: -10px !important;">

						<div class="CCrange selectbar" tag="ccrange" style="width: 100%;" >
							<ul class="reader-bar-list">
								{foreach key=userid item=last_name from=$USERS}
									<li itemid="{$userid}" emptype="p">
										<span class="item-name">{$last_name}</span><span class="remove-h">×</span>
									</li>
								{/foreach}
							</ul>
							<span class="input-tip"><a href="javascript:void" name="select_administrators" title="{'Pleasesettheadministratorsjspop1'|@getFixedLabel}" class="choosepublicadmin" style="margin-left: 10px;white-space:nowrap;"> {'Pleasesettheadministratorsjspop1'|@getFixedLabel}</a></span>
							<input class="input-field ui-hide" type="text" autocomplete="off" value="">
							<span class="show-select-panel" name="select_administrators_div"><span class="icon-homeimg icon-workp"></span></span>
						</div>
					</div>
				</td>
			</tr>
			<tr>
				<td class="pad paddT10">
					<p style="margin-left: 10px;margin-bottom: 10px;">{'CreateAndMaintainMultipleHighSeasPoolOfLeads'|@getFixedLabel}</p>
				</td>
			</tr>
		</tbody>
	</table>

	<table class="" width="100%" cellspacing="0" cellpadding="0" border="0" name="common_account_rule_table" {if $DATA['status'] neq 'yes'}style="display:none;"{else}style=""{/if}>
		<tbody>
			<tr>
				<td class="PublicTitle" width="100%">{'CommonSalesLeadAutomaticRecoveryRuleSettings'|@getFixedLabel}</td>
			</tr>
			<tr>
				<td class="pad paddT10" width="40%">
					<div style="margin-top: 15px;margin-left: 20px;margin-bottom: 20px;"><input type="hidden" value="{'AUTOMATICRECOVERYRULE'|@getFixedLabel}" name="auto_recovery_rule_label"></li> 
						<label><input type="checkbox" name="account_rule" {if $DATA['show_account_rule'] eq 'yes'}checked{/if}>&nbsp;&nbsp;{'EnableCommonLeadsAutomaticReclaimRules'|@getFixedLabel}</label>
						<select name="select_pool_id" class="commonSelectPop" style="width: 180px;">
							{foreach key=pool_id item=pool_name from=$ALL_POOL}
								<option value={$pool_id} {if $DATA['account_rule_pool_id'] eq {$pool_id}}selected{/if}>{$pool_name}</option>
							{/foreach}
						</select>
						<!--自动回收规则设置-->
						<div name="account_rule_div" class="main_grid_box" {if $DATA['show_account_rule'] eq 'yes'}{else}style="display:none"{/if}>
							<div class="grid-analysis-box">
								<div class="grid-analysis-header"></div>
								<div id="picklist_datas" class="cont_wrap clear_float pad10">
								
								<div class="PublicseaSet" style="margin-top:-1px;border: 0px solid #ddd;">
									<ul>
										<li>
											<span class="">{"CommonLeadsParticipateInRecycling"|@getFixedLabel}
												<select name="completeopt"  class="btn-radius-system input-btn-align">
													<option value="and" {if $COMPLETECONDITION eq 'and'}selected{/if}>{"SEARCHAND"|@getFixedLabel}</option>
													<option value="or" {if $COMPLETECONDITION eq 'or'}selected{/if}>{"OR"|@getFixedLabel}</option>
												</select>
											</span>
											<span class="colorRed paddT10" name="completeopt_and" {if $COMPLETECONDITION eq 'or'}style="display:none;"{/if}>{"alltherulesmustbedone"|@getFixedLabel}</span>
											<span class="colorRed paddT10" name="completeopt_or" {if $COMPLETECONDITION eq 'and'}style="display:none;"{/if}>{"oneoftherulesmustbedone"|@getFixedLabel}</span>
											<ul>
												{foreach from=$ARRCOMPLETECONDITION item=ruleinfo}
													<li class="padli10">
														<div class="publicDiv">{$ruleinfo.seqno}</div>
														{if $ruleinfo.status eq 'active'}
															<input type="checkbox" style="margin-top:-5px;" name="{$ruleinfo.tabname}_completechk" tag="chkcomplete_{$ruleinfo.seqno}" accounttype="chkcomplete" checked="" />
														{else}
															<input type="checkbox" style="margin-top:-5px;" name="{$ruleinfo.tabname}_completechk" tag="chkcomplete_{$ruleinfo.seqno}" accounttype="chkcomplete" />
														{/if}
														<select onchange="PublicLeadsObj.changeRule('complete','{$ruleinfo.tabname}',this)" name="changerule_complete_{$ruleinfo.tabname}">
															{if $ruleinfo.iscycle eq 'yes'}
																<option value="no">{'SINGLERULE'|@getFixedLabel}</option>
																<option value="yes" selected="">{'RECYCLERULE'|@getFixedLabel}</option>
															{else}
																<option value="no" selected="">{'SINGLERULE'|@getFixedLabel}</option>
																<option value="yes" >{'RECYCLERULE'|@getFixedLabel}</option>
															{/if}
														</select>
														<span name="complete_{$ruleinfo.tabname}_span_recycle"  {if $ruleinfo.iscycle eq 'no'} style="display:none"{/if}>
															{$ruleinfo.recyclelabelbol1|@getFixedLabel}&nbsp;<input type="text" name="{$ruleinfo.tabname}_completedays" tag="complete_days" day_seqno="{$ruleinfo.seqno}"  class="btn-radius-system input-btn-align" style="width: 50px;text-align: center;" value="{$ruleinfo.days}"/>
															{if $ruleinfo.recyclelabelbol2 neq ""}
																{$ruleinfo.recyclelabelbol2|@getFixedLabel}{if $LANGUAGETYPE eq 'zh'}；{else};{/if}
															{/if}
														</span>
														<span name="complete_{$ruleinfo.tabname}_span_single" {if $ruleinfo.iscycle eq 'yes'} style="display:none"{/if}>
															{$ruleinfo.singlelabelbol1|@getFixedLabel}&nbsp;<input type="text" name="{$ruleinfo.tabname}_single_completedays" tag="complete_days" day_seqno="{$ruleinfo.seqno}"  class="btn-radius-system input-btn-align" style="width: 50px;text-align: center;" value="{$ruleinfo.days}"/>
															{if $ruleinfo.singlelabelbol2 neq ""}
																{$ruleinfo.singlelabelbol2|@getFixedLabel}{if $LANGUAGETYPE eq 'zh'}；{else};{/if}
															{/if}
														</span>
													</li>
												{/foreach}
											</ul>
										</li>
									</ul>   
								</div></div></div></div>
							</div>
							<!--自动回收规则设置-----结束-->
				</td>
			</tr>
		</tbody>
	</table>
	<!--自动回收规则数据分类设置-->
	<div name="account_rule_advance_div" class="PublicseaSet" {if $DATA['show_account_rule'] eq 'yes'}{else}style="display:none;margin-top:-1px;"{/if}>
		<ul>
			<li class="PublicTitle">{'AUTORECYCLERULEDATACATEGORY'|@getFixedLabel}</li>   
		</ul>
		<div>
			{include file="AdvanceFilterCustViewPopup.tpl"}
		</div>
	</div>
</form>