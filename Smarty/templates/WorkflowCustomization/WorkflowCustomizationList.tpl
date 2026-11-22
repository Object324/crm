{*<!--修改编码格式:统一编码：UTF-8-->*}
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/WorkflowCustomization.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="jdyisv" id="jdyisv" value="{$JDYISV}" />
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_WORKFLOWCUSTOMIZATION_SET'|@getFixedLabel}
            {if $HelpHtml.WorkflowCustomizationList neq '' }{$HelpHtml.WorkflowCustomizationList}{/if}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
        <select fieldtype="select" id="frommodule_tabid" name="frommodule_tabid" class="btn-radius-system width150" onchange="WorkflowCustomization.selmodule(this);">
            {foreach item=tab from=$TAB}
                {if $tab.tabid eq $BLOCKID}
                    <option value="{$tab.tabid}" selected>{$tab.tabname}</option>
                {else}
                    <option value="{$tab.tabid}">{$tab.tabname}</option>
                {/if}                
            {/foreach}
        </select>
    </div>
    <div class="grid_tool">
		{*{if $JDYISV eq 'yes'}
			<div class="create-entity-toolbar lfloat prelative">
				<a href="javascript:;" class="pg-btn-grey dinline-block lfloat" onclick="WorkflowCustomization.createApiConfig()" title="{'THEINTERFACEPARAMENTERS'|@getFixedLabel}{'SETTINGS'|@getFixedLabel}">{'THEINTERFACEPARAMENTERS'|@getFixedLabel}{'SETTINGS'|@getFixedLabel}</a>
			</div>
		{/if}*}
		<div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="WorkflowCustomization.create(0)" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="cfList" class="cont_wrap clear_float" name="workflow_content">
            {include file='WorkflowCustomization/WorkflowCustomizationEntries.tpl'}
        </div>
    </div>
</div>
</form>
<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>