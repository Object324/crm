<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/multipingyin.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/picklist.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="{$CSSURL}themes/softed/PickList.css"/>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js"></script>
<script language="JavaScript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/treeview/jquery.treeview.js"></script>
<link rel="stylesheet" type="text/css" href="{$CRMCOMMONURL}crmcommon/css/treeview/jquery.treeview.css" />
{assign var='fldname' value='SmOwnerSearchScope'}
{assign var='DISPLAYVALUE' value=''}
{assign var='fldname_width' value='180'}
<div class="row-fluid ld-form-item-content" id="dv_cmb_{$fldname}">
	<span class="span10">
		<select class="Select" id="{$fldname}" name="{$fldname}" style='display:none;' onchange="get_search_senior(this)">
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
	   	<div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" style="width: {$fldname_width}px;" onMouseLeave="cmb_mouseleave(event,'{$fldname}','dv_cmb_{$fldname}')">
			 <a class="chzn-single" onclick="com_img_change(event,'{$fldname}','dv_cmb_{$fldname}')" href="javascript:void(0)" tabindex="-1"
			 name="cmb_a_{$fldname}" style="width: {$fldname_width}px;" >
				<div class="ld-select-inner-input" contenteditable="true" style="width: {$fldname_width}px;margin-left: -10px;border-style:none;padding-left: 8px;position: relative;" tabindex="0"
                     name='cmb_span_optiontext_{$fldname}' picklisttype="smownerpicklist" onclick="CrmPopup.getPopupObj('last').picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}','dv_cmb_{$fldname}')" >
                {$DISPLAYVALUE}
                </div>
				<div>
					<b></b>
				</div>
			 </a>
			 <div style=" left:-9000px;width: {$fldname_width}px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
				 <ul class="chzn-results" id="cmb_ul_{$fldname}">
					{assign var="foreachi" value="0"}
					{foreach key=User_Key item=User_value from=$Merge_SmOwner}
						{foreach key=User_id item=User_name from=$User_value}
							{foreach key=User_name_key item=User_name_value from=$User_name}
								<li userid='{$User_id}' picklisttype="smownerpicklist" class="active-result" name="dv_chzn_{$foreachi}_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','dv_cmb_{$fldname}');" onmouseover="cmb_limouseover(event,'{$fldname}','dv_cmb_{$fldname}')">{$User_name_key}</li>
								{assign var="foreachi" value=$foreachi+1}
							{/foreach}
						{/foreach}
					{/foreach}
						<li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
				 </ul>
			</div>
		</div>
	</span>
</div>