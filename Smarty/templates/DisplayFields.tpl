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
{assign var="fromlink" value=""}

<!-- Added this file to display the fields in Create Entity page based on ui types  -->
{foreach key=label item=subdata from=$data}
	<tr>
	{foreach key=mainlabel item=maindata from=$subdata}
		{include file='DetailView/EditViewUI.tpl'}
	{/foreach}
   	</tr>
{/foreach}