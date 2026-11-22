
<div id="stuff_{$stuffinfo['stuffid']}" data-boardstuffid="{$stuffinfo['boardstuffid']}" data-stuffid="{$stuffinfo['stuffid']}"
     data-stuffstyle="{$stuffinfo['stufftype']}" data-stuffliststyle="{$stuffinfo['stufflisttype']}"
     name="homeboard_draw_block_stuff" class="ld_homeboard_draw_block_stuff" style="overflow: hidden;height: {$stuffinfo['height']};">
    <input value="{$stuffinfo['stufftitle_zh']}" type="hidden" id="stuff_label_zh_{$stuffinfo['stuffid']}">
    <input value="{$stuffinfo['stufftitle_en']}" type="hidden" id="stuff_label_en_{$stuffinfo['stuffid']}">
    <div class="ld_homeboard_draw_block_stuff_close" data-stuffid="{$stuffinfo['stuffid']}" data-stuffstyle="{$stuffinfo['stufftype']}">
        <i class="icon_close"></i>
    </div>
    <div class="MatrixLayer_row" style="overflow: hidden;">
        <table width="100%" cellpadding="0" cellspacing="0" class="E_stripe" style="table-layout: fixed">
            <tr id="headerrow_{$stuffinfo['stuffid']}" >
                <th class="N_con_tit">
                    <div style="float: left;" data-tip="{$stuffinfo['StuffLabel']}" data-direction="top" data-type="position"
                        class="tip-items-list ld-stuff-tit-name">
                        {$stuffinfo['stufftitle_label']}
                    </div>
                </th>
                <th colspan="2" class="N_con_tit" align="right">

                </th>
            </tr>
        </table>
        <table width="100%" cellpadding="0" cellspacing="0" class="small" style="table-layout: fixed">
            <tr id="maincont_row_{$stuffinfo['stuffid']}">
                <td colspan="2">
                    <div class="salestarget-tab" id="sales_target_tab">
                        <div class="tab">
{*                            {include file="Home/HomeBoardNew_40_Content.tpl"}*}
                        </div>
                    </div>
                    {if $stuffinfo['stuffid'] eq 101}
                        <div style="height: {$stuff_con_height};" class="ld_stuffcontent">
                            <div id="preview_stuffcont_{$stuffinfo['stuffid']}" class="ld_stuffcont"
                                 style="overflow-y: auto; overflow-x:hidden;width:100%;height:{$stuff_con_height};">

                            </div>
                            {include file="Home/HomeBoardNew_101_LabelCon.tpl"}
                        </div>
                    {else}
                        <div id="preview_stuffcont_{$stuffinfo['stuffid']}" class="ld_stuffcont"
                             style="overflow-y: auto; overflow-x:hidden;width:100%;height:{$stuff_con_height};">

                        </div>
                    {/if}
                </td>
            </tr>
        </table>
    </div>
</div>