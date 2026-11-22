<div id="MarketingSettings">
    <div class="main_grid_top">
        <div class="grid-view-title lfloat overflow-hidden">
            <span class="grid-view-name dinline-block lfloat">
                营销按钮设置
            </span>
        </div>
        {*<div class="grid_tool">
            <div class="create-entity-toolbar lfloat prelative">
                <a href="javascript:;" class="pg-btn-blue dinline-block lfloat" name="New" onclick="add(this,'create','')" title="{'NEW'|@getFixedLabel}">{'NEW'|@getFixedLabel}</a>
            </div>
        </div>*}
    </div>
    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float">
{*                <input type="hidden" name="theme" value="{$THEME}">*}
                <div name="listcontent">
                    {include file="modules/CardSettings/MarketingSettingsContent.tpl"}
                </div>
            </div>
        </div>
    </div>
</div>