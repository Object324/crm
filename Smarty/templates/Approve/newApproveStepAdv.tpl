<div style="padding: 16px;">
    <div class="first-drawer-content-item">
                <label class="drawer-content-item-title2"><font color="red">*</font>{'STEPNAME'|@getFixedLabel}</label>
                <input class="txt ld-input-inner" name="stepname" type="text" value="{$stepname}">
    </div>
    <div class="first-drawer-content-item">
            <label class="drawer-content-item-title2">{'Priority'|@getFixedLabel}</label>
            <select class="ld-select-inner" name="priority">
                {$priorityhtml}
            </select>
    </div>
    <div>{'BRANCHHIGHESTPRIORITY'|@getFixedLabel}</div>
</div>
<div style="background-color: #fff;padding-right: 0px;width: 100%" class="advanceFilterNoDashedDiv" name="pop_adv_filter_div" id="pop_adv_filter_div">
