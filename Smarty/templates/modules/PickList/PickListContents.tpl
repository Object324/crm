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
<!--修改编码格式:统一编码：UTF-8-->
<div class="ControlDiv2">
    <div class="F_l">
    	<span>{'SELECTMODULE'|@getFixedLabel}</span>
        <select name="pickmodule" id="pickmodule" onChange="changeModule();">
		{foreach key=modulelabel item=module from=$MODULE_LISTS}
		
		   {assign var="modulelabel" value=$module|@getTranstab:$module}
		
			{if $MODULE eq $module}
				<option value="{$module}" selected>{$modulelabel}</option>
			{else}
                 <option value="{$module}">{$modulelabel}</option>
           	{/if}
		{/foreach}
		</select>             
    </div>
    <div class="F_l">
    	<span>{'SELECTPICKLIST'|@getFixedLabel}</span>
                <select name="avail_picklists" id="allpick">
			{foreach key=fld_nam item=fld_lbl from=$ALL_LISTS}
				<option value="{$fld_nam}">{$fld_lbl}</option>
			{/foreach}
		</select>
        {*<font style="color:red;">&nbsp;* {'MODULEDROPDOWN'|@getFixedLabel}</font>  *}       
    </div>

        <div class="F_r">
            <input type="button" value="{'ADDLESSIONPLAN'|@getFixedLabel}" name="add" class="createauto" onclick="showAddDiv()"/>
            <input type="button" value="{'UPDATES'|@getFixedLabel}" name="del" class="editauto" onclick="showEditDiv()"/>
            <input type="button" value="{'DELETE'|@getFixedLabel}" name="del" class="deleteauto" onclick="showDeleteDiv()"/>  
        </div>
   </span>
	
 </div>
<div class="pad10" >
    <div id="pickListContents">
    <table width="100%" class="listTable noborderT noborderR" cellpadding="5" cellspacing="0">
    	{foreach item=picklists from=$PICKLIST_VALUES}
    	<tr class="borderT">
    		{foreach item=picklistfields from=$picklists}
    			{if $picklistfields neq ''}
    				<td class="TitleHeading noborderL" width="33%" valign="top" align="left" >
    				    <b>{$picklistfields.fieldlabel}</b>    					
    				</td>
                    <!--
    				<td class="TitleHeading" valign="top">
    					<input type="button" value="{'ASSIGNPICKLIST'|@getFixedLabel}" class="editauto" onclick="assignPicklistValues('{$MODULE}','{$picklistfields.fieldname}','{$picklistfields.fieldlabel}');" >
    				</td>
                    -->
    			{else}
    				<td class="TitleHeading">&nbsp;</td>
    			{/if}
    		{/foreach}
    	</tr>       
    	<tr>
    		{foreach item=picklistelements from=$picklists}          
    			{if $picklistelements neq ''}
    				<td valign="top" class="borderR">
                    
                    {if $picklistelements.value|@count gt 10}
    				<ul class="mar0 padL10" style="height:280px;overflow:auto;">
                    {else}
                    <ul class="mar0 padL10" >
                    {/if}
    					{foreach item=elements from=$picklistelements.value}
    						{if $TEMP_MOD[$elements] neq ''}
    							<li style="color:#666;padding: 6px 0;">{$TEMP_MOD[$elements]}</li>
    						{elseif $MOD_PICKLIST[$elements] neq ''}
    							<li style="color:#666;padding: 6px 0;">{$MOD_PICKLIST[$elements]}</li>
    						{else}
    							<li style="color:#666;padding: 6px 0;">{$elements}</li>
    						{/if}
    					{/foreach}
    				</ul>
    				</td>
    			{else}
    				<td >&nbsp;</td>
    			{/if}
    		{/foreach}
    	</tr>
        
    	{/foreach}
    	</table>
    
    <!--edit:kevin date:2013-05-29 reason:4029-->
    </div>
</div>