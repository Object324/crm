<div align="left" colspan="2" class="DetailedTd2Info serviceformance_td"  id="td_cmb_{$fldname}" width="425">
    <div class="row-fluid"  id="dv_cmb_{$fldname}"  >
       
      <span class="span_{$i}">{$usefldlabel}</span>
		<span class="span10">
		{if $fldname eq 'bill_state'||$fldname eq 'servicetype'||$fldname eq 'bill_city'}
            <select name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' id="{$fldname}"  onchange="getBillCityDepency(this)" style="display:none">
         
         {else}
         <select name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' id="{$fldname}" style="display:none">         
         {/if}     
				{foreach item=arr from=$fldvalue}
                   {if $arr[2] eq 'selected'}
                    {assign var="optText" value=$arr[1]}
                  	<option value="{$arr[0]}" selected="true">
                            {$arr[1]}
                    </option>
				
					{else}
					<option value="{$arr[0]}" >
                          {$arr[1]}
                    </option>
					{/if}
				{/foreach}
                 
				
			   </select>
               <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" style="width: 285px;" onMouseLeave="cmb_mouseleave(event,'{$fldname}','table_serviceformancepick')">
    				<a class="chzn-single" onclick="com_img_change(event,'{$fldname}','table_serviceformancepick')" href="javascript:void(0)" tabindex="-1"
                     name="cmb_a_{$fldname}">
						<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 280px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','table_serviceformancepick')" onKeyUp="com_chosen(event,'{$fldname}','table_serviceformancepick')" value="{$optText}">
                        <div>
                            <b></b>
                        </div>
    				</a>
				    <div style=" left:-9000px;width: 280px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
					 <ul class="chzn-results" name="cmb_ul_{$fldname}">
							{assign var="i" value=0}
				        	{foreach item=arr from=$fldvalue name=foo}
            					{if $arr[0] eq 'NOTACCESS'|@getFixedLabel}
            				         <li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$arr[0]}','{$fldname}','table_serviceformancepick')" onmouseover="cmb_limouseover(event,'{$fldname}','table_serviceformancepick')">{$arr[0]}</li>
            					{else}
                                
            			         	<li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$arr[0]}','{$fldname}','table_serviceformancepick')" onmouseover="cmb_limouseover(event,'{$fldname}','table_serviceformancepick')">{$arr[0]}</li>
            					{/if}
								{assign var="i" value=$i+1}
				            {/foreach}
                             
                            <li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
					 </ul>
				 </div>
			 </div>
		 </span>
	 </div>
</div>