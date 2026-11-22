<title>{$chart_info['report_name']}</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script type="text/javascript" language="JavaScript">
    var frommobile = '{$frommobile}';
    var homefile = '{$homefile}';
    var environment = '{$environment}';
    var crm_url = '{$crm_url}';
    var wx_version = '{$wx_version}';
    var mainmodule = '{$chart_info['mainmodule']}';
    var modulelabel = '{$chart_info['mainmodule']|@getTranstab}';
</script>
{if $frommobile=='yes'}
    {*//移动端  zxm20221019*}
    <link href="{$CSSURL}themes/softed/common.css" rel="stylesheet">
    <link href="{$CSSURL}themes/softed/style.css" rel="stylesheet">
    <link href="{$CSSURL}themes/softed/leftmenu.css" rel="stylesheet">
    <link rel="stylesheet" href="{$CSSURL}themes/softed/select2.css" type="text/css"/><!--多选框-->
    <script type="text/javascript" src="{$JSURL}include/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="{$JSURL}include/language/zh.js"></script>
    <script type="text/javascript" language="JavaScript">
        var ld = $;
        var language = '{$LANGUAGETYPE}';
        var wx_userid = '{$wx_userid}';
        var appusertoken='{$appusertoken}';
        var global_js_url = '{$JSURL}';
        var global_commonurl='{$CRMCOMMONURL}';
        var global_js_version = '{$GLOBALMINVERSION}';
    </script>
    <script type='text/javascript' src='{$JSURL}include/js/cls_encryptyurl.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/crypto-js.min.js?v={$GLOBALMINVERSION}'></script>
    <script type="text/javascript" language="javascript"
            src="{$CRMCOMMONURL}crmcommon/js/jquery/echarts.min.js"></script>
    <!--报表-->
    <script type="text/javascript" src="{$JSURL}include/js/general.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/ldAjaxMobile.js"></script>
    <!--移动端的ajax请求-->
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/select2.min.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/cls_resetComboxHtml.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/picklist.js?v={$GLOBALMINVERSION}"></script>
    <!--多选框-->
    <script language="javascript" type="text/javascript"
            src="{$JSURL}crmcommon/js/My97DatePicker/WdatePicker.js"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/tooltip.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/modules/CustomEcharts/renderChart.js"></script>
{/if}

<div id="customtable_content" style="height:100%;">
    <div class="flex-start padT10 padB10">
        <div class="OtherConditionBut" id="OtherCondition">
            <span class="OtherConditionIcon"></span>
            {'screen'|@getFixedLabel}
        </div>
    </div>
    <div style="height:calc(100% - 50px);">
        {if $chart_info['chart_type']!='simple_sunburst' && $chart_info['isshow_table'] == 'Top' }
            <div id="chartTable_{$report_id}">
                {$chart_info['table']}
            </div>
        {/if}
        <div id="myChart_{$report_id}" class="EchartDiv" style="width: 100%;{if $chart_info['chart_type']!='simple_sunburst' && ( $chart_info['isshow_table'] == 'Top'|| $chart_info['isshow_table'] == 'Bottom') }height:500px;{else}height:700px;{/if}" ></div>
        {if $chart_info['chart_type']!='simple_sunburst' && $chart_info['isshow_table'] == 'Bottom' }
            <div id="chartTable_{$report_id}">
                {$chart_info['table']}
            </div>
        {/if}
    </div>
</div>
<script type="text/javascript">
    getScriptBackWithURL('include/js/modules/CustomEcharts/CustomEchartsDetail.js',function(){
        var popupobj = CrmPopup.getPopupObj("last");
        if(popupobj){
            var divid = popupobj.divid;//链接模块
        }else{
            popupobj = new CrmPopup();
            var divid = "customtable_content";//链接模块
            popupobj.divid = divid;
            CrmPopup.global_listPopupObj.push(popupobj);
        }
        var CustomEchartsDetailObj = new CustomEchartsDetail();

        CustomEchartsDetailObj.SetChartJqObj(ld('#'+divid+' #myChart_{$chart_info['report_id']}'));
        CustomEchartsDetailObj.SetTableJqObj(ld('#'+divid+' #chartTable_{$chart_info['report_id']}'));
        CustomEchartsDetailObj.show(popupobj,divid,'{$chart_info['report_id']}','{$chart_info['chart_type']}','');
    });
</script>
