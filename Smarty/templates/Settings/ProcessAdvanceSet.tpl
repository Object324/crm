<div style="padding: 16px;">
    <div class="first-drawer-content-item">
                <label class="drawer-content-item-title2"><font color="red">*</font>{'STEPNAME'|@getFixedLabel}</label>
                <input class="ld-input-inner" name="nodename" id="nodename" type="text" value="{$nodename}">
    </div>
    <div class="first-drawer-content-item">
            <label class="drawer-content-item-title2">{'Priority'|@getFixedLabel}</label>
            <select class="ld-select-inner" name="priority">
                {$priorityhtml}
            </select>
    </div>
    <div>{'NOTALLOWEDTOCONTINUEADVANCING'|@getFixedLabel}</div>
</div>
{include file='AdvanceFilterNew.tpl' SOURCE='customview' COLUMNS_BLOCK=$FIELDNAMES}
