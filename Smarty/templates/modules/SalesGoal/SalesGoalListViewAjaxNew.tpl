<!--中间-->
                {assign var=listtable_ui_type value=484|@getSys_deploy}
            	<div class="PrompLeft" style="width:14.8%;">
                	<table width="100%" border="0" cellspacing="0" cellpadding="0" style="background:#ddd" class="{if $listtable_ui_type['deploy_value'] eq 2}ld-list-contnet-noline{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if}">
                        <tr >
                            <th {if $isshowgroup eq 'yes'}colspan="2"{/if} >{'MONTH'|@getFixedLabel}</th>
                        </tr>
                        <tr>
                            {if $isshowgroup eq 'yes'}
                                <td>{'Sector'|@getFixedLabel}</td>
                                <td>{'LBL_USERS'|@getFixedLabel}</td>
                            {else}
                                <td>{$modulelabel}</td>
                            {/if}
                        </tr>
                        {foreach from=$RowHeaderArr item=headerinfo}
                            {if $isshowgroup eq 'yes'}
                                {if $headerinfo.colspan gt 1}
                                    <tr>
                                        <td  {if $headerinfo.linetype eq 'sum'}style="font-weight: bold;"{/if} colspan="{$headerinfo.colspan}" >{$headerinfo.group_label}{$headerinfo.name_label}</td>
                                    </tr>
                                {else}
                                    <tr>
                                        <td class="tip-items-goal" data-tip='{$headerinfo.group_label}' data-direction="top" data-type="position">
                                            {$headerinfo.group_label}
                                        </td>
                                        <td class="tip-items-goal" data-tip='{$headerinfo.name_label}' data-direction="top" data-type="position">
                                            {$headerinfo.name_label}
                                            {if $headerinfo.status eq 'Inactive'}
                                                <span style="color: red;">（{'Quit'|@getFixedLabel}）</span>
                                            {/if}
                                        </td>
                                    </tr>
                                {/if}
                            {else}
                                <tr>
                                    <td {if $headerinfo.linetype eq 'sum'}style="font-weight: bold;"{/if} class="tip-items-goal" data-tip='{$headerinfo.name_label}' data-direction="top" data-type="position">
                                        {$headerinfo.name_label}
                                        {if $headerinfo.status eq 'Inactive'}
                                            <span style="color: red;">（{'Quit'|@getFixedLabel}）</span>
                                        {/if}
                                    </td>
                                </tr>
                            {/if}
                        {/foreach}
                    </table>
                </div>

                <div class="PrompCenter" style="width:70%;">
            		<table width="{$TABLEWIDTH}%" border="0" cellspacing="0" cellpadding="0" style="background:#ddd;table-layout: fixed;" class="{if $listtable_ui_type['deploy_value'] eq 2}ld-list-contnet-noline{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if}">
                      <tr>
                        {foreach key = menu_mouth_id item=mouth_id from=$YEARMOUTH}
                            <th colspan="3" >
                            {$mouth_id}
                            </th>
                        {/foreach}
                      </tr>
                      <tr>
                        {foreach key = menu_mouth_id item=mouth_id from=$MOUTH}
                            <td style="width: {$tdpercent*2}%" >{'TEMPLATETARGET'|@getFixedLabel}</td>
                            <td style="width: {$tdpercent*2}%">{'TEMPLATECOMPLETE'|@getFixedLabel}</td>
                            <td style="width: {$tdpercent}%">%</td>
                        {/foreach}
                      </tr>
                      {$USERSALESGOAL}
            		  <tr>
            		  </tr>
                    </table>
                </div>
                <div class="PrompRight" style="width:15%;">
            		<table width="100%" border="0" cellspacing="0" cellpadding="0" style="background:#ddd" class="{if $listtable_ui_type['deploy_value'] eq 2}ld-list-contnet-noline{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if}">
                      <tr>
                        <th colspan="3">{'SUM'|@getFixedLabel}</th>
                      </tr>
                      <tr>
                        <td>{'TEMPLATETARGET'|@getFixedLabel}</td>
                        <td>{'TEMPLATECOMPLETE'|@getFixedLabel}</td>
                        <td>%</td>
                      </tr>
                      {$USERSALESGOALSUM}

                    </table>
                </div>
