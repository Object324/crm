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
<!--分页-->
<div class="AuditPaging_div">
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="padding:5px 0px;">
  <tr>
    <td valign="top" class="R">
    	<div class="PageDiv0">
        	<div class="ld-flex-start">
            	<div class="ld-pagenum-div">{$RECORD_COUNTS}</div>
                {$NAVIGATION}
            </div>
        </div>
    </td>
  </tr>
</table>
</div>
<!--分页  end-->     
<div class="clear"></div>

<table border="0" cellspacing="1" cellpadding="0" width="100%" class="listEntries">
	<tr>
	{foreach item=header from=$LIST_HEADER}
  		<th>{$header|@getFixedLabel}</th>
	{/foreach}
	</tr>
	{foreach item=entity name=listentity key=entity_id from=$LIST_ENTRIES}
    {if $smarty.foreach.listentity.iteration mod 2 eq '1'}
    <tr bgcolor="white" class="Hover">
    {else}
	<tr bgcolor="white" class="Hover lvtColDataBj">
    {/if}
		 {foreach item=data from=$entity}	
			 <td>{$data}</td>
		 {/foreach}
	</tr>
	{foreachelse}
	<tr bgcolor="white">
	<td colspan="4" align="center">
        <br />
        <div class="noResultBG">   		 
           <div class="noResultContent"> 
        		<div class="divNoRecord">{'NOTFOUNDANYRECORD'|@getFixedLabel}</div>
           </div>      
        </div>
        <br />
    </b>
	</td>
	</tr>
	{/foreach}
</table>
