	<td width="20%" class="DetailedTd1Label" align="right">
			{$usefldlabel}
	</td>
	<td width="30%" align="left" class="DetailedTd2Info">
        <div class="row-fluid"  id="dv_cmb_assigned_user_id"  >
    	   <span class="span10">
		
				<span id="assign_user" style="{$style_user}">
                 
					<select name="assigned_user_id" id="assigned_user_id" style="display:none" >
                       {foreach item=lastname key=userid from=$ALLOCATEUSERS }
                          <option value="{$userid}">{$lastname}</option>
                        {/foreach}
					</select>
                    
				</span>
                 <div id="dv_chzn_assigned_user_id" class="chzn-container chzn-container-single"   style="width: 110px;">
				<a class="chzn-single" style="width:110px;" onclick="com_img_change(event,'assigned_user_id')" href="javascript:void(0)" tabindex="-1" id="cmb_a_assigned_user_id">
					<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_assigned_user_id' onclick="cmb_picklist_end_foucs(event,'assigned_user_id')" onKeyUp="com_chosen(event,'assigned_user_id')" value="{$optText}">
                    <div>
                        <b></b>
                    </div>
				</a>
				<div style=" left:-9000px;width: 118px; top: 25px;" class="chzn-drop" id='dv_drop_assigned_user_id' onMouseLeave="cmb_mouseleave(event,'assigned_user_id')">
					 <ul class="chzn-results">
						{assign var="i" value=0}
					   {foreach item=lastname key=userid name=foo from=$ALLOCATEUSERS  }
							<li style="" class="active-result" id="dv_chzn_{$smarty.foreach.foo.iteration }_assigned_user_id" onclick="cmb_liclick('{$userid}','assigned_user_id')" onmouseover="cmb_limouseover(event,'assigned_user_id')">{$lastname}</li>
							{assign var="i" value=$i+1}
					   {/foreach}
                        <li style="" class="" id="li_chzn_assigned_user_id" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
					 </ul>
				 </div>
			 </div>
		 </span>
	 </div>
</td>