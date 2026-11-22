<!---会签审批步骤-->
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
    <input  type="hidden" name="countersigner" value="yes"/>
    <input type="hidden" name="userid_0" id="userid" value="{$NEXTSETPBY}"/>
    <input type="hidden" name="nextstep_0" id="nextstep" value="{$nextstepid}"/>
	<input  type="hidden" name="augmentsinger" value="{$augmentsinger}"/>
	<input  type="hidden" name="cur_nextstepby" value="{$CUR_NEXTSTEPBY}"/>
	<input  type="hidden" name="logconcurrentid" value='{$logconcurrentid}'/>
	<input  type="hidden" name="approvelogid" value="{$approvelogid}"/>
    <input  type="hidden" name="concurrentidStepCount" value="0"/>
    <table class="" border="0" cellpadding="0" cellspacing="0" width="100%">
        
        <tr>
    		<td class="ld-form-item-content select-input padL0">
                <input type="radio" id="approvestatus1" name="approvestatus" value="{$approveresult}" checked  />
        		<label for="approvestatus1">{'Agree'|@getFixedLabel}</label>
    		</td>
        </tr>
    	<tr>
    		<td class="ld-form-item-content select-input padL0">
                <input type="radio" id="approvestatus3" name="approvestatus" value="4" />
        		<label for="approvestatus3">{'NOTPASSRETURNCHARGE'|@getFixedLabel}</label>
    		</td>
        </tr>
		{if $counter_augmentsinger eq 'yes'}
			<tr>
                <td class="ld-form-item-content select-input padL0">
                    <input type="radio" id="approvestatus2" name="approvestatus" value="6"/>
					<input type="hidden" name="counter_augmentsinger" value="yes"/>
                    <label for="approvestatus2">{'Pleasesettheapprovers'|@getFixedLabel}</label>
					<div style="display: contents;">&nbsp;&nbsp;&nbsp;
						<div id="augmentsinger_username" name="augmentsinger_username" class="commonTextBoxPop" style="line-height:29px;padding-left:8px;width:140px;display:inline-flex;text-overflow:ellipsis;overflow:hidden;">&nbsp;</div>
						<a id="augmentsinger_approve_select" class="icon-homeimg icon-select marT-4" style="" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="approve_augmentsinger_selectuser();"></a>
						<input type="hidden" name="augmentsinger_userid" id="augmentsinger_userid" value=""/>
					</div>
                </td>
            </tr>
		{/if}
        <tr id="tr_mandatory_field">
            <td class="padT16" style="overflow: unset;">
                <div id="div_mandatory_field">
                    {$tablehtml}
                </div>
            </td>
        </tr>
        <tr name="procecess_table_6" style="" tag="tr_process">
            <td class="ld-form-item-content padT28 padL0 aa">
                {if $APPROVEREMARKREQUIRE eq 'yes'}
                <font color="red">*</font>
                {/if}
                <input name="requiretext" value="{$APPROVEREMARKREQUIRE}" type="hidden">
                <b>{'APPROVALSUGGESTION'|@getFixedLabel}</b><br />
                <textarea class="ld-textarea-inner marT16" name="description" rows="4"></textarea>
            </td>
        </tr>
    </table>
</form>