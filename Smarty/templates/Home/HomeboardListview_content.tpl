{if $MODULE=='MobileReport'}
<table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center" name="mobileWorkPlaceTable" style="table-layout:fixed;">
    <tbody>
    <tr style="position: sticky; top:0px;z-index:1;">
        <th>#</th>
        <th align="left" title="{$LIST_HEADER.1}" style="width: 10vw;">{$LIST_HEADER.1}</th>
        <th align="left" title="{$LIST_HEADER.2}">{$LIST_HEADER.2}</th>
        <th align="left" title="{$LIST_HEADER.3}">{$LIST_HEADER.3}</th>
        <th align="left" title="{$LIST_HEADER.4}">{$LIST_HEADER.4}</th>
        {if $languageType  eq 'en'}
            <th width="230">{'OPERATING'|@getFixedLabel}</th>
        {else}
            <th width="160">{'OPERATING'|@getFixedLabel}</th>
        {/if}
    </tr>
{else}
<table border=0 cellspacing=0 cellpadding=0 width=100% class="" name="mobileWorkPlaceTable">
    <thead>
    <tr>
        <th>#</th>
        <th align="left" title="{$LIST_HEADER.1}" style="width: 10vw;">{$LIST_HEADER.1}</th>
        <th align="left" title="{$LIST_HEADER.2}">{$LIST_HEADER.2}</th>
        <th align="left" title="{$LIST_HEADER.3}">{$LIST_HEADER.3}</th>
        <th align="left" title="{$LIST_HEADER.4}">{$LIST_HEADER.4}</th>
        {if $languageType  eq 'en'}
            <th width="230">{'OPERATING'|@getFixedLabel}</th>
        {else}
            <th width="160">{'OPERATING'|@getFixedLabel}</th>
        {/if}
    </tr>
    </thead>
    <tbody>
{/if}
    {if $HomeboardList|@count gte 1}
        {assign var="i" value=0}
        {foreach key=boardid item=homeboard_info from=$HomeboardList}
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$i}" data-boardid="{$boardid}" name="setting_board_{$boardid}" class="lvtColData ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
                <tr id="setting_{$i}" data-boardid="{$boardid}" name="setting_board_{$boardid}" class="lvtColDataBj ld-category-draggable" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
            <td>{$i}</td>
            <td>
                <span title="{$homeboard_info.boardname}">{$homeboard_info.boardname}</span>
            </td>
            <td style="overflow-wrap: break-word;" title="{$homeboard_info.description}" class="description">{$homeboard_info.description}</td>
            <td>{$homeboard_info.modifiedby}</td>
            <td>{$homeboard_info.modifiedtime}</span></td>
            <td style="width: 175px;">
                {if $MODULE eq 'VisualAnalysis' and $MODULE|@isPermitted:"EditView" neq 'yes'}{else}
                    <a class="Anu3_a" href="javascript:void(0)" onclick="editHomeboard({$boardid},'{$MODULE}')">{'EDIT'|@getFixedLabel}</a>
                {/if}
                {if $homeboard_info.boardid>0}
                    {if $MODULE eq 'VisualAnalysis' and $MODULE|@isPermitted:"Allocate" neq 'yes'}{else}
                        <a class="Anu3_a" href="javascript:void(0)" onclick="homeboardlist_scope({$boardid},this,'{$homeboard_info.boardtype}')">{'ALLOCATE'|@getFixedLabel}</a>
                    {/if}
                {/if}
                {if $MODULE eq 'VisualAnalysis' and $MODULE|@isPermitted:"Delete" neq 'yes'}{else}
                    <a class="Anu3_a redFont" href="javascript:void(0)" onclick="deleteHomeboard({$boardid},'{$MODULE}')">{'DELETE'|@getFixedLabel}</a>
                {/if}
                {if $homeboard_info.boardid>0}
                        <a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}" data-direction="left" data-type="position" style="display:none;cursor:move;margin-top:0px"></a>
                {/if}
            </td>
            <input type="hidden" id="homeboard_scope_{$boardid}" value="{$homeboard_info.scope}">
            <input type="hidden" id="homeboard_scopeid_{$boardid}" value="{$homeboard_info.scopeid}">
            </tr>
        {/foreach}
    {else}
        <tr class="lvtColData">
            <td colspan="6" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
        </tr>
    {/if}
    </tbody>
</table>