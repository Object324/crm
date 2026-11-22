{assign var=fldname value='selectwareid'}
	<div id="warehouse_div" style="margin-top: 3px;">
    <select onchange="getMoreWarehouse(this,'morewarehouseid');return false;" id="selectwareid" name="selectwareid" style="display:none">
	{foreach key=key item=name from=$MOREWAREHOUSES}
		{if $key eq $WAREHOUSEID}
			{assign var=optText value=$name}
			<option value="{$key}" selected="true">{$name}</option>   
		{else}
			<option value="{$key}">{$name}</option>   
		{/if}
		    
	{/foreach}
    </select>
                            
    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','warehouse_div')">
     	<a style="width:117px;height:24px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','warehouse_div')" href="javascript:void(0)" tabindex="-1"
         name="cmb_a_{$fldname}">
            
			<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','warehouse_div')" onKeyUp="com_chosen(event,'{$fldname}','warehouse_div')" value="{$optText}">
            <div>
                <b></b>
            </div>
	    </a>
	    <div style=" left:-9000px;width: 117px; top: 25px;z-index:902;" class="chzn-drop" name='dv_drop_{$fldname}' >
            <ul class="chzn-results" name="cmb_ul_{$fldname}">
				{assign var="i" value=0}
				{foreach key=key item=name from=$MOREWAREHOUSES}
					<li  class="active-result" style="padding: 6px 7px;" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}','warehouse_div')" onmouseover="cmb_limouseover(event,'{$fldname}','warehouse_div')">{$name}</li>
					{assign var="i" value=$i+1}   
				{/foreach}

				<li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
			 </ul>
	    </div>
    </div> 
 
    {if $show eq 1}
    <a class="icon-range" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}"  onclick="SmOwnerScopehightuser()"></a>
    {/if}
	</div>