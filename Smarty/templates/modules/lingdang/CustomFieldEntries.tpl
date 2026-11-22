
				<!--修改编码格式:统一编码：UTF-8-->
                <form action="index.php" method="post" name="form" onsubmit="puyoungJS_DialogBox.block();">
				<input type="hidden" name="fld_module" value="{$MODULE}">
				<input type="hidden" name="module" value="Settings">
				<input type="hidden" name="parenttab" value="Settings">
				<input type="hidden" name="mode">
				<table  class="listTableTopButtons" border="0" cellpadding="5" cellspacing="0" width="100%">
					<tr>
						<td class="big" align="left" nowrap="nowrap"><strong>{$MOD.LBL_MAPPED_FIELDS}</strong> </td>
                        <td align="right" width="80%"><input type="hidden" name="activitytype" value="E" checked></td>
					<!--{if $MODULE eq 'Calendar'}
						<td align="right" width="80%"><input type="radio" name="activitytype" value="E" checked>&nbsp;{$APP.Event}
						<input type="radio" name="activitytype" value="T">&nbsp;{$APP.Task} 
						</td>
					{/if}-->
                    
						<td align="right"><input type="button" value=" {$MOD.NewCustomField} " onClick="fnvshobj(this,'createcf');getCreateCustomFieldForm('{$MODULE}','','','')" class="create"/></td>
				</tr>
				</table>	
			
				<table class="listTable" border="0" cellpadding="5" cellspacing="0" width="100%">
					{if $MODULE eq 'Leads'}
					<tr>
						<td rowspan="2" class="colHeader small" width="5%">#</td>
					        <td rowspan="2" class="colHeader small" width="20%">{$MOD.FieldLabel}</td>
					        <td rowspan="2" class="colHeader small" width="20%">{$MOD.FieldType}</td>
							<td colspan="3" class="colHeader small" valign="top"><div align="center">{$MOD.LBL_MAPPING_OTHER_MODULES}</div></td>
							<td rowspan="2" class="colHeader small" width="20%">{$MOD.LBL_CURRENCY_TOOL}</td>
					</tr>

					<tr>
					  <td class="colHeader small" valign="top" width="18%">{$APP.Accounts}</td>
					  <td class="colHeader small" valign="top" width="18%">{$APP.Contacts}</td>
					  <td class="colHeader small" valign="top" width="19%">{$APP.Potentials}</td>
					 </tr>
					{else}
					<tr>
                      	<td class="colHeader small" width="5%">#</td>
                      	<td class="colHeader small" width="20%">{$MOD.FieldLabel}</td>
                      	<td class="colHeader small" width="20%">{$MOD.FieldType}</td>
                    	<!--{if $MODULE eq 'Calendar'}
                      		<td class="colHeader small" width="20%">{$APP.LBL_ACTIVITY_TYPE}</td>
                      	{/if}by kevin-->
                     	<td class="colHeader small" width="20%">{$MOD.LBL_CURRENCY_TOOL}</td>
					</tr>
					{/if}
					{foreach item=entries key=id from=$CFENTRIES}
					<tr>
						{foreach item=value from=$entries}
							<td class="listTableRow small" valign="top" nowrap>{$value}&nbsp;</td>
						{/foreach}
					</tr>
					{/foreach}
		</table>
		</form>
		<br>
		{if $MODULE eq 'Leads'}
			<strong>{$APP.LBL_NOTE}: </strong> {$MOD.LBL_CUSTOM_MAPP_INFO}
		{/if}