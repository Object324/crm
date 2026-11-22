<div class="ld-pop-container-second divPopOverflow">
  <input type="hidden" name="blockid" id="blockid" value="{$BLOCKID}" />
  <table class="ld-public-content-small" style="padding: 10px 14px 20px 10px;" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr {if $menu_user_type=='prm'}style="display:none;"{/if}>
      <td class="ld-form-item-label">
        <font color="red">*</font>{'ZHPARENTMENUNMAE'|@getFixedLabel}
      </td>
      <td class="ld-form-item-content">
        <input tag="{'ZHPARENTMENUNMAE'|@getFixedLabel}" id="mobileblock_name" name="mobileblock_name" type="text" value="{$BLOCKNAME}" class="ld-input-inner"/>
      </td>
    </tr>
    <tr {if $menu_user_type=='prm'}style="display:none;"{/if}>
      <td class="ld-form-item-label">
        <font color="red">*</font>{'ENPARENTMENUNMAE'|@getFixedLabel}
      </td>
      <td class="ld-form-item-content">
        <input tag="{'ENPARENTMENUNMAE'|@getFixedLabel}" id="mobileblock_name_en" name="mobileblock_name_en" type="text" value="{$ENBLOCKNAME}" class="ld-input-inner"/>
      </td>
    </tr>
    <tr {if $menu_user_type=='prm'}style="display:none;"{/if}>
      <td class="ld-form-item-label">
        <font color="red">*</font>{'WHETHERTOENABLE'|@getFixedLabel}
      </td>
      <td class="ld-form-item-content">
        <input type="checkbox" class="second_switch" id="mobileblock_presence" name="mobileblock_presence" {if $PRESENCE eq 'yes'} checked="true"{/if} />
      </td>
    </tr>
    <tr>
      <td class="ld-form-item-label{if $menu_user_type=='prm'} padT0{/if}">{$FUNCTIONMENUDESCRIPTION}
      </td>
      <td class="ld-form-item-content{if $menu_user_type=='prm'} padT0{/if}">
        <textarea class="ld-textarea-inner" id="menudescription" name="menudescription" type="text">{$MENUDESCRIPTION}</textarea>
      </td>
    </tr>
  </table>
  <div class="pad10 padT0">
    <div class="ld-pop-contnet-title-items">
      <div class="ld-pop-contnet-title-item" >
        {'SUBMODULEDISPLAY'|@getFixedLabel}
      </div>
    </div>
  </div>

  <table id="assignPicklistTable" class="settingPopTable settingPopTableNoBot" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="200" class="padTB5">
        <b style="color:#666;">{'ALLMODULES'|@getFixedLabel}</b><br />
		<input class="detailedViewTextBox" style="margin-top: 5px;" type="text"  onkeyup="clickSelectMember(this,'tabList')" tag="{'pleaseenterthecategoryyouarelookingfor'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingfor'|@getFixedLabel}" name="allmember" /><br>
        <select multiple style="height:200px;" ondblclick="addColumn('tabList','selectedtabColumns')" id="tabList" name="tabList" class="commonMultipleSelect marT5">
          {foreach key = number item = value from =$ALLTABS name=pname}
            <option value="{$value.tabid}:{$value.tab_tablename}">{$value.tabname}</option>
          {/foreach}
        </select>
        <input type="hidden" name="selectedtabColumnsString" />
      </td>
      <td align="left" width="60">
        <a class="icon-newhomearr icon-mright" href="javascript:;" title="{'MOVERIGHT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('tabList','selectedtabColumns');" ></a>
        <br />
        <a class="icon-newhomearr icon-mleft" style="margin-top: 15px;" href="javascript:;" title="{'MOVELEFT'|@getFixedLabel}" onclick="copySelectedOptionsSettingModule('selectedtabColumns','tabList');" ></a>
      </td>
      <td width="200" class="padTB5">
        <b style="color:#666;">{'DISPLAYMODULE'|@getFixedLabel}</b><br /><br /><br />
        <select multiple style="height:200px;" tag="{'DISPLAYMODULE'|@getFixedLabel}" ondblclick="addColumn('selectedtabColumns','tabList')" id="selectedtabColumns" name="selectedtabColumns" class="commonMultipleSelect marT5">
          {foreach key = number item = menus from = $HAVETABS name=pname}                                     
            <option value="{$menus.tabid}:{$menus.tab_tablename}">{$menus.tabname}</option>
           {/foreach}
        </select>
      </td>
      <td align="left" width="60">
        <a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFixedLabel}" onclick="select_moveUp('selectedtabColumns');"></a>
        <br />
        <a class="icon-newhomearr icon-mdown" style="margin-top: 15px;" href="javascript:;" title="{'MOVEDOWN'|@getFixedLabel}" onclick="select_moveDown('selectedtabColumns');"></a>
      </td>
    </tr>
  </table>
  {if $menu_user_type!='prm'}
    <div class="pad10">
      <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item" >
          {'visiblerangsettings'|@getFixedLabel}
        </div>
      </div>
    </div>
  {/if}
  <table class="settingPopTable lasttdbordernon padB10" width="100%" border="0" cellspacing="0" cellpadding="0" {if $menu_user_type=='prm'}style="display:none;"{/if}>
    <tr>
      <td width="320">
        <div id='view_scope' class="select-input">
          <label><input type="radio" {if $ALLOCATETYPE eq 'all'}checked="" {/if} value="all" name="radioUser" onclick="CustomScope.setAllUser();">
          <span class="padR10">{'ALLTHEUSERS'|@getFixedLabel}</span></label>
          <label><input type="radio" {if $ALLOCATETYPE eq 'group'}checked="" {/if} undefined="" onclick="CustomScope.setScopeGroup('{$ALLOCATEID}')" value="group" name="radioUser">
          <span class="padR10">{'SETBYDEPARTMENT'|@getFixedLabel}</span></label>
          <label><input type="radio" {if $ALLOCATETYPE eq 'user'}checked="" {/if} undefined="" onclick="CustomScope.setScopeUser('{$ALLOCATEID}');" value="user" name="radioUser">
          <span class="padR10">{'SETBYUSERS'|@getFixedLabel}</span></label>
          <label><input type="radio" {if $ALLOCATETYPE eq 'role'}checked="" {/if} undefined="" onclick="CustomScope.setScopeRole('{$ALLOCATEID}');" value="role" name="radioUser">
          <span class="padR10">{'SetByRole'|@getFixedLabel}</span></label>
          <input id="customscope_type" class="templateprintuser" type="hidden" value="{$ALLOCATETYPE}" name="customscope_type">
          <input id="customscope_ids" class="templateprintuser" type="hidden" value="{$ALLOCATEID}" name="customscope_ids">
        </div>
      </td>
    </tr>
  </table>
</div>
