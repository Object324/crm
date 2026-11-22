<script type="text/javascript" src="include/js/modules/CustomTables/CustomTables.js"></script>
<script type="text/javascript" src="include/js/modules/CustomTables/CustomTablesSqlColumns.js"></script>
<script type="text/javascript" src="include/js/modules/CustomTables/styleSet.js"></script>
<div class="customtable-content">
<div class="main_grid lfloat" style="width: 100%;">
    <div class="ld-ui-tabs" style="height:50px;position: sticky;top: 0px;background-color: #fff;">
        <ul class="ld-ui-tabs-nav" style="background-color: #fff;width:calc(100% - 17px);">
            <li class="{if $mode!="edit"}ld-ui-tabs-active{/if} change_tab" for="basicSet" id="basicSetLi"><a href="javascript:;">{'base'|@getFixedLabel}{'INFO'|@getFixedLabel}</a></li>
            <li  class="change_tab {if $mode=="edit"}ld-ui-tabs-active{/if}" id="tableSetLi" for="tableSet"><a href="javascript:;">{'Table'|@getFixedLabel}{'CONFIGTHE'|@getFixedLabel}</a></li>
        </ul>
    </div>
    <form id="chartInfoForm">
        <div class="tab-contents" id="basicSet" style="width:100%;{if $mode=="edit"}display:none;{/if}">
            {include file="CustomTables/basicSet.tpl"}
        </div>
        <div class="tab-contents" id="tableSet" style="width:100%;{if $mode!="edit"}display:none;{/if}">
            {include file="CustomTables/sqltableset.tpl"}
        </div>
    </form>
</div>
</div>
{*样式设置*}
{include file="CustomTables/styleSet.tpl"}
