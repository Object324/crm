<script>
    var timeValueArr = {$timeValueArr};
</script>
<script type="text/javascript" src="include/js/modules/CustomTables/CustomTables.js"></script>
<script type="text/javascript" src="include/js/modules/CustomTables/CustomTablesColumns.js"></script>
<script type="text/javascript" src="include/js/modules/CustomTables/CustomTablesSqlColumns.js"></script>
<script type="text/javascript" src="include/js/modules/CustomTables/CustomTablesConditions.js"></script>
<script type="text/javascript" src="include/js/modules/CustomTables/styleSet.js"></script>
<div class="customtable-content">
<div class="main_grid lfloat" style="width: 100%;">
    <input type="hidden" id="aaaaa" value="bbbbbb">
    <div class="ld-ui-tabs" style="height:50px;position: sticky;top: 0px;background-color: #fff;">
        <ul class="ld-ui-tabs-nav" style="background-color: #fff;width:calc(100% - 17px);">
            {if $mode!="edit"}
            <li class="ld-ui-tabs-active change_tab" for="selectTemplate" id="selectTemplateLi"><a href="javascript:;">{'SelectTemplate'|@getFixedLabel}</a></li>
            {/if}
            <li class="change_tab" for="moduleSet" id="moduleSetLi"><a href="javascript:;">{'base'|@getFixedLabel}{'INFO'|@getFixedLabel}</a></li>
            <li  class="change_tab {if $mode=="edit"}ld-ui-tabs-active{/if}" id="tableSetLi" for="tableSet"><a href="javascript:;">{'Table'|@getFixedLabel}{'CONFIGTHE'|@getFixedLabel}</a></li>
            <li  class="change_tab" for="advancedSetting"><a href="javascript:;">{'AdvanceSet'|@getFixedLabel}</a></li>
        </ul>
    </div>
    <form id="chartInfoForm">
        {if $mode!='edit'}
        <div class="tab-contents" id="selectTemplate" style="width:100%;">
            {include file="CustomTables/selectTemplate.tpl"}
        </div>
        {/if}
        {*编辑页面不显示模块选择*}
        <div class="tab-contents" id="moduleSet" style="width:100%;display:none;">
            {include file="CustomTables/moduleSet.tpl"}
        </div>
        <div class="tab-contents" id="tableSet" style="width:100%;{if $mode!="edit"}display:none;{/if}">
            {include file="CustomTables/tableSet.tpl"}
        </div>
        <div class="tab-contents" id="advancedSetting" style="width:100%;display:none;">
            {include file="CustomTables/advancedSetting.tpl"}
        </div>
    </form>
</div>
</div>
{*样式设置*}
{include file="CustomTables/styleSet.tpl"}
