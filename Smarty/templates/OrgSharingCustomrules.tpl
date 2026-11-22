<input type="hidden" name="customrule_id" id="customrule_id" value="{$CUSTOMRULE_ID}" />
<div class="divPopOverflow">
<form action="index.php" method="post" name="orgsharingcustomrules">
    <div class="ld-pop-container">
        <div class="ld-pop-contnet-title-items">
            <div class="ld-pop-contnet-title-item">{'AUTOSHARETO'|@getFixedLabel}（{'CUSTOMSHARESELECTATLEASTONE'|@getFixedLabel}）</div>
        </div>
    </div>
    <table class="ld-public-content-small padT0" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr id="group_tr" >
            <td class="ld-form-item-label">{'SPECIFYGROUP'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <div style="position:relative;">
                    <input type="text" id="groupid_name" readonly="true" name="groupid_name" class="ld-input-inner lfloat" style="width:50%;display:-webkit-inline-box;text-overflow:ellipsis;overflow:hidden;" onclick="approve_selectgroup();" value="{$DATA.GROUPNAME}"/>
                    <a class="icon-homeimg icon-select lfloat" href="javascript:;" style="margin-top: 7px;margin-left: 7px;" title="{'SELECT'|@getFixedLabel}" onclick="approve_selectgroup();"></a>
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" style="margin-top: 4px;" title="{'CLEAR'|@getFixedLabel}" onclick="ld('#groupid_name').val('');ld('#groupid').val('');">
                    <input type="hidden" name="groupid" id="groupid" value="{$DATA.GROUPID}"/>
                </div>
            </td>
        </tr>
        <tr id="username_tr">
            <td class="ld-form-item-label">{'SPECIFYUSER'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <div style="position:relative;">
                    <input type="text" id="userid_name" readonly="true" name="userid_name" class="ld-input-inner lfloat" style="width:50%;display:-webkit-inline-box;text-overflow:ellipsis;overflow:hidden;" onclick="approve_selectuser();" value="{$DATA.USERNAME}"/>
                    <a class="icon-homeimg icon-select lfloat" href="javascript:;" style="margin-top: 7px;margin-left: 7px;" title="{'SELECT'|@getFixedLabel}" onclick="approve_selectuser();"></a>
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" style="margin-top: 4px;" title="{'CLEAR'|@getFixedLabel}" onclick="ld('#userid_name').val('');ld('#userid').val('');">
                    <input type="hidden" name="userid" id="userid" value="{$DATA.USERID}"/>
                </div>
            </td>
        </tr>
        <tr id="role_name_tr" >
            <td class="ld-form-item-label">{'SPECIFYROLE'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input class="ld-input-inner" type="text" name="role_name" id="role_name" readonly="true" style="width:50%;" value="{$DATA.PROFILENAME}" onclick="selectPopupProfile('user_role','{'ROLES'|@getFixedLabel}')"/>
                <a class="icon-homeimg icon-select" href="javascript:selectPopupProfile('user_role','{'SPECIFYROLE'|@getFixedLabel}');"></a>
                <input class="icon-homeimg icon-clear inpb-reset" type="button" style="margin-top: 1px;margin-left: -3px;" title="{'CLEAR'|@getFixedLabel}" onclick="ld('#role_name').val('');ld('#user_role').val('');">
                <input type="hidden" name="user_role" id="user_role" value="{$DATA.PROFILEID}"/>
            </td>
        </tr>
    </table>
    <div class="ld-pop-container padT8">
        <div class="ld-pop-contnet-title-items">
            <div class="ld-pop-contnet-title-item">{'SHAREDPERMISSIONS'|@getFixedLabel}</div>
        </div>
    </div>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding: 0 24px;">
        <tr>
            <td>
                <div style="position: relative;float: left;" class="select-input">
                    <input type="radio" id="sharecustomrule_permission_read" name="sharecustomrule_permission"  value="read" {if $DATA.permission eq 'read' || $DATA.permission eq ''}checked{/if}>
                    <label for="sharecustomrule_permission_read"> {'Read Only'|@getFixedLabel}</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <input type="radio" id="sharecustomrule_permission_write" name="sharecustomrule_permission" value="write" {if $DATA.permission eq 'write'}checked{/if}>
                    <label for="sharecustomrule_permission_write">{'Read and write'|@getFixedLabel}</label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                </div>
            </td>
        </tr>
    </table>
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/advancefilter.js"></script>
    <input type="hidden" name="advft_criteria" id="advft_criteria" value="" />
    <input type="hidden" name="advft_criteria_groups" id="advft_criteria_groups" value="" />
    <div class="ld-pop-container padT28">
        <div class="ld-pop-contnet-title-items">
            <div class="ld-pop-contnet-title-item">{'SHARINGCONDITIONS'|@getFixedLabel}（{'NOCONDITIONSSET'|@getFixedLabel}）</div>
        </div>
    </div>
    <div name='adv_filter_div'>
        <div style="width: 100%;padding: 0 24px 20px;">
            <div style="background-color: #fff;padding-right: 0px;width: 100%" class="advanceFilterNoDashedDiv" name="pop_adv_filter_div" id="pop_adv_filter_div" >
                <div name="advanceFilterDashedDiv" class="advanceFilterDashedDiv">
                    <div name="advanceFilterGroupAddBtn" class="advanceFilterGroupAddBtn">
                        <i tag="addGroup" class="ld-fonticon ld-fonticon-add"></i>
                        <span tag="addGroup" style="padding-left: 4px">{'NEWCOMBINATION'|@getFixedLabel}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</form>
</div>