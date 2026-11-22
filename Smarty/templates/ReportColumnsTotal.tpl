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
<table width="100%" border="0" cellpadding="9" cellspacing="0">
	<tbody>
    <tr bgcolor="#F6F6F6">
		<td colspan="2" class="TabLeftHeard">
        	<span class="font14 lineheight16 greyFont8 fontbold">{$MOD.LBL_CALCULATIONS}</span>
        	{$MOD.LBL_SELECT_COLUMNS_TO_TOTAL}
        </td>
	</tr>
	<tr>
        <td colspan="2">
    	<div style="overflow:auto;">
    	<table class="listEntries" border="0" cellpadding="0" cellspacing="1" width="100%" >
    		<tbody>
    		<tr>	
        		<th width="40%">{$MOD.LBL_COLUMNS}</th>
        		<th width="15%">{$MOD.LBL_COLUMNS_SUM}</th>
        		<th width="15%">{$MOD.LBL_COLUMNS_AVERAGE}</th>
        		<th width="15%">{$MOD.LBL_COLUMNS_LOW_VALUE}</th>
        		<th width="15%">{$MOD.LBL_COLUMNS_LARGE_VALUE}</th>
    		</tr>
    		{foreach item=modules from=$BLOCK1}
    		{foreach item=row from=$modules}
    		<tr class="Hover" bgcolor="white">
        		{if $RECORDID neq ''}
                                <td><b>{$row.label.0}</b></td>
                        {else}
                                <td><b>{$row.0}</b></td>
                        {/if}
        		<td>{$row.1}</td>
        		<td>{$row.2}</td>
        		<td>{$row.3}</td>
        		<td>{$row.4}</td>
    		</tr>
    		{/foreach}
    		{/foreach}
    
    	{if $ROWS_COUNT eq 0}
    		<tr bgcolor="white"><td colspan="5"><b>{$MOD.NO_COLUMN}</b></td></tr>
    	{/if}
    
    		</tbody>
    	</table>
    	</div>
    	</td>
    </tr>
	</tbody>
</table>