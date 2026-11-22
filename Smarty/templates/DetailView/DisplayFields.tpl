
{assign var="fromlink" value=""}

{assign var="curr_row_num" value="0"}
{assign var="table_all_rowcount" value=$data|@count}
{foreach key=label item=subdata from=$data}
{math equation="($curr_row_num+y)" y=1 assign=curr_row_num }  
    <tr class="ld-form-item">
	{assign var="td1_uitype" value=$subdata[0][0][0][0]}
	{assign var="td2_uitype" value=$subdata[1][0][0][0]}
	{foreach key=mainlabel item=maindata from=$subdata}
        {assign var="row_td_count" value=$subdata|@count}
        {include file='DetailView/EditViewUI.tpl'}
	{/foreach}
   </tr>
{/foreach}
