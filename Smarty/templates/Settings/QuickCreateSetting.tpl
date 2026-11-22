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
<div class="F_l" style="">
  {'QuickCreateSetting'|@getFixedLabel}
	<select name="tab_quickcreate" class="btn-radius-system" style="font-family:Arial, Helvetica, sans-serif;font-size:12px; width:auto;margin-left: 5px;" id='tab_quickcreate'>
		<option value="no" {if $ISDUPLICATE=='no'}selected{/if}>{'DefaultDisplayQuickField'|@getFixedLabel}</option>
		<option value="yes" {if $ISDUPLICATE=='yes'}selected{/if}>{'DefaultDisplayAllfield'|@getFixedLabel}</option>			                
	</select>
</div>
<table class="" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="200">
	    <b>{'Available_fields'|@getFixedLabel}</b>
		<input class="detailedViewTextBox"  style="width: 200px;margin-top: 5px;" type="text" onkeyup="clickSelectMember(this,'AssmablyList')" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}"   name="allmember" />
      <input type="hidden" value="" id="AssmablyColumnsString" name="AssmablyColumnsString">
      {*zkt 20220602 52454销售线索》页面设置，快速创建字段中，必填字段“客户名称”，点击向左按钮不能删除（正常逻辑），但是双击就能删除*}
	    <select class="commonMultipleSelect width200 height250 marT10" name="AssmablyList" id="AssmablyList" multiple="" ondblclick="copySelectedQuickFields('AssmablyList','selectedAssmablyColumns')"><!--ondblclick="addColumn();-->
        {foreach item=fieldinfo  from=$ALLFIELDS name=relinfo}                                                          
          <option value="{$fieldinfo.col}">{$fieldinfo.label}</option>
        {/foreach}
      </select> 
    </td>
		<td width="50" class="ctextalign" style="padding: 5px;">
      <a class="icon-newhomearr icon-mright" style="margin-top: 15px;" href="javascript:;" onclick="copySelectedQuickFields('AssmablyList','selectedAssmablyColumns');" title="{'MOVERIGHT'|@getFIxedLabel}"></a>
      <a class="icon-newhomearr icon-mleft" style="margin-top: 25px;" href="javascript:;" onclick="copySelectedQuickFields('selectedAssmablyColumns','AssmablyList');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
		</td>
    <td width="200">
			<b>{'Selected_Fields'|@getFixedLabel}</b>
      <input type="hidden" value="" id="selectedAssmablyColumnsString" name="selectedAssmablyColumnsString">
			<select size="11" style="overflow:auto; height: 250px;width:200px;font-family:Arial, Helvetica, sans-serif;font-size:12px;-webkit-appearance: none; margin-top: 43px;" class="commonMultipleSelect width200 height250" name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="" ondblclick="copySelectedQuickFields('selectedAssmablyColumns','AssmablyList')">
        {foreach item=fieldinfo  from=$QUICKCREATEFIELDS }                                                          
          <option value="{$fieldinfo.col}">{$fieldinfo.label}</option>
        {/foreach}
      </select>
		</td>
		<td width="50" class="ctextalign" style="padding-left: 5px;">
			<a class="icon-newhomearr icon-mup" style="margin-top:15px;margin-left: -3px;" href="javascript:;" onclick="ModuleDetailmoveUp('selectedAssmablyColumns');" title="{'MOVEUP'|@getFIxedLabel}"></a>
			<a class="icon-newhomearr icon-mdown" style="margin-top:25px;margin-left: -3px;" href="javascript:;" onclick="ProductDetailmoveDown('selectedAssmablyColumns');" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
		</td>
  </tr>
</table>