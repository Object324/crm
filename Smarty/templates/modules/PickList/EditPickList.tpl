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
 * 说明：下拉框编辑重命名项目弹出层页面样式改变
-->
<div class="D_pop_tit">
	<strong class="D_ptita">{'EDITPICKLISTVALUE'|@getFixedLabel} - {$FIELDLABEL}</strong>
    <a href="javascript:fninvshnew('actiondiv');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
    </a>
</div>		
<table class="D_pop_bod D_pop_bod_line" border="0" cellpadding="1" cellspacing="0">
    <tr>
		<td   style="padding-left:12px;">
			<p>{'SELECTVALUEEDITPICK'|@getFixedLabel}</p>
		</td>
    <tr>
        <td style="padding-left:12px;">
            <select id="edit_availPickList" class="edit_availPickList" name="availList" onchange="selectForEdit();" multiple="">
    			{foreach item=pick_val key=pick_key from=$PICKVAL}
    				<option value="{$pick_key}">{$pick_val}</option>
    			{/foreach}
    		</select>
        </td>
    </tr>
    {if is_array($NONEDITPICKLIST)}
    <tr>
        <td style="padding-left:12px;">
            
                {foreach item=nonedit from=$NONEDITPICKLIST}
        			<span class="nonEditablePicklistValues">
        				{$nonedit}
        			</span>
        		{/foreach}
        </td>
	</tr>
    {/if}
    <tr>
        <td style="padding-left:12px;">{'EDITSELECTION'|@getFixedLabel}:</li>
            <input type="text" id="replaceVal" class="detailedViewTextBox_PickList" onkeyup="editpick_keyup(this,event);" fldname="{$FIELDNAME}" module="{$MODULE}"/>
        </td>
    </tr>
</table>       
<div class="D_pbtn">
	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="validateEdit('{$FIELDNAME}','{$MODULE}');"/><span>&nbsp;</span>
    <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fnhide('actiondiv');puyoungJS_DialogBox.unblock();"/>
</div>