{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
  	<tr>
		<td class="ld-form-item-content padL0" colspan="2">
			<select id="delete_availPickList" class="ld-multipleelect-inner" multiple="multiple" name="availList" style="width: 100%;height: 120px;" onchange="ComboxPopup.popupobj.replaceval_picklist(this);">
				{foreach item=pick_val key=pick_key from=$PICKVAL}
					{if $pick_key eq $SELECTVAL}
						{assign var=replace_picklist_val value=$pick_val}
						<option value="{$pick_key}" selected="">{$pick_val}</option>
					{else}
						<option value="{$pick_key}">{$pick_val}</option>
					{/if}
				{/foreach}
			</select>
		</td>
  	</tr>
  	<tr>
		<td class="ld-form-item-label">
			{'REPLACEWITHPICKLIST'|@getFixedLabel}
		</td>
		<td class="ld-form-item-content">
			<select id="replace_picklistval" class="ld-select-inner" name="replaceList">
				<option value=""></option>
				{foreach item=pick_val key=pick_key from=$PICKVAL}
					{if $replace_picklist_val eq $pick_val}
						<option value="{$pick_val}" style="display:none;">{$pick_val}</option>
					{else}
						<option value="{$pick_val}">{$pick_val}</option>
					{/if}
				{/foreach}
			</select>
		</td>
  	</tr>
</table>