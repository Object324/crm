<table class="" cellspacing="0" cellpadding="0" border="0" width="100%">
    <thead>
        <tr>
        <th>#</th>
        <th style="width: 200px" title="{'RULENAME'|@getFixedLabel}">{'RULENAME'|@getFixedLabel}</th>
        <th style="width: 310px" title="{'APPLICABLESCOPE'|@getFixedLabel}">{'APPLICABLESCOPE'|@getFixedLabel}</th>
        <th style="text-align: center" title="{'FixedReviewers'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
        <th style="width: 150px" title="{'ACTIVITYOPERATION'|@getFixedLabel}">{'ACTIVITYOPERATION'|@getFixedLabel}</th>
    </tr>
    </thead>
    <tbody>
        {foreach key=key item=item from=$workTemplateRuleArr}
        {if $key mod 2 eq '0'}
            <tr sort="yes" id="WorkTemplateRule_{$item.id}" class="lvtColData workTemplateRule" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" ruleid="{$item.id}">
                {else}
            <tr sort="yes" id="WorkTemplateRule_{$item.id}" class="lvtColDataBj workTemplateRule" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" ruleid="{$item.id}">
        {/if}
            <td tag="sequence">{$key+1}</td>
            <td tag="name"><span class="overflow-space" style="width: 200px;display: block">{$item.name}</span></td>
            <td tag="range"><span class="overflow-space" style="width: 310px;display: block">{$item.range}</span></td>
            <td tag="status" align="center">
                <input class="second_switch" type="checkbox" {if $item.status eq 'yes'}checked{/if} onclick="WorkTemplateRule.getInstance().changeStatus(this,{$item.id})">
            </td>
            <td tag="option">
            <a class="Anu3_a" href="javascript:void(0);" onclick="WorkTemplateRule.getInstance().create({$item.id})" tag="edit">{'EDIT'|@getFixedLabel}</a>
            {if $length gt 1}
                <a class="Anu3_a redFont" href="javascript:void(0);" onclick="WorkTemplateRule.getInstance().delete({$item.id})" tag="delete">{'DELETE'|@getFixedLabel}</a>
            {/if}
            <a class="Anu3_a ld-dragicon drag-handle" data-tip="{'DRAGTOSORT'|@getFixedLabel}" data-direction="right" data-type="position" style="cursor: move; margin-right: 18px; display: none;" tag="dragsort"></a>
        </td>
        </tr>
    {/foreach}
    </tbody>
</table>