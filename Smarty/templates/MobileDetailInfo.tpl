<div class="cont_wrap clear_float">
    <div class="ld-flex-start" style="flex-wrap: wrap;">
        <div>
            <table id="assignPicklistTable" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <th colspan="5">{'Entrydetailsdisplaystyle'|@getFixedLabel}</th>
                </tr>
                <tr>
                   <td colspan="4" width="800">
                       <div class="ld-flex-start">
                           <div class="marR10 pad10">
                               <label class="lineheight38"><input value="tile" type="radio" {if $mobiledetailinfoshowtype=='tile'}checked{/if} name="mobiledetailinfoshowtype"/>&nbsp;&nbsp;{'Tilefields'|@getFixedLabel}</label>
                           </div>
                           <div class="marR10 pad10">
                               <label class="lineheight38"><input value="fold" type="radio" {if $mobiledetailinfoshowtype=='fold'}checked{/if} name="mobiledetailinfoshowtype"/>&nbsp;&nbsp;{'Collapsefield'|@getFixedLabel}</label>
                           </div>
                           <div class="marR10 pad10">
                               <label class="lineheight38"><input value="table" type="radio" {if $mobiledetailinfoshowtype=='table'}checked{/if} name="mobiledetailinfoshowtype"/>&nbsp;&nbsp;{'Tabledisplay'|@getFixedLabel}</label>
                           </div>
                       </div>
                   </td>
                </tr>
                <tr id="detailFieldsSelectBlock" style="{if $mobiledetailinfoshowtype=='tile'}display:none;{/if}">
                    <table id="detailFieldsSelectBlockTable" style="{if $mobiledetailinfoshowtype=='tile'}display:none;{/if}">
                        <tr>
                            <td class="padT5" width="330">
                                <b class="greyFont6">{'Available_fields'|@getFixedLabel}</b> <br/>
                                <input class="detailedViewTextBox" style="width:304px;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('module')._onkeyup(this,'detailFieldList',event)" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}"   name="allmember" />
                                <br/>
                                <select multiple ondblclick="clickAddColumn('detailFieldList','selectedDetailFieldColumns')" class="btn-radius-system" id="detailFieldList" name="detailFieldList" style="overflow:auto;margin:5px 0; height: 200px;width:304px;padding: 0 5px;" >
                                    {foreach item = fieldInfo from =$fieldAllInfoArr}
                                        <option value="{$fieldInfo.columnname}">{$fieldInfo.fieldlabel}</option>
                                    {/foreach}
                                </select>
                                <input type="hidden" name="selectedDetailFieldColumnsString" />
                            </td>
                            <td width="74">
                                <a class="icon-newhomearr icon-mright" href="javascript:;" title="{'MOVERIGHT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('detailFieldList','selectedDetailFieldColumns');"></a>
                                <br/>
                                <a class="icon-newhomearr icon-mleft" style="margin-top: 15px;" href="javascript:;" title="{'MOVELEFT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('selectedDetailFieldColumns','detailFieldList');"></a>
                            </td>
                            <td class="padT5" width="330">
                                <b class="greyFont6">{'Selected_Fields'|@getFixedLabel}</b>
                                <br/> <br/> <br/>
                                <select multiple ondblclick="clickAddColumn('selectedDetailFieldColumns','detailFieldList')" id="selectedDetailFieldColumns" name="selectedDetailFieldColumns" class="btn-radius-system" style="overflow:auto;margin:5px 0; height: 200px;width:304px;padding: 0 5px;" size="11">
                                    {foreach item = fieldInfo from =$fieldSelectedArr}
                                        <option value="{$fieldInfo.columnname}">{$fieldInfo.fieldlabel}</option>
                                    {/foreach}
                                </select>
                            </td>
                            <td width="50">
                                <a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFixedLabel}" onclick="popup_moveUp('selectedDetailFieldColumns');" ></a>
                                <br/>
                                <a class="icon-newhomearr icon-mdown" style="margin-top:15px;" href="javascript:;" title="{'MOVEDOWN'|@getFixedLabel}" onclick="popup_moveDown('selectedDetailFieldColumns');"></a>
                            </td>
                        </tr>
                    </table>
                </tr>
                <tr>
                    <td colspan="4">
                        <div class="ld-flex-start ld-listview-btnscontent">
                            <div style="margin:0;" id="saveDetailFieldInfo" class="ld-button" title="{'SAVE'|@getFixedLabel}">{'SAVE'|@getFixedLabel}</div>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
        <div style="height:600px;margin-top: 50px;margin-left: 55px;">
            <img id="mobiledetailinfoshowtypeimg" style="width:600px;" src="{$IMAGEURL}themes/fieldicon/{$mobiledetailinfoshowtype}.jpg?v={$GLOBALMINVERSION}"/>
        </div>
    </div>
</div>