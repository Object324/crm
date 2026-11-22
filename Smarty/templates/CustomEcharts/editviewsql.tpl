<link type="text/css" rel="stylesheet" href="{$CSSURL}themes/softed/CustomEcharts.css">
<script type="text/javascript" src="include/js/modules/CustomEcharts/renderChart.js"></script>
<div class="main_grid lfloat" style="width: 100%;height: auto;">
    <form id="chartInfoForm">
        {*编辑页面不显示图表类型的选择*}
        {if $mode!="edit"}
            <div class="tab-contents" id="selectChartType" style="height:100%;overflow-y: scroll">
                {include file="CustomEcharts/chartType.tpl"}
            </div>
        {/if}
    </form>
</div>
