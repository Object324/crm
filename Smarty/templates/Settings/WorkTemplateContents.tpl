<table width="100%" border="0" cellspacing="0" cellpadding="0" class="settingTable fir-center" tag='worktplTab' name="workReportTable">
	<tbody>
  <tr tag="header">
  	<th>#</th>
    {assign var="i" value=0}
	  {foreach key=key item=item from=$HEADER}
		{if $key eq 'tools'}
			{if $opertion_num eq 4}
				<th align="left" title="{$item}" {if $LANGUAGETYPE eq 'zh'}width="170"{else}width="235"{/if}>{$item}</th>
			{else}
				<th align="left" title="{$item}" {if $LANGUAGETYPE eq 'zh'}width="120"{else}width="140"{/if}>{$item}</th>
			{/if}
		{else}
			<th align="left" {if $i eq '0'}width="35%"{/if}title="{$item}" key="{$i++}">{$item}</th>
		{/if}
 	{/foreach}
  </tr>
  {$ENTITYLIST}
</tbody>
</table>