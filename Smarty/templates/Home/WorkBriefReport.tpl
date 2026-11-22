<!--左边栏 saleskitlist   中间栏 saleskitview  右边设置栏 saleskitset  布局设置 layout 全局设置set_stuff      -->
<div class="ld_saleskitedit_draw">
    <link type="text/css" href="themes/softed/CustomEchartsStyle.css" rel="stylesheet">
    <!--销售简报列表搜索框-->
    <div class="ld_saleskitlist_block">
        <div class="ld_saleskitlist_search">
            <input type="text" class="ld-input-inner ld-input-inner-add" id="search_saleskitlist" placeholder="{'INPUTTHESALESKITNAME'|@getFixedLabel}" title="{'INPUTTHESALESKITNAME'|@getFixedLabel}">
            <b id="clearsearchBtn" class="ld-icon-clearsearch" style="display: none"></b>
            <b id="searchBtn" class="ld-icon-search"></b>
        </div>
        <div class="ld_homeboard_stuff" id="saleskitlist_all" name="saleskitlist_all">
            <div style="display: flex;margin: 10px 0;">
                <span style="font-size: 13px;color: #8998AC;margin-left: 16px;">{'OperationTip'|@getFixedLabel}</span>
                <b class="icon-homeimg icon-askgrey-help sort-tip-report" style="margin: 0 10px;" data-tip="{$OperationTip}"
                   data-type="position" data-direction="right"></b>
            </div>
            {assign  var="i" value=0}
            {foreach key=ReportType item=ListInfo from=$reportLabelList}
                {assign  var="i" value= $i + 1}
                <div class="ld_homeboard_stuff_title" style="position: sticky;top: 0px;z-index:1;margin: 14px 0 0;"
                     name="stufflist_title_{$ReportType}" data-type="{$ReportType}">
                    <span>{$i}. {$ListInfo['label']}</span>
                    <i class="icon-develop icon-develop_active" style="float: right;position: relative;top: 18px;"></i>
                </div>
                <div class="ld_homeboard_stuff_list saleskitlist" id="saleskitlist_{$ReportType}"
                     name="saleskitlist_{$ReportType}">
                    {if $ReportType eq 'custom'}
                        {assign  var="btnLabel" value= 'NEWCUSTOMSALESKIT'|@getFixedLabel}
                        <div class="ld-button ld-button-primary div-text-hidden sort-tip-report" style="padding: 0 5px;margin: 14px 14px 0;text-align: center;"
                             id="addCustomSaleskit" data-tip="{$btnLabel}" data-direction="top" data-type="position"> + {$btnLabel}</div>
                    {/if}
                    <ul name="saleskitstuff">
                        {foreach key=name item=reportInfo from=$ListInfo['list']}
                            <li class="ld_saleskitlist_stuff {if $reportInfo['presence'] eq 'yes'}ld_listchosestuff {else}drag-handle{/if} " id="reportlist_{$name}" data-name="{$name}" data-tag="old" data-type="{$ReportType}">
                                <span class="sort-tip-report" name="label" style="cursor: pointer" data-tip="{$reportInfo.label}" data-direction="top" data-type="position">
                                    {$reportInfo.label}
                                </span>
                                <span class="tag" name="checked_tag" {if $reportInfo['presence'] eq 'yes'}style="display: block;"{/if}><i class="check"></i></span>
                                    <span name="saleskit_delete" data-name="{$name}"
                                      {if $reportInfo['is_default'] neq 'yes' && $reportInfo['presence'] neq 'yes'}class="ld-saleskitview-block-stuff-delete"{/if}><i class="icon-deleted"></i></span>
                                <div class="ld_saleskitview_block_stuff_close" data-name="{$name}"><i class="icon_del"></i></div>
                            </li>
                        {/foreach}
                    </ul>
                    <div id="saleskit_list_notcontent_{$ReportType}" style="height: 40px;line-height: 40px;text-align: center;{if $custom_count neq '0' || $ReportType eq 'default'}display: none;{/if}">{'nodata'|@getFixedLabel}</div>
                </div>
            {/foreach}
        </div>
    </div>

    <!--中间栏 saleskitview-->
    <div style="height: 100%;width: calc(100% - 570px);overflow: auto;float: left;">
        <div class="ld_saleskitview" id="saleskitview" style="overflow: auto;">
            <div class="ld_saleskitview_block" style="height: {$BRIEFREPORTLAYOUT.height}px;">
                <div class="ld_saleskitview_row">
{*                    {assign var='i' value=1}*}
{*                    {section name=rowloop loop=$BRIEFREPORTLAYOUT.rowcount}*}
{*                        {section name=saleskitloop loop=$BRIEFREPORTLAYOUT.colcount}*}
{*                            {foreach key=name item=reportInfo from=$SELECTEDLIST}*}
{*                                {if $reportInfo.sequence eq $i}*}
                    {foreach key=k item=saleskitarr from=$SELECTEDLIST}
                    {foreach key=kk item=reportInfo from=$saleskitarr}
                    {assign var='name' value=$reportInfo.name}
                                    <div class="ld_saleskitview_stuff ld_saleskitview_block_stuff" data-tag="old" style="width:calc(100% / {$BRIEFREPORTLAYOUT.colcount} - 10px);margin:5px;overflow: hidden;">
                                        <div class="ld_saleskitstuff hover drag-handle j-toBiSale sort-tip-report" style="overflow: hidden;height: 90%; width: 95%;top: 5%;left: 0%;position: relative;cursor: pointer"
                                             data-tip="{$reportInfo.label}" data-direction="top" data-type="position" id="saleskitstuff_{$name}" data-name="{$name}" data-tag="old" >
                                            <div class="ld-saleskitview-block-stuff-close" name="middle_close_{$name}" data-name="{$name}"><i class="icon-close"></i></div>
                                            <div class="ld-stuff-item-header">
                                                <div class="ld-stuff-item-header-icon">
                                                </div>
                                                <div class="ld-stuff-item-header-title" name="label" style="line-height: 50px">
                                                    {$reportInfo.label}
                                                </div>
                                            </div>
                                            <div class="ld-stuff-item-content">
                                                <div  class="ld-stuff-item-content-l">
                                                    <div class="ld-stuff-item-c-l-t" style="height: 100%">
                                                        <div class="ld-stuff-item-c-label">
                                                            <span class="ld-stuff-item-c-data" style="padding-left: 0px">0</span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                    {/foreach}
                    {/foreach}
{*                                {/if}*}
{*                            {/foreach}*}
{*                            {assign var="i" value=$i+1}*}
{*                        {/section}*}
{*                    {/section}*}
                    <div class="ld_saleskitview_stuff ld_saleskitview_block_stuff keepcenter ld_saleskitview_stuff_new" style="width:calc(100% / {$BRIEFREPORTLAYOUT.colcount} - 10px);margin:5px;overflow: hidden;">
                        <div name="blankstuff_new">+{'dragmodule'|@getFixedLabel}</div>
                    </div>
                </div>
            </div>
            <input type="hidden" id="origin_colcount" value="{$BRIEFREPORTLAYOUT.colcount}">
        </div>
    </div>

    {*右边栏saleskitset*}
    <div class="ld_saleskitedit_drawer" id="saleskitset">
        <div class="ChartSetHead" style="height: 50px;background-color:#F0F3F7;margin-top: 0px;">
            <div class="ld_saleskit_settingdetail ld_saleskitset_saleskitset SetType div-text-hidden sort-tip-report CurSetType" tag="style"
                 style="width: 50%;height: 50px;margin:0px 5px;" data-tip="{$Label}" data-direction="top" data-type="position">{'LAYOUTSETTING'|@getFixedLabel}
            </div>
            <div class="ld_saleskit_settingdetail ld_saleskitset_saleskitset SetType div-text-hidden sort-tip-report" tag="setting"
                 style="width: 50%;height: 50px;margin:0px 5px;" data-tip="{$Label}" data-direction="top" data-type="position">{'SALESKITSETTING'|@getFixedLabel}
            </div>
        </div>
        <div style="padding: 10px" id="saleskitset_style">
            <div class="FieldBlock">
                <div class="marT10 FieldLabel Mandatory justifynormal">
                    <span>{'BriefReportStyle'|@getFixedLabel}</span>
                </div>
                <div class="FieldCon changesearch">
                    <select id="showtype" name="showtype" class="detailedViewTextBox custom-select js-example-basic-single Bornone bgF5F8FC" style="width: 100%;height: 30px">
                        <option value="text" {if $showstyle eq 'text'}selected{/if}>{'BriefReportShowStyleWithText'|@getFixedLabel}</option>
                        <option value="html" {if $showstyle eq 'html'}selected{/if}>{'BriefReportShowStyleWithHTML'|@getFixedLabel}</option>
                    </select>
                </div>
            </div>
        </div>
        <div class="ld_saleskitset_stuff FieldBlock" style="display: none" id="saleskitset_stuff">
            <div style="margin:20px auto;">{'Clickonthebriefingtosetup'|@getFixedLabel}</div>
        </div>
    </div>
</div>



