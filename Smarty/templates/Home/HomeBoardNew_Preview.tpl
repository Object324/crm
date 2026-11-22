
<div id="stuff_{$stuffinfo['stuffid']}" data-boardstuffid="{$stuffinfo['boardstuffid']}" data-stuffid="{$stuffinfo['stuffid']}"
     data-stuffstyle="{$stuffinfo['stufftype']}" data-stuffliststyle="{$stuffinfo['stufflisttype']}"
     name="homeboard_draw_block_stuff" class="ld_homeboard_draw_block_stuff" style="overflow: hidden;height: {$stuffinfo['height']};">
    <input value="{$stuffinfo['stufftitle_zh']}" type="hidden" id="stuff_label_zh_{$stuffinfo['stuffid']}">
    <input value="{$stuffinfo['stufftitle_en']}" type="hidden" id="stuff_label_en_{$stuffinfo['stuffid']}">
    <div class="ld_homeboard_draw_block_stuff_close" data-stuffid="{$stuffinfo['stuffid']}" data-stuffstyle="{$stuffinfo['stufftype']}">
        <i class="icon_close"></i>
    </div>
    <div class="MatrixLayer_row" style="overflow: hidden;">
        <table width="100%" cellpadding="0" cellspacing="0" class="E_stripe">
            {include file="Home/HomeBoardNew_{$stuffinfo['stuffid']}_Head.tpl"}
        </table>
        <table width="100%" cellpadding="0" cellspacing="0" class="small" style="table-layout: fixed !important;">
            <tr id="maincont_row_{$stuffinfo['stuffid']}">
                <td colspan="2">
                    {include file="Home/HomeBoardNew_{$stuffinfo['stuffid']}_Content.tpl"}
                </td>
            </tr>
        </table>
    </div>
</div>