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
{assign var="Firstrow" value=$FIRSTROW}
<table border="0" class="small cellLabel" cellpadding="0" cellspacing="1" width="100%">
	{foreach name=iter item=row from=$Firstrow}
	{assign var="counter" value=$smarty.foreach.iter.iteration}
	<tr>
		<td class="small" align="center" height="30">
			{$SELECTFIELD[$counter]}
		</td>
	</tr>
	{/foreach}
</table>
