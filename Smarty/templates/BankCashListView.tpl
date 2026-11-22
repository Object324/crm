<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/BankCash/BankCash.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
{$STDFILTER_JAVASCRIPT}
<script type="text/javascript">
var datetimestr = '{$datetimestr}';
function displaycondtype_click(keys)
{ldelim}
        var obj = document.getElementById(keys+'_div');
	obj.style.display = (obj.style.display == 'none')?'':'none';
{rdelim}

function setcondtype_click(objid,objname,keys)
{ldelim}	
	document.getElementById('set'+keys).innerHTML = objname+"&nbsp;&nbsp;<img border=0 src='themes/softed/images/arrow_down.gif'>";
	if(keys == 'searchcol')
    {ldelim}
		document.basicSearch.searchcol.value = objid;
	{rdelim}
	document.getElementById(keys+'_div').style.display = 'none';
{rdelim}
</script>

<div class="main_grid lfloat">
	<div class="main_grid_box">
	    <div class="grid-analysis-box">
	        <div class="grid-analysis-header">
	        </div>
	        <div class="cont_wrap clear_float">
				<div id="ledger">
					<!--切换导航-->
					{*hzx 20231215 列表页面页签优化*}
					{include file='ListViewNavBar.tpl'}
					{*<div class="D_Tab_div_more tabHieght" id="tabWareHouse">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
						  <tr>
							<td valign="top" class="L">
								<ul class="Tab_div_more_ul">
									{foreach item=value from=$BANKCASHMENU}
										*}{*BUG0069626 txy 20230726 现金银行流水账，账户增加文字浮显，否则账户名称过长显示省略号无法查看全部显示*}{*
										{if $value.id eq $BANKCASHID}
											<li><a  onclick="getBankCash({$value.id},this);return false;" class="On on tip-items-list" data-tip="{$value.name}" data-direction="top" data-type="position">{$value.name}</a></li>
										{else}
											<li><a  onclick="getBankCash({$value.id},this);return false;" class="tip-items-list" data-tip="{$value.name}" data-direction="top" data-type="position">{$value.name}</a></li>
										{/if}
									{/foreach}
									{if $MOREBANKCASHMENU|@count gt 0}
										{if $MOREBANKID neq ''}
											{assign var=c value='On'}
										{else}
											{assign var=c value='on'}
										{/if} 
										<li>        
										<a id="morebankcashid" class="{$c}">
										{'MORE'|@getFixedLabel}:
										</a>
										</li>		
									{/if}
								</ul>
								{if $MOREBANKCASHMENU|@count gt 0}
									<div id="ware_select_more" class="tab-more">
												{assign var=fldname value='selectbankid'}
													<div id="bankcash_div" style="margin-top: -3px;">
													<select onchange="getMoreBankCash(this,'morebankcashid');return false;" id="selectbankid" name="selectbankid" style="display:none">
													{foreach key=key item=name from=$MOREBANKCASHMENU}
														{if $key eq $BANKCASHID}
															{assign var=optText value=$name}
															<option value="{$key}" selected="true">{$name}</option>   
														{else}
															<option value="{$key}">{$name}</option>   
														{/if}
															
													{/foreach}
													</select>
																			
													<div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','bankcash_div')">
														<a style="width:117px;margin-top: 6px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','bankcash_div')" href="javascript:void(0)" tabindex="-1"
														 name="cmb_a_{$fldname}">
															
															<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0" name="cmb_span_optiontext_selectbankid" onclick="cmb_picklist_end_foucs(event,'selectbankid')" onKeyUp="com_chosen(event,'selectbankid')" value="{$optText}">
															<div>
																<b></b>
															</div>
														</a>
														{assign var="i" value=0}
														<div style=" left:-9000px;width: 117px; top: 32px;z-index:902;" class="chzn-drop" name='dv_drop_{$fldname}' >
															<ul class="chzn-results" name="cmb_ul_{$fldname}">
																{foreach key=key item=name from=$MOREBANKCASHMENU}
																	   
																	<li  class="active-result" style="padding: 6px 7px;" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}','bankcash_div')" onmouseover="cmb_limouseover(event,'{$fldname}','bankcash_div')">{$name}</li>
																	{assign var="i" value=$i+1}
																{/foreach}

																<li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
															 </ul>
														</div>
													</div> 
												 
													{if $show eq 1}
													<a class="icon-range" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}"  onclick="SmOwnerScopehightuser()"></a>
													{/if}
													</div>
									</div>
								{/if}
							</td>
						  </tr>
						</table>
					</div>*}
					<table border=0 cellspacing=0 cellpadding=0 width=100% align=center>  
						<tr>
					        <td>     
					        <div class="D_search">
					            <ul>
					            <li><span><font style="font-weight:bold;">{'DURINGQUERY'|@getFixedLabel}</font></span></li>
					            <li>
					                <select class="salesgoaltimeselect btn-radius-system" name="stdDateFilter" id="stdDateFilter" class="select" onchange='showDateRangeFor(this.options[this.selectedIndex].value )'>
										{assign var=special value='/\d+/'}
										{assign var=normal_last value='/last/'}
										{assign var=normal_before value='/before/'}
										{assign var=normal_next value='/next/'}     
					                    {foreach item=duration from=$STDFILTERCRITERIA}
					                        {assign var=last15day value='last15days'|@getFixedlabel}
											{if isset($duration) && isset($duration.text)}
												{if preg_match($special, $duration.text)}
													{assign var=normal_number value=$matches[0]}
													{if $normal_last|preg_match:$duration.text eq 1} 
															<option {$duration.selected} value={$duration.value}>{'LAST'|@getFixedLabel}{$normal_number}{'Days'|@getFixedLabel}</option>
															
													{elseif $normal_before|preg_match:$duration.text eq 1}
															<option {$duration.selected} value={$duration.value}>{$normal_number}{'DAYSAGO'|@getFixedLabel}</option>
													{elseif $normal_next|preg_match:$duration.text eq 1}
															<option {$duration.selected} value={$duration.value}>{'FUTURE'|@getFixedLabel}{$normal_number}{'Days'|@getFixedLabel}</option>
													{else}
															<option {$duration.selected} value={$duration.value}>{$normal_number}{'AFTERDAY'|@getFixedLabel}</option>
													{/if}
												{else}
													<option {$duration.selected} value={$duration.value}>{$duration.text|@getFixedLabel}</option>
												{/if}
											{/if}
					                    {/foreach}
					                 </select>
					            </li>
					            <li>
					                <span><input name="startdate" id="startdate" class="Wdate maxWidth160 WdateImage" tabindex="" id="jscal_field_createdate" type="text" style="border:1px solid #bababa;height:30px;"  fieldonly='0'  size="15" maxlength="11" value="{$FIRSTDAY}" onClick="WdatePicker()"/></span>
					            </li>
					            <li><span>{'TO'|@getFixedLabel}</span></li>
					            <li>
					                <span><input name="enddate" id="enddate" tabindex="" id="jscal_field_enddate" type="text" style="border:1px solid #bababa;height:30px;" fieldonly='0' size="15" maxlength="11" value="{$LASTDAY}" onClick="WdatePicker()" class="Wdate maxWidth160 WdateImage"/></span>
					            </li>
					            <li>
									<div class="ld-button ld-button-primary" onclick="submitfrom()">
										{'GENERATIONOFCURRENTACCOUNT'|@getFixedLabel}
									</div>
									<div class="ld-button" onclick="exportback('index.php?module={$MODULE}&action={$MODULE}Ajax&file=ExportBankCash&bankid={$BANKCASHID}&stdDateFilter={$SELCRITERIA}&startdate={$FIRSTDAY}&enddate={$LASTDAY}&hiddenledger={$LEDGER}&bankcashid=')">
										{'EXPORT'|@getFixedLabel}
									</div>
					            </li>
					            </ul>
					            <div class="clear"></div>
					            <input type="hidden" value="1" id="hiddenledger" name="hiddenledger" />
					        </div>
					        </td>
					    </tr>
					</table>
					<div id="bankcash_content">
						{include file='BankCashListViewEntries.tpl'}
					</div>
				</div>	            
	        </div>
	    </div>
	</div>
</div>

<script>
	var Listpagepopupobj=new CrmPopup();
	Listpagepopupobj.type="listpage";
	Listpagepopupobj.divid='tabWareHouse';
	CrmPopup.global_listPopupObj.push(Listpagepopupobj);

	ld('.main_grid .main_grid_box').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) +'px');
	{*BUG0069626 txy 20230726 现金银行流水账，账户增加文字浮显，否则账户名称过长显示省略号无法查看全部显示*}
	{literal}
	tooltip('.tip-items-list', {transition: true, time: 200});
	{/literal}

</script>