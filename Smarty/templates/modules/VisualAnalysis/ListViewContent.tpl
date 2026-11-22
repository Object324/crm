<div class="ld_VisualAnalysis_middle">
    {if $SHOWTYPE eq 'Card'}
        {foreach key=BoardType item=BoardTypeInfo from=$BOARDTYPELIST}
            <div {if $BOARDTYPECHOOSEN eq $BoardType} class="ld_VisualAnalysis_ChoosenColor" {/if}
                    name="{$BoardType}" title="{$BoardTypeInfo.label}" onclick="BoardListByType(this)">
                <span class="board_pre" >#</span>
                {$BoardTypeInfo.label}
                <span class="board_num" style="">{$BoardTypeInfo.num|@count}</span>
            </div>
        {/foreach}
    {/if}
</div>
<div class="main_grid_box ld_VisualAnalysis_box">

{if $SHOWTYPE eq 'Card'}


        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float ld_VisualAnalysis_listview_table" id="VisualAnalysis_listview_table" style="overflow-y: auto">
                {if $HomeboardList|@count gte 1}
                    {foreach key=boardid item=homeboard_info from=$HomeboardList}
                        <div class="ld_VisualAnalysis_listview_Card" onclick="Homeboard_changing_over({$boardid});
                            SaveBoardOperate(this,{$boardid},'view');">
                            <div class="ld_VisualAnalysis_listview_Card_div_img">
                                <img src="{$homeboard_info.icon_path}" alt="">
                            </div>
                            <div class="ld_VisualAnalysis_listview_Card_div_title">
                                {$homeboard_info.boardname}
                                {if $homeboard_info.isCollect eq 'no'}
                                    <div class="ld_VisualAnalysis_collection_div tip-items-list"
                                         data-tip="{'COLLET'|@getFixedLabel}" data-direction="top" data-type="position"
                                         data-tiptype="remain" onclick="Collect_div_click(event)">
                                        <span class="ld_VisualAnalysis_collection ld_VisualAnalysis_collect " value="no"
                                        onclick="SaveBoardOperate_Collect(this,event,{$boardid},'collect');">
                                        </span>
                                    </div>
                                {else}
                                    <div class="ld_VisualAnalysis_collection_div tip-items-list"
                                         data-tip="{'UNCOLLET'|@getFixedLabel}" data-direction="top" data-type="position"
                                         data-tiptype="remain" onclick="Collect_div_click(event)">
                                        <span class="ld_VisualAnalysis_collection ld_VisualAnalysis_collected" value="yes"
                                              onclick="SaveBoardOperate_Collect(this,event,{$boardid},'collect');">
                                        </span>
                                    </div>
                                {/if}

                            </div>
                            <div class="ld_VisualAnalysis_listview_Card_div_note" title="{$homeboard_info.description}">
                                {$homeboard_info.description}
                            </div>
                            <div class="ld_VisualAnalysis_listview_Card_div_time">
                                {$homeboard_info.modifiedby} &nbsp;&nbsp;&nbsp; {$homeboard_info.modifiedtime}
                            </div>
                            <div class="ld_VisualAnalysis_listview_Card_div_operate">
                                {if $PERMITARR.EditView eq 'yes'}
                                    <div class="tip-items-list"
                                         data-tip="{'EDIT'|@getFixedLabel}" data-direction="top" data-type="position">
                                        <i class="ld-fonticon ld-fonticon-edit" onclick="CardBoardOperate(event,this,{$boardid},'edit','{$homeboard_info.boardtype}')" style="font-size: 20px;"></i>
                                    </div>


                                {/if}
                                {if $PERMITARR.Allocate eq 'yes'}
                                    <div class="tip-items-list"
                                         data-tip="{'ALLOCATE'|@getFixedLabel}" data-direction="top" data-type="position">
                                        <i class="ld-fonticon ld-fonticon-allocate" onclick="CardBoardOperate(event,this,{$boardid},'scope','{$homeboard_info.boardtype}')"
                                           homeboard_scope_{$boardid} = "{$homeboard_info.scope}"
                                           homeboard_scopeid_{$boardid} = "{$homeboard_info.scopeid}" style="font-size: 20px;"></i>
                                    </div>
                                {/if}
                                {if $PERMITARR.Delete eq 'yes'}
                                    <div class="tip-items-list"
                                         data-tip="{'DELETE'|@getFixedLabel}" data-direction="top" data-type="position">
                                        <i class="ld-fonticon ld-fonticon-del" onclick="CardBoardOperate(event,this,{$boardid},'delete','{$homeboard_info.boardtype}')" style="font-size: 20px;"></i>
                                    </div>
                                {/if}
                            </div>
                        </div>
                    {/foreach}
                {else}
                    <div class="warningTableContent" style="z-index:600;padding-top:30px;">
                        <div class="wtc_img" style="margin: auto;text-align: center;">
                            <img src="themes/icon2023/ld-no-records.png"></div>
                        <div class="wtc_content" style="text-align: center;">{'NODATAFOUND'|@getFixedLabel}</div>
                    </div>
                {/if}
            </div>
        </div>

{elseif $SHOWTYPE eq 'List'}

        <div class="ld_VisualAnalysis_pagetype">
{*            <div name="basicsearch">*}
            {*<div class="ld-listview-basicsearch ld_VisualAnalysis_pagetype_search">
                <input type="text" class="commonSelectPop gwidth100 padR40" id="BoardSearchValue_2"
                       placeholder="{'SEARCHKEYWORDS'|@getFixedLabel}" onkeyup="SearchBoardSubmit(event,
                           this)" value="" autocomplete="off" style="border-radius:
                            4px 4px 4px 4px;
                           padding-right:40px;">
                <b style="position: absolute;right:21px;top:0;cursor: pointer;display:none"
                   class="ld-icon-clearsearch" onclick="clearBoardSearch(this);"></b>
                <b class="icon-categorybtn categorysear-search ld-listview-search" onclick="SearchBoard(this)"></b>
                <div style="position: absolute;right:0;top:30px;width:100%;background-color: #fff;z-index:902;">
                    <ol class="D_more_menua" id="basicSearchList">
                    </ol>
                </div>
            </div>*}
{*            </div>*}
            {foreach key=BoardType item=BoardTypeInfo from=$BOARDTYPELIST}
                <div {if $BOARDTYPECHOOSEN eq $BoardType} class="ld_VisualAnalysis_ChoosenColor" {/if}
                        name="{$BoardType}" title="{$BoardTypeInfo.label}" onclick="BoardListByType(this)" class="BoardType">
                    <span class="Icon_img"></span>
                    <span class="board_pre" >#</span>
                    <span class="board_type">
                        {$BoardTypeInfo.label}
                    </span>
                    <span class="board_num" style="">{$BoardTypeInfo.num|@count}</span>
                </div>
            {/foreach}
        </div>
        {assign var=listtable_ui_type value=484|@getSys_deploy}
        <div class="grid-analysis-box ld_VisualAnalysis_page_box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float ld_VisualAnalysis_listview_table" >
                <div id="resize_header_table_divid" name="resize_header_table_divid" style="overflow: hidden;">
                    <div>
                        <table border=0 cellspacing=0 cellpadding=0 width=100% class="{if $listtable_ui_type['deploy_value'] eq 2}ld-list-contnet-noline{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if} settingTable fir-center ld_VisualAnalysis_table">
                            <tr>
                                {foreach key=i item=headerInfo from=$LIST_HEADER}
                                    {assign var="width" value=$headerInfo.width}
                                    {assign var="label" value=$headerInfo.label}
                                    <th align="left" title="{$label}" style="width: {$width}">{$label}</th>
                                {/foreach}
                            </tr>
                        </table>
                    </div>
                </div>
                <div id="resize_content_table_divid" name="resize_content_table_divid" style="overflow-y: auto;overflow-x: hidden;">
                    <table border=0 cellspacing=0 cellpadding=0 width=100% class="{if $listtable_ui_type['deploy_value'] eq 2}ld-list-contnet-noline{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if} settingTable fir-center ld_VisualAnalysis_table">
                        {if $HomeboardList|@count gte 1}
                            {assign var="i" value=0}
                            {foreach key=boardid item=homeboard_info from=$HomeboardList}
                                {assign var="i" value=$i+1}
                                {if $i mod 2 eq '0'}
                                    <tr id="setting_{$i}" name="setting_board_{$boardid}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                                        {else}
                                    <tr id="setting_{$i}" name="setting_board_{$boardid}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                                {/if}
                                    <td align="" style="width: {$LIST_HEADER[0]['width']}">
                                        {if $homeboard_info.isCollect eq 'no'}
                                            <div class="ld_VisualAnalysis_collection_div tip-items-list"
                                                 data-tip="{'COLLET'|@getFixedLabel}" data-direction="top" data-type="position"
                                                 data-tiptype="remain" onclick="Collect_div_click(event)">
                                            <span class="ld_VisualAnalysis_collection ld_VisualAnalysis_collect " value="no"
                                                  onclick="SaveBoardOperate_Collect(this,event,{$boardid},'collect');">
                                            </span>
                                            </div>
                                        {else}
                                            <div class="ld_VisualAnalysis_collection_div tip-items-list"
                                                 data-tip="{'UNCOLLET'|@getFixedLabel}" data-direction="top" data-type="position"
                                                 data-tiptype="remain" onclick="Collect_div_click(event)">
                                            <span class="ld_VisualAnalysis_collection ld_VisualAnalysis_collected" value="yes"
                                                  onclick="SaveBoardOperate_Collect(this,event,{$boardid},'collect');">
                                            </span>
                                            </div>
                                        {/if}
                                        <a onclick="Homeboard_changing_over({$boardid}); SaveBoardOperate(this,{$boardid},'view');">
                                            <span title="{$homeboard_info.boardname}">{$homeboard_info.boardname}</span>
                                        </a>
                                    </td>
                                    <td style="width: {$LIST_HEADER[1]['width']}">{$homeboard_info.description}</td>
                                    <td style="width: {$LIST_HEADER[2]['width']}">{$homeboard_info.modifiedby}</td>
                                    <td style="width: {$LIST_HEADER[3]['width']}">{$homeboard_info.modifiedtime}</td>
                                    <td style="width: {$LIST_HEADER[4]['width']}">
                                        {if $PERMITARR.EditView eq 'yes'}
                                            <a class="Anu3_a" href="javascript:void(0)" onclick="editHomeboard({$boardid},'{$homeboard_info.boardtype}')">{'EDIT'|@getFixedLabel}</a>
                                        {/if}
                                        {if $PERMITARR.Allocate eq 'yes'}
                                            <a class="Anu3_a" href="javascript:void(0)" onclick="homeboardlist_scope({$boardid},this,'{$homeboard_info.boardtype}')"
                                               homeboard_scope_{$boardid} = "{$homeboard_info.scope}"
                                               homeboard_scopeid_{$boardid} = "{$homeboard_info.scopeid}">
                                                {'ALLOCATE'|@getFixedLabel}
                                            </a>
                                        {/if}
                                        {if $PERMITARR.Delete eq 'yes'}
                                            <a class="Anu3_a redFont" href="javascript:void(0)" onclick="deleteHomeboard({$boardid},'{$homeboard_info.boardtype}')">{'DELETE'|@getFixedLabel}</a>
                                        {/if}
                                        <input type="hidden" id="homeboard_scope_{$boardid}" value="{$homeboard_info.scope}">
                                        <input type="hidden" id="homeboard_scopeid_{$boardid}" value="{$homeboard_info.scopeid}">
                                    </td>
                                </tr>
                            {/foreach}

                        {else}
                            <tr class="lvtColData">
                                <td colspan="6" align="center" style="text-align: center !important;">
                                    {'NOTFOUNDANYRECORD'|@getFixedLabel}
                                </td>
                            </tr>
                        {/if}
                    </table>
                </div>
            </div>
        </div>
{/if}

</div>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/tooltip.js"></script>
<script type="text/javascript">

    {literal}

    tooltip('.tip-items-list', {transition: true, time: 200});
    {/literal}

    var SearchValue_2_Obj = ld("#VisualAnalysis_index #BoardSearchValue_2");
    SearchValue_2_Obj.bind('focus',function (){
        SearchValue_2_Obj.addClass('ld-border-color-3b7cff');
    });
    SearchValue_2_Obj.bind('blur',function (){
        SearchValue_2_Obj.removeClass('ld-border-color-3b7cff');
    });
</script>
