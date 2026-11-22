{if {$selectpage} eq 'functionsetting'}
    {*功能设置*}
    <div class="cont_wrap clear_float">
        <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
            <tr>
                <td class="ld-form-item-label">
                    {'ACTIVATE'|@getFixedLabel}{'CallRecording'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    <input name="callrecordstatus" {if $callrecordstatus eq 'yes'}checked="" {/if} type="checkbox" class="second_switch" onclick="callrecordsetting.enableCallRecord(this)">
                    <a href="javascript:;" onclick="callrecordsetting.editFields()" class="ld-button ld-button-primary rfloat" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
                </td>
            </tr>
        </table>
        <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <th colspan="2">{'PHONECALLINFIELDS'|@getFixedLabel}</th>
            </tr>
            {assign var="i" value=0}
            {foreach key=module item=label from=$phonefieldlabel}
                {assign var="j" value=$i++}
                {if $j mod 2 eq '0'}
                    <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                {else}
                    <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                {/if}
                    <td width="20%">{$module|@getTranstab}</td>
                    <td width="80%">{$label}</td>
                </tr>
            {/foreach}
        </table>
        <div style="padding: 10px;">
            <div style="color:red;font-weight: bold;">{'Attention'|@getFixedLabel}：</div>
            <div>1、通话录音功能仅限安卓的灵当APP使用</div>
            <div>2、启用功能后打开APP时，将自动同步最近30天</div>
        </div>
    </div>
{elseif {$selectpage} eq 'callrecordlogs'}
    {* 通话记录日志 *}
    <div class="" id="setLogsConditions">
        <table class="" id="CallRecordLogsTable" width="100%" cellspacing="0" cellpadding="0" border="0">
            <tr style="width: 100%;display: block;">
                <td class="ld-form-item-label ld-callrecord-header-td" align="right">
                    {'SELECTMODULE'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content" >
                    <select fieldtype="select" name="selectmodule" id="selectmodule" class="ld-select-inner" onchange="" style="">
                        {foreach name="selectmodule" key=modulename item=modulelabel from=$SELECTMODULE}
                            <option value="{$modulename}" >{$modulelabel}</option>
                        {/foreach}
                    </select>
                </td>
                <td class="ld-form-item-label ld-callrecord-header-td" align="right">
                    {'SELECT'|@getFixedLabel}{'DATE'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content" >
                    <input name="startdate" id="businesslogstartdate" class="Wdate ld-input-inner width120"  type="text"  size="20" maxlength="10" value="{$startdate}" onClick="WdatePicker();">
                    ~
                    <input name="enddate" id="businesslogenddate" class="Wdate ld-input-inner width120"  type="text"  size="20" maxlength="10" value="{$enddate}" onClick="WdatePicker();">
                </td>
            </tr>
            <tr style="width: 100%;display: block;">
                <td class="ld-form-item-label ld-callrecord-header-td" align="right">
                    {'Calltype'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content" >
                    <select fieldtype="select" name="selectcalltype" id="selectcalltype" class="ld-select-inner" style="">
                        {foreach key=value item=label from=$calltypes}
                            <option value="{$value}">{$label}</option>
                        {/foreach}
                    </select>
                </td>
                <td class="ld-form-item-label" align="right" style="width: 75px;padding:0;">

                </td>
                <td class="ld-form-item-content" >
                    <div class="marL15 marR10 ld-flex-start ld-flex-wrap" id="basicSearchNewDiv">
                        <div id="basicsearchcolumns_real" style="width:112px;">
                            <select name="search_field" onchange="" id="bas_searchfield" class="commonSelectPop gwidth100 overflow-space" style="border-radius: 4px 0 0 4px;border-right:none;" >
                                {foreach key=value item=label from=$basicsearch_options}    
                                    <option value="{$value}">{$label}</option>
                                {/foreach}
                            </select>
                            <input type="hidden" name="searchtype" value="BasicSearch">
                        </div>
                        <div class="ld-listview-basicsearch">
                            <input type="text" class="commonSelectPop gwidth100 padR40" onkeyup="callrecordsetting.setShowOrHideClearIcon()" 
                            onclick="" name="search_text" value="{$SEATCH_INPUT.search_text|htmlspecialchars}" 
                            autocomplete="off" style="border-radius: 0 4px 4px 0;padding-right:40px;">
                            <b style="display: none;position: absolute;right:5px;top:0;cursor: pointer" class="ld-icon-clearsearch" onclick="callrecordsetting.clearBasicSearch(this);"></b>
                        </div>
                    </div>
                </td>
                <td class="ld-form-item-content">
                    <a href="javascript:;" class="ld-button ld-button-primary" onclick="callrecordsetting.searchLogs();" title="{'SEARCH'|@getFixedLabel}">{'SEARCH'|@getFixedLabel}</a>
                </td>
            </tr>

        </table>
    </div>
    <div id="ld-operationlog-mainlist">
        {include file="Settings/OperationLogsList.tpl" FunctionObj = CallRecordSetting}
    </div>
    <style>
        .ld-callrecord-header-td{
            width: 150px !important;
            padding: 0 !important;
        }
    </style>
{/if}
