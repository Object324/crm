<div class="Showselect" style="margin-top: -6px;"  id="dv_reportlog_smowner">
{assign var=fldname value='searchOwner'}
	<label>{'Person_in_charge'|@getFixedLabel}</label>
    {*andrew 看周报、看月报界面：创建人下拉框中选择一个用户后，结果跳转到看日报界面了*}
    <select onchange="ChangeSearchOwner(this,{$REPORTLOGTYPE})" id="searchOwner" name="searchOwner" style="display:none">
    
    {foreach key=User_Key item=User_value from=$MERGESMOWNER}
        {foreach key=User_id item=User_name from=$User_value}
            {foreach key=User_name_key item=User_name_value from=$User_name}
            
                {if $User_id eq $SelectedOwner2}
                    {assign var=optText value=$User_name_key}
                    <option value="{$User_id}" selected="true">{$User_name_key}</option>
                {else}
       
                        <option value="{$User_id}">{$User_name_key}</option>
                  
                {/if}
            
            {/foreach}
        {/foreach}
    {/foreach}
  
    </select>
                            
    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','dv_reportlog_smowner')">
     	<a style="width:110px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','dv_reportlog_smowner')" href="javascript:void(0)" tabindex="-1"
         name="cmb_a_{$fldname}">
			<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','dv_reportlog_smowner')" onKeyUp="com_chosen(event,'{$fldname}','dv_reportlog_smowner')" value="{$optText}">
            <div>
                <b></b>
            </div>
	    </a>
	    <div style=" left:-9000px;width: 118px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
			 <ul class="chzn-results" name="cmb_ul_{$fldname}">
				{assign var="i" value=0} 
				{foreach key=User_Key item=User_value from=$MERGESMOWNER }
                    {foreach key=User_id item=User_name from=$User_value name=foo}
                        
                        {foreach key=User_name_key item=User_name_value from=$User_name }
        				        
                                   
 	                       <li style="" class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','dv_reportlog_smowner')" onmouseover="cmb_limouseover(event,'{$fldname}','dv_reportlog_smowner')">{$User_name_key}</li>
                              {assign var="i" value=$i+1}
        					
                        {/foreach}
                    {/foreach}
	            {/foreach}
                   
                   <li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
			 </ul>
	    </div>
    </div>
</div>