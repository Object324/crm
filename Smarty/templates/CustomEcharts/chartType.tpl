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
{*        <div style="height:70px;"></div>*}
        {foreach item=parenttype key=parentkey from=$chartTypeArr}
        <div>
            <h3 id="chart-type-{$parentkey}" class="chart-type-head" style="padding-top: 50px;">
                {$parenttype['label']}
                <span>{$parentkey}</span>
            </h3>
            <div class="chart-type-list">
                {foreach item=item key=key from=$parenttype['list']}
                <div class="chart-type-one" data-name="{$item['name']}" data-label="{$item['label']}" parentkey="{$parentkey}">
                    <div><img style="width:100%;" src="themes/chartimg/{$item['name']}.png"></div>
                    <div class="chart-name">{$item['label']}</div>
                </div>
                {/foreach}
            </div>
        </div>
        {/foreach}
    </div>
</div>
