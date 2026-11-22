{*<div class="main_grid lfloat main_grid_list">*}
{*    <div class="main_grid_top">*}
{*            {include file='ListViewBtnAndSeachChuantou.tpl'}*}
{*            <div class="clear"></div>*}
{*        </div>*}
{*    <div class="main_grid_box">*}
            <div class="grid-analysis-box">
                <div class="grid-analysis-header">
                </div>
                <div class="cont_wrap clear_float">
                    <div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
                        <div style=" visibility: visible; top: 194px;overflow:hidden" id="resize_header_table_divid" name="resize_header_table_divid">
                            <div  style="float:left; padding:0 10px;padding-right: 20px;">
                                <table class="listEntries fir-center" id="resize_header_tableid" name="resize_header_tableid" border="0" cellspacing="1" cellpadding="0" style="width:{$TOTALWIDTH}px">
                                    <tr>
                                        {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                            <th style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule="{$HEADERMODULE[$i]}" headername="{$HEADERNAME[$i]}" >{$header}</th>
                                        {/foreach}
                                    </tr>
                                </table>
                            </div>
                        </div>
                        {*wym BUG0073992 需要name属性找到该元素绑定事件*}
                        <div style="overflow:auto;height:300px;padding:0 10px" id="resize_content_table_divid" name="resize_content_table_divid">
                            <table class="listEntries fir-center marT-53" id="resize_content_tableid" name="resize_content_tableid" style="width:{$TOTALWIDTH}px;" border="0" cellspacing="1" cellpadding="0" >
                                <tr name="tr_header">
                                    {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                        <th style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule='{$HEADERMODULE[$i]}' headername="{$HEADERNAME[$i]}">{$header}</th>
                                    {/foreach}
                                </tr>
                                <tbody id="chuantou_listview_tbody">

                                    {$PROHTML}
                                    {if $MODULE == 'InventoryQuery'}
                                        {if $NUMOFROWS > 0}
                                            <tr bgcolor="white" onmouseout="this.className='lvtColData'" onmouseover="this.className='lvtColDataHover'" id="row_{$entity_id}">
                                                {foreach item=value key=entity_id from=$INVENTORYCOUNT}
                                                    <td align="right">{$value}</td>
                                                {/foreach}
                                            </tr>
                                            <tr bgcolor="white" onmouseout="this.className='lvtColData'" onmouseover="this.className='lvtColDataHover'" id="row_{$entity_id}">
                                                {foreach item=value key=entity_id from=$INVENTORYSUM}
                                                    <td align="right">{$value}</td>
                                                {/foreach}
                                            </tr>
                                        {/if}
                                    {else}
                                        {if $TOTALFLDHTML != ''}
                                            {$TOTALFLDHTML}
                                        {/if}
                                    {/if}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
{*        </div>*}
{*</div>*}
