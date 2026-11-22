
<div name="detailtable" class="popDetailTable"  style="display: block;" >
    {$TREXPENSE}
</div>

{*详情页 无论是否授权或者授权过期,有数据就显示*}
{if $InvioceHtml neq ''}
    {include file="modules/TabDetail/PiaozoneDetail.tpl"}
{/if}
