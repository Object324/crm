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
<!--
 * 更新操作
 * 操作人：cui
 * 时间：2014-1-24 
 * 说明：下拉框编辑界面：点击添加项目弹出层页面样式改变
-->
<div class="D_pop_tit">
	<strong class="D_ptita">{'ADDPICKLISTVALUE'|@getFixedLabel} - {$FIELDLABEL}</strong>
    <a href="javascript:fninvshnew('actiondiv');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
    </a>
</div>		
<table  class="D_pop_bod D_pop_bod_line" border="0" cellpadding="1" cellspacing="0">
	<tr>
		<td  width=400 colspan="2" style="padding-left:12px;">
			<p>{'ONEBYONEBELOW'|@getFixedLabel}</p>
			<textarea id="add_picklist_values" class="addTextarea" align="left" rows="10" style="border: 1px solid #ddd;padding: 5px;width:250px;"></textarea>
		</td>
	</tr>
	<tr>
        <td  width=200 style="display:none;padding-left:12px;">
            <b style="color:#333;">{'NONPICKLISTVALUE'|@getFixedLabel} :</b>
			{if is_array($NONEDITPICKLIST)}			
				<div id="nonedit_pl_values" name="availList" class="addSelectDiv0" style="border: 1px solid #AAAAAA;padding: 5px;">
					{foreach item=nonedit from=$NONEDITPICKLIST}
						<div class="picklist_noneditable_options" style="background-color: #ffffff;">
							{$nonedit}		
						</div>							
					{/foreach}
				</div>
			{else}
                <div id="nonedit_pl_values" name="availList" class="addSelectDiv0" style="border: 1px solid #AAAAAA;padding: 5px;">
					{foreach item=nonedit from=$NONEDITPICKLIST}
						<div class="picklist_noneditable_options" style="background-color: #ffffff;">
							{$nonedit}		
						</div>							
					{/foreach}
				</div>
            {/if}
        </td>
		<td  width=200 style="display:none;">
			<b style="color:#333;">{'SELECTPICKLISTROLESENTRIES'|@getFixedLabel} </b>
			<select id="add_availRoles" multiple="multiple" wrap size="5" name="add_availRoles" class="addSelectRoleDiv" style="border: 1px solid #AAAAAA;padding: 5px;">
				{foreach key=role_id item=role_details from=$ROLEDETAILS}
					<option value="{$role_id}">{$role_details}</option>
				{/foreach}
			</select>
		</td>
	</tr>
</table>

<div class="D_pbtn">
	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" id="saveAddButton" onclick="validateAdd('{$FIELDNAME}','{$MODULE}');fnhide('actiondiv');puyoungJS_DialogBox.unblock();"/><span>&nbsp;</span>
    <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fnhide('actiondiv');puyoungJS_DialogBox.unblock();"/>
</div>