<form action="index.php" method="post" name="frmsubmitapprove" >
<input type="hidden" name="module" value="Approve"/>
<input type="hidden" name="action" value="SubmitApprove"/>
<input type="hidden" name="idstring" value="{$RECORD}"/>
<input type="hidden" name="fld_module" value="{$BLOCK}"/>
<input type="hidden" name="returnmodule" value="{$RETURNMODULE}"/>
<input type="hidden" name="approvetype" value="{$APPROVETYPE}">
<input type="hidden" name="selectlen" value="{$SELECTLEN}">
<div class="DivCR" id="div_submitapprove_select"> 
<div id='subappcontent'>
<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
        <td width="100" align="right">{'Approval_Process'|@getFixedLabel}</td>
        <td style="overflow: inherit;">
        {assign var=fldname value='approvevalue'}
            <select id="approvevalue" onchange="getnextstepinfo(this)" name="approvevalue" style="display:none">
            {foreach item=approve from=$APPROVE}
            <option value="{$approve.approveid}" >{$approve.approvename}</option>
            {/foreach}
            </select>
            
            <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','div_submitapprove_select')">
             	<a style="width:208px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','div_submitapprove_select')" href="javascript:void(0)" tabindex="-1"
                 name="cmb_a_{$fldname}">
					<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','div_submitapprove_select')" onKeyUp="com_chosen(event,'{$fldname}','div_submitapprove_select')" value="{$APPROVE.0.approvename}">
                    <div>
                        <b></b>
                    </div>
        	    </a>
        	    <div style=" left:-9000px;width: 208px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
        			 <ul class="chzn-results" name="cmb_ul_{$fldname}">
        				{assign var="i" value=0}
                	   {foreach item=approve from=$APPROVE}
     	                    <li  class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$approve.approveid}','{$fldname}','div_submitapprove_select')" onmouseover="cmb_limouseover(event,'{$fldname}','div_submitapprove_select')">{$approve.approvename}</li>
							{assign var="i" value=$i+1}
        	            {/foreach}
                        <li class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
        			 </ul>
        	    </div>
            </div>	
        </td>
    </tr>
    <tr>
        <td align="right">{'NEXTAPPROVESTEP'|@getFixedLabel}</td>
        <td>
            <input type="text" class="commonTextBoxPop" name="nextstepname" disabled="disabled" value="{$APPROVEFIRSTSTEP.0}">
        </td>
    </tr>
    <tr>
            {if $APPROVEFIRSTSTEP.4 eq 'yes'}
                <td align="right"><span tag="label_countersigner">{'Countersigner'|@getFixedLabel}</span><span tag="label_approver" style="display:none">{'APPROVER'|@getFixedLabel}</span></td>
            {else}
                <td align="right"><span tag="label_approver">{'APPROVER'|@getFixedLabel}</span><span style="display:none" tag="label_countersigner">{'Countersigner'|@getFixedLabel}</span></td>
            {/if}
        <td>
            <!-- <input type="text" class="commonTextBoxPop" name="userid_name" id="userid_name" disabled="disabled" value="{$APPROVEFIRSTSTEP.1}" {if $APPROVEFIRSTSTEP.2 eq 0} onclick="approve_selectuser()"{/if}> -->
            <div id="userid_name" name="userid_name" class="commonTextBoxPop lfloat" style="line-height:29px;padding-left:8px;width:295px;text-overflow:ellipsis;overflow:hidden;">{$APPROVEFIRSTSTEP.1}&nbsp;</div>
            <a id="before_approve_select" {if $APPROVEFIRSTSTEP.2 eq 0} {else} style="display:none"{/if} class="icon-homeimg icon-select lfloat marT6" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="approve_selectuser();"></a>
            <input  type="hidden" name="userid" id="userid" value="{$APPROVEFIRSTSTEP.3}"/>
        </td>
    </tr>
</table>
</div>
</div>
</form>



