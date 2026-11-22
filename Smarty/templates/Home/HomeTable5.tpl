<table width="100%" cellpadding="0" cellspacing="0" class="small">
            		<tr class=''>
            			<td>

            				<div style="overflow-y: auto; overflow-x:hidden;width:100%;cursor:auto;"> 
            				    <div style="width:98%;margin:0 auto;">
                                    <div>
                                        <div class="datalist">
                                            <ul>
												{foreach key=labeltype item=monthweek from=$HOME_STUFF.data}
												
													{foreach key=labelbol item=row from=$monthweek}
														{if $labelbol eq $CURWEEKMONTH}
															<li label-type="{$labelbol}" style="width: {$CSSWIDTH}%;">
														{else}
															<li label-type="{$labelbol}" style="width: {$CSSWIDTH}%; display:none;">
														{/if}
															<h3>{$row.label}</h3>
															<h5 class="up"><a href="javascript:void(0)" onclick="setSalesKitTragetUrl('{$labeltype}','cur')" title="">{$row.value}</a></h5>
															<div class="data">
																<p>
																	<span>{$row.lastlabel}：<a href="javascript:void(0)" onclick="setSalesKitTragetUrl('{$labeltype}','last')" title="">{$row.lastvalue_span}</a></span>
                                </p>
                                <p>
																	<span class="chainnnumspan">
																		{'CHAINHOMEMONTH'|@getFixedLabel}
																		：
																		{if $row.lastvalue eq 0}
																			<b class="red">{$row.mom|@dateformat}</b>
																		{else}                                                                
																			{if $row.mom ge 0}
																			<b class="red">
																			{else}
																			<b class="green">-
																			{/if}
																			{$row.mom|@dateformat}
																			</b>
																		{/if}
																	</span>
																</p>
															</div>            
														</li>
													{/foreach}
												{/foreach}
                                              </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
            			</td>
            	    </tr>
            	</table>