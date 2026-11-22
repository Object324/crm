<link type="text/css" href="themes/softed/CustomEchartsStyle.css" rel="stylesheet">
<div class="ld_saleskitedit_draw">
    {*    左边栏*}
    <div class="ld_saleskitlist_block" style="width: 310px;">
        <div class="ld_saleskitlist_search">
            <input type="text" class="ld-input-inner ld-input-inner-add" id="StuffDetailSearchbox" placeholder="{'SearchGaugeName'|@getFixedLabel}">
            <b id="searchBtn" class="ld-icon-search"></b>
        </div>

        <div class="ld_saleskitlist">
            <div style="display: flex;margin: 10px 0;align-items: center">
                <span style="font-size: 13px;color: #8998AC;margin-left: 16px;">{'OperationTip'|@getFixedLabel}</span>
                <b class="icon-homeimg icon-askgrey-help tip-items-list" style="margin: 0 10px;" data-tip="{$OperationTip}"
                   data-type="position" data-direction="right"></b>
            </div>
            <div id="StuffDetailList" style="overflow: hidden auto;height: calc(100% - 50px);" class="ld_homeboard_stuff">
                {assign  var="i" value=0}
                {foreach key=StuffLabelType item=ListInfo from=$StuffLabelList}
                    {assign  var="i" value= $i + 1}
                    <div class="ld_homeboard_stuff_title" style="position: sticky;top: 0px;z-index:1;" blocksatus="expand"
                         name="stufflist_title_{$StuffLabelType}" data-type="{$StuffLabelType}">
                        <span>{$i}. {$ListInfo['label']}</span>
                        <i class="icon-develop icon-develop_active" style="float: right;position: relative;top: 18px;"></i>
                    </div>
                    <div class="ld_homeboard_stuff_list " id="stufflabellist_{$StuffLabelType}"
                         name="stufflabellist_{$StuffLabelType}">
                        {if $StuffLabelType eq 'custom'}
                            {assign  var="btnLabel" value= 'NewCustomTargetAnalysis'|@getFixedLabel}
                            <div class="ld-button ld-button-primary div-text-hidden tip-items-list" style="padding: 0 5px;margin: 14px 14px 0 calc(100% - 164px);text-align: center;width: 150px"
                                 id="addCustomStuffDetail" data-tip="{$btnLabel}" data-direction="top" data-type="position"> + {$btnLabel}</div>
                        {/if}
                        <ul id="stufflabellist_ul_{$StuffLabelType}">
                            {foreach key=StuffLabel item=StuffLabelInfo from=$ListInfo['list']}
                                <li class="ld_saleskitlist_stuff drag-handle {if $StuffLabelInfo.selected eq 'yes'}ld-dragontigerlist-shadow {else}{if $StuffLabelInfo.is_default neq 'yes'}ld-dragontigerlist-deleted{/if}{/if}"
                                    id="{$StuffLabelInfo.stufflabel}" style="cursor: pointer">
                                    <span class="tip-items-list" data-tip="{$StuffLabelInfo.label}" data-direction="top" data-type="position">
                                        {$StuffLabelInfo.label}
                                    </span>
                                    <span class="tag"  {if $StuffLabelInfo.selected eq 'yes'}style="display: block;"{/if}>
                                        <i class="check"></i>
                                    </span>
                                    {if $StuffLabelInfo.is_default neq 'yes'}
                                        <span class="tag-close" >
                                            <i class="icon-close"></i>
                                        </span>
                                    {/if}
                                </li>
                            {/foreach}
                        </ul>
                        <div name="stuffdetail_notcontent" style="height: 40px;line-height: 40px;text-align:
                        center;display: none;">{'nodata'|@getFixedLabel}</div>
                    </div>
                {/foreach}
            </div>
        </div>
    </div>

    <!--中间栏 saleskitview-->
    <div style="height: 100%;width: calc(100% - 600px);overflow: auto;float: left;">
        <div class="ld_targetanalysis" id="saleskitview" style="">
            <div class="ld_targetanalysis_NavBar" id="TargetNavBar"></div>
            <div class="ld_targetanalysis_list" id="GaugeList">
                <div id="emptyStuffDetail" class="ld_targetanalysis_stuff stuffDetailDiv ld_saleskitview_stuff_new">
                    <div name="blankstuff_new" class="keepcenter" style="width: 100%;height: 100%;">+{'DragTargetAnalysis'|@getFixedLabel}</div>
                </div>
            </div>
        </div>
    </div>

    {*    右边栏全局设置*}
    <div id="StuffDetailSet" class="ld_saleskitedit_drawer" style="overflow: hidden auto">
        <div id="StuffDetailSetHead" class="StuffDetailSetHead" style="">

        </div>
        <div id="StuffDetailSet_LayoutSet" class="ld_saleskitset_layout">
            <div class="FieldBlock">
                <div class="marT10 FieldLabel Mandatory justifynormal">
                    <span>{'GaugeRowNum'|@getFixedLabel}</span><span style="color:#979797">({'PC'|@getFixedLabel}) </span>
                </div>
                <div class="marT5 marB15 FieldCon">
                    <select class="Bornone FieldConText" id="saleskitset_layout_col" style="height: 30px;width: 100%;background:#F5F8FC;padding-left: 10px;">
                        <option >{if $boardtype neq 'MobileReport'||$boardtype neq 'prmMobileHome'}3{else}1{/if}</option>
                    </select>
                </div>
            </div>
            {if $boardtype neq 'MobileReport'||$boardtype neq 'prmMobileHome'}
            <div class="FieldBlock">
                <div class="FieldLabel Mandatory justifynormal">
                    <span>{'RowHeight'|@getFixedLabel}</span><span></span>{*每行简报高度*}
                </div>
                <div class="marT5 marB15 FieldCon bgF5F8FC bordertadius4">
                    <input type="number" max="230" min="120" id="saleskitset_layout_height" class="detailedViewTextBox Bornone FieldConText hlineheight30" style="width: 100%;
                    background:#F5F8FC;" value="{$LayoutSetInfo.height}">
                    <div class="height-arrow">
                        <div class="height-arrow-up left-3"></div>
                        <div class="height-arrow-down left-3"></div>
                    </div>
                </div>
            </div>
            {/if}
        </div>

        <div id="StuffDetailSet_GaugeSet" class="ld_saleskitset_layout" style="display: none">
            <div id="emptyTip" class="keepcenter" style="margin:20px auto;">{'ClickGaugeToSet'|@getFixedLabel}</div>
            <div id="StuffDetailSetDiv">

            </div>
        </div>
    </div>
</div>



