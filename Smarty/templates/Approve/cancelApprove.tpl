{* 审批日志暂时注释
<div name="approvelog_scroll" style="max-height: 250px;overflow: auto;border-bottom:2px solid #F1F1F1;margin-bottom:10px;">
<div style="margin: 3px 10px 10px 10px;"><span style="font-size: 13px;">{'approvelog'|@getFixedLabel}</span></div>
<div name="approvelog" >{include file='Approve/ApproveLogEntriesNew.tpl'}</div>
<div name="submitapprovelog" style="display:none;"></div>
</div>
*}
<form action="index.php" method="post"  name="frmcancelapprove">
    <input type="hidden" name="module" value="Approve"/>
    <input type="hidden" name="action" value="cancelApprove"/>
    <input type="hidden" name="record" value="{$RECORD}"/>
    <input type="hidden" name="fld_module" value="{$BLOCK}"/>
    <input type="hidden" name="concurrentidStepCount_cancel"/>
    <div id='subappcontent'>
        <table class="" border="0" cellpadding="0" cellspacing="0" width="100%">
            <input type="hidden" name="curapproveid" value="{$curapproveid}"/>
            {if $APPROVESTATUS neq 'Delete'&&$APPROVESTATUS neq 'NONE_APPROVE'}
                <tr>
                    <td class="ld-form-item-content select-input padL0" colspan="4">
                        <input type="radio" id="cancelapprovetype0" name="cancelapprovetype" class="" value='0' checked/>
                        <label for="cancelapprovetype0">{'APPROVE_CANCEL_BACKUP'|@getFixedLabel}{$APPROVESTATUS}</label>
                    </td>
                </tr>
                {if $ISADMIN eq 'yes' || $HAVECANCELPROFILE eq 'yes'}
                    <tr>
                        <td class="ld-form-item-content select-input padL0" colspan="4">
                            <input type="radio" id="cancelapprovetype3" name="cancelapprovetype"  class="" value='3'/>
                            <label for="cancelapprovetype3">{'APPROVERETURNORIGINAL'|@getFixedLabel}</label>
                        </td>
                    </tr>
                    <tr>
                        <td class="ld-form-item-content select-input padL0" colspan="3">
                            <input type="radio" id="cancelapprovetype1" name="cancelapprovetype" class="" value='1'/>
                            <label style="width: 209px;display: inline-block;" for="cancelapprovetype1">{'APPROVE_CANCEL_BACKAPPROVE'|@getFixedLabel}</label>
                            <select name="cancel_curprocessid" class="ld-select-inner width200 marL10" style="display:none;margin-top: -8px;">
                                <option value="{$APPROVEID}">{$curprocessname}</option>
                            </select>
                            <span class="select-input marL10" name="span_urgent" tag="urgent1" style="display:none;margin-top: -8px;">
                                <input type="checkbox" name="urgent"><label>{'UrgentApproval'|@getFixedLabel}</label>
                            </span>
                        </td>
                        <td tag="td_curprocess">
                        </td>
                    </tr>
                    <tr name="tr_process_1" tag="tr_process" style="display:none">
                        <td colspan="4">
                            <table class="" name="procecess_table_1" width="100%">
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td id="cancelapprovetype2_td1" class="ld-form-item-content select-input padL0" style="width: 230px;">
                            <input type="radio" id="cancelapprovetype2" name="cancelapprovetype" class="" value='2'/>
                            <label for="cancelapprovetype2">{'APPROVE_CANCEL_SELECTAPPROVE'|@getFixedLabel}</label>
                        </td>
                        <td id="cancelapprovetype2_td2" class="ld-form-item-content">
                            <select name="approveopts" class="commonSelectPop" style="width: 150px;">
                                {foreach item=approve from=$APPROVE name='approvestepeach'}
                                    <option value="{$approve.approveid}">{$approve.approvename}</option>
                                {/foreach}
                            </select>
                        </td>
                        <td id="cancelapprovetype2_td3" class="ld-form-item-content">
                            <span tag="urgent2" name="span_urgent" style="display:none">
                                <input type="checkbox" id="urgent" name="urgent">
                                <label for="urgent">{'UrgentApproval'|@getFixedLabel}</label>
                            </span>
                        </td>
                        <td tag="td_selectprocess">
                        </td>
                    </tr>
                    <tr name="tr_process_2" tag="tr_process" style="display:none">
                        <td colspan="4">
                            <table class="" name="procecess_table_2" width="100%">
                            </table>
                        </td>
                    </tr>
                {/if}
            {elseif $APPROVESTATUS eq "NONE_APPROVE"||$APPROVESTATUS eq 'Delete'}
                <tr>
                    <td class="ld-form-item-content select-input padL0" colspan="4">
                        <input type="radio" id="cancelapprovetype3" name="cancelapprovetype" checked=""  class="" value='3'/>
                        <label for="cancelapprovetype3">{'APPROVERETURNORIGINAL'|@getFixedLabel}</label>
                    </td>
                </tr>
                <tr>
                    <td class="ld-form-item-content select-input padL0" colspan="2">
                        <input type="radio" id="cancelapprovetype2" name="cancelapprovetype" class="" value='2'/>
                        <label for="cancelapprovetype2">{'APPROVE_CANCEL_SELECTAPPROVE'|@getFixedLabel}</label><!--使用新的流程重现流转-->
                    </td>
                    <td tag="td_selectprocess" class="ld-form-item-content" colspan="2">
                        <select name="approveopts" class="commonSelectPop" style="width: 150px;">
                            {foreach item=approve from=$APPROVE name='approvestepeach'}
                                <option value="{$approve.approveid}">{$approve.approvename}</option>
                            {/foreach}
                        </select>
                        <span name="username_approver_2" style="display:none" >&nbsp;&nbsp;&nbsp;{'APPROVER'|@getFixedLabel}
                            {* eidtor:gyq_14 reason:修改id *}
                            <input type="text" class="btn-radius-system" {if $CurStepspecifyapproverid eq 0}   {else} style="disabled="true"{/if} name="userid_name_2" readonly="true" style="width:25%" id="userid_name_2" value="{$nextsetpbyuser}"  />
                            <a name="before_approve_select_2" class="icon-homeimg icon-select" style="" href="javascript:;" title="选择" ></a>
                        </span>
                    </td>
                </tr>
                <tr name="tr_process_2" tag="tr_process" style="display:none">
                    <td colspan="4">
                        <table class="" name="procecess_table_2" width="100%">
                        </table>
                    </td>
                </tr>
            {else}
                <tr>
                    <td class="ld-form-item-content select-input padL0" colspan="2">
                        <input type="hidden" id="cancelapprovetype2" id="cancelapprovetype" name="cancelapprovetype" value="2" />
                        <label for="cancelapprovetype2">{'APPROVE_CANCEL_SELECTAPPROVE'|@getFixedLabel}</label>
                    </td>
                    <td tag="td_selectprocess" class="ld-form-item-content" colspan="2">
                        <select name="approveopts" class="commonSelectPop" style="width: 150px;" >
                            {foreach item=approve from=$APPROVE name='approvestepeach'}
                                <option value="{$approve.approveid}">{$approve.approvename}</option>
                            {/foreach}
                        </select>
                        <span name="username_approver_2" >&nbsp;&nbsp;&nbsp;{'APPROVER'|@getFixedLabel}
                            {* eidtor:gyq_14 reason:修改id *}
                            <input type="text" class="btn-radius-system" {if $CurStepspecifyapproverid eq 0}   {else} style="disabled="true"{/if} name="userid_name_2" readonly="true" style="width:25%" id="userid_name_2"   />
                            <a name="before_approve_select_2" class="icon-homeimg icon-select" style="" href="javascript:;" title="选择" ></a>
                        </span>
                    </td>
                </tr>
            {/if}
            <tr>
                <td class="ld-form-item-content padT28 padL0" colspan="4">
                    <font name="markrequire"  {if $APPROVEREMARKREQUIRE neq 'yes'}style="display:none;"{/if} color="red">*</font>
                    <input name="requiretext" stepvalue="{$APPROVEREMARKREQUIRE}" value="{$APPROVEREMARKREQUIRE}" type="hidden">
                    <b>{'APPROVALSUGGESTION'|@getFixedLabel}</b><br />
                    <textarea name="description" class="ld-textarea-inner marT16" rows="4"></textarea>
                </td>
            </tr>
        </table>
        <input type="hidden" name="approveuserid" id="approveuserid" value="{$NEXTSETPBY}"/>
    </div>
</form>