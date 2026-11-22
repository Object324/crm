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
    <input type="hidden" name="module" value="Accounts"/>
	<input type="hidden" name="action" value="AccountsAjax"/>
	<input type="hidden" name="file" value="savePublicAccount"/>
	<input type="hidden" name="advft_criteria_groups"/>
	<input type="hidden" name="advft_criteria"/>
	<input type="hidden" name="before_status" value ="{$BEFORE_STATUS}"/>

{*	//ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（弹窗页面）*}
	<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
			<td class="PublicTitle" width="100%">{'maximumnumberofcustomers'|@getFixedLabel}</td>
		</tr>
		<tr>
			<td class="pad paddT10" width="40%">
				<div style="margin-top: 15px;margin-left: 20px;margin-bottom: 20px;">
					<input type="radio" style="margin-top: -3px;" class="inputBornone" name="limit_type" id="NOLIMITS" {if $DATA.limit_type eq ''} checked="checked" {/if} value=""/>
					<label for="NOLIMITS">{'NOLIMITS'|@getFixedLabel}</label>
				</div>

				<div style="margin-top: 15px;margin-left: 20px;margin-bottom: 20px;">
					<input type="radio" style="margin-top: -3px;" class="inputBornone" name="limit_type" id="Accordingtotheusercontrol" {if $DATA.limit_type eq 'user'} checked="checked" {/if} value="user"/>
					<label for="Accordingtotheusercontrol">{'Accordingtotheusercontrol'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'Eachuser'|@getFixedLabel}&nbsp;</label>
					<input id='limit_count' type="text"  class="btn-radius-system input-btn-align" {if $DATA.limit_type eq 'user'}{else}disabled = true{/if} name="limit_count" label="{'Accounts'|getTranstab}" style="width:50px;text-align:center;" value="{$DATA.limit_count}"/>
				</div>

				<div style="margin-top: 15px;margin-left: 20px;margin-bottom: 20px;">
					<input type="radio" style="margin-top: -3px;" class="inputBornone" name="limit_type" id="Accordingtotherolcontrol" {if $DATA.limit_type eq 'role'} checked="checked" {/if} value="role"/> <label for="Accordingtotherolcontrol">{'Accordingtotherolcontrol'|@getFixedLabel}</label>
				</div>
				<div style="margin-top: 15px;margin-left: 20px;margin-bottom: 20px;padding-left:10px;display:{if $DATA.limit_type eq 'role'}{else}none{/if}" name='select_limit_type_role' >
					<table class='ControlTable1 listEntries' border=0 cellspacing=1 cellpadding=5 width=100%>
						<tr>
							<th width='70%' title="{'ROLES'|@getFixedLabel}">{'ROLES'|@getFixedLabel}</th>
							<th width='30%' title="{'Themaximumnumberofcustomers'|@getFixedLabel}">{'Themaximumnumberofcustomers'|@getFixedLabel}</th>
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
				<p style="margin-left: 10px;margin-bottom: 10px;color: red;">{'CreateMaximumnumberofTip'|@getFixedLabel}</p>
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
						<input type="checkbox" name="status" id="ACTIVATEPUBLICCUST" {if $DATA['status'] eq 'yes'}checked{/if} >&nbsp;&nbsp;<label for="ACTIVATEPUBLICCUST">{'ACTIVATEPUBLICCUST'|@getFixedLabel}</label>
					</div>
					<div {if $DATA['status'] neq 'yes'}style="margin-bottom: 20px;margin-left: 20px;display:none;"{else}style="margin-bottom: 20px;margin-left: 20px;"{/if} name="div_show_publicaccount_tab">
						<input type="checkbox" name="show_publicaccount_tab" id="Showtheallincludeunassignedtab" {if $DATA['show_publicaccount_tab'] eq 'yes'}checked{/if} >&nbsp;&nbsp;<label for="Showtheallincludeunassignedtab">{'Showtheallincludeunassignedtab'|@getFixedLabel}</label>
					</div>
					<!--
					<div {if $DATA['show_publicaccount_tab'] neq 'yes'}style="margin-bottom: 15px;margin-left: 20px;display:none;"{else}style="margin-bottom: 15px;margin-left: 20px;"{/if} name="div_default_publicaccount_tab">
						<input type="checkbox" name="default_publicaccount_tab"  {if $DATA['default_publicaccount_tab'] eq 'yes'}checked{/if} >&nbsp;&nbsp;{'Setthedefaulttabasallincludeunassigned'|@getFixedLabel}
					</div>
					-->
					<div {if $DATA['status'] neq 'yes'}style="margin-bottom: 15px;margin-left: 20px;display:none;"{else}style="margin-bottom: 15px;margin-left: 20px;"{/if} name="div_show_commonaccount_tab">
						<input type="checkbox" name="show_commonaccount_tab"  id="Showtheallincludecommonaccounttab" {if $DATA['show_commonaccount_tab'] neq 'no'}checked{/if} >&nbsp;&nbsp;<label for="Showtheallincludecommonaccounttab">{'Showtheallincludecommonaccounttab'|@getFixedLabel}</label>
					</div>
					<div {if $DATA['status'] neq 'yes'}style="margin-bottom: 15px;margin-left: 20px;display:none;"{else}style="margin-bottom: 15px;margin-left: 20px;"{/if} name="div_is_commonaccount_create">
						<input type="checkbox" name="is_commonaccount_create" id="Allownewordinarycustomers" {if $DATA['is_commonaccount_create'] neq 'no'}checked{/if} >&nbsp;&nbsp;<label for="Allownewordinarycustomers">{'Allownewordinarycustomers'|@getFixedLabel}</label>
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
					<p style="margin-left: 10px;margin-bottom: 10px;">{'Createandmaintainmultiplehighseaspool'|@getFixedLabel}</p>
				</td>
			</tr>
		</tbody>
	</table>
	<!--************************************************************-->
	<table class="" width="100%" cellspacing="0" cellpadding="0" border="0" name="common_account_rule_table" {if $DATA['status'] neq 'yes'}style="display:none;"{else}style=""{/if}>
		<tbody>
			<tr>
				<td class="PublicTitle" width="100%">{'CommoncustomersautomaticallyreclaimruleSettings'|@getFixedLabel}</td>
			</tr>
			<tr>
				<td class="pad paddT10" width="40%">
					<div style="margin-top: 15px;margin-left: 20px;margin-bottom: 20px;"><input type="hidden" value="{'AUTOMATICRECOVERYRULE'|@getFixedLabel}" name="auto_recovery_rule_label"></li> 
						<input type="checkbox" name="account_rule" id="Enablecommoncustomerautomaticreclaimrules" {if $DATA['show_account_rule'] eq 'yes'}checked{/if}>&nbsp;&nbsp;<label for="Enablecommoncustomerautomaticreclaimrules">{'Enablecommoncustomerautomaticreclaimrules'|@getFixedLabel}</label>
				</td>
			</tr>
		</tbody>
	</table>
	<div name="account_rule_div" {if $DATA['show_account_rule'] eq 'no'}style="display:none"{/if}>
		<table width="100%" cellspacing="0" cellpadding="0" border="0">
			<tbody><tr class="PublicTitle">
				<td>&nbsp;&nbsp;{'recyclingscheme'|@getFixedLabel}</td>
				<td style="text-align: right;"><input type="button" class="createauto" value="{'addrulecomments'|@getFixedLabel}" name="create_recyclingscheme"></td>
			</tr>
		</tbody></table>
		<table class="" width="100%" cellspacing="10" cellpadding="0" border="0" name="tablerulecondition" {if $DATA['status'] neq 'yes'}style="display:none;"{else}style=""{/if}>
			<tbody>
				<tr>
					<td style="text-align:center; width:2%">#</td>
					<td style="text-align:center; width:15%">{'recoveryconditions'|@getFixedLabel}</td>
					<td style="text-align:center; width:15%">{'recyclingrules'|@getFixedLabel}</td>
					<td style="text-align:center; width:25%"><font color="red">*</font>{'recyclingtothehighseas'|@getFixedLabel}</td>
					<td style="text-align:center; width:36%">{'rulecomments'|@getFixedLabel}</td>
					<td style="text-align:center; width:8%">&nbsp;</td>
				</tr>
			</tbody>
		</table>
	</div>
</form>