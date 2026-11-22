<div class="Showselect" id="div_component_showselect">
{assign var=fldname value='SmOwnerSearchScope'}
	<label>{'VIEWRANGE'|@getFixedLabel}</label>   
     <select onchange="setScope(this.value)" id="SmOwnerSearchScope" name="SmOwnerSearchScope" class="Sel_Owner" style="display:none">
                {foreach key=User_Key item=User_value from=$Merge_SmOwner}
                    {foreach key=User_id item=User_name from=$User_value}
                        {foreach key=User_name_key item=User_name_value from=$User_name}
                            {if $User_id eq $ownerScope}
                                {assign var=optText value=$User_name_key}
                                <option value="{$User_id}" selected="true">{$User_name_key}</option>
                            {else}
                                <option value="{$User_id}">{$User_name_key}</option>
                            {/if}
                            
                        {/foreach}
                    {/foreach}
                {/foreach}
           
    </select>
                            
    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','div_component_showselect')">
     	<a style="width:117px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','div_component_showselect')" href="javascript:void(0)" tabindex="-1"
         name="cmb_a_{$fldname}">
			<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','div_component_showselect')" onKeyUp="com_chosen(event,'{$fldname}','div_component_showselect')" value="{$optText}">
            <div>
                <b></b>
            </div>
	    </a>
	    <div style=" left:-9000px;width: 117px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
			 <ul class="chzn-results" name="cmb_ul_{$fldname}">
				{assign var="i" value=0}
        	   {foreach key=User_Key item=User_value from=$Merge_SmOwner }
                    {foreach key=User_id item=User_name from=$User_value name=foo}
                        {foreach key=User_name_key item=User_name_value from=$User_name }
 	                       <li  class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','div_component_showselect')" onmouseover="cmb_limouseover(event,'{$fldname}','div_component_showselect')">{$User_name_key}</li>
                            {if $User_id eq 'smowner_search_senior'}
                            {assign var="show" value=1}
                            {/if}	
        					{assign var="i" value=$i+1} 
                        {/foreach}
                    {/foreach}
	            {/foreach}
                   
                   <li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
			 </ul>
	    </div>
    </div>
        {if $show eq 1}
    	<a class="icon-range" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}"  onclick="SmOwnerScopehightuser()"></a>
 	  	{/if}
</div>