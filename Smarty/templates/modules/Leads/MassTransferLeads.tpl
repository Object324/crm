<div class="ld-description">
	<b class="info-icon"></b>
	<div class="ld-description-content">
		{'aftertransferringtothehighseas'|@getFixedLabel}
	</div>
</div>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Accounts"/>
    <input type="hidden" name="action" value ="savePublicAccount"/>
	<input type="hidden" name="record" value ="{$RECORD_STRING}"/>
	<table class="ld-public-content-small ld-public-content-single-column" width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>
			<tr>
				<td class="" width="40%">
					<div class="Category_New">
            		<table width="100%" cellspacing="0" cellpadding="0" border="0">
            			<tbody><tr>
							{if $PUBLIC_ACCOUNT_POOL|@count neq 0}
            				<td class="C" valign="middle">
                                <ul>
									<span class="category_span select-input marL0" style="font-weight: unset;">
										<input type="radio" value="transfer_to" name="transfer" checked>&nbsp;
										<label>{'Transfertothehighseas'|@getFixedLabel}</label>
									</span>
                                    <li tag="firstnode" style="display: flex;">
											<div class="ld-listview-category" name="div_select_public_account_pool">
												{assign var=fldname value='select_public_account_pool'}
												<select id="{$fldname}" name="{$fldname}" style="display:none">
													<option value="0" pool_id="0">{'LBL_PLEASE_SELECT'|@getFixedLabel}</option>
													{foreach item=pool_name key=pool_id from=$PUBLIC_ACCOUNT_POOL}
														{assign var=tmp_pool_id value=$pool_id}
														<option value="{$pool_id}" pool_id="{$pool_id}" 
														{if $PUBLIC_ACCOUNT_POOL|@count eq 1}
															selected
														{/if}>{$pool_name}</option>
													{/foreach}
												</select>
												<div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onmouseleave="cmb_mouseleave(event,'{$fldname}','showCustomPublicPoolList')">
													<a style="min-width:165px;width:auto;padding-right:20px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
														<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 145px;margin-left: -10px;border-style:none;" tabindex="0" name="cmb_span_optiontext_{$fldname}" onclick="cmb_picklist_end_foucs(event,'{$fldname}','showCustomPublicPoolList')" onkeyup="com_chosen(event,'{$fldname}','showCustomPublicPoolList')" value="{if $PUBLIC_ACCOUNT_POOL|@count eq 1}{$PUBLIC_ACCOUNT_POOL[$tmp_pool_id]}{/if}" placeholder="{'LBL_PLEASE_SELECT'|@getFixedLabel}">
														<div>
															<b></b>
														</div>
													</a>
													<div style="left: -9000px; padding-right: 5px; top: 25px; z-index: 902; width: 100%;" class="chzn-drop" name="dv_drop_{$fldname}">
														<ul class="chzn-results" name="cmb_ul_{$fldname}" style="float:none;">
															{assign var="i" value=0}
															{foreach item=pool_name key=pool_id from=$PUBLIC_ACCOUNT_POOL}
																<li  class="active-result" style="float:none;padding: 0 7px 0 7px;line-height:26px;height: auto;" pool_id="{$pool_id}" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$pool_id}','{$fldname}','')" onmouseover="cmb_limouseover(event,'{$fldname}','')">{$pool_name}</li>
																{assign var="i" value=$i+1}
															{/foreach}
															<li class="" name="li_chzn_{$fldname}" style="padding: 6px 7px;">{'NOMATCHINGITEMS'|@getFixedLabel}</li>
														</ul>
													</div>
												</div>
											</div>
                                    </li>
                                </ul>
                            </td>
                        </tr>
						{/if}
						{if $COMMONACCOUNT eq 'yes'}
							<tr>
								<td class="category_span marL0" style="font-weight: unset;"><input type="radio" value = "transfer_out" name="transfer" {if $PUBLIC_ACCOUNT_POOL|@count neq 0}{else}checked{/if}>&nbsp;&nbsp;{'TransferoutOftheHighHeasOfLeads'|@getFixedLabel}</td>
							</tr>
						{/if}
                    </tbody></table>
                </div>
				</td>
			</tr>
		</tbody>
	</table>
</form>