<form class="ld-massedit-form" name="EditView" id="massedit_form" action="index.php">
    <input id="idstring" value="{$IDS}" type="hidden" />
    <div class="ld-ui-tabs">
        <ul class="ld-ui-tabs-nav">
            {foreach key=header name=block item=data from=$BLOCKS}
                {if $smarty.foreach.block.index eq 0}
                    <li class="ld-ui-tabs-active" id="tab{$smarty.foreach.block.index}" onclick="massedit_togglediv({$smarty.foreach.block.index},{$BLOCKS|@count});"><a href="javascript:;">{$header}</a></li>
                {else}
                    <li id="tab{$smarty.foreach.block.index}" onclick="massedit_togglediv({$smarty.foreach.block.index},{$BLOCKS|@count});"><a href="javascript:;">{$header}</a></li>
                {/if}
            {/foreach}
        </ul>
    </div>
    {foreach key=header name=block item=data from=$BLOCKS}
        {if $smarty.foreach.block.index eq 0}
            <div id="massedit_div{$smarty.foreach.block.index}" class="ld-createedit-masscontent" style='display:block;'>
                <div class="ld-from-headblock-mass" style="white-space: nowrap;overflow: hidden;text-overflow: ellipsis;">
                    <div class="ld-from-headblock-title">{$header}<span>{'CHECKFIELDS'|@getFixedLabel}</span></div>
                </div>
                <table border=0 cellspacing=1 cellpadding=0 width=100% class='ld-createedit-tablecontent' style="table-layout: fixed;">
                    <tr><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td></tr>
                    {include file="DisplayFields.tpl"}
                </table>
            </div>
        {else}
            <div id="massedit_div{$smarty.foreach.block.index}" class="ld-createedit-masscontent" style='display:none;'>
                <div class="ld-from-headblock-mass" style="white-space: nowrap;overflow: hidden;text-overflow: ellipsis;">
                    <div class="ld-from-headblock-title">{$header}<span>{'CHECKFIELDS'|@getFixedLabel}</span></div>
                </div>
                <table border=0 cellspacing=1 cellpadding=0 width=100% class='ld-createedit-tablecontent' style="table-layout: fixed;">
                    <tr><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td></tr>
                    {include file="DisplayFields.tpl"}
                </table>
            </div>
        {/if}
    {/foreach}
</form>

