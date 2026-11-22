<div class="ld-public-content-small" name="topnavigationbarsettings" style="height: auto">
    {*  全局搜索  *}
    <div class="headersetting" name="quickfindsetting_div">
        <div class="headersetting-lable">
            <label name="quickfindsetting_label">{'QUICKFINDDISPLAYMODE'|@getFixedLabel}</label>
        </div>
        <div class="headersetting-select">
            <select class="ld-select-inner" name="quickfindsetting" style="width: 60%" {$display_quickfindsetting}>
                {foreach key=key item=value from=$quickfindsetting_arr}
                    <option value="{$key}" {if $value.selected eq 'selected'}selected{/if}>{$value.label}</option>
                {/foreach}
            </select>
            <select class="ld-select-inner" name="quickfindsetting_scope" style="width: 38%;margin-left: 2%"  {$display}>
                {foreach key=key item=value from=$quickfindsetting_scope_arr}
                    <option value="{$key}" {if $value.selected eq 'selected'}selected{/if}>{$value.label}</option>
                {/foreach}
            </select>
        </div>
    </div>
    {*  快速创建  *}
    <div class="headersetting" name="quickcreatesetting_div">
        <div class="headersetting-lable">
            <label name="quickcreatesetting_label">{'QUICKCREATEDISPLAYMODE'|@getFixedLabel}</label>
        </div>
        <div class="headersetting-select">
            <select class="ld-select-inner" name="quickcreatesetting" style="width: 60%" {$display_quickcreatesetting}>
                {foreach key=key item=value from=$quickcreatesetting_arr}
                    <option value="{$key}" {if $value.selected eq 'selected'}selected{/if}>{$value.label}</option>
                {/foreach}
            </select>
            <select class="ld-select-inner" name="quickcreatesetting_scope" style="width: 38%;margin-left: 2%" {$display}>
                {foreach key=key item=value from=$quickcreatesetting_scope_arr}
                    <option value="{$key}" {if $value.selected eq 'selected'}selected{/if}>{$value.label}</option>
                {/foreach}
            </select>
        </div>
    </div>
    {*  审批与消息  *}
    <div class="headersetting" name="approvalremindsetting_div">
        <div class="headersetting-lable">
            <label name="approvalremindsetting_label">{'APPROVALREMINDSDISPLAYMODE'|@getFixedLabel}</label>
        </div>
        <div class="headersetting-select">
            <select class="ld-select-inner" name="approvalremindsetting" style="width: 60%" {$display_approvalremindsetting}>
                {foreach key=key item=value from=$approvalremindsetting_arr}
                    <option value="{$key}" {if $value.selected eq 'selected'}selected{/if}>{$value.label}</option>
                {/foreach}
            </select>
            <select class="ld-select-inner" name="approvalremindsetting_scope" style="width: 38%;margin-left: 2%" {$display}>
                {foreach key=key item=value from=$approvalremindsetting_scope_arr}
                    <option value="{$key}" {if $value.selected eq 'selected'}selected{/if}>{$value.label}</option>
                {/foreach}
            </select>
        </div>
    </div>
    {*  帮助中心  *}
    <div class="headersetting" name="helpsetting_div">
        <div class="headersetting-lable">
            <label name="helpsetting_label">{'PRODUCTHELPMANUALSHOWTYPE'|@getFixedLabel}</label>
        </div>
        <div class="headersetting-select">
            <select class="ld-select-inner" name="helpmanualsetting" style="width: 60%" {$display_helpsetting}>
                {foreach key=key item=value from=$helpsetting_arr}
                    <option value="{$key}" {if $value.selected eq 'selected'}selected{/if}>{$value.label}</option>
                {/foreach}
            </select>
            <select class="ld-select-inner" name="helpsetting_scope" style="width: 38%;margin-left: 2%" {$display}>
                {foreach key=key item=value from=$helpsetting_scope_arr}
                    <option value="{$key}" {if $value.selected eq 'selected'}selected{/if}>{$value.label}</option>
                {/foreach}
            </select>
        </div>
    </div>
    {*  个人信息  *}
    <div class="headersetting" name="userinfosetting_div">
        <div class="headersetting-lable">
            <label name="userinfosetting_label">{'PERSONALINFORMATIONDISPLAYMODE'|@getFixedLabel}</label>
        </div>
        <div class="headersetting-select">
            <select class="ld-select-inner" name="userinfosetting" style="width: 60%" {$display_userinfosetting}>
                {foreach key=key item=value from=$userinfosetting_arr}
                    <option value="{$key}" {if $value.selected eq 'selected'}selected{/if}>{$value.label}</option>
                {/foreach}
            </select>
            <select class="ld-select-inner" name="userinfosetting_scope" style="width: 38%;margin-left: 2%" {$display}>
                {foreach key=key item=value from=$userinfosetting_scope_arr}
                    <option value="{$key}" {if $value.selected eq 'selected'}selected{/if}>{$value.label}</option>
                {/foreach}
            </select>
        </div>
    </div>
</div>