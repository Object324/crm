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
	{if $MAPTYPE eq 'list'}
		{'mapviewlistinfo'|@getFixedLabel}
	{else}
		{'mapviewdetailinfo'|@getFixedLabel}
	{/if}
</div>
<table class="" border="0" cellpadding="0" cellspacing="0">
	<input type="hidden" name="map_type" id="map_type" value="{$MAPTYPE}" />
	<input type="hidden" name="frommodule" id="frommodule" value="{$MODULE}" />
  <tr>
    <td width="200">
	    <b>{'Available_fields'|@getFixedLabel}</b>
		<input class="detailedViewTextBox"  style="width: 200px;margin-top: 5px;" type="text" onkeyup="clickSelectMember(this,'AssmablyList')" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}"  onblur="return cls_input_select.getInstance('field')._onblur(this)" onfocus="return cls_input_select.getInstance('field')._onfocus(this)" name="allmember" />
        <input type="hidden" value="" id="AssmablyColumnsString" name="AssmablyColumnsString">
	    <select class="commonMultipleSelect marT10" style="height: 250px;width:200px;" name="AssmablyList" id="AssmablyList" multiple="" ondblclick="copySelectedOptionsSettingModule('AssmablyList','selectedAssmablyColumns')"><!--ondblclick="addColumn();-->
        {foreach item=fieldinfo  from=$ALLFIELDS name=relinfo}                                                          
          <option value="{$fieldinfo.col}">{$fieldinfo.label}</option>
        {/foreach}
      </select> 
    </td>
		<td width="50" class="ctextalign" style="padding: 5px;">
      <a class="icon-newhomearr icon-mright" style="margin-top: 15px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('AssmablyList','selectedAssmablyColumns');" title="{'MOVERIGHT'|@getFIxedLabel}"></a>
      <a class="icon-newhomearr icon-mleft" style="margin-top: 25px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('selectedAssmablyColumns','AssmablyList');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
		</td>
    <td width="200">
			<b>{'Selected_Fields'|@getFixedLabel}</b>
      <input type="hidden" value="" id="selectedAssmablyColumnsString" name="selectedAssmablyColumnsString">
			<select size="11" style="height: 250px;width:200px;margin-top: 43px;" class="commonMultipleSelect marT10" name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="" ondblclick="copySelectedOptionsSettingModule('selectedAssmablyColumns','AssmablyList')">                                                               
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