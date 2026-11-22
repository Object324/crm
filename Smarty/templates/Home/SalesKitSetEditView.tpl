<!--左边栏 saleskitlist   中间栏 saleskitview  右边设置栏 saleskitset  布局设置 layout 全局设置set_stuff      -->
<div class="ld_saleskitedit_draw">
    <link type="text/css" href="themes/softed/CustomEchartsStyle.css" rel="stylesheet">
    <!--销售简报列表搜索框-->
    <div class="ld_saleskitlist_block">
        <div class="ld_saleskitlist_search">
            <input type="text" class="ld-input-inner ld-input-inner-add" id="search_saleskitlist" placeholder="{'INPUTTHESALESKITNAME'|@getFixedLabel}" title="{'INPUTTHESALESKITNAME'|@getFixedLabel}">
            <b id="searchBtn" class="ld-icon-search"></b>
        </div>
        <div class="ld_homeboard_stuff" id="saleskitlist_all" name="saleskitlist_all">
            <div style="display: flex;margin: 10px 0;">
                <span style="font-size: 13px;color: #8998AC;margin-left: 16px;">{'OperationTip'|@getFixedLabel}</span>
                <b class="icon-homeimg icon-askgrey-help sort-tip-items" style="margin: 0 10px;" data-tip="{$OperationTip}"
                   data-type="position" data-direction="right"></b>
            </div>
            {assign  var="i" value=0}
            {foreach key=SaleskitType item=ListInfo from=$StuffLabelList}
                {assign  var="i" value= $i + 1}
                <div class="ld_homeboard_stuff_title" style="position: sticky;top: 0px;z-index:1;"
                     name="stufflist_title_{$SaleskitType}" data-type="{$SaleskitType}">
                    <span>{$i}. {$ListInfo['label']}</span>
                    <i class="icon-develop icon-develop_active" style="float: right;position: relative;top: 18px;"></i>
                </div>
                <div class="ld_homeboard_stuff_list saleskitlist" id="saleskitlist_{$SaleskitType}"
                     name="saleskitlist_{$SaleskitType}">
                    {if $SaleskitType eq 'custom'}
                        {assign  var="btnLabel" value= 'NEWCUSTOMSALESKIT'|@getFixedLabel}
                        <div class="ld-button ld-button-primary div-text-hidden sort-tip-items" style="padding: 0 5px;margin: 14px 14px 0 calc(100% - 164px);text-align: center;width: 150px"
                             id="addCustomSaleskit" data-tip="{$btnLabel}" data-direction="top" data-type="position"> + {$btnLabel}</div>
                    {/if}
                    <ul name="saleskitstuff">
                        {foreach key=stufflabel item=saleskitinfo from=$ListInfo['list']}
                            <li class="ld_saleskitlist_stuff {if $saleskitinfo['used'] eq 'yes'}ld_listchosestuff {else}drag-handle{/if} " data-stufflabel="{$stufflabel}">
                                <span class="sort-tip-items" style="cursor: pointer" data-tip="{$saleskitinfo.label}" data-direction="top" data-type="position">
                                    {$saleskitinfo.label}
                                </span>
                                <span class="tag" {if $saleskitinfo['used'] eq 'yes'}style="display: block;"{/if}><i class="check"></i></span>
                                {if $saleskitinfo['is_default'] neq 'yes'}
                                    <span name="saleskit_delete" data-stufflabel="{$stufflabel}"
                                          {if $saleskitinfo['used'] neq 'yes'}class="ld-saleskitview-block-stuff-delete"{/if}><i class="icon-deleted"></i></span>
                                {/if}
                                <div class="ld_saleskitview_block_stuff_close" data-stufflabel="{$stufflabel}"><i class="icon_del"></i></div>
                            </li>
                        {/foreach}
                    </ul>
                    <div id="saleskit_list_notcontent" style="height: 40px;line-height: 40px;text-align: center;display: none;">{'nodata'|@getFixedLabel}</div>
                </div>
            {/foreach}
        </div>
    </div>

    <!--中间栏 saleskitview-->
    <div style="height: 100%;width: calc(100% - 570px);overflow: auto;float: left;">
        <div class="ld_saleskitview" id="saleskitview" style="overflow: auto;">
            <div class="ld_saleskitview_block" style="min-height: {$SALESKITLAYOUT.height}px; {if $boardtype eq 'MobileReport'||$boardtype eq 'prmMobileHome'}width:400px;margin: 0 auto;{/if}">
                <div class="ld_saleskitview_row" style="display: flex;flex-wrap: wrap;">
                        {foreach key=k item=saleskitinfo from=$HOME_STUFF}
                                {assign var='stufflabel' value=$saleskitinfo.stufflabel}
                                {assign var='COLCOUNT' value=$SALESKITLAYOUT.colcount}
                                {assign var='stuffid' value=35}
                                {assign var='ShowPercent' value=$SALESKITLAYOUT.isshowprevious}
                                {include file="Home/SalesKitSetEditView_center.tpl"}
                        {/foreach}
                    <div name="blankstuff_new_block" class="ld_saleskitview_stuff ld_saleskitview_block_stuff keepcenter ld_saleskitview_stuff_new" style="min-height:{if $SALESKITLAYOUT.isshowprevious eq 'yes' && $isshowprev eq 'yes'}123{else}98{/if}px;width:calc(100% / {$SALESKITLAYOUT.colcount} - 10px);margin:5px;overflow: hidden;background-color: #F7F8FA">
                        <div name="blankstuff_new">+{'dragmodule'|@getFixedLabel}</div>
                    </div>
                </div>
            </div>
            <input type="hidden" id="origin_colcount" value="{$SALESKITLAYOUT.colcount}">
        </div>
    </div>

    {*右边栏saleskitset*}
    <div class="ld_saleskitedit_drawer" id="saleskitset">
        <div class="ChartSetHead" style="height: 50px;background-color:#F0F3F7;margin-top: 0px;">
            {assign  var="Label" value= 'LAYOUTSETTING'|@getFixedLabel}
            {*zxm 20231017 移动端工作台看板不显示布局设置*}
{*            {if $boardtype neq 'MobileReport'}*}
                <div class="ld_saleskit_settingdetail ld_saleskitset_saleskitset SetType CurSetType div-text-hidden sort-tip-items" tag="0"
                     style="width: 45%;height: 50px;margin:0px 5px;" data-tip="{$Label}" data-direction="top" data-type="position">{$Label}</div>
{*            {/if}*}
            {assign  var="Label" value= 'SALESKITSETTING'|@getFixedLabel}
            <div class="ld_saleskit_settingdetail ld_saleskitset_saleskitset SetType div-text-hidden sort-tip-items" tag="1"
                 style="width: 45%;height: 50px;margin:0px 5px;" data-tip="{$Label}" data-direction="top" data-type="position">{$Label}</div>
        </div>
            <div class="ld_saleskitset_layout" id="saleskitset_layout">

                {*zxm 20231017 移动端工作台看板不显示布局设置*}
                {if $boardtype neq 'MobileReport'&&$boardtype neq 'prmMobileHome'}
                <div class="FieldBlock">
                    <div class="marT10 FieldLabel Mandatory justifynormal">
                        <span>{'NUMSOFCOLUMNS'|@getFixedLabel}</span><span style="color:#979797">({'PCsettingsonlytakeeffect'|@getFixedLabel}) </span>
                    </div>
                    <div class="marT5 marB15 FieldCon">
                        <select class="Bornone FieldConText" id="saleskitset_layout_col" style="height: 30px;width: 100%;background:#F5F8FC;padding-left: 10px;">
                            <option {if $SALESKITLAYOUT.colcount eq 2}selected{/if}>2</option>
                            <option {if $SALESKITLAYOUT.colcount eq 3}selected{/if}>3</option>
                            <option {if $SALESKITLAYOUT.colcount eq 4}selected{/if}>4</option>
                            <option {if $SALESKITLAYOUT.colcount eq 5}selected{/if}>5</option>
                            <option {if $SALESKITLAYOUT.colcount eq 6}selected{/if}>6</option>
                        </select>
                    </div>
                </div>
                {/if}
                <div class="FieldBlock">
                    <div class="FieldLabel Mandatory justifynormal">
                        <span>{'SHOWPREVIOUSPERIODDATA'|@getFixedLabel}</span>{*显示上期对比数据*}
                    </div>
                    <div class="marT5 marB15 FieldCon">
                        <input id="isshowprevious" type="checkbox" class="second_switch" value="{$SALESKITLAYOUT.isshowprevious}" >
                    </div>
                </div>

                <div class="FieldBlock" {if $SALESKITLAYOUT.isshowprevious eq 'no'}style="display: none"{/if}>
                    <div class="FieldLabel Mandatory justifynormal">
                        <span>{'EqualDuration'|@getFixedLabel}</span>{*上期按当前时间为截止时间*}
                    </div>
                    <div class="marT5 marB15 FieldCon">
                        <select class="Bornone FieldConText" id="EqualDuration" style="height: 30px;width: 100%;background:#F5F8FC;padding-left: 10px;">
                            <option value="yes">
                                {'EqualDurationYes'|@getFixedLabel}
                            </option>
                            <option value="no">
                                {'EqualDurationNo'|@getFixedLabel}
                            </option>
                        </select>
                    </div>
                </div>
                <div class="FieldBlock" {if $SALESKITLAYOUT.isshowprevious eq 'no'}style="display: none"{/if}>
                    <div class="FieldLabel Mandatory justifynormal">
                        <span>{'Displaypercentage'|@getFixedLabel}</span>{*显示百分比*}
                    </div>
                    <div class="marT5 marB15 FieldCon">
                        <input id="ShowPercent" type="checkbox" class="second_switch" >
                    </div>
                </div>
            </div>
        <div class="ld_saleskitset_stuff FieldBlock" style="display:none;" id="saleskitset_stuff">
            <div style="margin:20px auto;">{'Clickonthebriefingtosetup'|@getFixedLabel}</div>
        </div>
    </div>
</div>



