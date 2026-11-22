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
{*//Hidden fields for modules DetailView//  *}
<!--修改编码格式:统一编码：UTF-8-->
<input type="hidden" name="parenttab" value="{$CATEGORY}">
<input type="hidden"  name="allselectedboxes" id="allselectedboxes">
<!--{*	查看页面返回列表，启用搜索session参数		*}-->
<input type="hidden" name="query_session" id="query_session" value="0"/>

<!--{*	返回审批中心		*}-->
<input type="hidden" name="result_aprove" id="result_aprove" 
value="{$RESULT_APPROVE}"/>
<input type="hidden" name="module" id="detailmodule" value="{$MODULE}">
<input type="hidden" name="record" value="{$ID}">
<input type="hidden" name="isDuplicate" value=false>
<input type="hidden" name="action">
<input type="hidden" name="return_module">
<input type="hidden" name="return_action">
<input type="hidden" name="return_id">
<input type="hidden" name="mode">
<input type="hidden" name="version_account" value="{$VERSION_ACCOUNT}" />
{if $MODULE eq 'Accounts'}
	

	<input type="hidden" name="contact_id">
	<input type="hidden" name="member_id">
	<input type="hidden" name="opportunity_id">
	<input type="hidden" name="case_id">
	<input type="hidden" name="task_id">
	<input type="hidden" name="meeting_id">
	<input type="hidden" name="call_id">
	<input type="hidden" name="email_id">
	<input type="hidden" name="source_module">
	<input type="hidden" name="entity_id">
    <input type="hidden" id="assign_name" value="{$ASSIGNUSERID}"/>
	<input type="hidden" name="publicaccounttype" value="{$PUBLICACCOUNTTYPE}"/>
	<input type="hidden" name="pool_id" value="{$POOL_ID}"/>
	{$HIDDEN_PARENTS_LIST}
 {elseif $MODULE eq 'Leads'}
 <input type="hidden" name="publicaccounttype" value="{$PUBLICACCOUNTTYPE}"/>
 <input type="hidden" name="pool_id" value="{$POOL_ID}"/>
{elseif $MODULE eq "Users"}
    <input type="hidden" name="changepassword" />
    <input type="hidden" name="old_password" />
    <input type="hidden" name="new_password" />
{elseif $MODULE eq 'Contacts'}
	
	<input type="hidden" name="reports_to_id">
	<input type="hidden" name="opportunity_id">
	<input type="hidden" name="contact_id" value="{$ID}">
	<input type="hidden" name="parent_id" value="{$ID}">
	<input type="hidden" name="contact_role">
	<input type="hidden" name="task_id">
	<input type="hidden" name="meeting_id">
	<input type="hidden" name="call_id">
	<input type="hidden" name="case_id">
	<input type="hidden" name="new_reports_to_id">
	<input type="hidden" name="email_directing_module">
	{$HIDDEN_PARENTS_LIST}
{elseif $MODULE eq 'Potentials'}
	
       
        <input type="hidden" name="contact_role">
        <input type="hidden" name="opportunity_id" value="{$ID}">
        <input type="hidden" name="task_id">
        <input type="hidden" name="meeting_id">
        <input type="hidden" name="call_id">
        <input type="hidden" name="email_id">
        <input type="hidden" name="source_module">
        <input type="hidden" name="entity_id">
        <input type="hidden" name="convertmode">
        <input type="hidden" name="account_id" value="{$ACCOUNTID}">
		<input type="hidden" name="contact_id" value="{$CONTACTID}">
{elseif $MODULE eq 'Leads'}

	<input type="hidden" name="lead_id" value="{$ID}">
	<input type="hidden" name="parent_id" value="{$ID}">
	<input type="hidden" name="email_directing_module">
	{$HIDDEN_PARENTS_LIST}
{elseif $MODULE eq 'Products' || $MODULE eq 'Vendors' || $MODULE eq 'PriceBooks' || $MODULE eq 'Services'}
	{if $MODULE eq 'Products'}
		<input type="hidden" name="product_id" value="{$id}">
	{elseif $MODULE eq 'Vendors'}
		<input type="hidden" name="vendor_id" value="{$id}">
	{/if}
	<input type="hidden" name="parent_id" value="{$id}">
	
        <input type="hidden" name="return_module" value="{$RETURN_MODULE}">
        <input type="hidden" name="return_id" value="{$RETURN_ID}">
        <input type="hidden" name="return_action" value="">

{elseif $MODULE eq 'Emails'}
       
        <input type="hidden" name="contact_id" value="{$CONTACT_ID}">
        <input type="hidden" name="user_id" value="{$USER_ID}">
        <input type="hidden" name="return_module" value="{$RETURN_MODULE}">
        <input type="hidden" name="return_action" value="{$RETURN_ACTION}">
        <input type="hidden" name="return_id" value="{$RETURN_ID}">
        <input type="hidden" name="source_module">
        <input type="hidden" name="entity_id">

{elseif $MODULE eq 'Faq'}
	<input type="hidden" name="module" value="{$MODULE}">
        <input type="hidden" name="isDuplicate" value=false>
        <input type="hidden" name="action">
        <input type="hidden" name="return_module">
        <input type="hidden" name="return_action">
        <input type="hidden" name="return_id">
        <input type="hidden" name="source_module">
        <input type="hidden" name="entity_id">
{elseif $MODULE eq 'Quotes'}

        <input type="hidden" name="convertmode">
   
        <input type="hidden" name="member_id">
        <input type="hidden" name="opportunity_id">
        <input type="hidden" name="case_id">
        <input type="hidden" name="task_id">
        <input type="hidden" name="meeting_id">
        <input type="hidden" name="call_id">
        <input type="hidden" name="email_id">
        <input type="hidden" name="source_module">
        <input type="hidden" name="entity_id">
{elseif $MODULE eq 'PurchaseOrder' || $MODULE eq 'SalesOrder' || $MODULE eq 'Invoice'}
	
        <input type="hidden" name="member_id">
        <input type="hidden" name="opportunity_id">
        <input type="hidden" name="case_id">
        <input type="hidden" name="task_id">
        <input type="hidden" name="meeting_id">
        <input type="hidden" name="call_id">
        <input type="hidden" name="email_id">
        <input type="hidden" name="source_module">
        <input type="hidden" name="entity_id">
	{if $MODULE eq 'SalesOrder'}
        	<input type="hidden" name="convertmode">
	{/if}
{elseif $MODULE eq 'Calendar'}

        <input type="hidden" name="activity_mode" value="{$ACTIVITY_MODE}">
        <input type="hidden" name="isDuplicate" value=false>
        
        <input type="hidden" name="return_module">
        <input type="hidden" name="return_action">
        <input type="hidden" name="return_id">
        <input type="hidden" name="user_id" value="{$USER_ID}">
{elseif $MODULE eq 'Campaigns'}
       
        <input type="hidden" name="return_module">
        <input type="hidden" name="return_action">
        <input type="hidden" name="return_id">
{elseif $MODULE eq 'Reminds'}
     
	<input type="hidden" name="entity_id">
    <input type="hidden" name="reltab" >
    <input type="hidden" name="status_rmd" value="">
    <input type="hidden" name="time_start" id="time_start">
    <input type="hidden" name="assigned_user_id" value="">

{/if}

