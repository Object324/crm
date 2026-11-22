<form name="menu" action="index.php" method="post" onSubmit="if(validate()) { puyoungJS_DialogBox.block();} else { return false; }">
    <input type="hidden" name="parenttabid" value="{$PARENTTABID}"/>	
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'BASICINFORMATION'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
      	<tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'ZHPARENTMENUNMAE'|@getFixedLabel}</td>
			<td class="ld-form-item-content"><input id="parentchinese" name="parentchinese" type="text" value="{$ZHPARENTTABLABEL}" class="ld-input-inner gwidth90"/></td>
		</tr>
        <tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'ENPARENTMENUNMAE'|@getFixedLabel}</td>
			<td class="ld-form-item-content"><input id="parentenglish" name="parentenglish"   type="text" value="{$ENPARENTTABLELABEL}" class="ld-input-inner gwidth90"/></td>
		</tr>
        <tr style="display: none;">
			<td class="ld-form-item-label"><font color="red">*</font>{'DISPLAYORDER'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
                {if $SEQUENCE neq ''}
                <input id="parentindex" name="parentindex" type="text" value="{$SEQUENCE}" class="ld-input-inner gwidth90"/>
    	        {else}
                <input id="parentindex" name="parentindex" type="text" value="{$ADDSEQUENCES}" class="ld-input-inner gwidth90"/>
                {/if}
            </td>
    	</tr>
        <tr>
			<td class="ld-form-item-label"><font color="red">*</font>{'WHETHERTOENABLE'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
                <input type="checkbox" class="second_switch" id="visible" name="visible" value="{$visible}" {if $visible neq '1'}checked="true"{/if} />
            </td>
    	</tr>
        {*zxm 2021-1206 上传菜单图标 --start*}
        <tr>
            <td class="ld-form-item-label">{'UnselectedIcon'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                {if $inactive_icon}
                <div id="inactive_icon_preview" style="width:  40px;height:40px;">
                    <img src="{$inactive_icon}" style="width: 40px;height: 40px;">
                </div>
                {/if}
                <input name="inactive_icon_size" value="1024" type="hidden">
                <input name="inactive_icon_name" value="{$inactive_icon_name}" type="hidden">
                <input name="inactive_icon"  accept="image/*" value="{$inactive_icon_name}" onchange="validateFilename(this);" type="file" style="display: initial;width: 160px;">
                <input name="inactive_icon_name_hidden" value="{$inactive_icon_name}" type="hidden">
                <span style="color: red;font-size: 12px;display: initial;">{'menuIconUploadSizeTips'|@getFixedLabel}</span>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'SelectedIcon'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                {if $active_icon}
                <div id="active_icon_preview" style="width:  40px;height:40px;">
                    <img src="{$active_icon}" style="width: 40px;height: 40px;">
                </div>
                {/if}
                <input name="active_icon_size" value="1024" type="hidden">
                <input name="active_icon_name" value="{$active_icon_name}" type="hidden">
                <input name="active_icon" accept="image/*" value="{$active_icon_name}" onchange="validateFilename(this);" type="file" style="display: initial;width: 160px;">
                <input name="active_icon_name_hidden" value="{$active_icon_name}" type="hidden">
                <span style="color: red;font-size: 12px;display: initial;">{'menuIconUploadSizeTips'|@getFixedLabel}</span>
            </td>
        </tr>
        {*zxm 2021-1206 上传菜单图标 --end*}
        {if $Error neq ''}
        <tr>
            <td style="color:red;" colspan="2">
                {$Error}
            </td>
        </tr>                        
        {/if}					
    </table>
    <div class="ld-public-content-small padT8 padB0">
        <div class="ld-pop-contnet-title-items">
            <div class="ld-pop-contnet-title-item">{'SUBMODULEDISPLAY'|@getFixedLabel}</div>
        </div>
    </div>
    <table class="DragTransferTable" border="0" cellpadding="0" cellspacing="0" width="100%" style="padding-left: 14px;">
        <tr>
            <td>
                    <b style="color:#666;">{'ALLMODULES'|@getFixedLabel}</b><br />
                    <input class="detailedViewTextBox" style="width: 100%;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('module')._onkeyup(this,'tabList',event)" tag="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}"  name="allmember" /><br>
                    <select multiple ondblclick="addColumn('tabList','selectedColumns')" id="tabList" name="tabList" class="commonMultipleSelect" style="height: 200px;margin-top: 10px;">
                        {foreach key = number item = value from =$ALLTABS name=pname}
                            <option value="{$value.tabid}:{$value.tab_tablename}">{$value.tabname}</option>
                        {/foreach}
                    </select>
                    <input type="hidden" name="selectedtabColumnsString" />
                </td>
            <td align="center" width="20%">
                    <a class="icon-newhomearr icon-mright" href="javascript:;" title="{'MOVERIGHT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('tabList','selectedColumns');" style="margin-right:-1px"></a>
                    <br />
                    <a class="icon-newhomearr icon-mleft" style="margin-top: 15px;" href="javascript:;" title="{'MOVELEFT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('selectedColumns','tabList');" ></a>
                </td>
            <td >
                    <b style="color:#666;">{'DISPLAYMODULE'|@getFixedLabel}</b><br /><br /><br />
                    <select multiple ondblclick="addColumn('selectedColumns','tabList')" id="selectedColumns" name="selectedColumns"  class="commonMultipleSelect" style="height: 200px;margin-top: 10px;" size="11">
                        {foreach key = number item = menus from = $CHILDTABS name=pname}
                            <option value="{$menus.tabid}:{$menus.tab_tablename}">{$menus.tabname}</option>
                        {/foreach}
                    </select>
                </td>
            <td >
                    <a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFixedLabel}" onclick="popup_moveUp('selectedColumns');"></a>
                    <br />
                    <a class="icon-newhomearr icon-mdown" style="margin-top: 15px;margin-left: -1px;" href="javascript:;" title="{'MOVEDOWN'|@getFixedLabel}" onclick="popup_moveDown('selectedColumns');"></a>
                </td>
        </tr>
    </table>


	<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td>
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'visiblerangsettings'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-content padL0">
				<div id='view_scope' class="select-input">
                    <label class="padL0"><input type="radio" {if $ALLOCATETYPE eq 'all'}checked="" {/if} value="all" name="radioUser" onclick="CustomScope.setAllUser();">
                    <span class="padR10">{'ALLTHEUSERS'|@getFixedLabel}</span></label>
                    <label ><input type="radio" {if $ALLOCATETYPE eq 'group'}checked="" {/if} undefined="" onclick="CustomScope.setScopeGroup('{$ALLOCATEID}')" value="group" name="radioUser">
                    <span class="padR10">{'SETBYDEPARTMENT'|@getFixedLabel}</span></label>
                    <label ><input type="radio" {if $ALLOCATETYPE eq 'user'}checked="" {/if} undefined="" onclick="CustomScope.setScopeUser('{$ALLOCATEID}');" value="user" name="radioUser">
                    <span class="padR10">{'SETBYUSERS'|@getFixedLabel}</span></label>
                    <label ><input type="radio" {if $ALLOCATETYPE eq 'role'}checked="" {/if} undefined="" onclick="CustomScope.setScopeRole('{$ALLOCATEID}');" value="role" name="radioUser">
                    <span class="padR10">{'SetByRole'|@getFixedLabel}</span></label>
    				<input id="customscope_type" class="templateprintuser" type="hidden" value="{$ALLOCATETYPE}" name="customscope_type">
    				<input id="customscope_ids" class="templateprintuser" type="hidden" value="{$ALLOCATEID}" name="customscope_ids">
				</div>
			</td>
        </tr>
	</table>
  </form>
