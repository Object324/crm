{*<!--
/*+*******************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
-->*}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<!--修改编码格式:统一编码：UTF-8-->
<!-- <div style="float:left;color:#999;padding:6px 0px;">
    {$REGISTERINFO}
</div> -->
<table border=0 cellspacing=0 cellpadding=5 width=100% class="listTableTopButtons">

{if $ERROR_MSG neq ''}
<tr>
	{$ERROR_MSG}
</tr>
{/if}
</table>
{$CONTENTS}
<!--分页-->
<div class="PageDiv0" style="padding:0px 0px 6px 0px;">
	<ul>
    	<li>{$recordListRange}</li>
        {$NAVIGATION}
    </ul>
</div>
