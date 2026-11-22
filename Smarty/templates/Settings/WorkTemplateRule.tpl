<div id="workTemplateRule" reporttype="{$reporttype}">
    <table class="ld-public-content-small padB0" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
        <tbody>
            <tr>
            <td class="ld-form-item-label" >
                {'ACTIVATE'|@getFixedLabel}{'RULESETTINGS'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <input name="sensitivepresence" {if $status eq 'yes'}checked="" {/if} type="checkbox" class="second_switch" onclick="WorkTemplateRule.getInstance().changeSettingStatus(this)">
                <a href="javascript:;" onclick="WorkTemplateRule.getInstance().create('')" class="ld-button ld-button-primary rfloat" title="{'ADDLESSIONPLAN'|@getFixedLabel}{'LBL_PROFILES'|@getFixedLabel}">{'ADDLESSIONPLAN'|@getFixedLabel}{'RULE'|@getFixedLabel}</a>
            </td>
        </tr>
        </tbody>
    </table>
    <div class="ld-pop-container ld-table-container ld-table-container-lines">
        <div id="workTemplateRuleDiv" name="workTemplateRuleDiv" class="divPopOverflow">
            {include file='Settings/WorkTemplateRuleListView.tpl'}
        </div>
    </div>
</div>







