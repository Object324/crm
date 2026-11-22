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
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
</head>
<script>
var image_pth = '{$IMAGE_PATH}';

function showAllRecords()
{ldelim}
        modname = document.getElementById("relmod").name;
        idname= document.getElementById("relrecord_id").name;
        var locate = location.href;
        url_arr = locate.split("?");
        emp_url = url_arr[1].split("&");
        for(i=0;i< emp_url.length;i++)
        {ldelim}
                if(emp_url[i] != '')
                {ldelim}
                        split_value = emp_url[i].split("=");
                        if(split_value[0] == modname || split_value[0] == idname )
                                emp_url[i]='';
                        else if(split_value[0] == "fromPotential" || split_value[0] == "acc_id")
                                emp_url[i]='';

                {rdelim}
        {rdelim}
        correctUrl =emp_url.join("&");
        Url = "index.php?"+correctUrl;
        return Url;
{rdelim}

//function added to get all the records when parent record doesn't relate with the selection module records while opening/loading popup.
function redirectWhenNoRelatedRecordsFound()
{ldelim}
        var loadUrl = showAllRecords();
        window.location.href = loadUrl;
{rdelim}
</script>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<link rel="stylesheet" type="text/css" href="{$THEME_PATH}style.css">
<link rel="stylesheet" type="text/css" href="{$THEME_PATH}global.css">
<link rel="stylesheet" type="text/css" href="{$THEME_PATH}liststyle.css">
<style type="text/css">@import url("themes/{$THEME}/popup.css");</style>
<!-- <script type="text/javascript" src="include/jquery/jquery-3.5.1.min.js"></script> -->
<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript" language="JavaScript">
	var ld = $;
</script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/Inventory.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/json.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/{$LANGUAGETYPE}.js"></script>

<!-- vtlib customization: Javascript hook -->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/vtlib.js"></script>

<script language="JavaScript" type="text/javascript" src="{$JSRUL}modules/{$MODULE}/{$MODULE}.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/MassSMS.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSRUL}include/js/QuickCreate.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSRUL}include/js/EditView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSRUL}include/js/popup.js"></script>
<script type='text/javascript'>
	jQuery.noConflict();
</script>
<script type="text/javascript">
{literal}
function add_data_to_relatedlist(entity_id,recordid,mod, popupmode, callback) {
	var return_module = document.getElementById('return_module').value;
	if(popupmode == 'ajax') {
        puyoungJS_DialogBox.block();
		new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
             method: 'post',
             postBody: "module="+return_module+"&action="+return_module+"Ajax&file=updateRelations&destination_module="+mod+"&entityid="+entity_id+"&parentid="+recordid+"&mode=Ajax",
             onComplete: function(response) {
                 puyoungJS_DialogBox.unblock();
					var res = JSON.parse(response.responseText);
					if(typeof callback == 'function') {
						callback(res);
					}
                }
			}
		);
		return false;
	} else {
		{/literal}
           
        opener.document.location.href="index.php?module={$RETURN_MODULE}&action=updateRelations&destination_module="+mod+"&entityid="+entity_id+"&parentid="+recordid+"&return_module={$RETURN_MODULE}&return_action={$RETURN_ACTION}&parenttab={$CATEGORY}";
		window.close();
		{literal}
	}
}
{/literal}
function set_focus() {ldelim}
	$('search_txt').focus();
{rdelim}
</script>
<body  onload=set_focus() class="small" marginwidth=0 marginheight=0 leftmargin=0 topmargin=0 bottommargin=0 rightmargin=0>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="mailClient mailClientBg">
	<tr>
		<td>
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td class="moduleName" width="80%" >{'SOURCEMODULE'|@getTranstab}-{$MODULE|@getTranstab}</td>
				</tr>
			</table>
			<div id="status" style="position:absolute;display:none;right:135px;top:15px;height:27px;white-space:nowrap;"><img src="{'status.gif'|@lingdang_imageurl:$THEME}"></div>
			<table  align="center" width="99%" cellpadding="0" cellspacing="0" border="0"  class="homePageMatrixHdr">
				<tr>
					<td style="padding-top:10px;" >
						<form name="basicSearch" action="index.php">
                            <input type="hidden" name="searchtype" value="BasicSearch">
                            <input type="hidden" id="returnmodule" value="{$RETURNMODULE}" />
                            <input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}" />
							<input type="hidden" name="module" value="{$MODULE}">
							<input type="hidden" name="action" id="action" value="{$ACTION}">
							<input type="hidden" name="query" value="true">
							<input type="hidden" name="select_enable" id="select_enable" value="{$SELECT}">
							<input type="hidden" name="curr_row" id="curr_row" value="{$CURR_ROW}">
							<input type="hidden" name="fldname_pb" value="{$FIELDNAME}">
							<input type="hidden" name="productid_pb" value="{$PRODUCTID}">
							<input name="popuptype" id="popup_type" type="hidden" value="{$POPUPTYPE}">
							<input name="recordid" id="recordid" type="hidden" value="{$RECORDID}">
							<input name="record_id" id="record_id" type="hidden" value="{$RECORD_ID}">
							<input name="return_module" id="return_module" type="hidden" value="{$RETURN_MODULE}">
							<input name="from_link" id="from_link" type="hidden" value="{$smarty.request.fromlink.value|@vtlib_purify}">
							<input name="maintab" id="maintab" type="hidden" value="{$MAINTAB}">
							<input type="hidden" id="relmod" name="{$mod_var_name}" value="{$mod_var_value}">
                            <input type="hidden" id="relrecord_id" name="{$recid_var_name}" value="{$recid_var_value}">
							<input name="form"  id="popupform" type="hidden" value="{$smarty.request.form|@vtlib_purify}">
							<input  name="warehouse" id="warehouse" type="hidden" value="{$WAREHOUSEID}"/>
							 <input type="hidden" id="viewname" name="viewname" value="{$VIEWID}"/>
                             <input type="hidden" name="publicaccounttype" value="{$ACCOUNTTYPE}" />
                             <input  id="popupselect" type="hidden" value="{$SELECT}"/>
                             <input type="hidden" value="{$ACCOUNTID}" id="account_id"  name="account_id"/>
                             <input  type="hidden" value="{$VENDORID}" id="vendor_id" name="vendor_id"/>
                             <input type="hidden" name="ReportHeader" value="dheader"/>
							 <input type="hidden" name="accountid" value="{$ACCOUNTID}"/>
							 <input type="hidden" value="{$LISTALL}" id="listall" name="listall"/>
							{if $smarty.request.currencyid neq ''}
								<input type="hidden" name="curr_row" id="currencyid" value="{$smarty.request.currencyid|@vtlib_purify}">
							{/if}
                                
                        <table  align="center" width="100%"  cellpadding="5" cellspacing="0" style="background:#F4F4F4;">
						<tr  class="basicsearchfield">
							<td>
                                <div class="DivSearch">
                                <ul>
                                    <!-- <li class="searctype">{'SEARCH'|@getFixedLabel}</li> -->
                                    <li>{'Find_field'|@getFixedLabel}</li>
                                    <li id="basicsearchcolumns_real">
                                        {if $MODULE == 'SalesOrder'}
                                            <select style="width:120px" name="search_field">
                                                <option value="ld_salesorder.salesorderid" label="{$MODULE|@getTranstab}" {if $SEARCHFIELD eq 'ld_salesorder.salesorderid'} selected {/if}>{$MODULE|@getTranstab}</option>
                                                <option value="ld_salesorder.total" {if $SEARCHFIELD eq 'ld_salesorder.total'} selected {/if} label="{'SALESORDERCONTRACTAMOUNT'|@getFixedLabel}">{'SALESORDERCONTRACTAMOUNT'|@getFixedLabel}</option>
                                                {if $FROMMODULE neq 'Invoice'}
                                                <option value="ld_paymentplan.paymentplan_no" {if $SEARCHFIELD eq 'ld_paymentplan.paymentplan_no'} selected {/if} label="{'Numberofpaymentplans'|@getFixedLabel}">{'Numberofpaymentplans'|@getFixedLabel}</option>
                                                <option value="ld_paymentplan.plandate" {if $SEARCHFIELD eq 'ld_paymentplan.plandate'} selected {/if} label="{'Planstoreturntothedatefunds'|@getFixedLabel}">{'Planstoreturntothedatefunds'|@getFixedLabel}</option>
                                                <option value="ld_paymentplan.amount" {if $SEARCHFIELD eq 'ld_paymentplan.amount'} selected {/if} label="{'RECEIVABLE'|@getFixedLabel}{'AMOUNT'|@getFixedLabel}">{'RECEIVABLE'|@getFixedLabel}{'AMOUNT'|@getFixedLabel}</option>
                                                <option value="ld_paymentplan.periodtime" {if $SEARCHFIELD eq 'ld_paymentplan.periodtime'} selected {/if} label="{'Stages'|@getFixedLabel}">{'Stages'|@getFixedLabel}</option>
                                                <option value="invoice.invoicedate" {if $SEARCHFIELD eq 'invoice.invoicedate'} selected {/if} label="{'THENEWINVOICEDATE'|@getFixedLabel}">{'THENEWINVOICEDATE'|@getFixedLabel}</option>                                                
                                                <option value="invoice.invoice_no" {if $SEARCHFIELD eq 'invoice.invoice_no'} selected {/if} label="{'Invoice'|@getTranstab}{'Number'|@getFixedLabel}">{'Invoice'|@getTranstab}{'Number'|@getFixedLabel}</option>
                                                {/if}
                                                <option value="ld_account.accountname" {if $SEARCHFIELD eq 'ld_account.accountname'} selected {/if} label="{'Customer'|@getFixedLabel}">{'Customer'|@getFixedLabel}</option>
                                               {if $ACTIVESENDPAYMENTPLAN eq 'true'}
                                                <option value="ld_paymentplan.periodtime" {if $SEARCHFIELD eq 'ld_paymentplan.periodtime'} selected {/if} label="{'Stages'|@getFixedLabel}">{'Stages'|@getFixedLabel}</option>
                                               {/if}
                                            </select>
                                        {elseif $MODULE == 'PurchaseOrder'}
                                            <select style="width:120px" name="search_field">
                                                <option value="ld_purchaseorder.purchaseorderid" label="{$MODULE|@getTranstab}" {if $SEARCHFIELD eq 'ld_purchaseorder.purchaseorderid'} selected {/if}>{$MODULE|@getTranstab}</option>
                                                <option value="ld_purchaseorder.total" {if $SEARCHFIELD eq 'ld_purchaseorder.total'} selected {/if} label="{'PURCHASEAMOUNT'|@getFixedLabel}">{'PURCHASEAMOUNT'|@getFixedLabel}</option>
                                                <option value="ld_sendpayment.Sendpayment_no" {if $SEARCHFIELD eq 'ld_sendpayment.Sendpayment_no'} selected {/if} label="{'PAYMENTPLANNUMBER'|@getFixedLabel}">{'PAYMENTPLANNUMBER'|@getFixedLabel}</option>
                                                <option value="ld_sendpayment.Plandate" {if $SEARCHFIELD eq 'ld_sendpayment.Plandate'} selected {/if} label="{'PAYMENTPLADATE'|@getFixedLabel}">{'PAYMENTPLADATE'|@getFixedLabel}</option>
                                                <option value="ld_sendpayment.Amount" {if $SEARCHFIELD eq 'ld_sendpayment.Amount'} selected {/if} label="{'RECEIVABLE'|@getFixedLabel}{'AMOUNT'|@getFixedLabel}">{'RECEIVABLE'|@getFixedLabel}{'AMOUNT'|@getFixedLabel}</option>
												<option value="ld_sendpayment.cpperiodtime" {if $SEARCHFIELD eq 'ld_sendpayment.cpperiodtime'} selected {/if} label="{'Stages'|@getFixedLabel}">{'Stages'|@getFixedLabel}</option>
                                            </select>
                                        {elseif $MODULE == 'ServiceContracts'}
                                            <select class="txtBox" style="width:120px" name="search_field">
                                                <option value="ld_servicecontracts.{$FIELDNAME}" label="{$MODULE|@getTranstab}" {if $SEARCHFIELD eq "ld_servicecontracts.$FIELDNAME"} selected {/if}>{$MODULE|@getTranstab}</option>
                                                <option value="ld_servicecontracts.due_date" {if $SEARCHFIELD eq 'ld_servicecontracts.due_date'} selected {/if} label="{'DATEOFCONTRACT'|@getFixedLabel}">{'DATEOFCONTRACT'|@getFixedLabel}</option>
                                                <option value="ld_servicecontracts.contract_type" {if $SEARCHFIELD eq 'ld_servicecontracts.contract_type'} selected {/if} label="{'SERVICECONTRACTSTYPE'|@getFixedLabel}">{'SERVICECONTRACTSTYPE'|@getFixedLabel}</option>
                                                <option value="ld_servicecontracts.total" {if $SEARCHFIELD eq 'ld_servicecontracts.total'} selected {/if} label="{'SALESORDERCONTRACTAMOUNT'|@getFixedLabel}">{'SALESORDERCONTRACTAMOUNT'|@getFixedLabel}</option>
                                                <option value="temp.invoicedate" {if $SEARCHFIELD eq 'temp.invoicedate'} selected {/if} label="{'THENEWINVOICEDATE'|@getFixedLabel}">{'THENEWINVOICEDATE'|@getFixedLabel}</option>
                                                <option value="ld_paymentplan.periodtime" {if $SEARCHFIELD eq 'ld_paymentplan.periodtime'} selected {/if} label="{'Stages'|@getFixedLabel}">{'Stages'|@getFixedLabel}</option>
                                                {if $FROMMODULE neq 'Invoice'}
                                                <option value="temp.invoice_num" {if $SEARCHFIELD eq 'temp.invoice_num'} selected {/if} label="{'INVOICENO'|@getFixedLabel}">{'INVOICENO'|@getFixedLabel}</option>
                                                {/if}
                                                <option value="ld_account.accountname" {if $SEARCHFIELD eq 'ld_account.accountname'} selected {/if} label="{'Customer'|@getFixedLabel}">{'Customer'|@getFixedLabel}</option>
                                            </select>
                                        {/if}
                                    
                                    </li>
                                    <li>
                                        {'Find_Keyword'|@getFixedLabel}
                                        <input type="text" name="search_text" id="search_txt" style="width:120px" value="{$SEARCHTXT}"  onkeypress="return popupJs.keypress(event,document.getElementById('btnsearch'))" />
                                    </li>
                                    <li><input type="submit" name="search" id="btnsearch" value="{'FINDNOW'|@getFixedLabel}" class="createauto"/></li>
                                </ul>
                                    
                                </div>
                            </td>
						</tr>
						 <tr {if $ALPHABETICAL eq ''} style="display:none;"{/if}>
							<td style="padding-top:5px;" colspan="4" align="center">
								<table width="100%" class="small">
								<tr>	
									{$ALPHABETICAL}
								</tr>
								</table>
							</td>
						</tr>
						</table>
						</form>
					</td>
				</tr>
				{if $recid_var_value neq '' && $MODULE!='Contacts'}
                    <tr>
                        <td align="right"><input id="all_contacts" alt="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab}" title="{'SELECT'|@getFixedLabel} {$MODULE|@getTranstab}" class="edit autoWidth marR8" value="{'DISPLAYALL'|@getFixedLabel}{$MODULE|@getTranstab}" LANGUAGE=javascript onClick="window.location.href=showAllRecords();" type="button"  name="button"></td>
                    </tr>
                {/if}
			</table>
            
            <div id="qcform"></div>
			<div id="ListViewContents">
                {include file="CashPopupContents.tpl"}
			</div>
		</td>
	</tr>
	
</table>

</body>
<script>
var gPopupAlphaSearchUrl = '';
var gsorder ='';
var gstart ='';
function callSearch(searchtype)
{ldelim}
    gstart='';
    for(i=1;i<=26;i++)
    {ldelim}
        var data_td_id = 'alpha_'+ eval(i);
        getObj(data_td_id).className = 'searchAlph';
    {rdelim}
    gPopupAlphaSearchUrl = '';
    search_fld_val= document.basicSearch.search_field[document.basicSearch.search_field.selectedIndex].value;
    search_txt_val= encodeURIComponent(document.basicSearch.search_text.value.replace(/\'/,"\\'"));
    var urlstring = '';
    if(searchtype == 'Basic')
    {ldelim}
	urlstring = 'search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val;
    {rdelim}
	popuptype = $('popup_type').value;
	act_tab = $('maintab').value;
	urlstring += '&popuptype='+popuptype;
	urlstring += '&maintab='+act_tab;
	urlstring = urlstring +'&query=true&file={$ACTION}&module={$MODULE}&action={$MODULE}Ajax&ajax=true&search=true&frommodule='+frommodule+'';
	urlstring +=gethiddenelements();
	record_id = document.basicSearch.record_id.value;
  if(document.getElementById('account_id')!=undefined && document.getElementById('account_id').value!='')
    {ldelim}
        urlstring+='&accountid='+document.getElementById('account_id').value;
    {rdelim}
    if(document.getElementById('vendor_id')!=undefined&&document.getElementById('vendor_id').value!='')
    {ldelim}
        urlstring+='&vendorid='+document.getElementById('vendor_id').value;
    {rdelim}
    urlstring+="&SearchScope=SmOwner_Search_All&viewname="+document.getElementById("viewname").value;
	urlstring += "&popupmode={$POPUPMODE}";
	urlstring += "&callback={$CALLBACK}";
     if(document.getElementById('warehouse')!=undefined&&document.getElementById('warehouse').value>0)
     {ldelim}
        urlstring+='&wareid='+document.getElementById('warehouse').value;
        
    {rdelim}
	if(record_id!='')
		urlstring += '&record_id='+record_id;
	$("status").style.display="inline";
	new Ajax.Request(
		'index.php',
		{ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
				method: 'post',
				postBody: urlstring,
				onComplete: function(response) {ldelim}
					$("status").style.display="none";
					$("ListViewContents").innerHTML= response.responseText;
				{rdelim}
			{rdelim}
		);
{rdelim}	
function alphabetic(module,url,dataid)
{ldelim}
    gstart='';
    document.basicSearch.search_text.value = '';	
    for(i=1;i<=26;i++)
    {ldelim}
	var data_td_id = 'alpha_'+ eval(i);
	getObj(data_td_id).className = 'searchAlph';
    {rdelim}
    getObj(dataid).className = 'searchAlphselected';
    gPopupAlphaSearchUrl = '&'+url;	
    var urlstring ="module="+module+"&action="+module+"Ajax&file=Popup&ajax=true&search=true&"+url;
    urlstring +=gethiddenelements();
	record_id = document.basicSearch.record_id.value;
	if(record_id!='')
		urlstring += '&record_id='+record_id;
    if(document.getElementById('warehouse')!=undefined&&document.getElementById('warehouse').value>0)
    {ldelim}
        urlstring+='&wareid='+document.getElementById('warehouse').value;
    {rdelim}
    if(document.getElementById('frommodule') != undefined)
    {ldelim}
        if((module == 'PurchaseOrder' || module == 'SalesOrder') && document.getElementById('frommodule').value != '')
        {ldelim}
            urlstring += '&frommodule='+document.getElementById('frommodule').value;
        {rdelim}
    {rdelim}
    if(document.getElementById('account_id')!=undefined && document.getElementById('account_id').value!='')
    {ldelim}
        urlstring+='&accountid='+document.getElementById('account_id').value;
    {rdelim}
    if(document.getElementById('vendor_id')!=undefined&&document.getElementById('vendor_id').value!='')
    {ldelim}
        urlstring+='&vendorid='+document.getElementById('vendor_id').value;
    {rdelim}
    urlstring+="&SearchScope=SmOwner_Search_All&viewname="+document.getElementById("viewname").value;
    $("status").style.display="inline";
    //alert(urlstring);
    new Ajax.Request(
                'index.php',
                {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                                method: 'post',
                                postBody: urlstring,
                                onComplete: function(response) {ldelim}
                                	$("status").style.display="none";
                                   // alert(response.responseText);
									$("ListViewContents").innerHTML= response.responseText;
				{rdelim}
			{rdelim}
		);
{rdelim}
function gethiddenelements()
{ldelim}
	gstart='';
	var urlstring=''	
	if(getObj('select_enable').value != '')
		urlstring +='&select=enable';	
	if(document.getElementById('curr_row').value != '')
		urlstring +='&curr_row='+document.getElementById('curr_row').value;	
	if(getObj('fldname_pb').value != '')
		urlstring +='&fldname='+getObj('fldname_pb').value;	
	if(getObj('productid_pb').value != '')
		urlstring +='&productid='+getObj('productid_pb').value;	
	if(getObj('recordid').value != '')
		urlstring +='&recordid='+getObj('recordid').value;
	if(getObj('relmod').value != '')
                urlstring +='&'+getObj('relmod').name+'='+getObj('relmod').value;
    if(getObj('relrecord_id').value != '')
            urlstring +='&'+getObj('relrecord_id').name+'='+getObj('relrecord_id').value;
	
	// vtlib customization: For uitype 10 popup during paging
	if(document.getElementById('popupform'))
		urlstring +='&form='+encodeURIComponent(getObj('popupform').value);
	if(document.getElementById('forfield'))
		urlstring +='&forfield='+encodeURIComponent(getObj('forfield').value);
	if(document.getElementById('srcmodule'))
		urlstring +='&srcmodule='+encodeURIComponent(getObj('srcmodule').value);
	if(document.getElementById('forrecord'))
		urlstring +='&forrecord='+encodeURIComponent(getObj('forrecord').value);
	// END
		
	if(document.getElementById('currencyid') != null && document.getElementById('currencyid').value != '')
		urlstring +='&currencyid='+document.getElementById('currencyid').value;

	var return_module = document.getElementById('return_module').value;
	if(return_module != '')
		urlstring += '&return_module='+return_module;
	return urlstring;
{rdelim}
																									
function getListViewEntries_js(module,url)
{ldelim}
    var frommodule='';
 
    if(document.getElementById('popupfrommodule')!=undefined)
    {ldelim}
        frommodule=document.getElementById('popupfrommodule').value;
    {rdelim}
	gstart="&"+url;
 
	popuptype = document.getElementById('popup_type').value;
        var urlstring ="module="+module+"&action="+module+"Ajax&file={$ACTION}&ajax=true&"+url;
    	urlstring +=gethiddenelements();
	
	{if !$RECORD_ID}
		search_fld_val= document.basicSearch.search_field[document.basicSearch.search_field.selectedIndex].value;
		search_txt_val=document.basicSearch.search_text.value;
		if(search_txt_val != '')
			urlstring += '&query=true&search_field='+search_fld_val+'&searchtype=BasicSearch&search_text='+search_txt_val;
	{/if}
	if(gPopupAlphaSearchUrl != '')
		urlstring += gPopupAlphaSearchUrl;	
	else
		urlstring += '&popuptype='+popuptype;	
	
	record_id = document.basicSearch.record_id.value;
	if(record_id!='')
		urlstring += '&record_id='+record_id;

	urlstring += (gsorder !='') ? gsorder : '';
	var return_module = document.getElementById('return_module').value;
	if(module == 'Documents' && return_module == 'MailManager')
	{ldelim}
		urlstring += '&callback=MailManager.add_data_to_relatedlist';
		urlstring += '&popupmode=ajax';
		urlstring += '&srcmodule=MailManager';
	{rdelim}
    if(frommodule!='')
   {ldelim}
         urlstring=urlstring+'&frommodule='+frommodule;
        
    {rdelim}
    if(document.getElementById('account_id')!=undefined && document.getElementById('account_id').value!='')
    {ldelim}
        urlstring+='&accountid='+document.getElementById('account_id').value;
    {rdelim}
    if(document.getElementById('vendor_id')!=undefined&&document.getElementById('vendor_id').value!='')
    {ldelim}
        urlstring+='&vendorid='+document.getElementById('vendor_id').value;
    {rdelim}
   if(document.forms['basicSearch']!=undefined&&document.forms['basicSearch'].listall!=undefined&&document.forms['basicSearch'].listall.value!='')
    {ldelim}
        //edit:can //14146: 如收款单-选择源单：在第一页选择一条合同订单，然后再次点击选择按钮，翻页后，再选择一条合同订单，结果第一条合同订单被替换;
        var listval=document.forms['basicSearch'].listall.value;
        var listvals=document.forms['basicSearch'].listall.value.split(',');
        if(listvals.length>0)
        {ldelim}
            listval=listvals[0];
            urlstring+='&listval='+listval;
        {rdelim}
        
     {rdelim}
    urlstring+="&SearchScope=SmOwner_Search_All&viewname="+document.getElementById("viewname").value;
    urlstring+='&'
	$("status").style.display = "";
	new Ajax.Request(
                'index.php',
                {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                                method: 'post',
                                postBody: urlstring,
                                onComplete: function(response) {ldelim}
                                        $("ListViewContents").innerHTML= response.responseText;
									$("status").style.display = "none";
				{rdelim}
			{rdelim}
		);
{rdelim}

function getListViewSorted_js(module,url)
{ldelim}
	gsorder=url;
        var urlstring ="module="+module+"&action="+module+"Ajax&file=Popup&ajax=true"+url;
	record_id = document.basicSearch.record_id.value;
	if(record_id!='')
		urlstring += '&record_id='+record_id;
	urlstring += (gstart !='') ? gstart : '';
	$("status").style.display = "";
	new Ajax.Request(
                'index.php',
                {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                                method: 'post',
                                postBody: urlstring,
                                onComplete: function(response) {ldelim}
                                        $("ListViewContents").innerHTML= response.responseText;
									$("status").style.display = "none";
				{rdelim}
			{rdelim}
		);
{rdelim}

var product_labelarr = {ldelim}
	CLEAR_COMMENT:'{$APP.LBL_CLEAR_COMMENT}',
	DISCOUNT:'{$APP.LBL_DISCOUNT}',
	TOTAL_AFTER_DISCOUNT:'{$APP.LBL_TOTAL_AFTER_DISCOUNT}',
	TAX:'{$APP.LBL_TAX}',
	ZERO_DISCOUNT:'{$APP.LBL_ZERO_DISCOUNT}',
	PERCENT_OF_PRICE:'{$APP.LBL_OF_PRICE}',
	DIRECT_PRICE_REDUCTION:'{$APP.LBL_DIRECT_PRICE_REDUCTION}'
{rdelim};

</script>