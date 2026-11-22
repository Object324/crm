<div class="set-info" id="chart_set">
    <div class="base-info">
        <form id="info2">
            <div class="input-group mb-3" style="display:none;">
                <div class="input-group-prepend">
                    <span class="input-group-text">{'statisticalGraphics'|@getFixedLabel}{'MAILTITLE'|@getFixedLabel}</span>
                </div>
                <input type="text" class="form-control" id="chart_title_text" name="chart_title_text" placeholder="输入统计图标题" aria-label="统计图标题" aria-describedby="chart_title_text" value="{$chart_info['title1']->text}">
            </div>
            <div class="input-group mb-3" {if $chart_info['chart_type']== "pie"||$chart_info['chart_type']== "funnel"}style="display:none;"{/if}>
                <div class="input-group-prepend">
                    <span class="input-group-text"><input type="checkbox" id="xaxis_check" name="xaxis_check" {if $chart_info['xaxis1']}checked{/if} onchange="selfDefinedReportEdit2.checkChange(this,'xaxis')">&nbsp;启用X轴</span>
                </div>

                <select class="custom-select" id="xaxis_type" name="xaxis_type" {if $chart_info['xaxis1']}style="display:block"{else}style="display:none"{/if}>
                    <option {if $chart_info['xaxis1']->type == "category"}selected{/if} value="category">类目轴</option>
                    <option {if $chart_info['xaxis1']->type == "value"}selected{/if} value="value">数值轴</option>
                    <option {if $chart_info['xaxis1']->type == "time"}selected{/if} value="time">时间轴</option>
                    <option {if $chart_info['xaxis1']->type == "log"}selected{/if} value="log">对数轴</option>
                </select>
                <input {if $chart_info['xaxis1']}style="display:block"{else}style="display:none"{/if} type="text" aria-label="X轴名称" name="xaxis_name" id="xaxis_name" placeholder="X轴名称" class="form-control" value="{$chart_info['xaxis1']->name}">
            </div>
            <div class="input-group mb-3" {if $chart_info['chart_type']== "pie"||$chart_info['chart_type']== "funnel"}style="display:none;"{/if}>
                <div class="input-group-prepend">
                    <span class="input-group-text"><input id="yaxis_left_check" name="yaxis_left_check" type="checkbox" {if $chart_info['yaxis1']->left}checked{/if} onchange="selfDefinedReportEdit2.checkChange(this,'yaxis_left')">&nbsp;启用左Y轴</span>
                </div>
                <select class="custom-select" id="yaxis_left_type" name="yaxis_left_type" {if $chart_info['yaxis1']->left}style="display:block"{else}style="display:none"{/if}>
                    <option {if $chart_info['yaxis1']->left->type == "value"}selected{/if} value="value">数值轴</option>
                    <option {if $chart_info['yaxis1']->left->type == "category"}selected{/if} value="category">类目轴</option>
                    <option {if $chart_info['yaxis1']->left->type == "time"}selected{/if} value="time">时间轴</option>
                    <option {if $chart_info['yaxis1']->left->type == "log"}selected{/if} value="log">对数轴</option>
                </select>
                <input {if $chart_info['yaxis1']->left}style="display:block"{else}style="display:none"{/if} type="text" aria-label="左Y轴名称" name="yaxis_left_name" id="yaxis_left_name" placeholder="左Y轴名称" class="form-control" value="{$chart_info['yaxis1']->left->name}">
            </div>
            <div class="input-group mb-3" {if $chart_info['chart_type']== "pie"||$chart_info['chart_type']== "funnel"}style="display:none;"{/if}>
                <div class="input-group-prepend">
                    <span class="input-group-text"><input type="checkbox" id="yaxis_right_check" name="yaxis_right_check" {if $chart_info['yaxis1']->right}checked{/if} onchange="selfDefinedReportEdit2.checkChange(this,'yaxis_right')">&nbsp;启用右Y轴</span>
                </div>
                <select class="custom-select" id="yaxis_right_type" name="yaxis_right_type" {if $chart_info['yaxis1']->right}style="display:block"{else}style="display:none"{/if}>
                    <option {if $chart_info['yaxis1']->right->type == "value"}selected{/if} value="value">数值轴</option>
                    <option {if $chart_info['yaxis1']->right->type == "category"}selected{/if} value="category">类目轴</option>
                    <option {if $chart_info['yaxis1']->right->type == "time"}selected{/if} value="time">时间轴</option>
                    <option {if $chart_info['yaxis1']->right->type == "log"}selected{/if} value="log">对数轴</option>
                </select>
                <input {if $chart_info['yaxis1']->right}style="display:block"{else}style="display:none"{/if} type="text" aria-label="右Y轴名称" name="yaxis_right_name" id="yaxis_right_name" placeholder="右Y轴名称" class="form-control" value="{$chart_info['yaxis1']->right->name}">
            </div>
            {*饼图是否显示百分比*}
            <div class="input-group mb-3" {if $chart_info['chart_type']!= "pie"}style="display:none;"{/if}>
                <div class="input-group-prepend">
                    <span class="input-group-text"><input type="checkbox" id="showPercent" name="showPercent">&nbsp;显示百分比</span>
                </div>
            </div>
            <div class="input-group mb-3">
                <div class="input-group-prepend">
                    <span class="input-group-text">图例设置</span>
                </div>
                <select class="custom-select" id="legend_orient" name="legend_orient">
                    <option {if $chart_info['legend1']->orient == "horizontal"}selected{/if} value="horizontal">水平显示</option>
                    <option {if $chart_info['legend1']->orient == "vertical"}selected{/if} value="vertical">垂直显示</option>
                </select>
                <select class="custom-select" id="legend_type" name="legend_type">
                    <option {if $chart_info['legend1']->type == "plain"}selected{/if} value="plain">普通的</option>
                    <option {if $chart_info['legend1']->type == "scroll"}selected{/if} value="scroll">可滚动显示</option>
                </select>
            </div>
            {*                    <div class="input-group mb-3">*}
            {*                        <div class="input-group-prepend">*}
            {*                            <div class="input-group-text">*}
            {*                                <input id="tooltip" name="tooltip" type="checkbox" aria-label="是否显示提示框组件">*}
            {*                            </div>*}
            {*                        </div>*}
            {*                        <div class="input-group-prepend">*}
            {*                            <span class="input-group-text">显示提示框组件</span>*}
            {*                        </div>*}
            {*                    </div>*}
        </form>
        {*                    工具框设置默认显示*}
        <div>
            <button onclick="selfDefinedReport.beforeStep(2)" type="button" class="btn btn-light">{'ASTEP'|@getFixedLabel}</button>
            <button onclick="selfDefinedReport.nextStep(2)" type="button" class="btn btn-primary">{'NEXTSTEP'|@getFixedLabel}</button>
            <button onclick="selfDefinedReport.nextStep(2,'preview')" type="button" class="btn btn-primary">{'PREVIEW'|@getFixedLabel}</button>
        </div>
    </div>
</div>