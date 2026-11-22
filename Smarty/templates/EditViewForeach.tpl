{foreach key=header item=data from=$BLOCKS}
    {if $header eq 'ADDCOMMENT'|@getFixedLabel || $header eq 'COMMENT'|@getFixedLabel}
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td colspan=4 class="dvInnerHeader">
            <b>{'COMMENT'|@getFixedLabel}</b>
            </td>
        </tr>
        <tr>
            <td colspan=4 class="dvtCellInfo">{$COMMENT_BLOCK}</td>
        </tr>
        <tr><td>&nbsp;</td></tr>
    {/if}
    <tr>
		{if $header=='ADDRESSINFO'|@getFixedLabel && ($MODULE == 'Accounts' || $MODULE == 'Quotes' || $MODULE == 'PurchaseOrder' || $MODULE == 'SalesOrder'|| $MODULE == 'Invoice')}
            <td colspan=4 class="detailedViewHeader">
                <b>{$header}</b></td>
        {elseif $header== 'ADDRESSINFO'|@getFixedLabel && $MODULE == 'Contacts'}
            <td colspan=4 class="detailedViewHeader">
                <b>{$header}</b>
            </td>
        {else}
            <td colspan=4 class="detailedViewHeader">
                <b>{$header}</b>
		{/if}
            </td>
    </tr>
   	{if $MODULE eq 'Attachment'}
        {include file="AttachmentDisplayFields.tpl"}
    {else}
		{include file="DisplayFields.tpl"}
	{/if}
{/foreach}