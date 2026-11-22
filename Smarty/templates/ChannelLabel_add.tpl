<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td width="100%"><font color="red">*</font>{'Taggroupname'|@getFixedLabel}</td>
	</tr>
	<tr>
		<td width="100%">
			<input type="text" fieldonly="0" input_label="{'Taggroupname'|@getFixedLabel}" placeholder="{'pleaseenter'|@getFixedLabel}{'Taggroupname'|@getFixedLabel}" tabindex="p" name="label_group_name" id="label_group_name" value="" class="detailedViewTextBox" onfocus="this.className='commonDetailedTextBox gwidth90 bgcolordh'" onblur="this.className='detailedViewTextBox'">
		</td>
	</tr>
	<tr>
		<td width="100%"><font color="red">*</font>{'Tag'|@getFixedLabel}</td>
	</tr>
	<tr>
		<td width="100%" name="moduletag_tr">
			<input type="hidden" name="label_content_num" value="1"/>
			<div name="div_moduletag_tr" style="max-height: 300px; overflow-y: auto;" input_val="{'pleaseenter'|@getFixedLabel}{'Tag'|@getFixedLabel}">
				<div name="channelcode_tr_num_1">
					<input type="text" name="label_content" input_label="{'Tag'|@getFixedLabel}" id="label_content" style="width:60%;margin-top: 5px;" class="detailedViewTextBox" placeholder="{'pleaseenter'|@getFixedLabel}{'Tag'|@getFixedLabel}" tabindex="1" />
				</div>
			</div>
		</td>
	</tr>
</table>

<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
		<td width="100%"><a style="vertical-align: middle;" href="javascript:void(0);" onclick="add_channelcode_tr()">+ {'ADDITION'|@getFixedLabel}{'Tag'|@getFixedLabel}</a></td>
	</tr>
</table>