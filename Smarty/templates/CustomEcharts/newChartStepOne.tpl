<div class="set-info info-active" id="base_set">
    <div class="base-info">
        <form id="info1">
            {*所属分类*}
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                    <label class="input-group-text" for="parent_id">所属文件夹</label>
                </div>
                <select class="custom-select" id="parent_id" name="parent_id">
                    {foreach item=parent key=i from=$parent_reports}
                        <option {if $chart_info['parent_id']==$parent['report_id']||$parent_id==$parent['report_id']}selected{/if} value="{$parent['report_id']}">{$parent['report_name']}</option>
                    {/foreach}
                </select>
            </div>
            {*图表名称*}
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                    <span class="input-group-text">图表名称</span>
                </div>
                <input type="hidden" name="report_id" id="report_id" value="{$request['report_id']}">
                <input type="text" class="form-control" id="report_name" placeholder="请输入图表名称" aria-label="图表名称" aria-describedby="report_name" name="report_name" value="{$chart_info['report_name']}">
            </div>
            {*图表类型*}
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                    <label class="input-group-text" for="parent_id">图表类型</label>
                </div>
                <select class="custom-select" id="chart_type" name="chart_type" onchange="selfDefinedReportEdit1.chartTypeChange(this)">
                    <option {if $chart_info['chart_type']=='line'}selected{/if} value="line">折线图</option>
                    <option {if $chart_info['chart_type']=='bar'}selected{/if} value="bar">柱状图</option>
                    <option {if $chart_info['chart_type']=='line_bar'}selected{/if} value="line_bar">折柱混合图</option>
                    <option {if $chart_info['chart_type']=='pie'}selected{/if} value="pie">饼图</option>
                    <option {if $chart_info['chart_type']=='funnel'}selected{/if} value="funnel">漏斗图</option>
                    <option {if $chart_info['chart_type']=='bar_stack'}selected{/if} value="bar_stack">柱状堆叠图</option>
                </select>
            </div>
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                    <span class="input-group-text">报表描述</span>
                </div>
                <textarea class="form-control" name="report_desc" aria-label="报表描述">{$chart_info['report_desc']}</textarea>
            </div>
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                    <label class="input-group-text" for="mainmodule">统计模块</label>
                </div>
                <select onchange="selfDefinedReportEdit1.changeModuleNames(this)" class="custom-select" id="mainmodule" name="mainmodule">
                    {foreach item=modulename key=i from=$module_arr}
                        <option {if $chart_info['mainmodule']==$modulename['label']['modulename']}selected{/if} value="{$modulename['label']['modulename']}">{$modulename['label']['zh']}</option>
                    {/foreach}
                </select>
            </div>
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                    <span class="input-group-text"><input id="show_athome" name="show_athome" type="checkbox" {if $chart_info['show_athome']=='yes'}checked{/if}>允许PC端首页显示</span>
                </div>
            </div>
        </form>
        <div onclick="selfDefinedReport.nextStep(1)" type="button" class="btn btn-primary">{'NEXTSTEP'|@getFixedLabel}</div>
    </div>
</div>