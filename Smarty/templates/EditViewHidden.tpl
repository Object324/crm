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
{if $MODULE eq 'Emails'}
	<form name="EditView"  id="frmeditview" method="POST" ENCTYPE="multipart/form-data" action="index.php">
        <input type="hidden" name="form">
        <input type="hidden" name="send_mail">
        <input type="hidden" name="contact_id" value="{$CONTACT_ID}">
        <input type="hidden" name="user_id" value="{$USER_ID}">
        <input type="hidden" name="filename" value="{$FILENAME}">
        <input type="hidden" name="old_id" value="{$OLD_ID}">

{elseif $MODULE eq 'Contacts'}
	{$ERROR_MESSAGE}
        <form name="EditView" id="frmeditview" method="POST" ENCTYPE="multipart/form-data" action="index.php">
	<input type="hidden" name="activity_mode" value="{$ACTIVITY_MODE}">
	<input type="hidden" name="opportunity_id" value="{$OPPORTUNITY_ID}">
	<input type="hidden" name="contact_role">
	<input type="hidden" name="case_id" value="{$CASE_ID}">
	<input type="HIDDEN" name="MAX_FILE_SIZE" value="8000000">
	<input type="hidden" name="campaignid" value="{$campaignid}">
    <input type="hidden" name="potential_id" value="{$potential_id}">
{elseif $MODULE eq 'Potentials'}
	<form name="EditView" method="POST" ENCTYPE="multipart/form-data" action="index.php" >
	{*<!--edit:can date:20131028;reason:0005520:销售机会”，保存时，“联系人姓名”字段无法保存，并且页面左下角报错，如图。-->*}
    {*<!--<input type="hidden" name="contact_id" value="{$CONTACT_ID}">-->*}

{elseif $MODULE eq 'Campaigns'}
        <form name="EditView" id="frmeditview"  method="POST" ENCTYPE="multipart/form-data" action="index.php" >

{elseif $MODULE eq 'Calendar'}
	<input type="hidden" name="activity_mode" value="{$ACTIVITY_MODE}">
	<input type="hidden" name="product_id" value="{$PRODUCTID}">
    <input type="hidden" name="status_rmd" value="未读">    

{elseif $MODULE|@get_file_address:'ProductDetails' eq true || $MODULE == 'SalesBack' || $MODULE == 'PurchaseBack'|| $MODULE == 'CashBack' || $MODULE == 'PurchaseCashBack'||$MODULE eq 'Quotes'}
	<!-- (id="frmEditView") content added to form tag and new hidden field added,  -->
	<form id="frmEditView" name="EditView" ENCTYPE="multipart/form-data" method="POST" action="index.php">
	<input type="hidden" name="hidImagePath" id="hidImagePath" value="{$IMAGE_PATH}"/>
	{if $MODULE == 'PurchaseBack'}
	<input type="hidden" name="forback_purid" id="forback_purid" value="{$PURCHASEORDERID}" />
	 {/if}
	<!-- End of code added -->

	
 <input type="hidden" name="convertmode">
	

{elseif $MODULE eq 'HelpDesk'}
	<form name="EditView" method="POST" action="index.php" ENCTYPE="multipart/form-data">
	<input type="hidden" name="old_smownerid" value="{$OLDSMOWNERID}">
	<input type="hidden" name="old_id" value="{$OLD_ID}">


{elseif $MODULE eq 'Accounts' || $MODULE eq 'Faq' || $MODULE eq 'PriceBooks' || $MODULE eq 'Vendors'}
    {if $MODULE eq 'Accounts'}
	   <form name="EditView" method="POST" action="index.php" ENCTYPE="multipart/form-data" id="frmeditview">
       <input type="hidden" name="copypublicaccountid" value="{$CopyPublicAccountId}" /><!--yyx 2015-4-21 获取当前被复制客户的公海参数值-->
           {if $potential_id === null}
           {else}
               <input type="hidden" name="potential_id" value="{$potential_id}" /><!--Liver 2017-4-14 获取销售机会的id-->
           {/if}
		{if $quickcreate_publicaccount eq 'yes'}
			<input type="hidden" value="yes" name="quickcreate_publicaccount" />
		{/if}
       {else}
        <form name="EditView" method="POST" action="index.php" ENCTYPE="multipart/form-data"  >
    {/if}
    {if $MASSTYPE eq 'massedit'}
    <input  type="hidden" name="assign_name" value="{$SMOWNERIDS}" id="assign_name"/>
    {else}
    <input  type="hidden" name="assign_name" value="{$SEARCHSCOPE}" id="assign_name"/>
    {/if}
    {if $PUBLICACCOUNT>=0}
        <input type="hidden" name="publicaccount" value="{$PUBLICACCOUNT}"/>
    {/if}
{elseif $MODULE eq "Users"}
<form name="EditView" method="POST" action="index.php" ENCTYPE="multipart/form-data" >
    <input type="hidden" name="changepassword" />
    <input type="hidden" name="old_password" />
    <input type="hidden" name="new_password" />
	<input type="hidden" name="sms_account_name" value="{$SMS_ACCOUNT_NAME}" />
{elseif $MODULE eq 'Documents'}
	<form name="EditView" method="POST" ENCTYPE="multipart/form-data" action="index.php">
	<input type="hidden" name="max_file_size" value="{$MAX_FILE_SIZE}">
	<input type="hidden" name="form">
	<input type="hidden" name="email_id" value="{$EMAILID}">
	<input type="hidden" name="ticket_id" value="{$TICKETID}">
	<input type="hidden" name="fileid" value="{$FILEID}">
	<input type="hidden" name="old_id" value="{$OLD_ID}">
	<input type="hidden" name="parentid" value="{$PARENTID}">
	<input type="hidden" name="noteid" id="noteid" value="{$NOTEID}" />
{elseif $MODULE eq 'Attachment'}
	{$ERROR_MESSAGE}
    <form name="EditView" method="POST" ENCTYPE="multipart/form-data" action="index.php">
	<input type="hidden" value="{$PARENTID}" id="myatt_id" name="att_record" />
    <input type="hidden" value="{$PARENTMODULE}" id="myatt_moduel" name="myatt_moduel" />
    <input type="hidden" value="{$TYPE}" name="att_type" />
    <input type="hidden" value="{$PATH}" name="att_path" />
    <input type="hidden" value="{$USERID}" name="user_id" />
    <input type="hidden" value="{$SWID}" name="swid" />
    <!--用户详情页增加附件 zyh 20150420 PROT197   -->
{elseif $MODULE eq 'Products'}
	{$ERROR_MESSAGE}
	<form name="EditView" method="POST" ENCTYPE="multipart/form-data" action="index.php">
	<input type="hidden" name="activity_mode" value="{$ACTIVITY_MODE}">
	<input TYPE="hidden" name="MAX_FILE_SIZE" VALUE="80000000">
	<input type="hidden" name="product_id" value="{$PRODUCT_ID}" />
{elseif $MODULE eq 'Reminds'}
    <form name="EditView" method="POST" action="index.php">
    <input type="hidden" name="reltab" >
    <input type="hidden" name="status_rmd" value="未读">    
    <input type="hidden" name="assigned_user_id" value="{$CURRENT_USERID}">
    {elseif $MODULE eq 'Events'}
    <form name="EditView" method="POST" action="index.php">
{else}
	{$ERROR_MESSAGE}
 
	<form name="EditView" method="POST" action="index.php" ENCTYPE="multipart/form-data">
{/if}
{if $MODULE eq 'BankAccountSet'}
<input type="hidden" id="bankconfirmed" name="confirmed" value="">
{/if}
{if $MODULE eq 'Project' || $MODULE eq 'ServiceContracts' || $MODULE eq 'ProjectMilestone'}
    <input type="hidden" id="accountid" name="accountid" value="{$ACCOUNTID}">
{/if}

    <input type="hidden" id="deploy_205" name="deploy_205" value="{$DEPLOY_VALUE_205}">


{if $MODULE eq 'QuotesChange'}
<input type="hidden" id="change_type" name="change_type" value="{$CHANGE_TYPE}">
<input type="hidden" id="quote_id" name="quote_id" value="{$QUOTEID}">
{/if}
{if $MODULE eq 'BudgetChange'}
<input type="hidden" id="change_type" name="change_type" value="{$CHANGE_TYPE}">
<input type="hidden" id="customform14_id" name="customform14_id" value="{$CUSTOMFORM14ID}">
{/if}
<input type="hidden" name="pagenumber" value="{$smarty.request.start|@vtlib_purify}">
{if $MODULE eq 'Events'}
<input type="hidden" name="module" value="Calendar">
{else}
<input type="hidden" name="module" value="{$MODULE}">
{/if}
<input type="hidden" name="record" value="{$ID}">
<input type="hidden" name="mode" value="{$MODE}">
<input type="hidden" name="action">
<input type="hidden" name="parenttab" value="{$CATEGORY}">
<input type="hidden" name="return_module" value="{$RETURN_MODULE}">
<input type="hidden" name="return_id" value="{$RETURN_ID}">
<input type="hidden" name="return_action" value="{$RETURN_ACTION}">
<input type="hidden" name="return_viewname" value="{$RETURN_VIEWNAME}">
<input type="hidden" name="SearchScope" value="{$SEARCHSCOPE}">
<input type="hidden" name="createmode" value="{$CREATEMODE}" />
<input  type="hidden" name="upgradefrommodule" value="{$upgradefrommodule}"/>
<input type="hidden" name="upgradefromid" value="{$upgradefromid}" />
<input type="hidden" name="speciale_field" value="" />
{if $OP_MODE eq 'create_view'}
            <input type="hidden" name="createview" value="create_view" /> 
{/if}
{if $CREATE eq 'true'}
            <input type="hidden" name="Create" value="yes">
{/if}
{if $MODULE eq 'CashBill'||$MODULE eq 'SendCashBill'}
   <input type="hidden" name="convertmode">
{/if}

{if $MODULE eq 'Accounts' || $MODULE eq 'ServiceCharge'}
    <input  type="hidden" name="reference" value="1"/>
    <input  type="hidden" name="contactid" value="{$CONTACTID}"/>
    <input type="hidden" id="projectid" name="projectid" value="{$PROJECTID}" />
    {if $MODE neq 'edit'}
        <input type="hidden" id="publicaccount" name="publicaccount" value="{$PUBLICACCOUNT}" />
    {/if}
{/if}
{if $MODULE eq 'ServiceContracts' && $VERSION_ACCOUNT eq 'climaveneta'}
	<input  type="hidden" name="ordertype" value="{$ORDERTYPE}"/>
{/if}
{*收款单 佣金单  发票 选择源单-服务合同*}
{if $MODULE eq 'CashBill' || $MODULE eq 'Commission' || $MODULE eq 'Invoice'|| $MODULE eq 'Expense'|| $MODULE eq 'Project'}
    <input type="hidden" name="issourcemodule" id="issourcemodule" value="{$ISSOURCEMODULE}">
{/if}
<!--选择原单js函数使用-->
<input  type="hidden" name="listval" id="listval"/>
{if $MODULE eq 'PurchaseBack'}
    <input type="hidden" id="purchaseback_id" name="purchaseback_id" value="{$ID}">
{/if}
{if $MODULE eq 'PurchaseCashBack'}
    <input type="hidden" id="purchasecashback_id" name="purchasecashback_id" value="{$ID}">
{/if}
        {* editor:gyq_85 reason:汉天呼叫中心优化 单据创建增加销售机会*}
{if $MODULE eq 'Accounts' || $MODULE eq 'Contacts' || $MODULE eq 'HelpDesk' || $MODULE eq 'ContactRecords'
    || $MODULE eq 'Vendors' || $MODULE eq 'VendorContact' || $MODULE eq 'VendorContactRecords' ||$MODULE eq 'Potentials' }
    <input type="hidden" value="{$ENCRYPT_FILENAME}" name="callbutlername">
	<input type="hidden" value="{$CALLTYPE}" name="calltype">
    <input type="hidden" name="jiuweiaccount" value="{$JiuWeiAccount}" /><!--editor:gyq_11 reason:客户ID date:20160526-->
    <input type="hidden" name="callcenter_switch" value="{$CALLCENTERSWITCH}" /><!--editor:gyq_11 reason:客户ID date:20160526-->
    {*<input type="hidden" name="calltalkid" value="{$calltalkid}" />*}{*@edit:liushuai,2021-05-26,reason:【ID1001533】呼叫中心接口设置，增加接口类型“灵当语音盒”(弹屏关联创建时)*}
{/if}
<input type="hidden" name="version_account" id="version_account" value="{$VERSION_ACCOUNT}" />
<input type="hidden" name="version_trade" id="version_trade" value="{$VERSIONTRADE}" />
<input  type="hidden" name="delfileid" value=""/>
<!--图片-->
<input  type="hidden" name="imagedelfileid"/>
<!--附件管理模块-->
<input  type="hidden" name="attachmentdelfileid"/>
{if $VERSION_ACCOUNT eq 'climaveneta'}
<input type="hidden" name="haveInvenotryOrder" id="haveInvenotryOrder" value="{$haveInvenotryOrder}" />
{/if}
