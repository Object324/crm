{if false}
    <div name="approvelog_scroll" style="max-height: 400px;overflow: auto;border-bottom:2px solid #F1F1F1;margin-bottom:10px;float: left;width:50%;">
        <div style="margin: 3px 10px 10px 10px;"><span style="font-size: 13px;">{'approvelog'|@getFixedLabel}</span></div>
        {include file='Approve/ApproveLogEntriesNew.tpl'}
    </div>
{/if}
<form action="index.php" method="post" name="frmapproveblock" class="saveApproveLog">
    <input type="hidden" name="module" value="Approve"/>
    <input type="hidden" name="record" value="{$RECORD}"/>
    <input type="hidden" name="fld_module" value="{$MODULE}"/>
    <input type="hidden" name="returnmodule" value="{$RETURNMODULE}"/>
    <input type="hidden" name="stepid" value="{$STEPID}"/>
    <input type="hidden" name="laststepid" value="{$LASTSTEPID}"/>
    <input type="hidden" name="approveid" value="{$APPROVEID}"/>
    <input type='hidden' name="stepapprovebyids" value=""/>
    <input type="hidden" name="result_aprove_step" id="result_aprove_step" value="0"/>
    <input type="hidden" name="ended" id="ended" value="{$ENDED}"/>
    <input type="hidden" name="countersigner" value="no"/>
    <input type="hidden" name="augmentsinger" value="{$augmentsinger}"/>
    <input type="hidden" name="logconcurrentid" value='{$logconcurrentid}'/>
    <input type="hidden" name="approvelogid" value="{$approvelogid}"/>
    <input type="hidden" name="concurrentidStepCount" value="{$concurrentidStep_arr|sizeof}"/>
    <table class="" border="0" cellpadding="0" cellspacing="0" width="100%" style="margin-top: -16px;" >
        {if $ShowHaigeInfo  eq 'yes'}
            <tr>
                <td class="ld-form-item-content padL0">
                    <label>审批目标</label>
                    <label class="padL10">{$Quota}</label>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-content padL0">
                    <label>剩余审批额度</label>
                    <label class="padL10">{$BalanceApproveMoney}</label>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-content padL0">
                    <label>本单额度</label>
                    <label class="padL10">{$Total}</label>
                </td>
            </tr>
        {/if}
        {if $nextstep_concurrentid>0}
            <tr>
                <td class="ld-form-item-content select-input {if $concurrentidStep_arr|@is_array && sizeof($concurrentidStep_arr) > 0}padB16{/if} padL0" style="padding-top: 16px;" >
                    <input type="radio" id="approvestatus1" name="approvestatus" value="1" {$NEXTCHECK} class="" />
                    <label for="approvestatus1">{'CONTINUEAPPROVALSTEP'|@getFixedLabel}</label>
                </td>
            </tr>
            <tr name="procecess_table_1" style="display:none" tag="tr_process">
                <td>
                    <table class="settingPopTable settingPopTableNoBot" border="0" cellpadding="0" cellspacing="0" width="100%" >
                        {foreach from=$concurrentidStep_arr key=loop item=concurrentstep}
                            <tr>
                                <td align="right" style="width:100px">
                                    <label>{'APPROVALSTEP'|@getFixedLabel}</label>
                                </td>
                                <td class="select-input">
                                    {assign var='leftmarign' value='0px'}
                                    <select name="nextstep_{$loop}" class="ld-select-inner maxWidth160" style="margin-left:{$leftmarign}">
                                        <option value="{$concurrentstep.stepid}">{$concurrentstep.stepname}</option>
                                    </select>
                                    <div id="username_approver_{$loop}" style="display: contents;">
                                        <input type="hidden" name="stepseq_{$loop}" value="{$loop}"/>
                                        <input type="hidden" name="userid_name_{$loop}" id="userid_name_{$loop}" value='{$concurrentstep.approvebyname}'/>
                                        <input type="hidden" name="userid_{$loop}" id="userid_{$loop}" value="{$concurrentstep.approvebyid}"/>
                                        <input type="hidden" name="nextstep_countersigner_{$loop}" value="{$concurrentstep.countersigner}"/>
                                        <input type="hidden" name="nextstep_augmentsinger_{$loop}" value="{$concurrentstep.augmentsinger}"/>
                                        <input type="hidden" name="allow_emptyapprover_{$loop}" value="{$concurrentstep.allow_emptyapprover}"/>
                                    </div>
                                </td>
                            </tr>
                            {*eidt:zkt 1002441 审批，审批人添加框样式优化*}
                            <tr tag="rowdata" id="approvestep_selecttr_{$loop}" name="approvestep_selecttr_{$loop}" >
                                <td align="right" style="width:100px">
                                    <span tag='label_approver_{$loop}' {if $concurrentstep.countersigner eq 'yes' && $concurrentstep.augmentsinger eq ''}style='display:none'{/if}>{'APPROVER'|@getFixedLabel}</span>
                                    <span tag='label_countersigner_{$loop}' {if $concurrentstep.countersigner neq 'yes'} style="display:none"{/if} >{'Countersigner'|@getFixedLabel}</span>
                                </td>
                                <td class="ld-form-item-content">
                                    <div class="pubclear" style="padding:5px 3px 10px 0px;" id="before_approve_selectdiv_{$loop}">
                                        <div class="CCrange selectbar" id="approvers_div_{$loop}" name="approvers_div_{$loop}" tag="ccrange" style="margin-top: 0;width: 100%;border-radius:4px;overflow-y: auto;max-height:90px;">
                                            <ul class="reader-bar-list ld-input-inner-div-items">
                                                {foreach key=userid item=username from=$concurrentstep.stepuseridtonamearr}
                                                    <li class="ld-input-inner-div-item" itemid="approver_{$loop}_{$userid}" title='{$username}'>
                                                        <span class="item-name" >{$username}</span>{if $concurrentstep.specifyapproverid eq 0}<span class="remove-h" onclick="ApproveSelectApproverDiv_remove_oneuser(this,'userid_{$loop}','userid_name_{$loop}');">×</span>{/if}
                                                    </li>
                                                {/foreach}
                                            </ul>
                                            {if $concurrentstep.specifyapproverid eq 0}
                                                <span class="input-tip"><a href="javascript:;" name="select_approvers" tag="approvers" title="{'AddApprover'|@getFixedLabel}" class="choosepublicadmin" class="ld-text-change" style="margin-left: 10px;white-space:nowrap;" onclick="concurrentstepapprove_selectuser({$loop});">{'AddApprover'|@getFixedLabel}</a></span>
                                            {/if}
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        {/foreach}
                    </table>
                </td>
            </tr>
        {elseif ($NEXTSTEPS|@is_array && $NEXTSTEPS|@sizeof >0) || $ENDED eq 0}
            <tr name="procecess_head_1" {if !$NEXTSTEPS|@is_array || $NEXTSTEPS|@sizeof <=0}style="display:none"{/if} >
                <td class="ld-form-item-content select-input padL0" colspan="2" style="padding-top: 16px;">
                    <input type="radio" id="approvestatus1" name="approvestatus" value="1" {$NEXTCHECK} class="" onclick="changenetapproval('{$CurStepspecifyapproverid}')"/>
                    <label for="approvestatus1">{'CONTINUEAPPROVALSTEP'|@getFixedLabel}</label>
                </td>
            </tr>
            <tr name="procecess_table_1" style="display:none" tag="tr_process">
                <td class="padT16">
                    <table class="" border="0" cellpadding="0" cellspacing="0" width="100%" >
                        <tr>
                            <td align="right" style="width:100px">
                                <label>{'APPROVALSTEP'|@getFixedLabel}</label>
                            </td>
                            <td class="padL10">
                                {if $STEP eq 0}
                                    <select name="nextstep_0" class="ld-select-inner" onchange="ApproveStepChange(this)">
                                        {assign var='nextsetpid' value='1'}
                                        {foreach item=step from=$NEXTSTEPS}
                                            <option value="{$step.stepid}" {if $step.stepid eq $NEXTSETPID} {assign var='nextsetpid' value='1'}selected {/if}>{$step.stepname}</option>
                                        {/foreach}
                                    </select>
                                {else}
                                    <input type="text" class="ld-input-inner" name="nextstepname_0" readonly="true" value="{$NEXTSTEPS.0.stepname}">
                                    <input type="hidden"  class="commonTextBoxPop" name="nextstep_0"  value="{$NEXTSTEPS.0.stepid}">
                                {/if}
                                <div id="username_approver" style="display: contents;">
                                    <input type="hidden" name="userid_name_0" id="userid_name_0" value='{$nextsetpbyuser}'/>
                                    <input type="hidden" name="userid_0" id="userid_0" value="{$NEXTSETPBY}"/>
                                    <input type="hidden" name="allow_emptyapprover_0" id="allow_emptyapprover_0" value="{$ALLOWEMPTYAPPROVER}"/>
                                </div>
                            </td>
                        </tr>
                        {*eidt:zkt 1002441 审批，审批人添加框样式优化*}
                        <tr tag="rowdata" id="approvestep_selecttr_0" name="approvestep_selecttr_0" >
                            <td align="right" style="width:100px" class="padT16">
                                {if $nextstep_countersigner eq 'yes'}
                                    <span tag="label_countersigner">{'Countersigner'|@getFixedLabel}</span><span tag="label_approver" style="display:none;">{'APPROVER'|@getFixedLabel}</span>
                                {else}
                                    <span tag="label_approver">{'APPROVER'|@getFixedLabel}</span><span style="display:none;" tag="label_countersigner">{'Countersigner'|@getFixedLabel}</span>
                                {/if}
                            </td>
                            <td class="ld-form-item-content">
                                <div class="pubclear" id="before_approve_selectdiv_0">
                                    <div class="CCrange ld-input-inner-div" id="approvers_div_0" name="approvers_div_0" tag="ccrange" style="overflow-y: auto;max-height:90px;">
                                        <ul class="ld-input-inner-div-items">
                                            {foreach key=userid item=username from=$NEXTSETPIDTONAME}
                                                <li class="ld-input-inner-div-item" itemid="approver_0_{$userid}" title='{$username}'>
                                                    <span class="item-name" >{$username}</span>{if $CurStepspecifyapproverid eq 0}
                                                    <span class="remove-h" onclick="ApproveSelectApproverDiv_remove_oneuser(this,'userid_0','userid_name_0');">×</span>{/if}
                                                </li>
                                            {/foreach}
                                        </ul>
                                    </div>
                                    {if $CurStepspecifyapproverid eq 0}
                                        <div id="before_approve_select" class="ld-text-change" style="right: 10px;{if $CurStepspecifyapproverid eq 0}{else}display:none;{/if}" onclick="concurrentstepapprove_selectuser(0);">
                                            {'replacement'|@getFixedLabel}
                                        </div>
                                    {/if}
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        {/if}
        <!--通过并增加本步骤审批人-->
        {if $augmentsinger eq 'yes' || $augmentsinger eq 'no'}
            <tr>
                <td class="ld-form-item-content select-input padL0"  >
                    <input type="radio" id="approvestatus6" name="approvestatus" value="6" class=""/>
                    <label for="approvestatus6">{'Pleasesettheapprovers'|@getFixedLabel}</label>
                    <div style="display: contents;">
                        <input type="hidden" name="augmentsinger_username" id="augmentsinger_username" value=""/>
                        <input type="hidden" name="augmentsinger_userid" id="augmentsinger_userid" value=""/>
                    </div>
                </td>
            </tr>
            <tr name="procecess_table_6" style="display:none" tag="tr_process">
                <td class="padT16">
                    <table class="" border="0" cellpadding="0" cellspacing="0" width="100%">
                        {*eidt:zkt 1002441 审批，审批人添加框样式优化*}
                        <tr tag="rowdata" id="approvestep_selecttr_augmentsinger" name="approvestep_selecttr_augmentsinger">
                            <td align="right" style="width:100px" class="">
                                <span>{'APPROVER'|@getFixedLabel}</span>
                            </td>
                            <td class="ld-form-item-content">
                                <div class="pubclear" id="before_approve_selectdiv_augmentsinger">
                                    <div class="CCrange ld-input-inner-div" id="approvers_div_augmentsinger" name="approvers_div_augmentsinger" tag="ccrange" style="overflow-y: auto;max-height:90px;">
                                        <ul class="ld-input-inner-div-items">
                                        </ul>
                                    </div>
                                    <a class="ld-text-change" style="top: calc(50% - 16px);" onclick="approve_augmentsinger_selectuser();">
                                        {'replacement'|@getFixedLabel}
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        {/if}

        <tr name="procecess_table_2" style="{if $ENDED neq 0}display: none;{/if}"   >
            <td class="ld-form-item-content select-input padL0" >
                <input type="radio" id="approvestatus2" name="approvestatus" value="2" class="" {$ENDCHECK} onclick="changenetapproval(1)"/>
                <label for="approvestatus2">{'SUCCESSENDPROCESS'|@getFixedLabel}</label>
            </td>
        </tr>

        {if $HIDENBACKUP neq 'yes'}
            <tr>
                <td class="ld-form-item-content select-input padL0">
                    <input type="radio" id="approvestatus4" name="approvestatus" value="4" class="" onclick="changenetapproval(1)"/>
                    <label for="approvestatus4">{'NOTPASSRETURNCHARGE'|@getFixedLabel}</label>
                </td>
            </tr>
        {/if}
        {if $version_account neq 'haige'}
            {if $PRESTEPAPPROVEBY >= 1&&$logconcurrentid<=0 }
                <tr>
                    <td class="ld-form-item-content select-input padL0">
                        <input type="radio" id="approvestatus5" name="approvestatus" value="5" class="" onclick="changenetapproval(1)"/>
                        <label for="approvestatus5">{'IFNOTPASSEDTHENRETURNTOTHEPREVIOUSSTEP'|@getFixedLabel}</label>
                    </td>
                </tr>
            {/if}
        {/if}
        {if $version_account neq 'haige'}
            {if $ENDED eq 0 && ($logconcurrentid<=0||$LastStepForApprove eq 'yes') && $showcancelbill eq 'yes'}
                <tr>
                    <td class="ld-form-item-content select-input padL0">
                        <input type="radio" id="approvestatus3" name="approvestatus" value="3" class="" onclick="changenetapproval(1)"/>
                        <label for="approvestatus3">{'FAILENDPROCESS'|@getFixedLabel}</label>
                    </td>
                </tr>
            {/if}
        {/if}
        <tr id="tr_mandatory_field">
            <td class="padT28" style="overflow: unset;">
                <div id="div_mandatory_field">
                    {$tablehtml}
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-content padT28 padL0 cc">
                {if $APPROVEREMARKREQUIRE eq 'yes'}
                    <font color="red">*</font>
                {/if}
                <input name="requiretext" value="{$APPROVEREMARKREQUIRE}" type="hidden">
                <b>{'FILLINAPPROVALCOMMENTS'|@getFixedLabel}</b><br />
                <textarea class="ld-textarea-inner marT16" name="description" rows="4"></textarea>
            </td>
        </tr>
    </table>
</form>