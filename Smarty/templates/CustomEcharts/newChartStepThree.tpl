<div class="set-info" id="data_set">
    <div class="base-info" style="margin:10px 5%;">
        <form id="info3">
            <div class="form-row" >
                <div class="input-group col-md-6">
                    <div class="input-group-prepend">
                        <span class="input-group-text">统计维度</span>
                    </div>
                    <select class="custom-select" id="groupby" name="groupby" onchange="selfDefinedReportEdit3.changeGroupBy(this)">
                    </select>
                </div>
                <div class="input-group col-md-3" {if $chart_info['groupInfo'][0]['groupbytype']=='byField'}style="display:none;"{/if}>
                    <select class="custom-select" id="groupbytype" name="groupbytype" onchange="selfDefinedReportEdit3.changeByField(this)">
                        <option value="byField">请选择时间统计方式</option>
                        <option {if $chart_info['groupInfo'][0]['groupbytype']=='byYear'}selected{/if} value="byYear">按年度</option>
                        <option {if $chart_info['groupInfo'][0]['groupbytype']=='byQuarter'}selected{/if} value="byQuarter">按季度</option>
                        <option {if $chart_info['groupInfo'][0]['groupbytype']=='byMonth'}selected{/if} value="byMonth">按月度</option>
                        <option {if $chart_info['groupInfo'][0]['groupbytype']=='byWeek'}selected{/if} value="byWeek">按周</option>
                        <option {if $chart_info['groupInfo'][0]['groupbytype']=='byDay'}selected{/if} value="byDay">按天</option>
                    </select>
                </div>
{*                <div class="input-group col-md-3" {if $chart_info['groupInfo'][0]['groupbytype']!='byMonth'}style="display:none;"{/if}>*}
{*                    <select class="custom-select" id="stat_approach" name="stat_approach">*}
{*                        <option {if $chart_info['stat_approach']==''}selected{/if} value="">无</option>*}
{*                        <option {if $chart_info['stat_approach']=='tongbi'}selected{/if} value="tongbi">同比</option>*}
{*                        <option {if $chart_info['stat_approach']=='huanbi'}selected{/if} value="huanbi">环比</option>*}
{*                    </select>*}
{*                </div>*}
            </div>
            <div class="form-row" style="margin-top: 10px;">
                <div class="input-group col-md-6">
                    <div class="input-group-prepend" {if $chart_info['chart_type']=='pie'||$chart_info['chart_type']=='funnel'}style="display:none;"{/if}>
                        <span class="input-group-text"><input type="checkbox" id="groupby_secondcheck" name="groupby_secondcheck" {if $chart_info['groupInfo'][1]}checked{/if} onchange="selfDefinedReportEdit3.groupbySecondChange(this)">&nbsp;开启第二统计维度</span>
                    </div>
                    <select {if $chart_info['groupInfo'][1]}{else}style="display:none;"{/if}  class="custom-select" id="groupby_second" name="groupby_second" onchange="selfDefinedReportEdit3.changeGroupBySecond(this)">
                    </select>
                </div>
                <div class="input-group col-md-3">
                    <select class="custom-select" id="groupbytype_second" name="groupbytype_second" {if $chart_info['groupInfo'][1]&&$chart_info['groupInfo'][1]['groupbytype']!='byField'}{else}style="display:none;"{/if}>
                        <option value="byField">请选择时间统计方式</option>
                        <option {if $chart_info['groupInfo'][1]['groupbytype']=='byYear'}selected{/if} value="byYear">按年度</option>
                        <option {if $chart_info['groupInfo'][0]['groupbytype']=='byQuarter'}selected{/if} value="byQuarter">按季度</option>
                        <option {if $chart_info['groupInfo'][1]['groupbytype']=='byMonth'}selected{/if} value="byMonth">按月度</option>
                        <option {if $chart_info['groupInfo'][1]['groupbytype']=='byWeek'}selected{/if} value="byWeek">按周</option>
                        <option {if $chart_info['groupInfo'][1]['groupbytype']=='byDay'}selected{/if} value="byDay">按天</option>
                    </select>
                </div>
            </div>
            <div class="columns" style="margin-top: 10px;">
                <table class="table">
                    <thead>
                    <tr>
                        <th scope="col">统计字段</th>
                        <th scope="col">统计方式</th>
                        <th scope="col">展示形式</th>
                        <th scope="col">名称</th>
                        <th scope="col">选择Y轴</th>
{*                        <th scope="col">颜色</th>*}
                        <th scope="col">操作</th>
                    </tr>
                    </thead>
                    <tbody id="columnList">
                    </tbody>
                </table>
            </div>
        </form>
        <div>
            <button onclick="selfDefinedReport.beforeStep(3)" type="button" class="btn btn-light">{'ASTEP'|@getFixedLabel}</button>
            <button onclick="selfDefinedReport.nextStep(3)" type="button" class="btn btn-primary">{'NEXTSTEP'|@getFixedLabel}</button>
            <button onclick="selfDefinedReport.nextStep(3,'preview')" type="button" class="btn btn-primary">{'PREVIEW'|@getFixedLabel}</button>
        </div>
    </div>
</div>