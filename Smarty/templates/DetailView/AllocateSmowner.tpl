	<td width="20%" align="right">
			{$usefldlabel}
	</td>
	<td width="30%" align="left" >
            <div class="row-fluid"  id="dv_cmb_{$fldname}"  >
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
             

				<span id="assign_user" style="{$style_user}">
					<select name="{$fldname}" id="{$fldname}" class="small" style="display:none" >
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
                 <div id="dv_chzn_{$fldname}" class="chzn-container chzn-container-single"   style="width: 110px;">
				<a class="chzn-single" style="width: 110px;" onclick="com_img_change(event,'{$fldname}')" href="javascript:void(0)" tabindex="-1" id="cmb_a_{$fldname}">
					<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}')" value="{$optText}" onKeyPress=" return com_keyPress(event)">
                    <div>
                        <b></b>
                    </div>
				</a>
				<div style=" left:-9000px;width: 118px; top: 25px;" class="chzn-drop" id='dv_drop_{$fldname}' onMouseLeave="cmb_mouseleave(event,'{$fldname}')">
					 <ul class="chzn-results">
					
							{assign var="i" value=0}
            				{foreach key=key_one item=arr from=$fldvalue name=foo}
    							{foreach key=sel_value item=value from=$arr }
                                   <li style="" class="active-result" id="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$key_one}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$sel_value}</li>
								   {assign var="i" value=$i+1}
                                {/foreach}
						   {/foreach}
                                
   			         	     
				           
                            <li style="" class="" id="li_chzn_{$fldname}" >没有匹配项目</li>
					 </ul>
				 </div>
			 </div>
		 </span>
	 </div>
</td>