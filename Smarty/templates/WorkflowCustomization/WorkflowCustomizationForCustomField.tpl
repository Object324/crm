<form action="index.php" method="post" name="workflow_actions" class="ajax_form">
    <table class="ControlTable1 listEntries fir-center listSettingData" border="0" cellpadding="0" cellspacing="1" width="100%">
        <tr>
            <th width="30%" align="center">
               {'LISTFIELDS'|@getFixedLabel}
            </th>
            <th width="50%" align="center">
               {'FIELDNAME'|@getFixedLabel}
            </th>
			<th width="20%" align="center">
               {'fieldtype'|@getFixedLabel}
            </th>
        </tr>
		{if $CUSTOMFIELD_NUM gte 1}
			{foreach item=customfield_arr key=mode from=$CUSTOMFIELD}
				{if $mode eq 'head'}
					<tr class="lvtColData"><td colspan="3"><b>【{'Headerfield'|@getFixedLabel}】</b></td></tr>
				{else}
					<tr class="lvtColData"><td colspan="3"><b>【{'Entryfield'|@getFixedLabel}】</b></td></tr>
				{/if}
				{foreach item=arr from=$customfield_arr}
					<tr class="lvtColData">
						<td width="20%" align="left">
						   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{$arr.display_name}
						</td>
						<td width="20%" align="left">
							{$arr.number}
						</td>
						<td width="20%" align="left">
							{$arr.field_type}
						</td>
					</tr>
				{/foreach}
			{/foreach}
		{else}
			<tr class="lvtColData"><td colspan="3" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td></tr>
		{/if}
    </table>
    
</form>