<!---会签审批步骤-->
<link type="text/css" href="{$CSSURL}themes/softed/coordination.css" rel="stylesheet" />
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
    <input  type="hidden" name="countersigner" value="{$countersigner}"/>
    <input type="hidden" name="userid_0" id="userid" value="{$NEXTSETPBY}"/>
    <input type="hidden" name="nextstep_0" id="nextstep" value="{$STEPID}"/>
	<input  type="hidden" name="augmentsinger" value="{$augmentsinger}"/>
	<input  type="hidden" name="cur_nextstepby" value="{$CUR_NEXTSTEPBY}"/>
    <input  type="hidden" name="logconcurrentid" value='{$logconcurrentid}'/>
	<input  type="hidden" name="approvelogid" value="{$approvelogid}"/>
    <input  type="hidden" name="concurrentidStepCount" value="0"/>
    <table class="" border="0" cellpadding="0" cellspacing="0" width="100%">
        
        <tr>
    		<td class="ld-form-item-content select-input">
                <input type="radio" name="approvestatus" value="{$approveresult}" checked />
        		<label>{'CONTINUEAPPROVALSTEP'|@getFixedLabel}</label>
    		</td>
        </tr>
    	<tr>
    		<td class="ld-form-item-content select-input">
                <input type="radio" name="approvestatus" value="4" />
        		<label>{'NOTPASSRETURNCHARGE'|@getFixedLabel}</label>
    		</td>
        </tr>
		{if $augmentsinger eq 'yes'  || $augmentsinger eq 'no'}
			<tr>
                <td class="ld-form-item-content select-input">
                    <input type="radio" name="approvestatus" value="6"/>
					<input type="hidden" name="counter_augmentsinger" value="yes"/>
                    <label>{'Pleasesettheapprovers'|@getFixedLabel}</label>
				    <div style="display: contents;">&nbsp;&nbsp;&nbsp;
                        <input type="hidden" name="augmentsinger_username" id="augmentsinger_username" value=""/>
						<input type="hidden" name="augmentsinger_userid" id="augmentsinger_userid" value=""/>
					</div>
                </td>
            </tr>
            {*zkt 0050406: （https://81mis.com/kfbcrm/index.php [^]）合同订单》SO32，审批人yhaic，审批单据时，选择审批人的样式没有更新；‘审批步骤是并发审批加签’*}
            <tr name="procecess_table_6" style="display:none" tag="tr_process">
                <td>
                    <table class="settingPopTable settingPopTableNoBot settingPopTableNoBotLast" width="100%" cellspacing="0" cellpadding="0" border="0">
                        <tr tag="rowdata" id="approvestep_selecttr_augmentsinger" name="approvestep_selecttr_augmentsinger" >
                            <td align="right" style="width:100px"> {'APPROVER'|@getFixedLabel}</td>
                                
                            <td>	
                                <div class="pubclear" style="" id="before_approve_selectdiv_augmentsinger">
                                    <div id="approvers_div_augmentsinger" name="approvers_div_augmentsinger" class="CCrange selectbar"
                                     style="margin-top: 0;width: 100%;border-radius:4px;overflow-y: auto;max-height:90px">
                                     <ul class="reader-bar-list">
            						</ul>
                                     
                                     <span class="input-tip"><a href="javascript:;" name="select_approvers" tag="approvers" 
                                     title="{'AddApprover'|@getFixedLabel}" class="choosepublicadmin" style="margin-left: 10px;white-space:nowrap;" 
                                     onclick="approve_augmentsinger_selectuser();">{'AddApprover'|@getFixedLabel}</a></span>
                                     </div>
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
		{/if}
        <tr id="tr_mandatory_field">
            <td style="overflow: unset;">
                <div id="div_mandatory_field">
                    {$tablehtml}
                </div>

            </td>
        </tr>
        <tr>
            <td class="ld-form-item-content padT28 padL0 bb">
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