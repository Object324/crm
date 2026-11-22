<div class="ld-public-content-small padB0" style="height: auto">
    <div class="ld-form-item-div">
        <div class="ld-form-item-label">
            <label><font color="red">*</font>{'RULENAME'|@getFixedLabel}</label>
        </div>
        <div class="ld-form-item-content">
            <input class="ld-input-inner" name="rulename" ruleid="{$ruleid}" value="{if $mode eq 'edit'}{$name}{/if}">
        </div>
    </div>
    <div class="ld-form-item-div">
        <div class="ld-form-item-label">
            <label>{'WHETHERTOENABLE'|@getFixedLabel}</label>
        </div>
        <div class="ld-form-item-content">
            <input class="second_switch" style="margin-bottom: 3px" type="checkbox" name="ruleStatus" {if $mode eq 'edit'}{$status}{else}checked{/if}>
        </div>
    </div>
    <div class="ld-form-item-div">
        <div class="ld-form-item-label">
            <label>{'Backgroundcolor'|@getFixedLabel}</label>
        </div>
        <div class="ld-form-item-content">
            <div name="backgroundcolor" class="calendar-color-setting" style="background: {if $mode eq 'edit'}{$backgroundcolor}{else}#ff0256{/if};"
                 color="{if $mode eq 'edit'}{$backgroundcolor}{else}#ff0256{/if}" onclick="CalendarColorSettings.getInstance().changeColor(this,'{$mode}','backgroundcolor');"></div>
        </div>
    </div>
    <div class="ld-form-item-div">
        <div class="ld-form-item-label">
            <label>{'FontColor'|@getFixedLabel}</label>
        </div>
        <div class="ld-form-item-content">
            <div name="textcolor" class="calendar-color-setting" style="background: {if $mode eq 'edit'}{$textcolor}{else}#ffffff{/if};"
                 color="{if $mode eq 'edit'}{$textcolor}{else}#ffffff{/if}" onclick="CalendarColorSettings.getInstance().changeColor(this,'{$mode}','textcolor');"></div>
        </div>
    </div>
</div>
<div style="width: 100%;">
    {include file='newAdvanceFilter.tpl'}
</div>