{literal}
<form name="newTemplateForm" action="index.php" method="post" onSubmit="if(validate()) { puyoungJS_DialogBox.block();} else { return false; }">
{/literal}
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="action" value="SaveTemplate"/>
    <input type="hidden" name="mode" value="{$MODE}"/>
    <input type="hidden" name="templatename_label" value="{'TEMLATENAME'|@getFixedLabel}" />
    <input type="hidden" name="parenttab" value="Settings"/>
    <input type="hidden" name="templateid" value="{$TEMPLATEID}"/>
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <th colspan="2">{'TEMLATENAME'|@getFixedLabel}</th>
        <tr>
            <td width="20%"><font color="red">*</font>{'TEMLATENAME'|@getFixedLabel}</td>
            <td width="80%"><input id="templatename" name="templatename" type="text" value="{$TEMPLATENAME}" class="controlInput btn-radius-system"/></td>
        </tr>
    </table>
    <!--选择显示的组件-->
    <table id="assignPicklistTable" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <th colspan="4">{'DISPLAYMODULE'|@getFixedLabel}</th>
        <tr>
            <td class="padT5" width="330">
                <b class="greyFont6">{'ALLMODULES'|@getFixedLabel}</b> <br/>
				<input class="detailedViewTextBox" style="width:330px;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('module')._onkeyup(this,'AssmablyList',event)" tag="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" onblur="return cls_input_select.getInstance('module')._onblur(this)"  name="allmember" />
                <br/>
                <select multiple ondblclick="clickAddColumn('AssmablyList','selectedAssmablyColumns')" class="btn-radius-system" id="AssmablyList" name="AssmablyList" style="overflow:auto;margin:5px 0; height: 150px;width:330px;padding: 0 5px;" >
                    {foreach key = number item = assmablys from =$ALLASSMABLYS name=pname}
                        {assign var="assmablylabel" value=$assmablys}
                        {if $VERSIONTYPE eq 1 && $assmablys eq 'RECEIVESUMMARY'}
                            {assign var="assmablyname" value=$RECEIVESUMMARY}
                        {else}
                            {assign var="assmablyname" value=$assmablys|@getFixedLabel}
                        {/if}
                        {assign var="stuffid" value=$number}
                        <option value="{$stuffid}::{$assmablys}">{$assmablyname}</option>
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
                <b class="greyFont6">{'DISPLAYMODULE'|@getFixedLabel}</b>
                <br/> <br/> <br/>
                <select multiple ondblclick="clickAddColumn('selectedAssmablyColumns','AssmablyList')" id="selectedAssmablyColumns" name="selectedAssmablyColumns" class="btn-radius-system" style="overflow:auto;margin:5px 0; height: 150px;width:330px;padding: 0 5px;" size="11">
                    {foreach key = number item = menus from = $ASSIGNED_VALUES name=pname}
                        {assign var="tabid" value=$menus[0]}
                        {assign var="enmodulename" value=$menus[1]}
                         {if $VERSIONTYPE eq 1 && $enmodulename eq 'RECEIVESUMMARY'}
                            {assign var="modulename" value=$RECEIVESUMMARY}
                        {else}
                            {assign var="modulename" value=$menus[1]|@getFixedLabel}
                        {/if}
                        
                       
                        <option value="{$tabid}::{$enmodulename}">{$modulename}</option>
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
    <!--选择角色-->
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <th colspan="4">{'SELECTROLES'|@getFixedLabel}</th>
        <tr>
            <td class="padT5" valign="top" width="330">
                <b class="greyFont6">{'AVAILABLEROLES'|@getFixedLabel}</b>
                <br />
                <select id="RoleList" ondblclick="clickAddColumn('RoleList','selectedRoleColumns')" name="RoleList" multiple="multiple" size="10" class="btn-radius-system" style="overflow:auto;margin:5px 0; height: 150px;width:330px;padding: 0 5px;">
                {foreach key=profileid item=profilename from=$PROFILEALL}
                    <option value="roles:{$profileid}">{'LBL_ROLES'|@getFixedLabel}:{$profilename}</option>
                {/foreach}
                </select>
                <input type="hidden" name="selectedRoleColumnsString"/>
                <input type="hidden" name="findStr" >&nbsp;
            </td>
            <td align="center" width="50">
                <a class="icon-newhomearr icon-mright" href="javascript:;" title="{'MOVERIGHT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('RoleList','selectedRoleColumns')"></a>
                <br />
                <a class="icon-newhomearr icon-mleft" style="margin-top: 15px;" href="javascript:;" title="{'MOVELEFT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('selectedRoleColumns','RoleList')"></a>
            </td>
            <td class="padT5" valign="top" width="330">
                <b class="greyFont6">{'SELECTEDROLES'|@getFixedLabel}</b>
                <br />
                <select id="selectedRoleColumns" ondblclick="clickAddColumn('selectedRoleColumns','RoleList')" name="selectedColumns" multiple="multiple" size="10" class="btn-radius-system" style="overflow:auto;margin:5px 0; height: 150px;width:330px;padding: 0 5px;">
                <!--左边-->
                {foreach item=element from=$MEMBER}
                    <option value="{$element.0}">{$element.1}</option>
                {/foreach}
                </select>
            </td>
            <td width="50">
            </td>
        </tr>
    </table>
</form>