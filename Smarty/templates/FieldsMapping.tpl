{*<style type="text/css">@import url("themes/{$THEME}/style.css");</style>*}
<style type="text/css">@import url("themes/{$THEME}/selfstyle.css");</style>
<input type="hidden" name="record" id="record" value="{$RECORDID}" />
{if $SELECTMAPPFIELDS eq 'yes'}
	<div class="pad20 select-input">
		<input class="templateprintRadio input-btn-align" type="radio" name="status" {if $STATUS eq 'Following'}checked{/if} value ="Following" tag="{'FOLLOWING'|@getFixedLabel}">
		<label class="padR10">{'FOLLOWING'|@getFixedLabel}</label>
		<input class="templateprintRadio input-btn-align" type="radio" name="status" {if $STATUS eq 'Failedtoclose'}checked{/if} value ="Failedtoclose" tag="{'FAILLEDTOCOLSE'|@getFixedLabel}">
		<label class="padR10">{'FAILLEDTOCOLSE'|@getFixedLabel}</label>
		<input class="templateprintRadio input-btn-align" type="radio" name="status" {if $STATUS eq 'Upgrade'}checked{/if} value ="Upgrade" tag="{'UPGRADE'|@getFixedLabel}">
		<label class="padR10">{'UPGRADE'|@getFixedLabel}</label>
		{if $ISADMIN eq 'on'}
			<a class="icon-setup rfloat icon-setup_icon" href="javascript:;"></a><br />
		{/if}
		<div id="fileurereason_div" {if $STATUS eq 'Failedtoclose'}style="margin-top: 5px;display:;"{else}style="margin-top: 5px;display:none;"{/if}>
			{if $LANGUAGETYPE eq 'zh'}
				{'FAILLEDTOCOLSE'|@getFixedLabel}{'Reason'|@getFixedLabel}
			{else}
				{'Reason'|@getFixedLabel}
			{/if}
			<textarea id="fileurereason" class="ld-textarea-inner" style="margin-top: 5px; height: 50px; overflow: hidden; overflow-wrap: break-word; resize: horizontal;">{$FAILEUREREASON}</textarea>
		</div>
	</div>
{else}
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tbody>
			<tr>
				<th title="{'RELFECTLBL_FIELDNAME'|@getFixedLabel}" style="text-align:center;">{'RELFECTLBL_FIELDNAME'|@getFixedLabel}</th>
				<th title="{'FIELDSMAPPING'|@getFixedLabel}{'MODULE'|@getFixedLabel}" style="text-align:center;">{'FIELDSMAPPING'|@getFixedLabel}{'MODULE'|@getFixedLabel}</th>
				<th title="{'AFTERRELFECTLBL_FIELDNAME'|@getFixedLabel}" style="text-align:center;">{'AFTERRELFECTLBL_FIELDNAME'|@getFixedLabel}</th>
			</tr>
			{foreach key=columnname item=fieldinfo from=$FIELDSMAP name=list}
			{assign var=i value=$smarty.foreach.list.iteration}
			{if $i%2 neq 0}
				<tr id="setting_{$i}" class="lvtColData" onmouseover="listOnMouseOver(ld(this));" onmouseout="listOnMouseOut(ld(this),'on');">
			{else}
				<tr id="setting_{$i}" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),'On');">
			{/if}
					{if $columnname eq 'smcreatorid' || $columnname eq 'smownerid'}
	                    <td align="left">
	                        <select name="{$columnname}_mappedfield" id="{$columnname}_mappedfield" tag="{$columnname}" class="ld-select-inner gwidth90">
		                        {foreach key=user_columnname item=user_field from=$USERFIELDS}
		                        	<option value="{$user_columnname}" {if $user_columnname eq $fieldinfo.mapped_columnname || (empty($fieldinfo.mapped_columnname) && $user_columnname eq $columnname)} selected="true"{/if}>
										{$user_field.fieldlabel}
									</option>
		                        {/foreach}
	                        </select>
	                    </td>
                    {else}
                    	<td align="left">{$fieldinfo.fieldlabel}{if $fieldinfo.typeofdata eq 'M'}<font color="red">*</font>{/if}</td>
					{/if}
                    <td align="left">
						<select name="mapmodule[{$i}]" id="mapmodule[{$i}]" tag="{$columnname}" class="ld-select-inner gwidth90" {if $fieldinfo.is_disabled eq 1}disabled{/if}>
							{*wym XUQIU20240204-09 销售线索可编辑追踪字段*}
							<option value="{$MAPMODULE}" {if $fieldinfo.mapmodule eq $MAPMODULE} selected="true" {/if}>{$MAPMODULE|@getTransTab}</option>
							{if $fieldinfo.bigtype neq 'fileattachment' && $MAPMODULE eq 'Accounts'}
                            	<option value="Contacts" {if $fieldinfo.mapmodule eq 'Contacts'} selected="true" {/if}>{'Contacts'|@getTransTab}</option>
							{/if}
                            <option value="AccountsContacts" {if $fieldinfo.mapmodule eq 'AccountsContacts'} selected="true"{else} style="display:none;" {/if}>{'Accounts'|@getTransTab}/{'Contacts'|@getTransTab}</option>
						</select>
					</td>
					<td>
						<select name="{$columnname}_mapfield" id="{$columnname}_mapfield" class="ld-select-inner gwidth90" {if $fieldinfo.is_disabled eq 1}disabled{/if}>
							<option value="" tag="">---{'NONE'|@getFixedLabel}---</option>
							{if $fieldinfo.bigtype eq 'fileattachment'}
                                {foreach item="column_info" from=$FILEFIELD}
    								<option value="{$column_info.columnname}" tag="{$column_info.tag}" {if $column_info.columnname eq $fieldinfo.fieldmaping } selected="true" {/if}  {if $fieldinfo.uitype eq 1109 && $column_info.uitype neq 1109 } style="display:none;" {/if}>
    									{$column_info.fieldlabel}
    								</option>
    							{/foreach}
							{else}
                                {foreach item="column_info" from=$MAPPINGFIELDS}
    								<option value="{$column_info.columnname}" tag="{$column_info.tag}"
											{if $column_info.columnname eq $fieldinfo.fieldmaping && ($column_info.tag eq $fieldinfo.mapmodule || $fieldinfo.mapmodule  == 'AccountsContacts')} selected="true" {/if}>
    									{$column_info.fieldlabel}
    								</option>
    							{/foreach}
                            {/if}
						</select>
					</td>
				</tr>
			{/foreach}
		</tbody>
	</table>
{/if}