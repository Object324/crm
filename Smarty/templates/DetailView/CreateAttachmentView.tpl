{*<!--

/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
*
 ********************************************************************************/

-->*}
<!--
zyh
用户详情页增加附件
PROT197 
20150420
-->
<!-- {*if $PARENTID eq ''*} -->
    {if $USERID eq ''}
        <tr>
			<td class="DetailedTd1Label" width="20%" align="right"><font color="red">*</font>{$ARRFIELDLABEL.assigned_user_id}</td>
			<td  class="DetailedTd2Info">
				<!-- <select name="smownerid" id="smownerid">
				{foreach key=user_id item=user_combo from=$USERCOMBO}
					{foreach key=user_name item=fvalue from=$user_combo}
						<option value="{$user_id}" {if $smownerid eq $user_id} selected {/if}>{$user_name}</option> 
					{/foreach}
				{/foreach}
				</select> -->
				
				<!-- 附件 负责人 begin -->
					{assign var="fldname" value="smownerid"}
						<div class="row-fluid"  id="dv_cmb_{$fldname}">
						   <span class="span10">
								<span id="assign_user" style="{$style_user}">
								<select name="{$fldname}" id="{$fldname}" class="small" style="display:none" >
									{foreach key=user_id item=user_combo from=$USERCOMBO}
										{foreach key=user_name item=fvalue from=$user_combo}
											<option value="{$user_id}" {if $smownerid eq $user_id} selected {assign var="optText" value=$user_name}
											{/if}>{$user_name}</option> 
										{/foreach}
									{/foreach}
								</select>
							</span>
							 <div id="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" style="width: 245px;">
							<a class="chzn-single" onclick="com_img_change(event,'{$fldname}')" href="javascript:void(0)" tabindex="-1" id="cmb_a_{$fldname}">
								<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 190px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}')" value="{$optText}">
								<!--
								<span class="changeImg_down" onclick="com_img_change(event,'{$fldname}')" id="cmb_span_{$fldname}">&nbsp;&nbsp;&nbsp;&nbsp;	
								</span>
								-->
								<div>
									<b></b>
								</div>
							</a>
							<div style=" left:-9000px;width: 198px; top: 25px;" class="chzn-drop" id='dv_drop_{$fldname}' onMouseLeave="cmb_mouseleave(event,'{$fldname}')">
								 <ul class="chzn-results">
									{assign var="i" value=0}
									{foreach key=user_id item=user_combo from=$USERCOMBO name=foo}
										{foreach key=user_name item=fvalue from=$user_combo}
											<li style="" class="active-result" id="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$user_id}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$user_name}</li>
											{assign var="i" value=$i+1}
										{/foreach}
									{/foreach}
										<li style="" class="" id="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
								 </ul>
							 </div>
						 </div>
					 </span>
				 </div>
				<!-- 附件 负责人 end -->

			</td>

            <td class="DetailedTd1Label" width="20%" align="right">{$ARRFIELDLABEL.related_to}</td>
            <td  class="DetailedTd2Info">
               <select id="related_to_type" name="related_to_type" style="width:80px;">
               		{foreach key=key item=item from=$PARENTTYPE}
						<option value='{$item}' {if $item == $PARENTMODULE}selected{/if}>{$item|@getTranstab}</option>
               		{/foreach}
                </select>
            <input id="related_to_name" name="related_to_name" readonly="" style="border:1px solid #bababa;" value="{$PARENTNAME}" type="text">
            <a class="icon-homeimg icon-select" href="javascript:;"  title="选择" onclick="selectRelatedTo('related_to_type' ,'related_to','Attachment','')"></a>
            <input class="icon-homeimg icon-clear inpb-reset" type="button" title="清除"  onclick="this.form.related_to.value=''; this.form.related_to_name.value=''; return false;"/>&nbsp;
         	<input id="related_to" name="related_to" value="{$PARENTID}" type="hidden">
           </td>
        </tr>
    {else}
        <input id="related_to" name="related_to" value="{$USERID}" type="hidden"/>
        <input id="related_to_type" name="related_to_type" value="Users" type="hidden"/>
		<input id="smownerid" name="smownerid" value="{$USERID}" type="hidden"/>
    {/if}
 <!--{* {else}
    <input id="related_to" name="related_to" value="{$PARENTID}" type="hidden">   
    <input id="related_to_type" name="related_to_type" value="{$PARENTMODULE}" type="hidden">      
       	  
            
{/if} *}-->	
<input type="hidden" value="{$FIELDTYPE}" id="fieldtypeall" name="fieldtypeall" >
<tr style="height:25px">
<td class="DetailedTd1Label" width="20%" align="right"><font color="red">*</font>{$ARRFIELDLABEL.filename}</td>
<td class="DetailedTd2Info" width="30%" align="left">
    <input id="file_name" class="detailedViewTextBox" type="text" onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" value="" tabindex="" readonly="true" name="file_name" fieldonly="0">
</td>
<td class="DetailedTd1Label" width="20%" align="right">{$ARRFIELDLABEL.isenabled}</td>
<td class="DetailedTd2Info" width="30%" align="left">
    <select id="att_isenabled" name="att_isenabled">
        <option id="att_isenabled_on">{'BETOVIEWABLE'|@getFixedLabel}</option>
        <option id="att_isenabled_off">{'BETOVIEWABLEPRIVATE'|@getFixedLabel}</option>
    </select>
</td>
</tr>
<tr>
    <td class="DetailedTd1Label" width="20%" align="right">{'FILE'|@getFixedLabel}</td>
    <td class="DetailedTd2Info" width="30%" align="left" colspan="3">
    </td>
    
</tr>
<tr>
<td class="DetailedTd1Label" width="20%" align="right">{$ARRFIELDLABEL.description}</td>
<td class="DetailedTd2Info" width="80%" colspan="3" align="left">
    <textarea id="att_description" name="att_description" class="detailedViewTextBox"></textarea>
</td>
</tr> 
<!--
*新增操作，条件附件上传插件 UPLOADIFY
*by andy 20131227
-->                       