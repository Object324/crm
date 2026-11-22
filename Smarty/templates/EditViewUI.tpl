{*修改编码格式:统一编码：UTF-8*}
		{assign var="uitype" value="$maindata[0][0][0]"}
        {assign var="fieldonly" value="$maindata[0][1][0]"}
		{assign var="fldlabel" value="$maindata[1][0]"}
		{assign var="fldlabel_sel" value="$maindata[1][1]"}
		{assign var="fldlabel_combo" value="$maindata[1][2]"}
		{assign var="fldlabel_other" value="$maindata[1][3]"}
		{assign var="fldname" value="$maindata[2][0]"}
		{assign var="fldvalue" value="$maindata[3][0]"}
		{assign var="secondvalue" value="$maindata[3][1]"}
		{assign var="thirdvalue" value="$maindata[3][2]"}
		{assign var="typeofdata" value="$maindata[4]"}
	 	{assign var="vt_tab" value="$maindata[5][0]"}
		{if $typeofdata eq 'M'}
			{assign var="mandatory_field" value="*"}
		{else}
			{assign var="mandatory_field" value=""}
		{/if}
		{* vtlib customization: Help information for the fields *}
		{assign var="usefldlabel" value=$fldlabel}
		{assign var="fldhelplink" value=""}
        <!--$uitype值为 2 26 53 4 19 28 56 27 1 -->
		{if $FIELDHELPINFO && $FIELDHELPINFO.$fldname}
			{assign var="fldhelplinkimg" value='help_icon.gif'|@lingdang_imageurl:$THEME}
		
          	<!--assign var="fldhelplink" value="<img style='cursor:pointer' onclick='vtlib_field_help_show(this, \"$fldname\");' border=0 src='$fldhelplinkimg'>"-->
           
            
			{if $uitype neq '10'}
				{assign var="usefldlabel" value="$fldlabel $fldhelplink"}
			{/if}
		{/if}
		{* END *}
		{* vtlib customization *}
        {*//uitype10uitype*}    
		{if $uitype eq '10'}
		<td width=20% class="dvtCellLabel" align=right>
			<font color="red">{$mandatory_field}</font>
			{$fldlabel.displaylabel}

			{if count($fldlabel.options) eq 1}
				{assign var="use_parentmodule" value=$fldlabel.options.0}
               
				<input type='hidden' class='small' name="{$fldname}_type" value="{$use_parentmodule}"/>
			{else}
			
    			{if $fromlink eq 'qcreate'}
    			<select id="{$fldname}_type" fieldonly='{$fieldonly}' class="small" name="{$fldname}_type" onChange='document.QcEditView.{$fldname}_name.value=""; document.QcEditView.{$fldname}.value="";'>
    			{else}
    			<select id="{$fldname}_type"  fieldonly='{$fieldonly}' class="small" name="{$fldname}_type" onChange='document.EditView.{$fldname}_name.value=""; document.EditView.{$fldname}.value="";ld("#qcform").innerHTML=""'>
                {/if}
                    {foreach item=option from=$fldlabel.options}
                    <!--
                    更新操作
                    date:20140218
                    reason:联系记录增加创建提醒功能
                    by andy
                    -->
                        {if $MODULE eq 'Reminds'&&($option eq 'Calendar')}
                        {else}
        				<option value="{$option}"
        				{if $fldlabel.selected == $option}selected{/if}>
        				{$option|@getTranstab}
        				</option>
                        {/if}
        			{/foreach}
			 </select>
			{/if}
			{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			{$fldhelplink}

			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input id="{$fldname}" name="{$fldname}" type="hidden" value="{$fldvalue.entityid}" id="{$fldname}">
				<input id="{$fldname}_name" name="{$fldname}_name" id="edit_{$fldname}_name" readonly type="text" style="border:1px solid #bababa;" value="{$fldvalue.displayvalue}">
				{if $fromlink eq 'qcreate'}
				<a class="icon-homeimg icon-select" href="javascript:;"  tabindex="{$vt_tab}"
                     title="{'SELECT'|@getFixedLabel}" onclick='return window.open("index.php?module="+ document.QcEditView.{$fldname}_type.value +"&action=Popup&html=Popup_picker&form=vtlibPopupView&forfield={$fldname}&srcmodule={$MODULE}&forrecord={$ID}","test","width=840,height=602,resizable=1,scrollbars=1,top=150,left=200");'></a>
				{else}
				<a class="icon-homeimg icon-select" href="javascript:;"  tabindex="{$vt_tab}"
                    title="{'SELECT'|@getFixedLabel}" onclick="selectRelatedTo(document.EditView.{$fldname}_type.value ,'{$fldname}','{$MODULE}','{$ID}')"></a>
				{/if}
				<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" 	onclick="this.form.{$fldname}.value=''; this.form.{$fldname}_name.value=''; return false;"/>&nbsp;
			</td>
		{* END *}
		{elseif $uitype eq 2}
			<td width=20% class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small">{/if}
			</td>
			<td width=30% align=left class="dvtCellInfo">
            {*客户查重*}
                {if $fldname eq 'accountname' && $MODULE neq 'BankAccountSet'}  
                    <input type="text" fieldonly='{$fieldonly}' name="{$fldname}" tabindex="{$vt_tab}" value="{$fldvalue}" tabindex="{$vt_tab}" class="detailedViewTextBox" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'" style="width:70%;float:left;" id="account_name_check"/> 
                    {if $MODULE|@isPermitted:'accountdatadup'  eq 'yes'}
                    <input type="button" id="check" name="check" onclick="look_check_repeat();" class="Button_clearD" value="{'CHECK'|@getFixedLabel}" style="float:left;margin-left:5px;"/>
                    {/if}
                    <div id="check_repeat" class="D_pop_box LdPopWidth600px" style="display:none;position:absolute;">
                        <div class="Title"><img src="{$IMAGEURL}themes/softed/tier/icon_loto.png?v={$GLOBALMINVERSION}" class="Logo" /><span class="Name">{'CHECK'|@getFixedLabel}</span>
                    		<a href="javascript:fninvshnew('check_repeat');">
                    			<img src="{$IMAGEURL}themes/softed/tier/icon_close.png?v={$GLOBALMINVERSION}" class="Close" />
                    		</a>
                    	</div>                        	
                        <div class="Content_div">
                        	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                              <tr>
                                <td class="Note">
                    			{if $CREATE eq 'true'}
                    				<ul class="LdPop_ul10" id="accounts">
                    					<li><span>{$usefldlabel}:</span></li>
                    					<li class="A"><input type="text" name="cheack_repeat_accountname" id="cheack_repeat_accountname" size="25" value="{$accountvalue}"  onfocus="cleanall();" />&nbsp;&nbsp;&nbsp;</li>
                    					<li class="B"><input type="button" id="check" name="check" onclick="search_account();" value="{'FINDNOW'|@getFixedLabel}"/></li>
                    				</ul>
                    			{else}
                    				<ul class="LdPop_ul10" id="accounts">
                    					<li><span>{$usefldlabel}:</span></li>
                    					<li class="A"><input type="text" name="cheack_repeat_accountname" id="cheack_repeat_accountname" value="{$fldvalue}" onfocus="cleanall();" />&nbsp;&nbsp;&nbsp;</li>
                    					<li class="B"><input onclick="search_account();" type="button" id="check" name="check" size="25" value="{'FINDNOW'|@getFixedLabel}"/></li>
                    				</ul>
                    			{/if}
                    				<ul class="LdPop_ul10">
                    					<li><span>{'NOTECHECKCUSTOMERS'|@getFixedLabel}</span></li>
                    				</ul>							
                                </td>
                              </tr>
                            </table>
                        </div>
                        <div id="accounts_table_all" style="padding:1px;font-size: 12px;">
                          
                        </div>
                    </div>
            {else} 
				<input type="text" fieldonly='{$fieldonly}' name="{$fldname}" tabindex="{$vt_tab}" value="{$fldvalue}" tabindex="{$vt_tab}" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'">
			{/if}    
            </td>
        {elseif $uitype eq 70}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="31%" align=left class="dvtCellInfo">
               <table>
                 <tr>
                 <td>
                 <input name="{$fldname}"  type="hidden" value="{$fldvalue.0}">
				<input name="date_only" id="jscal_field_{$fldname}"  style="border:1px solid #bababa;" size="15" maxlength="10" value="{$fldvalue.0}" onClick="WdatePicker()" class="Wdate">
                <input type="hidden" name="time_reminds" id="time_reminds">
				</td>
                <td>
                 <!--<img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_{$fldname}">-->
                </td>
                <td>
                        {$fldvalue.1}                
                 </td>
                 </tr>
                 </table>
                {foreach key=date_format item=date_str from=$secondvalue}
					{assign var=dateFormat value="$date_format"}
					{assign var=dateStr value="$date_str"}
				{/foreach}
                 
				<!--<script type="text/javascript" id='massedit_calendar_{$fldname}'>
					Calendar.setup ({ldelim}
						inputField : "jscal_field_{$fldname}", ifFormat : "{$dateFormat}", showsTime : false, button : "jscal_trigger_{$fldname}", singleClick : true, step : 1
					{rdelim})
				</script>-->
			</td>
            
            {elseif $uitype eq 86}          
         <td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			{foreach key=date_format item=date_str from=$secondvalue}
					{assign var=dateFormat value="$date_format"}
					{assign var=dateStr value="$date_str"}
                    {assign var=timeformat value="%H:%M:%S"}
				{/foreach}
			<td width="32%" align=left class="dvtCellInfo">
               <table>
                 <tr>
                 <td>
				<input name="{$fldname}" id="jscal_field_{$fldname}"  style="border:1px solid #bababa;width:150px;" size="15" maxlength="25" value="{$fldvalue.0}" onClick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim})" class="Wdate">
                <input type="hidden" name="time_reminds" id="time_reminds">
				</td>
                <td>
                 <!--<img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_{$fldname}">-->
                </td>              
                 </tr>
                 </table>
                
				<!--<script type="text/javascript" id='massedit_calendar_{$fldname}'>
					Calendar.setup ({ldelim}
						inputField : "jscal_field_{$fldname}", ifFormat : "{$dateFormat} {$timeformat}", showsTime : true, button : "jscal_trigger_{$fldname}", singleClick : true, step : 1
					{rdelim})
				</script>-->
			</td>
		{elseif $uitype eq 3 || $uitype eq 4}<!-- Non Editable field, only configured value will be loaded -->
                <td width=20% class="dvtCellLabel" align=right>
                <font color="red">{$mandatory_field}</font>{$usefldlabel} 
                {if $MASS_EDIT eq '1'}
                <input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small">
                {/if}
                </td>
                <td width=30% align=left class="dvtCellInfo"><input readonly type="text" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" {if $MODE eq 'edit'} value="{$fldvalue}" {else} value="{$MOD_SEQ_ID}" {/if} class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'"></td>
		                          
        {elseif $uitype eq 11 || $uitype eq 1 || $uitype eq 13 || $uitype eq 7}
           

		
            <td width=20% class="dvtCellLabel" align=right><font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}</td>
            
            
			{if $fldname eq 'tickersymbol' && $MODULE eq 'Accounts'}
				<td width=30% align=left class="dvtCellInfo">
					<input fieldonly='{$fieldonly}' type="text" name="{$fldname}" tabindex="{$vt_tab}" id ="{$fldname}" value="{$fldvalue}" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh';" onBlur="this.className='detailedViewTextBox';{if $fldname eq 'tickersymbol' && $MODULE eq 'Accounts'}sensex_info(){/if}">
					<span id="vtbusy_info" style="display:none;">
					<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
				</td>
			{else}
                {if $fldname eq "approveby"}
                    <td width=30% align=left class="dvtCellInfo">
                        
                        <input fieldonly='{$fieldonly}' type="hidden" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$last_name[0].id}" />
                        <div type="text" id="approveby_name" name="approveby_name">{$last_name[0].last_name}</div>
                         <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" 
                         onclick=" window.open('index.php?module=Users&action=Popup','test','width=840,height=602,resizable=1,scrollbars=1,top=150,left=200');"></a>  
                    </td>
                {else}
                     <td width=30% align=left class="dvtCellInfo"><input fieldonly='{$fieldonly}' type="text" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'"  style="width:58%;height: 25px;line-height: 25px;border: 1px solid #bababa;" onBlur="this.className='detailedViewTextBox'"></td>
                {/if}   
            {/if}
		{elseif $uitype eq 9}
			<td width=20% class="dvtCellLabel" align=right><font color="red">{$mandatory_field}</font>{$usefldlabel}  {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}</td>
			<td width=30% align=left class="dvtCellInfo"><input type="text"  fieldonly='{$fieldonly}' tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'"></td>
		{elseif $uitype eq 19 || $uitype eq 20}
			<!-- In Add Comment are we should not display anything -->
            {*edit:can date:20130912; reason:常见问答中有两个textarea,所以要加<tr>*}
            {if $MODULE eq 'Faq'}
            <tr>
            {/if}
			{if $fldlabel eq 'ADDCOMMENT'|@getFixedLabel}
				{assign var=fldvalue value=""}
			{/if}
			<td width=20% class="dvtCellLabel" align=right>
					<font color="red">{$mandatory_field}</font>
				{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td colspan=3 class="dvtCellInfo">
            <!--add lmx 20140228 0007266: 刘总建议：客户。联系人等模块新增界面：描述信息区块中的描述及备注字段太大，只要保留两行的高度就好-->
			<!--<textarea class="detailedViewTextBox" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' onFocus="this.className='commonDetailedTextBox bgcolordh'" name="{$fldname}"  onBlur="this.className='detailedViewTextBox'" cols="90" rows="4"></textarea>
				-->
  	          <textarea class="detailedViewTextBox" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" name="{$fldname}" onBlur="this.className='detailedViewTextBox'" cols="90" style="height:30px" >{$fldvalue}</textarea>
                {if $fldlabel eq $MOD.Solution}
				<input type = "hidden" name="helpdesk_solution" value = '{$fldvalue}'>
				{/if}
			</td>
              {if $MODULE eq 'Faq' }
                </tr>
            {/if}
        {elseif $uitype eq 230 }
        
                <td width=20% class="dvtCellLabel" align=right>
                    {$usefldlabel}<br /><input type='button' id="Rich{$fldname}" class="edit" value="{'CALLTEMPLATE'|@getFixedLabel}"/>
                </td>
                <td colspan="3">
                	<textarea class="detailedViewTextBox" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" name="{$fldname}"  onBlur="this.className='detailedViewTextBox'" cols="90" style="height:30px">{$fldvalue}</textarea>
                </td>
           
		{elseif $uitype eq 21 || $uitype eq 24}
			<td width=20% class="dvtCellLabel" align=right>
					<font color="red">{$mandatory_field}</font>
				{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width=30% align=left class="dvtCellInfo">
				<textarea value="{$fldvalue}" name="{$fldname}" tabindex="{$vt_tab}" class="detailedViewTextBox" onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'" style="height:30px">{$fldvalue}</textarea>
			</td>
        {elseif $uitype eq 15}
        
		{elseif  $uitype eq 16  || $uitype eq '31' || $uitype eq '32'}
			<td width="20%" class="dvtCellLabel"  align=right>
				<font color="red">
                {$mandatory_field}
                </font>
              
              {$usefldlabel}
                {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left  class="dvtCellInfo">
				{if $MODULE eq 'Calendar'}
			   		<select name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}'  class="small" style="width:160px;">
				{elseif ( $fldname eq 'accountallview' ||$fldname eq 'level')&&$IS_ADMIN eq false}
                 <select name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' id="{$fldname}" class="small" disabled="true">
                {else}
                    <select name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' id="{$fldname}" class="small">
                {/if}
				{foreach item=arr from=$fldvalue}
					{if $arr[0] eq 'NOTACCESS'|@getFixedLabel}
					<option value="{$arr[0]}" {$arr[2]}>
						{$arr[0]}
					</option>
					{else}
					<option value="{$arr[0]}" {$arr[2]}>
                                                {$arr[0]}
                                        </option>
					{/if}
				{/foreach}
                {if $fldname eq 'level'}
                    {foreach item=value key=key from=$level}
                        {if $level_show == $key  && $level_show neq '' || $level_show_user == $key  && $level_show_user neq ''}
                        <option value="{$key}" selected="ture">{$value}</option>
                        {else}
                        <option value="{$key}">{$value}</option>
                        {/if}
                    {/foreach}
                {elseif $fldname eq 'approvestatus'}
                    {foreach item=value key=key from=$approvestatus}
                            {if $MODE eq 'edit'}
                                {if $approvestatus_show == $key  && $approvestatus_show neq '' || $approvestatus_show_user == $key  && $approvestatus_show_user neq ''}
                                <option value="{$key}" selected="selected">{$value}</option>
                                {else}
                                <option value="{$key}">{$value}</option>
                                {/if}
                            {else}
                                {if $key eq '1'}
                                <option value="{$key}" selected="selected">{$value}</option>
                                {else}
                                <option value="{$key}">{$value}</option>
                                {/if}
                            {/if}
                    {/foreach}
                {else}                                           
                {/if}  
				
			   </select>
			</td>
   		{elseif $uitype eq 252 || $uitype eq 251 }
			<td width="20%" class="dvtCellLabel"  align=right>   
            				<font color="red">{$mandatory_field}</font>
              {$usefldlabel}
                {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left  class="dvtCellInfo">
			   		<select name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' id='{$uitype}' class="small" style="width:160px;">
				{foreach item=arr from=$fldvalue}
					<option value="{$arr[0]}" {$arr[2]}>{$arr[1]}</option>		
				{/foreach}
			   </select>
			</td>
        {elseif $uitype eq 1021 || $uitype eq 1022 ||$uitype eq 1023}
        
       	    <td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>
				{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				{if $MODULE eq 'Calendar'}
			   		<select name="{$fldname}" tabindex="{$vt_tab}" fieldonly='{$fieldonly}'  class="small" style="width:160px;">
				{else}
			   		<select name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' class="small">
			   	{/if}
				{foreach item=arr from=$fldvalue}
					{if $arr[0] eq 'NOTACCESS'|@getFixedLabel}
					<option value="{$arr[0]}" {$arr[2]}>
						{$arr[0]}
					</option>
					{else}
					<option value="{$arr[0]}" {$arr[2]}>
                                                {$arr[0]}
                                        </option>
					{/if}
				{foreachelse}
					<option value=""></option>
					<option value="" style='color: #777777' disabled>--{'NONE'|@getFixedLabel}--</option>
				{/foreach}
			   </select>
			</td>
		{elseif $uitype eq 33}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
			   <select MULTIPLE name="{$fldname}[]" size="4" style="width:160px;" id="{$fldname}" tabindex="{$vt_tab}" class="small">
				{foreach item=arr from=$fldvalue}
					<option value="{$arr[1]}" {$arr[2]}>
                                                {$arr[0]}
                                        </option>
				{/foreach}
			   </select>
			</td>

		{elseif $uitype eq 53}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				{assign var=check value=1}
				{foreach key=key_one item=arr from=$fldvalue}
					{foreach key=sel_value item=value from=$arr}
						{if $value ne ''}
							{assign var=check value=$check*0}
						{else}
							{assign var=check value=$check*1}
						{/if}
					{/foreach}
				{/foreach}

				{if $check eq 0}
					{assign var=select_user value='checked'}
					{assign var=style_user value='display:block'}
					{assign var=style_group value='display:none'}
				{else}
					{assign var=select_group value='checked'}
					{assign var=style_user value='display:none'}
					{assign var=style_group value='display:block'}
				{/if}

				<input type="radio" tabindex="{$vt_tab}" style="display:none" name="assigntype" {$select_user} value="U" onclick="toggleAssignType(this.value)" checked="true" >
             

				<span id="assign_user" style="{$style_user}">
					<select name="{$fldname}" id="{$fldname}" class="small"  fieldonly='{$fieldonly}' >
						{foreach key=key_one item=arr from=$fldvalue}
							{foreach key=sel_value item=value from=$arr}
								<option value="{$key_one}" {$value}>{$sel_value}</option>
                            {/foreach}
						{/foreach}
					</select>
                    
				</span>
                
			</td>
         {elseif $uitype eq 800}
            <td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>
                {$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="salesback_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}">
                <input name="{$fldname}" type="hidden" value="{$secondvalue}">
             </td>
         {elseif $uitype eq 100}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="33%" align=left class="dvtCellInfo">
				<span id="assign_user" style="{$style_user}">
					<input id="txt_select_user" readonly="" class="detailedViewTextBox" onclick="fnDropDownUsers(this,'div_select_user',18);BodyClick(this,'div_select_user');" />
                    <input id="{$fldname}" name="{$fldname}" type="hidden" value="">
                        <div id="div_select_user" style="display:none;position:absolute;z-index:9999999;width:200px;">
                        <table width="100%" cellpadding="0" border="0" cellspacing="0" style="border:1px black solid;background:white;">
                        {assign var=count_num value=0}
                        {assign var=colum_num value=2}
                        {foreach key=key_one item=arr from=$fldvalue}
							{foreach key=sel_value item=value from=$arr}
                               {if $count_num eq 0}
                               <tr>
                               {elseif $count_num%$colum_num eq 0}
                               </tr><tr>
                               {/if}
                               <td>
                                   <table>
                                       <tr>
                                           <td>
                                               {if $value eq $sel_value}
                                               <input checked="" type="checkbox" name="cb_select_user" onclick="getSelected('{$fldname}')"/>
                                               {else}
                                               <input type="checkbox" name="cb_select_user" onclick="getSelected('{$fldname}')"/>
                                               {/if}
                                            </td>
                                        <td>
            								<span id="sp_user_{$count_num}">{$sel_value}</span>
                                            <input id="txt_user_{$count_num++}" type="hidden" value="{$key_one}"/>
                                        </td>
                                        </tr>
                                   </table>
                               </td>                         
							{/foreach}
						{/foreach}
                        </tr>
                        </table>
                        </div>
				</span>
                <script type="text/javascript">
                    window.onresize = function(){ldelim}
                        if(document.getElementById('div_select_user')!=undefined&&document.getElementById('div_select_user').style.display!='none'){ldelim}
                            fnDropDownUsers(getObj('txt_select_user'),'div_select_user',18);BodyClick(getObj('txt_select_user'),'div_select_user');
                        {rdelim}
                    {rdelim};
                </script>

			</td>
		{elseif $uitype eq 52 || $uitype eq 77}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				{if $uitype eq 52}
					<select name="{$fldname}" tabindex="{$vt_tab}" class="small" fieldonly='{$fieldonly}' >
				{elseif $uitype eq 77}
					<select name="{$fldname}" tabindex="{$vt_tab}" class="small" fieldonly='{$fieldonly}' >
				{else}
					<select name="{$fldname}" tabindex="{$vt_tab}" class="small" fieldonly='{$fieldonly}' >
				{/if}

				{foreach key=key_one item=arr from=$fldvalue}
					{foreach key=sel_value item=value from=$arr}
						<option value="{$key_one}" {$value}>{$sel_value}</option>
					{/foreach}
				{/foreach}
				</select>
			</td>
		{elseif $uitype eq 51}
			{if $MODULE eq 'Accounts'}
				{assign var='popuptype' value = 'specific_account_address'}
			{else}
				{assign var='popuptype' value = 'specific_contact_account_address'}
			{/if}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input readonly name="account_name" style="border:1px solid #bababa;" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}">
                <input name="{$fldname}" type="hidden" value="{$secondvalue}">
                <a class="icon-homeimg icon-select" href="javascript:;"  tabindex="{$vt_tab}" title="{'SELECT'|@getFixedLabel}"  onclick='return window.open("index.php?module=Accounts&action=Popup&popuptype={$popuptype}&form=TasksEditView&form_submit=false&fromlink={$fromlink}&recordid={$ID}","contact_account","width=840,height=602,resizable=1,scrollbars=1");'></a>
                <input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.account_id.value=''; this.form.account_name.value='';return false;" />
			</td>
		{elseif $uitype eq 50}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input readonly name="account_name" type="text"  fieldonly='{$fieldonly}' value="{$fldvalue}">
                <input name="{$fldname}" type="hidden" value="{$secondvalue}">
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" onclick='return window.open("index.php?module=Accounts&action=Popup&popuptype=specific&form=TasksEditView&form_submit=false&fromlink={$fromlink}","test","width=840,height=602,resizable=1,scrollbars=1");'></a>
				<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.account_id.value=''; this.form.account_name.value='';return false;"/>
			</td>
		{elseif $uitype eq 73}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
            {if $MODULE eq 'OutboundOrder' && $ACCOUNTID > 0}
			<td width="30%" align=left class="dvtCellInfo">
				<input readonly name="account_name" id = "single_accountid" type="text" fieldonly='{$fieldonly}'  value="{$ACCOUNTNAME}"><input name="{$fldname}" type="hidden" value="{$ACCOUNTID}">
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" onclick='return window.open("index.php?module=Accounts&action=Popup&popuptype=specific_account_address&form=TasksEditView&form_submit=false&fromlink={$fromlink}&fromModule={$MODULE}","test","width=840,height=602,resizable=1,scrollbars=1");'></a>
				<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.account_id.value=''; this.form.account_name.value='';return false;"/>
			</td>
            {elseif $MODULE eq 'SalesBack'||$MODULE eq 'CashBack'}
            <td width="30%" align=left class="dvtCellInfo">
				<input readonly name="account_name" id = "single_accountid" type="text" fieldonly='{$fieldonly}'  value="{$fldvalue}"><input name="{$fldname}" type="hidden" value="{$secondvalue}">
			</td>
            {else}
            <td width="30%" align=left class="dvtCellInfo">
				<input readonly name="account_name" id = "single_accountid" type="text" fieldonly='{$fieldonly}'  value="{$fldvalue}" style="border: 1px solid #BABABA;"><input name="{$fldname}" type="hidden" value="{$secondvalue}">
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='return window.open("index.php?module=Accounts&action=Popup&popuptype=specific_account_address&form=TasksEditView&form_submit=false&fromlink={$fromlink}&fromModule={$MODULE}&related=1","test","width=840,height=602,resizable=1,scrollbars=1");'></a>
				<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.account_id.value=''; this.form.account_name.value='';return false;"/>
			</td>
            {/if}
        {elseif $uitype eq 244}
            <td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
            <td width="30%" align=left class="dvtCellInfo">
				<input readonly name="related_account_name" id = "related_accountid_name" type="text" fieldonly='{$fieldonly}'  value="{$fldvalue}" style="border: 1px solid #BABABA;"><input name="{$fldname}" type="hidden" value="{$secondvalue}">
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='return window.open("index.php?module=Accounts&action=Popup&popuptype=specific_account_address&form=TasksEditView&form_submit=false&fromlink={$fromlink}&fromModule={$MODULE}&related=2","test","width=840,height=602,resizable=1,scrollbars=1");'></a>
				<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.related_accountid.value=''; this.form.related_accountid_name.value='';return false;"/>
			</td>
		{elseif $uitype eq 75 || $uitype eq 81}
			<td width="20%" class="dvtCellLabel" align=right>
				{if $uitype eq 81}
					{assign var="pop_type" value="specific_vendor_address"}
					{else}{assign var="pop_type" value="specific"}
				{/if}
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
                {if $PURCHASEORDERID >0 && $MODULE == 'Stock'}
                    <input name="vendor_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$VENDORNAME}">
                    <input name="{$fldname}" id="{$fldname}" type="hidden" value="{$VENDORID}">
                    <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='return window.open("index.php?module=Vendors&action=Popup&html=Popup_picker&popuptype={$pop_type}&form=EditView&fromlink={$fromlink}&fromModule={$MODULE}","test","width=840,height=602,resizable=1,scrollbars=1");'></a>
                {else}
    				<input name="vendor_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}">
                    <input name="{$fldname}" id="{$fldname}" type="hidden" value="{$secondvalue}">
                    <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='return window.open("index.php?module=Vendors&action=Popup&html=Popup_picker&popuptype={$pop_type}&form=EditView&fromlink={$fromlink}&fromModule={$MODULE}","test","width=840,height=602,resizable=1,scrollbars=1");'></a>
				{/if}
                <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.vendor_id.value='';this.form.vendor_name.value='';return false;"/>
			</td>
		{elseif $uitype eq 57}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
                {if $MODULE == 'Contacts'}
                    <input type="hidden" id = "single_accountid" fieldonly='{$fieldonly}'  value="{$ACCOUNTNAME}">
                {/if}
				{if $fromlink eq 'qcreate'}
					<input name="contact_name" readonly type="text" fieldonly='0' style="border:1px solid #bababa;" value="{$fldvalue}">
                    <input name="{$fldname}" type="hidden" value="{$secondvalue}">
                    <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='selectContact("false","general",document.QcEditView)'></a>
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.contact_id.value=''; this.form.contact_name.value='';return false;"/>
				{else}
					<input name="contact_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}"><input name="{$fldname}" type="hidden" value="{$secondvalue}">
                    <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='selectContact("false","general",document.EditView,1)'></a>
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.contact_id.value=''; this.form.contact_name.value='';return false;"/>
				{/if}
			</td>
        {elseif $uitype eq 245} {*销售机会-相关联系人*}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				{if $fromlink eq 'qcreate'}
					<input name="contact_name" readonly type="text" fieldonly='{$fieldonly}' style="border:1px solid #bababa;" value="{$fldvalue}">
                    <input name="{$fldname}" type="hidden" value="{$secondvalue}">
                    <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='selectContact("false","general",document.QcEditView)'></a>
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.contact_id.value=''; this.form.contact_name.value='';return false;"/>
				{else}
					<input name="related_contact_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}"><input name="{$fldname}" type="hidden" value="{$secondvalue}">
                    <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='selectContact("false","general",document.EditView,2)'></a>
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.related_contactid.value=''; this.form.related_contact_name.value='';return false;"/>
				{/if}
			</td>
        {elseif $uitype eq 96}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				{if $fromlink eq 'qcreate'}
					<input name="contact_name" readonly type="text" fieldonly='{$fieldonly}' style="border:1px solid #bababa;" value="{$fldvalue}">
                    <input name="{$fldname}" type="hidden" value="{$secondvalue}">
                    <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='selectVendorContact("false","general",document.QcEditView)'></a>&nbsp;
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.contact_id.value=''; this.form.contact_name.value='';return false;"/>
				{else}
					<input name="contact_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}">
                    <input name="{$fldname}" type="hidden" value="{$secondvalue}">
                    <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='selectVendorContact("false","general",document.EditView)'></a>&nbsp;
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.contact_id.value=''; this.form.contact_name.value='';return false;"/>
				{/if}
			</td>
		{elseif $uitype eq 58}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="campaignname" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}">
                <input name="{$fldname}" type="hidden" value="{$secondvalue}">
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='return window.open("index.php?module=Campaigns&action=Popup&html=Popup_picker&popuptype=specific_campaign&form=EditView&fromlink={$fromlink}","test","width=840,height=602,resizable=1,scrollbars=1");'></a>
                <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.campaignid.value=''; this.form.campaignname.value='';return false;"/>
			</td>

		{elseif $uitype eq 80}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
            {if $MODULE eq 'OutboundOrder' && $SALESORDERID > 0}
            <td width="30%" align=left class="dvtCellInfo">
				<input name="salesorder_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$SALESORDERNAME}">
                <input name="{$fldname}" type="hidden" value="{$SALESORDERID}">
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick="selectSalesOrder('{$MODULE}');"></a>
                <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.salesorder_id.value=''; this.form.salesorder_name.value='';{if $MODULE eq 'CashBill'}ClearPaymentList('{$MODULE}');{/if}return false;"/>
			</td>
            {elseif $MODULE eq 'SalesBack'||$MODULE eq 'CashBack'}
			 <td width="30%" align=left class="dvtCellInfo">
				<input name="salesorder_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}">
                <input name="{$fldname}" type="hidden" value="{$secondvalue}">
             </td>
            {else}
			<td width="30%" align=left class="dvtCellInfo">
				<input name="salesorder_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}"><input name="{$fldname}" type="hidden" value="{$secondvalue}">
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick="selectSalesOrder('{$MODULE}');"></a>
                <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onClick="this.form.salesorder_id.value=''; this.form.salesorder_name.value='';{if $MODULE eq 'CashBill'}ClearPaymentList('{$MODULE}');{/if}return false;"/>
			</td>
            {/if}
        <!--联系记录新增服务单字段-->
        {elseif $uitype eq 240}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="troubleticket_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}"><input name="{$fldname}" type="hidden" value="{$secondvalue}">
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick="selecttroubleticket('{$MODULE}');"></a>
                <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onClick="this.form.troubleticketid.value=''; this.form.troubleticket_name.value='';{if $MODULE eq 'CashBill'}ClearPaymentList('{$MODULE}');{/if}return false;"/>
			</td>
         <!--联系记录新增项目任务字段-->
        {elseif $uitype eq 241}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="projecttask_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}"><input name="{$fldname}" type="hidden" value="{$secondvalue}">
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick="selectprojecttask('{$MODULE}');"></a>
                <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onClick="this.form.projecttaskid.value=''; this.form.projecttask_name.value='';{if $MODULE eq 'CashBill'}ClearPaymentList('{$MODULE}');{/if}return false;"/>
			</td>
         <!--服务单新增服务合同字段-->
        {elseif $uitype eq 243}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="ServiceContracts_subject" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}"><input name="{$fldname}" type="hidden" value="{$secondvalue}">
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick="SelectServicecontracts('{$MODULE}');"></a>
                <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onClick="this.form.servicecontractsid.value=''; this.form.ServiceContracts_subject.value='';{if $MODULE eq 'CashBill'}ClearPaymentList('{$MODULE}');{/if}return false;" />
			</td>
		{elseif $uitype eq 78}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small">{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="quote_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}">
                <input name="{$fldname}" type="hidden" value="{$secondvalue}" >&nbsp;
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  onclick='selectQuote()' ></a>&nbsp;
                <input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onClick="this.form.quote_id.value=''; this.form.quote_name.value='';return false;"/>
			</td>

		{elseif $uitype eq 76}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="potential_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}"><input name="{$fldname}" type="hidden" value="{$secondvalue}">
                <a class="icon-homeimg icon-select" href="javascript:;"  tabindex="{$vt_tab}" title="{'SELECT'|@getFixedLabel}"  onclick='selectPotential("{$MODULE}")'></a>
                <input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.potential_id.value=''; this.form.potential_name.value='';return false;"/>
			</td>

		{elseif $uitype eq 17}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
			<input style="width:74%;" class = 'detailedViewTextBox' type="text"  fieldonly='{$fieldonly}'  tabindex="{$vt_tab}" name="{$fldname}" style="border:1px solid #bababa;" size="27" onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'"onBlur="this.className='detailedViewTextBox'" onkeyup="validateUrl('{$fldname}');" value="{$fldvalue}">
			</td>

		{elseif $uitype eq 85}
            <td width="20%" class="dvtCellLabel" align=right>
                <font color="red">{$mandatory_field}</font>
                {$usefldlabel}
                {if $MASS_EDIT eq '1'}
                	<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >
                {/if}
            </td>
            <td width="30%" align=left class="dvtCellInfo">
            <!--
            更新操作
            edit：cdw
            date：20131212
            reason：0006196: 查看明细界面当传真、手机、QQ、邮件字段内容为空时，后面的图标按钮应该不显示，另外，网络电话不需要加图标，去掉文字上面的链接
            -->
				<!--<img src="{'skype.gif'|@lingdang_imageurl:$THEME}" alt="Skype" title="Skype"  align="absmiddle"></img>-->
				<input class='detailedViewTextBox' type="text" fieldonly='{$fieldonly}'  tabindex="{$vt_tab}" name="{$fldname}" style="border:1px solid #bababa;" size="27" onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'" value="{$fldvalue}">
            </td>
    
		{elseif $uitype eq 71 || $uitype eq 72}
            {if ($MODULE eq 'BankAccountSet' && $CONFIRMEDST eq '0')||$MODULE neq 'BankAccountSet'}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				{if $fldname eq "unit_price" && $fromlink neq 'qcreate'}
					<span id="multiple_currencies">
						<input name="{$fldname}" id="{$fldname}"  fieldonly='{$fieldonly}' tabindex="{$vt_tab}" type="text" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'; updateUnitPrice('unit_price', '{$BASE_CURRENCY}');"  value="{$fldvalue}" style="width:60%;">
					{if $MASS_EDIT neq 1}
						&nbsp;<a href="javascript:void(0);" onclick="updateUnitPrice('unit_price', '{$BASE_CURRENCY}'); toggleShowHide('currency_class','multiple_currencies');">{'More_Currency'|@getFixedLabel}&raquo;</a>
					{/if}
					</span>
					{if $MASS_EDIT neq 1}
					<div id="currency_class" class="LdPop_box LdPopWidth650px" style="position:absolute; display:none;z-index:1000;">
						<input type="hidden" name="base_currency" id="base_currency" value="{$BASE_CURRENCY}" />
						<input type="hidden" name="base_conversion_rate" id="base_currency" value="{$BASE_CURRENCY}" />
						<input type="hidden" name="price_decimal" id="price_decimal" value="{$price_decimal}" />
                        <div class="Title"><img src="themes/softed/tier/icon_loto.png" class="Logo" /><span class="Name">{'PRODUCT_PRICES'|@getFixedLabel}</span>
                        	<a onclick="toggleShowHide('multiple_currencies','currency_class');">
                        		<img src="themes/softed/tier/icon_close.png" class="Close" />
                        	</a>
                        </div>		
                        <div class="Content_div">
                        	<table width="100%" border="0" cellspacing="0" cellpadding="0">
                        	  <tr>
                        		<td class="Note">
                        			<table width="100%" border="0" cellspacing="0" cellpadding="0">
                        				<tr>
                        					<th class="LdPop_ul5th">{'Currency'|@getFixedLabel}{$MASS_EDIT}</th>            
                        					<th class="LdPop_ul5th">{'Price'|@getFixedLabel}</th>
                        					<th class="LdPop_ul5th">{'CONVERSIONRATE'|@getFixedLabel}</th>
                        					<th class="LdPop_ul5th">{'RPrice'|@getFixedLabel}</th>
                        					<th class="LdPop_ul5th">{'Base_Currency'|@getFixedLabel}</th>
                        				</tr>
                        					{foreach item=price key=count from=$PRICE_DETAILS}
                        						<tr>
                        							{if $price.check_value eq 1 || $price.is_basecurrency eq 1}
                        								{assign var=check_value value="checked"}
                        								{assign var=disable_value value=""}
                        							{else}
                        								{assign var=check_value value=""}
                        								{assign var=disable_value value="disabled=true"}
                        							{/if}
                        
                        							{if $price.is_basecurrency eq 1}
                        								{assign var=base_cur_check value="checked"}
                        							{else}
                        								{assign var=base_cur_check value=""}
                        							{/if}
                        
                        							{if $price.curname eq $BASE_CURRENCY}
                        								{assign var=call_js_update_func value="updateUnitPrice('$BASE_CURRENCY', 'unit_price');"}
                        							{else}
                        								{assign var=call_js_update_func value=""}
                        							{/if}
                        
                        							<td class="LdPop_ul4body">
                        								{$price.currencylabel|@getTranslatedCurrencyString} ({$price.currencysymbol})
                        								<input type="checkbox" name="cur_{$price.curid}_check" id="cur_{$price.curid}_check" class="small" onclick="fnenableDisable(this,'{$price.curid}'); updateCurrencyValue(this,'{$price.curname}','{$BASE_CURRENCY}','{$price.conversionrate}');" {$check_value}/>
                        							</td>
                        							<td class="LdPop_ul4body">
                        								<input {$disable_value} type="text" fieldonly='{$fieldonly}' size="10" class="ld-input-inner" name="{$price.curname}" id="{$price.curname}" value="{$price.curvalue}" onBlur="{$call_js_update_func} fnpriceValidation('{$price.curname}');"/>
                        							</td>
                        							<td class="LdPop_ul4body">
                        								<input disabled=true type="text" fieldonly='{$fieldonly}' size="10" class="ld-input-inner" name="cur_conv_rate{$price.curid}" value="{$price.conversionrate}"/>
                        							</td>
                        							<td class="LdPop_ul4body">
                        								<input {$disable_value} type="button" class="edit" id="cur_reset{$price.curid}"  onclick="updateCurrencyValue(this,'{$price.curname}','{$BASE_CURRENCY}','{$price.conversionrate}');" value="{'RPrice'|@getFixedLabel}"/>
                        							</td>
                        							<td class="LdPop_ul4body">
                        								<input disabled='true' {$disable_value} type="radio" class="detailedViewTextBox" id="base_currency{$price.curid}" name="base_currency_input" value="{$price.curname}" {$base_cur_check} onchange="updateBaseCurrencyValue()" />
                        							</td>
                        						</tr>
                        					{/foreach}			
                        			</table>
                        		</td>
                        	  </tr>
                        	</table>
                        </div>
					</div>
					{/if}
				{else}
					<input name="{$fldname}" tabindex="{$vt_tab}" type="text"  fieldonly='{$fieldonly}' class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'"  value="{$fldvalue}">
				{/if}
			</td>
        {/if}
		{elseif $uitype eq 56}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
           
			{if $fldname eq 'notime' && $ACTIVITY_MODE eq 'Events'}
				{if $fldvalue eq 1}
					<td width="30%" align=left class="dvtCellInfo">
						<input name="{$fldname}" type="checkbox" tabindex="{$vt_tab}" onclick="toggleTime()" checked>
					</td>
				{else}
					<td width="30%" align=left class="dvtCellInfo">
						<input name="{$fldname}" tabindex="{$vt_tab}" type="checkbox" onclick="toggleTime()" >
					</td>
				{/if}
			<!-- For Portal Information we need a hidden field existing_portal with the current portal value -->
			{elseif $fldname eq 'portal'}
				<td width="30%" align=left class="dvtCellInfo">
					<input type="hidden" name="existing_portal" value="{$fldvalue}">
					<input name="{$fldname}" type="checkbox" tabindex="{$vt_tab}" {if $fldvalue eq 1}checked{/if}>
				</td>
            {elseif $fldname eq 'select_servicedetail'}
                {if $IS_ADMIN eq false}
                <input type="hidden" name="select_servicedetail" value="{$fldvalue}">
                {/if}
                {if $fldvalue eq 1}
					<td width="30%" align=left class="dvtCellInfo">
						<input name="{$fldname}" type="checkbox" tabindex="{$vt_tab}" {if $IS_ADMIN eq false}  disabled="true" {/if} checked>
					</td>
				{else}
					<td width="30%" align=left class="dvtCellInfo">
						<input name="{$fldname}" tabindex="{$vt_tab}" type="checkbox" {if $IS_ADMIN eq false}  disabled="true" {/if} >
					</td>
				{/if}
            {elseif $fldname eq 'select_due_date'}
                {if $IS_ADMIN eq false}
                <input type="hidden" name="select_due_date" value="{$fldvalue}">
                {/if}
                {if $fldvalue eq 1}
					<td width="30%" align=left class="dvtCellInfo">
						<input name="{$fldname}" type="checkbox" tabindex="{$vt_tab}"  {if $IS_ADMIN eq false}  disabled="true" {/if} checked>
					</td>
				{else}
					<td width="30%" align=left class="dvtCellInfo">
						<input name="{$fldname}" tabindex="{$vt_tab}" type="checkbox" {if $IS_ADMIN eq false}  disabled="true" {/if} >
					</td>
				{/if}
            {elseif ($fldname eq 'accountallview' ||$fldname eq 'level')&&$IS_ADMIN eq false}
			     {if $fldvalue eq 1}
					<td width="30%" align=left class="dvtCellInfo">
						<input name="{$fldname}" type="checkbox" tabindex="{$vt_tab}"  disabled="true" checked>
					</td>
				{else}
					<td width="30%" align=left class="dvtCellInfo">
						<input name="{$fldname}" tabindex="{$vt_tab}" type="checkbox" disabled="true" >
					</td>
				{/if}
            {else}
            
				{if $fldvalue eq 1}
					<td width="30%" align=left class="dvtCellInfo">
						<input name="{$fldname}" type="checkbox" tabindex="{$vt_tab}" checked>
					</td>
				{elseif $fldname eq 'filestatus'&& $MODE eq 'create'}
					<td width="30%" align=left class="dvtCellInfo">
						<input name="{$fldname}" type="checkbox" tabindex="{$vt_tab}" checked>
					</td>
               
				{else}
					<td width="30%" align=left class="dvtCellInfo">
                    {*<!---|| $USER_MODE eq 'create']-->*}
						<input name="{$fldname}" tabindex="{$vt_tab}" type="checkbox" {if ( $PROD_MODE eq 'create' &&  $fldname|substr:0:3 neq 'cf_') ||( $fldname|substr:0:3 neq 'cf_' && $PRICE_BOOK_MODE eq 'create' ) }checked{/if}>
					</td>
				{/if}
			{/if}
		{elseif $uitype eq 23 || $uitype eq 5 || $uitype eq 6}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="34%" align=left class="dvtCellInfo">
				{foreach key=date_value item=time_value from=$fldvalue}
					{assign var=date_val value="$date_value"}
					{assign var=time_val value="$time_value"}
				{/foreach}
                {foreach key=date_format item=date_str from=$secondvalue}
					{assign var=dateFormat value="$date_format"}
					{assign var=dateStr value="$date_str"}
				 {/foreach}
               
                 {if $MODULE eq 'Accounts'}
                     {if $MODE eq 'edit'}
                        {if $date_val neq ''}
                            <input class="Wdate" name="{$fldname}" tabindex="{$vt_tab}" id="jscal_field_{$fldname}"  fieldonly='{$fieldonly}' type="text" style="border:1px solid #bababa;" size="15" maxlength="10" value="{$date_val}" onClick="WdatePicker()">
                        {else }
                            <input class="Wdate" name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' id="jscal_field_{$fldname}" type="text" style="border:1px solid #bababa;" size="15" maxlength="10" value="" onClick="WdatePicker()">
                        {/if}
                     {else}
                        <input class="Wdate" name="{$fldname}" tabindex="{$vt_tab}" id="jscal_field_{$fldname}" type="text"  fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" size="15" maxlength="10" value="{$date_val}" onClick="WdatePicker()">
                     {/if}
                 {else}
                    <input class="Wdate" name="{$fldname}" tabindex="{$vt_tab}" id="jscal_field_{$fldname}" type="text" style="border:1px solid #bababa;"  fieldonly='{$fieldonly}'  size="15" maxlength="10" value="{$date_val}" onClick="WdatePicker()">
                 {/if}
                 <!--<img style="margin: -2px 0 0 5px;" src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_{$fldname}"/>-->
                
				{if $uitype eq 6}
                    {if $MODULE eq 'Reminds'}
                    {$STARTHOUR}
                    {else}
					<input name="time_start" tabindex="{$vt_tab}" style="border:1px solid #bababa;" size="5" maxlength="5" type="text"  fieldonly='{$fieldonly}' value="{$time_val}">
				    {/if}
                {/if}
				{if $uitype eq 6 && $QCMODULE eq 'Event'}
					<input name="dateFormat" type="hidden" value="{$dateFormat}">
				{/if}
				{if $uitype eq 23 && $QCMODULE eq 'Event'}
					<input name="time_end" style="border:1px solid #bababa;" size="5" maxlength="5" type="text"  fieldonly='{$fieldonly}'  value="{$time_val}">
				{/if}
				<!--<script type="text/javascript" id='massedit_calendar_{$fldname}'>
					Calendar.setup ({ldelim}
						inputField : "jscal_field_{$fldname}", ifFormat : "{$dateFormat}", showsTime : false, button : "jscal_trigger_{$fldname}", singleClick : true, step : 1
					{rdelim})
				</script>-->
			</td>         
            

		{elseif $uitype eq 63}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="{$fldname}" type="text"  fieldonly='{$fieldonly}' size="2" value="{$fldvalue}" tabindex="{$vt_tab}" >
				<select name="duration_minutes" tabindex="{$vt_tab}" class="small" fieldonly='{$fieldonly}' >
					{foreach key=labelval item=selectval from=$secondvalue}
						<option value="{$labelval}" {$selectval}>{$labelval}</option>
					{/foreach}
				</select>

		{elseif $uitype eq 68 || $uitype eq 66 || $uitype eq 62}
       
			<td width="20%" class="dvtCellLabel" align=right>
            {if $uitype eq 68}
            	<font color="red">{$mandatory_field}</font>
			     {$fldlabel.displaylabel}
            {/if}
				{if $fromlink eq 'qcreate'}
					<select class="small" name="parent_type" onChange='document.QcEditView.parent_name.value=""; document.QcEditView.parent_id.value=""' fieldonly='{$fieldonly}' >
				{else}
					<select class="small" fieldonly='{$fieldonly}'  name="parent_type" onChange='document.EditView.parent_name.value=""; document.EditView.parent_id.value=""'>
				{/if}
					{section name=combo loop=$fldlabel}
                        {if $fldlabel_combo[combo] neq ""}
					       	<option value="{$fldlabel_combo[combo]}" {$fldlabel_sel[combo]}>{$fldlabel[combo]} </option>
                        {/if}
                    {/section}
				</select>
				{if $MASS_EDIT eq '1'}<input type="checkbox" name="parent_id_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="{$fldname}" type="hidden" value="{$secondvalue}">
				<input name="parent_name" readonly id = "parentid" type="text"  fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}">
				&nbsp;
				{if $fromlink eq 'qcreate'}
					<a class="icon-homeimg icon-select" href="javascript:;"  tabindex="{$vt_tab}" title="{'SELECT'|@getFixedLabel}"  onclick='return window.open("index.php?module="+ document.QcEditView.parent_type.value +"&action=Popup&html=Popup_picker&form=HelpDeskEditView&fromlink={$fromlink}","test","width=840,height=602,resizable=1,scrollbars=1,top=150,left=200");'></a>&nbsp;
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.parent_id.value=''; this.form.parent_name.value=''; return false;"/>
				{else}
					<a class="icon-homeimg icon-select" href="javascript:;" tabindex="{$vt_tab}" title="{'SELECT'|@getFixedLabel}"  onclick='return window.open("index.php?module="+ document.EditView.parent_type.value +"&action=Popup&html=Popup_picker&form=HelpDeskEditView&fromlink={$fromlink}","test","width=840,height=602,resizable=1,scrollbars=1,top=150,left=200");'></a>&nbsp;
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.parent_id.value=''; this.form.parent_name.value=''; return false;" />
					{/if}
			</td>

		{elseif $uitype eq 357}
			<td width="20%" class="dvtCellLabel" align=right>To:&nbsp;</td>
			<td width="90%" colspan="3">
				<input name="{$fldname}" type="hidden" value="{$secondvalue}">
				<textarea readonly name="parent_name" cols="70" style="height:30px">{$fldvalue}</textarea>&nbsp;
				<select name="parent_type" class="small" fieldonly='{$fieldonly}' >
					{foreach key=labelval item=selectval from=$fldlabel}
						<option value="{$labelval}" {$selectval}>{$labelval}</option>
					{/foreach}
				</select>
				&nbsp;
				{if $fromlink eq 'qcreate'}
					<a class="icon-homeimg icon-select" href="javascript:;"  tabindex="{$vt_tab}" title="{'SELECT'|@getFixedLabel}"  onclick='return window.open("index.php?module="+ document.QcEditView.parent_type.value +"&action=Popup&html=Popup_picker&form=HelpDeskEditView&fromlink={$fromlink}","test","width=840,height=602,resizable=1,scrollbars=1,top=150,left=200");'></a>&nbsp;
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.parent_id.value=''; this.form.parent_name.value=''; return false;" />
				{else}
					<a class="icon-homeimg icon-select" href="javascript:;"  tabindex="{$vt_tab}" title="{'SELECT'|@getFixedLabel}"  onclick='return window.open("index.php?module="+ document.EditView.parent_type.value +"&action=Popup&html=Popup_picker&form=HelpDeskEditView&fromlink={$fromlink}","test","width=840,height=602,resizable=1,scrollbars=1,top=150,left=200");' ></a>&nbsp;
                    <input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.parent_id.value=''; this.form.parent_name.value=''; return false;" />
				{/if}
			</td>
		   <tr style="height:25px">
			<td width="20%" class="dvtCellLabel" align=right>CC:&nbsp;</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="ccmail" type="text"  fieldonly='{$fieldonly}'  class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'"  value="">
			</td>
			<td width="20%" class="dvtCellLabel" align=right>BCC:&nbsp;</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="bccmail" type="text"  fieldonly='{$fieldonly}' class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'"  value="">
			</td>
		   </tr>

		{elseif $uitype eq 59}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<input name="{$fldname}" type="hidden" value="{$secondvalue}">
				<input name="product_name" readonly type="text"  fieldonly='{$fieldonly}' value="{$fldvalue}" style="border: 1px solid #BABABA;">
                <a class="icon-homeimg icon-select" href="javascript:;"  tabindex="{$vt_tab}" title="{'SELECT'|@getFixedLabel}"  onclick='return window.open("index.php?module=Products&action=Popup&html=Popup_picker&form=HelpDeskEditView&popuptype=specific&fromlink={$fromlink}","testproduct","width=840,height=602,resizable=1,scrollbars=1,top=150,left=200");'></a>
                <input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.product_id.value=''; this.form.product_name.value=''; return false;"/>
			</td>

		{elseif $uitype eq 55 || $uitype eq 255}
			<td width="20%" class="dvtCellLabel" align=right>
			{if $MASS_EDIT eq '1' && $fldvalue neq ''}
				{$APP.Salutation}<input type="checkbox" name="salutationtype_mass_edit_check" id="salutationtype_mass_edit_check" class="small" ><br />
			{/if}
			{if $uitype eq 55}
				{$usefldlabel}{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			{elseif $uitype eq 255}
				<font color="red">{$mandatory_field}</font>{$usefldlabel}{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			{/if}
			</td>

			<td width="30%" align=left class="dvtCellInfo">
			{if $fldvalue neq ''}
			<select name="salutationtype" class="small" fieldonly='{$fieldonly}' >
				{foreach item=arr from=$fldvalue}
				<option value="{$arr[1]}" {$arr[2]}>
				{$arr[0]}
				</option>
				{/foreach}
			</select>
			{if $MASS_EDIT eq '1'}<br />{/if}
			{/if}
			<input type="text" name="{$fldname}" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'" style="width:58%;" value= "{$secondvalue}" >
			</td>

		{elseif $uitype eq 22}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<textarea name="{$fldname}" cols="30" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' style="height:30px">{$fldvalue}</textarea>
			</td>
        {elseif $uitype eq 14}
            <td width="20%" class="dvtCellLabel" align=right>
				<!--by LD TIFA 20121220
                <font color="red">{$mandatory_field}</font>{$usefldlabel} {"LBL_TIMEFIELD"|@getTranslatedString}{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}-->
			<font color="red">{$mandatory_field}</font>{$usefldlabel}{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
            </td>
			<td width=10% align=left class="dvtCellInfo">
				<input type="text" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}'  name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'">
			</td>
			
		{elseif $uitype eq 69}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel}
				{if $MASS_EDIT eq '1'}
					<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small"  >
				{/if}
			</td>
			<td colspan="3" width="30%" align=left class="dvtCellInfo table_img_display">
				{if $MODULE eq 'Products'}
					<input name="del_file_list" type="hidden" value="">
					<div id="files_list">
                        
						<div class="input_file_box">
                            <input id="my_file_element" type="file" name="file_1" tabindex="{$vt_tab}"  onchange="validateFilename(this)"/><span>{'Up_to_six_the_number_of_files'|@getFixedLabel}</span>
                        </div>
						<!--input type="hidden" name="file_1_hidden" value=""/-->
						{assign var=image_count value=0}
						{if $maindata[3].0.name neq '' && $DUPLICATE neq 'true'}
						   {foreach name=image_loop key=num item=image_details from=$maindata[3]}
							<div class="img_diplay_box">
								<div>
                                    <img src="{$image_details.path}{$image_details.name}" >
                                </div>
                                <div>
                                    <span>&nbsp;&nbsp;[{$image_details.orgname}]</span><input id="file_{$num}" value="{'DELETE'|@getFixedLabel}" type="button" class="deleteauto" onclick='this.parentNode.parentNode.removeChild(this.parentNode);delRowEmt("{$image_details.orgname}")'>
                                </div>
							</div>
					   	   {assign var=image_count value=$smarty.foreach.image_loop.iteration}
					   	   {/foreach}
						{/if}
					</div>

					<script>
						{*<!-- Create an instance of the multiSelector class, pass it the output target and the max number of files -->*}
						var multi_selector = new MultiSelector( document.getElementById( 'files_list' ), 6 );
						multi_selector.count = {$image_count}
						{*<!-- Pass in the file element -->*}
						multi_selector.addElement( document.getElementById( 'my_file_element' ) );
					</script>
				{else}
					<input name="{$fldname}"  type="file" value="{$maindata[3].0.name}" tabindex="{$vt_tab}" onchange="validateFilename(this);" />
					<input name="{$fldname}_hidden"  type="hidden" value="{$maindata[3].0.name}" />
					<input type="hidden" name="id" value=""/>
					{if $maindata[3].0.name != "" && $DUPLICATE neq 'true'}
						<div id="replaceimage">[{$maindata[3].0.orgname}] <a href="javascript:;" onClick="delimage({$ID})">{'DELETE'|@getFixedLabel}</a></div>
					{/if}
				{/if}
			</td>

		{elseif $uitype eq 61}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel}
				{if $MASS_EDIT eq '1'}
					<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small"  disabled >
				{/if}
			</td>

			<td colspan="1" width="30%" align=left class="dvtCellInfo">
				<input name="{$fldname}"  type="file" value="{$secondvalue}" tabindex="{$vt_tab}" onchange="validateFilename(this)"/>
				<input type="hidden" name="{$fldname}_hidden" value="{$secondvalue}"/>
				<input type="hidden" name="id" value=""/>{$fldvalue}
			</td>
		{elseif $uitype eq 156}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
				{if $fldvalue eq 'on'}
					<td width="30%" align=left class="dvtCellInfo">
						{if ($secondvalue eq 1 && $CURRENT_USERID != $smarty.request.record) || ($MODE == 'create')}
							<input name="{$fldname}" tabindex="{$vt_tab}" type="checkbox" checked>
						{else}
							<input name="{$fldname}" type="hidden" value="on">
							<input name="{$fldname}" disabled tabindex="{$vt_tab}" type="checkbox" checked>
						{/if}
					</td>
				{else}
					<td width="30%" align=left class="dvtCellInfo">
						{if ($secondvalue eq 1 && $CURRENT_USERID != $smarty.request.record) || ($MODE == 'create')}
							<input name="{$fldname}" tabindex="{$vt_tab}" type="checkbox">
						{else}
							<input name="{$fldname}" disabled tabindex="{$vt_tab}" type="checkbox">
						{/if}
					</td>
				{/if}
		{elseif $uitype eq 98}<!-- Role Selection Popup -->
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
			{if $thirdvalue eq 1}
				<select id="$fldname}" name="{$fldname}" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class="borderALL">
				{foreach item=arr key=uivalueid from=$secondvalue}
					{foreach key=sel_value item=value from=$arr}
						<option value="{$uivalueid}" {$value}>{$sel_value}</option>
					{/foreach}
				{/foreach}
			   </select>
			{else}
				<input name="role_name" id="role_name" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' class="txtBox" readonly value="{$secondvalue}" type="text">&nbsp;
			{/if}
			<input name="user_role" id="user_role" value="{$fldvalue}" type="hidden">
			</td>
		{elseif $uitype eq 104}<!-- Mandatory Email Fields -->
			 <td width=20% class="dvtCellLabel" align=right>
			<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			 </td>
    	     <td width=30% align=left class="dvtCellInfo"><input type="text" fieldonly='{$fieldonly}'  name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" tabindex="{$vt_tab}" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'"></td>
			{elseif $uitype eq 115}<!-- for Status field Disabled for nonadmin -->
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
			   {if $secondvalue eq 1 && $CURRENT_USERID != $smarty.request.record}
			   	<select id="user_status" name="{$fldname}" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class="small">
			   {else}
			   	<select id="user_status" disabled name="{$fldname}" class="small" fieldonly='{$fieldonly}' >
			   {/if}
				{foreach item=arr from=$fldvalue}
                                        <option value="{$arr[1]}" {$arr[2]} >
                                                {$arr[0]}
                                        </option>
				{/foreach}
			   </select>
			</td>
			{elseif $uitype eq 105}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo" style="height: 50px">
				{if $MODE eq 'edit' && $IMAGENAME neq ''}
					<input name="{$fldname}"  type="file" value="{$maindata[3].0.name}" tabindex="{$vt_tab}" onchange="validateFilename(this);" /><div id="replaceimage">[{$IMAGENAME}]&nbsp;<a href="javascript:;" onClick="delUserImage({$ID})">{'DELETE'|@getFixedLabel:$MODULE}</a></div>
					<br><span style="color: red;">{'ONLYJPGGIFIMG'|@getFixedlabel}</span>
					<input name="{$fldname}_hidden"  type="hidden" value="{$maindata[3].0.name}" />
				{else}
               <input name="{$fldname}"  type="file" value="{$maindata[3].0.name}" tabindex="{$vt_tab}" onchange="validateFilename(this);" /><br><span style="color: red;">{'ONLYJPGGIFIMG'|@getFixedLabel}</span>
					<input name="{$fldname}_hidden"  type="hidden" value="{$maindata[3].0.name}" />
				{/if}
					<input type="hidden" name="id" value=""/>
					{$maindata[3].0.name}
			</td>
			{elseif $uitype eq 103}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" colspan="3" align=left class="dvtCellInfo">
				<input type="text" name="{$fldname}" value="{$fldvalue}"  fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'">
			</td>
			{elseif $uitype eq 101}<!-- for reportsto field USERS POPUP -->
				<td width="20%" class="dvtCellLabel" align=right>
			      <font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
	            </td>
				<td width="30%" align=left class="dvtCellInfo">
					<input id="{$fldname}_name" name="{$fldname}_name" fieldonly='{$fieldonly}'  readonly type="text" style="border:1px solid #bababa;" value="{$fldvalue}" class="small" />
					<input id="{$fldname}" name="{$fldname}" type="hidden" value="{$secondvalue}" id="{$fldname}" />
					<input title="{$APP.LBL_CHANGE_TITLE}" accessKey="C" type="button" class="small" value='{$APP.LBL_CHANGE}' name="btn1" onclick='return window.open("index.php?module=Users&action=Popup&html=Popup_picker&form=vtlibPopupView&form_submit=false&fromlink={$fromlink}&recordid={$ID}&forfield={$fldname}","test","width=840,height=603,resizable=1,scrollbars=1");'>
	            	<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" onclick="this.form.{$fldname}.value=''; this.form.{$fldname}_name.value=''; return false;"/>
				</td>
			{elseif $uitype eq 116 || $uitype eq 117}<!-- for currency in users details-->
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
			   {if $secondvalue eq 1 || $uitype eq 117}
			   	<select name="{$fldname}" tabindex="{$vt_tab}" class="small" fieldonly='{$fieldonly}' >
			   {else}
			   	<select disabled name="{$fldname}" tabindex="{$vt_tab}" class="small" fieldonly='{$fieldonly}' >
			   {/if}

				{foreach item=arr key=uivalueid from=$fldvalue}
					{foreach key=sel_value item=value from=$arr}
						<option value="{$uivalueid}" {$value}>{$sel_value|@getTranslatedCurrencyString}</option>
						<!-- code added to pass Currency field value, if Disabled for nonadmin -->
						{if $value eq 'selected' && $secondvalue neq 1}
							{assign var="curr_stat" value="$uivalueid"}
						{/if}
						<!--code ends -->
					{/foreach}
				{/foreach}
			   </select>
			<!-- code added to pass Currency field value, if Disabled for nonadmin -->
			{if $curr_stat neq '' && $uitype neq 117}
				<input name="{$fldname}" type="hidden" value="{$curr_stat}">
			{/if}
			<!--code ends -->
			</td>
			{elseif $uitype eq 106}
			<td width=20% class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td width=30% align=left class="dvtCellInfo">
				{if $MODE eq 'edit'}
				<input type="text" readonly name="{$fldname}" value="{$fldvalue}"  fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'">
				{else}
				<input type="text" name="{$fldname}" value="{$fldvalue}"  fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'">
				{/if}
			</td>
			{elseif $uitype eq 99}
				{if $MODE eq 'create'}
				<td width=20% class="dvtCellLabel" align=right>
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
				</td>
				<td width=30% align=left class="dvtCellInfo">
					<input type="password" name="{$fldname}" tabindex="{$vt_tab}" value="{$fldvalue}" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'">
				</td>
                {else}
                <td width=20% class="dvtCellLabel" align=right>
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
				</td>
				<td width=30% class="dvtCellInfo" align="left">{$CHANGE_PW_BUTTON}</td>	
				{/if}
		{elseif $uitype eq 30}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
			</td>
			<td colspan="3" width="30%" align=left class="dvtCellInfo">
				{assign var=check value=$secondvalue[0]}
				{assign var=yes_val value=$secondvalue[1]}
				{assign var=no_val value=$secondvalue[2]}

				<input type="radio" name="set_reminder" tabindex="{$vt_tab}" value="Yes" {$check}>&nbsp;{$yes_val}&nbsp;
				<input type="radio" name="set_reminder" value="No">&nbsp;{$no_val}&nbsp;

				{foreach item=val_arr from=$fldvalue}
					{assign var=start value="$val_arr[0]"}
					{assign var=end value="$val_arr[1]"}
					{assign var=sendname value="$val_arr[2]"}
					{assign var=disp_text value="$val_arr[3]"}
					{assign var=sel_val value="$val_arr[4]"}
					<select name="{$sendname}" class="small" fieldonly='{$fieldonly}' >
						{section name=reminder start=$start max=$end loop=$end step=1 }
							{if $smarty.section.reminder.index eq $sel_val}
								{assign var=sel_value value="SELECTED"}
							{else}
								{assign var=sel_value value=""}
							{/if}
							<OPTION VALUE="{$smarty.section.reminder.index}" "{$sel_value}">{$smarty.section.reminder.index}</OPTION>
						{/section}
					</select>
					&nbsp;{$disp_text}
				{/foreach}
			</td>
		{elseif $uitype eq 26}
		<td width="20%" class="dvtCellLabel" align=right>
		<font color="red">{$mandatory_field}</font>{$fldlabel}
		{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
		</td>
		<td width="30%" align=left class="dvtCellInfo">
			<select name="{$fldname}" tabindex="{$vt_tab}" class="small" fieldonly='{$fieldonly}' >
				{foreach item=v key=k from=$fldvalue}
				<option value="{$k}">{$v}</option>
				{/foreach}
			</select>
		</td>
        {elseif $uitype eq 400}{*edit:can; reason:费用报销-》票据张数 other:正整数*}
        	<td width="20%" class="dvtCellLabel" align=right>
		<font color="red">{$mandatory_field}</font>{$fldlabel}
		{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
		</td>
		<td width="30%" align=left class="dvtCellInfo">
		  <input type='text' name="{$fldname}" value="{$fldvalue}" positive ='1'   fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'">
		</td>
		{elseif $uitype eq 27}
		<td width="20%" class="dvtCellLabel" align="right" >
			<font color="red">{$mandatory_field}</font>{$fldlabel_other}&nbsp;
			{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}" id="{$fldname}_mass_edit_check" class="small" >{/if}
        </td>
        <td width="30%" align=left class="dvtCellInfo">
			<select class="small"  fieldonly='{$fieldonly}' name="{$fldname}" onchange="changeDldType((this.value=='I')? 'file': 'text');">
                {section name=combo loop=$fldlabel}
                {if $fldlabel[combo] eq 'Internal'}
                <option value="{$fldlabel_combo[combo]}" {$fldlabel_sel[combo]} >{'INTERNAL'|@getFixedLabel} </option>
                {elseif $fldlabel[combo] eq 'External'}
			     <option value="{$fldlabel_combo[combo]}" {$fldlabel_sel[combo]} >{'EXTERNAL'|@getFixedLabel} </option>
                {else}
                <option value="{$fldlabel_combo[combo]}" {$fldlabel_sel[combo]} >{$fldlabel[combo]|@getFixedLabel} </option>
                {/if}
				{/section}
			</select>
			<script>
				function lingdang_{$fldname}Init(){ldelim}
					var d = document.getElementsByName('{$fldname}')[0];
					var type = (d.value=='I')? 'file': 'text';

					changeDldType(type, true);
				{rdelim}
				if(typeof window.onload =='function'){ldelim}
					var oldOnLoad = window.onload;
					document.body.onload = function(){ldelim}
						lingdang_{$fldname}Init();
						oldOnLoad();
					{rdelim}
				{rdelim}else{ldelim}
					window.onload = function(){ldelim}
						lingdang_{$fldname}Init();
					{rdelim}
				{rdelim}

			</script>
		</td>
		{elseif $uitype eq 28}
        <!--$uitype =28 上传开始 by andy 20131129-->
		<td width="100" height="30px" class="dvtCellLabel" align=right>
			<font color="red">{$mandatory_field}</font>{$usefldlabel}
			{if $MASS_EDIT eq '1'}
				<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small"  disabled >
			{/if}
		</td>
		<td colspan="1" width="30%" align="left" class="dvtCellInfo">
		<script type="text/javascript">
			function changeDldType(type, onInit){ldelim}
           
				var fieldname = '{$fldname}';
				if(!onInit){ldelim}
					var dh = getObj('{$fldname}_hidden');
					if(dh) dh.value = '';
				{rdelim}

				var v1 = document.getElementById(fieldname+'_E__');
				var v2 = document.getElementById(fieldname+'_I__');
				var msg = document.getElementById('limitmsg');

				var text = v1.type =="text"? v1: v2;
				var file = v1.type =="file"? v1: v2;
				var filename = document.getElementById(fieldname+'_value');
				{literal}
				if(type == 'file'){
					// Avoid sending two form parameters with same key to server
					file.name = fieldname;
					text.name = '_' + fieldname;

					file.style.display = '';
					text.style.display = 'none';
					text.value = '';
					filename.style.display = '';
					msg.style.display = '';
				}else{
					// Avoid sending two form parameters with same key to server
					text.name = fieldname;
					file.name = '_' + fieldname;

					file.style.display = 'none';
					text.style.display = '';
					file.value = '';
					filename.style.display = 'none';
					filename.innerHTML="";
                                        msg.style.display = 'none';
				}
				{/literal}
			{rdelim}
		</script>
		<div>
        {*onchange="validateFilename(this);validateFileSize(this,'{$UPLOAD_MAXSIZE}');" *}
			<input name="{$fldname}" name="{$fldname}_I__" type="file" value="{$secondvalue}" tabindex="{$vt_tab}" style="display: none;"/>
			<input type="hidden" name="{$fldname}_hidden" value="{$secondvalue}"/>
			<input type="hidden" name="id" value=""/>
			<input type="text" id="{$fldname}_E__" name="{$fldname}"  fieldonly='{$fieldonly}'  class="detailedViewTextBox" onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'" value="{$secondvalue}" /><br>
			<div id="displaySize"></div>
            <span id="{$fldname}_value" style="display:none;">
				{if $secondvalue neq ''}
					[{$secondvalue}]
				{/if}
			</span>
		</div>
                <span id="limitmsg" style= "color:red; display:none;"> {'MAXUPLOADSIZE'|@getFixedLabel} {$UPLOADSIZE}MB</span>
		</td>
        <!--$uitype =28 上传结束 by andy 20131129-->
		{elseif $uitype eq 83} <!-- Handle the Tax in Inventory -->
			{foreach item=tax key=count from=$TAX_DETAILS}
				{if $tax.check_value eq 1}
					{assign var=check_value value="checked"}
					{assign var=show_value value="visible"}
				{else}
					{assign var=check_value value=""}
					{assign var=show_value value="hidden"}
				{/if}
				<td align="right" class="dvtCellLabel" style="border-bottom:0px;">
					{$tax.taxlabel} ({'PERCENT'|@getFixedLabel})
                    
					<input type="checkbox" name="{$tax.check_name}" id="{$tax.check_name}" class="small" onclick="fnshowHide(this,'{$tax.taxname}')" {$check_value}>
				</td>
				<td class="dvtCellInfo" align="left" style="border-bottom:0px;border-color:white;">
					<input type="text" class="detailedViewTextBox"  fieldonly='{$fieldonly}'  name="{$tax.taxname}" id="{$tax.taxname}" value="{$tax.percentage}" style="visibility:{$show_value};" onBlur="fntaxValidation('{$tax.taxname}')">
				</td>
			   </tr>
			{/foreach}
			<td colspan="1" class="dvtCellInfo" style="border-bottom:0px;"></td>
        {elseif $uitype eq 150}{*date:2013-10-31  edit:chj  reson:采购订单表单信息*}
			<td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
                {if $PURCHASEORDERID >0 && ($MODULE == 'Stock')}
    				<input name="purchaseorder_name" id="purchaseorder_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$PURCHASEORDERNAME}">
                    <input name="purchaseorder_id" id="purchaseorder_id" type="hidden" value="{$PURCHASEORDERID}">
                {else}
                    <input name="purchaseorder_name" id="purchaseorder_name" readonly type="text" fieldonly='{$fieldonly}'  style="border:1px solid #bababa;" value="{$fldvalue}">
                    <input name="purchaseorder_id" id="purchaseorder_id" type="hidden" value="{$secondvalue}">
                {/if}
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  
                onclick="showrelatedlist('HelpDesk','PurchaseOrder',"select','')" ></a>
				<input class="icon-homeimg icon-clear inpb-reset" type="button" tabindex="{$vt_tab}" title="{'CLEAR'|@getFixedLabel}"  onclick="this.form.purchaseorder_id.value='';this.form.purchaseorder_name.value='';return false;" />
			</td>
            <script type="text/javascript">
            function open_form_specific(module,pop_type, fromlink)
            {ldelim}
                    var vendor = document.getElementById('vendor_id').value;
                    return window.open("index.php?module=PurchaseOrder&action=Popup&html=Popup_picker&popuptype="+pop_type+"&form=EditView&select=enable&fromlink="+fromlink+"&vendorid="+vendor+"&frommodule="+module,"test","width=840,height=602,resizable=1,scrollbars=1");
            {rdelim}
            </script>
            {elseif $uitype eq 151}{*date:2013-10-31  edit:chj  reson:仓库信息*}
            <td width="20%" class="dvtCellLabel" align=right>
				<font color="red">{$mandatory_field}</font>{$usefldlabel}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
				<select name="{$fldname}" id="{$fldname}" style="width:150px;">
                {foreach item=value key=key from=$WAREALL}
                    <option value="{$key}" {if $key == $fldvalue}selected{/if}>{$value}</option>
                {/foreach}
                </select>
				{if $MODULE eq 'Checks'}
					<input type="button" value="{'intheinstankinventory'|@getFixedLabel}" onclick="InstantInventory('{$MODULE}')" />
				{/if}
			</td>
		{elseif $uitype eq 1101 || $uitype eq 1102 || $uitype eq 1103}
            <!--
            更新操作
            edit:cdw
            date:20131119
            reason:0005674: 新增单据自定义字段((手机、传真或QQ)，设置新增字段为“必填字段”，保存后，新增单据，结果必填字段没有显示红色*。
            -->
            <td width="20%" class="dvtCellLabel" align="right">
            {if $typeofdata eq 'M'}
               <font color="red">{$mandatory_field}</font><span style="font-size:12px;">{$usefldlabel}</span>
               {if $MASS_EDIT eq '1'}
               <input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" />
               {/if}
            {else}
               <font style="font-size:12px;">{$usefldlabel}</font>
               {if $MASS_EDIT eq '1'}
               <input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" />
               {/if}
            {/if}
            </td>
            <td width="30%" align="left" class="dvtCellInfo">
              <input fieldonly='{$fieldonly}' type="text" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class="detailedViewTextBox" style="width:58%;" onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onBlur="this.className='detailedViewTextBox'"/>
            </td>
        {elseif $uitype eq 200 && $MODULE_ACTIVATE == true}
            <td width="20%" class="dvtCellLabel" align=right>
				{'ORIGNALBILL'|@getFixedLabel}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
                <input type="text" id="salesorder_id" name="salesorder_id" />
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  
                onclick="selectSalesOrder('{$MODULE}');"></a>
            </td>
        {elseif $uitype eq 201 && $MODULE_ACTIVATE == true}
            <td width="20%" class="dvtCellLabel" align=right>
				{'ORIGNALBILL'|@getFixedLabel}
			</td>
			<td width="30%" align=left class="dvtCellInfo">
                <input type="text" id="purchaseorder_id" name="purchaseorder_id" />
                <a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}"  
                onclick="selectPurchaseOrder('{$MODULE}');"></a>
            </td>
        {/if}