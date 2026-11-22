<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
<!--综合报表工具栏按钮-->
<input type="hidden" id="year_situation" value="year_situation"/>
<input type="hidden" id="account_cashbill" value="account_cashbill"/>
<input type="hidden" id="user_cashbill" value="user_cashbill"/>
<input type="hidden" id="user_salesorder" value="user_salesorder"/>
<input type="hidden" id="costprice_salesorder" value="costprice_salesorder"/>
<input type="hidden" id="grossprofitdetial" value="grossprofitdetial"/>
<input type="hidden" id="product_grossprofit" value="product_grossprofit"/>
<input type="hidden" id="account_grossprofit" value="account_grossprofit"/>
<input type='hidden' id="SalesOrder_HxDetail" value="SalesOrder_HxDetail"/>
<input type='hidden' id="SalesOrder_Testingdetial" value="SalesOrder_Testingdetial"/>
<input type='hidden' id="latticepointdetial" value="latticepointdetial"/>
<input type='hidden' id="RWmarketAll" value="RWmarketAll"/>
<input type="hidden" id="SaleOrder_HxRent" value="SaleOrder_HxRent"/>
<input type="hidden" id="Drilldown_reports" value="Drilldown_reports"/>
<input type="hidden" id="HBRreports" value="HBRreports"/>
<input type="hidden" id="guotongreports" value="guotongreports"/>
<input type="hidden" id="guotongreports2" value="guotongreports2"/>
<input type="hidden" id="guotongreports3" value="guotongreports3"/>
<!--中间-->
<div class="{if $listtype!='screen'}statistic-analysis-content{/if}">
    <div class="statistic-analysis-sidebar prelative lfloat" {if $listtype=='screen'}style="display: none;"{/if}>
        <div class="statistic-analysis-accordion">
            <div class="analysis-accordion-content">
                <a href="javascript:;" class="analysis-accordion-header displayblock" title="{'ReportName'|@getFixedLabel}"><i class="dinline-block lfloat"></i><span class="dinline-block lfloat">{'ReportName'|@getFixedLabel}</span></a>
                <div class="analysis-accordion" style="display: block;">
                    <ul class="list">
                        {assign var='i' value=1}
                        {foreach key=key item=item from=$TYPENAMEPRESENCE}
                            {if $i eq 1}
                                <li class="active"><a href="javascript:;" id="change_table_{$key}" onclick="change_table('{$key}');" title="{$key|@getFixedLabel}">{$key|@getFixedLabel}</a></li>
                            {else}
                                <li><a href="javascript:;" id="change_table_{$key}" onclick="change_table('{$key}');" title="{$key|@getFixedLabel}">{$key|@getFixedLabel}</a></li>
                            {/if}
                            {assign var="i" value=$i+1}
                        {/foreach}
                    </ul>
                </div>
            </div>
        </div>
    </div>
    <div class="main_grid lfloat">
        <div class="main_grid_top">
            <div class="grid-view-title overflow-hidden">
                {if $version neq 'fudi'}
                    <div class="yearFlex">
                        <ul id="div_year_table">
                            {$year_show}
                        </ul>
                    </div>
                {/if}
            </div>
            <div class="grid_tool">
            </div>
        </div>
        <div class="main_grid_box">
            <div class="grid-analysis-box">
                <div class="grid-analysis-header">
                </div>
                <div class="cont_wrap clear_float" id="Comprehensivereport_list">
                    {foreach key=key item=item from=$TYPENAMEPRESENCE}
                        {include file="Comprehensivereport/ReportDetail/$key.tpl"}
                    {/foreach}
                </div>
            </div>
        </div>
    </div>
</div>
<!--中间 end-->
<script>
    //32519:综合表报：年度表前面应该增加一个年份。
    var annualtext="{'ANNUALTABLE'|@getFixedLabel}";
    chose_year("{$now}");
    
    var report_typename='{$JSONTYPENAME}';
    var default_report = '{$DEFAULTREPORT}'; //获取第一个报表
    change_table(default_report);

    ld(function(){
        //加载内容中点击事件
        initContentLeftMenuClick();
    });
</script>