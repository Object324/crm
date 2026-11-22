<div class="edit-left" >
</div>
<div class="edit-right" >
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
	  	<tr>
			<td class="Tdcenter" valign="top">
				<input type="hidden" id="bemodulestatus" name="bemodulestatus" value="{$BESTATUS}" />
				<input type="hidden" name="SearchScope" id="SearchScopeDetail" value="{$SEARCHSCOPE}"/>
				<input type="hidden" name="productdeploy" id="productdeploy" value="{$PERODUCTDEPLOY}" />
				<input type="hidden" name="version_account" value="{$VERSION_ACCOUNT}" />
				<div id="DetailContent" class="ld-createedit-content">
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr>
							<td class="left">
								<div class="DivC" id="div_pagerecord">
									<div class="Top">
										{include file='EditViewHidden.tpl'}
										<input type="hidden" name="duplicateid" value="{$duplicateid}"/>
										<table border="0" cellspacing="0" cellpadding="0" width="100%" class="">
											{include file='DetailView/EditViewForeach.tpl'}
											{if $MODULE == 'Stock' || $MODULE == 'OutboundOrder'}
												<input type="hidden" value="{$DEPLOYVALUE}" id="delpoyvalue" name="delpoyvalue" />
											{/if}
											{if $MODULE eq 'PurchaseOrder' || $MODULE eq 'SalesOrder' || $MODULE eq 'Quotes' || $MODULE eq 'Invoice'|| $MODULE eq 'ServiceContracts' || $MODULE eq 'PurchaseBack'|| $MODULE eq 'PurchaseCashBack' || $MODULE eq 'PurchaseInvoice'||$MODULE eq 'WareHouseTransfer'||$MODULE eq 'Productbom'||$MODULE eq 'OutboundOrder'||$MODULE eq 'Stock'||$MODULE eq 'Checks' || $PERODUCTDEPLOY eq 1 || $MODULE|@get_file_address:'ProductDetails' == true}
												<tr>
													<td colspan="4" align="left" name="productdetailtabletd" class="ld-createedit-content-entry entryContentPad">
														{* 出入库单 *}
														{$ASSOCIATEDPRODUCTS}
													</td>
												</tr>
											{/if}
											{if $MODULE eq 'WorkSheet'}
												<tr>
													<td colspan="4" align="left" name="partdetailtabletd" class="ld-createedit-content-entry entryContentPad">
														{* 工单管理特殊分录*}
														{$ASSOCIATEDPART}
													</td>
												</tr>
											{/if}
											<tr colspan="4" style="display: none;"><td></td></tr>
									  	</table>
									</div>
								</div>
							</td>
						</tr>
					</table>
				</div>
			</td>
	  	</tr>
	</table>
	<input name='search_url' id="search_url" type='hidden' value='{$SEARCH}'>
	</form>



	<!-- This div is added to get the left and top values to show the tax details-->
	<div id="tax_container" style="display:none; position:absolute; z-index:1px;"></div>
	<!--同步库存，加载框-->
	<div id="divId" class="veil_newnobg" style="position:absolute;width:100%;display:none;top:0px;left:0px;z-index:9999;">
		<table border="0" cellpadding="0" cellspacing="0" align="center" style="vertical-align:middle;width:100%;height:100%;">
		<tbody><tr>
				<td class="big" align="center">
					<img src="themes/images/plsWaitAnimated.gif"/>
				</td>
			</tr>
		</tbody>
		</table>
	</div>

	<!--合同订单保存后自动创建出库单，如果仓库为禁用弹出框-->
	<div id="outboundorderDiv" class="D_pop_box LdPopWidth400px" style="display:none;">
		<div class="D_pop_tit">
			<strong class="D_ptita">{'SELECTWAREHOUSE'|@getFixedLabel}</strong>
			<a href="javascript:saveOutboundorder(0)" class="D_ptitc">
				<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
			</a>
		</div>
		<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
			<tr>
				<td>
					{'AUTOCREATECHUKUCHAN'|@getFixedLabel}{$WAREHOUSE}{'DISABLEDPLEASECHOOSEWAREHOUSE'|@getFixedLabel}
				</td>
				<td>
					<select name="AfterCreateSalesOrder_CreateOutboundOrder" id="AfterCreateSalesOrder_CreateOutboundOrder">
						{foreach  key=mainlabel item=maindata from=$WAREALL }
							<option value="{$mainlabel}">{$maindata}</option>
						{/foreach}
					</select>
				</td>
			</tr>
		</table>
	 </div>

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