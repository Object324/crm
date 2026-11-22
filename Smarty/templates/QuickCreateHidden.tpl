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
{if $MODULE eq 'HelpDesk'}
	{literal}
	<form name="QcEditView" method="POST" action="index.php"  ENCTYPE="multipart/form-data">
	{/literal}
{elseif $SECONDEQUICKCREATE eq 'yes'}
	{literal}
	<form name="Second_QcEditView" method="POST" action="index.php"  ENCTYPE="multipart/form-data">
	{/literal}
{else}
	{literal}
	<form name="QcEditView" method="POST" action="index.php" ENCTYPE="multipart/form-data">
	{/literal}
{/if}

{if $MODULE eq 'Calendar'}
	<input type="hidden" name="activity_mode" value="{$ACTIVITY_MODE}">
{elseif $MODULE eq 'Events'}
        <input type="hidden" name="activity_mode" value="{$ACTIVITY_MODE}">
{elseif $MODULE eq 'Reminds'}
    <input type="hidden" name="reltab" >
    <input type="hidden" name="status_rmd" value="未读">
    <input type="hidden" name="time_start" id="time_start">
    <input type="hidden" name="assigned_user_id" value="{$CURRENT_USERID}">
{elseif $MODULE eq 'ContactRecords'}
    <input type="hidden" name="createview" value="create_view">
    {if $CTYPE eq 'gengjin'}
      <input type="hidden" name="gengjin" value="gengjin">
      <input type="hidden" name="return_module" value="{$return_module}">  
      <input type="hidden" name="return_action" value="{$return_action}">  
    	<input type="hidden" name="return_id" value="{$return_id}">
        <!-- <input type="hidden" name="record" value="{$return_id}"> -->
    {/if}
{elseif $MODULE eq 'ProjectProgress'}
    <input type="hidden" name="createview" value="create_view"/>
    {if $CTYPE eq 'progress'}
      <input type="hidden" name="progress" value="progress"/>
      <input type="hidden" name="return_module" value="{$return_module}"/>  
      <input type="hidden" name="return_action" value="{$return_action}"/>  
    	<input type="hidden" name="return_id" value="{$return_id}"/>
        <!-- <input type="hidden" name="record" value="{$return_id}"> -->
    {/if}
{elseif $MODULE eq 'Accounts'}
	<input type="hidden" value="yes" name="quickcreate_publicaccount" />
{/if}

    <input type="hidden" name="record" value="">

	<input type="hidden" name="action" value="Save">
	<input type="hidden" name="module" value="{$MODULE}">
    <input type='hidden' name="qcreatetype" value="{$QUICKTYPE}">
    <input type="hidden" name="Create" value="true"/>
    <input type="hidden" value="create_view" name="createview">
	<input type="hidden" value="{$DETAIL_QUICKCREATE}" name="detail_quickcreate" id="detail_quickcreate" />
 