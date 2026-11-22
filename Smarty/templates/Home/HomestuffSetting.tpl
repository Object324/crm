<table  border="0" cellspacing="0" cellpadding="5" width="100%" id="assignPicklistTable" align="center">
	<tr>
	  <td class="trBorder">
		<table width="600">
		  <tr>
			<td width="200">
				<b style="padding-left:15px;color:#666;">{'availablecomponents'|@getFixedLabel}</b>
				<select multiple ondblclick="addColumn('AssmablyList','selectedColumns2')" id="AssmablyList" name="AssmablyList" style="overflow:auto;margin:10px 15px; height: 150px;width:200px;font-family:Arial, Helvetica, sans-serif;font-size:12px;" >
					{foreach item = info from =$BALASTUFF name=pname}
						<option value="{$info.Stuffid}">{$info.Stufftitle}</option>
					{/foreach}
				</select>
				<input type="hidden" name="selectedAssmablyColumnsString" />
			</td>
			<td align="center" width="64">
				<a class="icon-homearr icon-mright" href="javascript:;" title="{'MOVERIGHT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('AssmablyList','selectedColumns2');"></a>
				<a class="icon-homearr icon-mleft" href="javascript:;" title="{'MOVELEFT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('selectedColumns2','AssmablyList');"></a>
			</td>
			<td width="200">
				<b style="padding-left:15px;color:#666;">{'diplayorganizationandsequence'|@getFixedLabel}</b>
				<select multiple ondblclick="addColumn('selectedColumns2','AssmablyList')" id="selectedColumns2" name="selectedColumns2" style="overflow:auto;margin:10px 15px; height: 150px;width:200px;font-family:Arial, Helvetica, sans-serif;font-size:12px;" size="11">
					{foreach item = info from = $HAVESTUFF name=pname}
						<option value="{$info.Stuffid}">{$info.Stufftitle}</option>
					{/foreach}
				</select>
			</td>
			<td align="center" width="65">
				<a class="icon-homearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFixedLabel}" onclick="moveUp();" ></a>
				<a class="icon-homearr icon-mdown" href="javascript:;" title="{'MOVEDOWN'|@getFixedLabel}" onclick="moveDown();"></a>
			</td>
		</tr>
	  </table>
	</td>
</tr>
</table>
