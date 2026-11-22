{if $WholeApproveLog|@is_array && ($WholeApproveLog)|@sizeof > 0}
    <div style="max-height: 250px;overflow: auto;border-bottom:2px solid #F1F1F1;margin-bottom:10px;">
        <div style="margin: 3px 10px 10px 10px;"><span style="font-size: 13px;">{'approvelog'|@getFixedLabel}</span></div>
        <div name="submitapprovelog">{include file='Approve/ApproveLogEntriesNew.tpl'}</div>
    </div>
{/if}
<form action="index.php" method="post" name="frmsubmitapprove" >
    <input type="hidden" name="module" value="Approve"/>
    <input type="hidden" name="action" value="SubmitApprove"/>
    <input type="hidden" name="idstring" value="{$RECORD}"/>
    <input type="hidden" name="fld_module" value="{$ApproveModule}"/>
    <input type="hidden" name="returnmodule" value="{$RETURNMODULE}"/>
    <input type="hidden" name="approvetype" value="{$APPROVETYPE}">
    <input type="hidden" name="selectlen" value="{$SELECTLEN}">
    <input type="hidden" name="concurrentidStepCount" value="{if $APPROVEFIRSTSTEP|@is_array}{$APPROVEFIRSTSTEP|@sizeof}{else}0{/if}"/>
    <input type="hidden" name="isnewapprove" value="{$isnewapprove}" />
    <div class="DivCR" id="div_submitapprove_select">
        <div id='subappcontent' class="ld-public-content-small">
            <table class="" border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td class="ld-form-item-label padB16">{'Approval_Process'|@getFixedLabel}</td>
                    <td class="ld-form-item-content padB16" style="overflow: inherit;">
                        {assign var=fldname value='approvevalue'}
                        <select id="approvevalue" onchange="getnextstepinfo(this)" name="approvevalue" style="display:none">
                            {assign var='defaulttext' value=$APPROVE.0.approvename}
                            {assign var= 'defaultsubmit' value=$APPROVE.0.submitremark}
                            {assign var= 'showurgent' value=$APPROVE.0.showurgent}
                            {foreach item=approve from=$APPROVE}
                                {if $approve.selected eq 'selected'}
                                    {assign var= 'defaultsubmit' value=$approve.submitremark}
                                    {assign var='defaulttext' value=$approve.approvename}
                                    {assign var= 'showurgent' value=$approve.showurgent}
                                    {assign var= 'isnewapprove' value=$approve.isnewapprove}
                                    <option value="{$approve.approveid}"  selected="">{$approve.approvename}</option>
                                {else}
                                    <option value="{$approve.approveid}"  >{$approve.approvename}</option>
                                {/if}
                            {/foreach}
                        </select>
                        <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','div_submitapprove_select')">
                            <a class="chzn-single" onclick="com_img_change(event,'{$fldname}','div_submitapprove_select')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
                                <input class="ld-select-inner-input" type="text" autocomplete="off" tabindex="0" name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','div_submitapprove_select')" onKeyUp="com_chosen(event,'{$fldname}','div_submitapprove_select')" value="{$defaulttext}">
                                <div>
                                    <b></b>
                                </div>
                            </a>
                            <div style=" left:-9000px;top: 32px;display:none;" class="chzn-drop" name='dv_drop_{$fldname}' >
                                <ul class="chzn-results" name="cmb_ul_{$fldname}">
                                    {assign var="i" value=0}
                                    {foreach item=approve from=$APPROVE}
                                        <li class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="approve_change('{$approve.approveid}','{$fldname}','div_submitapprove_select','{$approve.submitremark.display}','{$approve.submitremark.require}','{$approve.showurgent}')" onmouseover="cmb_limouseover(event,'{$fldname}','div_submitapprove_select')">{$approve.approvename}</li>
                                        {assign var="i" value=$i+1}
                                    {/foreach}
                                    <li class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                                </ul>
                            </div>
                        </div>
                    </td>
                </tr>
            </table>
            <table class="" border="0" cellpadding="0" cellspacing="0" width="100%" name="submitapprovestep_table">
                <tbody>
                {foreach from=$APPROVEFIRSTSTEP key=loop item=submitstepinfo }
                    <tr tag='rowdata'>
                        <td class="ld-form-item-label">{'APPROVALSTEP'|@getFixedLabel}</td>
                        <td class="ld-form-item-content">
                            <input type="text" class="ld-input-inner" name="nextstepname_{$loop}" readonly="true" value="{$submitstepinfo.nextstepname}">
                            <input type="hidden" name="nextstep_{$loop}" value="{$submitstepinfo.stepid}">
                            <input type="hidden"  name="stepseq_{$loop}" value="{$loop}">
                            <input type="hidden" value="nextstep_countersigner_{$loop}" value="{$submitstepinfo.countersigner}"/>
                            <input type="hidden" value="nextstep_augmentsinger_{$loop}" value="{$submitstepinfo.augmentsinger}"/>
                            <input type="hidden" name="allow_emptyapprover_{$loop}" value="{$submitstepinfo.allow_emptyapprover}"/>
                            <div name="userid_name_{$loop}" id="userid_name_{$loop}" style="display:none" >{$submitstepinfo.newstepapprover}</div>
                            <input type="hidden" name="userid_{$loop}" id="userid_{$loop}" value="{$submitstepinfo.stepuserids}"/>
                        </td>
                    </tr>
                    {*eidt:zkt 1002441 审批，审批人添加框样式优化*}
                    <tr tag="rowdata" id="approvestep_selecttr_{$loop}" name="approvestep_selecttr_{$loop}" >
                        <td class="ld-form-item-label">
                            {if $submitstepinfo.countersigner eq 'yes'}
                                <span tag="label_countersigner">{'Countersigner'|@getFixedLabel}</span><span tag="label_approver" style="display:none;">{'APPROVER'|@getFixedLabel}</span>
                            {else}
                                <span tag="label_approver">{'APPROVER'|@getFixedLabel}</span><span style="display:none;" tag="label_countersigner">{'Countersigner'|@getFixedLabel}</span>
                            {/if}
                        </td>
                        <td class="ld-form-item-content">
                            <div class="pubclear" style="padding:0px;" id="before_approve_selectdiv_{$loop}">
                                <div class="CCrange ld-input-inner-div" id="approvers_div_{$loop}" name="approvers_div_{$loop}" tag="ccrange" style="overflow-y: auto;max-height:90px;">
                                    <ul class="ld-input-inner-div-items">
                                        {foreach key=userid item=username from=$submitstepinfo.stepuseridtonamearr}
                                            <li class="ld-input-inner-div-item" itemid="approver_{$loop}_{$userid}" title='{$username}'>
                                                <span class="item-name" >{$username}</span>{if $submitstepinfo.specifyapproverid eq 0}<span class="remove-h" onclick="ApproveSelectApproverDiv_remove_oneuser(this,'userid_{$loop}','userid_name_{$loop}');">×</span>{/if}
                                            </li>
                                        {/foreach}
                                    </ul>
                                </div>
                                {if $submitstepinfo.specifyapproverid eq 0}
                                    <a class="ld-text-change" style="{if $CurStepspecifyapproverid eq 0}{else}display:none;{/if}" onclick="concurrentstepapprove_selectuser({$loop});">
                                        {'replacement'|@getFixedLabel}
                                    </a>
                                {/if}
                            </div>
                        </td>
                    </tr>
                {/foreach}
                </tbody>
            </table>
            <table class="" width="100%" border="0" cellpadding="0" cellspacing="0" name="showurgent" style="display:{if $showurgent neq "yes"}none{/if}">
                <tr>
                    <td class="ld-form-item-label padT16">{'UrgentApproval'|@getFixedLabel}</td>
                    <td class="ld-form-item-content padT16"><div class="ld-text-inner"><input type="checkbox" name="urgent"></div></td>
                </tr>
            </table>
            {*@edit:liushuai,2021-03-22,reason:【ID1001043】提交审批弹出层中增加提交意见*}
            <table class="" width="100%" border="0" cellpadding="0" cellspacing="0" name="showsubmitremark" style="display:{if $defaultsubmit.display neq "yes"}none{/if}">
                <tr>
                    <td class="ld-form-item-label padT16">
                        <div style="display:{if $defaultsubmit.require neq "yes"||$defaultsubmit.display neq "yes" }none{else}inline{/if}" name="submitremarkrequire" style="float:left;">
                            <font color="red">*</font>
                        </div>
                        {'FILLINAPPROVALCOMMENTS'|@getFixedLabel}
                    </td>
                    <td class="ld-form-item-content padT16">
                        <textarea id="submit_description" name="submit_description" class="ld-textarea-inner" rows="4"></textarea>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</form>