{*<div class="main_grid lfloat main_grid_list">*}
{*    <div class="main_grid_top">*}
{*        {include file='ListViewBtnAndSeachChuantou.tpl'}*}
{*    </div>*}
{*    <div class="main_grid_box">*}
            <div class="grid-analysis-box">
                <div class="grid-analysis-header">
                </div>
                <div class="cont_wrap clear_float" style="margin-left:10px;">
                	<div id="divMapShow" class="divMapShow" style="width:100%; display:none;" >
                		<div class="divMapLeft" id="divMapLeft">
                			
                		</div>
                		<div class="divMapRight">
                			<div id="map_div" name="map_div" style="width:100%;">
                		
                			</div>
                		</div>
                	 </div>
                    <div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;"><!-- style="width:100%;" -->
                        <div style=" visibility: visible; top: 194px;overflow:hidden" id="resize_header_table_divid" name="resize_header_table_divid">
                            <div style="float:left; padding-right:20px;">
                                <table border="0" cellspacing="1" cellpadding="0" name="resize_header_tableid" id="resize_header_tableid" style="width:{$TOTALWIDTH}px" class="listEntries fir-center" >
                                    <tr>
                                        {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                            <th style="width:{$LISTHEADERWIDTH[$i]}px" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}' tag="{$i+1}">{$header}</th>
                                        {/foreach}
                                    </tr>
                                </table>
                            </div>
                        </div>
                        <div style="overflow:auto;height:300px;" id="resize_content_table_divid" name="resize_content_table_divid">
                           
                            <table border="0" cellspacing="1" cellpadding="0" id="resize_content_tableid"  name="resize_content_tableid"  style="width:{$TOTALWIDTH}px" class="listEntries fir-center marT-53" >
                                <thead>
                                <tr name="tr_header">
                                    {foreach name="listviewforeach" item=header key=i from=$LISTHEADER}
                                        <th style="width:{$LISTHEADERWIDTH[$i]}px" tag="{$i+1}" headermodule='{$HEADERMODULE[$i]}' headername='{$HEADERNAME[$i]}'>{$header}</th>
                                    {/foreach}
                                </tr>
                                </thead>
                                {* 产品明细序时簿*}
                                <tbody id="chuantou_listview_tbody">
                                    {$PROHTML}
                                    {if $TOTALFLDHTML != ''}
                                        {$TOTALFLDHTML}
                                    {/if}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
{*        </div>*}
{*</div>*}


