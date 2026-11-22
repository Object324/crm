{if $MODE neq 'edit'}
    <div class="main_grid_top">
        <div class="grid-view-title lfloat overflow-hidden">
          <span class="grid-view-name dinline-block lfloat">
            {'LBL_EXPRESS100_SETTINGS'|@getFixedLabel}
          </span>
        </div>
        <div class="grid_tool">
            <div class="displayflex">
                <a href="javascript:;" class="ld-button ld-button-primary" onclick="editExpress100Setting()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
            </div>
        </div>
    </div>
    <div class="main_grid_box">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float">
                <table border="0" cellspacing="0" cellpadding="0" width="100%" class="settingTable">
                    <tr>
                        <th colspan="2">{'LBL_EXPRESS100_SETTINGS'|@getFixedLabel}</th>
                    </tr>
                    <tr id="setting_2">
                        <td width="20%"><span>{'EXPRESS_QUERY_COMPONENT_INTERFACE_MODE'|@getFixedLabel}</span></td>
                        <td width="80%"><span>{if {$KEYTYPE} eq 'default'}{'DETAIL_QUERY_INTERFACE'|@getFixedLabel}{else}{'SELF_PURCHASE_EXPRESS_100_INTERFACE'|@getFixedLabel}{/if}</span></td>
                    </tr>
                    {if $KEYTYPE neq 'default'}
                        <tr id="setting_3">
                            <td><span title="">{'EXPRESS_100_INTERFACE_KEY'|@getFixedLabel}</span> </td>
                            {if $KEY neq ''}
                                <td><span>*********</span></td>
                            {else}
                                <td><span></span></td>
                            {/if}
                        </tr>
                        <tr id="setting_4">
                            <td><span title="">{'EXPRESS_100_INTERFACE_CUSTOMER'|@getFixedLabel}</span> </td>
                            {if $CUSTOMER neq ''}
                                <td><span>*********</span></td>
                            {else}
                                <td><span></span></td>
                            {/if}
                        </tr>
                    {/if}
                </table>
                <div class="listRloesHelp">
                    <font color="red">{'TIP'|@getFixedLabel}：</font>
                    <ul>
                        <li>{'KUAIDI100USETIPSONE'|@getFixedLabel}</li>
                        <li>{'KUAIDI100USETIPSTHREE'|@getFixedLabel}</li>
                        <li>{'KUAIDI100USETIPSTWO'|@getFixedLabel}</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
{else}
    <div class="divPopOverflow">
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr id="setting_2">
            <td class="ld-form-item-label"><span title="">{'EXPRESS_QUERY_COMPONENT_INTERFACE_MODE'|@getFixedLabel}</span> </td>
            <td class="ld-form-item-content">
                <select name="display_type" id="display_type" class="ld-select-inner" onChange="selectExpress100KeyType(this)">
                    <option value="default" {if $KEYTYPE eq 'default'}selected="true"{/if}>{'DETAIL_QUERY_INTERFACE'|@getFixedLabel}</option>
                    <option value="self_purchase" {if $KEYTYPE eq 'self_purchase'}selected="true"{/if} >{'SELF_PURCHASE_EXPRESS_100_INTERFACE'|@getFixedLabel}</option>
                </select>
            </td>
        </tr>
        <table class="ld-public-content-small padT0" id="kuaiDi_100_Setting" border="0" cellpadding="0" cellspacing="0" width="100%" {if $KEYTYPE eq 'default'}hidden{/if}>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font><span >{'EXPRESS_100_INTERFACE_KEY'|@getFixedLabel}</span> </td>
                <td class="ld-form-item-content">
                    <input class="ld-input-inner" value="" name="key"/>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label"><font color="red">*</font><span >{'EXPRESS_100_INTERFACE_CUSTOMER'|@getFixedLabel}</span> </td>
                <td class="ld-form-item-content">
                    <input class="ld-input-inner" value="" name="customer"/>
                </td>
            </tr>
        </table>

    </table>
    </div>
{/if}

