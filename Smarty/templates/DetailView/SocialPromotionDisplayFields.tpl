
{assign var="fromlink" value=""}

{assign var="curr_row_num" value="0"}
{assign var="table_all_rowcount" value=$data|@count}

{math equation="($curr_row_num+y)" y=1 assign=curr_row_num }

    {assign var='count' value=0}
	{foreach key=mainlabel item=maindata from=$data}
        <tr {if $count >8}style="display: none" {/if}>
        {assign var="row_td_count" value=$subdata|@count}
        {include file='DetailView/EditViewUI.tpl'}
        </tr>
        {assign var='count' value=$count+1}
	{/foreach}




