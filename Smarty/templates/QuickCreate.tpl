

{include file='QuickCreateHidden.tpl'}
<!-- quick create UI starts -->
<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
{assign var="fromlink" value="qcreate"}
{assign value='QcEditView' var='formname'}
{assign value='yes' var='POPUPBUTTON'}
{assign var="curr_row_num" value="0"}
{assign var="table_all_rowcount" value=$QUICKCREATE|@count}
{foreach item=subdata from=$QUICKCREATE}
    {math equation="($curr_row_num+y)" y=1 assign=curr_row_num } 
	<tr>
		{foreach key=mainlabel item=maindata from=$subdata}
            {assign var="row_td_count" value=$subdata|@count}
			{include file='DetailView/EditViewUI.tpl'}										
		{/foreach}
	</tr>
{/foreach}    	
</table>

