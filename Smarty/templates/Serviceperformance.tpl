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
<script type="text/javascript">
	jQuery.noConflict();
</script>
{if $PICKIST_DEPENDENCY_DATASOURCE neq ''}
<script type="text/javascript">
     fielddepend=new FieldDependencies({$PICKIST_DEPENDENCY_DATASOURCE});
	jQuery(document).ready(function() {ldelim} (fielddepend.init()) {rdelim});
</script>
{/if}
<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="action" value="createtemplatePrint"/>
    <input type="hidden" name="mode" value="create"/>
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="selectserverttab" id='selectserverttab' value="{$SELECTSERVERTTABID}" />
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_SERVICE_PERFORMANCE_PARAMETERS'|@getFixedLabel}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'Performance_measures'|@getFixedLabel}</span>
        <select fieldtype="select" name="TemplateModule" onchange="templateServerSel(this)" id="TemplateModule" class="btn-radius-system" style="width:180px;">
            {foreach item=tabname key=tabid from=$SELECTTABCNT}
                {if $tabid eq $SELECTSERVERTTABID}
                    <option value="{$tabid}" selected="true">{$tabname}</option>
                {else}
                    <option value="{$tabid}">{$tabname}</option>
                {/if}
            {/foreach}
        </select>
    </div>
    <div class="grid_tool">
    </div>
</div>
<div class="main_grid_set select-input ld-wordwrap-listcontent" id="setLogsConditions" style="display: flex;height: 50px;align-items: center;">
    {if $SELECTSERVERTTABID eq 2}
        <div style="height: 42px;padding-top: 3px;" id="table_serviceformancepick">
            {include file='Settings/ServicePerformanceContentPick.tpl'}
        </div>
    {/if}
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="serviceperformance_div" class="cont_wrap clear_float">
            
            <div name="serviceperformancecontent">
                {include file="ServiceperformanceContent.tpl"}
            </div>
         
            <div class="listRloesHelp">
                <font color="red">{'TIPS'|@getFixedlabel}:</font>
                {if $servicetype eq 'bill_area'}
                    <ul>
                        <li>{'Performance_scores_bill_area'|@getFixedLabel}</li>
                        {if 'ProjectTask'|@vtlib_isModuleActive}
                            <li>{'Project_scores_bill_area'|@getFixedLabel}</li>
                        {/if}
                    </ul>
                {else}
                    <ul>
                        <li>{'Performance_scores_1'|@getFixedLabel}</li>
                        {if 'ProjectTask'|@vtlib_isModuleActive}
                            <li>{'Performance_scores_2'|@getFixedLabel}</li>
                            <li style="text-indent: 38px;">{'Performance_scores_3'|@getFixedLabel}</li>
                            <li style="text-indent: 38px;">{'Performance_scores_4'|@getFixedLabel}</li>
                            <li style="text-indent: 38px;">{'Performance_scores_5'|@getFixedLabel}</li>
                            <li style="text-indent: 38px;">{'Performance_scores_6'|@getFixedLabel}</li>
                            <li style="text-indent: 38px;">{'Performance_scores_7'|@getFixedLabel}</li>
                            <li style="text-indent: 38px;">{'Performance_scores_8'|@getFixedLabel}</li>
                            <li style="text-indent: 38px;">{'Performance_scores_9'|@getFixedLabel}</li>
                            <li style="text-indent: 38px;">{'Performance_scores_10'|@getFixedLabel}</li>
                        {/if}
                    </ul>
                {/if}
            </div>
        </div>
    </div>
</div>

<div id="divPrintAllocate" class="D_pop_box LdPopWidth600px" style="display:none;position:absolute;z-index:10000;"></div>
<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>
<script>
{literal}
var popupobj=new Object();
popupobj.divid="div_servieperformance";
CrmPopup.global_listPopupObj.push(popupobj);
{/literal}
function deletegroup(obj,groupid)

{ldelim}
	$("status").style.display="inline";
        new Ajax.Request(
                'index.php',
                {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                        method: 'post',
                        postBody:'module=Users&action=UsersAjax&file=GroupDeleteStep1&groupid='+groupid,
                        onComplete: function(response) {ldelim}
                                $("status").style.display="none";
                                $("tempdiv").innerHTML=response.responseText;
								fnvshobj(obj,"tempdiv");
                        {rdelim}
                {rdelim}
        );
{rdelim}
</script>