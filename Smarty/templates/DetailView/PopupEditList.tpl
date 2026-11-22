<div name="ExpenseTab">
	{$TREXPENSE}
</div>
{*新建 编辑页   新增授权或者授权过期但有明细数据*}
{if $PiaozoneAuth eq 'yes'}
    {include file="PiaozoneList.tpl"}
{/if}