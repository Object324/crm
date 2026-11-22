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
<form id="UnifiedSearch_moduleform" name="UnifiedSearch_moduleform">
    <div class="scrollContent scrollContent-autoheight">		
	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0" style="margin:0 auto;">
		{foreach item=SEARCH_MODULEINFO key=SEARCH_MODULENAME from=$ALLOWED_MODULES name=allowed_modulesloop}
		{if $smarty.foreach.allowed_modulesloop.index % 3 == 0}
		<tr >	
		{/if}
			<td class=""><input type='checkbox' name='search_onlyin' style="margin: -2px 4px 0 0;" value='{$SEARCH_MODULENAME}'
			{if $SEARCH_MODULEINFO.selected}checked=true{/if}>{$SEARCH_MODULEINFO.label}</td>
		{if $smarty.foreach.allowed_modulesloop.index % 3 == 2}
		</tr>
		{/if}
		{/foreach}
	</table>  
    </div>      	
</form>