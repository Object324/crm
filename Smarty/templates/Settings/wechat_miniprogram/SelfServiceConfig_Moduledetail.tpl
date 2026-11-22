<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Settings.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/SelfServiceConfig.js"></script>
<form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<input type="hidden" id="selftype" value="{$SELFTYPE}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {$CUSTOMERSELFSERVICECONFIG03}
        </span>
        <span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
        <select fieldtype="select" name="WeixinMpModule" id="WeixinMpModule" class="btn-radius-system width150">
            {foreach item=item key=key from=$SELECTMODULES}
                <option value="{$item}" >{$item|@getTransTab}</option>
            {/foreach}
        </select>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a id="selfconfig_field_create" href="javascript:;" class="ld-button ld-button-primary" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div id="MpModuleFields" class="cont_wrap clear_float">
            {*editor:gyq_20190531 reason:添加多余div,防止删除后，JS报错 document.getElementById('MpModuleViewall').innerHTML = ajaxhtml[0];*}
            <div class="pad10" id="MpModuleViewall" hidden></div>
            <div id="MpModuleListFields" hidden></div>
            {$MPMODULEFIELDSHTML}
        </div>
    </div>
</div>

<div id="selfconfig_create"style="display:none;width:450px;">
<div id="selfconfig_create_div"></div>
</div>
<div id="selfconfig_module"style="display:none;width:450px;">
<div id="selfconfig_module_div"></div>
</div>
    <script>
        getJsScript('include/js/SelfServiceConfig.js',function (){
            SelfServiceConfig.movetable('moduledetail');
        });
    </script>