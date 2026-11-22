{assign var="fromlink" value=""}
{assign var="curr_row_num" value="0"}
{assign var="table_all_rowcount" value=$data|@count}
<table class="ld-approve-mandatoryfield" border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<th class="ld-approve-boldth">{'APPROVAL'|@getFixedLabel}{'MANDATORYFIELDS'|@getFixedLabel}</th>
		<th class="ld-approve-boldth"></th>
	</tr>
	{foreach key=label item=maindata from=$data}
		{assign var="curr_row_num" value="0" }
		<tr>
			{assign var="row_td_count" value=0}
			{include file='DetailView/EditViewUI.tpl'}
		</tr>
	{/foreach}
</table>
