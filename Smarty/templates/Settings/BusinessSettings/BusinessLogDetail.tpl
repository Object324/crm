
<div class="main_grid lfloat main_grid_list">
    <div class="main_grid_top">
        <div class="ld-flex-between gwidth100 ld-flex-wrap" id="resize_popupsearch_div" name="resize_popupsearch_div">
            <div class="ld-flex-start ld-flex-wrap">
                <div >
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td class="ld-form-item-label">
                                <span class="category_span">{'operatoroer'|@getFixedLabel}</span>
                            </td>
                            <td class="ld-form-item-content">
                                <select class="ld-select-inner" id="businessoperator" name="businessoperator" onchange="BusinessInformationobj.SearchBusinesslogDetail();">
                                    <option value="" >{'ALL'|@getFixedLabel}</option>
                                    {foreach item=entityinfo name=listentity key=index from=$operatorarr}
                                        <option value="{$index}" {if $index eq $selectedoperator}selected{/if}>{$entityinfo}</option>
                                    {/foreach}
                                </select>
                            </td>
                            <td class="ld-form-item-label">
                                {'QUERYMETHOD'|@getFixedLabel}
                            </td>
                            <td class="ld-form-item-content">
                                <select class="ld-select-inner" id="businesssearchtype" name="businesssearchtype" onchange="BusinessInformationobj.SearchBusinesslogDetail();">
                                    <option value="" >{'ALL'|@getFixedLabel}</option>
                                    {foreach item=entityinfo name=listentity key=index from=$operationtypearr}
                                        <option value="{$index}" {if $selectedoperationtype eq $index}selected{/if}>{$entityinfo}</option>
                                    {/foreach}
                                </select>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            {*<div class="ld-flex-end ld-flex-wrap" style="margin-left: auto;">
                <!--分页-->
                <div class="PageDiv0">
                    <div class="ld-flex-start" style="position: relative;">
                        <div class="ld-pagenum-div">{$recordListRange}</div>
                        {$NAVIGATION}
                    </div>
                </div>
            </div>*}
        </div>
    </div>
    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float">
                <div id="hdScrolllistentries_yy" name="hdScrolllistentries_yy" style="position: relative;">
                    <div style=" visibility: visible; top: 194px;overflow:hidden" id="resize_header_table_divid" name="resize_header_table_divid">
                        <div  style="float:left; padding:0 10px">
                            <table class="listEntries fir-center" id="resize_header_tableid" name="resize_header_tableid" border="0" cellspacing="1" cellpadding="0" style="width:100%">
                                <tr>
                                    {foreach item=entityinfo name=listentity key=index from=$businessloglistheader_arr}
                                        <th title="{$entityinfo}" width="200" >{$entityinfo}</th>
                                    {/foreach}
                                </tr>
                            </table>
                        </div>
                    </div>
                    <div style="overflow:hidden auto;height:300px;padding:0 10px" id="resize_content_table_divid" name="resize_content_table_divid">
                        <table class="listEntries fir-center marT-53" id="resize_content_tableid" name="resize_content_tableid" style="width:100%;" border="0" cellspacing="1" cellpadding="0" >
                            <tr name="tr_header">
                                {foreach item=entityinfo name=listentity key=index from=$businessloglistheader_arr}
                                    <th title="{$entityinfo}" width="200" >{$entityinfo}</th>
                                {/foreach}
                            </tr>
                            <tbody id="businesslogdetail_tbody">
                            {assign var="listentity" value='1'}
                            {assign var="i" value=0}
                            {foreach item=entityinfo name=listentity key=index from=$businesslogdetailshow_arr}
                                {assign var="j" value=$i++}
                                {if $j mod 2 eq '0'}
                                    <tr id="setting_{$j}"  class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                                        {else}
                                    <tr id="setting_{$j}"  class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                                {/if}
                                {foreach item=keyentityinfo name=tmplistentity key=tmpindex from=$headerkeyarr}
                                        <td width="200">
                                            {$entityinfo[$keyentityinfo]}
                                        </td>
                                {/foreach}
                                </tr>
                                {foreachelse}
                                <tr bgcolor="white">
                                    <td colspan="6" align="center" style="height: 0px;">
                                        {include file="NoRecords.tpl"}
                                    </td>
                                </tr>
                            {/foreach}

                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
