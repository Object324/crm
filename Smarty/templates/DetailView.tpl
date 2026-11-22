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
{*<!--edit:kevin date:2013-10-28 reason:5335-->*}

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js?v={$GLOBALMINVERSION}"></script>
<link rel="stylesheet" type="text/css" media="all" href="{$CSSURL}themes/softed/Paymentplan.css?v={$GLOBALMINVERSION}">
<script type='text/javascript' src='{$JSURL}include/js/user_approveby.js?v={$GLOBALMINVERSION}'></script>
<script type='text/javascript' src='{$JSURL}include/js/Mail.js?v={$GLOBALMINVERSION}'></script>
<script type="text/javascript" src="modules/ModTracker/ModTrackerCommon.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="modules/ModComments/ModCommentsCommon.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/reflection.js?v={$GLOBALMINVERSION}"></script>
<script src="{$CRMCOMMONURL}/crmcommon/js/scriptaculous/scriptaculous.js?v={$GLOBALMINVERSION}" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/dtlviewajax.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js?v={$GLOBALMINVERSION}"></script>
<span id="crmspanid" name="crmspanid" class="ld-detail-edit-small" style="display:none;" onmouseover="New_show('crmspanid');">
	<i class="ld-fonticon ld-fonticon-edit" title="{'EDIT'|@getFixedLabel}"></i>
</span>

<div id="convertleaddiv" style="display:block;position:absolute;left:225px;top:150px;"></div>
<script>
var gVTModule = '{$smarty.request.module|@vtlib_purify}';
var  hiddenlabel="{'HIDDEN'|@getFixedLabel}";
var showLabel="{'DISPLAY'|@getFixedLabel}";
{literal}
function callConvertLeadDiv(id)
{
        new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'module=Leads&action=LeadsAjax&file=ConvertLead&record='+id,
                        onComplete: function(response) {
                                $("convertleaddiv").innerHTML=response.responseText;
				eval($("conv_leadcal").innerHTML);
                        }
                }
        );
}
function showHideStatus(sId,anchorImgId,sImagePath)
{
	oObj = eval(document.getElementById(sId));
	if(oObj.style.display == 'block')
	{
		oObj.style.display = 'none';
		if(anchorImgId !=null){
			eval(document.getElementById(anchorImgId)).src =  'icon-homeimg icon-inactivate';
			eval(document.getElementById(anchorImgId)).alt = showLabel;
			eval(document.getElementById(anchorImgId)).title = showLabel;
		}
	}
	else
	{
		oObj.style.display = 'block';
		if(anchorImgId !=null){
			eval(document.getElementById(anchorImgId)).src = 'icon-homeimg icon-activate';
			eval(document.getElementById(anchorImgId)).alt = hiddenlabel;
			eval(document.getElementById(anchorImgId)).title = hiddenlabel;
		}
	}
}
<!-- End Of Code modified by SAKTI on 10th Apr, 2008 -->

<!-- Start of code added by SAKTI on 16th Jun, 2008 -->
function setCoOrdinate(elemId){
	oBtnObj = document.getElementById(elemId);
	var tagName = document.getElementById('lstRecordLayout');
	leftpos  = 0;
	toppos = 0;
	aTag = oBtnObj;
	do{
	  leftpos  += aTag.offsetLeft;
	  toppos += aTag.offsetTop;
	} while(aTag = aTag.offsetParent);

	tagName.style.top= toppos + 20 + 'px';
	tagName.style.left= leftpos - 276 + 'px';
}

function getListOfRecords(obj, sModule, iId,sParentTab)
{
		new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: 'module=Users&action=getListOfRecords&ajax=true&CurModule='+sModule+'&CurRecordId='+iId+'&CurParentTab='+sParentTab,
			onComplete: function(response) {
				sResponse = response.responseText;
				$("lstRecordLayout").innerHTML = sResponse;
                
				Lay = 'lstRecordLayout';
                fnvshobj(obj,'lstRecordLayout');
			}
		}
	);
}
{/literal}
function tagvalidate()
{ldelim}
	if(trim(document.getElementById('txtbox_tagfields').value) != '')
		SaveTag('txtbox_tagfields','{$ID}','{$MODULE}');
	else
	{ldelim}
		var confirm_str = "{$APP.PLEASE_ENTER_TAG}";
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	{rdelim}
{rdelim}
function DeleteTag(id,recordid)
{ldelim}
	$("vtbusy_info").style.display="inline";
	Effect.Fade('tag_'+id);
	new Ajax.Request(
		'index.php',
                {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                        method: 'post',
                        postBody: "file=TagCloud&module={$MODULE}&action={$MODULE}Ajax&ajxaction=DELETETAG&recordid="+recordid+"&tagid=" +id,
                        onComplete: function(response) {ldelim}
						getTagCloud();
						$("vtbusy_info").style.display="none";
                        {rdelim}
                {rdelim}
        );
{rdelim}

//Added to send a file, in Documents module, as an attachment in an email
function sendfile_email()
{ldelim}
	filename = $('dldfilename').value;
	document.DetailView.submit();
	OpenCompose(filename,'Documents');
{rdelim}

</script>
<!--{if $MODULE eq 'Leads' or $MODULE eq 'Contacts' or $MODULE eq 'Accounts' or $MODULE eq 'Campaigns' or $MODULE eq 'Vendors'}
	<form name="SendMail" style="float:left;"><div id="sendmail_cont" style="z-Index:9999999999999;position:absolute;"></div></form>
{/if}-->

<div id="lstRecordLayout" class="LdPop_box LdPopWidth300px" style="display:none;"></div>

<div id="divAccountShare" class="LdPop_box LdPopWidth500px" style="display:none;width:500px;position:absolute;z-index: 2147483647;"></div>
<div id="divPotentialsShare" class="LdPop_box LdPopWidth500px" style="display:none;width:500px;position:absolute;z-index: 2147483647;"></div>
{assign var=date_format value='(yyyy-mm-dd)'}
{if $MODULE eq 'Accounts' || $MODULE eq 'Contacts' || $MODULE eq 'Leads'}
	{if $MODULE eq 'Accounts'}
		{assign var=address1 value='$MOD.LBL_BILLING_ADDRESS'}
		{assign var=address2 value='$MOD.LBL_SHIPPING_ADDRESS'}
	{/if}
	{if $MODULE eq 'Contacts'}
		{assign var=address1 value='$MOD.LBL_PRIMARY_ADDRESS'}
		{assign var=address2 value='$MOD.LBL_ALTERNATE_ADDRESS'}
	{/if}
	<div id="locateMap" onMouseOut="fninvshnew('locateMap')" onMouseOver="fnvshNrm('locateMap')">
		<table bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<td>
					{if $MODULE eq 'Accounts'}
						<a href="javascript:;" onClick="fninvshnew('locateMap'); searchMapLocation( 'Main' );" class="calMnu">{$MOD.LBL_BILLING_ADDRESS}</a>
						<a href="javascript:;" onClick="fninvshnew('locateMap'); searchMapLocation( 'Other' );" class="calMnu">{$MOD.LBL_SHIPPING_ADDRESS}</a>
					{/if}

					{if $MODULE eq 'Contacts'}
						<a href="javascript:;" onClick="fninvshnew('locateMap'); searchMapLocation( 'Main' );" class="calMnu">{$MOD.LBL_PRIMARY_ADDRESS}</a>
						<a href="javascript:;" onClick="fninvshnew('locateMap'); searchMapLocation( 'Other' );" class="calMnu">{$MOD.LBL_ALTERNATE_ADDRESS}</a>
					{/if}

				</td>
			</tr>
		</table>
	</div>
{/if}


<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td>        
			{*{include file='Buttons_List1.tpl'}*}           
			<!-- Contents -->
			<table border=0 cellspacing=0 cellpadding=0 width=98% align=center>
				<tr>                
					<td valign=top><img src="{'showPanelTopLeft.gif'|@lingdang_imageurl:$THEME}"></td>
					<td class="showPanelBg" valign=top width=100%>
						<!-- PUBLIC CONTENTS STARTS-->
						<div class="small" style="padding:10px" >
                            {if $MODULE eq 'Attachment'}
                                                
                            {else}
							<table align="center" border="0" cellpadding="0" cellspacing="0" width="95%">
								<tr><td>
										{* Module Record numbering, used MOD_SEQ_ID instead of ID *}
										{assign var="USE_ID_VALUE" value=$MOD_SEQ_ID}
									{if $USE_ID_VALUE eq ''} {assign var="USE_ID_VALUE" value=$ID} {/if}
									<span class="font14 fontbold">
                                    [ {$USE_ID_VALUE} ] {$NAME} -  {$MODULE|@getTranstab} {'INFORMATION'|@getFixedLabel}
                                    </span>&nbsp;&nbsp;&nbsp;
                                    <span class="small">{$UPDATEINFO}
                                    </span>&nbsp;
                                    <span id="vtbusy_info" style="display:none;" valign="bottom">
                                    <img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0">
                                    </span>
                                    <span id="vtbusy_info" style="visibility:hidden;" valign="bottom">
                                    <img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0">
                                    </span>
								</td></tr>
						    </table>
                            {/if}
						<br>
                        <!-- Account details tabs -->
						<table border=0 cellspacing=0 cellpadding=0 width=95% align=center>
							<tr>
								<td>
									<table border=0 cellspacing=0 cellpadding=3 width=100% class="small">
										<tr>
											<td class="dvtTabCache" style="width:10px" nowrap>&nbsp;</td>
											<td class="dvtSelectedCellCommon dvtSelectedCell" align=center nowrap>{$MODULE|@getTranstab} {'INFORMATION'|@getFixedLabel}</td>
											<td class="dvtTabCache" style="width:10px">&nbsp;</td>
											{if $SinglePane_View eq 'false' && $IS_REL_LIST neq false && $IS_REL_LIST|@count > 0}
												<td class="dvtUnSelectedCell" onmouseout="fnHideDrop('More_Information_Modules_List');" onmouseover="fnDropDown(this,'More_Information_Modules_List');" align="center" nowrap>
													<a href="index.php?action=CallRelatedList&module={$MODULE}&record={$ID}&parenttab={$CATEGORY}">{'MORE'|@getFixedLabel} {'INFORMATION'|@getFixedLabel}</a>
                                                    <div onmouseover="fnShowDrop('More_Information_Modules_List')" onmouseout="fnHideDrop('More_Information_Modules_List')"
														 id="More_Information_Modules_List" class="drop_mnu" style="left: 502px; top: 76px; display: none;">
														<table border="0" cellpadding="0" cellspacing="0" width="100%">
															{foreach key=_RELATION_ID item=_RELATED_MODULE from=$IS_REL_LIST}
																<tr><td><a class="drop_down" href="index.php?action=CallRelatedList&module={$MODULE}&record={$ID}&parenttab={$CATEGORY}&selected_header={$_RELATED_MODULE}&relation_id={$_RELATION_ID}">{$_RELATED_MODULE|@getTranslatedString:$MODULE}</a></td></tr>
															{/foreach}
														</table>
													</div>
												</td>
											{/if}
											<td class="dvtTabCache" align="right" style="width:100%">
                                            <div class="rightbuttonimg">
												{if $privrecord neq ''}
                                                  	<img align="absmiddle" title="{'PREVDATA'|@getFixedLabel}" onclick="location.href='index.php?module={$MODULE}&viewtype={$VIEWTYPE}&action=DetailView&record={$privrecord}&parenttab={$CATEGORY}&start={$privrecordstart} {if $result_aprove  eq '1' || $result_aprove eq '2' }&result_aprove={$result_aprove}{/if}'" name="privrecord" src="{'rec_prev.gif'|@lingdang_imageurl:$THEME}">&nbsp;
												{else}
													<img align="absmiddle" title="{'PREVDATA'|@getFixedLabel}" src="{'rec_prev_disabled.gif'|@lingdang_imageurl:$THEME}">
												{/if}
												{if $privrecord neq '' || $nextrecord neq ''}
													
												{/if}
												{if $nextrecord neq ''}
													<img align="absmiddle" title="{'NEXTDATA'|@getFixedLabel}" onclick="location.href='index.php?module={$MODULE}&viewtype={$VIEWTYPE}&action=DetailView&record={$nextrecord}&parenttab={$CATEGORY}&start={$nextrecordstart}'{if $result_aprove  eq '1' || $result_aprove eq '2' }&result_aprove={$result_aprove}{/if} " name="nextrecord" src="{'rec_next.gif'|@lingdang_imageurl:$THEME}">&nbsp;
												{else}
													<img align="absmiddle" title="{'NEXTDATA'|@getFixedLabel}" src="{'rec_next_disabled.gif'|@lingdang_imageurl:$THEME}">&nbsp;
												{/if}
                                            </div>
                                            <div class="rightbuttona">
                                            {if $MODULE eq 'Calendar'}
                                                <a class="Anu1_a" title="{'BACKTOLIST'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='ListView';DetailView.module.value='{$MODULE}';submitFormForAction('DetailView','ListView');"><img src="themes/softed/button/icon_back.png" /><span>{'BACKTOLIST'|@getFixedLabel}</span></a>
                                            {elseif $MODULE eq 'PaymentPlan'}
                                                <a class="Anu1_a" title="{'BACKTOLIST'|@getFixedLabel}" onclick="document.getElementById('return_module').value='{$MODULE}'; document.getElementById('return_action').value='index';document.getElementById('module').value='{$MODULE}';submitFormForAction('DetailView','index');"><img src="themes/softed/button/icon_back.png" /><span>{'BACKTOLIST'|@getFixedLabel}</span></a>
                                            {else}
                                                <a class="Anu1_a" title="{'BACKTOLIST'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='index';DetailView.module.value='{$MODULE}';submitFormForAction('DetailView','index');"><img src="themes/softed/button/icon_back.png" /><span>{'BACKTOLIST'|@getFixedLabel}</span></a>
											{/if}
                                            <!---edit button--->
                                             {if $EDITVIEW eq 'permitted'}
                                                <!---add lmx 20140214 转公海或者转普通按钮--->
                                                {$ACTIONLINKINFO}
                                                {if $MODULE neq 'Reminds' && $MODULE neq 'PaymentPlan'}
                                                    {if $ISEDIT eq 0}
                                             {if ($MODULE eq 'CashBill' || $MODULE eq 'SendCashBill') && $CHECKOUTSTATUS eq '未审核'}
                                                <a class="Anu1_a" title="{'Checkout'|@getFixedLabel}" onclick="checkcashbill('{$ID}',1,1);"><img src="themes/softed/button/icon_approval.png" /><span>{'Checkout'|@getFixedLabel}</span></a>
                                                <a class="Anu1_a" title="{'EDIT'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='DetailView'; DetailView.return_id.value='{$ID}';DetailView.module.value='{$MODULE}';submitFormForAction('DetailView','EditView');"><img src="themes/softed/button/icon_writer.png" /><span>{'EDIT'|@getFixedLabel}</span></a>
                                             {/if}   
                                             {if ($MODULE eq 'CashBill' || $MODULE eq 'SendCashBill') && $CHECKOUTSTATUS eq '已审核'}
                                                  <a class="Anu1_a" title="{'ACheckout'|@getFixedLabel}" onclick="checkcashbill('{$ID}',2,1);"><img src="themes/softed/button/icon_approval.png" /><span>{'ACheckout'|@getFixedLabel}</span></a>   
                                             {/if}
                                             {if $MODULE neq 'CashBill' && $MODULE neq 'SendCashBill'}
                                             <a class="Anu1_a" title="{'EDIT'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='DetailView'; DetailView.return_id.value='{$ID}';DetailView.module.value='{$MODULE}';submitFormForAction('DetailView','EditView');"><img src="themes/softed/button/icon_writer.png" /><span>{'EDIT'|@getFixedLabel}</span></a>
                                                 {/if}
                                                  {/if}
                                                {elseif $MODULE eq 'PaymentPlan'}
                                                    <a class="Anu1_a" title="{'EDIT'|@getFixedLabel}" onclick="document.getElementById('return_module').value='{$MODULE}'; document.getElementById('return_action').value='DetailView'; document.getElementById('return_id').value='{$ID}';document.getElementById('module').value='{$MODULE}';submitFormForAction('DetailView','EditView');"><img src="themes/softed/button/icon_writer.png" /><span>{'EDIT'|@getFixedLabel}</span></a>
                                                {else}
                                                    <a class="Anu1_a" title="{'CREATE'|@getFixedLabel}" onclick="NewInfo(event,'{$MODULE}','{$CATEGORY}');"><img src="themes/softed/button/icon_add.png" /><span>{'CREATE'|@getFixedLabel}</span></a>
											    {/if}  
                                            {/if}
                                            {if $MODULE eq 'BankAccountSet' && $CONFIRMEDST eq '0'}
                                                
                                                <a class="Anu1_a" title="{'CONFIRME'|@getFixedLabel}" onclick="set_bank_checks_presence({$ID},2);"><img src="themes/softed/button/icon_writer.png" /><span>{'CONFIRME'|@getFixedLabel}</span></a>
                                            {/if}
                                            {if $MODULE eq 'BankAccountSet' && $CONFIRMEDST neq '0'}
                                                <a class="Anu1_a" title="{'Account_Permissions'|@getFixedLabel}" onclick="PotentialsShare(this,'{$ID}');puyoungJS_DialogBox.unblock();"><img src="themes/softed/button/icon_approval.png" /><span>{'Account_Permissions'|@getFixedLabel}</span></a>
                                            {/if}
                                            
                                               <!---add lmx 20142020 销售机会新增共享按钮--->
                                               {if $POTENTIALS}
                                                    <a class="Anu1_a" title="{'SHARE'|@getFixedLabel}" onclick="PotentialsShare(this,'{$ID}');puyoungJS_DialogBox.unblock();"><img src="themes/softed/button/icon_share.png" /><span>{'SHARE'|@getFixedLabel}</span></a>
                                               {/if}
                                               {if $ACCOUNTSHARE}
                                                     <a class="Anu1_a" title="{'SHARE'|@getFixedLabel}" onclick="SetModuleShare('{$MODULE}','{$ID}');puyoungJS_DialogBox.unblock();"><img src="themes/softed/button/icon_share.png" /><span>{'SHARE'|@getFixedLabel}</span></a>
                                                {/if}
                                                {if $ISSUBMIT eq 1}
                                                   <div id="SubmitApprove" class="full-menu" style="display:none;width:30%;">
                                                   </div>
                                                   <a class="Anu1_a" title="{'SUBMITAPPROVAL'|@getFixedLabel}" onclick="submitapprove(this,'SubmitApprove','{$MODULE}',{$ID});"><img src="themes/softed/button/icon_approval.png" /><span>{'SUBMITAPPROVAL'|@getFixedLabel}</span></a>
                                                {/if}
                                                {if $ISAPPROVE eq 1}
                                                    <a class="Anu1_a" title="{'APPROVAL'|@getFixedLabel}" onclick="approveBlocks({$ID},'{$MODULE}',this,'ApproveBlocks');"><img src="themes/softed/button/icon_approval.png" /><span>{'APPROVAL'|@getFixedLabel}</span></a>
                                                {/if}
                                                <!---duplicate button--->
                                                
												{if $EDIT_DUPLICATE eq 'permitted' && $MODULE neq 'Documents'&& $MODULE neq 'Reminds'}
													{if $MODULE eq 'PaymentPlan'}
                                                        <a class="Anu1_a" title="{'COPY'|@getFixedLabel}" onclick="document.getElementById('return_module').value='{$MODULE}'; document.getElementById('return_action').value='DetailView'; document.getElementById('isDuplicate').value='true';document.getElementById('module').value='{$MODULE}'; submitFormForAction('DetailView','EditView');"><img src="themes/softed/button/icon_copy.png" /><span>{'COPY'|@getFixedLabel}</span></a>
                                                    {elseif $MODULE eq 'Attachment'}
                                                        
                                                    {else}                                                        
                                                        <a class="Anu1_a" title="{'COPY'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='DetailView'; DetailView.isDuplicate.value='true';DetailView.module.value='{$MODULE}'; submitFormForAction('DetailView','EditView');"><img src="themes/softed/button/icon_copy.png" /><span>{'COPY'|@getFixedLabel}</span></a>
												    {/if}
                                                {/if}
												{if $DELETE eq 'permitted'}
                                                     {if $MODULE eq 'PaymentPlan'}
                                                        <a class="Anu1_a" title="{'DELETE'|@getFixedLabel}" onclick="document.getElementById('return_module').value='{$MODULE}'; document.getElementById('return_action').value='index';
                                                        {if $MODULE eq 'Accounts'} var confirmMsg = arrJsPopLabel['SUREWANTDELETE'] 
                                                        {else} var confirmMsg = '{$APP.NTC_DELETE_CONFIRMATION}' {/if}; submitFormForActionWithConfirmation('DetailView', 'Delete', confirmMsg);">
                                                        <img src="themes/softed/button/icon_del.png" /><span>{'DELETE'|@getFixedLabel}</span></a>
                                                        
                                                     {elseif $MODULE eq 'Attachment'}
                                                        <!--edit:diony time:20131206 reson:判断如果是附件删除按钮不显示-->
                                                     {elseif $MODULE eq 'ContactRecords' || $MODULE eq 'Calendar' || $MODULE eq 'Potentials'}
                                                     {*
                                                        reason:知识管理增加审批流程
                                                        edit； andy
                                                        data:  02140414
                                                     *}
                                                         {if $ISDELETES eq 0}
    												        	 <a class="Anu1_a" title="{'DELETE'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='index';
                                                                 {if $MODULE eq 'Accounts'} var confirmMsg = arrJsPopLabel['REMOVEWILLDELETEOTHER']+'?'; 
                                                                 {else} var confirmMsg = arrJsPopLabel['SUREWANTDELETE'] {/if}; submitFormForActionWithConfirmation('DetailView', 'Delete', confirmMsg);">
                                                                 <img src="themes/softed/button/icon_del.png" /><span>{'DELETE'|@getFixedLabel}</span></a>
    				                                      {/if}

                                                     {elseif ($MODULE eq 'CashBill' || $MODULE eq 'SendCashBill') && $CHECKOUTSTATUS eq '已审核'}
                                                     {else}
                                                         {if $ISDELETE eq 0}
    												        	 <a class="Anu1_a" title="{'DELETE'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='index';
                                                                 {if $MODULE eq 'Accounts'} var confirmMsg = arrJsPopLabel['REMOVEWILLDELETEOTHER']+'?'; 
                                                                 {else} var confirmMsg = arrJsPopLabel['SUREWANTDELETE'] {/if}; submitFormForActionWithConfirmation('DetailView', 'Delete', confirmMsg);">
                                                                 <img src="themes/softed/button/icon_del.png" /><span>{'DELETE'|@getFixedLabel}</span></a>
    				                                      {/if}
                                                      {/if}
                                                {/if}
                                                </div>                                                
											</td>
										</tr>
									</table>
                                    {if $ISAPPROVE eq 1}
                                    <div id="ApproveBlocks" class="full-menu" style="display:none;">
                                    </div>
                                    <div class="full-menu" id="approvelog" style="display:none;z-index:1000000;border: 3px solid #687BA2;"></div>
                                    <div class="layerPopup" id="approvestepresult" style="display:none;z-index:1000000000;"></div>
                                    {/if}
                                    {if $ISAPPROVE eq 1}
                                    <div class="layerPopup" id="approvelog" style="display:none;z-index:1000000;"></div>
                                    <div class="full-menu" id="approvestepresult" style="display:none;z-index:1000000000;"></div>
                                    {/if}
								</td>
							</tr>

							<tr>
								<td valign=top align=left >
									<table border=0 cellspacing=0 cellpadding=3 width=100% class="dvtContentSpace" style="border-bottom:0;">
										<tr valign=top>
											<td align=left>
												<!-- content cache -->
                                            	<div id="MainDetailFeilds">
                                                    <!--详情页开始-->                                                
                                                   {if $MODULE eq 'Attachment'} 
                                                        {include file="AttachmentDetailTable.tpl"}
                                                   {else}
                										{include file="DetailTable.tpl"}	
                                                   {/if}  
                                                </div>
                                            </td>
											<td width=22% valign=top style="border-left:1px dashed #cccccc;padding:13px">
                                                {if $MODULE neq 'Calendar'}
											
												<table width="100%" border="0" cellpadding="5" cellspacing="0">
                                                	<tr><td align="left" class="genHeaderSmall">{'OPERATING'|@getFixedLabel}</td></tr>
                                                    
                                                    {if $MODULE eq 'PaymentPlan'&& $CAHSBILLCREATE eq 'yes'}
                                                    <tr>
                                                        <td align="left" style="padding-left:10px;">
                                                        <a href="javascript:CreateCashBill(this,'{$ID}')"  ><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel}{$CASHBILLMODULE|@getTranstab:$CASHBILLMODULE}</a>
                                                        </td>
                                                    </tr>
                                                    {/if}
                                                    {if $MODULE eq 'SendPayment'&& $SENDCAHSBILLCREATE eq 'yes'}
                                                    <tr>
                                                        <td align="left" style="padding-left:10px;">
                                                        <a href="javascript:CreateSendCashBill(this,'{$ID}')"  ><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {$SENDCASHBILLMODULE|@getTranstab:$SENDCASHBILLMODULE}</a>
                                                        </td>
                                                    </tr>
                                                    {/if}
                                                    {if $PROJECTTASKCREATE eq 'permitted'}
                                                    <tr>
                                                        <td align="left" style="padding-left:10px;">
                                                        <a href="index.php?module=ProjectTask&action=EditView&projectid={$ID}&return_module=ProjectTask&return_action=DetailView&project_id={$ID}&Create=yes" target="_blank" onclick=""><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'ProjectTask'|@getTranstab:'ProjectTask'}</a>
                                                        </td>
                                                    </tr>
                                                    {/if}
                                                    
                                                    {if $PROJECTMILESTONECREATE  eq 'permitted'}
                                                    <tr>
                                                        <td align="left" style="padding-left:10px;">
                                                            <a href="index.php?module=ProjectMilestone&action=EditView&projectid={$ID}&return_module=ProjectMilestone&return_action=DetailView&Create=yes" target="_blank" onclick=""><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'ProjectMilestone'|@getTranstab:'ProjectMilestone'}</a>
                                                        </td>
                                                    </tr>
                                                    {/if}
                                                    {if $REMINDS  eq 'permitted'|| $MODULE  eq 'VendorContactRecords'}
                                                    <tr>
                                                        <td align="left" style="padding-left:10px;">
                                                        <a href="index.php?module=Reminds&action=EditView&projectid={$ID}&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank" onclick=""><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
                                                        </td>
                                                    </tr>
                                                    {/if}
                                                    {if $MODULE eq 'Potentials'}
                                                        {if $ConvertContactRecords eq 'permitted'}
                                                            <tr>
                                                        		<td align="left" style="padding-left:10px;">
                                                        			<a href="index.php?return_module=ContactRecords&return_action=DetailView&convertmode=potentialcontactrecords&module=ContactRecords&action=EditView&potential_id={$ID}&account_id={$ACCOUNTID}&contact_id={$CONTACTID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'ContactRecords'|@getTranstab:'ContactRecords'}</a>
                                                        		</td>
                                                        	</tr>
                                                        {/if}
                                                        {if $CONVERTINVOICE eq 'permitted'}
                                                        	<tr>
                                                        		<td align="left" style="padding-left:10px;">
                                                        			<a href="index.php?return_module=Invoice&return_action=DetailView&convertmode={$CONVERTMODE}&module=Invoice&action=EditView&potential_id={$ID}&Create=yes&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'Invoice'|getTranstab:'Invoice'}</a>
                                                        		</td>
                                                        	</tr>
                                                        {/if}
                                                        {if $SalesOrderEditView eq 'permitted'}
                                                        	<tr>
                                                        		<td align="left" style="padding-left:10px;">
                                                        			<a href="index.php?return_module=SalesOrder&return_action=DetailView&module=SalesOrder&action=EditView&potential_id={$ID}&Create=yes&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'SalesOrder'|@getTranstab:'SalesOrder'}</a>
                                                        		</td>
                                                        	</tr>
                                                        {/if}
                                                        {if $QuotesEditView eq 'permitted'}
                                                        	<tr>
                                                        		<td align="left" style="padding-left:10px;">
                                                        			<a href="index.php?return_module=Quotes&return_action=DetailView&module=Quotes&action=EditView&potential_id={$ID}&Create=yes&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'Quotes'|@getTranstab:'Quotes'}</a>
                                                        		</td>
                                                        	</tr>
                                                        {/if}
                                                        {if $CalendarEditView eq 'permitted' }
                                                              <tr>
                                                                  <td align="left" style="padding-left:10px;">
                                                                   <a href="index.php?module=Calendar&action=EditView&return_module=Calendar&return_action=DetailView&parent_id={$ID}&Create=yes&potential_id={$ID}&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'Calendar'|@getTranstab:'Calendar'}</a>
                                                                  </td>
                                                              </tr>
                                                        {/if}
                                                        <tr>
                                                          <td align="left" style="padding-left:10px;">
                                                          <a href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
                                                          </td>
                                                        </tr>                                                  
                                                	{elseif $TODO_PERMISSION eq 'true' || $EVENT_PERMISSION eq 'true' || $CONTACT_PERMISSION eq 'true'|| $MODULE eq 'Contacts' || ($MODULE eq 'Documents')}
                                                        
                                                		{if $MODULE eq 'Contacts'}
                                                			{assign var=subst value="contact_id"}
                                                			{assign var=acc value="&account_id=$accountid"}
                                                		{else}
                                                			{assign var=subst value="parent_id"}
                                                			{assign var=acc value=""}
                                                		{/if}
                                                        <!--end-->
                                                        
                                                        
                                                        <!-- by LD Can 20130118 客户明细界面增加发票，联系人，报价单新增按钮-->
                                                        {if $MODULE eq 'Accounts'}                                                           
                                                           {if $ContactEditView eq 'yes' }
                                                              <tr>
                                                                  <td align="left" style="padding-left:10px;">
                                                                      <a href="index.php?module=Contacts&action=EditView&return_module=Contacts&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'Contacts'|@getTranstab:'Contacts'}</a>
                                                                   </td>
                                                              </tr>
                                                          {/if}
                                                          {if $ContactRecordEditView eq 'yes'}
                                                              <tr>
                                                                  <td align="left" style="padding-left:10px;">
                                                                       <a href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'ContactRecords'|@getTranstab:'ContactRecords'}</a>
                                                                  </td>
                                                              </tr>
                                                           {/if}
                                                           {if $CalendarEditView eq 'yes' }
                                                              <tr>
                                                                  <td align="left" style="padding-left:10px;">
                                                                  <a href="index.php?module=Calendar&action=EditView&return_module=Calendar&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'Calendar'|@getTranstab:'Calendar'}</a>
                                                                  </td>
                                                              </tr>
                                                            {/if}
                                                          <tr>
                                                              <td align="left" style="padding-left:10px;">
                                                              <a href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
                                                              </td>
                                                          </tr>
                                                          {if $QuoteEditView eq 'yes' }
                                                                <tr>
                                                                    <td align="left" style="padding-left:10px;">
                                                                        <a href="index.php?module=Quotes&action=EditView&return_module=Quotes&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'Quotes'|@getTranstab}</a>
                                                                    </td>
                                                                </tr>
                                                           {/if}                                                             
                                                           {if $PotentialEditView eq 'yes' }
                                                                <tr>
                                                                      <td align="left" style="padding-left:10px;">
                                                                      <a href="index.php?module=Potentials&action=EditView&return_module=Potentials&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'Potentials'|@getTranstab:'Potentials'}</a>
                                                                      </td>
                                                                </tr>
                                                            {/if}                                                             
                                                            {if $SaleOrderEditView eq 'yes' }
                                                              <tr>
                                                                  <td align="left" style="padding-left:10px;">                                                                            
                                                                  <a href="index.php?module=SalesOrder&action=EditView&return_module=SalesOrder&return_action=DetailView&return_id=&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'SalesOrder'|@getTranstab:'SalesOrder'}</a>
                                                                  </td>
                                                              </tr>
                                                             {/if}                                                          
                                                             {if $InvoiceEditView eq 'yes' }
                                                                  <tr>
                                                                      <td align="left" style="padding-left:10px;">
                                                                      <a href="index.php?module=Invoice&action=EditView&return_module=Invoice&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'Invoice'|@getTranstab:'Invoice'}</a>
                                                                      </td>
                                                                  </tr>
                                                               {/if}
                                                               {if $OutboundOrderEditView eq 'yes'}
                                                                   <tr>
                                                                    <td align="left" style="padding-left:10px;">
                                                                        <a href="index.php?module=OutboundOrder&action=EditView&return_module=OutboundOrder&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'OutboundOrder'|@getTranstab:'OutboundOrder'}</a>
                                                                    </td>
                                                                   </tr>
                                                               {/if}
                                                               <tr>
                                                                    <td align="left" style="padding-left:10px;">
                                                                        <a href="index.php?module=CashBill&action=EditView&return_module=CashBill&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'CashBill'|@getTranstab:'CashBill'}</a>
                                                                    </td>
                                                               </tr>
                                                        {/if}
                                                        {if  $ConvertContactRecords eq 'permitted'}                                                            
                                                            <tr>
                                                        		<td align="left" style="padding-left:10px;">
                                                        			<a href="index.php?return_module=ContactRecords&return_action=DetailView&convertmode=contactcontactrecords&module=ContactRecords&action=EditView&account_id={$ACCOUNTID}&Create=yes&contact_id={$ID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'ContactRecords'|@getTranstab:'ContactRecords'}</a>
                                                        		</td>
                                                        	</tr>                                                             
                                                        {/if}
                                                        <!--联系记录没有日程 by LD Can 20130205-->
                                                        {if $MODULE neq 'ContactRecords'}
                                                        	{if  $MODULE eq 'Contacts'}
                                                                {if $CREATEATTACHMENT eq 'permitted' && $FORSHOW eq 'yes'}                                                                
                                                        		<tr>
                                                        			<td align="left" style="padding-left:10px;">
                                                        				<a href="index.php?module=Contacts&action=EditView&return_action=DetailView&parenttab=Parent Accounts&Create=true&contact_id={$ID}&account_id={$ACCOUNTID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'THELOWCONTACT'|@getFixedLabel}</a>
                                                        			</td>
                                                        		</tr>                                                               
                                                                {/if} 
                                                                {if  $FORSHOW eq 'yes'}                                                                
                                                        		<tr>
                                                        			<td align="left" style="padding-left:10px;">
                                                        				<a href="index.php?module=Contacts&action=ContactsHierarchy&contact_id={$ID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'VIEW'|@getFixedLabel} {'THELOWLEVELCONTRACTS'|@getFixedLabel}</a>
                                                        			</td>
                                                        		</tr>                                                               
                                                                {/if}
                                                                {if $EVENT_PERMISSION eq 'true'}                                                                
                                                        		<tr>
                                                        			<td align="left" style="padding-left:10px;">
                                                        				<a href="index.php?module=Calendar&action=EditView&return_module={$MODULE}&return_action=DetailView&activity_mode=Events&return_id={$ID}&{$subst}={$ID}{$acc}&parenttab={$CATEGORY}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'Calendar'|@getTranstab:'Calendar'}</a>
                                                        			</td>
                                                        		</tr>                                                               
                                                                {/if}                                                                
                                                                <tr>
                                                                  <td align="left" style="padding-left:10px;">
                                                                  <a href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&contact_id={$CONTACTID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
                                                                  </td>
                                                                  </tr>                                                               
                                                        	{/if}                                                            
                                                        {/if}
                                                        {if $MODULE eq 'Leads'}															
                                                            {if $SENDMAILBUTTON eq 'permitted'}
                                                        		<tr>
                                                        			<td align="left" style="padding-left:10px;">
                                                        				{foreach key=index item=email from=$EMAILS}
                                                        					<input type="hidden" name="email_{$index}" value="{$email}"/>
                                                        				{/foreach}
                                                        				<a href="javascript:void(0);" onclick="{$JS}"><span class="icon-homeimg icon-pointer"></span>{$APP.LBL_SENDMAIL_BUTTON_LABEL}</a>
                                                        			</td>
                                                        		</tr>
                                                        	{/if}
                                                            {if $MODULE eq 'Contacts'} 
                                                            {if $SENDSMSBUTTON eq 'permitted'}
                                                            <tr>
                                                                <td align="left" style="padding-left:10px;">
                                                                <a href="javascript:void(0);" onclick="window.open('index.php?module=MassSMS&action=index&parenttab=Marketing&select_options={$ID}&return_module={$MODULE}&return_action=DetailView',null,'1024,768,menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes')"><span class="icon-homeimg icon-pointer"></span>{'Send_SMS'|@getFixedLabel}</a>
                                                                </td>
                                                                </tr>
                                                            {/if}
                                                            {/if}                                                            
                                                        {/if} 
                                                        <!-- Start: Actions for Documents Module -->
                                                        {if $MODULE eq 'Documents'}
                                                        	<tr>
                                                            <td align="left" style="padding-left:10px;">
                                                        			{if $DLD_TYPE eq 'I' && $FILE_STATUS eq '1' && $FILE_EXIST eq 'yes'}
                                                        				<a href="index.php?module=uploads&action=downloadfile&fileid={$FILEID}&entityid={$NOTESID}" onclick="javascript:dldCntIncrease({$NOTESID});"><span class="icon-homeimg icon-pointer"></span>{'DOWNLOADFILE'|@getFixedLabel}</a>
                                                        			{elseif $DLD_TYPE eq 'E' && $FILE_STATUS eq '1'}
                                                        				<a target="_blank" href="{$DLD_PATH}" onclick="javascript:dldCntIncrease({$NOTESID});"><span class="icon-homeimg icon-pointer"></span>{'DOWNLOADFILE'|@getFixedLabel}</a>
                                                        			{/if}
                                                        	</td>
                                                            </tr>
                                                        	{if $CHECK_INTEGRITY_PERMISSION eq 'yes'}
                                                        		<tr>
                                                                <td align="left" style="padding-left:10px;">
                                                        			<a href="javascript:;" onClick="checkFileIntegrityDetailView({$NOTESID});"><span class="icon-homeimg icon-pointer"></span>{'CHECKATTACHMENTINTEGRITY'|@getFixedLabel}</a>&nbsp;
                                                        			<input type="hidden" id="dldfilename" name="dldfilename" value="{$FILEID}-{$FILENAME}">
                                                        			<span id="vtbusy_integrity_info" style="display:none;">
                                                        				<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
                                                        			<span id="integrity_result" style="display:none"></span>
                                                        		</td></tr>
                                                        	{/if}
                                                            {if $DLD_TYPE eq 'I' &&  $FILE_STATUS eq '1' && $FILE_EXIST eq 'yes'}
                                                        		<tr>
                                                                    <td align="left" style="padding-left:10px;">
                                                        				<input type="hidden" id="dldfilename" name="dldfilename" value="{$FILEID}-{$FILENAME}"><!--attachment.gfi-->
                                                        				<a href="javascript: document.DetailView.return_module.value='Documents'; document.DetailView.return_action.value='DetailView'; document.DetailView.module.value='Documents'; document.DetailView.action.value='EmailFile'; document.DetailView.record.value={$NOTESID}; document.DetailView.return_id.value={$NOTESID}; sendfile_email();"><span class="icon-homeimg icon-pointer"></span>{'SENTEMAILATTACHMENTS'|@getFixedLabel}</a>
                                                        			</td>
                                                                </tr>
                                                            {/if}
                                                        {/if}   
                                                        
                                                	{/if}
                                                </table>
                                                
                                                
                                                {if $CUSTOM_LINKS && $CUSTOM_LINKS.DETAILVIEWBASIC}                                                
													<table width="100%" border="0" cellpadding="5" cellspacing="0">
                                                        {if $SENDMAILBUTTON eq 'permitted'}
                                                                {if $ISMASSEMAIL neq 5}
    																<tr>
    																	<td align="left" style="padding-left:10px;">
    																		{foreach key=index item=email from=$EMAILS}
    																			<input type="hidden" name="email_{$index}" value="{$email}"/>
    																		{/foreach}
    																		{if $MODULE eq 'Accounts'}
                                                                            <a href="javascript:void(0);" onclick="detailview_email_account_show('Accounts')"><span class="icon-homeimg icon-pointer"></span>{'Send_mail'|@getFixedLabel}</a>
                                                                            {else}
                                                                            <a href="javascript:void(0);" onclick="detailview_email_contact_show()"><span class="icon-homeimg icon-pointer"></span>{'Send_mail'|@getFixedLabel}</a>
                                                                            {/if}
                                                                        </td>
    																</tr>
                                                                    {/if}
    															{/if}
                                                                {if $SENDSMSBUTTON eq 'permitted'}
                                                                    {if $ISMASSEMAIL neq 5}
                                                                        <tr>
                                                                            <td align="left" style="padding-left:10px;">
                                                                            {if $MODULE eq 'Accounts'}
                                                                            <a href="javascript:void(0);" onclick="detailview_SMS_account_show('SMS','Accounts')"><span class="icon-homeimg icon-pointer"></span>{'Send_SMS'|@getFixedLabel}</a>
                                                                            {else}
                                                                            <a href="javascript:void(0);" onclick="detailview_MassSMS_contact_show()"><span class="icon-homeimg icon-pointer"></span>{'Send_SMS'|@getFixedLabel}</a>
                                                                            {/if}
                                                                            </td>
                                                                        </tr>
                                                                    {/if}
                                                                {/if}
                                                                {if $CREATEATTACHMENT eq 'permitted'}
                                                                    <tr>
                                                                        <td align="left" style="padding-left:10px;">
                                                                        <a href="index.php?module=Attachment&action=EditView&return_module=Attachment&return_action=DetailView&parent_id={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel} {'Attachment'|@getFixedLabel}</a>
                                                                        </td>
                                                                    </tr>
                                                                {/if}
                                                                
                                                                {if $MODULE eq 'ContactRecords'}
                                                                    <tr>
                                                                        <td align="left" style="padding-left:10px;">
                                                                        <a href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank" class="webMnu"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
                                                                        </td>
                                                                    </tr>
                                                                {/if}
                                                                {if $MODULE eq 'HelpDesk'}
                                                                <tr>
                                                                    <td align="left" style="padding-left:10px;">
                                                                    <a href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&Create=yes&troubleticketid={$ID}&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel}  {'ContactRecords'|@getTranstab:'ContactRecords'}</a>
                                                                    </td>
                                                                </tr>
                                                                {/if}
                                                                {if $MODULE eq 'Project'}
                                                                    <tr>
                                                                        <td align="left" style="padding-left:10px;">
                                                                        <a href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&Create=yes&account_id={$ACCOUNTID}&projectid={$ID}&contact_id={$CONTACTID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel}  {'ContactRecords'|@getTranstab:'ContactRecords'}</a>
                                                                        </td>
                                                                    </tr>
                                                                {/if}
                                                                {if $MODULE eq 'ProjectTask'}
                                                                    <tr>
                                                                        <td align="left" style="padding-left:10px;">
                                                                        <a href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&Create=yes&projecttaskid={$ID}&projectid={$PROJECTID}" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel}  {'ContactRecords'|@getTranstab:'ContactRecords'}</a>
                                                                        </td>
                                                                    </tr>
                                                                {/if}
                                                                {if $MODULE eq 'HelpDesk'}
                                                                    <tr>
                                                                        <td align="left" style="padding-left:10px;">
                                                                        <a href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank"><span class="icon-homeimg icon-pointer"></span>{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
                                                                        </td>
                                                                    </tr>
                                                                {/if}
                                                                {foreach item=CUSTOMLINK from=$CUSTOM_LINKS.DETAILVIEWBASIC}  
                                                           	<tr>
																<td align="left" style="padding-left:10px;">
																	{assign var="customlink_href" value=$CUSTOMLINK->linkurl}
																	{assign var="customlink_label" value=$CUSTOMLINK->linklabel}
																	{if $customlink_label eq ''}
																		{assign var="customlink_label" value=$customlink_href}
																	{else}
																		{* Pickup the translated label provided by the module *}
																		{assign var="customlink_label" value=$customlink_label|@getTranslatedString:$CUSTOMLINK->module()}
																	{/if}
																	{if $CUSTOMLINK->linkicon}
																		<a href="{$customlink_href}"><img hspace=5 align="absmiddle" border=0 src="{$CUSTOMLINK->linkicon}"></a>
																	{/if}
																	<a href="{$customlink_href}">{$customlink_label|@getFixedLabel}</a>
                                                                </td>                                                        
															</tr>
                                                        {/foreach}
                                                    </table>
												{/if}
                                           
												{* vtlib customization: Custom links on the Detail view basic links *}
												
												{* vtlib customization: Custom links on the Detail view *}
												{if $CUSTOM_LINKS && $CUSTOM_LINKS.DETAILVIEW}
													<br/>
													{if !empty($CUSTOM_LINKS.DETAILVIEW)}
														<table width="100%" border="0" cellpadding="5" cellspacing="0">
															<tr>
                                                                <td align="left" class="dvtUnSelectedCell dvtCellLabel">
															     <a href="javascript:;" onmouseover="fnvshobj(this,'vtlib_customLinksLay');" onclick="fnvshobj(this,'vtlib_customLinksLay');"><b>{$APP.LBL_MORE} {$APP.LBL_ACTIONS} &#187;</b></a>
																</td>
                                                            </tr>
														</table>
														<br/>
														<div style="display: none; left: 193px; top: 106px;width:155px; position:absolute;" id="vtlib_customLinksLay"
															 onmouseout="fninvshnew('vtlib_customLinksLay')" onmouseover="fnvshNrm('vtlib_customLinksLay')">
															<table bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="0" width="100%">
																<tr>
                                                                    <td style="border-bottom: 1px solid rgb(204, 204, 204); padding: 5px;"><b>{$APP.LBL_MORE} {$APP.LBL_ACTIONS} &#187;</b>
                                                                    </td>
                                                                </tr>
																<tr>
																	<td>
																		{foreach item=CUSTOMLINK from=$CUSTOM_LINKS.DETAILVIEW}
																			{assign var="customlink_href" value=$CUSTOMLINK->linkurl}
																			{assign var="customlink_label" value=$CUSTOMLINK->linklabel}
																			{if $customlink_label eq ''}
																				{assign var="customlink_label" value=$customlink_href}
																			{else}
																				{* Pickup the translated label provided by the module *}
																				{assign var="customlink_label" value=$customlink_label|@getTranslatedString:$CUSTOMLINK->module()}
																			{/if}
																			<a href="{$customlink_href}" class="drop_down">{$customlink_label}</a>
																		{/foreach}
																	</td>
																</tr>
															</table>
														</div>
													{/if}
												{/if}
												{* END *}
												<!-- Action links END -->
                                                {/if}
                                                
                                                
                                                
                                                
                                                {*aaaaaa*}
												{if $TAG_CLOUD_DISPLAY eq 'true'}
													<!-- Tag cloud display -->
													<table border=0 cellspacing=0 cellpadding=0 width=100% class="tagCloud">
														<tr>
															<td class="tagCloudTopBg"><img src="{$IMAGE_PATH}tagCloudName.gif" border=0></td>
														</tr>
														<tr>
															<td>
                                                            <div id="tagdiv" style="display:visible;">
                                                            <form method="POST" action="javascript:void(0);" onsubmit="return tagvalidate();">
                                                            <input class="textbox"  type="text" id="txtbox_tagfields" name="textbox_First Name" value="" style="width:100px;margin-left:5px;">
                                                            </input>
                                                            &nbsp;&nbsp;
                                                            <input name="button_tagfileds" type="submit" class="save" value="{$APP.LBL_TAG_IT}11" />
                                                            </form>
                                                            </div>
                                                            </td>
														</tr>
														<tr>
															<td class="tagCloudDisplay" valign=top> <span id="tagfields">{$ALL_TAG}</span></td>
														</tr>
													</table>
													<!-- End Tag cloud display -->
												{/if}
												<!-- Mail Merge-->
												<br>
													<form action="index.php" method="post" name="TemplateMerge" id="form">
														<input type="hidden" name="module" value="{$MODULE}">
														<input type="hidden" name="parenttab" value="{$CATEGORY}">
														<input type="hidden" name="record" id="record" value="{$ID}">
														<input type="hidden" name="action">
                            <!--工具-->
                            <!-- Following condition is added to avoid the Tools section in Products and Vendors because we are not providing the Print and Email Now links throughout all the modules. when we provide these links we will remove this if condition -->
                            {if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT'&& $MODULE neq 'Attachment'}
                                <span class="genHeaderSmall" style="display:block;margin-bottom:10px;">{'TOOLS'|@getFixedLabel}</span>
                                <table class="listTable" width="103%" cellspacing="0" cellpadding="5" border="0">
                                    <tbody>
                                        <tr>
                                            <td class="colHeader small">
                                               {'Please_select_a_template'|@getFixedLabel}
                                            </td>
                                        </tr>
                                        <tr>
                                            <td >
                                                <select id="templateprinttype" class="borderALL"  name="templateprinttype" style="width:145px;">
                                                    {foreach item=templateinfo key=printid from=$TEMPLATEPRINTS}
                                                        {if $templateinfo.1 eq 1}
                                                            <option value='{$printid}' selected="true">{$templateinfo.0}</option>
                                                        {else}
                                                        <option value='{$printid}'>{$templateinfo.0}</option>
                                                        {/if}
                                                    {foreachelse}
                                                        <option value="0">{'Please_select_print_templates'|@getFixedLabel}</option>
                                                    {/foreach}
                                                </select>
                                            </td>
                                        </tr>
                                    <!-- To display the Export To PDF link for PO, SO, Quotes and Invoice - starts -->
                                   {if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT'}
                        		   {assign var=export_pdf_action value="CreatePDF"}
                                        <tr>
                                            <td class="listTableRow small" style="border-bottom:0px;">
                                                <a href="javascript:;" onclick="var printid=document.getElementById('templateprinttype').value;if(printid==0) {ldelim} 
									var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
												RemindsMsg('','LdPopWidth400px','','yes','',confirm_str);
                                                return false;
                                                {rdelim} OpenNewWebTab('index.php?module=Settings&action=TemplatePrintHtml&tabname={$MODULE}&printid='+printid+'&record={$ID}')"><span class="icon-homeimg icon-pointer"></span>{'PRINT'|@getFixedLabel}</a>
                                            </td>
                                        </tr>
                                        <tr>
                        	                <td class="listTableRow small" style="border-bottom:0px;">
                  		                    	<a onclick="ConvertToPDF(this,'{$MODULE}',{$ID});" href="javascript:;"><span class="icon-homeimg icon-pointer"></span>{'ExporttoPDF'|@getFixedLabel}</a>
                        	               </td>
                                        </tr>
                                        {if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT'}
                                        <!-- Added to give link to  send Invoice PDF through mail -->
                                            <tr>
                            	               <td class="listTableRow small">
                        		                   <a href="javascript:;" onclick="javascript:var printid=document.getElementById('templateprinttype').value;if(printid==0) {ldelim}
                        		    var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
												RemindsMsg('','LdPopWidth400px','','yes','',confirm_str);
                        		                   return false;{rdelim} window.open('index.php?module={$MODULE}&action=SendPDFMail&printid='+printid+'&record={$ID}')"><span class="icon-homeimg icon-pointer"></span>{'Send_Email_Add_PDF'|@getFixedLabel}</a> 
                            	               </td>
                                            </tr>
                                        {/if}
                                    {/if}
                                    <!-- Above if condition is added to avoid the Tools section in Products and Vendors because we are not providing the Print and Email Now links throughout all the modules. when we provide these links we will remove this if condition -->
                                    </tbody>
                                </table>
                            {/if}
                                                                             
                    </form>
												{if !empty($CUSTOM_LINKS.DETAILVIEWWIDGET)}
													{foreach key=CUSTOMLINK_NO item=CUSTOMLINK from=$CUSTOM_LINKS.DETAILVIEWWIDGET}
														{assign var="customlink_href" value=$CUSTOMLINK->linkurl}
														{assign var="customlink_label" value=$CUSTOMLINK->linklabel}
														{* Ignore block:// type custom links which are handled earlier *}
														{if !preg_match("/^block:\/\/.*/", $customlink_href)}
															{if $customlink_label eq ''}
																{assign var="customlink_label" value=$customlink_href}
															{else}
																{* Pickup the translated label provided by the module *}
																{assign var="customlink_label" value=$customlink_label|@getTranslatedString:$CUSTOMLINK->module()}
															{/if}
															<br/>
															<table border=0 cellspacing=0 cellpadding=0 width=100% class="rightMailMerge">
																<tr>
																	<td class="rightMailMergeHeader">
																		<b>{$customlink_label}</b>
																		<img id="detailview_block_{$CUSTOMLINK_NO}_indicator" style="display:none;" src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0" align="absmiddle" />
																	</td>
																</tr>
																<tr style="height:25px">
																	<td class="rightMailMergeContent">
                                                                    <div id="detailview_block_{$CUSTOMLINK_NO}"></div>
                                                                    </td>
																</tr>
																<script type="text/javascript">
																    vtlib_loadDetailViewWidget("{$customlink_href}", "detailview_block_{$CUSTOMLINK_NO}", "detailview_block_{$CUSTOMLINK_NO}_indicator");
																</script>
															</table>
														{/if}
													{/foreach}
												{/if}
											</td>
										</tr>
									</table>
									<!-- PUBLIC CONTENTS STOPS-->
								</td>
							</tr>
							<tr>
								<td>
                                    {*{if $TEMPLATEPRINTS eq 'NOTEMPLATEPRINT'}*}
									<table border=0 cellspacing=0 cellpadding=3 width=100% class="small" >
										<tr>
											<td class="dvtTabCacheBottom" style="width:10px" nowrap>&nbsp;</td>
											<td class="dvtSelectedCellCommon dvtSelectedCellBottom" align=center nowrap>{$MODULE|@getTranstab} {'INFORMATION'|@getFixedLabel}</td>
											<td class="dvtTabCacheBottom" style="width:10px">&nbsp;</td>
											{if $SinglePane_View eq 'false' && $IS_REL_LIST neq false && $IS_REL_LIST|@count > 0}
												<td class="dvtUnSelectedCell" align=center nowrap>
                                                <a href="index.php?action=CallRelatedList&module={$MODULE}&record={$ID}&parenttab={$CATEGORY}">{'MORE'|@getFixedLabel} {'INFORMATION'|@getFixedLabel}</a>
                                                </td>
											{/if}
											<td class="dvtTabCacheBottom" align="right" style="width:100%" >
											<div class="rightbuttonimg">
											{if $privrecord neq ''}
                                              	<img align="absmiddle" title="{'PREVDATA'|@getFixedLabel}" onclick="location.href='index.php?module={$MODULE}&viewtype={$VIEWTYPE}&action=DetailView&record={$privrecord}&parenttab={$CATEGORY}&start={$privrecordstart}'" name="privrecord" src="{'rec_prev.gif'|@lingdang_imageurl:$THEME}">&nbsp;
											{else}
												<img align="absmiddle" title="{'PREVDATA'|@getFixedLabel}" src="{'rec_prev_disabled.gif'|@lingdang_imageurl:$THEME}">
											{/if}
											{if $privrecord neq '' || $nextrecord neq ''}
												<!--<img align="absmiddle" title="{'JUMPURL'|@getFixedLabel}" onclick="var obj = this;var lhref = getListOfRecords(obj, '{$MODULE}',{$ID},'{$CATEGORY}');" name="jumpBtnIdTop" id="jumpBtnIdTop" src="{'rec_jump.gif'|@lingdang_imageurl:$THEME}">&nbsp;-->
											{/if}
											{if $nextrecord neq ''}
												<img align="absmiddle" title="{'NEXTDATA'|@getFixedLabel}" startpage="{$nextrecordstart}" module="{$MODULE}" viewtype="{$VIEWTYPE}" record='{$nextrecord}' onclick="DetailViewPreVNext(ld(this))" name="nextrecord" src="{'rec_next.gif'|@lingdang_imageurl:$THEME}">&nbsp;
											{else}
												<img align="absmiddle" title="{'NEXTDATA'|@getFixedLabel}" src="{'rec_next_disabled.gif'|@lingdang_imageurl:$THEME}">&nbsp;
											{/if}
                                            </div>
                                            <div class="rightbuttona">
                                            {if $MODULE eq 'Calendar'}
                                                <a class="Anu1_a" title="{'BACKTOLIST'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='ListView';DetailView.module.value='{$MODULE}';submitFormForAction('DetailView','ListView');"><img src="themes/softed/button/icon_back.png" /><span>{'BACKTOLIST'|@getFixedLabel}</span></a>
                                            {elseif $MODULE eq 'PaymentPlan'}
                                                <a class="Anu1_a" title="{'BACKTOLIST'|@getFixedLabel}" onclick="document.getElementById('return_module').value='{$MODULE}'; document.getElementById('return_action').value='index';document.getElementById('module').value='{$MODULE}';submitFormForAction('DetailView','index');"><img src="themes/softed/button/icon_back.png" /><span>{'BACKTOLIST'|@getFixedLabel}</span></a>
                                            {else}
                                                <a class="Anu1_a" title="{'BACKTOLIST'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='index';DetailView.module.value='{$MODULE}';submitFormForAction('DetailView','index');"><img src="themes/softed/button/icon_back.png" /><span>{'BACKTOLIST'|@getFixedLabel}</span></a>
											{/if}
                                            <!---edit button--->
                                             {if $EDITVIEW eq 'permitted'}
                                                <!---add lmx 20140214 转公海或者转普通按钮--->
                                                {$ACTIONLINKINFO}
                                                {if $MODULE neq 'Reminds' && $MODULE neq 'PaymentPlan'}
                                                    {if $ISEDIT eq 0}
                                                    {if ($MODULE eq 'CashBill' || $MODULE eq 'SendCashBill') && $CHECKOUTSTATUS eq '未审核'}
                                                <a class="Anu1_a" title="{'Checkout'|@getFixedLabel}" onclick="checkcashbill('{$ID}',1,1);"><img src="themes/softed/button/icon_approval.png" /><span>{'Checkout'|@getFixedLabel}</span></a>
                                                <a class="Anu1_a" title="{'EDIT'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='DetailView'; DetailView.return_id.value='{$ID}';DetailView.module.value='{$MODULE}';submitFormForAction('DetailView','EditView');"><img src="themes/softed/button/icon_writer.png" /><span>{'EDIT'|@getFixedLabel}</span></a>
                                             {/if}   
                                             {if ($MODULE eq 'CashBill' || $MODULE eq 'SendCashBill') && $CHECKOUTSTATUS eq '已审核'}
                                                  <a class="Anu1_a" title="{'ACheckout'|@getFixedLabel}" onclick="checkcashbill('{$ID}',2,1);"><img src="themes/softed/button/icon_approval.png" /><span>{'ACheckout'|@getFixedLabel}</span></a>   
                                             {/if}
                                             {if $MODULE neq 'CashBill' && $MODULE neq 'SendCashBill'}
                                             <a class="Anu1_a" title="{'EDIT'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='DetailView'; DetailView.return_id.value='{$ID}';DetailView.module.value='{$MODULE}';submitFormForAction('DetailView','EditView');"><img src="themes/softed/button/icon_writer.png" /><span>{'EDIT'|@getFixedLabel}</span></a>
                                                 {/if}
                                                    {/if}
                                                {elseif $MODULE eq 'PaymentPlan'}
                                                    <a class="Anu1_a" title="{'EDIT'|@getFixedLabel}" onclick="document.getElementById('return_module').value='{$MODULE}'; document.getElementById('return_action').value='DetailView'; document.getElementById('return_id').value='{$ID}';document.getElementById('module').value='{$MODULE}';submitFormForAction('DetailView','EditView');"><img src="themes/softed/button/icon_writer.png" /><span>{'EDIT'|@getFixedLabel}</span></a>
                                                {else}
                                                    <a class="Anu1_a" title="{'CREATE'|@getFixedLabel}" onclick="NewInfo(event,'{$MODULE}','{$CATEGORY}');"><img src="themes/softed/button/icon_add.png" /><span>{'CREATE'|@getFixedLabel}</span></a>
											    {/if}  
                                            {/if}
                                            {if $MODULE eq 'BankAccountSet' && $CONFIRMEDST eq '0'}
                                                
                                                <a class="Anu1_a" title="{'CREATE'|@getFixedLabel}" onclick="set_bank_checks_presence({$ID},2);"><img src="themes/softed/button/icon_writer.png" /><span>{'CONFIRME'|@getFixedLabel}</span></a>
                                            {/if}
                                            {if $MODULE eq 'BankAccountSet' && $CONFIRMEDST neq '0'}
                                                <a class="Anu1_a" title="{'Account_Permissions'|@getFixedLabel}" onclick="PotentialsShare(this,'{$ID}');puyoungJS_DialogBox.unblock();"><img src="themes/softed/button/icon_approval.png" /><span>{'Account_Permissions'|@getFixedLabel}</span></a>
                                            {/if}
                                               <!---add lmx 20142020 销售机会新增共享按钮--->
                                               {if $POTENTIALS}
                                                    <a class="Anu1_a" title="{'SHARE'|@getFixedLabel}" onclick="PotentialsShare(this,'{$ID}');puyoungJS_DialogBox.unblock();"><img src="themes/softed/button/icon_share.png" /><span>{'SHARE'|@getFixedLabel}</span></a>
                                               {/if}
                                               {if $ACCOUNTSHARE}
                                                     <a class="Anu1_a" title="{'SHARE'|@getFixedLabel}" onclick="SetModuleShare('{$MODULE}','{$ID}');puyoungJS_DialogBox.unblock();"><img src="themes/softed/button/icon_share.png" /><span>{'SHARE'|@getFixedLabel}</span></a>
                                                {/if}
                                                {if $ISSUBMIT eq 1}
                                                   <div id="SubmitApprove" class="full-menu" style="display:none;width:30%;">
                                                   </div>
                                                   <a class="Anu1_a" title="{'SUBMITAPPROVAL'|@getFixedLabel}" onclick="submitapprove(this,'SubmitApprove','{$MODULE}',{$ID});"><img src="themes/softed/button/icon_approval.png" /><span>{'SUBMITAPPROVAL'|@getFixedLabel}</span></a>
                                                {/if}
                                                {if $ISAPPROVE eq 1}
                                                    <a class="Anu1_a" title="{'APPROVAL'|@getFixedLabel}" onclick="approveBlocks({$ID},'{$MODULE}',this,'ApproveBlocks');"><img src="themes/softed/button/icon_approval.png" /><span>{'APPROVAL'|@getFixedLabel}</span></a>
                                                {/if}
                                                <!---duplicate button--->
                                                
												{if $EDIT_DUPLICATE eq 'permitted' && $MODULE neq 'Documents'&& $MODULE neq 'Reminds'}
													{if $MODULE eq 'PaymentPlan'}
                                                        <a class="Anu1_a" title="{'COPY'|@getFixedLabel}" onclick="document.getElementById('return_module').value='{$MODULE}'; document.getElementById('return_action').value='DetailView'; document.getElementById('isDuplicate').value='true';document.getElementById('module').value='{$MODULE}'; submitFormForAction('DetailView','EditView');"><img src="themes/softed/button/icon_copy.png" /><span>{'COPY'|@getFixedLabel}</span></a>
                                                    {elseif $MODULE eq 'Attachment'}
                                                        
                                                    {else}                                                        
                                                        <a class="Anu1_a" title="{'COPY'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='DetailView'; DetailView.isDuplicate.value='true';DetailView.module.value='{$MODULE}'; submitFormForAction('DetailView','EditView');"><img src="themes/softed/button/icon_copy.png" /><span>{'COPY'|@getFixedLabel}</span></a>
												    {/if}
                                                {/if}
												{if $DELETE eq 'permitted'}
                                                     {if $MODULE eq 'PaymentPlan'}
                                                        <a class="Anu1_a" title="{'DELETE'|@getFixedLabel}" onclick="document.getElementById('return_module').value='{$MODULE}'; document.getElementById('return_action').value='index';
                                                        {if $MODULE eq 'Accounts'} var confirmMsg = '{$APP.NTC_ACCOUNT_DELETE_CONFIRMATION}' 
                                                        {else} var confirmMsg = arrJsPopLabel['SUREWANTDELETE'] {/if}; submitFormForActionWithConfirmation('DetailView', 'Delete', confirmMsg);">
                                                        <img src="themes/softed/button/icon_del.png" /><span>{'DELETE'|@getFixedLabel}</span></a>
                                                        
                                                     {elseif $MODULE eq 'Attachment'}
                                                        <!--edit:diony time:20131206 reson:判断如果是附件删除按钮不显示-->
                                                     {elseif ($MODULE eq 'CashBill' || $MODULE eq 'SendCashBill') && $CHECKOUTSTATUS eq '已审核'}
                                                     {else}
                                                         {if $ISDELETE eq 0}
    												        	 <a class="Anu1_a" title="{'DELETE'|@getFixedLabel}" onclick="DetailView.return_module.value='{$MODULE}'; DetailView.return_action.value='index';
                                                                 {if $MODULE eq 'Accounts'} var confirmMsg = arrJsPopLabel['REMOVEWILLDELETEOTHER']
                                                                 {else} var confirmMsg = arrJsPopLabel['SUREWANTDELETE'] {/if}; submitFormForActionWithConfirmation('DetailView', 'Delete', confirmMsg);">
                                                                 <img src="themes/softed/button/icon_del.png" /><span>{'DELETE'|@getFixedLabel}</span></a>
    				                                      {/if}
                                                      {/if}
                                                {/if}
                                                </div>
											</td>
										</tr>
									</table>
                                    {*{/if}*}
								</td>
							</tr>
						</table>


{if $MODULE eq 'Products'}
<script language="JavaScript" type="text/javascript" src="include/js/modules/Products/Productsslide.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript">Carousel();</script>
{/if}
<input type="hidden" name="num_rows_account_detail_sms" id="num_rows_account_detail_sms" value="{$num_rows_account_detail_sms}"/>
<input type="hidden" name="num_rows_contact_detail_sms" id="num_rows_contact_detail_sms" value="{$num_rows_contact_detail_sms}"/>
{if $MODULE eq 'Accounts' || $MODULE eq 'Contacts'}
    <!--
    更新操作
    edit:cdw
    date:20131119
    reason:客户详细界面群发短信功能改进
    -->
    {if $MODULE eq 'Accounts'}
    <div id="SMSedit" class="full-menu" style="position: absolute;  z-index: 9999999; width: 300px; left: 575px; top: 484px;display:none;">
    {elseif $MODULE eq 'Contacts'}
    <div id="SMSedit" class="full-menu" style="position: absolute;  z-index: 9999999; width: 300px; left: 575px; top: 344px;display:none;">
    {/if}
   
    </div>
{/if}
<input type="hidden" name="num_rows_account_detail_email" id="num_rows_account_detail_email" value="{$num_rows_account_detail_email}"/>
<input type="hidden" name="num_rows_contact_detail_email" id="num_rows_contact_detail_email" value="{$num_rows_contact_detail_email}"/>
{if $MODULE eq 'Accounts' || $MODULE eq 'Contacts'}
  
    {if $MODULE eq 'Accounts'}
    <div id="Emailedit" class="full-menu" style="position: absolute;  z-index: 9999999; width: 300px; left: 575px; top: 484px;display:none;">
    {elseif $MODULE eq 'Contacts'}
    <div id="Emailedit" class="full-menu" style="position: absolute;  z-index: 9999999; width: 300px; left: 575px; top: 344px;display:none;">
    {/if}                            
    
    </div>
{/if}

<script>

function getTagCloud()
{ldelim}

	var obj = $("tagfields");
	if(obj != null && typeof(obj) != undefined) {ldelim}
		new Ajax.Request(
		    'index.php',
			{ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
			method: 'post',
			postBody: 'module={$MODULE}&action={$MODULE}Ajax&file=TagCloud&ajxaction=GETTAGCLOUD&recordid={$ID}',
			onComplete: function(response) {ldelim}
                                $("tagfields").innerHTML=response.responseText;
                                $("txtbox_tagfields").value ='';
                        {rdelim}
			{rdelim}
		);
	{rdelim}
{rdelim}
getTagCloud();
</script>
<!-- added for validation -->
<script language="javascript">
  var fieldname = new Array({$VALIDATION_DATA_FIELDNAME});
  var fieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL});
  var fielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE});
</script>
</td>
	<td align=right valign=top><img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}"></td>
</tr>
</table>
<!--End Contents-->