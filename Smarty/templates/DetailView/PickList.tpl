{if $CALENDARTEMPLATEDETAILS eq ''} {* editor:gyq_13 reason:日程模板明细只保留字段值 date:20160617 *}
    <td class="ld-form-item-label">
        <font color="red">{$mandatory_field}</font>{$usefldlabel}
        {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
        {include file='Helptips.tpl'}
    </td>
{/if}
	{if $uitype eq 601}
        <td class="ld-form-item-content" name="td_cmb_{$fldname}">
	{elseif $CALENDARTEMPLATEDETAILS neq ''}
        <td class="ld-form-item-content" name="td_cmb_{$fldname}" style="overflow: inherit;">
    {else}
        <td class="ld-form-item-content" name="td_cmb_{$fldname}">
	{/if}
    <div class="row-fluid"  name="dv_cmb_{$fldname}">
		<span class="span10">
			{if $MODULE eq 'Calendar'}
		   		<select name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' style="display:none" >
			{elseif ( $fldname eq 'accountallview' ||$fldname eq 'level')&&$IS_ADMIN eq false}
                <select name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}'  disabled="true" style="display:none" >
			{elseif $fldname eq 'approvestatus'}
				<select name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}'   key="users" style="display:none" onchange="UpdateApproveby_name(this)">
            {elseif $ordertype_onclick eq 'yes' && $fldname eq 'ordertype'}
				<select name="{$fldname}"  tabindex="{$vt_tab}"  fieldonly='{$fieldonly}'   style="display:none" onchange="setProductToolFieldDisplay(this)">
			{elseif $fldname eq 'social_activitytype'}
				<select name="{$fldname}"  tabindex="{$vt_tab}"  fieldonly='{$fieldonly}'   style="display:none" onchange="changeSocialActivitytype(this)">
			{else}
                <select name="{$fldname}"  tabindex="{$vt_tab}"  fieldonly='{$fieldonly}'   style="display:none">
            {/if}
			{foreach item=arr from=$fldvalue}
               {if $arr[2] eq 'selected'}
                {assign var="optText" value=$arr[0]}
                  	<option value="{$arr[0]}" selected="true">
                        {$arr[0]}
                    </option>		
				{else}
                    <option value="{$arr[0]}" >
                        {$arr[0]}
                    </option>
				{/if}
			{/foreach}
            {if $fldname eq 'approvestatus'}
                {foreach item=value key=key from=$approvestatus}
                    {if $MODE eq 'edit' || $DUPLICATE|| $mode_showpagerule eq 'yes'}
                        {if $approvestatus_show == $key  && $approvestatus_show neq '' || $approvestatus_show_user == $key  && $approvestatus_show_user neq ''}
                       {assign var="optText" value=$value}
                        <option value="{$key}" selected="selected">{$value}</option>
                        {else}
                        <option value="{$key}">{$value}</option>
                        {/if}
                    {else}
                        {if $key eq '1'}
                        {assign var="optText" value=$value}
                        <option value="{$key}" selected="selected">{$value}</option>
                        {else}
                        <option value="{$key}">{$value}</option>
                        {/if}
                    {/if}
                {/foreach}                            
            {/if}
			    </select>
                <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}')">
					{if $uitype eq 601 && $ISADMIN eq 'off'}
    					<a class="chzn-single" onclick="" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}" draggable="false" >
					{else}
						<a class="chzn-single" onclick="com_img_change(event,'{$fldname}')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}" draggable="false" >
					{/if}
						<input class="ld-select-inner-input" type="text" autocomplete="off" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}')" value="{$optText}">
                        <div>
                            <b></b>
                        </div>
    				</a>
                    {*wyt 221128 BUG0059263 kfbcrm 成员管理页面---审批委托字段---字段宽度与下拉选项的宽度不一致*}
				    <div style="display: none; left:-9000px;top:32px;" class="chzn-drop" name='dv_drop_{$fldname}' >
    					<ul class="chzn-results" name="cmb_ul_{$fldname}">
							{assign var="i" value=0}
    			        	{foreach item=arr from=$fldvalue name=foo}
								{if $fldname eq 'social_activitytype'}
									{if $arr[0] neq ''}
										{if $arr[0] eq 'NOTACCESS'|@getFixedLabel}
											 <li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$arr[0]}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$arr[0]}</li>
										{else}
											<li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$arr[0]}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$arr[0]}</li>
										{/if}
									{/if}
								{else}
									{if $arr[0] eq 'NOTACCESS'|@getFixedLabel}
										 <li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$arr[0]}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$arr[0]}</li>
									{else}
										<li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$arr[0]}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$arr[0]}</li>
									{/if}
								{/if}
								{assign var="i" value=$i+1}
    			            {/foreach}
                            {if $fldname eq 'approvestatus'}
								{assign var="i" value=0}
                                {foreach item=value key=key from=$approvestatus name=foo}
                                    {if $MODE eq 'edit'}
                                        {if $approvestatus_show == $key  && $approvestatus_show neq '' || $approvestatus_show_user == $key  && $approvestatus_show_user neq ''}
                                        <li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$value}</li>
                                        {else}
                                        <li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$value}</li>
                                        {/if}
                                    {else}
                                        {if $key eq '1'}
                                        <li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$value}</li>
                                        {else}
                                        <li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$value}</li>
                                        {/if}
                                    {/if}
									{assign var="i" value=$i+1}
                                {/foreach}
								
                            {/if}
							
                            <li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
    					</ul>
				    </div>
                </div>
        </span>
	</div>
    {if $CALENDARTEMPLATEDETAILS eq '' && checkCurrentUserIsAdmin() eq 'on' && $uitype eq 15 && $fldname neq 'approvestatus' && $fldname neq 'paymenttype'}
        {if $fldname eq 'userlevel' && $MODULE eq 'Settings'}
            <b onclick="getCombox('Users','{$fldname}')" title="{'SETTINGS'|@getFixedLabel}" class="icon-homeimg icon-setgrey marT6 marL5 c" style="cursor:pointer;"></b>
        {else}
            <b onclick="getCombox('{$MODULE}','{$fldname}')" title="{'SETTINGS'|@getFixedLabel}" class="icon-homeimg icon-setgrey marT6 marL5 d" style="cursor:pointer;"></b>
        {/if}
    {/if}
</td>