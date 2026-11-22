{*<!--
/*+********************************************************************************
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  *********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
{if $_FIELD_UI_TYPE eq 56}
	<input id="{$_FIELD_ELEMENT_ID}" name="{$_FIELD_ELEMENT_ID}" type="checkbox" class="second_switch" {if $_FIELD_SELECTED_VALUE eq 1}checked{/if} onclick="cmb_defaultvalue_checked(this,'onecheckbox','{$_FIELD_ID}','{$_FIELD_COLUMNNAME}');">
{elseif $_FIELD_UI_TYPE eq 23 || $_FIELD_UI_TYPE eq 5 || $_FIELD_UI_TYPE eq 6}
	{*<!--13年12月24日,andrew修改,将日期插件改下拉框-->*}
	<select class="small" id="{$_FIELD_ELEMENT_ID}" name="{$_FIELD_ELEMENT_ID}" style='max-width:160px;' onchange="cmb_defaultvalue_checked(this,'date','{$_FIELD_ID}','{$_FIELD_COLUMNNAME}');">
		{*0040518: 设置>系统设置>选择 界面设置 中的页面设置>列表右边页面设置>新增字段>字段类型为日期>选择默认值时存在问题*}
		<option value="" {if $value.defaultvalue.value eq ''}selected{/if}></option><!--今天-->
	    <option value="1" {if $value.defaultvalue.value eq 'thistoday'}selected{/if}>{'now'|@getFixedLabel}</option><!--今天-->
		{foreach key=key item=AfterDayitem from=$AfterDayInfo}
			<option value="{$AfterDayitem.value}" {if $value.defaultvalue.value eq $AfterDayitem.value}selected{/if}>{$AfterDayitem.label}</option>
		{/foreach}
	    <option value="oneyear" {if $value.defaultvalue.value eq 'oneyear'}selected{/if}>{'OneYearLater'|@getFixedLabel}</option><!--一年后：明年今天的前一天-->
		{foreach key=key item=DaysAgoitem from=$DaysAgoInfo}
			<option value="{$DaysAgoitem.value}" {if $value.defaultvalue.value eq $DaysAgoitem.value}selected{/if}>{$DaysAgoitem.label}</option>
		{/foreach}
		<option value="beforeoneyear" {if $value.defaultvalue.value eq 'beforeoneyear'}selected{/if}>{'OneYearAgo'|@getFixedLabel}</option><!--一年前：明年今天的前一天-->
	</select>
	{*<!--<input class="small" id="{$_FIELD_ELEMENT_ID}" name="{$_FIELD_ELEMENT_ID}" type="text" size="11" maxlength="10" value="{if $_FIELD_SELECTED_VALUE neq 0}{$_FIELD_SELECTED_VALUE}{/if}">
	<img align="absmiddle" src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_{$_FIELD_ELEMENT_ID}" />
	<script type="text/javascript" id='layouteditor_{$_FIELD_ELEMENT_ID}' class='layouteditor_javascript'>
		Calendar.setup ({ldelim}
			inputField : "{$_FIELD_ELEMENT_ID}", ifFormat : "{$JS_DATEFORMAT}", showsTime : false, button : "jscal_trigger_{$_FIELD_ELEMENT_ID}", singleClick : true, step : 1
		{rdelim})
	</script>-->*}
{elseif $_FIELD_UI_TYPE eq 86}
	<select class="small" id="{$_FIELD_ELEMENT_ID}" name="{$_FIELD_ELEMENT_ID}" style='max-width:160px;'>
		<option value="" {if $value.defaultvalue.value eq ''}selected{/if}></option><!--今天-->
		<option value="1" {if $value.defaultvalue.value eq 'thistoday'}selected{/if}>{'now'|@getFixedLabel}</option><!--现在-->
		{foreach key=key item=AfterDayitem from=$AfterDayInfo}
			<option value="{$AfterDayitem.value}" {if $value.defaultvalue.value eq $AfterDayitem.value}selected{/if}>{$AfterDayitem.label}</option>
		{/foreach}
		<option value="oneyear" {if $value.defaultvalue.value eq 'oneyear'}selected{/if}>{'OneYearLater'|@getFixedLabel}</option><!--一年后：明年今天的前一天-->
		{foreach key=key item=DaysAgoitem from=$DaysAgoInfo}
			<option value="{$DaysAgoitem.value}" {if $value.defaultvalue.value eq $DaysAgoitem.value}selected{/if}>{$DaysAgoitem.label}</option>
		{/foreach}
		<option value="beforeoneyear" {if $value.defaultvalue.value eq 'beforeoneyear'}selected{/if}>{'OneYearAgo'|@getFixedLabel}</option><!--一年前：明年今天的前一天-->
	</select>
 	{* //zkt 0045569: （https://61mis.com/kfbcrm [^] ）页面设置-》成员管理中，类似“角色权限”“状态”“部门”这类字段设施默认后不生效*}
{elseif $_FIELD_UI_TYPE eq 98}
    <select class="detailedViewSelect bgwhite" name="{$_FIELD_COLUMNNAME}" id="{$_FIELD_ELEMENT_ID}" style='max-width:160px;'>
        {foreach key=key item=item from=$defaultsetting._allvalues}
            <option value="{$item.id}"{if $defaultsetting.value eq $item.id} selected="true" {/if}>{$item.name}</option>
        {/foreach}
    </select>
{elseif $_FIELD_UI_TYPE eq 115 && $_FIELD_COLUMNNAME eq 'status'}
    <select class="detailedViewSelect bgwhite" name="{$_FIELD_COLUMNNAME}" id="{$_FIELD_ELEMENT_ID}" style='max-width:160px;'>
        {foreach key=key item=item from=$defaultsetting._allvalues}
            <option value="{$item.hiddenvalue}"{if $defaultsetting.value eq $item.hiddenvalue} selected="true" {/if}>{$item.value}</option>
        {/foreach}
    </select>
{elseif $_FIELD_UI_TYPE eq 19 || $_FIELD_UI_TYPE eq 21}
 	<textarea id="{$_FIELD_ELEMENT_ID}" name="{$_FIELD_ELEMENT_ID}" class="ld-textarea-inner gwidth90" style="margin: 5px 0px; height: 50px; resize: vertical !important;" oninput="cmb_defaultvalue_checked(this,'textarea','{$_FIELD_ID}','{$_FIELD_COLUMNNAME}');">{$_FIELD_SELECTED_VALUE}</textarea>
{elseif $_FIELD_UI_TYPE eq 15 ||$_FIELD_UI_TYPE eq 34 || $_FIELD_UI_TYPE eq 16  ||$_FIELD_UI_TYPE eq 251 ||$_FIELD_UI_TYPE eq 252}
	{*// @edit:dong @date:2020/07/21 @reason:0035699 单据明细界面>页面设置>编辑任意下拉框字段>打开设置默认值下拉选项：添加一个搜索功能*}
	{if $MODULE!='ExpenseBudget' && $value.fieldname!='budget_indicators' }
		{*ZXM 预算单 指标类型的先不加设置*}
		{include file="Settings/FieldEditPickList.tpl"}
	{/if}
{elseif $_FIELD_UI_TYPE eq 33}
	<select {if $_FIELD_UI_TYPE eq 33} MULTIPLE {/if} style="width:70%" onchange="setCheckBox(this,{$value.fieldselect});cmb_defaultvalue_checked(this,'morecheckbox','{$_FIELD_ID}','{$_FIELD_COLUMNNAME}');" id="{$_FIELD_ELEMENT_ID}" name="{$_FIELD_ELEMENT_ID}" style='max-width:160px;'>
		{foreach item=_PICKLIST_VALUE from=$_ALL_AVAILABLE_VALUES}
			<option value="{$_PICKLIST_VALUE}"
					{if $_FIELD_UI_TYPE eq 33}
						{if _FIELD_SELECTED_VALUE|@is_array && $_PICKLIST_VALUE|@in_array:$_FIELD_SELECTED_VALUE}
							selected
						{/if}
					{else}
						{if $_PICKLIST_VALUE eq $_FIELD_SELECTED_VALUE}
							selected
						{/if}
					{/if}
			>{$_PICKLIST_VALUE}
			</option>
			{foreachelse}
			<option value=""></option>
			<option value="" style='color: #777777' disabled>{'NONE'|@getFixedLabel}</option>
		{/foreach}
	</select>
  	<b onclick="getCombox('{$MODULE}','{$value.fieldname}')" title="{'SETTINGS'|@getFixedLabel}" class="icon-picklist-set" style="cursor:pointer;"></b>
{elseif $_FIELD_UI_TYPE eq 130&&($MODULE =='OutboundOrder'||$MODULE=='Stock')}
    <select class="detailedViewSelect bgwhite" name="{$_FIELD_COLUMNNAME}" id="{$_FIELD_ELEMENT_ID}" style='max-width:160px;'>
        {if $MODULE=='OutboundOrder'}
            <option value="未出库">未出库</option>
            <option value="已出库" {if $_FIELD_SELECTED_VALUE eq '已出库'}selected=""{/if}>已出库</option>
        {else if $MODULE=='Stock'}
            <option value="未入库">未入库</option>
            <option value="已入库" {if $_FIELD_SELECTED_VALUE eq '已入库'}selected=""{/if}>已入库</option>
        {/if}
    </select>
{elseif $_FIELD_UI_TYPE eq 53 && ($_FIELD_COLUMNNAME == 'smownerid' || $_FIELD_COLUMNNAME == 'servicecasher')}
    <select class="detailedViewSelect bgwhite" name="{$_FIELD_COLUMNNAME}" id="{$_FIELD_ELEMENT_ID}" style='max-width:160px;'>
        {foreach item=info  from=$_ALL_AVAILABLE_VALUES }
            <option value="{$info.value}"  {if $info.presence eq 1}style="display:none;"{/if}
            {if $_FIELD_SELECTED_VALUE eq $info.value}selected=""{/if} >{$info.label}</option>
        {/foreach}
    </select>
{else}
    {if $defaultsetting.permitted eq false ||$value.uitype eq 202}
    	<input id="{$_FIELD_ELEMENT_ID}" disabled="true" name="{$_FIELD_ELEMENT_ID}" type="text" value="{$_FIELD_SELECTED_VALUE}" />
    {else}
		{*@edit:liushuai,2021-05-19,reason:【ID1001646】页面设置，字段属性设置“默认”值后（文本框内容不为空时默认选中状态）*}
        <input id="{$_FIELD_ELEMENT_ID}" name="{$_FIELD_ELEMENT_ID}" class="ld-input-inner gwidth90" style="cursor: text;" type="text" value="{$_FIELD_SELECTED_VALUE}" oninput="cmb_defaultvalue_checked(this,'text','{$_FIELD_ID}','{$_FIELD_COLUMNNAME}');"/>
    {/if}
{/if}