<!--中间-->
<style>
    .input-width-45{
        width:45%;float:left;margin-right:10px;
    }
    .input-width-30{
        width:30%;float:left;margin-right:10px;
    }
    .input-width-70{
        width:70%;float:left;margin-right:10px;
    }
    .flex-input-group {
        display: inline-block;
        width: 50%;
    }
</style>
<script type="text/javascript" src="include/js/modules/CustomEcharts/CustomEchartsCreate.js"></script>
<script type="text/javascript" src="include/js/modules/CustomEcharts/renderChart.js"></script>
<div class="main_grid lfloat" style="width: 100%;">
    <div class="ld-ui-tabs" >
        <ul class="ld-ui-tabs-nav">
            <li class="ld-ui-tabs-active" for="chartForm" onclick="changeTab(this)"><a href="javascript:;">{'CONFIGTHE'|@getFixedLabel}</a></li>
            <li for="chartPreview" onclick="changeTab(this)"><a href="javascript:;">{'PREVIEW'|@getFixedLabel}</a></li>
        </ul>
    </div>
    <div class="tab-contents" id="chartForm">
        <form id="chartInfoForm">
            <table class="" border="0" cellspacing="0" cellpadding="0" width="100%">
            <tbody>
            <tr>
                <td colspan="4">
                    <div name="displayfields">
                        <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
                            <tbody>
                            {*基本信息*}
                            <tr>
                                <td colspan="4" class="editrelhead">
                                    <b>{'BASICINFO'|@getFixedLabel}</b>
                                </td>
                            </tr>
                            <tr>
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    <font color="red">*</font>{'ReportName'|@getFixedLabel}
                                </td>
                                <td width="35%">
                                    <input type="hidden" name="report_id" id="report_id" value="{$chart_info['report_id']}">
                                    <input type="hidden" name="report_type" id="report_type" value="chart">
                                    <input type="text" name="report_name" id="report_name" placeholder="{'ReportName'|@getFixedLabel}" value="{$chart_info['report_name']}" class="detailedViewTextBox  input-width-70" autocomplete="off" required>
                                </td>
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    <font color="red">*</font>{'SELECT'|@getFixedLabel}{'MAILFOLDER'|@getFixedLabel}
                                </td>
                                <td width="35%">
                                    <select name="parent_id" id="parent_id" class="detailedViewTextBox input-width-70" >
                                        {foreach item=parent key=i from=$parent_reports}
                                            <option {if $chart_info['parent_id']==$parent['report_id']||$parent_id==$parent['report_id']}selected{/if} value="{$parent['report_id']}">{$parent['report_name']}</option>
                                        {/foreach}
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    {'OFTENUSEREPORTWORD'|@getFixedLabel}{'CAMCARDCAPTION'|@getFixedLabel}
                                </td>
                                <td colspan="3">
                                    <textarea class="detailedViewTextBox" name="report_desc" style="margin-top: 3px; overflow: hidden; overflow-wrap: break-word; resize: horizontal; height: 52px;" id="report_desc"  aria-label="{'OFTENUSEREPORTWORD'|@getFixedLabel}{'CAMCARDCAPTION'|@getFixedLabel}">{$chart_info['report_desc']}</textarea>
                                </td>
                            </tr>
                            {*图表参数*}
                            <tr>
                                <td colspan="4" class="editrelhead">
                                    <b>{'ChartParameters'|@getFixedLabel}</b>
                                </td>
                            </tr>
                            <tr>
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    <font color="red">*</font>{'StatisticsModule'|@getFixedLabel}
                                </td>
                                <td width="35%">
                                    <select  onchange="selfDefinedReport.changeModuleNames(this)" name="mainmodule" id="mainmodule" class="detailedViewTextBox input-width-70 custom-select js-example-basic-single">
                                        {foreach item=modulename key=i from=$module_arr}
                                            <option {if $chart_info['mainmodule']==$modulename['modulename']}selected{/if} value="{$modulename['modulename']}">{$modulename['name']}</option>
                                        {/foreach}
                                    </select>
                                </td>
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    <font color="red">*</font>{'chartType'|@getFixedLabel}
                                </td>
                                <td width="35%">
                                    <select name="chart_type" id="chart_type"  onchange="selfDefinedReport.chartTypeChange(this)" class="detailedViewTextBox input-width-45">
                                        {foreach item=chartType key=chartTypeKey from=$chartTypeArr}
                                            <option {if $chart_info['chart_type']==$chartTypeKey}selected{/if} value="{$chartTypeKey}">{$chartType}</option>
                                        {/foreach}
                                    </select>
                                    <select name="funnel_type" id="funnel_type" class="detailedViewTextBox input-width-45" {if $chart_info['chart_type']!='funnel'}style="display:none;"{/if}>
                                        <option {if $chart_info['funnel_type']=='triangle'} selected {/if} value="triangle">倒三角形</option>
                                        <option {if $chart_info['funnel_type']=='triangle'} selected {/if} value="lad">倒梯形</option>
                                        <option {if $chart_info['funnel_type']=='triangle'} selected {/if} value="bowls">碗形</option>
                                    </select>
                                    <span {if  $chart_info['chart_type']!='pie'}style="display:none;"{/if}><input {if  $chart_info['show_percent']=='yes'}checked{/if} type="checkbox"  id="showPercent" name="showPercent">
                                    {'SHOWINGRECORDS'|@getFixedLabel}{'Percents'|@getFixedLabel}</span>

                                </td>
                            </tr>
                            <tr>
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    相关模块
                                </td>
                                <td colspan="3">
                                    <select multiple name="relatedmodule[]" id="relatedmodule" class="detailedViewTextBox input-width-90 custom-select js-example-basic-single" onchange="selfDefinedReport.relatedModuleChange(this)">
                                    </select>
                                </td>
                            </tr>
                            <tr id="groupbytr">
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    <font color="red">*</font>{'StatisticalDimension'|@getFixedLabel}
                                </td>
                                <td width="35%">
                                    <select name="groupby" id="groupby" class="detailedViewTextBox input-width-45" onchange="selfDefinedReport.changeGroupBy(this)">
                                    </select>
                                    <select name="groupbytype" id="groupbytype" class="detailedViewTextBox input-width-45 custom-select" style="{if $Show_time_group_type eq 'yes'}{else} display:none;{/if}" onchange="selfDefinedReport.changeByField(this)">
                                        <option value="byField">请选择时间统计方式</option>
                                        {foreach item=timeFormat key=timeFormatKey from=$timeFormatType}
                                            <option {if $chart_info['groupInfo'][0]['groupbytype']==$timeFormatKey} selected {/if}  value="{$timeFormatKey}">{$timeFormat}</option>
                                        {/foreach}
                                    </select>
                                </td>
                                <td width="15%" class="DetailedTd1Label" align="right" {if $chart_info['chart_type']=='simple_sunburst'} style="display:none"{/if}>
                                    <input type="checkbox" id="groupby_secondcheck" name="groupby_secondcheck" class="" {if $chart_info['groupInfo'][1]}checked{/if} onchange="selfDefinedReport.groupbySecondChange(this)">
                                    启用第二统计维度
                                </td>
                                <td width="35%" {if $chart_info['groupInfo'][1]}style="visibility: visible"{else}style="visibility: hidden"{/if}>
                                    <select name="groupby_second" id="groupby_second" class="detailedViewTextBox input-width-45"  onchange="selfDefinedReport.changeGroupBySecond(this)">
                                    </select>
                                    <select name="groupbytype_second" id="groupbytype_second" class="detailedViewTextBox input-width-45" {if $chart_info['groupInfo'][1]&&$chart_info['groupInfo'][1]['groupbytype']!='byField'}{else}style="display:none;"{/if}>
                                        <option value="byField">请选择时间统计方式</option>
                                        {foreach item=timeFormat key=timeFormatKey from=$timeFormatType}
                                            <option {if $chart_info['groupInfo'][1]&&$chart_info['groupInfo'][1]['groupbytype']==$timeFormatKey} selected {/if} value="{$timeFormatKey}">{$timeFormat}</option>
                                        {/foreach}
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    显示数据总条数
                                </td>
                                <td width="35%">
                                    <input type="number" name="limit" id="limit" class="detailedViewTextBox input-width-70" autocomplete="off" value="{$chart_info['limit']}">
                                </td>
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    <input type="checkbox" checked="" id="orderby_check" name="orderby_check" {if $chart_info['orderby_type']}checked{/if} onchange="selfDefinedReport.orderbycheckChange(this)">
                                    启用按统计值排序
                                </td>
                                <td width="35%">
                                    <select name="orderby_type" id="orderby_type" class="detailedViewTextBox input-width-70">
                                        <option {if $chart_info['orderby_type']=='desc'}selected{/if} value="desc">倒序</option>
                                        <option {if $chart_info['orderby_type']=='asc'}selected{/if} value="asc">顺序</option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    {'LegendSettings'|@getFixedLabel}
                                </td>
                                <td width="35%">
                                    <select name="legend_type" id="legend_type" class="detailedViewTextBox input-width-45">
                                        {foreach item=legendTyp key=legendTypKey from=$legendType}
                                            <option {if $chart_info['legend1']->type==$legendTypKey} selected {/if } value="{$legendTypKey}">{$legendTyp}</option>
                                        {/foreach}
                                    </select>
                                    <select name="legend_orient" id="legend_orient" class="detailedViewTextBox input-width-45">
                                        {foreach item=legendOri key=legendOriKey from=$legendOrient}
                                            <option {if $chart_info['legend1']->orient==$legendOriKey} selected  {/if }  value="{$legendOriKey}">{$legendOri}</option>
                                        {/foreach}
                                    </select>
                                </td>
                                <td width="15%" class="DetailedTd1Label" align="right" {if $chart_info['chart_type']=='pie'||$chart_info['chart_type']=='funnel' ||$chart_info['chart_type']=='simple_sunburst'} style="visibility: hidden;"{/if}>
                                    <input type="checkbox" id="xaxis_check" name="xaxis_check" checked onchange="selfDefinedReport.xaxisCheckChange(ld(this))">
                                    X轴类型
                                </td>
                                <td width="35%" {if $chart_info['chart_type']=='pie'||$chart_info['chart_type']=='funnel' ||$chart_info['chart_type']=='simple_sunburst'} style="visibility: hidden;"{/if}>
                                    <select name="xaxis_type" id="xaxis_type" class="detailedViewTextBox input-width-30">
                                        {foreach item=axisTyp key=axisTypKey from=$axisType}
                                            <option {if $chart_info['xaxis1']->type==$axisTypKey} selected {/if}value="{$axisTypKey}">{$axisTyp}</option>
                                        {/foreach}
                                    </select>
                                    <input type="text" name="xaxis_name" id="xaxis_name" placeholder="输入X轴名称" value="{$chart_info['xaxis1']->name}" class="detailedViewTextBox input-width-30" autocomplete="off">
                                    <select name="xaxis_name_rotate" id="xaxis_name_rotate" class="detailedViewTextBox input-width-30">
                                        <option {if $chart_info['xaxis1']->axisLabel->rotate==0} selected {/if} value="0">X轴刻度值倾斜度数 0°</option>
                                        <option {if $chart_info['xaxis1']->axisLabel->rotate==45} selected {/if} value="45">X轴刻度值倾斜度数 45°</option>
                                        <option {if $chart_info['xaxis1']->axisLabel->rotate==90} selected {/if} value="90">X轴刻度值倾斜度数 90°</option>
                                        <option {if $chart_info['xaxis1']->axisLabel->rotate==-45} selected {/if} value="-45">X轴刻度值倾斜度数 -45°</option>
                                        <option {if $chart_info['xaxis1']->axisLabel->rotate==-90} selected {/if} value="-90">X轴刻度值倾斜度数 -90°</option>
                                    </select>
                                </td>
                            </tr>
                            <tr id="yaxistr" {if $chart_info['chart_type']=='pie'||$chart_info['chart_type']=='funnel' ||$chart_info['chart_type']=='simple_sunburst'} style="display: none;"{/if}>
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    <input type="checkbox" checked="" id="yaxis_left_check" name="yaxis_left_check" class="" {if $chart_info['yaxis1']->left}checked{/if} onchange="selfDefinedReport.xaxisCheckChange(ld(this))">
                                    启用左Y轴
                                </td>
                                <td width="35%">
                                    <select name="yaxis_left_type" id="yaxis_left_type" class="detailedViewTextBox input-width-45">
                                        {foreach item=axisTyp key=axisTypKey from=$axisType}
                                            <option {if $chart_info['yaxis1']->left->type==$axisTypKey} selected {/if} value="{$axisTypKey}">{$axisTyp}</option>
                                        {/foreach}
                                    </select>
                                    <input type="text" name="yaxis_left_name" id="yaxis_left_name" placeholder="输入左Y轴名称" class="detailedViewTextBox input-width-45" autocomplete="off" value="{$chart_info['yaxis1']->left->name}">
                                </td>
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    <input type="checkbox" id="yaxis_right_check" name="yaxis_right_check" class="" value="" {if $chart_info['yaxis1']->right}checked{/if} onchange="selfDefinedReport.xaxisCheckChange(ld(this))">
                                    启用右Y轴
                                </td>
                                <td width="35%">
                                    <select name="yaxis_right_type" id="yaxis_right_type" class="detailedViewTextBox input-width-45" {if $chart_info['yaxis1']->right}style="display:block"{else}style="display:none"{/if}>
                                        {foreach item=axisTyp key=axisTypKey from=$axisType}
                                            <option {if $chart_info['yaxis1']->right->type==$axisTypKey} selected {/if} value="{$axisTypKey}">{$axisTyp}</option>
                                        {/foreach}
                                    </select>
                                    <input {if $chart_info['yaxis1']->right}style="display:block"{else}style="display:none"{/if} type="text" name="yaxis_right_name" id="yaxis_right_name" value="{$chart_info['yaxis1']->right->name}" placeholder="输入右Y轴名称"  class="detailedViewTextBox input-width-45" autocomplete="off">
                                </td>
                            </tr>
                            <tr id="can_penetrate_tr" {if $chart_info['chart_type']!='pie'&&$chart_info['chart_type']!='funnel'}style="display:none;"{/if} >
                                <td width="15%" class="DetailedTd1Label" align="right">
                                    <input type="checkbox" id="can_penetrate" name="can_penetrate" {if $chart_info['can_penetrate']=='yes'}checked{/if}>
                                    允许穿透
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" class="editrelhead">
                                    <b>统计字段设置</b>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" style="padding:0 10px;">
                                    <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed" id="totalColumnList">
                                        <thead>
                                        <tr>
                                            <td width="10%" align="center">计算方法</td>
                                            <td width="50%" align="center">统计字段</td>
                                            <td width="10%" align="center">展现形式</td>
                                            <td width="10%" align="center">显示名称</td>
                                            <td {if $chart_info['chart_type']=='pie'|| $chart_info['chart_type']=='funnel'|| $chart_info['chart_type']=='simple_sunburst'}style="display:none;"{/if} class="render-line-yaxis-td" width="10%" align="center">选择Y轴</td>
                                            <td width="10%" align="center">操作</td>
                                        </tr>
                                        </thead>
                                        <tbody id="columnList">
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" class="editrelhead">
                                    <b>条件设置</b>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" style="padding:0 10px;">
                                    <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed" id="conditionColumnList">
                                        <thead>
                                        <tr tag="">
                                            <td align="right" colspan="5" style="border-bottom: none;">
                                                <a title="文件夹排序" class="pg-btn-blue dinline-block rfloat" data-groupid="1" onclick="selfDefinedReport.addNewConditionGroup(this);">
                                                    <span>添加组合条件</span>
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="20%" align="center">选择字段</td>
                                            <td width="15%" align="center">选择条件</td>
                                            <td width="40%" align="center">关键词</td>
                                            <td width="15%" align="center">筛选关系</td>
                                            <td width="10%" align="center">操作</td>
                                        </tr>
                                        </thead>
                                        <tbody id="highSearch">
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" class="editrelhead">
                                    <b>{'SHOWINGRECORDS'|@getFixedLabel}{'Setup'|@getFixedLabel}</b>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" class="DetailedTd1Label select-input">
                                    <input type="checkbox" id="linkmodulecheck" {if $chart_info['linkmodulecheck']==yes}checked{/if}>
                                    <label>{'SETASLINKMODULE'|getFixedLabel}</label>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" class="DetailedTd1Label select-input">
                                    <input type="checkbox" id="show_athome" name="show_athome" {if $chart_info['show_athome']==yes}checked{/if}>
                                    <label>{'showAtPcHome'|getFixedLabel}</label>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" class="DetailedTd1Label select-input padL30">
                                    <input id="show_athome_person" name="show_athome_person" type="checkbox" {if isset($chart_info['show_athome_info']['person'])&&$chart_info['show_athome_info']['person']=='yes'}checked{/if}>
                                    <label>{'showAtPcHomeOfScope'|getFixedLabel}</label>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" class="DetailedTd1Label select-input padL30">
                                    <input id="show_athome_timecheck" name="show_athome_timecheck" type="checkbox" {if isset($chart_info['show_athome_info']['timecheck'])&&$chart_info['show_athome_info']['timecheck']=='yes'}checked{/if}>
                                    <label>{'showAtPcHomeOfTime'|getFixedLabel}</label>
                                    <select style="width:100px;" name="show_athome_time" id="show_athome_time" class="detailedViewTextBox">
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" class="DetailedTd1Label select-input padL30">
                                    <input id="show_athome_approve" name="show_athome_approve" type="checkbox" {if isset($chart_info['show_athome_info']['approve'])&&$chart_info['show_athome_info']['approve']=='yes'}checked{/if}>
                                    <label>{'showAtPcHomeOfApprove'|getFixedLabel}</label>
                                </td>
                            </tr>
{*                            <tr>*}
{*                                <td colspan="4" style="padding:0 30px;">*}
{*                                    <input type="checkbox">&nbsp;在移动端首页显示*}
{*                                </td>*}
{*                            </tr>*}
{*                            <tr>*}
{*                                <td colspan="4" style="padding:0 50px;">*}
{*                                    <div style="display:flex;justify-content: flex-start">*}
{*                                        <div style="padding:0 10px;"><input type="checkbox">&nbsp;关联首页数据查看范围</div><div style="padding:0 10px;"><input type="checkbox">&nbsp;关联首页数据查看范围</div>*}
{*                                    </div>*}
{*                                </td>*}
{*                            </tr>*}
                            </tbody>
                        </table>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
        </form>
    </div>
    <div class="tab-contents" id="chartPreview" style="display:none;">
        <table class="" border="0" cellspacing="0" cellpadding="0" width="100%">
            <tbody>
                <tr>
                    <td colspan="4" class="editrelhead">
                        <b>{'PREVIEW'|@getFixedLabel}</b>
                    </td>
                </tr>
                <tr>
                    <td colspan="4">
                        <div id="myChart" style="margin:0 auto 60px auto;width: 800px; height: 600px;" >
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

</div>
<script>
    var chart_info = {$chart_info|json_encode};
    var timeValueArr = {$timeValueArr};
    let mainmodule = ld('#mainmodule').val();
    let chartType = ld('#chart_type').val();

    var popupobj=CrmPopup.getPopupObj("last");
    var divid = popupobj.divid;
    //模块 选择
    ld(document).ready(function() {
        ld('#mainmodule').select2({
            language: 'zh-CN',
            dropdownParent: ld('#'+divid)
        });

    });

    selfDefinedReport.xaxisCheckChange()
    if(chart_info){
        mode = 'edit';
    }else{
        mode = 'init';
    }
    // 相关模块
    selfDefinedReport.getRelatedModule(chart_info);
    selfDefinedReport.getTotalColumn(mode,chart_info);
    
    
  
    
    if(chart_info){
        //编辑的时候
        customRenderChart.setChart(chart_info);
        ld('.set-info').hide();
        var step = "{$step}";
        if(step==1){
            ld('.tab-one').removeClass('tab-active');
            ld('#for_chart_set').addClass('tab-active');
            ld('#chart_set').show();
        }else{
            ld('#base_set').show();
        }
    }else{
        customRenderChart.initChart('line');
        //新建的时候
        totalColumnListTableObj.getChartColumnType('line');
    }
    function changeTab(obj){
        ld(obj).siblings().removeClass('ld-ui-tabs-active');
        ld(obj).addClass('ld-ui-tabs-active');
        ld('.tab-contents').hide();
        let fortab = ld(obj).attr('for');
        if(fortab=='chartPreview'){
            selfDefinedReport.saveInfo(4,'no');
        }
        ld('#'+fortab).show();
    }
</script>