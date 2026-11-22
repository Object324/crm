<!--修改编码格式:统一编码：UTF-8-->

<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBI_PRICEPOLICY_SETTINGS'|@getFixedLabel}
        </span>
    </div>
    <div class="grid_tool">

    </div>
</div>
<div id="PricePolicySet" class="main_grid_box PricePolicySet ld-table-container ld-table-container-lines" style="overflow-y: hidden">
    <div id="PricePolicyHead" style="width: 100%;">

    </div>
    <div id="PricePolicyBody" style="width: 100%;">

    </div>
</div>
<script type="text/javascript">
    {literal}
        AjaxJSPage('PricePolicy_js','include/js/modules/PricePolicy/PricePolicy.js');
        PricePolicy.getInstance().getSetInstance().showContent();
    {/literal}
</script>