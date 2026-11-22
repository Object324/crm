{if $mode eq 'view' || $mode eq 'saveSetting' || $mode eq 'saveTax'}
    <script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/PiaozoneSetting.js?v={$GLOBALMINVERSION}"></script>
    <form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
        <input type="hidden" name="module" value="Settings"/>
        <input type="hidden" name="parenttab" value="Settings"/>
        <input type="hidden" name="action"/>
        <div class="main_grid_top">
            <div class="grid-view-title lfloat overflow-hidden">
                <span class="grid-view-name dinline-block lfloat">{'PiaozoneSettingListTile'|@getFixedLabel}</span>
            </div>
            <div class="grid_tool">
                <div class="displayflex">
                    <a href="javascript:;" class="ld-button ld-button-primary" onclick="PiaozoneSetting.getInstance().editSetting()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
                    <a href="javascript:;" class="ld-button" onclick="PiaozoneSetting.getInstance().clearSetting()" title="{'LOGOUTS'|@getFixedLabel}">{'LOGOUTS'|@getFixedLabel}</a>
                </div>
            </div>
        </div>
        <div class="main_grid_box">
            <div class="grid-analysis-box">
                <div class="grid-analysis-header">
                </div>
                <div class="cont_wrap clear_float">
                    <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <th colspan="2">{'LBL_INTERFACE_SETTINGS'|@getFixedLabel}</th>
                        </tr>
                        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                            <td width="20%">{'PiaozoneMethod'|@getFixedLabel}</td>
                            <td width="80%">{'UsePurchaseFlagshipInvoice'|@getFixedLabel}</td>
                        </tr>
                        <tr class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                            <td>{'InvoiceLoginAddress'|@getFixedLabel}</td>
                            <td>{$service_url}</td>
                        </tr>
                        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                            <td>{'LoginAccount'|@getFixedLabel}</td>
                            <td>{$user}</td>
                        </tr>
                        <tr class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                            <td>appID</td>
                            <td>{$appId}</td>
                        </tr>
                        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                            <td>appSecret</td>
                            <td>{$appSecret}</td>
                        </tr>
                        <tr class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                            <td>{'TenantId'|@getFixedLabel}</td>
                            <td>{$accountId}</td>
                        </tr>
                        <tr class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                            <td>{'OrganizationCode'|@getFixedLabel}</td>
                            <td>{$orgNumber}</td>
                        </tr>
                    </table>
                    <div id="view_companyInfo">
                        {include file='Settings/PiaozoneSettingCommon.tpl'}
                    </div>
                </div>
            </div>
        </div>
    </form>

{elseif $mode eq 'editSetting'}
    <form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
        <input type="hidden" name="module" value="Settings"/>
        <input type="hidden" name="parenttab" value="Settings"/>
        <input type="hidden" name="ajax" value="save"/>
        <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td colspan="2">
                    <div class="ld-pop-contnet-title-items">
                        <div class="ld-pop-contnet-title-item">{'LBL_INTERFACE_SETTINGS'|@getFixedLabel}</div>
                    </div>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label" style="width: 205px;">{'PiaozoneMethod'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <p>{'UsePurchaseFlagshipInvoice'|@getFixedLabel}</p>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>{'InvoiceLoginAddress'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <input tag="required" type="text" size="50" name="service_url" id="service_url" value="{$service_url}" class="ld-input-inner">
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>{'LoginAccount'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <input tag="required" type="text" size="100" name="user" id="user" value="{$user}" class="ld-input-inner">
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>appId</td>
                <td class="ld-form-item-content">
                    <input tag="required" type="text" size="100" name="appId" id="appId" value="{$appId}" class="ld-input-inner">
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>appSecret</td>
                <td class="ld-form-item-content">
                    <input tag="required" type="text" size="100" name="appSecret" id="appSecret" value="{$appSecret}" class="ld-input-inner">
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>{'TenantId'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <input tag="required" type="text" size="100" name="accountId" id="accountId" value="{$accountId}" class="ld-input-inner">
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>{'OrganizationCode'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <input tag="required" type="text" size="100" name="orgNumber" id="orgNumber" value="{$orgNumber}" class="ld-input-inner">
                </td>
            </tr>
        </table>
        <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td colspan="2">
                    <div class="ld-pop-contnet-title-items">
                        <div class="ld-pop-contnet-title-item">{'InvoiceHeader'|@getFixedLabel}</div>
                    </div>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label" colspan="2">
                    <div class="ld-pop-container ld-table-container ld-table-container-lines" style="padding:unset;padding-bottom: 15px" id="edit_companyInfo">
                        {include file='Settings/PiaozoneSettingCommon.tpl'}
                    </div>
                </td>
            </tr>
        </table>
    </form>


{elseif $mode eq 'createTax'}
    <form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
        <input type="hidden" name="module" value="Settings"/>
        <input type="hidden" name="parenttab" value="Settings"/>
        <input type="hidden" name="ajax" value="save"/>
        <table class="ld-public-content-paddingright" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>{'COMPANYNAME'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <input tag="required" type="text" size="50" name="name" id="name" value="{$companyName}" class="ld-input-inner">
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font>{'CompanyTaxID'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <input tag="required" type="text" size="100" name="taxNo" id="taxNo" value="{$taxNo}" class="ld-input-inner">
                </td>
            </tr>

            <tr>
                <td class="ld-form-item-label">{'APPLICABLESCOPE'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <div id='view_scope' class="select-input" style="margin: 7px 0">
                        <input type="radio" {if $scopeType eq 'all'}checked={/if}  value="all" id="alltheuser" name="radioUser" tag="edit" onclick="PiaozoneSetting.getInstance().setScopeValue(this,'all')">
                        <label class="padR10" for="alltheuser">{'ALLTHEUSERS'|@getFixedLabel}</label>
                        <input type="radio" {if $scopeType eq 'group'}checked{/if} onclick="PiaozoneSetting.getInstance().setScopeValue(this,'group')" id="selectgroup"  tag="edit" scopeType="group" name="radioUser">
                        <label class="padR10" for="selectgroup">{'SETBYDEPARTMENT'|@getFixedLabel}</label>
                        <input type="radio" {if $scopeType eq 'user'}checked{/if} onclick="PiaozoneSetting.getInstance().setScopeValue(this,'user')" id="selectuser"  tag="edit" scopeType="user" name="radioUser" >
                        <label class="padR10" for="selectuser">{'SETBYUSERS'|@getFixedLabel}</label>
                        <input type="radio" {if $scopeType eq 'role'}checked{/if} onclick="PiaozoneSetting.getInstance().setScopeValue(this,'role')" id="selectrole"  tag="edit" scopeType="role" name="radioUser">
                        <label class="padR10" for="selectrole">{'SetByRole'|@getFixedLabel}</label>
                        <input type="hidden" value="{$scopeType}" id="scopeType" name="scopeType">
                        <input type="hidden" value="{$scopeValue}" id="scopeValue" name="scopeValue">
                    </div>
                </td>
            </tr>

        </table>

    </form>


{elseif $mode eq 'setTaxScope'}
    <form action="index.php" method="post" name="company" onsubmit="puyoungJS_DialogBox.block();">
        <input type="hidden" name="module" value="Settings"/>
        <input type="hidden" name="parenttab" value="Settings"/>
        <input type="hidden" name="ajax" value="save"/>
        <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td class="ld-form-item-label">{'APPLICABLESCOPE'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <div id='view_scope' class="select-input" style="margin: 7px 0">
                        <input type="radio" {if $scopeType eq 'all'}checked={/if} value="all" id="alltheuser" name="radioUser" tag="view" onclick="PiaozoneSetting.getInstance().setScopeValue(this,'all')">
                        <label class="padR10" for="alltheuser">{'ALLTHEUSERS'|@getFixedLabel}</label>
                        <input type="radio" {if $scopeType eq 'group'}checked{/if} onclick="PiaozoneSetting.getInstance().setScopeValue(this,'group')" id="selectgroup"  tag="view" value="group" name="radioUser">
                        <label class="padR10" for="selectgroup">{'SETBYDEPARTMENT'|@getFixedLabel}</label>
                        <input type="radio" {if $scopeType eq 'user'}checked{/if} onclick="PiaozoneSetting.getInstance().setScopeValue(this,'user')" id="selectuser" tag="view" value="user" name="radioUser">
                        <label class="padR10" for="selectuser">{'SETBYUSERS'|@getFixedLabel}</label>
                        <input type="radio" {if $scopeType eq 'role'}checked{/if} onclick="PiaozoneSetting.getInstance().setScopeValue(this,'role')" id="selectrole" tag="view" value="role" name="radioUser">
                        <label class="padR10" for="selectrole">{'SetByRole'|@getFixedLabel}</label>
                        <input type="hidden" value="{$scopeType}" id="scopeType" name="scopeType">
                        <input type="hidden" value="{$scopeValue}" id="scopeValue" name="scopeValue">
                    </div>
                </td>
            </tr>
        </table>

    </form>

{/if}