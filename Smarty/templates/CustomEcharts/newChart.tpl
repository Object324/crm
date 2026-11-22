<!doctype html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
    <title>{'CREATE'|@getFixedLabel}{'statisticalGraphics'|@getFixedLabel}</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <link rel="stylesheet" href="crmcommon/js/My97DatePicker/skin/WdatePicker.css" type="text/css" />
    <!-- CSS -->
    <link href="crmcommon/js/bootstrap-4.6.0-dist/css/bootstrap.min.css" rel="stylesheet" >
    <link href="themes/softed/selfDefinedReport.css" rel="stylesheet" >
    <style>
        .flex-input-group{
            display:flex;
            justify-content: space-between;
        }
    </style>
    <script type="text/javascript">
        var language = "{$language}";
        var chart_info = {$chart_info|json_encode};
    </script>
    <script type="text/javascript" src="crmcommon/js/jquery/jquery-1.10.1.min.js"></script>
    <script type="text/javascript" src="crmcommon/js/My97DatePicker/WdatePicker.js"></script>
    <script type="text/javascript" src="crmcommon/js/jquery/echarts.min.js"></script>
    <!-- jQuery and JavaScript Bundle with Popper -->
    <script type="text/javascript" src="crmcommon/js/bootstrap-4.6.0-dist/js/bootstrap.bundle.min.js" ></script>
    <script type="text/javascript" src="include/js/modules/CustomEcharts/CustomEchartsCreate.js"></script>
    <script type="text/javascript" src="include/js/modules/CustomEcharts/renderChart.js"></script>
    <script type="text/javascript" src="include/js/ldAjax.js"></script>

</head>
<body style="margin:0 auto;">
<div class="chart-container">
    <div class="chart-create-header">{'CREATE'|@getFixedLabel}{'statisticalGraphics'|@getFixedLabel}</div>
    <div class="design-content">
        <div class="design-tab">
            <div class="tab-one tab-active" onclick="selectWhichSet(this)" for="base_set" cur-step="1">{'base'|@getFixedLabel}{'INFO'|@getFixedLabel}</div>
            <div class="tab-one" id="for_chart_set" onclick="selectWhichSet(this)" for="chart_set" cur-step="2">{'statisticalGraphics'|@getFixedLabel}{'CONFIGTHE'|@getFixedLabel}</div>
            <div class="tab-one" onclick="selectWhichSet(this)" for="data_set" cur-step="3">{'data'|@getFixedLabel}{'CONFIGTHE'|@getFixedLabel}</div>
            <div class="tab-one" onclick="selectWhichSet(this)" for="condition_set" cur-step="4">{'CONDITION'|@getFixedLabel}{'CONFIGTHE'|@getFixedLabel}</div>
            <div class="tab-one" onclick="selectWhichSet(this)" for="sort_set" cur-step="5">{'SORT'|@getFixedLabel}{'CONFIGTHE'|@getFixedLabel}</div>
        </div>
        <div class="design-body">
            {include file="CustomEcharts/newChartStepOne.tpl"}
            {include file="CustomEcharts/newChartStepTwo.tpl"}
            {include file="CustomEcharts/newChartStepThree.tpl"}
            {include file="CustomEcharts/newChartStepFour.tpl"}
            {include file="CustomEcharts/newChartStepFive.tpl"}
        </div>
    </div>
    <div class="show-chart" style="margin:0 15%;">
{*        <div id="chart_title" class="chart-title">{$chart_info['report_name']}</div>*}
        <div id="myChart" style="width: 100%;height:600px;"></div>
    </div>
</div>

<script type="text/javascript">
    var timeValueArr = {$timeValueArr};//时间选择值
    //
    customRenderChart.initChart('line');
    //渲染统计字段
    function selectWhichSet (obj){
        var report_id = ld('#report_id').val();
        if(report_id==''||report_id==undefined){
            return false;
        }
        $('.tab-one').removeClass('tab-active');
        $(obj).addClass('tab-active');
        var id = $(obj).attr('for');
        $('.set-info').hide();
        $('#'+id).show();
        var cur_step = $(obj).attr('cur-step');
        selfDefinedReport.saveInfo(cur_step-1);
    }
    selfDefinedReportEdit3.showFields();
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
        //新建的时候
        selfDefinedReport.getChartColumnType('line');
    }

</script>
</body>
</html>