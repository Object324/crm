<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js?v={$GLOBALMINVERSION}" type="text/javascript"></script>
<script language="javascript" type="text/javascript" src="{$JSURL}include/js/general.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/OperationLogs.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="OperationLogs" id="form" onsubmit="puyoungJS_DialogBox.block();">
    <input type='hidden' name='module' value='OperationLogs'/>
    <input type='hidden' name='action' value='OperationLogs'/>
    <input type='hidden' name='record' id='record' value="{$ID}"/>
    <input type='hidden' name='parenttab' value='Settings'/>
    <input type='hidden' name='logtype' value='{$LogType}'/>
    <input id="search_date_custom" type="hidden" value="">

    <div class="main_grid_top">
        <div class="grid-view-title lfloat overflow-hidden">
            <span class="grid-view-name dinline-block lfloat">
                {$Title}<i class="ld-fonticon ld-fonticon-help padL10 tip-items-list" data-tip="{'OperationLogsTips'|@getFixedLabel}" data-direction="top" data-type="position"></i>
            </span>
            <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
            <select fieldtype="select" name="selectmodule" id="selectmodule" class="btn-radius-system width150 lfloat" onchange="Operationlogs.changeModule(this)" style="display:none;height:30px">
                {foreach name="selectmodule" key=modulename item=modulelabel from=$SELECTMODULE}
                    <option value="{$modulename}" >{$modulelabel}</option>
                {/foreach}
            </select>
        </div>
        <div class="grid_tool">
            <div class="displayflex">
                <a id="set_logduration" href="javascript:;" class="ld-button ld-button-primary" title="{'SET'|@getFixedLabel}">{'SET'|@getFixedLabel}</a>
            </div>
        </div>
    </div>
    <div class="main_grid_set select-input ld-wordwrap-listcontent" id="setLogsConditions" style="display: flex;height: 50px;align-items: center;">
        {* <span class="grid-view-choose dinline-block lfloat">{'operatoroer'|@getFixedLabel}</span> *}
        {*操作人*}
        <div class="ld-operationlog-chooseusers" id="ld-operationlog-chooseusers" style="height: inherit;">
            <input id="customscope_type" type="hidden" value="" name="customscope_type">
            <input id="customscope_ids" type="hidden" value="SmOwner_Search_All" name="customscope_ids">
            <div class="" id="showselectsearchscope" style="display: flex;align-items: center;">
            {assign var=fldname value='SmOwnerSearchScope'}
                <label>{'operatoroer'|@getFixedLabel}</label>
                <div class="ld-form-item-content" style="width: 150px;">
                    <select onchange="Operationlogs.setScope_onchange(this)" id="SmOwnerSearchScope" name="SmOwnerSearchScope" style="display:none">
                    {foreach key=User_Key item=User_value from=$Merge_SmOwner}
                        {foreach key=User_id item=User_name from=$User_value}
                            {foreach key=User_name_key item=User_name_value from=$User_name}
                                {if $User_id eq 'smowner_search_senior'}
                                    {assign var="show" value=1}
                                    <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if}  value="{$User_id}">{$User_name_key}</option>
                                {else}
                                    <option {if $displayinactiv=='no' && in_array($User_id,$inactiveuser)} style="display: none;" {/if}  value="{$User_id}" {if $User_id eq 'SmOwner_Search_All'} selected="" {/if}>{$User_name_key}</option>
                                {/if}
                
                            {/foreach}
                        {/foreach}
                    {/foreach}
                    </select>
                </div>
                {if $show eq 1}
                    <a class="icon-range tip-items-list" href="javascript:void(0);" data-tip="{'VIEWRANGE'|@getFixedLabel}" data-direction="top" data-type="position" onclick="Operationlogs.setScope('senior')"></a>
                {/if}
            </div>
        </div>
        {*操作时间*}
        <div class="ld-operationlog-settime">
            <span class="grid-view-choose dinline-block lfloat">
                {'operatoroertime'|@getFixedLabel}
            </span>
            <div class="home_laydate_div" style="margin: 0 0 3px 10px;">
                <input type="hidden" class="laydate_time_value" id="laydate_time_value" data-value="{$timesearchdefault}">
                <input type="hidden" class="laydate_time_hiddenvalue" id="laydate_time_hiddenvalue">
                <input type="text" {if $current_language eq 'en'}style="width:120px;"{/if} placeholder="选择" class="home_laydate_time laydate_time cursorPointer" readonly="" value="{$DATASELECT[$timesearchdefault]}">
                <div class="home_laydate_jiantou laydate_jiantou" style="top:14px;"></div>
            </div>
        </div>
        {*操作行为*}
        <div class="ld-operationlog-operationaction">
            <span class="grid-view-choose dinline-block lfloat" style="margin-right: 10px;">
                {'OperationBehavior'|@getFixedLabel}
            </span>
            <div class="ld-form-item-content" style="width: 150px;">
                <select fieldtype="select" name="selectoperation" id="selectoperation" class="ld-select-inner" style="display:none;">
                    {foreach key=action item=actionlabel from=$available_actions}
                        <option value="{$action}">{$actionlabel}</option>
                    {/foreach}
                </select>
            </div>
        </div>
        {*查询按钮*}
        <div class="ld-operationlog-search">
            <a id="searchlogs" href="javascript:;" class="ld-button ld-button-primary" title="{'QUERYTO'|@getFixedLabel}">{'QUERYTO'|@getFixedLabel}</a>
        </div>
    </div>
    {* <div class="main_grid_box">
    </div> *}
    <div id="ld-operationlog-mainlist">
        {include file='Settings/OperationLogsList.tpl' FunctionObj = OperationLogs}
    </div>
</form>

<style>
    .ld-operationlog-settime{
        margin-left: 100px;
        display: flex;
        align-items: center;
    }
    .ld-operationlog-operationaction{
        margin-left: 100px;
        display: flex;
        align-items: center;
    }
    .ld-operationlog-operationaction .chzn-container-single .chzn-single{
        line-height: initial;
    }
    .ld-operationlog-chooseusers .chzn-container-single .chzn-single{
        line-height: initial;
    }
    .ld-operationlog-search{
        margin-left: 30px;
        display: flex;
        align-items: center;
    }
    .ld-operationlog-setlogtime{
        line-height: 60px;
        display: flex;
        justify-content: center;
        align-items: center;
    }
</style>

<script>
    //声明对象
    var Operationlogs=new OperationLogs();
    Operationlogs.bindEvent();
    //下拉框
    var selectobj_field = ld("#"+popupobj.divid).find("select[name=selectoperation]");// 操作行为
    var cls_resetComboxHtmlobj=new cls_resetComboxHtml("selectoperation");
    cls_resetComboxHtmlobj.setComboxObjHtml();
    var selectwidth = Tools.getParentobjByChild(selectobj_field,'div').width();
    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj_field,selectwidth+10);
    var selectobj_field = ld("#"+popupobj.divid).find("select[name=SmOwnerSearchScope]");// 操作人
    var cls_resetComboxHtmlobj=new cls_resetComboxHtml("SmOwnerSearchScope");
    cls_resetComboxHtmlobj.setComboxObjHtml();
    var selectwidth = Tools.getParentobjByChild(selectobj_field,'div').width();
    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj_field,selectwidth+10);
    //日历
    laydate.render({
        elem: '.home_laydate_time',
        theme: 'type-ym',
        trigger: 'click',
        btns: [],
        type: 'date',
        newType: 'date',
        range: true,
        /** 自定义选择时间区间后，触发的时间变化回调函数 */
        change: function (value, date, edate) {
            ld('.home_laydate_time').val(arrJsPopLabel['custom']);//选择日期时赋值custom
            ld('.laydate_time_hiddenvalue').val(value);
            value=value.split(' - ');
            var begin_date=value[0];
            var end_date=value[1];
            value=begin_date+'~'+end_date;
            ld('#search_date_custom').val(value);
            ld(" .layui-laydate").remove();//关掉弹出层
        },
        /** 时间选择变化后，触发的回调函数 */
        /* timeChange: function () {
            initWidgets();
        } */
    });
    
</script>