{*
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
* ("License"); You may not use this file except in compliance with the License
* The Original Code is:  lingdang CRM Open Source
* The Initial Developer of the Original Code is lingdang.
* Portions created by lingdang are Copyright (C) lingdang.
* All Rights Reserved.
<!--修改编码格式:统一编码：UTF-8-->
*
********************************************************************************/ *}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/SensitiveRules.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="form" onsubmit="puyoungJS_DialogBox.block()">
<input type="hidden" name="fld_module" value="{$MODULE}">
<input type="hidden" name="module" value="Settings">
<input type="hidden" name="parenttab" value="Settings">
<input type="hidden" name="mode">
<div id="dv_pagelayt_drag">
	<div class="ControlDiv2" style="border-bottom:none;display:none;">
		<div class="F_l" style="display:none">
			<b>{'quickcreatesettings'|@getFixedLabel}</b>
			<select name="tab_isduplicate" class="btn-radius-system" style="font-family:Arial, Helvetica, sans-serif;font-size:12px; width:auto"  id='tab_isduplicate' onchange="updateTabDuplicate('{$MODULE}')">
					<option value="no" {if $ISDUPLICATE=='no'}selected{/if}>{'defaultquickcreate'|@getFixedLabel}</option>
					<option value="yes" {if $ISDUPLICATE=='yes'}selected{/if}>{'defaultdisplaymoreitem'|@getFixedLabel}</option>			                
			</select>
		</div>
	    <div class="F_r">
		    <input type="button" class="createauto" onclick="fun_createblock('{$MODULE}');" alt="{'NEWBLOCK'|@getFixedLabel}" title="{'NEWBLOCK'|@getFixedLabel}" value="{'NEWBLOCK'|@getFixedLabel}"/>
	    </div>
  	</div>
  	<div class="blocks"><ul style="margin-bottom: 0px;"><li></li><li></li></ul></div>
{*	wyt 221212 XUQIU1000876 单据详情界面显示优化第三版（增加关键信息区块设置，需要可拖动调整）*}
{*	页面设置->关键字段信息区块*}
    {if $display_keywork_block eq 'yes'}
	<div >
		<div class="blocks" id="block_keyword">
			<div  class="DivCName title settingpage">
				<span id="block_name_keyword" >{'KEYINFORMATION'|@getFixedLabel}</span>
				<input type="checkbox" onclick="view_display_fields('{$MODULE}')" {if $VIEWKEYWORDS eq 0}checked{/if} class="second_switch"/>
				<div class="DivCNameRight" style="margin-right: 11px;">
					<!-- 设置显示字段 -->
							<a href="javascript:void(0);" onclick="set_dispaly_fields(this,'{$MODULE}','','')">{'SETDISPLAYFIELDS'|@getFixedLabel}</a>

				</div>
			</div>

			<ul style="width:100%" class="blockfields" blockid="keyword" >
				{foreach item=entries_key key=id from=$CFENTRIESKEYWORDS name=outer}

{*							{if $entries_key.keywords eq 'yes'}*}
								<li blockid="keyword" columnname="{$entries_key.columnName}" class="keywordsfields">
									<span class="drag-handle icon-layout2 icon-layout2-move" title="{'drag'|@getFixedLabel}" style="cursor:move"></span>
									<span>{$entries_key.fieldLableKey}</span>
								</li>
{*							{/if}*}

				{/foreach}
			</ul>
		</div>

	</div>
    {/if}
	{foreach item=entries key=id from=$CFENTRIES name=outer}
		<div class="blocks" id="block_{$entries.blockid}" blockid="{$entries.blockid}" block_sequence="{$entries.sequence}">
			<div class="DivCName title settingpage">
				<span class="drag-handle icon-layout2 icon-layout2-move" title="{'drag'|@getFixedLabel}" style="cursor:move;"></span>
				<select name="display_status_{$entries.blockid}" class="btn-radius-system" style="font-family:Arial, Helvetica, sans-serif;font-size:12px; width:auto" onChange="changeShowstatus('{$entries.tabid}','{$entries.blockid}','{$MODULE}')" id='display_status_{$entries.blockid}'>
					<option value="show" {if $entries.display_status==1}selected{/if}>{if $entries.block_label eq 'LBL_LABEL'}{'EXPANSIONFORLABEL'|@getFixedLabel}{else}{'EXPANSION'|@getFixedLabel}{/if}</option>
					<option value="hide" {if $entries.display_status==0}selected{/if}>{if $entries.block_label eq 'LBL_LABEL'}{'COLLAPSEFORLABEL'|@getFixedLabel}{else}{'COLLAPSE'|@getFixedLabel}{/if}</option>
					{if $entries.block_label eq 'LBL_LABEL'}<!--230413 BUG0062118 wyt 页面设置，标签区块名称前面去掉“开启”选项（展开和收起已经默认有开启功能了），另外“展开”标签修改为“开启-展开”，“收起”标签修改为“开启-收起”-->
						<option value="none" {if $entries.display_status==2}selected{/if}>{'HIDDEN'|@getFixedLabel}</option>
						{* <option value="open" {if $entries.display_status==3}selected{/if}>{'OPENMODULE'|@getFixedLabel}</option> *}
					{/if}
				</select>
				<span id="block_name_{$entries.blockid}" title="{$entries.blocklabel}" style="max-width: calc(100% - 700px);display: inline-block;overflow: hidden;position: relative;white-space: nowrap;text-overflow: ellipsis;vertical-align: middle;">{$entries.blocklabel}</span>
				<a class="icon-layout2 icon-layout2-edit" href="javascript:void(0);" title="{'MODIFIEDBLOCKNAME'|@getFixedLabel}" onclick="Modifiedblockname(this,'{$entries.tabid}','{$entries.blockid}')"></a>
				<div class="DivCNameRight">
					{if $entries.block_label neq 'LBL_LABEL'}
						<!--新增字段-->
						{if $entries.hascustomtable && $entries.blockid neq $COMMENTSECTIONID && $entries.blockid neq $SOLUTIONBLOCKID }
							<a href="javascript:void(0);" onclick="addField('{$entries.blockid}','')">{'ADDCUSTOMFIELDS'|@getFixedLabel}</a>
						{/if}
                        
                        {if $entries.block_label eq 'LBL_ACCOUNT_PRIMARYCONTACT'}
                            <a href="javascript:void(0);" onclick="ContactsfieldSet('{$entries.blockid}','{$MODULE}')">{'ACTIVITYADDREMOVEFIELD'|@getFixedLabel}</a>
                        {else}
							<!--显示隐藏-->
							{if $entries.blockid neq $COMMENTSECTIONID && $entries.blockid neq $SOLUTIONBLOCKID}
							<a href="javascript:void(0);" onclick="fnvshobj_HiddenFields(this,'hiddenfields_{$entries.blockid}');">{'HIDDENFIELDS'|@getFixedLabel}<b style="display:none">[11]</b></a>
							{/if}
						{/if}
						{*<!--移动字段-->
						{if $entries.blockid neq $COMMENTSECTIONID && $entries.blockid neq $SOLUTIONBLOCKID}
							<a href="javascript:void(0);" onclick="fnvshobj(this,'movefields_{$entries.blockid}');">{'MOBILEFIELD'|@getFixedLabel}</a>
						{/if}*}
					{/if}
					<!--区块上移下移-->
					{if $smarty.foreach.outer.last}
						<a href="javascript:void(0);" onclick="changeBlockorder('block_up','{$entries.tabid}','{$entries.blockid}','{$MODULE}') ">{'BLOCKSUPOFSETTING'|@getFixedLabel}</a>                
					{elseif $smarty.foreach.outer.first}
						<a href="javascript:void(0);" onclick="changeBlockorder('block_down','{$entries.tabid}','{$entries.blockid}','{$MODULE}') ">{'BLOCKSDOWNOFSETTING'|@getFixedLabel}</a>
					{else}
						<a href="javascript:void(0);" onclick="changeBlockorder('block_down','{$entries.tabid}','{$entries.blockid}','{$MODULE}') ">{'BLOCKSDOWNOFSETTING'|@getFixedLabel}</a>
						<a href="javascript:void(0);" onclick="changeBlockorder('block_up','{$entries.tabid}','{$entries.blockid}','{$MODULE}') ">{'BLOCKSUPOFSETTING'|@getFixedLabel}</a>
					{/if}
					{if $entries.iscustom == 1 }
						<a href="javascript:void(0);" onclick="deleteCustomBlock('{$MODULE}','{$entries.blockid}','{$entries.no}')">{'DELETEBLOCK'|@getFixedLabel}</a> 
					{/if}&nbsp;&nbsp;
				</div>
				<!-- 新增字段 开始-->
				<div id="addfield_{$entries.blockid}" style="display:none; position:absolute;" class="E_pop_box LdPopWidth500px">
					<div class="E_pop_tit">
						<strong class="E_ptita">{'Add_custom_fields'|@getFixedLabel}</strong>
						<button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="addFieldCancel('{$entries.blockid}');return false;"></button>
					</div>
                {assign var="blockid" value=$entries.blockid}
                {include file='Settings/addPicklistField.tpl'}
                </div>
				<!-- 新增字段 结束-->
				<!-- 显示隐藏 开始-->
				<div id="hiddenfields_{$entries.blockid}" style="display:none; position:absolute;" class="E_pop_box LdPopWidth400px" name="hiddenfields_{$entries.blockid}">
					<div class="E_pop_tit">
						<strong class="E_ptita">{'HIDDENFIELDS'|@getFixedLabel}</strong>
						<button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('hiddenfields_{$entries.blockid}');return false;"></button>
					</div>
					<table class="ld-pop-container-second padT2" name="HiddenFieldsTable" border="0" cellpadding="0" cellspacing="0" width="100%">
					  <tr>
						<td>
							{if $entries.hidden_count neq '0' || $entries.hidden_count neq null}
								<p class="marT10">{'CHOOSEHIDDENFIELD'|@getFixedLabel}</p>
                                <input type="hidden" name="selectedColumnsString2">{*hjz 增加页面设置的未启用字段查询*}
                                <input class="detailedViewTextBox marT10" blockid="{$entries.blockid}" style="width: 93%;" type="text" onkeyup="cls_input_select.getInstance('field')._onkeyup(this,'hiddenfield_assignid_{$entries.blockid}',event)"
                                tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" onblur="return cls_input_select.getInstance('field')._onblur(this)" onfocus="return cls_input_select.getInstance('field')._onfocus(this)" name="allmember" /><br>
							{/if}
							<ul class="LdPop_ul6 padTB10">
								<li>
									{if $entries.hidden_count neq '0'}
									<select id="hiddenfield_assignid_{$entries.blockid}"  multiple="" name="hiddenfield_assignid_{$entries.blockid}">
									{foreach name=inner item=value from=$entries.hiddenfield}	
										<option value="{$value.fieldselect}">{$value.fieldlabel}</option>
									{/foreach}
										</select>
									{else}
									{'Nohiddenfields'|@getFixedLabel}
									{/if}
								</li>
							</ul>
						</td>
					  </tr>
					</table>
					<div class="E_pbtn E_pbtn_special">
						{if $entries.hidden_count neq '0'}
							<input type="button" class="ld-button ld-button-primary" value="{'CANCELHIDDEN'|@getFixedLabel}" onclick="show_move_hiddenfields('{$MODULE}','{$entries.tabid}','{$entries.blockid}','showhiddenfields');"/>
						{/if}
					</div>
				</div>
			</div>
			<ul style="width:100%" class="blockfields" blockid="{$entries.blockid}">
				{foreach name=inner item=value from=$entries.field}
					{if $entries.block_label eq 'LBL_LABEL'}
						<li blockid="" columnname=""></li>
					{else}
						<li blockid="{$entries.blockid}" columnname="{$value.columnname}">
							<span class="drag-handle icon-layout2 icon-layout2-move" title="拖动" style="cursor:move"></span>
							<a class="icon-layout2 icon-layout2-edit" href="javascript:;" title="{'EDITPROPERTIES'|@getFixedLabel}" onclick="fun_editField({$value.fieldselect},{$value.uitype},'{$MODULE}');isuitypedisp({$value.fieldselect},{$value.uitype});"></a>
							{if $value.fieldtype eq 'M'}
								<font color='red'> *</font>
							{/if}
							<span>{$value.label}</span>
						</li>
					{/if}
				{/foreach}
				{if is_array($entries.field) && $entries.field|@count gte 1}
					<li blockid="{$entries.blockid}" id="ul_none_{$entries.blockid}" style="display:none;">&nbsp;</li>
				{else}
					<li blockid="{$entries.blockid}" id="ul_none_{$entries.blockid}" >&nbsp;</li>
				{/if}
			</ul>
		</div>
	{/foreach}
</div>

{literal}
<style>
/*.selectSpan .select2-container {
    height: 29px;
    line-height: 29px;
    padding: 3px 0;
}*/
.row-fluid {
	position: inherit !important;
}
</style>
{/literal}
<script>
	// 时间格式信息字符串
	var timeFormatStr = '{$timeFormatArr}';
	var timeFormatArr;
{literal}
	/** 获取时间格式信息数组 */
	function getTimeFormatArr() {
		return timeFormatArr || (timeFormatArr = JSON.parse(timeFormatStr));
	}
{/literal}
</script>
