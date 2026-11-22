
{if $CALENDARTEMPLATEDETAILS eq ''} {* editor:gyq_13 reason:日程模板明细只保留字段值 date:20160617 *}
    <td width="20%" class="ld-form-item-label">
           <font color="red">
          {$mandatory_field}
          </font>
          {$usefldlabel}
          {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
    </td>
{/if}

	<td width="30%" align="left"  class="ld-form-item-content"  name="td_cmb_{$fldname}">

    <div class="row-fluid"  name="dv_cmb_{$fldname}">
		<span class="span10">

			<input name="{$fldname}" type="hidden" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}'  value="{$optText}"  style="display:none">

            <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" style="width: {if $CALENDARTEMPLATEDETAILS eq ''}285px;{else}117px{/if}" onMouseLeave="cmb_mouseleave(event,'{$fldname}')">

						<a class="chzn-single" {if $CALENDARTEMPLATEDETAILS neq ''}style="width:{if $CALENDARTEMPLATEDETAILS eq ''}285px;{else}115px{/if}" {/if} onclick="return CrmPopup.getPopupObj('last').picklist_arrow_click(event,'{$fldname}')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
						<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: {if $CALENDARTEMPLATEDETAILS eq ''}285px{else}105px{/if};margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="CrmPopup.getPopupObj('last').picklist_end_foucs(event,'{$fldname}')" onKeyUp="CrmPopup.getPopupObj('last').picklistobjarray['{$fldname}'].com_chosen(event)','dv_salesgoallist_smownerscope')" value="{$optText|getTranstab}">
                        <div>
                            <b></b>
                        </div>
    				</a>
				    <div style=" left:-9000px;width: {if $CALENDARTEMPLATEDETAILS eq ''}280px{else}123px{/if}; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
    					<ul class="chzn-results" name="cmb_ul_{$fldname}">
                            <li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
    					</ul>
				 </div>
			</div>
		</span>
	</div>
    {if $CALENDARTEMPLATEDETAILS eq '' && checkCurrentUserIsAdmin() eq 'on' && $uitype eq 15 && $fldname neq 'approvestatus' && $fldname neq 'paymenttype'}
        {if $fldname eq 'userlevel' && $MODULE eq 'Settings'}
        <b onclick="getCombox('Users','{$fldname}')" title="{'SETTINGS'|@getFixedLabel}" class="icon-homeimg icon-setgrey marT5 marL5 a" style="cursor:pointer;"></b>
        {else}
        <b onclick="getCombox('{$MODULE}','{$fldname}')" title="{'SETTINGS'|@getFixedLabel}" class="icon-homeimg icon-setgrey marT5 marL5 b" style="cursor:pointer;"></b>
        {/if}
    {/if}
</td>
