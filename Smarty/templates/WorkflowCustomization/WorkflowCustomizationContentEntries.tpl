{assign var="i" value=0}
{foreach key=workflow_actionid item=arr from=$WORKFLOW_ACTIONS}
    {assign var="j" value=$i++}
    {if $j mod 2 eq '0'}
        <tr  id="setting_{$j}" workflow_actionid="{$workflow_actionid}" class="lvtColData dragtrrow" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
        <tr id="setting_{$j}" workflow_actionid="{$workflow_actionid}" class="lvtColDataBj dragtrrow" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
    {/if}
    <td>{$i}</td>
    <td>{if $arr.action_type eq 'API'}{'CallAPI'|@getFixedLabel}{elseif $arr.action_type eq 'Link2ERP'}{'CallLink2ERP'|@getFixedLabel}{elseif $arr.action_type eq 'UpdateFields'}{'updatefields'|@getFixedLabel}{elseif $arr.action_type eq 'ExcuteSql'}{'ExcuteSQL'|@getFixedLabel}{elseif $arr.action_type eq 'AutoShare'}{'AUTOSHARE'|@getFixedLabel}{/if}</td>
    <td>{$arr.action_title}</td>
    <td><input type="checkbox" class="second_switch" {if $arr.status eq 'Active'}checked{/if} onclick="WorkflowCustomization.operateActions(this,event)" tag="status" workflow_actionid={$workflow_actionid} /></td>
    <td>
        <a class="Anu3_a" onclick="WorkflowCustomization.operateActions(this,event)" action_type="{$arr.action_type}" workflow_actionid="{$workflow_actionid}" tag="edit">{'EDIT'|@getFixedLabel}</a>
        <a class="Anu3_a redFont" onclick="WorkflowCustomization.operateActions(this,event)" workflow_actionid="{$workflow_actionid}" tag="delete">{'DELETE'|@getFixedLabel}</a>
        <a  class="drag-handle ld-category-icon ld-category-drag" title="{'MOVE'|@getFixedLabel}" style="cursor:move;"></a>
    </td>
{/foreach}