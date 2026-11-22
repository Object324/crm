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
修改编码格式:统一编码：UTF-8
-->*}
<input type="hidden" name="module">
<input name="maxrecords" type="hidden" value="{$MAX_RECORDS}" id='maxrecords'>
<input id="recordid" type="hidden" value="{$RECORDID}">
<input type="hidden" name="mode">
<input type="hidden" name="return_module" id="return_module" value="{$MODULE}">
<input type="hidden" name="RLreturn_module" id="RLreturn_module" value="{$MODULE}">
<input type="hidden" name="allselectedboxes"  id="allselectedboxes">
{if $SinglePane_View eq 'true'}
	<input type="hidden" name="return_action" value="DetailView">
{else}
	<input type="hidden" name="return_action" value="CallRelatedList">
{/if}
<input type="hidden" name="return_id" value="{$ID}">
<input type="hidden" name="RLparent_id" id="RLparent_id" value="{$ID}">
<input type="hidden" name="parenttab" id="parenttab" value="{$CATEGORY}">
<input type="hidden" name="action">
{if $MODULE eq 'Calendar'}
	<input type="hidden" name="activity_mode" value="{$ACTIVITY_MODE}">
	<input type="hidden" name="user_id" value="{$USER_ID}">
	<input type="hidden" name="record" value="{$ID}">
{elseif $MODULE eq 'Accounts'}
    {*BUG20240529-44 ls 240531 客户-详情页编辑客户单据 修改”客户类型“字段 ”代理商“字段会变成”客户名称“(页面上两个name=account_id导致布局规则取值代理商字段错误)*}
{*        <input type="hidden" name="account_id" id="raccount_id" value="{$ID}">*}
        <input type="hidden" name="contact_id" id="rcontact_id" value="{$CONTACTID}">
	{$HIDDEN_PARENTS_LIST}
{elseif $MODULE eq 'Contacts'}
{*    <input type="hidden" name="contact_id" id="rcontact_id" value="{$ID}">*}
    <input type="hidden" name="account_id" id="raccount_id" value="{$ACCOUNTID}">
	<input type="hidden" name="campaignid" value="{$campaignid}">
	{$HIDDEN_PARENTS_LIST}
{elseif $MODULE  eq 'Project'}
    <input type="hidden" name="contact_id" id="rcontact_id" value="{$CONTACTID}">
    <input type="hidden" name="account_id" id="raccount_id" value="{$ACCOUNTID}">
    <!-- <input type="hidden" name="contact_id" id="rcontact_id" value="{$CONTACTID}"> -->
    <input type="hidden" name="potential_id" id="rpotential_id" value="{$POTENTIALID}">
    <input type="hidden" name="salesorderid" id="rsalesorderid" value="{$SALESORDERID}">
{elseif $MODULE  eq 'ProjectTask'}
    <input type="hidden" name="account_id" id="raccount_id" value="{$ACCOUNTID}">
    <input type="hidden" name="contact_id" id="rcontact_id" value="{$CONTACTID}">
    <input type="hidden" name="projecttask_id" value="{$ID}">
    <input type="hidden" name="projectid" id="rprojectid" value="{$PROJECTID}">
{elseif $MODULE eq 'Campaigns'}
    <input type="hidden" name="campaignid" value="{$ID}">
{elseif $MODULE eq 'Leads'}
	<input type="hidden" name="lead_id" value="{$ID}">
	<input type="hidden" name="campaignid" value="{$campaignid}">
	{$HIDDEN_PARENTS_LIST}
{elseif $MODULE eq 'Potentials'}
    <input type="hidden" name="potential_id" value="{$ID}">
    <input type="hidden" name="account_id" id="raccount_id" value="{$ACCOUNTID}">
    <input type="hidden" name="contact_id" id="rcontact_id" value="{$CONTACTID}">
{elseif $MODULE eq 'Quotes'}
    <input type="hidden" name="quoteid" value="{$ID}">
    <input type="hidden" name="account_id" id="raccount_id" value="{$ACCOUNTID}">
    <input type="hidden" name="contact_id" id="rcontact_id" value="{$CONTACTID}">
    <input  type="hidden" name="potential_id" id="rpotential_id" value="{$POTENTIALID}"/>
{elseif $MODULE eq 'SalesOrder'}
    <input type="hidden" name="salesorderid" value="{$ID}">
    <input type="hidden" name="salesorder_id" id="rsalesorder_id" value="{$ID}"/>
    <input type="hidden" name="account_id" id="raccount_id" value="{$ACCOUNTID}">
    <input type="hidden" name="contact_id" id="rcontact_id" value="{$CONTACTID}">
    <input type="hidden" name="potential_id" id="rpotential_id" value="{$POTENTIALID}"/>
{elseif $MODULE eq 'PurchaseOrder'}
	<input type="hidden" name="purchaseorderid" id="rpurchaseorderid" value="{$ID}">
    <input type="hidden" name="vendor_id" id="rvendor_id" value="{$VENDOR_ID}">
	<input type="hidden" name="contact_id" id="rcontact_id" value="{$CONTACTID}">
{elseif $MODULE eq 'PurchaseInvoice' || $MODULE eq 'Stock'}
	<input type="hidden" name="vendor_id" id="rvendor_id" value="{$VENDOR_ID}">
{elseif $MODULE eq 'Invoice'}
    <input type="hidden" name="invoiceid" value="{$ID}">
	<input type="hidden" name="account_id" id="raccount_id" value="{$ACCOUNTID}">
{elseif $MODULE eq 'OutboundOrder'}
	<input type="hidden" name="account_id" id="raccount_id" value="{$ACCOUNTID}">
{elseif $MODULE eq 'Products'}
    <input type="hidden" name="product_id" value="{$ID}">
    <input type="hidden" name="vendor_id" id="rvendor_id" value="{$VENDOR_ID}">
{elseif $MODULE eq 'Vendors'}
	<input type="hidden" name="vendor_id" id="rvendor_id" value="{$ID}">
    <input type="hidden" name="account_id" id="raccount_id" value="{$ACCOUNTID}">
{elseif $MODULE eq 'PriceBooks'}
	<input type="hidden" name="pricebook_id" value="{$ID}">
	<input type="hidden" name="rcurrency_id" id="rcurrency_id" value="{$CURRENCY_ID}">
{elseif $MODULE eq 'Emails'}
	<input type="hidden" name="email_id"  value="{$ID}">
	<input type="hidden" name="user_id"  value="{$USER_ID}">
	<input type="hidden" name="record" value="{$ID}">
{elseif $MODULE eq 'HelpDesk'}
    <input type="hidden" name="ticket_id" value="{$ID}">
    <input type="hidden" name="account_id" id="raccount_id" value="{$ACCOUNTID}">
    <input type="hidden" name="contact_id" id="rcontact_id" value="{$CONTACTID}">
    <input type="hidden" name="salesorderid" id="rsalesorderid" value="{$SALESORDERID}">
{elseif $MODULE eq 'ServiceContracts' || $MODULE eq 'ServiceReturn'}
    <input type="hidden" name="account_id" id="raccount_id" value="{$ACCOUNTID}">
    <input type="hidden" name="contact_id" id="rcontact_id"  value="{$CONTACTID}">
    <input type="hidden" name="salesorderid" id="rsalesorderid" value="{$SALESORDERID}">
{elseif $MODULE eq 'VendorContact'}
	<input type="hidden" name="vendor_id" id="rvendor_id" value="{$VENDOR_ID}">
    <input type="hidden" name="vendorcontact_id" id="rvendorcontact_id" value="{$ID}">
{elseif $MODULE eq 'SendPayment'}
	<input type="hidden" name="vendor_id" id="rvendor_id" value="{$VENDOR_ID}">	
{/if}
    <input  type="hidden" name="Create" value="yes"/>