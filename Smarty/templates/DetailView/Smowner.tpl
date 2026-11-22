{if $CALENDARTEMPLATEDETAILS eq ''} {* editor:gyq_13 reason:日程模板明细只保留字段值 date:20160617 *}
	<td class="ld-form-item-label">
		<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" name="{$fldname}_mass_edit_check" class="small" >{/if}
		{include file='Helptips.tpl'}
	</td>
{/if}
{if $CALENDARTEMPLATEDETAILS eq ''}
    <td class="ld-form-item-content">
{else}
    <td class="ld-form-item-content" style="overflow: inherit;">
{/if}
    {if ($MODULE eq 'Documents' || $MODULE eq 'PublicAnnouncement') && $fldname eq 'assigned_user_id'}
        <div class="row-fluid"  name="dv_cmb_{$fldname}" style="position:relative;">
    {else}
        <div class="row-fluid"  name="dv_cmb_{$fldname}">
	{/if}
		<span class="span10">
			{assign var=check value=1}
			{foreach key=key_one item=arr from=$fldvalue}
				{foreach key=sel_value item=value from=$arr}
					{if $value ne ''}
						{assign var=check value=$check*0}
					{else}
						{assign var=check value=$check*1}
					{/if}
				{/foreach}
			{/foreach}
			{if $check eq 0}
				{assign var=select_user value='checked'}
				{assign var=style_user value='display:block'}
				{assign var=style_group value='display:none'}
			{else}
				{assign var=select_group value='checked'}
				{assign var=style_user value='display:none'}
				{assign var=style_group value='display:block'}
			{/if}
			<input type="radio" tabindex="{$vt_tab}" style="display:none" name="assigntype" {$select_user} value="U" onclick="toggleAssignType(this.value)" checked="true" >
         	<span name="assign_user" style="{$style_user}">
				{if $VERSIONINFO.account eq 'zhongneng' && ($MODULE eq 'Quotes' || $MODULE eq 'Invoice' || $MODULE eq 'OutboundOrder' || $MODULE eq 'SalesOrder'|| $MODULE eq 'QuotesChange')}
					<select name="{$fldname}"  class="small" style="display:none" onchange="getSmownerStore(this);">
				{else}
					<select name="{$fldname}"  class="small" style="display:none">
				{/if}
                    <option value=""></option>
					{foreach key=key_one item=arr from=$fldvalue}
						{foreach key=sel_value item=value from=$arr}
                            {if $value eq 'selected'}
                                {assign var="optText" value=$sel_value}
                            {/if}
							<option value="{$key_one}" {$value}>{$sel_value}</option>
                        {/foreach}
					{/foreach}
				</select>
         	</span>
            <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single">
				{if $BANGWO8 neq 'yes'}
					<a class="chzn-single" onclick="com_img_change(event,'{$fldname}')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
			 	{/if}
                    {*zkt 20220930 BUG0057295下拉框字段-当文本超出下拉框的长度时，显示错误 contenteditable="true"*}
					<div class="ld-select-inner-div" contenteditable=true tabindex="0" name='cmb_span_optiontext_{$fldname}' type="text" onclick="CrmPopup.getPopupObj('last').picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}')" picklisttype="smownerpicklist">
                    	{$optText}
                    </div>
                    <div>
                        <b></b>
                    </div>
				</a>
				<div style="display:none;left:-9000px;top:32px;" class="chzn-drop" name='dv_drop_{$fldname}' onMouseLeave="cmb_mouseleave(event,'{$fldname}')">
					<ul class="chzn-results">
						{*@edit:liushuai,2021-03-12,reason: 44984: （https://61mis.com/kfbcrm [^]）客户新建界面，“单选用户1”字段选择用户后，不能再选择空选项了（需要补丁）【除了销售负责人不能选择空，其它单选用户的类型字段可以选择为空】*}
							{if $fldname neq 'assigned_user_id'} <li userid="" style=""  picklisttype='smownerpicklist'  class="active-result" name="dv_chzn_0_{$fldname}" onclick="cmb_liclick('','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')"></li>{/if}
							{foreach key=key_one item=arr from=$fldvalue name=foo}
    							{foreach key=sel_value item=value from=$arr }
                                   <li userid="{$key_one}" picklisttype='smownerpicklist' class="active-result" name="dv_chzn_{$smarty.foreach.foo.iteration }_{$fldname}" onclick="cmb_liclick('{$key_one}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$sel_value}</li>
                                {/foreach}
						    {/foreach}
                            <li style="" class="" name="li_chzn_{$fldname}" >{'NORECORDSAREFOUND'|@getFixedLabel}</li>
					</ul>
				</div>
			</div>
		</span>
	</div>
</td>