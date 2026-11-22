{literal}
<form name="newTemplateForm" action="index.php" method="post" onSubmit="if(validate()) { puyoungJS_DialogBox.block();} else { return false; }">
{/literal}
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="action" value="SaveTemplate"/>
    <input type="hidden" name="mode" value="{$MODE}"/>
    <input type="hidden" name="templatename_label" value="{'TEMLATENAME'|@getFixedLabel}" />
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="templateid" value="{$TEMPLATEID}"/>
    <!--选择显示的组件-->
    <table id="assignPicklistTable" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <th colspan="4"><input name="button" class="E_pbtnok" onclick="add_channelcode_label()" value="{'NEW'|@getFixedLabel}{'Tag'|@getFixedLabel}" type="button"></th>
        <tr>
            <td class="padT5" width="330">
                <b class="greyFont6">{'Optionaltag'|@getFixedLabel}</b> <br/>
				<input class="detailedViewTextBox" style="width:304px;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('module')._onkeyup(this,'AssmablyList',event)" tag="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" onblur="return cls_input_select.getInstance('module')._onblur(this)" onfocus="return cls_input_select.getInstance('module')._onfocus(this)" name="allmember" />
                <br/>
                <select multiple ondblclick="addColumn('AssmablyList','selectedAssmablyColumns')" class="btn-radius-system" id="AssmablyList" name="AssmablyList" style="overflow:auto;margin:5px 0; height: 150px;width:304px;padding: 0 5px;" >
                    {foreach item = channellabel_arr from =$CHANNELLABEL_ARRAY}
						{foreach key = channel_obj item = channellabels from =$channellabel_arr.tag}
							<option value="{$channellabel_arr.group_id}|::|{$channellabel_arr.group_name}|::|{$channellabels.name}|::|{$channellabels.id}">{$channellabel_arr.group_name}&nbsp;:&nbsp;{$channellabels.name}</option>
						{/foreach}
                    {/foreach}
                </select>
                <input type="hidden" name="selectedAssmablyColumnsString" />
            </td>
            <td width="50">
                <a class="icon-newhomearr icon-mright" href="javascript:;" title="{'MOVERIGHT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('AssmablyList','selectedAssmablyColumns');"></a>
                <br/>
                <a class="icon-newhomearr icon-mleft" style="margin-top: 15px;" href="javascript:;" title="{'MOVELEFT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('selectedAssmablyColumns','AssmablyList');"></a>
            </td>
            <td class="padT5" width="330">
                <b class="greyFont6">{'SelectedTags'|@getFixedLabel}</b>
                <br/> <br/> <br/>
                <select multiple ondblclick="addColumn('selectedAssmablyColumns','AssmablyList')" id="selectedAssmablyColumns" name="selectedAssmablyColumns" class="btn-radius-system" style="overflow:auto;margin:5px 0; height: 150px;width:304px;padding: 0 5px;" size="11">
                    {foreach item = channellabel_arr from =$SELETED_CHANNELLABEL_ARRAY}
						{foreach key = channel_obj item = channellabels from =$channellabel_arr.tag}
							<option value="{$channellabel_arr.group_id}|::|{$channellabel_arr.group_name}|::|{$channellabels.name}|::|{$channellabels.id}">{$channellabel_arr.group_name}&nbsp;:&nbsp;{$channellabels.name}</option>
						{/foreach}
                    {/foreach}
                </select>
            </td>
            <td width="45">
                <a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFixedLabel}" onclick="popup_moveUp('selectedAssmablyColumns');" ></a>
                <br/>
                <a class="icon-newhomearr icon-mdown" style="margin-top:15px;" href="javascript:;" title="{'MOVEDOWN'|@getFixedLabel}" onclick="popup_moveDown('selectedAssmablyColumns');"></a>
            </td>
        </tr>
    </table>
</form>