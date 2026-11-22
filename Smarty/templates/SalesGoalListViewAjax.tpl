<!--中间-->
            <div class="PrompLeftCenter" >
            	<div class="PrompLeft">
                	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="background:#ddd">
                        <tr>
                            <th colspan="2">{'MONTH'|@getFixedLabel}</th>
                        </tr>
                        <tr>
                            <td colspan="">{'LBL_USERS'|@getFixedLabel}</td>
                            <td colspan="">{'Sector'|@getFixedLabel}</td>
                        </tr>
                        {foreach from=$USERSGROUP key=groupid item=userArr}
                        {assign var='showgrouptotal' value='no'}
                            {foreach from=$userArr item=item}
                            
                                {if $item["userid"]|@array_key_exists:$SHOWUSERID_ARR}
                                    {assign var='showgrouptotal' value='yes'}
                                    {assign var='groupname' value={$item["groupname"]}}
                                    <tr>
                                        <td class="tip-items-goal" data-tip='{$USERS[$item["userid"]]}' data-direction="top" data-type="position">{$USERS[$item['userid']]}</td>
                                        <td class="tip-items-goal" data-tip='{$item["groupname"]}' data-direction="top" data-type="position">{if $item['groupname']}{$item['groupname']}{else}无{/if}</td>
                                    </tr>
                                {/if}
                            {/foreach}
                            {if $showgrouptotal eq 'yes'}
                            <tr ><td colspan="2" class="subtotal"  title='{$groupname}'><b>{'Sector'|@getFixedLabel}{'NETTOTAL'|@getFixedLabel}</b></td></tr>
                            {/if}
                        {/foreach}
                        <tr>
                            <td colspan="2"><b>{'SUM'|@getFixedLabel}</b></td>
                        </tr>
                    </table>
                </div>
                <div class="PrompCenter">
            		<table width="{$TABLEWIDTH}%" border="0" cellspacing="1" cellpadding="0" style="background:#ddd">
                      <tr>
                        {foreach key = menu_mouth_id item=mouth_id from=$YEARMOUTH}
                            <th colspan="3" >
                            {$mouth_id}
                            </th>
                        {/foreach}
                      </tr>
                      <tr class="TrBj">
                        {foreach key = menu_mouth_id item=mouth_id from=$MOUTH}
                            <td>{'TEMPLATETARGET'|@getFixedLabel}</td>
                            <td>{'TEMPLATECOMPLETE'|@getFixedLabel}</td>
                            <td>%</td>
                        {/foreach}
                      </tr>
                      {$USERSALESGOAL}
            		  <tr>
            		  {foreach key = month item=info from=$MONTHTOTAL}
            				<td><div id="listgoal"><b>{if $MODULELOOK neq '' && $MODULELOOK neq 'accountsnumber'}¥{/if}{$info.tolook}</b></div></td>
            				<td><div id="listgoal"><b>{if $MODULELOOK neq '' && $MODULELOOK neq 'accountsnumber'}¥{/if}{$info.complete}</b></div></td>
            				<td></td>
            		  {/foreach}
            		  </tr>
                    </table>
                </div>
                <div class="PrompRight">
            		<table width="129%" border="0" cellspacing="1" cellpadding="0" style="background:#ddd">
                      <tr>
                        <th colspan="3">{'SUM'|@getFixedLabel}</th>
                      </tr>
                      <tr class="TrBj">
                        <td>{'TEMPLATETARGET'|@getFixedLabel}</td>
                        <td>{'TEMPLATECOMPLETE'|@getFixedLabel}</td>
                        <td>%</td>
                      </tr>
                      {$USERSALESGOALSUM}
            		  <tr>
                        <td><div id="listgoal"><b>{if $MODULELOOK neq '' && $MODULELOOK neq 'accountsnumber'}¥{/if}{$USERSALESGOALSUMALL.tolook}</b></div></td>
                        <td><div id="listgoal"><b>{if $MODULELOOK neq '' && $MODULELOOK neq 'accountsnumber'}¥{/if}{$USERSALESGOALSUMALL.complete}</b></div></td>
                        <td><b>{$total_complete}</b></td>
                      </tr>
                    </table>
                </div>
            </div>