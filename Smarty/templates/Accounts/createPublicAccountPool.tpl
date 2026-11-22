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
<form name="save_public_account_pool" action="index.php" method="post">
<input type="hidden" name="module" value="Accounts"/>
<input type="hidden" name="action" value="AccountsAjax"/>
<input type="hidden" name="file" value="savePublicAccountPool"/>
<input type="hidden" name="select_pool_id" value="{$POOL_ID}"/>
<input type="hidden" name="advft_criteria_groups"/>
<input type="hidden" name="advft_criteria"/>
<input type="hidden" name="languagetype" value="{$LANGUAGETYPE}"/>

<div class="main_grid_box">
	<div class="grid-analysis-box">
		<div class="grid-analysis-header"></div>
        <div id="picklist_datas" class="cont_wrap clear_float pad10">
			<!--基本信息-->
			<div class="PublicseaSet">
				<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
					<tbody>
						<tr>
							<td class="PublicTitle" colspan="2">{'BASICINFO'|@getFixedLabel}</td>
						</tr>
						<tr>
							<td width="20%">
								<span class="pad"><font color="red">*</font>{'Name(ZH)'|@getFixedLabel}</span>
							</td>
							<td style="padding-top: 10px;">
								<input type="text" class="detailedViewTextBox" style="width:50%;" name="zh_name" label="{'Name(ZH)'|@getFixedLabel}" value="{$POOLDATA.zh_name}">
							</td>
						</tr>
						<tr>
							<td width="20%">
								<span class="pad"><font color="red">*</font>{'Name(EN)'|@getFixedLabel}</span>
							</td>
							<td style="padding-top: 10px;">
								<input type="text" class="detailedViewTextBox" style="width:50%;" name="en_name" label="{'Name(EN)'|@getFixedLabel}" value="{$POOLDATA.en_name}">
							</td>
						</tr>
						<tr>
							<td width="20%">
								<span class="pad"><font color="red">*</font>{'Mangers'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</span>
							</td>
							<td>
								<input type="hidden" name="select_administrators_id" value="{$POOLDATA.administrators}" />
								<div class="pubclear pubEnd" id="sendLogFoot">
									<div class="CCrange selectbar" name="administrators_div" tag="ccrange" style="margin-top: 0;">
										<ul class="reader-bar-list">
											{foreach key=userid item=last_name from=$POOLDATA.administrators_lastname}
												<li itemid="{$userid}" emptype="p">
													<span class="item-name">{$last_name}</span><span class="remove-h">×</span>
												</li>
											{/foreach}
										</ul>
										<span class="input-tip"><a href="javascript:void" name="select_administrators" tag="administrators" title="{'Pleasesettheadministrators'|@getFixedLabel}" class="choosepublicadmin" style="margin-left: 10px;white-space:nowrap;"> {'Pleasesettheadministrators'|@getFixedLabel}</a></span>
										<input class="input-field ui-hide" type="text" autocomplete="off" value="">
										<span class="show-select-panel" name="select_administrators_div" tag="administrators"><span class="icon-homeimg icon-workp"></span></span>
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<td width="20%">
								<span class="pad">{'Members'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
							</td>
							<td class="select-input" style="padding: 10px 0;">	
								  <input type="radio" {if $POOLDATA.usertype eq 'all' || $POOLDATA.usertype eq ''}checked="" {/if} value="all" name="radioUser" id="pulicaccount_all">
								  <label class="padR10" for="pulicaccount_all">{'ALLTHEUSERS'|@getFixedLabel}</label>
								  <input type="radio" {if $POOLDATA.usertype eq 'group'}checked="" {/if} value="group" name="radioUser" id="pulicaccount_group">
								  <label class="padR10" for="pulicaccount_group">{'SETBYDEPARTMENT'|@getFixedLabel}</label>
								  <input type="radio" {if $POOLDATA.usertype eq 'user'}checked="" {/if} value="user" name="radioUser" id="pulicaccount_user">
								  <label class="padR10" for="pulicaccount_user">{'SETBYUSERS'|@getFixedLabel}</label>
								  <input id="usertype" class="templateprintuser" type="hidden" value="{if $POOLDATA.usertype eq ''}all{else}{$POOLDATA.usertype}{/if}" name="usertype">
								  <input id="userids" class="templateprintuser" type="hidden" value="{$POOLDATA.userids}" name="userids">
							</td>
						</tr>
						<!--允许"公海分配"的成员 -->
						<tr>
							<td width="20%">
								<span class="pad">{'AllowmembersAssignUnassigned'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</span>
							</td>
							<td>
								<input type="hidden" name="allow_user_id" value="{$POOLDATA.allow_users}" />
								<div class="pubclear pubEnd" id="sendLogFoot" style="padding-bottom:10px;">
									<div name="allow_user_div" class="CCrange selectbar" tag="ccrange" style="margin-top: 0;">
										<ul class="reader-bar-list">
											{foreach key=userid item=last_name from=$POOLDATA.allow_users_lastname}
												<li itemid="{$userid}" emptype="p">
													<span class="item-name">{$last_name}</span><span class="remove-h">×</span>
												</li>
											{/foreach}
										</ul>
										<span class="input-tip"><a href="javascript:void" name="select_allow_user" tag="allow_user" title="{'SELECT'|@getFixedLabel}{'Members'|@getFixedLabel}" class="choosepublicadmin" style="margin-left: 10px;white-space:nowrap;"> {'SELECT'|@getFixedLabel}{'Members'|@getFixedLabel}</a></span>
										<input class="input-field ui-hide" type="text" autocomplete="off" value="">
										<span class="show-select-panel" name="select_allow_user_div" tag="allow_user"><span class="icon-homeimg icon-workp"></span></span>
									</div>
								</div>
							</td>
						</tr>
						<!--允许"转换公海"的成员 -->
						<tr style="display:none">
							<td width="20%">
								<span class="pad">{'AllowmembersTransfer'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</span>
							</td>
							<td>
								<input type="hidden" name="transfer_user_id" value="{$POOLDATA.transfer_users}" />
								<div class="pubclear pubEnd" id="sendLogFoot">
									<div name="transfer_user_div" class="CCrange selectbar" tag="ccrange" style="margin-top: 0;">
										<ul class="reader-bar-list">
											{foreach key=userid item=last_name from=$POOLDATA.transfer_users_lastname}
												<li itemid="{$userid}" emptype="p">
													<span class="item-name">{$last_name}</span><span class="remove-h">×</span>
												</li>
											{/foreach}
										</ul>
										<span class="input-tip"><a href="javascript:void" name="select_transfer_user" tag="transfer_user" title="{'SELECT'|@getFixedLabel}{'Members'|@getFixedLabel}" class="choosepublicadmin" style="margin-left: 10px;white-space:nowrap;"> {'SELECT'|@getFixedLabel}{'Members'|@getFixedLabel}</a></span>
										<input class="input-field ui-hide" type="text" autocomplete="off" value="">
										<span class="show-select-panel" name="select_administrators_div" tag="transfer_user"><span class="icon-homeimg icon-workp"></span></span>
									</div>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
				<!-- <ul>
					<li class="PublicTitle">{'BASICINFO'|@getFixedLabel} </li>
					<li>
						<span class="pad"><font color="red">*</font>{'Name(ZH)'|@getFixedLabel}</span>
						<input type="text" class="detailedViewTextBox" style="width:50%;" name="zh_name" label="{'Name(ZH)'|@getFixedLabel}" value="{$POOLDATA.zh_name}">
					</li>
					<li>
						<span class="pad"><font color="red">*</font>{'Name(EN)'|@getFixedLabel}</span>
						<input type="text" class="detailedViewTextBox" style="width:50%;" name="en_name" label="{'Name(EN)'|@getFixedLabel}" value="{$POOLDATA.en_name}">
					</li>
					<li>
						<span class="pad"><font color="red">*</font>{'Mangers'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;</span>
						<input type="hidden" name="select_administrators_id" value="{$POOLDATA.administrators}" />
						<div class="pubclear pubEnd" id="sendLogFoot">
							<div class="CCrange selectbar" tag="ccrange" style="" >
								<ul class="reader-bar-list">
									{foreach key=userid item=last_name from=$POOLDATA.administrators_lastname}
										<li itemid="{$userid}" emptype="p">
											<span class="item-name">{$last_name}</span><span class="remove-h">×</span>
										</li>
									{/foreach}
								</ul>
								<span class="input-tip"><a href="javascript:void" name="select_administrators" title="{'Pleasesettheadministrators'|@getFixedLabel}" class="choosepublicadmin" style="margin-left: 10px;white-space:nowrap;"> {'Pleasesettheadministrators'|@getFixedLabel}</a></span>
								<input class="input-field ui-hide" type="text" autocomplete="off" value="">
								<span class="show-select-panel" name="select_administrators_div"><span class="icon-homeimg icon-workp"></span></span>
							</div>
						</div>
					</li>
					<li>
						<span class="pad">&nbsp;&nbsp;{'Members'|@getFixedLabel}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
						
						  <input type="radio" {if $POOLDATA.usertype eq 'all' || $POOLDATA.usertype eq ''}checked="" {/if} value="all" name="radioUser" >
						  <label class="padR10">{'ALLTHEUSERS'|@getFixedLabel}</label>
						  <input type="radio" {if $POOLDATA.usertype eq 'group'}checked="" {/if} value="group" name="radioUser">
						  <label class="padR10">{'SETBYDEPARTMENT'|@getFixedLabel}</label>
						  <input type="radio" {if $POOLDATA.usertype eq 'user'}checked="" {/if} value="user" name="radioUser">
						  <label class="padR10">{'SETBYUSERS'|@getFixedLabel}</label>
						  <input id="usertype" class="templateprintuser" type="hidden" value="{if $POOLDATA.usertype eq ''}all{else}{$POOLDATA.usertype}{/if}" name="usertype">
						  <input id="userids" class="templateprintuser" type="hidden" value="{$POOLDATA.userids}" name="userids">
					</li>
				</ul> -->
			</div>
			<!--公海已分配客户数量上限-->
			<div class="PublicseaSet" style="margin-top:-1px;">
				<ul>
					<li class="PublicTitle">{'maximumnumberofhighseascustomers'|@getFixedLabel}</li>
					<li class="paddT10" style="padding-left:10px;"><input type="radio" style="margin-top: -3px;" class="inputBornone" name="limit_type" id="Accordingtotheusercontrol" {if $POOLDATA.limit_type eq 'user' || $POOLDATA.limit_type eq ''} checked="checked" {/if} value="user" onclick="changeastricttype('1','')"/>
						<label for="Accordingtotheusercontrol">{'Accordingtotheusercontrol'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'Eachuser'|@getFixedLabel}&nbsp;</label>
						<input id='limit_count' type="text"  class="btn-radius-system input-btn-align" {if $POOLDATA.limit_type eq 'role'}disabled = true {/if} name="limit_count" label="{'LBL_PUBLICALLOCATE'|@getFixedLabel}" style="width:50px;text-align:center;" value="{$POOLDATA.limit_count}"/>
					</li>
					<li style="padding-left:10px;">
						<input type="radio" style="margin-top: -3px;" class="inputBornone" name="limit_type" id="Accordingtotherolcontrol" {if $POOLDATA.limit_type eq 'role'} checked="checked" {/if} value="role" onclick="changeastricttype('2',{if $COUNT eq ''}0{else}{$COUNT}{/if})"/><label for="Accordingtotherolcontrol">{'Accordingtotherolcontrol'|@getFixedLabel}</label>
					</li>
					<li  class="paddT10" name='select_limit_type_role' {if $POOLDATA.limit_type eq 'role'}style="padding-left:10px;"{else}style="display:none;padding-left:10px;"{/if} >
						<table class='ControlTable1 listEntries' border=0 cellspacing=1 cellpadding=5 width=100%>
							<tr>
								<th width='70%' title="{'ROLES'|@getFixedLabel}">{'ROLES'|@getFixedLabel}</th>
								<th width='30%' title="{'Themaximumnumberofhighseascustomers'|@getFixedLabel}">{'Themaximumnumberofhighseascustomers'|@getFixedLabel}</th>
							</tr>
							{foreach key=role_id item=role_info from=$ACCOUNBT_ROLE_LIMITCOUNT}
								<tr bgcolor='white'>
									<td nowrap><span title='{$role_info.role_name}'>{$role_info.role_name}</span></td>
									<td> 
										<input  name="txtbox_role_count[]" roleid={$role_id} class="detailedViewTextBox" style="width:150px;float:left;" type="text" value="{$role_info.limit_count}" maxlength="100">
										<input name="txtbox_roleid[]" value="{$role_id}" type="hidden" />
									</td>
								</tr>
							{/foreach}
						</table>
					</li>
				</ul>
            </div>
			<!--业务规则-->
			<div class="PublicseaSet">
				<ul>
					<li class="PublicTitle">{'Businessrules'|@getFixedLabel} </li>
					<li>
						<span class="pad"><input type="checkbox" onclick="productsDetailsChecks(this)" class="inputBornone input-btn-align" name="allowget" id="allowget" {if $POOLDATA.allowget eq 'yes'}checked{/if} value="{$POOLDATA.allowget}" /><label class="marL5" for="allowget">{'UNALLOCATECUSTOMERADMIN'|@getFixedLabel}</label></span>
					</li>
					<li id="poolmember_show_noallocate_li" style="{if $POOLDATA.allowget neq 'yes'}display:none;{/if}">
						<span class="pad"><input type="checkbox" onclick="productsDetailsChecks(this)" class="inputBornone input-btn-align" name="poolmember_show_noallocate" id="poolmember_show_noallocate" {if $POOLDATA.poolmember_show_noallocate eq 'yes'}checked{/if} value="{$POOLDATA.poolmember_show_noallocate}" /><label class="marL5" for="poolmember_show_noallocate">{'ISSHOWUNALLOCATEDHIGHSEAS'|@getFixedLabel}</label></span>
					</li>
					<li>
						<span class="pad"><input type="checkbox" onclick="productsDetailsChecks(this)" class="inputBornone input-btn-align" name="dataprofile" id="dataprofile" {if $POOLDATA.dataprofile eq 'yes'}checked{/if} value="{$POOLDATA.dataprofile}" /><label class="marL5" for="dataprofile">{'CUSTOMERCONTROLPUBLIC'|@getFixedLabel}</label> </span>
					</li> 
					<li>
						<span class="pad"><input type="checkbox" onclick="productsDetailsChecks(this)" class="inputBornone input-btn-align" name="allow_unallocated_showinall" id="allow_unallocated_showinall" {if $POOLDATA.allow_unallocated_showinall eq 'yes'}checked{/if} value="{$POOLDATA.allow_unallocated_showinall}" /><label class="marL5" for="allow_unallocated_showinall">{'Allowtheunallocatedcustomerstobedisplayedinalllist'|@getFixedLabel}</label></span>
					</li> 
					<li>
						<span class="pad"><input type="checkbox" onclick="productsDetailsChecks(this)" class="inputBornone input-btn-align" name="allow_allocated_showinall" id="allow_allocated_showinall" {if $POOLDATA.allow_allocated_showinall eq 'yes'}checked{/if} value="{$POOLDATA.allow_allocated_showinall}" /><label class="marL5" for="allow_allocated_showinall">{'Allowtheallocatedcustomerstobedisplayedinalllist'|@getFixedLabel}</label></span>
					</li> 
					<li>
						<span class="pad"><input type="checkbox" onclick="productsDetailsChecks(this)" class="inputBornone input-btn-align" name="allow_trasnfer_others" id="allow_trasnfer_others" {if $POOLDATA.allow_trasnfer_others eq 'yes'}checked{/if} value="{$POOLDATA.allow_trasnfer_others}" /><label class="marL5" for="allow_trasnfer_others">{'Allowuserstotransfertheallocatedcustomerstootherseas'|@getFixedLabel}</label></span>
					</li>
					<!-- 公海成员客户序时簿“新建”功能下拉选项-->
					<li style="height:40px;">
						<span class="pad">{*<span class="colorRed">*</span>*}{'NEWBUTTONDROP-DOWNOPTIONS'|@getFixedLabel}</span>
						{assign var=fldname value='create_buttons'}
						<select id="create_buttons"  name="create_buttons" style="display:none">
							{foreach key=key item=item from=$buttonarray}
							<option value="{$key}" {if $key == $buttontype}selected{/if}>{$item}</option>
							{/foreach}
						</select>
						<div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" style="display:none;position:absolute; margin-left:6px;margin-top:-2px;" onMouseLeave="cmb_mouseleave(event,'{$fldname}','SettingRightContent')">
							<a style="width:108px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','SettingRightContent')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
								<span name="cmb_span_optiontext_{$fldname}">{$buttonarray.$buttontype}</span>
								<div><b></b></div>
							</a>
							<div style="left:-9000px;width: 108px; top: 20px;" class="chzn-drop" name='dv_drop_{$fldname}' >
								<div class="chzn-search">
									<input class="search_bg" type="text" autocomplete="off" style="width: 96px;" tabindex="0"  name='txt_search_{$fldname}' onclick="com_chosen(event,'{$fldname}','SettingRightContent')" onKeyUp="com_chosen(event,'{$fldname}','SettingRightContent')">
								</div>
								<ul class="chzn-results" name="cmb_ul_{$fldname}">
									{foreach key=key item=item from=$buttonarray}
										{assign var="i" value=$i+1}   
										<li  class="active-result" style="padding: 6px 7px;" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}','SettingRightContent')" onmouseover="cmb_limouseover(event,'{$fldname}','SettingRightContent')"> {$item}</li>
									{/foreach}
									<li class="" name="li_chzn_{$fldname}" style="padding: 6px 7px;">{'NOMATCHINGITEMS'|@getFixedLabel}</li>
								</ul>
							</div>
						</div>
						<div style="position: absolute;display: inline;padding-left:8px;margin-top: -8px;height:10px" id="dv_{$fldname}">
							<select  multiple id="m_{$fldname}" name="m_{$fldname}[]">    
							  {foreach key=key item=item from=$buttonarray}
							  {assign var=m_selected value=''}
								{foreach item=sel_type from=$POOLDATA.create_buttons}
								  {if $key eq $sel_type}
									{assign var=m_selected value='selected'}
								  {/if}
								{/foreach}
								<option value="{$key}" {$m_selected}>{$item}</option>
							  {/foreach}
							</select>
						</div>
					</li>
					<!-- 客户转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）-->
					<li>
						<span class="pad">
							{'AFTERCONVERTINGMODIFYTHEOWNER'|@getFixedLabel}
							<div style="position: absolute;display: inline;">
								<input fieldonly='' type="hidden" tabindex="" name="userid_after_transfer" value="{$POOLDATA.userid_after_transfer}" />
								<!-- <input type="text" id="user_name" class="btn-radius-system marTminus_3" name="user_name" value="{$user_name}"/> -->
								<div class="btn-radius-system marTminus_3 lfloat" name="userid_after_transfer_name" style="width:150px;line-height: 30px;padding-left: 8px;background: #fff;">{$POOLDATA.userid_after_transfer_lastname}</div>
								<a class="icon-homeimg icon-select lfloat marT4" href="javascript:;" title="{'SELECT'|@getFixedLabel}" tag="userid_after_transfer" name="select_user_name"></a>
								<a class="icon-homeimg icon-clear lfloat marT2" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" tag="userid_after_transfer" name="clear_user_name"></a>
							</div>  
						</span>
					</li>
					<!-- 公海已分配客户释放后，更改客户负责人为（为空表示不更改）-->
					<li>
						<span class="pad">
						{'AFTERRELEASINGTHEALLOCATEDHIGNSEAS'|@getFixedLabel}
						<div style="position: absolute;display: inline;">
							<input fieldonly='' type="hidden" tabindex="" name="userid_after_release" value="{$POOLDATA.userid_after_release}" />
							<!-- <input type="text" id="allotuser_name" class="btn-radius-system marTminus_3" name="allotuser_name" value="{$allotuser_name}"/> -->
							<div class="btn-radius-system marTminus_3 lfloat" name="userid_after_release_name" style="width:150px;line-height: 30px;padding-left: 8px;background: #fff;">{$POOLDATA.userid_after_release_lastname}</div>
							<a class="icon-homeimg icon-select lfloat marT4" href="javascript:;" title="{'SELECT'|@getFixedLabel}" tag="userid_after_release" name="select_user_name"></a>
							<a class="icon-homeimg icon-clear lfloat marT2" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" tag="userid_after_release" name="clear_user_name"></a>
						</div>
						</span>
					</li>
					<!-- 客户被自动回收后天内不允许被当前销售负责人再次领取（为0或空表示不控制） -->
					<li id="objtainaccountcontrolday">
						<span class="pad">
							{'ObjtainAccountControlDays1'|@getFixedLabel}<input type="text" value="{$POOLDATA.objtainaccountcontroldays}" name="objtainaccountcontroldays" class="btn-radius-system input-btn-align" style="width: 50px;text-align: center;" />{'ObjtainAccountControlDays2'|@getFixedLabel}
						</span>
					</li>
					<!-- 客户回收前提前多少天提醒销售负责人（为0表示当天提醒，为空表示不提醒） -->
					<li >
						<span class="pad">{"BEFOREREMINDDAYSCUSTOMER"|@getFixedLabel}</span><input class="btn-radius-system input-btn-align"  name='beforereminddays' type="text" value="{$POOLDATA.beforereminddays}"/>
					</li>
				</ul>
			</div>
           
            <!--自动回收规则设置-->
            <div class="PublicseaSet" style="margin-top:-1px;">
				<ul>
					<li class="PublicTitle">{'AUTOMATICRECOVERYRULE'|@getFixedLabel}<input type="hidden" value="{'AUTOMATICRECOVERYRULE'|@getFixedLabel}" name="auto_recovery_rule_label"></li>   
					<li>
						<span class="pad">1、<input type="checkbox" id="completeopt_checkbox" checked disabled="" />&nbsp;{"COMPLETEAUTOMATICRECOVERYRULE"|@getFixedLabel}
							<select name="completeopt"  class="btn-radius-system input-btn-align">
								<option value="and" {if $COMPLETECONDITION eq 'and'}selected{/if}>{"SEARCHAND"|@getFixedLabel}</option>
								<option value="or" {if $COMPLETECONDITION eq 'or'}selected{/if}>{"OR"|@getFixedLabel}</option>
							</select>
						</span>
						<span class="colorRed paddT10" name="completeopt_and" {if $COMPLETECONDITION eq 'or'}style="display:none;"{/if}>{"alltherulesmustbedone"|@getFixedLabel}</span>
						<span class="colorRed paddT10" name="completeopt_or" {if $COMPLETECONDITION eq 'and'}style="display:none;"{/if}>{"oneoftherulesmustbedone"|@getFixedLabel}</span>
						<ul>
							{foreach from=$ARRCOMPLETECONDITION item=ruleinfo}
								<li class="padli30">
									<div class="publicDiv">{$ruleinfo.seqno}</div>
									{if $ruleinfo.status eq 'active'}
										<input type="checkbox" style="margin-top:-5px;" name="{$ruleinfo.tabname}_completechk" tag="chkcomplete_{$ruleinfo.seqno}" accounttype="chkcomplete" checked="" />
									{else}
										<input type="checkbox" style="margin-top:-5px;" name="{$ruleinfo.tabname}_completechk" tag="chkcomplete_{$ruleinfo.seqno}" accounttype="chkcomplete" />
									{/if}
									<select onchange="publicAccounts.getInstance().changeRule('complete','{$ruleinfo.tabname}',this)" name="changerule_complete_{$ruleinfo.tabname}" style="padding: 3px;">
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
            </div>
			<!--自动回收规则数据分类设置-->
			<div class="PublicseaSet" style="margin-top:-1px;">
				<ul>
					<li class="PublicTitle">{'AUTORECYCLERULEDATACATEGORY'|@getFixedLabel}</li>   
				</ul>
				<div>
					{include file="AdvanceFilterCustViewPopup.tpl"}
				</div>
			</div>
        </div>
    </div>
</div>
</form>