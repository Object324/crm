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
<div class="ld-description">
	<b class="info-icon"></b>
	<div class="ld-description-content">
		{if $MODE eq 'edit'}
			{'SETTINGDEPENCYPARENTCHILD'|@getFixedLabel}
		{else}
			{'DEPENCYEDITSECOND'|@getFixedLabel}
		{/if}
	</div>
</div>
<div class="ld-pop-container overflowauto padT5">
<form enctype="multipart/form-data" name="mergeDuplicates" method="post" action="index.php?module={$MODULE}&action=FindDuplicateRecords" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="module" value="{$MODULE}"/>
	<input type="hidden" name="parenttab" value="{$CATEGORY}"/>
	<input type="hidden" name="action" value="FindDuplicateRecords"/>
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="BorBnone" style="width: 30%;">
				<span style="display: inline-block;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;width: 195px;">{'SUPERIORMAOHAO'|@getFixedLabel}{$PARENTLABEL}</span>
				<a href="javascript:void(0);" onclick="showPickList('sourcefield','{$SOURCEFIELD}')" class="rfloat" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
			</td>
			<td class="BorBnone" style="width: 30%;">
				<span style="display: inline-block;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;width: 195px;">{'SUBORDINATEMAOHAO'|@getFixedLabel}{'AVAILABLE'|@getFixedLabel}{$CHILDLABEL}</span>
				<a href="javascript:void(0);" onclick="showPickList('targetfield','{$TARGETFIELD}')" class="rfloat" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
			</td>
			<td class="BorBnone" valign="center"></td>
			<td class="BorBnone" style="width: 30%;">
				<span style="display: inline-block;white-space: nowrap;overflow: hidden;text-overflow: ellipsis;width: 195px;">{'choose'|@getFixedLabel}{$CHILDLABEL}</span>
				<a href="javascript:void(0);" onclick="getDepencyPickList()" class="rfloat" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
			</td>
			<td class="BorBnone" valign="center"></td>
		</tr>
		<tr>
			<td>
				<input class="ld-input-inner" type="text" onkeyup="cls_input_select.getInstance('input')._onkeyup(this,'parentdepecyfieldname',event)" tag="{'pleaseenterthecategoryyouarelookingfor'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingfor'|@getFixedLabel}" name="allmember" /><br />
				<select id="parentdepecyfieldname" size="8" onchange="changeModuleFieldOption()" name="parentdepecyfieldname" class='commonMultipleSelect gwidth100' style="height: 230px;margin-top: 5px;">
					{foreach from=$ARRPARENTPICKLIST item=str_text name=picklistvalue}
					{if $smarty.foreach.picklistvalue.index eq 0}
					<option value="{$str_text}" selected="">{$str_text}</option>
					{else}
					<option value="{$str_text}">{$str_text}</option>
					{/if}
					{/foreach}
				</select>
			</td>
			<td>
				<input class="ld-input-inner" type="text" onkeyup="cls_input_select.getInstance('input')._onkeyup(this,'childdepecyfieldname',event)" tag="{'pleaseenterthecategoryyouarelookingfor'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingfor'|@getFixedLabel}" name="allmember" /><br />
				<select id="childdepecyfieldname" size="8" name="childdepecyfieldname" class='commonMultipleSelect gwidth100' multiple style="height: 230px;margin-top: 5px;" ondblclick="moveRightNoRemove('childdepecyfieldname','selectfieldnames');setDepencySelectFields()">
					{foreach from=$ARRCHILDPICKLIST item=str_text name=picklistvalue}
						<option value="{$str_text}">{$str_text}</option>
					{/foreach}
				</select>
			</td>
			<td valign="center">
				<a class="ld-icon-newhomearr-mright ld-icon-movetoright sort-tip-btn" href="javascript:;" onclick="moveRightNoRemove('childdepecyfieldname','selectfieldnames');setDepencySelectFields()" data-tip="{'MOVERIGHT'|@getFixedLabel}"></a>
				<br /><br />
				<a class="ld-icon-newhomearr-mleft ld-icon-movetoleft sort-tip-btn" href="javascript:;" onclick="selectOptions('selectfieldnames','childdepecyfieldname');setDepencySelectFields()" data-tip="{'MOVELEFT'|@getFixedLabel}"></a>
			</td>
			<td>
				<!--BUG0066922  yujun 2023-6-1-->
				<select id="selectfieldnames" size="10" name="selectfieldnames" class='commonMultipleSelect gwidth100' multiple style="height: 230px;margin-top:30px;" ondblclick="clickAddColumn('selectfieldnames','childdepecyfieldname');setDepencySelectFields()">
					{foreach from=$ARRSELECTFIELDNAME item=str_text name=picklistvalue}
						<option value="{$str_text}">{$str_text}</option>
					{/foreach}
				</select>
			</td>
			<td valign="center">
				<a class="ld-icon-newhomearr-mup ld-icon-moveup sort-tip-btn" href="javascript:;" onclick="select_moveUp('selectfieldnames');setselectFieldNameOrder()" data-tip="{'MOVEUP'|@getFixedLabel}"></a>
				<br /><br />
				<a class="ld-icon-newhomearr-mdown ld-icon-movedown sort-tip-btn" href="javascript:;" onclick="select_moveDown('selectfieldnames');setselectFieldNameOrder()" data-tip="{'MOVEDOWN'|@getFixedLabel}"></a>
			</td>
		</tr>
	</table>
</form>
</div>