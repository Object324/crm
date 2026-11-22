<div id="stuff_{$stuffinfo['stuffid']}" data-boardstuffid="{$stuffinfo['boardstuffid']}" class="ld_homeboard_index_layout_plate_stuff" style="height: {$stuffinfo['height']};">
    <table width="100%" cellpadding="0" cellspacing="0" class="E_stripe" style="table-layout: fixed">
        <tr id="headerrow_{$stuffinfo['stuffid']}" >
            <th class="ld-stuff-tit">
                <div class="ld-stuff-tit-name tip-items-list" style="float: left; "
                     data-tip="{$stuffinfo['StuffLabel']}" data-direction="top" data-type="position">
                    <span class="icon-bluelt"></span>
                    {$stuffinfo['StuffLabel']}
                </div>
            </th>
            <th colspan="2" class="ld-stuff-tit" align="right">
                {if $stuffinfo['stuff_url']['url'] neq ''}
                    <a style="height: 25px; margin-right: 8px;float: right; font-size:12px; color:#999;font-weight:normal;"
                       title="{'MORE'|getFixedLabel}" onclick="home_href('{$stuffinfo['stuff_url']['url']}','{$stuffinfo['stuff_url']['page_addurl']}')"
                       href="javascript:;" id="a_{$stuffinfo['stuffid']}">
                        {'MORE'|getFixedLabel}
                        <b class="home_next"></b>
                    </a>
                {/if}
                <div style="display:flex;justify-content: flex-end;">
                    {if 'SalesGoal'|@isPermitted:"EditView" eq 'yes' or 'SalesGoal'|@isPermitted:"Create" eq 'yes'}
                    <span class="Stuff_ManageSalesgoal" onclick="SalesGoalManage()">{'MANAGEINDICATORS'|@getFixedLabel}</span>
                    {/if}
                    <a style="height: 25px; margin-right: 8px; font-size:12px; color:#999;font-weight: normal;display: inline-block;"
                       title="{'MORE'|getFixedLabel}" href="#" id="a_{$stuffinfo['stuffid']}" onclick="SalesRankings({$stuffinfo['stuffid']})">
                        {'MORE'|getFixedLabel}
                        <b class="home_next"></b>
                    </a>
                </div>
            </th>
        </tr>
    </table>
    <table width="100%" cellpadding="0" cellspacing="0" class="small" style="table-layout: fixed !important;">
        <tr id="maincont_row_{$stuffinfo['stuffid']}">
            <td colspan="2">
                <div class="salestarget-tab" id="sales_target_tab">
                    <div class="tab" >
{*                        {$PageTabHtml}*}
                    </div>
                </div>
                {if $stuffinfo['stuffid'] eq 101}
                    <div style="height: {$stuff_con_height};" class="ld_stuffcontent">
                        <div id="stuffcont_{$stuffinfo['stuffid']}" class="ld_stuffcont"
                             style="width:65%;height: {$stuff_con_height};">
                        </div>
                        {include file="Home/HomeBoardNew_101_LabelCon.tpl"}
                    </div>
                {else}
                    <div id="stuffcont_{$stuffinfo['stuffid']}" class="ld_stuffcont"
                         style="overflow-y: auto; overflow-x:hidden;
                            width:100%;height: {$stuff_con_height};">
                    </div>
                {/if}
            </td>
        </tr>
    </table>
</div>