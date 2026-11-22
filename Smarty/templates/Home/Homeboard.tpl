{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script>
    var salesCurrentIndex = 1;
    var current_language = "{$current_language}";
    AjaxJSPage("HomeStuff_js",'include/js/modules/Home/Homestuff.js');
</script>
<script type="text/javascript" src="include/js/modules/CustomEcharts/renderChart.js"></script>
<link rel="stylesheet" type="text/css" href="themes/softed/Homeboard.css"/>
<link rel="stylesheet" type="text/css" href="themes/softed/CustomTable.css"/>


<input id="homeLayout" type="hidden" value="{$LAYOUT}">
<input id="selectuserid" type="hidden" {if $selected_searchscope_value neq ''}value="{$selected_searchscope_value}"{/if}>
<input id="selectuserid_all" type="hidden" value="{$ALL_USER_ID}">
<input id="search_date_custom" type="hidden" value="">

<div id="home_index" class="home-index ld-bg-color" >
    <input id="boardid" type="hidden" value="{$Home_boardid}">
    <div class="home_header_top" >
        <div style="float: left;margin-top: 12px;">
            {include file='SearchScope_New.tpl'}
        </div>
        <div class="home_laydate_div" style="margin-left: 12px;">
            <input type="hidden" class="laydate_time_value" data-value="{$HOMEBOARD_CONTENT['timesearchdefault']}">
            <input type="hidden" class="laydate_time_hiddenvalue" {if $HOMEBOARD_CONTENT['customDateValue'] neq ''}value="{$HOMEBOARD_CONTENT['customDateValue']}"{/if}>
            <input type="text" {if $current_language eq 'en'}style="width:120px;"{/if} placeholder="选择" class="home_laydate_time laydate_time cursorPointer" readonly="" value="{$DATASELECT[$HOMEBOARD_CONTENT['timesearchdefault']]}">
            <div class="home_laydate_jiantou laydate_jiantou"></div>
        </div>
        <div id="homeboard_approve" style="position: relative;float: left;margin-top: 12px;margin-left: 20px;"></div>
        {*@edit:liushuai,2020-09-08,reason:【ID1000285】PC端：首页增加首页视图设置*}
        {if isset($PRMHOMEBOARD) && $PRMHOMEBOARD == 'yes'}{else}
            <div class="home-header-top-setting" {if $MODULE eq 'VisualAnalysis' } style="display: none" {/if}>
                <div style="margin-top: 12px;margin-right: 10px;">
                    <div  style="cursor: pointer;position: relative;" boardname="{$HOMEBOARDLISTNEW[$Home_boardid]}" class="homeboard_name"
                          tabindex="-2" id="homeboard_name" boardid="{$Home_boardid}">
                        {$HOMEBOARDLISTNEW[$Home_boardid]}
                        <span class="ld_icon_arrowdown" style="margin-left: 8px;"></span>
                        <div id="homeboard_List" tabindex="-1" style="outline: 0;" class="ld_homeboard_head_select">
                            {include file='Home/HomeboardDropList.tpl'}
                        </div>
                    </div>
                </div>
            </div>
        {/if}

    </div>
    <div id="home-content-div" class="home-content-div">
        <table width="100%" cellpadding="0" cellspacing="0" border="0" align="center" valign="top" id="homestuffdiv">
            <tr>
                <td width="100%" align="center" valign="top">
                    <div id="MainMatrix" class="show_tab" style="padding:0px;width:100%;position:relative;z-index:10;">
                        {include file="Home/Homeboard_layout.tpl"}
                    </div>
                </td>
            </tr>
        </table>
    </div>
</div>
<script language="javascript">

    //hzx XUQIU1002272 首页看板界面、设置，审批状态修改为下拉框，样式优化模块单据界面：查询分类、查看范围下拉框样式优化
    var approvelist = {$APPROVE_LIST};
    {literal}
    //首页查询审批状态过滤
    if(typeof global_home_approve !== "undefined"){
        global_home_approve = [];
    }else{
        var global_home_approve = [];//首页查询审批状态过滤
    }
    for(let i = 0;i<approvelist.length;i++){
        if(approvelist[i].selected){
            global_home_approve.push(approvelist[i].value);
        }
    }
    homeboardApproveRender(approvelist);//审批组件

    var Listpagepopupobj=new CrmPopup();
    Listpagepopupobj.type="home";
    Listpagepopupobj.refreshpage='no';
    Listpagepopupobj.searchtype="";//基本查询和高级查询，32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
    Listpagepopupobj.module='Home';
    CrmPopup.global_listPopupObj.push(Listpagepopupobj);
    //setHeight();

    {/literal}
</script>
{*<!-- Main Contents Ends Here -->*}
<script>
    var _isAdmin = '{$ISADMIN}';
    var version_account = '';
    var homeplatestuff_arr=[];//看板组件信息数组
    var Vt_homePageWidgetInfoList=[];
    function initStuffArr(){
        {if $HOMEBOARD_CONTENT['homeboard_plate']|@count > 0}

        {foreach item=plateinfo key=index_plate from=$HOMEBOARD_CONTENT['homeboard_plate']}
        homeplatestuff_arr[{$index_plate}]=0;
        Vt_homePageWidgetInfoList[{$index_plate}] = [
            {foreach item=stuffinfo key=index_stuff from=$plateinfo['homeboard_plate_stuff']}
            {if ($stuffinfo['stufftype'] neq 'Default' || $stuffinfo['stufftitle_label'] neq 'Home Page Dashboard'|@getTranslatedString:'Home')
        && $stuffinfo['stufftype'] neq 'DashBoard' && $stuffinfo['stufftype'] neq 'ReportCharts'}
            {ldelim}
                'boardstuffid':{$stuffinfo['boardstuffid']},
                'widgetId':{$stuffinfo['stuffid']},
                'widgetType':'{$stuffinfo['stufftype']}',
                'widgetlistType':'{$stuffinfo['stufflisttype']}',
                'chart_type':'{$stuffinfo['chart_type']}',//zxm 20230510 SQL统计图放首页 首页请求需要report_type和chart_type
                'plateindex':{$index_plate}
                {rdelim}
            {if $index_plate+1 < $HOMEBOARD_CONTENT['homeboard_plate']|@count || $index_stuff+1 < $plateinfo['homeboard_plate_stuff']|@count},{/if}
            {/if}
            {/foreach}
        ]
        {/foreach}
        {/if}
    }
    {literal}
    ld(function(){
        initWidgets();
        Header_Top_Load();
    })
    var div_width = CrmPopup.getClientWidth()-getLeftMenuWidth()-16;
    var boardid=ld("#boardid").val();
    // 首页日期加载
    homeboardLaydateRender();
    //edit: txy 2023/09/04 首页看板增加拖动排序功能
    homeboardListSorting();
    {/literal}
</script>
