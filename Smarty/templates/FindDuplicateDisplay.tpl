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

{*
/**
 *edit:kevin
 *date:2013-07-31
 *reason:4482
 *function:merge_fields
 */
*}
<div class="ld-pop-container">
{* If we duplicate merge is within same module show the headers ... *}
{if $MODULE eq $smarty.request.module}
	{*{include file='Buttons_List.tpl'}*}
	<div id="searchingUI" style="display:none;align:center;">
		<img src="{'searching.gif'|@lingdang_imageurl:$THEME}" alt="{$APP.LBL_SEARCHING}"  title="{$APP.LBL_SEARCHING}">
	</div>
{/if}
			
{* Common Output: Within module Duplicate Search or Post Import Duplicate Search *}		
<div id="duplicate_ajax" >
	{include file='FindDuplicateAjax.tpl'}
</div>
<div id="current_action" style="display:none">{$smarty.request.action|@vtlib_purify}</div>
{* END *}
</div>