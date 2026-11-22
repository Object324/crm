{assign var=listtable_ui_type value=484|@getSys_deploy}
<div id="PrompLeftCenter">
<div class="PrompLeft" style="width: 15%;">
    <input type="hidden" name="alluserid" id="alluserid" value="{$ALLUSERID}" />
    <input type="hidden" name="allmonth" id="allmonth" value="{$ALLYEARMOUTH}" />
    <input type="hidden" name="record_str" id="record_str" value="{$record_str}" />
    <input type="hidden" name="groupid_str" id="groupid_str" value="{$groupid_str}" />
    <input type="hidden" name="modulename" id="modulename" value="{$modulename}" />
    <input type="hidden" name="module_look" value="{$MODULELOOK}">
    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="background:#ddd" class="{if $listtable_ui_type['deploy_value'] eq 2}ld-list-contnet-noline{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if}">
        <tr >
            <th style="line-height: 25px;" {if $isshowgroup eq 'yes'}colspan="2"{/if} >{'MONTH'|@getFixedLabel}</th>
        </tr>
        <tr>
            {if $isshowgroup eq 'yes'}
                <td style="line-height: 25px;" >{'Sector'|@getFixedLabel}</td>
                <td style="line-height: 25px;">{'LBL_USERS'|@getFixedLabel}</td>
            {else}
                <td style="line-height: 25px;">{$modulelabel}</td>
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
<div id="listcenter" style="display:block;width: 75%;" class="PrompCenter">
    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="background:#ddd" class="{if $listtable_ui_type['deploy_value'] eq 2}ld-list-contnet-noline{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if}">
        <tr >
            {foreach key = menu_mouth_id item=mouth_id from=$YEARMOUTH}
                <th style="line-height: 51px;" wdith="8&">
                    {$mouth_id}
                </th>
            {/foreach}
        </tr>

        {$SALESGOALINFO}
    </table>
</div>
<div class="PrompRight" style="width: 10%">
    <table width="{$TABLEWIDTHAFTER}%" border="0" cellspacing="0" cellpadding="0" style="background:#ddd" class="{if $listtable_ui_type['deploy_value'] eq 2}ld-list-contnet-noline{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if}">
        <tr>
            <th style="line-height: 51px;">{'SUM'|@getFixedLabel}</th>
        </tr>
        {$SALESGOALSUM}
    </table>
</div>
</div>