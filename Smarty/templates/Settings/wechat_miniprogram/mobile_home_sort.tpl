<div class="E_pop_tit">
    <strong class="E_ptita">{'reportsort'|@getFixedLabel}</strong>
    <a href="javascript:fninvshnew('sortview');" class="E_ptitc">
        <img class="E_ptitcimg" src="themes/icon/pop_close.png" id="colse_mobile_block_sort"
             alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
    </a>
</div>
<table class="D_pop_bod bgwhite" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
    <tr>
        <td>
            <input type="hidden" name="selectedColumnsString2">
            <select id="selectedColumns2" multiple="" class="selectedColumns2" onchange="selectedColumnClick(this);"
                    name="selectedColumns2" size="10">
                {foreach item=blockinfo key=blockid from=$ALLBLOCKS}
                    <option value="{$blockid}">{$blockinfo.blockname}</option>
                {/foreach}
            </select>
        </td>
        <td align='center' width="30">
            <a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFIxedLabel}"
               onclick="ModuleDetailmoveUp('selectedColumns2')"></a>
            <a class="icon-newhomearr icon-mdown" style="margin-top: 15px;" href="javascript:;"
               title="{'MOVEDOWN'|@getFIxedLabel}" onclick="ProductDetailmoveDown('selectedColumns2')"></a>
        </td>
    </tr>
</table>

<div class="E_pbtn">
    <input type="button" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}"
           id="save_mobile_block_sort"/><span>&nbsp;</span>
    <input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" id="cancel_mobile_block_sort"/>
</div>