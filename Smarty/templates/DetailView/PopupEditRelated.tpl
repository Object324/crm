<div class="edit-left" >
</div>
<div class="edit-right" >
	<div class="List3Box">
		<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
			<tr>

				<td class="TdLeft" style="display:none;" valign="top">


				</td>
				<td class="Tdcenter" valign="top">
					<input type="hidden" name="SearchScope" id="SearchScopeDetail" value="{$SEARCHSCOPE}"/>
					<div id="DetailContent" class="ld-createedit-content">
						{*控制最大宽度:max-width: 1300px;*}
						<table border="0" cellspacing="0" cellpadding="0" aling="left" style="width:100%;">
							<tr>
								<td class="left">
									<div class="DivC" id="div_pagerecord">
										{include file='EditViewHidden.tpl'}
										<table class="" border=0 cellspacing="0" cellpadding=0 width=100%>

											{*录音文件信息*}
											{if ($MODULE eq 'Accounts' || $MODULE eq 'Contacts' || $MODULE eq 'HelpDesk' || $MODULE eq 'ContactRecords'
											|| $MODULE eq 'Vendors' || $MODULE eq 'VendorContact' || $MODULE eq 'VendorContactRecords') && $CALLDISPLAY eq 'yes'}
												{include file="DetailView/CallButlerEditView.tpl"}
											{/if}
											{include file='DetailView/EditViewForeach.tpl'}
											<!-- Added to display the Product Details in Inventory-->
											{if $MODULE eq 'SalesBack'}
												<tr>
													<td colspan=4 class="ld-createedit-content-entry entryContentPad">
														{include file="Inventory/ProductDetailsEditView.tpl"}
													</td>
												</tr>
											{/if}
											{if $MODULE eq 'CashBill'}
												<tr {if $DISPLAYTABDETAIL eq 'no'}style="display:none;"{/if} name="cashbilltitle">
													<td colspan=4 class="ld-from-headblock-entry entryContentPad">
														<div class="ld-from-headblock-title"><b tag="headblock-title"><span id="CashBillrelatemessagespan"></span>{'GATHERINGINFORMATION'|@getFixedLabel}</b></div>
													</td>
												</tr>
												<tr>
													<td colspan=4 class="ld-createedit-content-entry entryContentPad">
														<div class="popDetailTable" name="cashbillsource">{$THHTML}</div>
													</td>
												</tr>
											{/if}
											{if $MODULE eq 'SendCashBill'}
												<tr >
													<td colspan=4 class="ld-createedit-content-entry entryContentPad">
														{include file="modules/SendCashBill/SendPaymentList.tpl"}
													</td>
												</tr>
											{/if}
											{if $MODULE eq 'Commission' }
												<tr>
													<td colspan=4 class="ld-createedit-content-entry entryContentPad">
														<div name="cashbillsource">{$THHTML}</div>
														{*include file="modules/Commission/CommissionList.tpl"*}
													</td>
												</tr>
											{/if}
											{if get_file_address($MODULE,$MODULE|cat:'DetailFieldsHtml') && $MODULE neq 'PricePolicy'}
												<tr>
													<td colspan=4 class="ld-createedit-content-entry entryContentPad">
														{include file="DetailView/PopupEditList.tpl"}
													</td>
												</tr>
											{/if}
											{if $MODULE eq 'LessionPlan' }
												<tr>
													<td colspan=4 class="ld-createedit-content-entry entryContentPad">
														{include file="modules/LessionPlan/LessionPlanList.tpl"}
													</td>
												</tr>
											{/if}
											{if $MODULE eq 'Events'}
												{include file="ActivityEditView.tpl"}
											{/if}
										</table>
									</div>
								</td>
							</tr>
						</table>
					</div></form>
					<!--	related	-->
					<div class="paneldiv">

						<div id='RelatedContent'  style="display: none;">
						</div>
						</form>
					</div>
				</td>
			</tr>
		</table>
		{if $QUICKCREATE neq ''}
			<div class="E_morefields ctextalign">
				<a href="javascript:;" id="pagechange" onclick="CreatePagePopup.pagechange()">{"COLLAPSE"|@getFixedLabel}<i class="icon-homeimg icon-chevronup-blue"></i></a>
			</div>
		{/if}
	</div>
	<!--公告选择用户,提醒选择接收人div-->
	<div id="recipient_namediv" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
	<div id="actiondiv" class="D_pop_box LdPopWidth900px" style="display:none; z-index:3;"></div>
	<!--相关信息设置div-->
	<div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
	<input name='search_url' id="search_url" type='hidden' value='{$SEARCH}'/>
	</form>

	<table id="popup_submit_head" border="0" cellspacing="0" cellpadding="0" width="100%" style="{if empty($APPROVE_ARR) || ($APPROVE_ARR|@is_array && $APPROVE_ARR|@sizeof eq 0)}display: none;{/if}" class="DetailContentTable linefeed">
		<tbody><tr>
			<td colspan="4" class="ld-from-headblock">
				<div class="ld-from-headblock-title" tag="headblock-title">{"SELECTAPPROVALPROC"|@getFixedLabel}</div>
			</td>
		</tr></tbody>
	</table>
	<div id="popup_submit_content" style="{if empty($APPROVE_ARR) || ($APPROVE_ARR|@is_array && $APPROVE_ARR|@sizeof eq 0)}display: none;{/if}" class="ld-public-content-big dd">
		{include file="Approve/SubmitApproveNew.tpl"}
	</div>
</div>
