
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
                 <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single"   style="width: 140px;">
				<a class="chzn-single" onclick="com_img_change(event,'{$fldname}','dv_cmb_{$fldname}')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}" style="width:140px;">
					<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 120px;margin-left: -10px;border-style:none;" tabindex="0" name="cmb_span_optiontext_{$fldname}" onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}')" value="{$optText}">
					<!--
                    <span class="changeImg_down" onclick="com_img_change(event,'{$fldname}')" id="cmb_span_{$fldname}">&nbsp;&nbsp;&nbsp;&nbsp;	
					</span>
                    -->
                    <div>
                        <b></b>
                    </div>
				</a>
				<div style=" left:-9000px;width: 148px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' onMouseLeave="cmb_mouseleave(event,'{$fldname}','dv_cmb_{$fldname}')">
					 <ul class="chzn-results">
					
				        
            				{foreach key=key_one item=arr from=$fldvalue name=foo}
    							{foreach key=sel_value item=value from=$arr }
                                   <li style="" class="active-result" name="dv_chzn_{$smarty.foreach.foo.iteration }_{$fldname}" onclick="cmb_liclick('{$key_one}','{$fldname}','dv_cmb_{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}','dv_cmb_{$fldname}')">{$sel_value}</li>
                                {/foreach}
						   {/foreach}
                                
   			         	     
				           
                            <li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
					 </ul>
				 </div>
			 </div>
		 </span>
	 </div>
