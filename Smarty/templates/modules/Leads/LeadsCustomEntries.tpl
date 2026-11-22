{*
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/ *}
		<!--修改编码格式:统一编码：UTF-8-->		
                <form action="index.php" method="post" name="form" onsubmit="puyoungJS_DialogBox.block();">
				<input type="hidden" name="fld_module" value="{$MODULE}">
				<input type="hidden" name="module" value="Settings">
				<input type="hidden" name="parenttab" value="Settings">
				<input type="hidden" name="mode">
				<table  class="listTableTopButtons" border="0" cellpadding="5" cellspacing="0" width="100%">
					<tr>
						<td class="big" align="left"><strong>{$MOD.LBL_MAPPED_FIELDS}</strong> </td>
						<td align="right"><input type="button" class="create" onclick="javascript: submitForm('form','index.php?module=Settings&action=LeadCustomFieldMapping');" alt="Edit" title="Edit" value="Edit"/>
						</td>
					{if $MODULE eq 'Calendar'}
						<input type="radio" name="activitytype" value="E" checked>&nbsp;{$APP.Event}
						<input type="radio" name="activitytype" value="T">&nbsp;{$APP.Task}
					{/if}
					</tr>
				</table>
				</form>
				<table class="listTable" border="0" cellpadding="5" cellspacing="0" width="100%">
					{if $MODULE eq 'Leads'}
					<tr>
						<td rowspan="2" class="colHeader" width="5%">#</td>
						<td rowspan="2" class="colHeader" width="20%">{$MOD.FieldLabel}</td>
					    <td rowspan="2" class="colHeader" width="20%">{$MOD.FieldType}</td>
						<td colspan="4" class="colHeader" valign="top"><div align="center">{$MOD.LBL_MAPPING_OTHER_MODULES}</div></td>
					</tr>

					<tr>
					  <td class="colHeader" valign="top" width="18%">{$APP.Accounts}</td>
					  <td class="colHeader" valign="top" width="18%">{$APP.Contacts}</td>
					  <td class="colHeader" valign="top" width="19%">{$APP.Potentials}</td>
					  <td class="colHeader" width="20%">{$MOD.LBL_CURRENCY_TOOL}</td>

					</tr>
					{else}
					<tr>
                      	<td class="colHeader small" width="5%">#</td>
                      	<td class="colHeader small" width="20%">{$MOD.FieldLabel}</td>
                      	<td class="colHeader small" width="20%">{$MOD.FieldType}</td>
                    	{if $MODULE eq 'Calendar'}
                      		<td class="colHeader small" width="20%">{$APP.LBL_ACTIVITY_TYPE}</td>
                      	{/if}
						</tr>
					{/if}
					{foreach item=entries key=id from=$CFENTRIES}
					<tr>
						{foreach item=value from=$entries.map}
							<td class="listTableRow small" valign="top" nowrap>{$value}&nbsp;</td>
						{/foreach}
							<td class="listTableRow small" valign="top" nowrap>
									{if $entries.editable eq 1}
									<form name="form{$entries.cfmid}" method="post">
										<a class="icon-homeimg icon-sdel" href="javascript:;" title="{'LBL_DELETE_BUTTON_LABEL'|@getTranslatedString:$MODULE}" 
                                            onclick="javascript: deleteForm('form{$entries.cfmid}','index.php?action=DeleteConvertLeadMapping&module=Settings&parenttab=Settings&cfmid={$entries.cfmid}' );"></a>
									</form>
									{/if}
							</td>
					</tr>
					{/foreach}
		</table>
		</form>
		<br>
		{if $MODULE eq 'Leads'}
			<strong>{$APP.LBL_NOTE}: </strong> {$MOD.LBL_CUSTOM_MAPP_INFO}
		{/if}