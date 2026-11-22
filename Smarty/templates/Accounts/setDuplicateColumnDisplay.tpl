<!--修改编码格式:统一编码：UTF-8-->
<div class="setDuplicate" style="max-height: 550px;overflow-y:auto">
    {*查询字段*}
    <div class="ld-pop-container padB0">
        <div class="ld-pop-contnet-title-items">
            <div class="ld-pop-contnet-title-item">{'SetQueryFields'|@getFixedLabel}</div>
        </div>
    </div>
    <table class="settingPopTable settingPopTableNoBot ld-pop-container-second" name="SearchFieldsTabel" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td width="200px;" style="padding:10px 0 10px 10px;">
                <b>{'Available_fields'|@getFixedLabel}</b><br>
                <input class="detailedViewTextBox" style="width:200px;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('field')._onkeyup(this,'tobeselecte_module',event)" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" onblur="return cls_input_select.getInstance('field')._onblur(this)" onfocus="return cls_input_select.getInstance('field')._onfocus(this)" name="allmember" /><br>
                <input type="hidden" value="" id="tobeselecte_module_String" name="tobeselecte_module_String">
                <select style="height: 180px;width:200px;margin-top: 10px;" class="commonMultipleSelect" name="tobeselecte_module" id="tobeselecte_module" multiple="" ondblclick="setDuplicateColumnDisplay.getInstance().copySelectedOptionsSettingField('lefttoright');"><!--ondblclick="addColumn();-->
                    {foreach item=related_module key=related_moduleid from=$searchfields_arr name=relinfo}
                        <option value="search_{$related_moduleid}" rawvalue="{$related_moduleid}">
                            {$related_module}
                        </option>
                    {/foreach}
                </select>
            </td>
            <td width="65px;" align="center">
                <a class="icon-newhomearr icon-mright" href="javascript:;" onclick="setDuplicateColumnDisplay.getInstance().copySelectedOptionsSettingField('lefttoright');" title="{'MOVERIGHT'|@getFIxedLabel}"></a><br>
                <a class="icon-newhomearr icon-mleft" style="margin-top:15px;" href="javascript:;" onclick="setDuplicateColumnDisplay.getInstance().copySelectedOptionsSettingField('righttoleft');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
            </td>
            <td width="200px;" style="padding: 10px 0 10px 10px;">
                <b>{'Selected_Fields'|@getFixedLabel}</b><br><br><br>
                <input type="hidden" value="" id="selected_searchfields_String" name="selected_searchfields_String">
                <select size="11" style="height: 180px;width:200px;margin-top: 10px;" class="commonMultipleSelect" name="selected_searchfields" id="selected_searchfields" multiple="" ondblclick="setDuplicateColumnDisplay.getInstance().copySelectedOptionsSettingField('righttoleft');">
                    {foreach item=item key=itemid from=$searchfields_selected_arr name=relinfo}
                        <option value="search_{$itemid}" rawvalue="{$itemid}">
                                {$item}
                        </option>
                    {/foreach}
                </select>
            </td>
            <td align="left" width="60px;">
                <a class="icon-newhomearr icon-mup" href="javascript:;" onclick="setDuplicateColumnDisplay.getInstance().fieldDetailmoveUp();" title="{'MOVEUP'|@getFIxedLabel}"></a><br>
                <a class="icon-newhomearr icon-mdown" style="margin-top:15px;" href="javascript:;" onclick="setDuplicateColumnDisplay.getInstance().fieldDetailmoveDown();" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
            </td>
        </tr>
    </table>
    {*显示字段*}
    <div class="ld-pop-container padB0">
        <div class="ld-pop-contnet-title-items">
            <div class="ld-pop-contnet-title-item">{'SetDisplayFieldsForDuplicate'|@getFixedLabel}</div>
        </div>
    </div>
    <table class="settingPopTable settingPopTableNoBot ld-pop-container-second" name="DisplayFieldsTable" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td width="200px;" style="padding:10px 0 10px 10px;">
                <b>{'Available_fields'|@getFixedLabel}</b><br>
                <input class="detailedViewTextBox" style="width:200px;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('field')._onkeyup(this,'tobeselecte_module',event)" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" onblur="return cls_input_select.getInstance('field')._onblur(this)" onfocus="return cls_input_select.getInstance('field')._onfocus(this)" name="allmember" /><br>
                <input type="hidden" value="" id="tobeselecte_module_String" name="tobeselecte_module_String">
                <select style="height: 180px;width:200px;margin-top: 10px;" class="commonMultipleSelect" name="tobeselecte_module" id="tobeselecte_module" multiple="" ondblclick="setDuplicateColumnDisplay.getInstance().copySelectedOptionsSettingField('lefttoright');"><!--ondblclick="addColumn();-->
                    {foreach item=related_module key=related_moduleid from=$actions_arr name=relinfo}
                        <option value="{$related_moduleid}">
                            {$related_module}
                        </option>
                    {/foreach}
                </select>
            </td>
            <td width="65px;" align="center">
                <a class="icon-newhomearr icon-mright" href="javascript:;" onclick="setDuplicateColumnDisplay.getInstance().copySelectedOptionsSettingField('lefttoright');" title="{'MOVERIGHT'|@getFIxedLabel}"></a><br>
                <a class="icon-newhomearr icon-mleft" style="margin-top:15px;" href="javascript:;" onclick="setDuplicateColumnDisplay.getInstance().copySelectedOptionsSettingField('righttoleft');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
            </td>
            <td width="200px;" style="padding: 10px 0 10px 10px;">
                <b>{'Selected_Fields'|@getFixedLabel}</b><br><br><br>
                <input type="hidden" value="" id="beselected_module_String" name="beselected_module_String">
                <select size="11" style="height: 180px;width:200px;margin-top: 10px;" class="commonMultipleSelect" name="beselected_module" id="beselected_module" multiple="" ondblclick="setDuplicateColumnDisplay.getInstance().copySelectedOptionsSettingField('righttoleft');">
                    {foreach item=item key=itemid from=$actions_arr_userd name=relinfo}
                        <option value="{$itemid}">
                                {$item}
                        </option>
                    {/foreach}
                </select>
            </td>
            <td align="left" width="60px;">
                <a class="icon-newhomearr icon-mup" href="javascript:;" onclick="setDuplicateColumnDisplay.getInstance().fieldDetailmoveUp();" title="{'MOVEUP'|@getFIxedLabel}"></a><br>
                <a class="icon-newhomearr icon-mdown" style="margin-top:15px;" href="javascript:;" onclick="setDuplicateColumnDisplay.getInstance().fieldDetailmoveDown();" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
            </td>
        </tr>
    </table>
</div>
<div class="E_pbtn">
    <input type="button" class="E_pbtnok ld-button ld-button-primary" value="{'SAVE'|@getFixedLabel}" onclick="setDuplicateColumnDisplay.getInstance().saveColumnSetting('{$MODULE}')"/><span>&nbsp;</span>
    <input type="button" class="E_pbtncancel ld-button ld-button-cancel" value="{'CANCEL'|@getFixedLabel}" onclick="setDuplicateColumnDisplay.getInstance().button_closeDiv()"/>
</div>