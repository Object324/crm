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

<form action="index.php" method="post" name="save_normal_account_rule" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" value="{'AUTOMATICRECOVERYRULE'|@getFixedLabel}" name="auto_recovery_rule_label">
	<input type="hidden" value="{$NORMALID}" name="normal_id">
	<table class="" width="100%" cellspacing="0" cellpadding="0" border="0" name="common_account_rule_table">
		<tbody>
			<tr>
				<td class="pad paddT10" width="40%">
					<div>
						<!--自动回收规则设置-->
						<div name="account_rule_div" class="main_grid_box">
							<div class="grid-analysis-box" style="margin-top: -17px;">
								<div id="picklist_datas" class="cont_wrap clear_float pad10">
								
								<div class="PublicseaSet" style="margin-top:-1px;border: 0px solid #ddd;">
									<ul>
										<li>
											<span class="">{"NORMALCUSTOMRECYCLE"|@getFixedLabel} 
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
														<select onchange="cls_PublicAccount.changeRule('complete','{$ruleinfo.tabname}',this)" name="changerule_complete_{$ruleinfo.tabname}">
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
</form>