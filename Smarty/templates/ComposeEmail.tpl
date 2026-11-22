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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset={$APP.LBL_CHARSET}"/>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<title>{'COMPOSENEWMESSAGE'|@getFixedLabel}</title>
<!-- diony_ico 2012-12-03   
<link REL="SHORTCUT ICON" HREF="include/images/lingdangcrm_icon.ico">	
-->
<style type="text/css">@import url("{$CSSURL}themes/{$THEME}/style.css");</style>
<style type="text/css">@import url("{$CSSURL}themes/{$THEME}/popup.css");</style>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
	<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery-ui.min.js"></script>
	<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
 <script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script><!--文本区域自动增高-->
 	<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.config.js"></script><!--编辑器-->
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.all.js"></script>
    <script type="text/javascript" src="include/js/RichKinde.js"></script><!--很早以前的编辑器，这个不需要-->
    <script type="text/javascript" src="{$JSURL}include/js/select2.min.js"></script><!--多选框-->
    <script type="text/javascript" src="{$JSURL}include/js/MsgPopup.js"></script><!--弹出层提示-->
<script type="text/javascript" language="JavaScript">
	var ld = $;
	var global_js_url='{$JSURL}';
</script>

<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js"></script>
<script src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/scriptaculous.js" type="text/javascript"></script>
<script src="{$JSURL}include/js/general.js" type="text/javascript"></script>

<script type="text/javascript" src="{$JSURL}modules/Products/multifile.js"></script>
 <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CommonPagePopup.js"></script><!--拖拽效果-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupDrag.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/QcPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PageRecordPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupLayer.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/MassEditPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CreatePagePopup.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupUserGroup.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopupWindows.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/SaveDataRecord.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchField.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/webuploader/webuploader.js"></script><!--附件上传-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/webuploader.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js"></script><!--编辑-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/ComboxPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/cls_picklist.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/MsgPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/en.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<style type="text/css">@import url("themes/{$THEME}/global.css");</style>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.config.js"></script>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.all.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/Mail.js"></script>
</head>
<body marginheight="0" marginwidth="0" topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
{literal}
<form name="EditView" method="POST" ENCTYPE="multipart/form-data" action="index.php" onSubmit="if(email_validate(this.form,'')) { puyoungJS_DialogBox.block();} else { return false; }">
{/literal}
<input type="hidden" name="send_mail" >
<input type="hidden" name="contact_id" value="{$CONTACT_ID}">
<input type="hidden" name="user_id" value="{$USER_ID}">
<input type="hidden" name="filename" value="{$FILENAME}">
<input type="hidden" name="old_id" value="{$OLD_ID}">
<input type="hidden" name="module" value="{$MODULE}">
<input type="hidden" name="record" value="{$ID}">
<input type="hidden" name="mode" value="{$MODE}">
<input type="hidden" name="action">
<input type="hidden" name="popupaction" value="create">
<input type="hidden" name="hidden_toid" id="hidden_toid">
<input type="hidden" name="printid" id="printid" value="{$PRINTID}">

<div class="WriteEmailHeader" align="center">{'COMPOSENEWMESSAGE'|@getFixedLabel}</div>
<table border="0" class="writEmailTab" cellpadding="0" cellspacing="1" width="100%">
<tbody>

        <tr>
            <td align="right" width="70">{'Sender'|@getFixedLabel}</td>
            <td>
            <!--<input type=hidden name="from_mail" value="{$FROM_EMAIL}"/>-->
            <select name="from_email" class="Tnputselect">
    			{foreach key=labelval item=selectval from=$FROMALLMAIL}
    				{if $selectval eq selected}
    					{assign var=selectmodule value="selected"}
    				{else}
    					{assign var=selectmodule value=""}
    				{/if}               
    				<option value="{$labelval}" {$selectmodule}>{$labelval}</option>
    			{/foreach}
    		</select>
            </td>
        </tr> 
    

       <tr>
    	<td align="right"><font color="red">*</font>{'ADDRESSEE'|@getFixedLabel}</td>
    	<td>
     		<input name="{$elements.2.0}" id="{$elements.2.0}" type="hidden" value="{$IDLISTS}"/>
    		<input type="hidden" name="saved_toid" value="{$TO_MAIL}"/>
    		<!--
            更新操作
            edit：cdw
            date：20131202
            reason：手机、Email、QQ类型字段在查看明细界面时改进
            -->
        <div style="float: left;width:47%">
          <input id="parent_name" name="parent_name"type="text" value="{$TO_MAIL}{$allinfo}"  class="Tnputselect" style="width: 100%;"/>
        </div>
        <div style="float: left;margin-left: 10px;">
          <div style="float: left;margin-top:2px;">
        		<select name="parent_type" class="Tnputselect">
        			{foreach key=labelval item=selectval from=$elements.1.0}
        				{if $selectval eq selected}
        					{assign var=selectmodule value="selected"}
        				{else}
        					{assign var=selectmodule value=""}
        				{/if}
                        <!--BY LD KEVIN 修改bug3292-->
                        {if $labelval neq 'Vendors'}                
        				<option value="{$labelval}" {$selectmodule}>{$labelval|@getTranstab}</option>
                        {/if}
        			{/foreach}
        		</select>
          </div> 
          <div style="float: left;margin-top:4px;">
    			<a class="icon-homeimg icon-select" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" onclick='selModulePopup();'></a>
        		<a class="icon-homeimg icon-clear" href="javascript:;"  title="{'CLEAR'|@getFixedLabel}" onclick="$('parent_id').value=''; $('hidden_toid').value='';$('parent_name').value=''; return false;"></a>
          </div>
    	  </div>
    	</td>
       </tr>
    	<tr>
    	{if 'ccmail'|@emails_checkFieldVisiblityPermission:'readwrite' eq '0'}   
           	<td align="right">{'CC'|@getFixedLabel}</td>
        	<td>
        		<input name="ccmail" id ="cc_name" type="text" value="{$CC_MAIL}" class="Tnputselect" style="width:47%"/>
        	</td>
    	{else}
    		<td>&nbsp;</td>
    		<td>&nbsp;</td>
    	{/if}
       	</tr>
       {if 'bccmail'|@emails_checkFieldVisiblityPermission:'readwrite' eq '0'}   
       	<tr>
    	<td align="right">{'BCC'|@getFixedLabel}</td>
    	<td >
    		<input name="bccmail" id="bcc_name" type="text" value="{$BCC_MAIL}" class="Tnputselect" style="width:47%"/>
    	</td>
       	</tr>
       	{/if}
        
	
   <tr>
	<td align="right" nowrap><font color="red">*</font>{"Theme"|getFixedLabel}</td>
        {if $WEBMAIL eq 'true' or $RET_ERROR eq 1}
                <td><input type="text" name="subject" value="{$SUBJECT}" id="{$elements.2.0}" class="Tnputselect" style="width:47%"/></td>
        {else}
                <td><input type="text" name="subject" value="{$elements.3.0}" id="{$elements.2.0}" class="Tnputselect" style="width:47%"/></td>
        {/if}
   </tr>

   <tr>
	<td align="right" nowrap>{$elements.1.0}</td>
	<td>
		<!--<input name="{$elements.2.0}"  type="file" class="small txtBox" value="" size="78"/>-->
		<input name="del_file_list" type="hidden" value=""/>
        <div id="files_list" >
			
            <input id="my_file_element" class="Tnputselect" type="file" name="{$elements.2.0}" onchange="validateFilename(this);validateFileSize(this,'{$UPLOAD_MAXSIZE}')"  >  
			<input type="hidden" name="{$elements.2.0}_hidden" value="" />
            {*<span id="limitmsg" style= "color:red; display:'';">{'MAXFILESSIX'|@getFixedLabel}{'MAXUPLOADSIZE'|@getFixedLabel} {$UPLOADSIZE} MB</span>*}
			<p></p>
			{if $smarty.request.attachment != ''}
				<div>
					{$ATTACHMENT}
				</div>
			{/if}
    	</div>
   
        <script>
			var multi_selector = new MultiSelector( document.getElementById( 'files_list' ), 6 );
			multi_selector.count = 0
			multi_selector.addElement( document.getElementById( 'my_file_element' ) );
		</script>
                 
		<div id="attach_temp_cont" style="display:none;">
		<table width="100% ">
		
	{if $smarty.request.attachment != ''}
             <tr><td width="100%" colspan="2">{$smarty.request.attachment|@vtlib_purify}<input type="hidden" value="{$smarty.request.attachment|@vtlib_purify}" name="pdf_attachment"></td></tr>                                                                                                                                                                                      {else}   

		{foreach item="attach_files" key="attach_id" from=$elements.3}	
			<tr id="row_{$attach_id}">
                <td width="90%">{$attach_files}</td>
                <td><img src="{'no.gif'|@lingdang_imageurl:$THEME}" onclick="delAttachments({$attach_id})" alt="{$APP.LBL_DELETE_BUTTON}" title="{$APP.LBL_DELETE_BUTTON}" style="cursor:pointer;"/></td>
            </tr>	
		{/foreach}
		<input type='hidden' name='att_id_list' value='{$ATT_ID_LIST}' />
	{/if}

		{if $WEBMAIL eq 'true'}
		{foreach item="attach_files" from=$webmail_attachments}
                <tr ><td width="90%">{$attach_files}</td></tr>
        {/foreach}	
		{/if}
		</table>	
		</div>	
		{$elements.3.0}
        <div id="attach_cont" class="addEventInnerBox" style="display:none;overflow:auto;height:100px;width:100%;position:relative;left:0px;top:0px;">
        </div>
	</td>
   </tr>
   	
   
	

    <tr>
        <td align="right">{'Content'|@getFixedLabel}</td>
    	<td>
            {if $WEBMAIL eq 'true' or $RET_ERROR eq 1}
        		<input type="hidden" name="from_add" value="{$from_add}"/>
        		<input type="hidden" name="att_module" value="Webmails"/>
        		<input type="hidden" name="mailid" value="{$mailid}"/>
        		<input type="hidden" name="mailbox" value="{$mailbox}"/>
            
                <script id="description1" name="description1" type="text/plain" style="width:730px;height:200px;">{$DESCRIPTION}</script>
            {else}
                <script id="description1" name="description1" type="text/plain" style="width:730px;height:200px;">{$elements.3.0}</script>
            {/if}
            <script type="text/javascript">
           
                var bodyEditor = UE.getEditor('description1');
            </script>
    	</td>
       </tr>
   <tr>
	<td colspan="2" align="center">
		<input class="editauto" onclick="openEmailTemplates(this)" type="button" name="button" value="{'SELECTEMAILTEMPLATE'|@getFixedLabel}"/>
		<input class="editauto" onclick="return email_validate(this.form,'save');" type="button" name="button" value="{'SAVE'|@getFixedLabel}" />
		<input name="{'SEND'|@getFixedLabel}" value="{'SEND'|@getFixedLabel}" class="editauto" type="button" onclick="return email_validate(this.form,'send');"/>
		<input name="{'CANCEL'|@getFixedLabel}" value="{'CANCEL'|@getFixedLabel}" class="cancelauto" type="button" onclick="window.close()"/>
	</td>
   </tr>
</tbody>
</table>
</form>
<!--邮件模板，弹出框-->
</body>
<div id="emailTemplatesDiv" class="D_pop_box LdPopWidth600px" style="display:none;">		
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'EMAILTEMPLATES'|@getFixedLabel}</strong>
        <a href="javascript:hideOptions('emailTemplatesDiv');puyoungJS_DialogBox.unblock();" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    <div style="width: 100%;height:200px;overflow-y:auto;">
	<table id="emailTemplatesTable" class="D_pop_bod listEntries" cellspacing="1" cellpadding="1" border="0">
    </table>
    </div>
</div>
<script>
var cc_err_msg = '{'CCEMAILERROR'|@getFixedLabel}';
var no_rcpts_err_msg = '{$MOD.LBL_NO_RCPTS_EMAIL_ERROR}';
var bcc_err_msg = '{'BCCEMAILERROR'|@getFixedLabel}';
{literal}
var issubmit = 1;
function submittemplate(templateid)
{    
    
    new Ajax.Request(
    	'index.php',
        {queue: {position: 'end', scope: 'command'},
        method: 'post',
        postBody:"module=Users&action=UsersAjax&file=TemplateMerge&templateid="+templateid,
        onComplete: function(response) {
            if(response.responseText.indexOf('###SUCCESS###') > -1){
    			var results=response.responseText.split('###SUCCESS###');
                //document.getElementById('description1').value = results[1];
                bodyEditor.setContent(results[1]);
                //javascript:hideOptions('emailTemplatesDiv');
				puyoungJS_DialogBox.unblock();
				cancelCrmPopup();
    		}
 	    }
    });
}
function email_validate(oform,mode)
{
 
	if(trim(mode) == '')
	{
		return false;
	}
	if(oform.parent_name.value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
	{
        var confirm_str = arrJsPopLabel['THERECOPIENTEMAILCANNOTBEEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	//Changes made to fix tickets #4633, # 5111 to accomodate all possible email formats
	var email_regex = /^[a-zA-Z0-9]+([\_\-\.]*[a-zA-Z0-9]+[\_\-]?)*@[a-zA-Z0-9]+([\_\-]?[a-zA-Z0-9]+)*\.+([\_\-]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)*$/;
	
	if(document.EditView.ccmail != null){
		if(document.EditView.ccmail.value.length >= 1){
			var str = document.EditView.ccmail.value;
            arr = new Array();
            arr = str.split(",");
            var tmp;
	    	for(var i=0; i<=arr.length-1; i++){
	            tmp = arr[i];
	            if(tmp.match('<') && tmp.match('>')) {
                    if(!findAngleBracket(arr[i])) {
                        var confirm_str = cc_err_msg+": "+arr[i];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                    }
            	}
				else if(trim(arr[i]) != "" && !(email_regex.test(trim(arr[i]))))
	            {
                        var confirm_str = cc_err_msg+": "+arr[i];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
	                    return false;
	            }
			}
		}
	}	
	if(document.EditView.bccmail != null){
		if(document.EditView.bccmail.value.length >= 1){
			var str = document.EditView.bccmail.value;
			arr = new Array();
			arr = str.split(",");
			var tmp;
			for(var i=0; i<=arr.length-1; i++){
				tmp = arr[i];
				if(tmp.match('<') && tmp.match('>')) {
                    if(!findAngleBracket(arr[i])) {
                        var confirm_str = bcc_err_msg+": "+arr[i];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                    }
            	} 
            	else if(trim(arr[i]) != "" && !(email_regex.test(trim(arr[i])))){
                    var confirm_str = bcc_err_msg+": "+arr[i];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					return false;	
				}
			}	
		}
	}	
	if(oform.subject.value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
	{
		/*if(email_sub = prompt('你没有为这个电子邮件指定主题，如果您想提供一个，请先输入。','(无主题)'))
		{
			oform.subject.value = email_sub;
		}else
		{
			return false;
		}*/
        var confirm_str = arrJsPopLabel['THEMESCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);      
        oform.subject.focus();
        return false;
	}
   
	if(mode == 'send')
	{
	 
		server_check()	
	}else if(mode == 'save')
	{
		if(issubmit != 1) return false;
		issubmit = 2;
		oform.action.value='Save';
		oform.submit();
	}else
	{
		return false;
	}
}
//function to extract the mailaddress inside < > symbols.......for the bug fix #3752
function findAngleBracket(mailadd)
{
        var strlen = mailadd.length;
        var success = 0;
        var gt = 0;
        var lt = 0;
        var ret = '';
        for(i=0;i<strlen;i++){
                if(mailadd.charAt(i) == '<' && gt == 0){
                        lt = 1;
                }
                if(mailadd.charAt(i) == '>' && lt == 1){
                        gt = 1;
                }
                if(mailadd.charAt(i) != '<' && lt == 1 && gt == 0)
                        ret = ret + mailadd.charAt(i);

        }
        if(/^[a-z0-9]([a-z0-9_\-\.]*)@([a-z0-9_\-\.]*)(\.[a-z]{2,3}(\.[a-z]{2}){0,2})$/.test(ret)){
                return true;
        }
        else
                return false;

}
function server_check()
{
	var oform = window.document.EditView;
	ldAjaxHtmlNoProgress('index.php',"module=Emails&action=EmailsAjax&file=Save&ajax=true&server_check=true",function (ajaxhtml) {
		if(ajaxhtml.indexOf('SUCCESS') > -1)
		{
			oform.send_mail.value='true';
			oform.action.value='Save';
			oform.submit();
		}else
		{

			$errors=ajaxhtml.split('$$FAILURE$$');
			RemindsMsg("","LdPopWidth400px","","yes","",$errors[1]);
			return false;
		}
	});
}
$('attach_cont').innerHTML = $('attach_temp_cont').innerHTML;
function delAttachments(id)
{
    new Ajax.Request(
        'index.php',
        {queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: 'module=Contacts&action=ContactsAjax&file=DelImage&attachmodule=Emails&recordid='+id,
            onComplete: function(response)
            {
		Effect.Fade('row_'+id);	                
            }
        }
    );

}
{/literal}
</script>

</html>