<div name="div_check_repeat">
	<div id="accounts_table_all" style=" overflow:auto; width:640px; height:210px;margin:0 auto;">
		<table class="listdata" style="table-layout: auto;margin-top: 2px;" width="100%" cellspacing="1" cellpadding="0" border="0">
			<tr>                   
				<th><span title="#">#</span></th>
				<th><span title="仓库">仓库</span></th>
				<th><span title="产品编号">产品编号</span></th>
				<th><span title="产品名称">产品名称</span></th>
				<th><span title="库存量">库存量</span></th>
			</tr>
			{if $RET_DATA eq ''}
				<tr height="170px" valign="center">  				
					<td align="center" style="background: #fff;" colspan="5">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
				</tr> 
			{else} 
				{assign var="i" value=0}
				{foreach item=inven_info key=col from=$RET_DATA}    
					{assign var="j" value=$i++}
					{if $j mod 2 eq '0'}
					<tr id="poprow_{$j}" class="lvtColData" onmouseout="setPopTrColorOut('poprow_{$j}','on');" onmouseover="setPopTrColor('poprow_{$j}');">
					{else}
					<tr id="poprow_{$j}" class="lvtColDataBj" onmouseout="setPopTrColorOut('poprow_{$j}','On');" onmouseover="setPopTrColor('poprow_{$j}');">
					{/if}                           
						<td align="left"><span title="">{$i}</span></td>    
						<td align="left"><span title="">{$inven_info.warehouse_name}</span></td>    
						<td  align="left"><span title="">{$inven_info.inventory_code}</span></td>
						<td  align="left"><span title="">{$inven_info.inventory_name}</span></td>
						<td  align="left"><span title="">{$inven_info.quantity}</span></td>						
					</tr>
				{/foreach}
			{/if}
		</table>                         
	</div>
</div>