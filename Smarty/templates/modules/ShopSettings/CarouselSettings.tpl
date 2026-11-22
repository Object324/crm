<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>

<div id="divLinkModuleCustom">
    <div class="main_grid_top">
        <div class="grid-view-title lfloat overflow-hidden">
            <span class="grid-view-name dinline-block lfloat">
                {'CarouselSetting'|@getFixedLabel}<font>（{'ShowOnlyTheFirst5Carousels'|@getFixedLabel}）</font>
            </span>
        </div>
        <div class="grid_tool">
            <div class="create-entity-toolbar lfloat prelative">
                <a href="javascript:;" class="ld-button ld-button-primary" name="New" onclick="CarouselSettings_edit(this,'create','')" title="{'NEW'|@getFixedLabel}">{'NEW'|@getFixedLabel}</a>
            </div>
        </div>
    </div>
    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float">
                <input type="hidden" name="mode" value="create"/>
                <input type="hidden" name="module" value="ShopSettings"/>
                <div name="listcontent">
                    {include file="modules/ShopSettings/CarouselSettingsListContent.tpl"}
                </div>
            </div>
        </div>
    </div>
</div>