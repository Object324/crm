{* creator:gyq_13 reason:日程模板列表框架 date:20160613 *}
{*<!--修改编码格式:统一编码：UTF-8-->*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Calendar/TemplateCalendar/TemplateCalendar.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/inputAddSubNumberBox.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/advancefilter.js?v={$GLOBALMINVERSION}"></script>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_CALENDAR_TEMPLATE'|@getFixedLabel}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
        <select fieldtype="select" name="pick_module" id="pick_module" onchange="TemplateCalendar.getInstance().switchModule(this,'{$blockidsetting}','{$FIELDIDSETTING}');" class="btn-radius-system width150">
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
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="TemplateCalendar.getInstance().addNewCalendar(0,0)" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="cfList" class="cont_wrap clear_float">
            <!--{include file="MobileMenuListEntries.tpl"} 系统设置  日程模板定制-->
			{include file="TemplateCalendar/CalendarTemplateEntries.tpl"}
        </div>
    </div>
</div>
<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>