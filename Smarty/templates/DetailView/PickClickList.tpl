{if $CALENDARTEMPLATEDETAILS eq ''} {* editor:gyq_13 reason:日程模板明细只保留字段值 date:20160617 *}
    <td class="ld-form-item-label">
        <font color="red">{$mandatory_field}</font>{$usefldlabel}
        {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
        {include file='Helptips.tpl'}
    </td>
{/if}
<td class="ld-form-item-content" name="td_cmb_{$fldname}">
    <div class="row-fluid"  name="dv_cmb_{$fldname}">
		<span class="span10">
            {if $bigtype eq 'picklist_key'}
                <input name="{$fldname}" type="hidden" tabindex="{$vt_tab}" fieldonly='{$fieldonly}'  value="{$maindata['value']}" style="display:none">
            {else}
                {if $MODULE eq 'Calendar'}
                    <input name="{$fldname}" type="hidden" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' value="{$optText}" style="display:none" >
                {elseif ( $fldname eq 'accountallview' ||$fldname eq 'level')&&$IS_ADMIN eq false}
                    <input name="{$fldname}" type="hidden" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' value="{$optText}" disabled="true" style="display:none" >
                {elseif $fldname eq 'approvestatus'}
                    <input name="{$fldname}" type="hidden" tabindex="{$vt_tab}" fieldonly='{$fieldonly}'  value="{$optText}" key="users" style="display:none" onchange="UpdateApproveby_name(this)">
                {elseif $ordertype_onclick eq 'yes' && $fldname eq 'ordertype'}
                    <input name="{$fldname}" type="hidden" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' value="{$optText}"  style="display:none" onchange="setProductToolFieldDisplay(this)">
                {else}
                    <input name="{$fldname}" type="hidden" tabindex="{$vt_tab}" fieldonly='{$fieldonly}'  value="{$optText}" style="display:none">
                {/if}
            {/if}
            <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}')">
				{if $uitype eq 601 && $ISADMIN eq 'off'}
					<a class="chzn-single" onclick="" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}" draggable="false" >
				{else}
					<a class="chzn-single" onclick="return CrmPopup.getPopupObj('last').picklist_arrow_click(event,'{$fldname}')"
                       href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}" draggable="false" >
				{/if}
                    {* zxm 预算单 预算指标字段值需要翻译*}
                    {if $fldname eq 'budget_indicators'}
                        <input class="ld-select-inner-input" type="text" autocomplete="off" onclick="CrmPopup.getPopupObj('last').picklist_end_foucs(event,'{$fldname}')" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onKeyUp="CrmPopup.getPopupObj('last').picklistobjarray['{$fldname}'].com_chosen(event)" value="{$optText|@getFixedLabel}">
                    {else}
					    <input class="ld-select-inner-input" type="text" autocomplete="off" style="color: {$fieldvaluecolor};" onclick="CrmPopup.getPopupObj('last').picklist_end_foucs(event,'{$fldname}')" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onKeyUp="CrmPopup.getPopupObj('last').picklistobjarray['{$fldname}'].com_chosen(event)" value="{$optText}">
                    {/if}
                    <div>
                        <b></b>
                    </div>
				</a>
			    <div style=" left:-9000px;top: 32px;" class="chzn-drop" name='dv_drop_{$fldname}' >
					<ul class="chzn-results" name="cmb_ul_{$fldname}">
                        {if $fldname eq 'approvestatus'}
                            {foreach item=value key=key from=$approvestatus name=foo}
                                {if $MODE eq 'edit'}
                                    {if $approvestatus_show == $key  && $approvestatus_show neq '' || $approvestatus_show_user == $key  && $approvestatus_show_user neq ''}
                                    <li style="" class="active-result" name="dv_chzn_{$smarty.foreach.foo.iteration }_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$value}</li>
                                    {else}
                                    <li style="" class="active-result" name="dv_chzn_{$smarty.foreach.foo.iteration }_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$value}</li>
                                    {/if}
                                {else}
                                    {if $key eq '1'}
                                    <li style="" class="active-result" name="dv_chzn_{$smarty.foreach.foo.iteration }_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$value}</li>
                                    {else}
                                    <li style="" class="active-result" name="dv_chzn_{$smarty.foreach.foo.iteration }_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$value}</li>
                                    {/if}
                                {/if}
                            {/foreach}                               
                        {/if}  
                        <li style="" class="" name="li_chzn_{$fldname}" >{'NORECORDSAREFOUND'|@getFixedLabel}</li>
					</ul>
			    </div>
			</div>
		</span>
	</div>
    {if $CALENDARTEMPLATEDETAILS eq '' && checkCurrentUserIsAdmin() eq 'on' && $uitype eq 15 && $fldname neq 'approvestatus' && $fldname neq 'paymenttype' && $fldname neq
    'gender' && $fldname neq 'pricepolicy_type' && $fldname neq 'pricepolicy_forms'}
        {if $fldname eq 'userlevel' && $MODULE eq 'Settings'}
            <i onclick="getCombox('Users','{$fldname}')" title="{'SETTINGS'|@getFixedLabel}" class="ld-fonticon ld-fonticon-set"></i>
        {elseif $MODULE eq 'Leads' && $fldname eq 'status'}
            {*BUG0057621 zxm 20230529  销售线索、新建/编辑/复制界面，“商机状态”字段下拉选项后面去掉“设置”图标按钮*}
        {else}
            {if $fldname eq 'budget_indicators' && $MODULE eq 'ExpenseBudget' && $BUDGETTYPE eq 'salesGoalBudget'}
                <script src="{$JSURL}include/js/modules/SalesGoal/SalesGoal.js" type="text/javascript"></script>
                <i onclick="SalesGoalList()" title="{'MANAGEINDICATORS'|@getFixedLabel}" class="ld-fonticon ld-fonticon-set"></i>
            {else}
                <i onclick="getCombox('{$MODULE}','{$fldname}')" title="{'SETTINGS'|@getFixedLabel}" class="ld-fonticon ld-fonticon-set"></i>
            {/if}
        {/if}
    {/if}
</td>