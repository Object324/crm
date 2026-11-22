<title>{$report_info['report_name']}</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link type="text/css" rel="stylesheet" href="{$CSSURL}themes/softed/CustomTable.css">
<script type="text/javascript" language="JavaScript">
    var frommobile = '{$frommobile}';
    var homefile = '{$homefile}';
</script>
{*链接模块 点击打开新页签报错  需要重新载入js,因为打开新页签没有leftmenu了*}
{if $frommobile=='yes'|| $isAjax=="no"}
    {*//移动端  zxm20221019*}
    <link href="{$CSSURL}themes/softed/common.css" rel="stylesheet">
    <link href="{$CSSURL}themes/softed/style.css" rel="stylesheet">
    <link href="{$CSSURL}themes/softed/leftmenu.css" rel="stylesheet">
    <link href="{$CSSURL}crmcommon/css/treeview/jquery.treeview.css" rel="stylesheet">
    <link rel="stylesheet" href="{$CSSURL}themes/softed/select2.css" type="text/css" /><!--多选框-->
    <script type="text/javascript" src="{$JSURL}include/jquery/jquery.min.js"></script>
    <script type="text/javascript" src="{$JSURL}include/language/zh.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/Sortable.min.js"></script>
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
        var global_js_sync_id=[];
    </script>
    <script type='text/javascript' src='{$JSURL}include/js/cls_encryptyurl.js?v={$GLOBALMINVERSION}'></script>
    <script type='text/javascript' src='{$JSURL}include/js/crypto-js.min.js?v={$GLOBALMINVERSION}'></script>
    <script type="text/javascript" language="javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/echarts.min.js"></script><!--报表-->
    <script type="text/javascript" src="{$JSURL}include/js/general.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/menucommon.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/ldAjaxMobile.js"></script><!--移动端的ajax请求-->
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupDrag.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupLayer.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/select2.min.js?v={$GLOBALMINVERSION}"></script><!--多选框-->
    <script language="javascript" type="text/javascript" src="{$JSURL}crmcommon/js/My97DatePicker/WdatePicker.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/modules/CustomTables/CustomTables.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/modules/CustomTables/CustomTablesResize.js"></script>
    <script type="text/javascript" src="{$JSURL}include/js/freezecolumns.js"></script>
{else}
    <script type="text/javascript" src="include/js/modules/CustomTables/CustomTablesResize.js"></script>
    <script type="text/javascript" src="include/js/freezecolumns.js"></script>
    {*<script type="text/javascript" src="include/js/modules/CustomTables/styleSet.js"></script>*}
{/if}

<div class="customtable-content" id="customtable_content">
    <form id="chartInfoForm">
        <div style="display:block;min-height:45px" name='dvcondition'>
            <div style="display: none;">
                <input type="hidden" name="report_id" id="report_id" value="{$report_info['report_id']}"/>
                <input type="hidden" name="report_name" id="report_name" placeholder="{'ReportName'|@getFixedLabel}" value="{$report_info['report_name']}" class="detailedViewTextBox  input-width-70" autocomplete="off" required/>
                <input type="hidden" id="report_type" name="report_type" value="{$report_info['report_type']}">
                <input class="second_switch" type="checkbox" id="linkmodulecheck" name="linkmodulecheck" {if $report_info['linkmodulecheck']=='yes'}checked{/if}>
                <textarea class="detailedViewTextBox" name="description" style="margin-top: 3px; overflow: hidden; overflow-wrap: break-word; resize: horizontal; height: 52px;" id="description"  aria-label="{'OFTENUSEREPORTWORD'|@getFixedLabel}{'CAMCARDCAPTION'|@getFixedLabel}">{$report_info['description']}</textarea>
            </div>
            {if count($filterArr)>0}
            <div style="display: flex;justify-content: flex-end;width:calc(100% - 20px);padding:0 10px;margin:5px auto;">
                <label>
                    {'ShowFilterCriteria'|@getFixedLabel}
                    <input type="checkbox" id="toggleSearch" class="second_switch" {if $report_info['isshow_search']=='yes'}checked=""{/if}>
                </label>
            </div>
            <div id="searchList" style="{if $report_info['isshow_search']=='no'}display:none;{/if} {if $frommobile=='yes'}width:calc(100% - 20px);{else}width:80%;{/if}margin:0 auto;background-color: #transparent;padding: 10px;box-shadow: 0px 1px 2px 2px rgb(0 0 0 / 10%);">
                <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed" id="conditionColumnList">
                    <thead>
                    {foreach $filterArr as $filterGroup}
                    <tr>
                        {foreach $filterGroup as $filterLine}
                            <td width="15%" class="DetailedTd1Label" align="right">
                                <font color="red"></font>{$filterLine.display_name}
                            </td>
                            <td width="35%">
                                {*模糊查找*}
                                {if $filterLine.var_type=='string'}
                                    <input class="detailedViewTextBox  input-width-70" type="text" name="sqlvar_{$filterLine.var_name}" id="sqlvar_{$filterLine.var_name}" value="{$filterLine.default_value_actual}">
                                {/if}
                                {if $filterLine.var_type=='number' }
                                    <input class="detailedViewTextBox  input-width-70" type="number" name="sqlvar_{$filterLine.var_name}" id="sqlvar_{$filterLine.var_name}" value="{$filterLine.default_value_actual}">
                                {/if}
                                {if $filterLine.var_type=='date'}
                                    <input readonly type="text" class="detailedViewTextBox" name="sqlvar_{$filterLine.var_name}" autocomplete="off" value="{$filterLine.default_value_actual}" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd'{rdelim})">
                                {/if}
                                {if $filterLine.var_type=='datetime'}
                                    <input readonly type="text" class="detailedViewTextBox" name="sqlvar_{$filterLine.var_name}" autocomplete="off" value="{$filterLine.default_value_actual}" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss'{rdelim})">
                                {/if}
                                {if $filterLine.var_type=='select'}
                                    <select name="sqlvar_{$filterLine.var_name}" id="sqlvar_{$filterLine.var_name}" class="detailedViewTextBox input-width-70" >
                                        <option value=""></option>
                                        {foreach item=select_value key=i from=$filterLine['select_values_arr']}
                                            <option {if $select_value==$filterLine['default_value']}selected{/if} value="{$select_value}">{$select_value}</option>
                                        {/foreach}
                                    </select>
                                {/if}
                                {if $filterLine.var_type=='multiselect'}
                                    <select name="sqlvar_{$filterLine.var_name}[]" id="sqlvar_{$filterLine.var_name}" multiple class="detailedViewTextBox input-width-70 sqlvar-detail-selectmulti">
                                        {foreach item=select_value key=i from=$filterLine['select_values_arr']}
                                            <option {if in_array($select_value,$filterLine['default_values_arr']) }selected{/if} value="{$select_value}">{$select_value}</option>
                                        {/foreach}
                                    </select>
                                    <script>
                                        ld('#{$filterLine.var_name}').select2({ldelim}width:'90%',closeOnSelect: true{rdelim});
                                    </script>
                                {/if}
                                {if $filterLine.var_type=='selectuser'}

{*                                    {assign var=usefldlabel value=$filterLine.display_name}*}
{*                                    {include file='DetailView/Smowner.tpl'}*}
                                {/if}
                                {if $filterLine.var_type=='multiuser'}
                                    {assign var=usefldlabel value=$filterLine.display_name}
                                    {assign var=fldname value=$filterLine.var_name}
                                    {assign var=MODULE value=$filterLine.modulename}
                                    {assign var=secondvalue value=$filterLine.default_value}
                                    {assign var=fldvalue value=$filterLine.usernames_str}
                                    <div class="commonDetailedTextBox gwidth70 bgwhite lfloat" id="{$fldname}_name" name="{$fldname}_name" style="padding-left: 8px;overflow: hidden;text-overflow: ellipsis;">{$fldvalue}</div>
                                    <a class="icon-homeimg icon-select lfloat marT4" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='select_purview("{$fldname}_name","sqlvar_{$fldname}","User","sel_radio","search_yes","{$MODULE}","{$usefldlabel}","private")'></a>
{*                                    <a data-filterid='{$filterLine.id}' tag="selectMultiuser" data-popup_selecttype="users" data-fldname="{$fldname}" data-poptitle="{$filterLine.display_name}" data-module="{$MODULE}" class="icon-homeimg icon-select lfloat marT4" href="javascript:;" title="{'SELECT'|@getFixedLabel}"></a>*}
{*                                    <input class="icon-homeimg icon-clear inpb-reset lfloat marT2" type="button" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','{$fldname}','{$fldname}_name','','{$MODULE}','popupselectfield');"/>*}
                                    <input type="hidden" value="{$secondvalue}" id="sqlvar_{$fldname}" name="sqlvar_{$fldname}" />
                                {/if}
                                {if $filterLine.var_type=='checkbox'}
                                    <input class="second_switch"  {if $filterLine.default_value_actual eq 'on'}checked{/if} type="checkbox" id="sqlvar_{$filterLine.var_name}" name="sqlvar_{$filterLine.var_name}">
                                {/if}
{*                                审批组件筛选条件*}
                                {if $filterLine.var_type=='approvestatus'}
                                    <div class="home-header-approve-select approve-select" style="margin-top:0px;">
                                        {foreach item=approvearr key=j from=$ApproveList}
                                        <label for="sqlvar_{$filterLine.var_name}_{$approvearr.value}" class="overflow-space" style="max-width: 100px;display: inline-block;" ><input type="checkbox" id="sqlvar_{$filterLine.var_name}_{$approvearr.value}" name="sqlvar_{$filterLine.var_name}[]" value="{$approvearr.rawvalue}" {if $approvearr.rawvalue|@in_array:$filterLine['approvestatus_default_value_arr']}checked{/if}>{$approvearr.label}</label>{if $j eq 0}&nbsp;{/if}
                                        {/foreach}
                                    </div>
                                {/if}
{*                                选部门变量*}
                                {if $filterLine.var_type=='department'}
                                    {assign var=usefldlabel value=$filterLine.display_name}
                                    {assign var=fldname value=$filterLine.var_name}
                                    {assign var=MODULE value=$filterLine.modulename}
                                    {assign var=secondvalue value=$filterLine.default_value}
                                    {assign var=fldvalue value=$filterLine.groupnames_str}
                                    <div id="{$fldname}_name" name="{$fldname}_name" class="commonDetailedTextBox gwidth70 bgwhite lfloat" style="padding-left: 8px;overflow: hidden;text-overflow: ellipsis;">{$fldvalue}</div>
                                    <a data-filterid='{$filterLine.id}' tag="selectDepartment"  data-popup_selecttype="group" data-fldname="{$fldname}" data-poptitle="{$filterLine.display_name}" data-module="{$MODULE}" class="icon-homeimg icon-select lfloat marT4" href="javascript:;" title="{'SELECT'|@getFixedLabel}"></a>
                                    <input type="hidden" value="{$secondvalue}" id="sqlvar_{$fldname}" name="sqlvar_{$fldname}">
                                {/if}
{*                                当前操作员变量*}
                                {if $filterLine.var_type=='curroperator'}
                                    <div>{$filterLine.default_value}</div>
                                {/if}
                            </td>
                        {/foreach}
                    </tr>
                    {/foreach}
                </table>
                <div class="ld-flex-end">
                    {*<a id="hideSearch" style="margin-right:10px;" class="pg-btn-blue dinline-block">{'COLLAPSE'|@getFixedLabel}</a>*}
                    <a id="toSearch" class="pg-btn-blue dinline-block">{'SEARCHNEW'|@getFixedLabel}</a>
                </div>
            </div>
            {/if}
            <!--分页-->
            <div  style="display:block;height:42px;margin: 10px 0;">
                <div class="PageDiv0">
                    <ul>
                        <li name='totaldescription'>{$RECORDLISTRANGMSG}</li>{*共11条记录*}
                        <li><span id="goleft" class="no-icon-prevpage"></span></li>{*左边箭头*}
                        <li class="Input" id="pageoftotalpages">1/1</li>
                        <li><span id="goright" class="no-icon-nextpage"></span></li>
                        <li>{'GoTo'|@getFixedLabel}<input class="txtBox btn-radius-system pagenum_system search_bg marLR5" value="1" id="changePageCount" name='pagenum' type="text"/>{'PAGE'|@getFixedLabel}</li>
                        <li >
                            <select class="detailedViewTextBox" name="limitrecord" id="limitrecord">
                                <option value="20" {if $LimitRecord eq '20'} selected=""{/if}>20 {'ItemPage'|@getFixedLabel}</option>
                                <option value="50" {if $LimitRecord eq '50'} selected=""{/if}>50 {'ItemPage'|@getFixedLabel}</option>
                                <option value="100" {if $LimitRecord eq '100'} selected=""{/if}>100 {'ItemPage'|@getFixedLabel}</option>
                                <option value="200" {if $LimitRecord eq '200'} selected=""{/if}>200 {'ItemPage'|@getFixedLabel}</option>
                                <option value="500" {if $LimitRecord eq '500'} selected=""{/if}>500 {'ItemPage'|@getFixedLabel}</option>
                                <option value="1000" {if $LimitRecord eq '1000'} selected=""{/if}>1000 {'ItemPage'|@getFixedLabel}</option>
                                <option value="2000" {if $LimitRecord eq '2000'} selected=""{/if}>2000 {'ItemPage'|@getFixedLabel}</option>
                            </select>
                        </li>
                    </ul>
                </div>
            </div>

        </div>
        {include file="CustomTables/detailtable.tpl"}
    </form>
</div>
{if $isAjax=="no"}
    {*链接模块*}
    <script>
        getScriptBackWithURL('include/js/modules/CustomTables/CustomTablesSqlDetail.js',function() {
            var popupobj = CrmPopup.getPopupObj("last");
            if(popupobj){
                var divid = popupobj.divid;//链接模块
            }else{
                popupobj = new CrmPopup();
                var divid = "customtable_content";//链接模块
                popupobj.divid = divid;
                CrmPopup.global_listPopupObj.push(popupobj);
            }
            var CustomTablesSqlDetailObj = new CustomTablesSqlDetail();
            CustomTablesSqlDetailObj.setPopupobj(popupobj);
            CustomTablesSqlDetailObj.setDivid(divid);
            CustomTablesSqlDetailObj.setReportId('{$report_info['report_id']}');
            CustomTablesSqlDetailObj.init();
        });
    </script>
{/if}
<script>
    var s_height = ld(window).height();
    ld('#div_thResizableContent').css('height',s_height-165);
</script>
