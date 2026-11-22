<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/LoginPolicy.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/Entry_Fields_Access.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/tooltip.js?v={$GLOBALMINVERSION}"></script>
<div class="divPopOverflow">
    <form action="index.php" method="post" name="LoginPolicyform" class="ajax_form">
        <!-- <input type="hidden" name="mode" value="create"> -->
        {if $allocatePopup neq 'yes'}
        <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td colspan="4">
                    <div class="ld-pop-contnet-title-items">
                        <div class="ld-pop-contnet-title-item">{'BASICINFO'|@getFixedLabel}</div>
                    </div>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    <font color="red">*</font>{'RULENAME'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    <input type="text" class="ld-input-inner" id="rulename" name="rulename" value="{$rulename}"/>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    <font color="red">*</font>{'WHETHERTOENABLE'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    <input name="enablestatus" {if $enablestatus eq 'yes'}checked="" {/if} type="checkbox" class="second_switch">
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    {'RULEDESCRIPTION'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content" colspan="3">
                    <textarea type="text" class="ld-textarea-inner" id="description" name="description" value="{$description}">{$description}</textarea>
                </td>
            </tr>
        </table>
        <table id="ruletypeTable" class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td colspan="4">
                    <div class="ld-pop-contnet-title-items">
                        <div class="ld-pop-contnet-title-item">{'RULESETTINGS'|@getFixedLabel}</div>
                    </div>
                </td>
            </tr>
            <tr class="ruletype">
                <td class="ld-form-item-label">
                    <font color="red">*</font>{'RULETYPE'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    <select name="ruletype" class="ld-select-inner" onclick="LoginPolicy.ruletype_change()">
                        <option value="Unlimited" {if $ruletype eq 'Unlimited'}selected{/if}>{'UNLIMITED2'|@getFixedLabel}</option>
                        <option value="WEB" {if $ruletype eq 'WEB'}selected{/if}>{'WEB'|@getFixedLabel}</option>
                        <option value="Mobile " {if $ruletype eq 'Mobile'}selected{/if}>{'MobileTerminal'|@getFixedLabel}</option>
                        <option value="Geographicalregion" {if $ruletype eq "Geographicalregion"}selected{/if}>{'LOCATEMAP'|@getFixedLabel}</option>
                        <option value="IPaddress" {if $ruletype eq 'IPaddress'}selected{/if}>{'IPADDRESS'|@getFixedLabel}</option>
                        {*<option value="MACaddress" {if $ruletype eq 'MACaddress'}selected{/if}>{'WEB'|@getFixedLabel}MAC地址映射</option>
                        <option value="DeviceID" {if $ruletype eq 'DeviceID'}selected{/if}>{'MobileTerminal'|@getFixedLabel}设备ID映射</option>*}
                    </select>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">
                    <font color="red">*</font>{'CONTROLMODE'|@getFixedLabel}
                </td>
                <td class="ld-form-item-content">
                    <select name="controlmode" class="ld-select-inner">
                        <option value="enable" {if $controlmode eq 'enable'}selected{/if}>{'ALLOWEDLOGIN'|@getFixedLabel}</option>
                        <option value="disable" {if $controlmode eq 'disable'}selected{/if}>{'NOTALLOWEDLOGIN'|@getFixedLabel}</option>
                    </select>
                </td>
            </tr>
            </tr>
            {if $typecontent_arr.statusvalue[1] eq ''}
                <tr style="display: {if $ruletype neq 'Geographicalregion'}none{/if};" class="Region_option_0" rowindex="0" rowdeleted="no">
                    <td class="ld-form-item-label">
                        <font color="red">*</font>{'LOCATEDCITY'|@getFixedLabel}
                    </td>
                    <td class="ld-form-item-content region_sel" colspan="3">
                        {if $mode eq 'edit'}
                            {if $ruletype eq 'Geographicalregion'}
                                <select class="ld-select-inner status_sel_0" style="width: 200px;">
                                    {foreach key=index item=item from=$sourcevalue}
                                        <option class="status_opt_0" {if $item eq {$typecontent_arr.statusvalue[0]}}selected{/if}>{$item}</option>
                                    {/foreach}
                                    {$typecontent_arr.statusvalue[0]}
                                </select><select class="ld-select-inner city_sel_0" style="width: 200px;margin-left: 10px;">
                                    {foreach key=index item=cityitem from=$Region_arr[$typecontent_arr.statusvalue[0]]}
                                        <option class="status_opt_{$id}" {if $cityitem eq {$typecontent_arr.typecontent[0]}}selected{/if}>{$cityitem}</option>
                                    {/foreach}
                                    {$typecontent_arr.typecontent[0]}
                                </select><a class="padL10 regiondelete_0" title="{'DELETE'|@getFixedLabel}" onclick="LoginPolicy.deleteregionRow(0)">{'DELETE'|@getFixedLabel}</a>
                            {/if}
                        {/if}
                    </td>
                </tr>
            {/if}
            {if $mode eq 'edit'}
                {if $ruletype eq 'Geographicalregion'}
                    {if $typecontent_arr.statusvalue[1] neq ''}
                        {foreach key=id item=item from=$typecontent_arr.statusvalue}
                            <tr style="display: {if $ruletype neq 'Geographicalregion'}none{/if};" class="Region_option_{$id}" rowindex="{$id}" rowdeleted="no">
                                <td class="ld-form-item-label">
                                    <font color="red">*</font>{'LOCATEDCITY'|@getFixedLabel}
                                </td>
                                <td class="ld-form-item-content region_sel" colspan="3">
                                    <select class="ld-select-inner status_sel_{$id}" style="width: 200px;">
                                        {foreach key=index item=statusitem from=$sourcevalue}
                                            <option class="status_opt_{$id}" {if $statusitem eq {$typecontent_arr.statusvalue[$id]}}selected{/if}>{$statusitem}</option>
                                        {/foreach}
                                    </select><select class="ld-select-inner city_sel_{$id}" style="width: 200px;margin-left: 10px;">
                                        {foreach key=index item=cityitem from=$Region_arr[$typecontent_arr.statusvalue[$id]]}
                                            <option class="status_opt_{$id}" {if $cityitem eq {$typecontent_arr.typecontent[$id]}}selected{/if}>{$cityitem}</option>
                                        {/foreach}
                                    </select><a class="padL10 regiondelete_{$id}" title="{'DELETE'|@getFixedLabel}" onclick="LoginPolicy.deleteregionRow({$id})">{'DELETE'|@getFixedLabel}</a>
                                </td>
                            </tr>
                        {/foreach}
                    {/if}
                {/if}
            {/if}
            <tr id="groupfooter_1" style="display: {if $ruletype neq 'Geographicalregion'}none{/if};">
                <td class="ld-form-item-label"></td>
                <td class="ld-form-item-content" colspan="3"><a href="javascript:void(0);" onclick="LoginPolicy.addregionRow()">{'ADDLINE'|@getFixedLabel}</a></td>
            </tr>
            {* IP地址填写区域 *}
            <tr style="display: {if $ruletype neq 'IPaddress'}none{/if};" class="IPaddress_option">
                <td class="ld-form-item-label">
                    <font color="red">*</font><span class="valign-middle lineheight18">{'IPADDRESS'|@getFixedLabel}</span><i class="ld-fonticon ld-fonticon-help valign-middle lineheight18 tip-items-list" data-tip="{'SourseSupports'|@getFixedLabel}<br>{'SingleIPFormat'|@getFixedLabel}<br>{'CIDRFormat'|@getFixedLabel}" data-direction="top" data-type="position"></i>
                </td>
                <td class="ld-form-item-content" colspan="3">
                    <div class="IP_area ld-textarea-inner marB10">
                        <div id="tagContainer" style="max-width: 600px;white-space: normal;">
                        {if $mode eq 'edit'}
                            {if $ruletype eq 'IPaddress'}
                                <input type="hidden" value="{$typecontent_arr[1]}">
                                {foreach key=id item=typecontent from=$typecontent_arr.typecontent}
                                    {if $typecontent neq ''}
                                        <span class="tag" style="border-left-color: #1c61da;" value="{$typecontent}">{$typecontent}
                                            <button class="tag_delbtn" onclick="LoginPolicy.deleteIPTag(this)" title="{'DELETE'|@getFixedLabel}">×</button>
                                        </span>
                                    {/if}
                                {/foreach}
                            {/if}
                        {/if}

                        <input type="text" id="tagInput" placeholder="{'ENTERTOADDIPADDRESS'|@getFixedLabel}" style="border: none;line-height: 32px;width: 315px;" onkeyup="value=value.replace(/[^0-9\#\.\/]/g,'')"></div>
                    </div>
                    <a onclick="LoginPolicy.addcurrentIP()">{'ADDYOURIP'|@getFixedLabel}</a>
                </td>
            </tr>
            {* MAC地址映射 *}
            {*<tr style="display: {if $ruletype neq 'MACaddress'}none{/if};">
                <td colspan="2" align="left" tag="firstnode" id="categoryAdvsear" style="line-height:46px !important;padding-left: 20px;">
                    <input class="saveauto" type="button" href="javascript:void(0);" name="advancesearchpop" value="添加映射" onclick="fun_ProductTopic.getInstance().advancesearchpop();">
                </td>
                <td colspan="2" align="right">
                    <div class="ld-listview-basicsearch" style="margin-right: 20px;width: 300px;">
                        <input type="text" class="commonSelectPop gwidth100 padR40" onkeyup="fun_ProductTopic.getInstance().basicsearch()" name="search_text" value="" autocomplete="off" style="border-radius: 4px;">
                        <b style="position: absolute;right:30px;top:0;cursor: pointer" class="ld-icon-clearsearch" onclick="fun_ProductTopic.getInstance().clearPopupLayerSearch(this);"></b>
                        <b class="categorysear-search ld-listview-search" id="listview-search" name="listview-search" onclick="fun_ProductTopic.getInstance().basicsearch()"></b>
                    </div>
                </td>
            </tr>
            <tr style="height: 80px; display: {if $ruletype neq 'MACaddress'}none{/if};" class="MACaddress_option">
                <td colspan="4" style="padding: 20px;">
                    <table name="usermac_loginpolicy" class="ControlTable1 listEntries fir-center listSettingData" width="100%" cellspacing="1" cellpadding="0" border="0">
                        <tr>
                            <th style="width:15%;">用户名</th>
                            <th style="width:15%;">姓名</th>
                            <th style="width:60%;">MAC 地址</th>
                            <th style="width:10%;">操作</th>
                        </tr>
                        <tbody id="tableBody">
                            <tr class="ld-category-draggable lvtColData"  onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),'on')" >
                                <td style="width:15%;">用户名</th>
                                <td style="width:15%;">姓名</th>
                                <td style="width:60%;">MAC 地址</th>
                                <td style="width:10%;">操作</th>
                            </tr>
                        </tbody>
                    </table>
                    <div class="PageDiv0">
                        <div class="ld-flex-start" style="position: relative;">
                            <div class="ld-pagenum-div"> 共 7 条</div>
                            <div class="ld-pagenum-div">
                                <div class="ld-pagenum-value outline bgwhite">
                                    <div id="pagenum_show">1/1&nbsp;&nbsp;<b class="down"></b><b style="visibility: hidden">1</b></div>
                                    <input type="hidden" id="pagenum"
                                        onchange="getListViewEntries_js('Accounts','parenttab=Parent Accounts&amp;start='+this.value+'');"
                                        name="pagenum" value="1" autocomplete="off">
                                    <div class="ld-pagenum-list">
                                        <ol class="D_more_menua">
                                            <li class="selected" onclick="ldSelectPageNum(this,1,1)"><a>1/1</a></li>
                                        </ol>
                                    </div>
                                </div>
                            </div>
                            <div class="ld-pagenum-div icon-left-inactive"><b class="icon-pre-next cursorNotAllowed"></b></div>
                            <div class="ld-pagenum-div icon-right-inactive"><b class="icon-pre-next cursorNotAllowed"></b></div>
                        </div>
                    </div>
                </td>
            </tr>*}
        </table>
        {/if}
        <table class="ld-public-content-small{if $allocatePopup neq 'yes'} padT8{/if}" id="Scopeselect" style="display: {if $ruletype eq 'MACaddress'}none{/if};" border="0" cellpadding="0" cellspacing="0" width="100%">
            {if $allocatePopup neq 'yes'}
            <tr>
                <td colspan="4">
                    <div class="ld-pop-contnet-title-items">
                        <div class="ld-pop-contnet-title-item">{'APPLICABLESCOPE'|@getFixedLabel}</div>
                    </div>
                </td>
            </tr>
            {/if}
            <tr>
                <td class="ld-form-item-content padL0 select-input" id='view_scope' selectvalue="" selected_user="">
                    <label class="padL0 padR10">
                        {'APPLICABLESCOPE'|@getFixedLabel}
                    </label>
                    <input type="radio" {if $applicablescope eq 'all'}checked="" {/if} checked value="all" name="radioUser" id="ALLTHEUSERS" onclick="LoginPolicy.setScopeFields_Access('all',{$ruleid})">
                    <label class="padR10" for="ALLTHEUSERS">{'ALLTHEUSERS'|@getFixedLabel}</label>
                    <input type="radio" {if $applicablescope eq 'group'}checked="" {/if} onclick="LoginPolicy.setScopeFields_Access('group',{$ruleid})" value="group" name="radioUser" id="SETBYDEPARTMENT">
                    <label class="padR10" for="SETBYDEPARTMENT">{'SETBYDEPARTMENT'|@getFixedLabel}</label>
                    <input type="radio" {if $applicablescope eq 'user'}checked="" {/if} onclick="LoginPolicy.setScopeFields_Access('user',{$ruleid})" value="user" name="radioUser" id="SETBYUSERS">
                    <label class="padR10" for="SETBYUSERS">{'SETBYUSERS'|@getFixedLabel}</label>
                    <input type="radio" {if $applicablescope eq 'role'}checked="" {/if} onclick="LoginPolicy.setScopeFields_Access('role',{$ruleid})" value="role" name="radioUser" id="SetByRole">
                    <label class="padR10" for="SetByRole">{'SetByRole'|@getFixedLabel}</label>
                    <input id="customscope_type" class="loginpolicyuser" type="hidden" value="{$applicablescope}" name="customscope_type">
                    <input id="customscope_ids" class="loginpolicyuser" type="hidden" value="{$allocateid}" name="customscope_ids">
                </td>
            </tr>
        </table>
    </form>
</div>
<style>
    .IPaddress_option{
        /* margin: 10px; */
    }
    .IP_area{
        height: auto;
        min-height: 100px;
        background-color: #fbfeff;
        border: 1px solid #dbdbdb;
        border-radius: 4px;
        padding: 0 8px;
    }
    .tag {
        display: inline-block;
        padding: 3px 6px;
        margin: 5px 3px;
        background-color: #ffffff;
        border-radius: 4px;
        border-top: 1px solid #dbdbdb;
        border-bottom: 1px solid #dbdbdb;
        border-right: 1px solid #dbdbdb;
        border-left-width: 5px;
        border-left-style: solid;
        border-left-color: #da1c1c;
        font-weight: bolder;
        line-height: 16px;
    }
    .tag_delbtn{
        border: none;
        background-color: #ffffff;
        font-weight: bolder;
        margin-left: 3px;
        cursor: pointer;
        font-size: 14px;
    }
    .regiondelete{
        cursor: pointer;
    }
</style>