<table class="settingTable fir-center" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr style="position: sticky; top:0px;z-index:1000;">
        {foreach key=index item=listheader from=$listheader_arr}
            <th title="{$listheader.label}" style="{$listheader.width}">{$listheader.label}</th>
        {/foreach}  
	</tr>
	{if {$listdata_arr|@count} gte 1}
		{assign var="i" value=0}
		{foreach key=index item=arr from=$listdata_arr}
			{assign var="j" value=$i++}
			{if $j mod 2 eq '0'}
				<tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
			{else}
				<tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
			{/if} 
                {foreach key=tmpkey item=value from=$arr.showitems}
                    <td id="{$tmpkey}_{$index}">{$value}</td>
                {/foreach}
                <td><input type="checkbox" class="second_switch" name="changeactive" {if $arr.is_active eq 'yes'}checked{/if} onclick="" data-btnid="{$arr.btnid}" /></td>
				<td>
					<a class="Anu3_a" href="javascript:void(0);" data-btnid="{$arr.btnid}" data-tabid="{$arr.tabid}" name="editbtn">{'EDIT'|@getFixedLabel}</a>
					<a class="Anu3_a redFont" href="javascript:void(0);" data-btnid="{$arr.btnid}" name="deletebtn">{'DELETE'|@getFixedLabel}</a>
				</td>
			</tr>
		{/foreach}
	{else}
		<tr class="lvtColData">
			<td colspan="8" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
		</tr>
	{/if}
</table>