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
<div style="display: block;" id="orgLay" class="LdPop_box LdPopWidth350px">

<div class="Title"><img src="themes/softed/tier/icon_loto.png" class="Logo" />
    <span class="Name">{'ASSINGPICKLISTVALUE'|@getFixedLabel}</span>
	<a href="javascript:fnhide('actiondiv');puyoungJS_DialogBox.unblock();">
		<img src="themes/softed/tier/icon_close.png" class="Close" />
	</a>
</div>		
<div class="Content_div">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td class="Note">
    		<table border="0" cellspacing="0" cellpadding="5" width="100%" id="assignPicklistTable">
        	<tbody>
        		<tr>	
        			<td width="auto;">	
        				<b>{'AVAILPICKLISTVALUE'|@getFixedLabel}</b>
        				<select multiple id="availList" name="availList" class="crmFormList" style="overflow:auto; height: 150px;width:200px;border:1px solid #666666;font-family:Arial, Helvetica, sans-serif;font-size:12px;">
        					{foreach item=pick_val key=pick_key from=$PICKVAL}
        						<option value="{$pick_key}">{$pick_val}</option>
        					{/foreach}
        				</select>
        			</td>
                    <td align="center" width="25px;">
        				<a class="icon-homearr icon-mright" href="javascript:;" title="{'MOVERIGHT'|@getFixedLabel}" onclick="moveRight();"></a>
        				<a class="icon-homearr icon-mleft" href="javascript:;" title="{'MOVELEFT'|@getFixedLabel}" onclick="removeValue();"></a>
        			</td>
        			<td width="auto;">
        				<b>{'ASSIGNROLEPICKLIST'|@getFixedLabel} {$ROLENAME}</b>
        				<select multiple id="selectedColumns" name="selectedColumns" class="crmFormList" style="overflow:auto; height: 150px;width:200px;border:1px solid #666666;font-family:Arial, Helvetica, sans-serif;font-size:12px;">
        					{foreach item=val key=key from=$ASSIGNED_VALUES}
        						<option value="{$key}">{$val}</option>
        					{/foreach}
                	    </select>
        			</td>
                    <td align="center">
        				<a class="icon-homearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFixedLabel}" onclick="moveUp();"></a>
        				<a class="icon-homearr icon-mdown" href="javascript:;" title="{'MOVEDOWN'|@getFixedLabel}" onclick="moveDown();"></a>
        			</td>
        		</tr>
        		<tr>
        			<td>
        				<a href='javascript:;' onclick="showRoleSelectDiv('{$ROLEID}')" id="addRolesLink">
        					<b>{'ADDOTHERROLEPICK'|@getFixedLabel}</b>
        				</a>
        			</td> 	
        		</tr>
        	</tbody>
        	</table>
        </td>
      </tr>
    </table>
</div>
<div class="Bottom">
    <div class="Bottom_div width145">
        <a class="Button_saveGreen width60" onclick="saveAssignedValues('{$MODULE}','{$FIELDNAME}','{$ROLEID}');" >{'SAVE'|@getFixedLabel}</a><span>&nbsp;</span>
        <a class="Button_backOrg width60" onclick="fnhide('actiondiv');puyoungJS_DialogBox.unblock();">{'CANCEL'|@getFixedLabel}</a>
    </div>
</div>

</div>