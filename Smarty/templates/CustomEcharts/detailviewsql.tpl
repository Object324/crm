<title>{$mainInfo['report_name']}</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script type="text/javascript" language="JavaScript">
    var frommobile = '{$frommobile}';
    var homefile = '{$homefile}';
</script>
{if $frommobile=='yes'}
    {*//移动端  zxm20221019*}
    <link href="{$CSSURL}themes/softed/common.css" rel="stylesheet">
    <link href="{$CSSURL}themes/softed/style.css" rel="stylesheet">
    <link href="{$CSSURL}themes/softed/leftmenu.css" rel="stylesheet">
    <link href="{$CSSURL}crmcommon/css/treeview/jquery.treeview.css" rel="stylesheet">
    <link rel="stylesheet" href="{$CSSURL}themes/softed/select2.css" type="text/css" /><!--多选框-->
    <script type="text/javascript" src="{$JSURL}include/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="{$JSURL}include/language/zh.js"></script>
    <script type="text/javascript" language="JavaScript">
        var ld = $;
        var language='{$LANGUAGETYPE}';
        var CURRENT_USER_ID=1;
        var wx_userid='{$wx_userid}';
        var appusertoken='{$appusertoken}';
        var global_js_url='{$JSURL}';
        var global_commonurl='{$CRMCOMMONURL}';
        var global_js_version='{$GLOBALMINVERSION}';
        var iskehu001='{$iskehu001}';
    </script>
    <script type='text/javascript' src='{$JSURL}include/js/cls_encryptyurl.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/crypto-js.min.js?v={$GLOBALMINVERSION}'></script>
    <script type="text/javascript" language="javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/echarts.min.js"></script><!--报表-->
    <script type="text/javascript" src="{$JSURL}include/js/general.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/ldAjaxMobile.js"></script><!--移动端的ajax请求-->
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupDrag.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupLayer.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/select2.min.js?v={$GLOBALMINVERSION}"></script><!--多选框-->
    <script type="text/javascript" src="{$JSURL}include/js/cls_resetComboxHtml.js?v={$GLOBALMINVERSION}"></script>
    <script type="text/javascript" src="{$JSURL}include/js/picklist.js?v={$GLOBALMINVERSION}"></script>
    <script language="javascript" type="text/javascript" src="{$JSURL}crmcommon/js/My97DatePicker/WdatePicker.js"></script>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/tooltip.js?v={$GLOBALMINVERSION}"></script>
{/if}
<div id="customtable_content" class="customtable-content" style="height:100%;">
    {if count($sqlFilterArr)>0}
        {include file="CustomEcharts/sqlConditions.tpl"}
    {/if}
    <div class="padT10 padB10" name='dvcondition'>
        <div class="OtherConditionBut" id="OtherCondition">
            <span class="OtherConditionIcon"></span>
            {'screen'|@getFixedLabel}
        </div>
    </div>
    <div style="height:calc(100% - 55px);">
        {if $mainInfo['isshow_table'] == 'Top' }
            <div id="chartTable_{$request['report_id']}">
                {$chartSet['table']}
            </div>
        {/if}
        <div id="myChart_{$request['report_id']}" class="EchartDiv" style="width: 100%;{if $mainInfo['isshow_table'] == 'Top'|| $mainInfo['isshow_table'] == 'Bottom' }height:500px;{else}height:700px;{/if}"
                {$mainInfo['isshow_table']}></div>
        {if $mainInfo['isshow_table'] == 'Bottom' }
            <div id="chartTable_{$request['report_id']}">
                {$chartSet['table']}
            </div>
        {/if}
    </div>
</div>
<script>
    getJsScript('include/js/modules/CustomEcharts/CustomEchartsSqlDetail.js',function(){
        var popupobj = CrmPopup.getPopupObj("last");
        if(popupobj){
            var divid = popupobj.divid;//链接模块
        }else{
            popupobj = new CrmPopup();
            var divid = "customtable_content";//链接模块
            popupobj.divid = divid;
            CrmPopup.global_listPopupObj.push(popupobj);
        }
        var CustomEchartsSqlDetailObj = new CustomEchartsSqlDetail();
        CustomEchartsSqlDetailObj.SetChartJqObj(ld('#'+divid+' #myChart_' + '{$mainInfo['report_id']}'));
        CustomEchartsSqlDetailObj.SetTableJqObj(ld('#'+divid+' #chartTable_' + '{$mainInfo['report_id']}'));
        CustomEchartsSqlDetailObj.show(popupobj,divid,'{$mainInfo['report_id']}','{$chartSet['chart_type']}','');
    });
</script>

