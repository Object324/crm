{*<!--
/*+********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
-->*}
<table class="" id="RolesProfile_ParentTabs" border="0" cellpadding="0" cellspacing="0" width="100%" style="">
	<tbody>
		<tr style="">
			<td class="f1" colspan="5" style="padding: 10px;">
				<div class="menustandarddiv menustandarddivactive" onclick="clickshowMenuProfile('all')" data-parenttabid="all" name="div_parenttab_all">
					{'ALL'|@getFixedLabel}<span class="" toptag="show" sontag="parenttab_all"></span>
				</div>
				{foreach key=index item=menuinfo from=$MENU_STANDARD_PRIV}
					{assign var=parenttabid value=$menuinfo.id}
					{assign var=parenttabname value=$menuinfo.name}
					<div class="menustandarddiv" onclick="clickshowMenuProfile('{$parenttabid}')" data-parenttabid="{$parenttabid}" name="div_parenttab_{$parenttabid}">
						{$MENU_PARENTLIST[$parenttabname]}<span class="" toptag="hidden" sontag="parenttab_{$parenttabid}"></span>
					</div>
				{/foreach}
			</td>
		</tr>
	</tbody>
</table>
<div class="ld-rolesprofile-list" id="RolesProfile_MainList" style="overflow: auto;margin: 0px 16px;">
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tbody>
			{foreach key=index item=menuinfo from=$MENU_STANDARD_PRIV}
				{assign var=parenttabid value=$menuinfo.id}
				{assign var=parenttabname value=$menuinfo.name}
				{assign var=privileg_stand value=$menuinfo.stand}
				<tr tag="parenttab_head_{$parenttabid}" style="display:;">
					<td class="ld-rolesprofile-tabbar f1" colspan="5" style="">
						<div class="DivCName DivCNamehover" onclick="showHideMenuProfile('{$parenttabid}','{$parenttabname}')" data-parenttabid="{$parenttabid}" style="border:0;">
							<span class="" id="parenttab_{$parenttabid}" name="parenttab_{$parenttabname}" tag="show"></span>{$MENU_PARENTLIST[$parenttabname]}
						</div>
					</td>
				</tr>
				<tr tag="activeparenttab_{$parenttabid}" style="display: none;">
					<td class="ld-rolesprofile-tabbar f1" colspan="5" style="">
						<div class="DivCName DivCNamehover" style="border:0;">
							{$MENU_PARENTLIST[$parenttabname]}</span>
						</div>
					</td>
				</tr>
				{foreach key=tabid item=profile_stand from=$privileg_stand}	
					{assign var=modulename value=$tabid|@getTabModuleName}
					{if !empty($modulename|@getTranstab)}
						<tr tag="parenttab_{$parenttabid}" style="display:;" tabid="{$tabid}">
							<td class="ld-rolesprofile-list-modulename" width="15%" align="left">
								<div style="flex-direction: column;">
									<div>
										{if !empty($profile_stand[3])}
											{$profile_stand[3]}
										{else}
											&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
										{/if}
										{if $tabid eq '-2'}
											<span style="margin-left: 4px;">{$MOBILEREPORTLABEL}</span>
										{else}
											<span style="margin-left: 4px;">{$modulename|@getTranstab}</span>
										{/if}
									</div>
									{if $ISMODULEFIELD[$tabid] eq 'yes'}
										<div style="margin-top: 6px;padding-left: 18px;">
											<a class="Anu3_a" href="javascript:;" profileid="{$PROFILEID}" style="font-size: 14px;" onclick="EditProfileField({$PROFILEID},{$tabid},this,'selectModuleFieldList')">{'SETVISIBLERANGEFIELDS'|@getFixedLabel}</a>
										</div>
									{/if}
								</div>
							</td>
							<td width="85%" align="center" colspan="3" style="white-space: inherit;padding: 0px;">
								{assign var='fori' value=0}
								{assign var='forj' value=0}
								<table class="ld-rolesprofile-list-profilearea" border="0" cellpadding="0" cellspacing="0" width="100%" align="center">
									<tr>
										{foreach key=actionid item=stand_prive from=$profile_stand name=actionfor}
											{assign var='fori' value=$fori+1}
											{if $actionid neq 3}
												{assign var='forj' value=$forj+1}
												<td width="133" style="white-space:inherit;border:0px;">
													{$stand_prive}
												</td>
												{if $fori%7 eq 0}
													{assign var='fori' value=1}
													{assign var='forj' value=1}
													</tr><tr>
												{/if}
											{/if}
										{/foreach}
										{*BUG0072361 txy 20230907 kfbcrm-角色权限-编辑-报表分析增加打印功能后，跟下面不对齐了 *}
										{while ($forj < 6 && $forj >1) } <!-- 如果生成的<td>元素少于6，添加额外的空<td>元素 -->
											<td width="133" style="white-space:inherit;border:0px;"></td>
											{assign var='forj' value=$forj+1} <!-- 递增计数器 -->
										{/while}
									</tr>
								</table>
							</td>
						</tr>
					{/if}
				{/foreach}
			{/foreach}
		</tbody>
	</table>
</div>
