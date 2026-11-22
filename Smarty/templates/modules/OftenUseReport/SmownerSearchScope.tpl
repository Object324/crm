<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/multipingyin.js"></script>
<!--	opts start  -->
{assign var='fldname' value='SmOwnerSearchScope'}
{assign var='DISPLAYVALUE' value=''}
{assign var='fldname_width' value='170'}
<div class="row-fluid"  id="dv_cmb_{$fldname}"  >
	<span class="span10">
		<select class="Select" id="{$fldname}" name="{$fldname}" style='display:none;'  onchange="get_search_senior(this)">
		{foreach key=User_Key item=User_value from=$Merge_SmOwner}
			{foreach key=User_id item=User_name from=$User_value}
				{foreach key=User_name_key item=User_name_value from=$User_name}
					{if $DISPLAYVALUE == ''}
						{assign var='DISPLAYVALUE' value=$User_name_key}
					{/if}
					<option value="{$User_id}"
					{if $User_id eq $SmOwnerSearchScope}
						selected="true"
						{assign var='DISPLAYVALUE' value=$User_name_key}
					{/if}>{$User_name_key}</option>
				{/foreach}
			{/foreach}
		{/foreach}
		</select>
        <input type="hidden" name="selectuserid" id="selectuserid" value="{$selectuserid}">
	   <div id="dv_chzn_{$fldname}" class="chzn-container chzn-container-single"   style="width: {$fldname_width}px;"  onMouseLeave="cmb_mouseleave(event,'{$fldname}')">
			<a class="chzn-single" onclick="com_img_change(event,'{$fldname}')" href="javascript:void(0)" tabindex="-1"
			 id="cmb_a_{$fldname}" style="width: {$fldname_width-10}px;" >
				<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: {$fldname_width-15}px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','')" onKeyUp="com_chosen(event,'{$fldname}','')" value="{$DISPLAYVALUE}">
				<div>
					<b></b>
				</div>
			</a>
			<div style=" left:-9000px;width: {$fldname_width-2}px; top: 25px;" class="chzn-drop" id='dv_drop_{$fldname}' >
			 <ul class="chzn-results" id="cmb_ul_{$fldname}">
				{assign var="foreachi" value="0"}
				{foreach key=User_Key item=User_value from=$Merge_SmOwner}
					{foreach key=User_id item=User_name from=$User_value}
						{foreach key=User_name_key item=User_name_value from=$User_name}
							<li style="" class="active-result" id="dv_chzn_{$foreachi}_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}');" onmouseover="cmb_limouseover(event,'{$fldname}')">{$User_name_key}</li>
							{assign var="foreachi" value=$foreachi+1}
						{/foreach}
					{/foreach}
				{/foreach}
					<li style="" class="" id="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
			 </ul>
			</div>
		 </div>
	 </span>
 </div>
 
 <!--	opts end  -->