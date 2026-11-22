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
<script>
var moveupLinkObj,moveupDisabledObj,movedownLinkObj,movedownDisabledObj;
</script>
<table width="100%" border="0" cellpadding="9" cellspacing="0">
	<tbody>
    <tr bgcolor="#F6F6F6">
    	<td colspan="4" class="TabLeftHeard">
        	<span>{$MOD.LBL_SELECT_COLUMNS}</span>
        	{$MOD.LBL_SELECT_COLUMNS_TO_GENERATE_REPORTS} 
        </td>
	</tr>
	<tr>
    	<td colspan="2" style="padding-right:190px;" align="right"><b>{$MOD.LBL_AVAILABLE_FIELDS}</b></td>
    	<td colspan="2"><b>{$MOD.LBL_SELECTED_FIELDS}</b></td>
	</tr>
	<tr  valign="top">
    	<td align="right" width="30%">
        	<select style="overflow: auto; height: 245px; width: 160px;" id="availList" multiple size="16" name="availList" ondblclick='addColumnCustomviewModule("availList","selectedColumns")'>
        	{$BLOCK1}
        	</select>
    	</td>
    	<td align="center" width="10%" valign="middle">
    	   <a class="icon-homearr icon-mright" href="javascript:;" title="{$APP.LBL_ADD_ITEM}"  onclick="copySelectedOptionsCustomviewModule('availList','selectedColumns');return false;" ></a><br/>
           <a class="icon-homearr icon-mleft" href="javascript:;" title="{'MOVELEFT'|@getFixedLabel}"  onclick="copySelectedOptionsCustomviewModule('selectedColumns','availList');return false;"></a>
        </td>
    	<input type="hidden" name="selectedColumnsString"/>
    	<td align="left" width="23%">
        	<select style="overflow: auto; height: 245px; width: 160px;" id="selectedColumns" size="16" name="selectedColumns" onchange="selectedColumnClick(this);" multiple ondblclick='addColumnCustomviewModule("selectedColumns","availList")'>
        	{$BLOCK2}
        	</select>
    	</td>
    	<td align="left" width="10%" valign="middle" align="center">
            <a class="icon-homearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFixedLabel}" onclick="moveUp();"></a>
            <br />
            <a class="icon-homearr icon-mdown" href="javascript:;" title="{'MOVEDOWN'|@getFixedLabel}" onclick="moveDown();"></a>
        </td>
        <td>&nbsp;</td>
	</tr> 
	</tbody>
</table>