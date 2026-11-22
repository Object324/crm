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
		{'DUPLICATECHECKREMIND'|@getFixedLabel}
	</div>
</div>
<div class="ld-pop-container-second overflowauto">
{if $MODULE neq 'Accounts'}
	{*editor:gyq_170 reason:自动查重合并返回值修改  2020/3/9 14:47*}
	<form enctype="multipart/form-data" name="mergeDuplicates" method="post" action="index.php?module={$MODULE}&action=FindDuplicateRecords" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="{$MODULE}"/>
		<input type="hidden" name="parenttab" value="{$CATEGORY}"/>
		<input type="hidden" name="action" value="FindDuplicateRecords"/>
		<input type="hidden" name="selectedColumnsString"/>
		<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tbody>
				<tr style="display: none;">
					<td width="50%" style="padding-top: 10px;">
						<span class="optionalfieldSpan">{'OPTIONALFIELD'|@getFixedLabel}</span><br>
						<input class="detailedViewTextBox" style="width: 100%;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('field')._onkeyup(this,'availList',event)" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" value="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" onblur="return cls_input_select.getInstance('field')._onblur(this)" onfocus="return cls_input_select.getInstance('field')._onfocus(this)" name="allmember" /><br>
						<select id="availList" multiple size="" name="availList" class='commonMultipleSelect' style="width: 100%;height: 270px;margin: 10px 0;" ondblclick="clickAddColumn('availList','selectedColumns')">
						{$AVALABLE_FIELDS}
						</select>
					</td>
					<td valign="center">
						<a class="icon-newhomearr icon-mright" href="javascript:;" onclick="selectOptions('availList','selectedColumns');" title="{'MOVERIGHT'|@getFixedLabel}"></a>
						<br />
						<a class="icon-newhomearr icon-mleft" href="javascript:;" onclick="selectOptions('selectedColumns','availList');" title="{'MOVELEFT'|@getFixedLabel}"></a>
					</td>
					<td width="50%" style="padding-top: 10px;">
						<span class="optionalfieldSpan">{'Selected_Fields'|@getFixedLabel}</span><br><br><br>
						<select id="selectedColumns" size="10" name="selectedColumns" class='commonMultipleSelect' multiple style="width: 100%;height: 270px;margin: 10px 0;" ondblclick="clickAddColumn('selectedColumns','availList')">
						{$FIELDS_TO_MERGE}
						</select>
					</td>
				</tr>
			</tbody>
		</table>
	</form>

{else}
	<form enctype="multipart/form-data" name="mergeDuplicates" method="post" action="index.php?module={$MODULE}&action=FindDuplicateRecords" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="{$MODULE}">
		<input type="hidden" name="parenttab" value="{$CATEGORY}">
		<input type="hidden" name="action" value="FindDuplicateRecords">
		<input type="hidden" name="selectedColumnsString"/>
		<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
    		<tbody>
				<tr style="display: none;">
					<td width="50%" style="padding-top: 10px;">
                        <span class="optionalfieldSpan">{'OPTIONALFIELD'|@getFixedLabel}</span><br>
						<input class="detailedViewTextBox" style="width:100%;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('field')._onkeyup(this,'availList',event)" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}"  name="allmember" /><br>
						<select id="availList" multiple size="" name="availList" class='commonMultipleSelect' style="width: 100%;height: 270px;margin: 10px 0;" ondblclick="clickAddColumn('availList','selectedColumns')">
						{$AVALABLE_FIELDS}
						</select>
					</td>
					<td valign="center">
                        <a class="icon-newhomearr icon-mright" href="javascript:;" onclick="selectOptions('availList','selectedColumns');" title="{'MOVERIGHT'|@getFixedLabel}"></a><br>
                        <a class="icon-newhomearr icon-mleft" href="javascript:;" style="margin-top:15px;" onclick="selectOptions('selectedColumns','availList');" title="{'MOVELEFT'|@getFixedLabel}"></a>
                    </td>
					<td width="50%" style="padding-top: 10px;">
                        <span class="optionalfieldSpan">{'Selected_Fields'|@getFixedLabel}</span><br><br><br>
						<select id="selectedColumns" size="10" name="selectedColumns" class='commonMultipleSelect' multiple style="width: 100%;height: 270px;margin: 10px 0;" ondblclick="clickAddColumn('selectedColumns','availList')">
						{$FIELDS_TO_MERGE}
						</select>
					</td>
				</tr>
    		</tbody>
    	</table>
	</form>
{/if}
</div>