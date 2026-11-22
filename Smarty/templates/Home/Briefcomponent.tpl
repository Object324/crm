{foreach item = row key =key from=$BFCOMPONENT}       
    <div class="cooperativeWorktranstab" style="overflow: hidden;text-overflow:ellipsis" tag="div_{$row.component_strtolower}">
        <div tag="span_transtab_{$row.component_strtolower}" class="padB5">{$row.componentlabel}</div>
        <span tag="create_span_{$row.component_strtolower}" name="{$row.component_name}" class="folder colorLink hoverUnderLine padR3 tip-workbirefreport-list" data-tip="0" data-direction="top" data-type="position">0</span>
        {$row.componentunit}
    </div>
{/foreach}    