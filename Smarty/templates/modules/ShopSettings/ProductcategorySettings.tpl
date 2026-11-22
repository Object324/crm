<div id="divLinkModuleCustom">
    <div class="main_grid_top">
        <div class="grid-view-title lfloat overflow-hidden">
            <span class="grid-view-name dinline-block lfloat">
                {$product_fieldlabel}{'SETTINGS'|@getFixedLabel}<font>
            </span>
        </div>
        <div class="grid_tool">
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
                    {include file="modules/ShopSettings/ProductcategoryContent.tpl"}
                </div>
            </div>
        </div>
    </div>
</div>