<script type="text/javascript" src="include/js/modules/CustomEcharts/renderChart.js"></script>
<div class="main_grid lfloat" style="width: 100%;height: auto;">
    <form id="chartInfoForm">
    {*编辑页面不显示图表类型的选择*}
    {if $mode!="edit"}
    <div class="tab-contents" id="chartType" style="height:100%;overflow-y: scroll">
        <div class="chart-type-content">
            <div class="chart-type-names" style="height:100%;">
            </div>
            <div class="chart-type-names" style="position: fixed;height:100%;">
                <ul id="left_chart_nav">
                    {foreach item=parenttype key=parentkey from=$chartTypeArr}
                        <li class="{if $parentkey=='line'}active{/if}" parentkey="{$parentkey}">
                            <a id="left-chart-nav-{$parentkey}" href="#chart-type-{$parentkey}" class="left-chart-nav-link">
                                <div class="chart-name">{$parenttype['label']}</div>
                            </a>
                        </li>
                    {/foreach}
                </ul>
            </div>
            <div class="chart-type-icons" id="chart_type_lists">
                {foreach item=parenttype key=parentkey from=$chartTypeArr}
                    <div>
                        <h3 id="chart-type-{$parentkey}" class="chart-type-head" style="padding-top: 50px;">
                            {$parenttype['label']}
                            <span>{$parentkey}</span>
                        </h3>
                        <div class="chart-type-list">
                            {foreach item=item key=key from=$parenttype['list']}
                                <div class="chart-type-one" data-name="{$item['name']}" data-label="{$item['label']}" parentkey="{$parentkey}">
                                    <div><img style="width:100%;" src="{$IMAGEURL}themes/chartimg/{$item['name']}.png?v={$GLOBALMINVERSION}"></div>
                                    <div class="chart-name">{$item['label']}</div>
                                </div>
                            {/foreach}
                        </div>
                    </div>
                {/foreach}
            </div>
        </div>
    </div>
    {/if}
    </form>
</div>
