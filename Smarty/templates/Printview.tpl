<div class="pad10">
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
	   <tr>
	       <td width="30%" align="right">
	         {'Please_select_a_template'|@getFixedLabel}
	       </td>
	       <td width="70%" align="left">
	           <select id="templateprintmoduletype" name="templateprintmoduletype" class="commonSelectPop">
				{foreach item=templateinfo key=sequenceid from=$TEMPLATEPRINTS}
					{assign var=printid value=$templateinfo.2}
					{if $templateinfo.1 eq 1}
						<option value='{$printid}' selected="true" type="{$templateinfo.3}">{$templateinfo.0}</option>
					{else}
					<option value='{$printid}' type="{$templateinfo.3}">{$templateinfo.0}</option>
					{/if}
				{foreachelse}
					<option value="0">{'Please_select_print_templates'|@getFixedLabel}</option>
				{/foreach}
				</select>
	       </td>
	   </tr>
	</table>
</div>