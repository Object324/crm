<div class="set-info" id="sort_set">
    <div class="base-info">
        <form id="info5">
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                    <span class="input-group-text"><input type="checkbox" id="orderby_check" name="orderby_check" {if $chart_info['orderby_type']}checked{/if} onchange="selfDefinedReportEdit5.orderbycheckChange(this)">启用值排序</span>
                </div>
{*                <select class="custom-select" id="orderby" name="orderby">*}
{*                    <option value="">按统计值</option>*}
{*                    <option value="">按时间</option>*}
{*                </select>*}
                <select class="custom-select" id="orderby_type" name="orderby_type">
                    <option {if $chart_info['orderby_type']=='desc'}selected{/if} value="desc">倒序</option>
                    <option {if $chart_info['orderby_type']=='asc'}selected{/if} value="asc">顺序</option>
                </select>
            </div>
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                    <span class="input-group-text">统计条数</span>
                </div>
                <input type="number" class="form-control" id="limit" placeholder="请输入统计条数" aria-label="统计条数" aria-describedby="limit" name="limit" value="{$chart_info['limit']}">
            </div>
            <div>
                <button onclick="selfDefinedReport.beforeStep(5)" type="button" class="btn btn-light">{'ASTEP'|@getFixedLabel}</button>
                <button onclick="selfDefinedReport.nextStep(5,'yes')" type="button" class="btn btn-primary">{'SPCOMPLETED'|@getFixedLabel}</button>
                <button onclick="selfDefinedReport.nextStep(5,'preview')" type="button" class="btn btn-primary">{'PREVIEW'|@getFixedLabel}</button>
            </div>
        </form>
    </div>
</div>