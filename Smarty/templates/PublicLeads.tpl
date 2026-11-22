
<div class="ld-ui-tabs" name="public_account_pool" style="overflow: visible;height:50px !important;">
{*	0044145: （61mis.com/kfbcrm）客户管理-客户（王耀文客户问题，需要补丁）；公海数有多个时，多公海下拉框选项无法正常显示*}
	<ul class="ld-ui-tabs-nav">
		<!-- 显示 “全部（含所有公海）”页签 -->
		{if $SHOW_PUBLICACCOUNT_TAB eq 'yes'}
			<li {if $ACCOUNTTYPE eq 'ALLACCOUNT'} class="ld-ui-tabs-active" {/if} pool_id="0" accounttype='ALLACCOUNT' onclick="PublicLeadsObj.showCustomType(this)"><a href="javascript:;">{'theallincludeunassignedpool'|@getFixedLabel}</a></li>
		{/if}
		<!-- 默认 “全部（含所有公海）”页签 -->
		<li {if $ACCOUNTTYPE eq 'DEFAULTALLACCOUNT'} class="ld-ui-tabs-active" {/if} pool_id="0" accounttype = 'DEFAULTALLACCOUNT' onclick="PublicLeadsObj.showCustomType(this)"><a href="javascript:;">{'thedefaultallincludeunassigned'|@getFixedLabel}</a></li>
		<!-- 显示 “全部（普通客户）”页签 -->
		{if $SHOW_COMMONACCOUNT_TAB eq 'yes'}
			<li {if $ACCOUNTTYPE eq 'COMMONACCOUNT'} class="ld-ui-tabs-active" {/if} pool_id="0" accounttype='COMMONACCOUNT' onclick="PublicLeadsObj.showCustomType(this)"><a href="javascript:;">{'allexcludinghignseas'|@getFixedLabel}</a></li>
		{/if}
		{foreach key=customtype item=labelbol from=$PUBLIC_Leads_LABEL}
			{if $customtype eq $ACCOUNTTYPE}
				<li class="ld-ui-tabs-active" pool_id="{$POOL_ID}" accounttype = '{$customtype}' onclick="PublicLeadsObj.showCustomType(this)"><a href="javascript:;">{$labelbol|@getFixedLabel}</a></li>
			{else}
				<li onclick="PublicLeadsObj.showCustomType(this)" accounttype = '{$customtype}' pool_id="{$POOL_ID}" ><a href="javascript:;">{$labelbol|@getFixedLabel}</a></li>
			{/if}
		{/foreach}
		<input type="hidden" id="create_commonaccount" name="create_commonaccount" value="{$CREATE_COMMONACCOUNT}" />
	</ul>
	<div>
		<ul>
			{if $PUBLIC_Leads_POOL_LABEL|@count neq 0}
				<div class="LdShowselect" id="showCustomPublicPoolList" style="padding: 10px 0 0 0;">
					{assign var=fldname value='select_public_account_pool'}
					<select onchange="PublicLeadsObj.showCustomType(this)" id="{$fldname}" name="{$fldname}" style="display:none">
						{foreach item=pool_info key=pool_id from=$PUBLIC_Leads_POOL_LABEL}
							<option value="{$pool_id}" pool_id="{$pool_id}" accounttype = '{$pool_info.accounttype}' {if $pool_id eq $POOL_ID}selected{/if}>{$pool_info.pool_name}</option>
						{/foreach}
					</select>
					<div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onmouseleave="cmb_mouseleave(event,'{$fldname}','showCustomPublicPoolList')">
						<a style="min-width:165px;width:auto;padding-right:20px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
							<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off"  style="width: 145px;margin-left: -10px;border-style:none;" tabindex="0" name="cmb_span_optiontext_{$fldname}" onclick="cmb_picklist_end_foucs(event,'{$fldname}','showCustomPublicPoolList')" onkeyup="com_chosen(event,'{$fldname}','showCustomPublicPoolList')" value="{$POOL_NAME}">
							<div>
								<b></b>
							</div>
						</a>
						<div style="left: -9000px; padding-right: 5px; top: 30px; z-index: 902; width: 100%;" class="chzn-drop" name="dv_drop_{$fldname}">
							<ul class="chzn-results" name="cmb_ul_{$fldname}" style="float:none;">
								{assign var="i" value=0}
								{foreach item=pool_info key=pool_id from=$PUBLIC_Leads_POOL_LABEL}
									<li  class="active-result" style="float:none;padding: 0 7px 0 7px;line-height:26px;height: auto;" accounttype = '{$pool_info.accounttype}' pool_id="{$pool_id}" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$pool_id}','{$fldname}','')" onmouseover="cmb_limouseover(event,'{$fldname}','')">{$pool_info.pool_name}</li>
									{assign var="i" value=$i+1}
								{/foreach}
								<li class="" name="li_chzn_{$fldname}" style="padding: 6px 7px;">{'NOMATCHINGITEMS'|@getFixedLabel}</li>
							</ul>
						</div>
					</div>
				</div>
			{/if}
			
		</ul>
		{if $PUBLIC_Leads.administrator eq 'yes'}
			<b onclick="publicLeadslistobj.edit_account_public_pool(ld(this),event);" style="margin-top: 8px;margin-left: 9px;cursor:pointer;" title="{'PUBLICCUSTOMERSET'|@getFixedLabel}" class="icon-homeimg icon-setgrey b" ></b>
		{/if}
	</div>
</div>
<script id="listajaxentries">
var popupobj=CrmPopup.getPopupObj("last");
var module = '{$MODULE}';
var publicLeadslistobj;
 getJsScript('include/js/modules/Leads/publicLeads.js', function () {
				publicLeadslistobj = new publicLeads(popupobj);	//公海参数、公海池 
});

</script>