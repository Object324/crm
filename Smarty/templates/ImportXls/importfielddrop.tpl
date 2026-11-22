    {assign var='optText' value=""}
    <div class="row-fluid" >
		<span class="span10">
			
                    <select name="mapped_fields[]" id="{$fldname}"   style="display:none" onchange="defaultImportXls(this,'{$ky}')">
                
				{foreach item=drp from=$IMPORTCOLUMN}
                        {if $value.3 eq $drp.1}
                                {assign var='optText' value=$drp.2}
                                    <option value="{$drp.1}" selected="true">{$drp.2} </option>
                        {else}
                                     <option value="{$drp.1}" >{$drp.2} </option>
                        {/if}
				{/foreach}
                
			   </select>
               <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single"   style="width: 220px"  onMouseLeave="cmb_mouseleave(event,'{$fldname}','ImportXlsDiv')">
					
						<a class="chzn-single" {if $CALENDARTEMPLATEDETAILS neq ''}style="width:115px" {/if} onclick="com_img_change(event,'{$fldname}','ImportXlsDiv')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
						<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: {if $CALENDARTEMPLATEDETAILS eq ''}198px{else}123px{/if};margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','ImportXlsDiv')" onKeyUp="com_chosen(event,'{$fldname}','ImportXlsDiv')" value="{$optText}">
                        <div>
                            <b></b>
                        </div>
    				  </a>
				    <div style=" left:-9000px;width: {if $CALENDARTEMPLATEDETAILS eq ''}198px{else}123px{/if}; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
					 <ul class="chzn-results" name="cmb_ul_{$fldname}">
							{assign var="i" value=0}
				        	{foreach item=drp from=$IMPORTCOLUMN name=foo}
            			         	<li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$drp.1}','{$fldname}','ImportXlsDiv')" onmouseover="cmb_limouseover(event,'{$fldname}','ImportXlsDiv')">{{$drp.2}}</li>
            						{assign var="i" value=$i+1}
				            {/foreach}
                           
                            <li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
					 </ul>
				 </div>
			 </div>
		 </span>
  </div>
