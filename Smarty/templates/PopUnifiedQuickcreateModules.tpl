
<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td width="30%" class="padTB10">
			<b style="color:#666;">{'ALLMODULES'|@getFixedLabel}</b><br />
			<input class="detailedViewTextBox" style="width: 100%;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('module')._onkeyup(this,'tabList',event)" tag="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}"  name="allmember" /><br>
			<select multiple ondblclick="addColumn('tabList','selectedColumns')" id="tabList" name="tabList" class="commonMultipleSelect" style="width: 300px;height: 200px;margin-top: 10px;">
				{foreach key = number item = value from =$ALLOWED_MODULES name=pname}
					<option value="{$value[1]}">{$value[0]}</option>
				{/foreach}
			</select>
			<input type="hidden" name="selectedtabColumnsString" />
		</td>
		<td align="center" width="20%">
			<a class="icon-newhomearr icon-mright" href="javascript:;" title="{'MOVERIGHT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('tabList','selectedColumns');" style="margin-right:-1px"></a>
			<br />
			<a class="icon-newhomearr icon-mleft" style="margin-top: 15px;" href="javascript:;" title="{'MOVELEFT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('selectedColumns','tabList');" ></a>
		</td>
		<td width="30%" align="left" class="padTB10">
			<b style="color:#666;">{'DISPLAYMODULE'|@getFixedLabel}</b><br /><br /><br />
			<select multiple ondblclick="addColumn('selectedColumns','tabList')" id="selectedColumns" name="selectedColumns"  class="commonMultipleSelect" style="width: 300px;height: 200px;margin-top: 10px;" size="11">
				{foreach key = number item = menus from = $SELECT_MODULES name=pname}
					<option value="{$menus[1]}">{$menus[0]}</option>
				{/foreach}
			</select>
		</td>
		<td align="center" width="20%">
			<a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFixedLabel}" onclick="popup_moveUp('selectedColumns');"></a>
			<br />
			<a class="icon-newhomearr icon-mdown" style="margin-top: 15px;margin-left: -1px;" href="javascript:;" title="{'MOVEDOWN'|@getFixedLabel}" onclick="popup_moveDown('selectedColumns');"></a>
		</td>
	</tr>
</table>