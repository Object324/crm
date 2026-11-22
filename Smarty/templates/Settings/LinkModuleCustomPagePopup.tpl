<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/SetUeryScope.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>
<div class="divPopOverflow">
<table class="ld-public-content-small" cellspacing="0" cellpadding="0" border="0" width="100%">
    <tr>
        <td class="ld-form-item-label">
           <font color="red">*</font>{'CNTAG'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <input type="text" class="ld-input-inner" name="zh_label" value="{$zh_label}">
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">
            <font color="red">*</font>{'ENTAG'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <input type="text" class="ld-input-inner" name="en_label" value="{$en_label}">
        </td>
    </tr>
    {*// @edit:dong @date:2020/10/29 @reason: 数据分类设置为链接模块*}
    {if $ENTITYTYPE eq 'category'}
        {*模块名称*}
        <tr>
            <td class="ld-form-item-label">
                {'MODULENAME'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <div class="ld-input-inner-div">{$LINKMODULE}</div>
            </td>
        </tr>
        {*数据分类*}
        <tr>
            <td class="ld-form-item-label">
                {'DATACATEGORY'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <div class="ld-input-inner-div">{$LINKCVIDNAME}</div>
            </td>
        </tr>
    {else}
        <tr>
            <td class="ld-form-item-label">
                <font color="red">*</font>{'LINKADDRESS'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <input type="text" {if $ENTITYTYPE eq 'customfine'}readonly=""{/if} class="ld-input-inner" name="linkaddress" value="{$url}">
            </td>
        </tr>
    {/if}
    <tr>
        <td class="ld-form-item-label">{'ModuleIcon'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            {if $active_icon}
                <div id="active_icon_preview" style="width:  40px;height:40px;">
                    <img src="{$active_icon}" style="width: 40px;height: 40px;">
                </div>
            {/if}
            <input name="active_icon_size" value="1024" type="hidden">
            <input name="active_icon_name" value="{$active_icon_name}" type="hidden">
            <input name="active_icon" accept="image/*" value="{$active_icon_name}" onchange="validateFilename(this);" type="file">
            <input name="active_icon_name_hidden" value="{$active_icon_name}" type="hidden">
            <span style="color: red;line-height: 20px;">{'menuIconUploadSizeTips'|@getFixedLabel}</span>
        </td>
    </tr>
    <tr {if $ENTITYTYPE eq 'customfine'}style="display:none;"{/if}>
        <td class="ld-form-item-label">回传token验证</td>
        <td class="ld-form-item-content">
            {if $AuthCheck eq 'yes'}
                <input type="checkbox" class="second_switch" name="accessTokenCheck" checked="" >
                <a name="addparam" style="padding:5px;">添加参数</span>
            {else}
                <input type="checkbox" class="second_switch" name="accessTokenCheck" >
                <a name="addparam" style="padding:5px; display:none">添加参数</span>
            {/if}
        </td>
    </tr>
    <tr>
        <td class="ld-form-item-label">{'APPLICABLESCOPE'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
        	<div id='view_scope' class="select-input">
				<input type="radio" {if $scope eq 'all'}checked="" {/if} value="all" name="radioUser" id="ALLTHEUSERS" onclick="CustomScope.setAllUser();">
                <label class="padR10" for="ALLTHEUSERS">{'ALLTHEUSERS'|@getFixedLabel}</label>
				<input type="radio" {if $scope eq 'group'}checked="" {/if} undefined="" onclick="CustomScope.setScopeGroup('{$allocateid}')" value="groups" name="radioUser" id="SETBYDEPARTMENT">
                <label class="padR10" for="SETBYDEPARTMENT">{'SETBYDEPARTMENT'|@getFixedLabel}</label>
				<input type="radio" {if $scope eq 'user'}checked="" {/if} undefined="" onclick="CustomScope.setScopeUser('{$allocateid}');" value="users" name="radioUser" id="SETBYUSERS">
                <label class="padR10" for="SETBYUSERS">{'SETBYUSERS'|@getFixedLabel}</label>
				<input type="radio" {if $scope eq 'role'}checked="" {/if} undefined="" onclick="CustomScope.setScopeRole('{$allocateid}');" value="role" name="radioUser" id="SetByRole">
				 <label class="padR10" for="SetByRole">{'SetByRole'|@getFixedLabel}</label>
				<input id="customscope_type" class="templateprintuser" type="hidden" value="{$scope}" name="customscope_type">
				<input id="customscope_ids" class="templateprintuser" type="hidden" value="{$allocateid}" name="customscope_ids">
			</div>
        </td>
    </tr>
</table>
</div>
<script>
    {literal}
    
    {/literal}
</script>