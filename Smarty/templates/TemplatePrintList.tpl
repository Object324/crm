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
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/TemplateprintList.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>
<!--新添加的部分-->
<div id="divPrintAllocate" class="D_pop_box LdPopWidth500px" style="display:none;width:500px;position:absolute;z-index: 9999;"></div>
<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="action" value="createtemplatePrint"/>
<input type="hidden" name="mode" value="create"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="printtabid" value="{$PRINTTABID}" />
<input type="hidden" name="blockidsetting" id="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" id="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_PRINT_TEMPLATE'|@getFixedLabel}{if $HelpHtml.TemplatePrintList neq '' }{$HelpHtml.TemplatePrintList}{/if}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
        <select fieldtype="select" onchange="TemplateprintList.templatePrintSel()" id="TemplateModule" name="TemplateModule"
         class="btn-radius-system width150" style="display:none">
            {foreach item=tabname key=tabid from=$PRINTTABS}
                {if $tabid eq $PRINTTABID}
                    <option value="{$tabid}" selected="true">{$tabname}</option>
                {else}
                    <option value="{$tabid}">{$tabname}</option>
                {/if}
            {/foreach}
        </select>
        
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" onclick="TemplateprintList.create(0,'Word')" class="ld-button ld-button-primary" title="{'CreateWordTemplate'|@getFixedLabel}">{'CreateWordTemplate'|@getFixedLabel}</a>
            <a href="javascript:;" onclick="TemplateprintList.create(0,'Excel')" class="ld-button ld-button-primary" title="{'CreateExcelTemplate'|@getFixedLabel}">{'CreateExcelTemplate'|@getFixedLabel}</a>
            <a href="javascript:;" onclick="TemplateprintList.create(0)" class="ld-button ld-button-primary" title="{'CreateHTMLTemplate'|@getFixedLabel}">{'CreateHTMLTemplate'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float" name="templateprintlist">
            {include file="TemplatePrintLists.tpl"}
        </div>
    </div>
</div>

<div id="divPrintAllocate" class="D_pop_box LdPopWidth600px" style="display:none;position:absolute;z-index:10000;"></div>
<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>
<script>
function deletegroup(obj,groupid)
{ldelim}
        new Ajax.Request(
                'index.php',
                {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                        method: 'post',
                        postBody:'module=Users&action=UsersAjax&file=GroupDeleteStep1&groupid='+groupid,
                        onComplete: function(response) {ldelim}
                                $("tempdiv").innerHTML=response.responseText;
								fnvshobj(obj,"tempdiv");
                        {rdelim}
                {rdelim}
        );
{rdelim}
</script>