<tr>
  <td width="50%" align="right">{'Select_field'|@getFixedLabel}</td>
  <td width="50%" style="overflow: inherit;">
				    <select id="stdDateFilterField" name="stdDateFilterField" class="select" onchange="standardFilterDisplay();" style="display:none;">
    				{foreach item=stdfilter name=stdfil from=$STDFILTERCOLUMNS}
                        {if $stdfilter.selected eq 'selected'}
                            {assign var='opttext' value=$stdfilter.text}
    					  <option selected="selected" value={$stdfilter.value}>{$stdfilter.text}</option>
                        {else}
                          <option value={$stdfilter.value}>{$stdfilter.text}</option>
                        {/if}
                        {if $smarty.foreach.stdfil.first}
                            {assign var='optDefault' value=$stdfilter.text}
                        {/if}	
    				{/foreach}
                    </select>
                    <div name="dv_chzn_stdDateFilterField" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'stdDateFilterField','dv_customview_stdfiler')" style="z-index:999;">
    					<a class="chzn-single" onclick="com_img_change(event,'stdDateFilterField','dv_customview_stdfiler')" href="javascript:void(0)" tabindex="-1"
    					 name="cmb_a_stdDateFilterField" style="width:190px;">
							<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 170px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_stdDateFilterField' onclick="cmb_picklist_end_foucs(event,'stdDateFilterField','dv_customview_stdfiler')" onKeyUp="com_chosen(event,'stdDateFilterField','dv_customview_stdfiler')" value="{if $opttext neq ''}{$opttext}{else}{$optDefault}{/if}">
    						<div><b></b></div>
    					</a>
    					<div style="left:-9000px; top: 25px;width:198px;" class="chzn-drop" name='dv_drop_stdDateFilterField' >
    						 <ul class="chzn-results" name="cmb_ul_stdDateFilterField">
								{assign var="i" value=0}
    						   {foreach item=stdfilter from=$STDFILTERCOLUMNS }
    							   <li class="active-result" name="dv_chzn_{$i}_stdDateFilterField" onclick="cmb_liclick('{$stdfilter.value}','stdDateFilterField','dv_customview_stdfiler')" onmouseover="cmb_limouseover(event,'stdDateFilterField','dv_customview_stdfiler')">{$stdfilter.text}</li>
								   {assign var="i" value=$i+1}
    							{/foreach}
    							   <li name="li_chzn_stdDateFilterField" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
    						 </ul>
    					</div>
    				</div>
  </td>
</tr>
<tr>
  <td align="right">{'SELECT_TIME'|@getFixedLabel}</td>
  <td style="overflow: inherit;">
			<select name="stdDateFilter" id="stdDateFilter" class="select" onchange='showDateRange(this.options[this.selectedIndex].value )' style="display:none">
					{assign var=special value='/\d+/'}
					{assign var=normal_last value='/last/'}
					{assign var=normal_before value='/before/'}
					{assign var=normal_next value='/next/'} 
					{assign var=day value='Days'|@getFixedLabel}
					{assign var=last value='LAST'|@getFixedLabel}
					{assign var=before value='DAYSAGO'|@getFixedLabel }
					{assign var=future value='FUTURE'|@getFixedLabel }
					{assign var=after value='AFTERDAY'|@getFixedLabel }       
    				{foreach item=duration from=$STDFILTERCRITERIA}                                             
                            {if $special|preg_match:$duration.text:$matches eq 1}                                   
                               {assign var=normal_number value=$matches[0]}
                               {if $normal_last|preg_match:$duration.text eq 1}                                   
                                   {if $duration.selected eq 'selected'}
                                     {assign var=optText value=$last|cat:$normal_number|cat:$day}
                                   {/if}
                                   <option {$duration.selected} value="{$duration.value}">{$last}{$normal_number}{$day}</option>
                               {elseif $normal_before|preg_match:$duration.text eq 1} 
                                   {if $duration.selected eq 'selected'}
                                     {assign var=optText value=$normal_number|cat:$before}
                                   {/if}                                  
                                  <option {$duration.selected} value="{$duration.value}">{$normal_number}{$before}</option>
                               {elseif $normal_next|preg_match:$duration.text eq 1} 
                                   {if $duration.selected eq 'selected'}
                                     {assign var=optText value=$future|cat:$normal_number|cat:$day}
                                   {/if}                                   
                                   <option {$duration.selected} value="{$duration.value}">{$future}{$normal_number}{$day}</option>
                               {else} 
                                    {if $duration.selected eq 'selected'}
                                      {assign var=optText value=$normal_number|cat:$after}
                                    {/if}                                       
                                   <option {$duration.selected} value="{$duration.value}">{$normal_number}{$after}</option>
                               {/if}  
                            {else}
                                   {if $duration.selected eq 'selected'}
                                      {assign var=optText value=$duration.text|@getFixedLabel}
                                    {/if} 
                                    <option {$duration.selected} value="{$duration.value}">{$duration.text|@getFixedLabel}</option>
                            {/if} 		                                     
    				{/foreach}               				   
			     	</select>
                      <div name="dv_chzn_stdDateFilter" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'stdDateFilter','dv_customview_stdfiler')" style="z-index:990;">
                         	<a style="width:110px;" class="chzn-single" onclick="com_img_change(event,'stdDateFilter','dv_customview_stdfiler')" href="javascript:void(0)" tabindex="-1"
                             name="cmb_a_stdDateFilter">
								<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_stdDateFilter' onclick="cmb_picklist_end_foucs(event,'stdDateFilter','dv_customview_stdfiler')" onKeyUp="com_chosen(event,'stdDateFilter','dv_customview_stdfiler')" value="{if $opttext neq ''}{$opttext}{else}{'custom'|@getFixedLabel}{/if}">
                                </span>
                                <div>
                                    <b></b>
                                </div>
                    	    </a>
                    	    <div style=" left:-9000px;width: 118px; top: 25px;" class="chzn-drop" name='dv_drop_stdDateFilter' >
                    			 <ul class="chzn-results" name="cmb_ul_stdDateFilter">								      
								 {assign var=special value='/\d+/'}
								 {assign var=normal_last value='/last/'}
								 {assign var=normal_before value='/before/'}
								 {assign var=normal_next value='/next/'}
								 {assign var="j" value=0}
                            	 {foreach key=User_Key item=duration from=$STDFILTERCRITERIA }                                          
									                                               
                                     {if $special|preg_match:$duration.text:$matches eq 1}                                       
                                       {assign var=normal_number value=$matches[0]}
                                       {if $normal_last|preg_match:$duration.text eq 1} 
                                            <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','dv_customview_stdfiler')" onmouseover="cmb_limouseover(event,'stdDateFilter','dv_customview_stdfiler')">{'LAST'|@getFixedLabel}{$normal_number}{'Days'|@getFixedLabel}</li>
                                       {elseif $normal_before|preg_match:$duration.text eq 1}                                     
                                           <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','dv_customview_stdfiler')" onmouseover="cmb_limouseover(event,'stdDateFilter','dv_customview_stdfiler')">{$normal_number}{'DAYSAGO'|@getFixedLabel}</li>
                                       {elseif $normal_next|preg_match:$duration.text eq 1}                                   
                                            <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','dv_customview_stdfiler')" onmouseover="cmb_limouseover(event,'stdDateFilter','dv_customview_stdfiler')">{'FUTURE'|@getFixedLabel}{$normal_number}{'Days'|@getFixedLabel}</li>
                                       {else}                                      
                                            <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','dv_customview_stdfiler')" onmouseover="cmb_limouseover(event,'stdDateFilter','dv_customview_stdfiler')">{$normal_number}{'AFTERDAY'|@getFixedLabel}</li>
                                       {/if}  
                                    {else}
                                        <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','dv_customview_stdfiler')" onmouseover="cmb_limouseover(event,'stdDateFilter','dv_customview_stdfiler')">{$duration.text|@getFixedLabel}</li>
                                    {/if}
									{assign var="j" value=$j+1}
								{/foreach}                                           
                                           <li style="" class="" name="li_chzn_stdDateFilter" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                        			 </ul>
                    	    </div>
                     </div>
  </td>
</tr>