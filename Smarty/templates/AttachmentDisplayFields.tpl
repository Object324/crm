<script src="include/jquery/jquery.min.js" type="text/javascript"></script>
<input type="hidden" value="{$PARENTID}"  name="att_record" />
<input type="hidden" value="{$PARENTMODULE}" id="related_to_type_input" name="myatt_moduel" />
<input type="hidden" value="{$PARENTID}" id="myatt_id" name="att_record" />
<input type="hidden" value="{$PARENTMODULE}" id="myatt_moduel" name="myatt_moduel" />
<input type="hidden" value="{$FIELDTYPE}" id="fieldtypeall" name="fieldtypeall" >
<input type="hidden" value="{$ATTACHMENTSID}" name="att_attachmentsid" />
<input type="hidden" value="{$RECORD}" name="att_record" id="att_record" />
<input type="hidden" value="{$TYPE}" name="att_type" />
<input type="hidden" value="{$PATH}" name="att_path" />
<tr style="height:25px">
    <td class="DetailedTd1Label" width="20%" align="right"><font color="red">*</font>{$ARRFIELDLABEL.assigned_user_id}</td>
    <td class="DetailedTd2Info" width="30%" align="left">
    {foreach key=user_id item=user_combo from=$USERCOMBO}
    	{foreach key=user_name item=fvalue from=$user_combo}
    		{if $smownerid eq $user_id}
    		<input id="dv_chzn_1_assigned_user_id" class="detailedViewTextBox" type="text" onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" value="{$user_name}" name="dv_chzn_1_assigned_user_id" tabindex="" fieldonly="1" readonly="">
    								<input type="hidden" id="smownerid" name="smownerid" value="{$user_id}">
    		{/if}
    	{/foreach}
    {/foreach}
    </td>
      <td class="DetailedTd1Label" width="20%" align="right">{$ARRFIELDLABEL.related_to}</td>
            <td  class="DetailedTd2Info">
               <select id="related_to_type" name="related_to_type" style="width:80px;">
               		{foreach key=key item=item from=$PARENTTYPE}
						<option value='{$item}' {if $item == $PARENTMODULE}selected{/if}>{$item|@getTranstab}</option>
               		{/foreach}
                </select>
            <input id="related_to_name" name="related_to_name" readonly="" style="border:1px solid #bababa;" value="{$PARENTNAME}" type="text">
            <a class="icon-homeimg icon-select" href="javascript:;" title="选择" onclick="selectRelatedTo('related_to_type','related_to','Attachment','')"></a>
            <input class="icon-homeimg icon-clear inpb-reset" type="button" title="清除" onclick="this.form.related_to.value=''; this.form.related_to_name.value=''; return false;"/>&nbsp;
         	<input id="related_to" name="related_to" value="{$PARENTID}" type="hidden">
    </td>
</tr>
<tr style="height:25px">
    <td class="DetailedTd1Label" width="20%" align="right"><font color="red">*</font>{$ARRFIELDLABEL.filename}</td>
    <td class="DetailedTd2Info" width="30%" align="left"  >
        <input id="file_name" class="detailedViewTextBox" type="text" onblur="this.className='detailedViewTextBox'" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" value="{$FILENAME}" readonly="true" tabindex="" name="file_name" fieldonly="0" size="30">
    </td>
     <td class="DetailedTd1Label" width="20%" align="right">{$ARRFIELDLABEL.isenabled}</td>
    <td class="DetailedTd2Info" width="30%" align="left">
        <select id="att_isenabled" name="att_isenabled">
            {if $ISENABLED neq 1} 
                <option id="att_isenabled_off" selected="true">{'BETOVIEWABLEPRIVATE'|@getFixedLabel}</option>
                <option id="att_isenabled_on">{'BETOVIEWABLE'|@getFixedLabel}</option>
            {else}
    			<option id="att_isenabled_off">{'BETOVIEWABLEPRIVATE'|@getFixedLabel}</option>
                <option id="att_isenabled_on" selected="true">{'BETOVIEWABLE'|@getFixedLabel}</option>
    		{/if}          
        </select>
    </td>
</tr>
<tr style="height:25px">
    <td class="DetailedTd1Label" width="20%" align="right">{'FILE'|@getFixedLabel}</td>
    <td class="DetailedTd2Info" width="30%" align="left" colspan="3" >
    </td>
    
   
</tr>  
<tr style="height:25px">
<td class="DetailedTd1Label" width="20%" align="right">{$ARRFIELDLABEL.description}</td>
<td class="DetailedTd2Info" width="80%" colspan="3" align="left">
    <textarea id="att_description" name="att_description" class="detailedViewTextBox">{$DESCRIPTION}</textarea>
</td>
</tr> 
<!--
*新增操作，条件附件上传插件 UPLOADIFY
*by andy 20131227
-->
                                    