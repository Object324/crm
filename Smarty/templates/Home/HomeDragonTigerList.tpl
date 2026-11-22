<div class="ld_saleskitedit_draw">
    {*    左边栏*}
    <div class="ld_saleskitlist_block" style="width: 310px;">
        <div class="ld_saleskitlist_search">
            <input type="text" class="ld-input-inner ld-input-inner-add" id="dragontiger_searchbox" placeholder="{'INPUTTHEDRAGONTIGERNAME'|@getFixedLabel}">
            <b id="searchIcon" class="ld-icon-search"></b>
        </div>

        <div class="ld_saleskitlist">
            <div style="display: flex;margin: 10px 0;align-items: center">
                <span style="font-size: 13px;color: #8998AC;margin-left: 16px;">{'OperationTip'|@getFixedLabel}</span>
                <b class="icon-homeimg icon-askgrey-help tip-items-list" style="margin: 0 10px;" data-tip="{$OperationTip}"
                   data-type="position" data-direction="right"></b>
                <a id="SortDragonTigerList" class="ld-button ld-button-primary" style="margin: 0 30px 0 auto;">
                    <span>{'SORT'|@getFixedLabel}</span>
                </a>
            </div>
            <div id="dragontigerlist" style="overflow: hidden auto;height: calc(100% - 50px);" class="ld_homeboard_stuff">
                {assign  var="i" value=0}
                {foreach key=StuffLabelType item=ListInfo from=$StuffLabelList}
                    {assign  var="i" value= $i + 1}
                    <div class="ld_homeboard_stuff_title" style="position: sticky;top: 0px;z-index:1;"
                         name="stufflist_title_{$StuffLabelType}" data-type="{$StuffLabelType}">
                        <span>{$i}. {$ListInfo['label']}</span>
                        <i class="icon-develop icon-develop_active" style="float: right;position: relative;top: 18px;"></i>
                    </div>
                    <div class="ld_homeboard_stuff_list " id="stufflabellist_{$StuffLabelType}"
                         name="stufflabellist_{$StuffLabelType}">
                        {if $StuffLabelType eq 'custom'}
                            {assign  var="btnLabel" value= 'ADDCUSTOMDRAGONTIGER'|@getFixedLabel}
                            <div class="ld-button ld-button-primary tip-items-list" style="padding: 0 5px;margin: 14px 14px 0 calc(100% - 164px);text-align: center;width: 150px"
                                 id="addCustomDrangonTigerList" data-tip="{$btnLabel}" data-direction="top" data-type="position"> + {$btnLabel}</div>
                        {/if}
                        <ul id="dragontigerstuff_{$StuffLabelType}">
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
                        <div name="dragontiger_list_notcontent" style="height: 40px;line-height: 40px;text-align:
                        center;display: none;">{'nodata'|@getFixedLabel}</div>
                    </div>
                {/foreach}
            </div>
        </div>
    </div>

    {*    预览面板*}
    <div style="height: 100%;width: calc(100% - 600px);overflow: auto;float: left;background-color: rgb(230, 233, 240);">
        <div class="ld-dragontiger-preview" id="stuff_{$stuffinfo['stuffid']}" style="height: {$stuff_height}">
            <table width="100%" cellpadding="0" cellspacing="0" class="small" style="table-layout: fixed">
                <tr id="maincont_row_{$stuffinfo['stuffid']}">
                    <td colspan="2">
                        {include file="Home/HomeBoardNew_{$stuffinfo['stuffid']}_Content.tpl"}
                    </td>
                </tr>
            </table>
        </div>
    </div>

    {*    右边栏全局设置*}
    <div class="ld_saleskitedit_drawer" style="overflow: hidden auto">
        <div style="height: 50px;">
            <div class="ld_saleskitset_saleskitset" style="width: 100%">{'GLOBALSETTING'|@getFixedLabel}</div>
        </div>

        <div class="ld_saleskitset_layout" style="display: none">

            <div id="StuffDetailSearch">

            </div>
        </div>
    </div>
</div>