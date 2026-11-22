<div id="stuff_{$stuffinfo['stuffid']}" data-boardstuffid="{$stuffinfo['boardstuffid']}" class="ld_homeboard_index_layout_plate_stuff" style="height: {$stuffinfo['height']};">
    <table width="100%" cellpadding="0" cellspacing="0" class="ld_homeboardstuff_E_stripe" style="table-layout: fixed">
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
