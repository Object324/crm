{*<!--修改编码格式:统一编码：UTF-8-->*}

{foreach key=header item=detail from=$BLOCKS}
	<tr><td style="padding:5px;width:100%;">

			<!-- Detailed View Code starts here-->
			<table border=0 cellspacing=0 cellpadding=0 width=100% class="small">
				<tr>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td align=right>
					{if $header eq $MOD.LBL_ADDRESS_INFORMATION && ($MODULE eq 'Accounts' || $MODULE eq 'Contacts') }
						<input name="mapbutton" value="{$APP.LBL_LOCATE_MAP}" class="create" type="button" onClick="fnvshobj(this,'locateMap');" onMouseOut="fninvshnew('locateMap');" title="{$APP.LBL_LOCATE_MAP}">
						{/if}
					</td>
				</tr>

            {if $header eq $MOD.LBL_PUBLICACCOUNT_LOG && $ACCOUNTSET eq 0&& $PUBLICACCOUNT_LOG neq ''}

                <tr>{strip}
						<td colspan=4 class="dvInnerHeader">

							<div style="float:left;font-weight:bold;"><div style="float:left;"><a href="javascript:showHideStatus('publicaccountlog','aidpublicaccountlog','{$IMAGE_PATH}');">
										{if $BLOCKINITIALSTATUS[$header] neq 1}
											<a class="icon-homeimg icon-inactivate" href="javascript:;" id="aidpublicaccountlog" title="{'HIDDEN'|@getFixedLabel}"></a>
										{else}
											<a class="icon-homeimg icon-activate" href="javascript:;" id="aidpublicaccountlog"  title="{'DISPLAY'|@getFixedLabel}"></a>
										{/if}
									</a></div><b>&nbsp;
									{'RECORDSOFOPERATION'|@getFixedLabel}
								</b></div>
						</td>{/strip}
					</tr>
                    <tr>
                        <td>

                        <div id="publicaccountlog" style="overflow: auto; height: 100px; width: 100%;padding-left: 5px;">
                        {$PUBLICACCOUNT_LOG}
                        </div>
                        </td>
                    </tr>
				{/if}

				{if $header neq 'Comments'&& $header neq $MOD.LBL_PUBLICACCOUNT_LOG }

					<tr>{strip}
						<td colspan=4 class="dvInnerHeader">

							<div style="float:left;font-weight:bold;"><div style="float:left;"><a href="javascript:showHideStatus('tbl{$header|replace:' ':''}','aid{$header|replace:' ':''}','{$IMAGE_PATH}');">
										{if $BLOCKINITIALSTATUS[$header] eq 1}
											<a class="icon-homeimg icon-activate" href="javascript:;" id="aid{$header|replace:' ':''}" title="{'HIDDEN'|@getFixedLabel}"></a>
										{else}
											<a class="icon-homeimg icon-inactivate" href="javascript:;" id="aid{$header|replace:' ':''}" title="{'DISPLAY'|@getFixedLabel}"></a>
										{/if}
									</a></div><b>&nbsp;
									{$header}
								</b></div>
						</td>{/strip}
					</tr>
				{/if}
			</table>
			{if $header neq 'Comments'&& $header neq $MOD.LBL_PUBLICACCOUNT_LOG}
				{if $BLOCKINITIALSTATUS[$header] eq 1}
					<div style="width:auto;display:block;" id="tbl{$header|replace:' ':''}" >
					{else}
					<div style="width:auto;display:none;" id="tbl{$header|replace:' ':''}" >
					{/if}
						<table border=0 cellspacing=0 cellpadding=0 width="100%" class="small">
							{foreach item=detail from=$detail}
								<tr style="height:25px">
									{foreach key=label item=data from=$detail}
										{assign var=keyid value=$data.ui}
										{assign var=keyval value=$data.value}
										{assign var=keytblname value=$data.tablename}
										{assign var=keyfldname value=$data.fldname}
										{assign var=keyfldid value=$data.fldid}
										{assign var=keyoptions value=$data.options}
										{assign var=keysecid value=$data.secid}
										{assign var=keyseclink value=$data.link}
										{assign var=keycursymb value=$data.cursymb}
										{assign var=keysalut value=$data.salut}
										{assign var=keyaccess value=$data.notaccess}
										{assign var=keycntimage value=$data.cntimage}
										{assign var=keyadmin value=$data.isadmin}
										{assign var=display_type value=$data.displaytype}
										{assign var=_readonly value=$data.readonly}
                                        {assign var=fieldonly value=$data.fieldonly}
										{*zxm 20211230字段颜色 字段说明样式*}
										{assign var=fieldvaluecolor value=$data.fieldvaluecolor}
										{assign var=fieldplaceholder value=$data.fieldplaceholder}
										{assign var=ShowHyperlinks value=$data.ShowHyperlinks}
										{assign var = BUSINESSQUERY value = $data.businessquery}{* 是否为工商查询字段 *}
										{assign var = ENABLEBUSINESS value = $data.isenablebusiness}{* 是否启用工商查询 *}
										{assign var = BUSINESSFUZZYQUERY value = $data.isenablebusinessfuzzyquery}{* 是否启用工商模糊查询 *}
										{if $label ne ''}
											{if $keycntimage ne ''}
												<td class="dvtCellLabel" align=right width=25%><input type="hidden" id="hdtxt_IsAdmin" value={$keyadmin}></input>{$keycntimage}</td>
											{elseif $keyid eq '71' || $keyid eq '72'}<!-- Currency symbol -->
												<td class="dvtCellLabel" align=right width=25%>{$label}<input type="hidden" id="hdtxt_IsAdmin" value={$keyadmin}></input> ({$keycursymb})</td>
												{elseif $keyid eq '9'}
												<td class="dvtCellLabel" align=right width=25%><input type="hidden" id="hdtxt_IsAdmin" value={$keyadmin}></input>{$label} (%)</td>
												{elseif $keyid eq '14'}
												<td class="dvtCellLabel" align=right width=25%>{$label}<input type="hidden" id="hdtxt_IsAdmin" value={$keyadmin}></input> </td>
												{else}
		                                        <td class="dvtCellLabel" align=right width=25%><input type="hidden" id="hdtxt_IsAdmin" value={$keyadmin}></input>{$label}</td>
												{/if}

												{if $EDIT_PERMISSION eq 'yes' && $display_type neq '2' && $_readonly eq '0'}
													{* Performance Optimization Control *}
													{if !empty($DETAILVIEW_AJAX_EDIT)}

                                                        {if $alloweditpage eq 'no' ||  $EDITSTATUS eq 'no' ||($MODULE eq 'BankAccountSet' && $keyfldname eq 'initmoney'&& $CONFIRMEDST eq '1')||($MODULE eq 'Accounts'&& $keytblname eq 'ld_contactdetails' )}
                                                            {include file="DetailNoEdit.tpl"}
												        {else}
                                                            {include file="DetailViewUI.tpl"}
                                                        {/if}

                                                	{else}

														{include file="DetailViewFields.tpl"}
													{/if}
													{* END *}
												{else}

													{include file="DetailViewFields.tpl"}
												{/if}

											{/if}

										{/foreach}
								</tr>
							{/foreach}
						</table>
					</div>
				{/if}
		</td>
	</tr>
{/foreach}