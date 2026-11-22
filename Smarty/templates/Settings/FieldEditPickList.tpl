<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/multipingyin.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/picklist.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="{$CSSURL}themes/softed/PickList.css"/>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js"></script>
<script language="JavaScript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/treeview/jquery.treeview.js"></script>
<link rel="stylesheet" type="text/css" href="{$CRMCOMMONURL}crmcommon/css/treeview/jquery.treeview.css" />
<!--	opts start  -->
{assign var='_FIELD_COLUMNNAME_width' value='160'}

<div class="row-fluid"  style="height:25px; line-height: 25px;" id="dv_cmb_{$_FIELD_COLUMNNAME}">
	<span class="span10">
		<select class="Select" style='display:none;' name="{$_FIELD_COLUMNNAME}" id="{$_FIELD_ELEMENT_ID}">
			{foreach key=key item=item from=$defaultsetting._allvalues}
				<option value="{$item}"
				{if $defaultsetting.value eq $item} selected="true" {/if}>{$item}</option>
			{/foreach}
		</select>
{*        <input type="hidden" name="leadsource" id="{$_FIELD_ELEMENT_ID}" value="{$selectuserid}">*}
	   	<div name="dv_chzn_{$_FIELD_COLUMNNAME}" class="chzn-container chzn-container-single" style="width: {$_FIELD_COLUMNNAME_width}px;" onMouseLeave="cmb_mouseleave(event,'{$_FIELD_COLUMNNAME}','dv_cmb_{$_FIELD_COLUMNNAME}')">
			<a class="chzn-single" onclick="com_img_change(event,'{$_FIELD_COLUMNNAME}','dv_cmb_{$_FIELD_COLUMNNAME}')" href="javascript:void(0)" tabindex="-1"
               name="cmb_a_{$_FIELD_COLUMNNAME}" style="width: {$_FIELD_COLUMNNAME_width}px;" >
				  <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: {$_FIELD_COLUMNNAME_width-15}px;margin-left: -10px;border-style:none;color: {$_allvaluecolors.$_FIELD_SELECTED_VALUE};" tabindex="0"  name='cmb_span_optiontext_{$_FIELD_COLUMNNAME}' onclick="cmb_picklist_end_foucs(event,'{$_FIELD_COLUMNNAME}','dv_cmb_{$_FIELD_COLUMNNAME}')" onKeyUp="com_chosen(event,'{$_FIELD_COLUMNNAME}','dv_cmb_{$_FIELD_COLUMNNAME}')" value="{$_FIELD_SELECTED_VALUE}">
				<div>
					<b></b>
				</div>
			</a>
			<div style=" left:-9000px;width: {$_FIELD_COLUMNNAME_width}px;{if $MODULE eq 'Users' && $value.columnname eq 'gender'}top: 30px;{else}top: 24px;{/if}" class="chzn-drop" name='dv_drop_{$_FIELD_COLUMNNAME}' >
				<ul class="chzn-results" id="cmb_ul_{$_FIELD_COLUMNNAME}">
				{assign var="foreachi" value="0"}
                {*duan 20220808 BUG0053408 下拉框字段默认值设置增加空选项值*}
				{if $MODULE eq 'Users' && $value.columnname eq 'gender'}
				{else}
                	<li  style="color:{$_allvaluecolors.$item};" class="active-result" name="dv_chzn_{$foreachi}_{$_FIELD_COLUMNNAME}"  onclick="cmb_liclick('','{$_FIELD_COLUMNNAME}','dv_cmb_{$_FIELD_COLUMNNAME}');cmb_defaultvalue_checked(this,'select','{$_FIELD_ID}','{$_FIELD_COLUMNNAME}');" onmouseover="cmb_limouseover(event,'{$_FIELD_COLUMNNAME}','dv_cmb_{$_FIELD_COLUMNNAME}')" ></li>
                {/if}
				{assign var="foreachi" value=$foreachi+1}
				 {foreach key=key item=item from=$defaultsetting._allvalues}

					 <li  style="color:{$_allvaluecolors.$item};" class="active-result" name="dv_chzn_{$foreachi}_{$_FIELD_COLUMNNAME}"  onclick="cmb_liclick('{$item}','{$_FIELD_COLUMNNAME}','dv_cmb_{$_FIELD_COLUMNNAME}');cmb_defaultvalue_checked(this,'select','{$_FIELD_ID}','{$_FIELD_COLUMNNAME}');" onmouseover="cmb_limouseover(event,'{$_FIELD_COLUMNNAME}','dv_cmb_{$_FIELD_COLUMNNAME}')" >{$item}</li>
					 {assign var="foreachi" value=$foreachi+1}
                 {/foreach}
					<li style="" class="" name="li_chzn_{$_FIELD_COLUMNNAME}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
			 </ul>
			</div>
		 </div>
		{* wym XUQIU20240204-09 销售线索可编辑追踪字段*}
		{if $MODULE eq 'Users' && $value.columnname eq 'gender' }
		{else}
		 <b onclick="getCombox('{$MODULE}','{$value.fieldname}')" title="{'SETTINGS'|@getFixedLabel}" class="icon-picklist-set" style="cursor:pointer; margin-left: 6px;"></b>
		{/if}
     </span>

</div>

<!--	opts end  -->