<!--修改编码格式:统一编码：UTF-8-->
<form action="index.php" method="post" name="selectmemberform" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Users">
    <input type="hidden" name="action" value="DeleteProfile">
    <input type="hidden" name="delete_role_id" value="{$PROFILEID}">
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    {assign var=entries value=$CFENTRIES}
    <table class="ld-public-content-small" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class="ld-form-item-label">{'TDAC'|@getFixedLabel}</td>
            <td class="ld-form-item-content">{$PROFILE_NAME}</td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'LBL_TRANSFER_USER_ROLE'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select name="profileid" style="display: none;">
                    {foreach name=profile item=profileinfo from =$PROINFO}
                        <option value="{$profileinfo.profileid}" >{$profileinfo.profilename}{$profileid}</option>
                    {/foreach}
                </select>
                <div name="dv_chzn_profileid" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'profileid')">
                    <a class="chzn-single" onclick="com_img_change(event,'profileid')" href="javascript:void(0)" tabindex="-1" name="cmb_a_profileid">
                        <input class="ld-select-inner-input" type="text" autocomplete="off" tabindex="0"  name='cmb_span_optiontext_profileid' onclick="cmb_picklist_end_foucs(event,'profileid')" onKeyUp="com_chosen(event,'profileid')" value="">
                        <input name="profileid" type="hidden" tabindex="l" fieldonly="0" value="" style="display:none">
                        <div>
                            <b></b>
                        </div>
                    </a>
                    <div style=" left:-9000px;top: 32px;" class="chzn-drop" name='dv_drop_profileid' >
                        <ul class="chzn-results" name="cmb_ul_profileid">
                            {assign var="i" value=0}
                            {foreach key=profile item=profileinfo from=$PROINFO }
                                <li style="" class="active-result" name="dv_chzn_{$i}_profileid" onclick="cmb_liclick('{$profileinfo.profileid}','profileid')" onmouseover="cmb_limouseover(event,'profileid')">{$profileinfo.profilename}{$profileid}</li>
                                {assign var="i" value=$i+1}
                            {/foreach}
                            <li style="" class="" name="li_chzn_profileid" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                        </ul>
                    </div>
                </div>
            </td>
        </tr>
    </table>
</form>