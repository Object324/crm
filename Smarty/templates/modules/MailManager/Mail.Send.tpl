<!--*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************** -->
<!--修改编码格式:统一编码：UTF-8-->
<form action="javascript:void(0)" method="POST" id="_mail_replyfrm_" ENCTYPE="multipart/form-data" name='submit'>

<div class="WriteEmailHeader" style="font-size:14px;" id="send_mail_fldrname" name="send_mail_fldrname">
    {'COMPOSENEWMESSAGE'|@getFixedLabel}
    <span><a href="javascript:void(0);" onclick="MailManager.mail_reply_close();" >&#171; &nbsp;{'RETURN'|@getFixedLabel}</a></span>
</div>
<div id="send_email_con" name="send_email_con">
    <div id="_popupsearch_" style="display:none;position:absolute;width:500px;z-index:80000;"></div>
        <input type="hidden" name="emailid" class="detailedViewTextBox" id="emailid"/>
        <input type="hidden" name="docids" class="detailedViewTextBox" id="docids"/>
        <input type="hidden" name="attachmentCount" class="detailedViewTextBox" id="attachmentCount"/>
        
{strip}
        <table class="writEmailTab" width="100%" cellpadding="1" cellspacing="1" border="0">
            <tr>
                <td align="right" width="70">{'ADDRESSEE'|@getFixedLabel}</td>
                <td>
                    <input type="text" name="to" id="_mail_replyfrm_to_" class="Tnputselect"/>
                    <input type="hidden" name="linkto"/>

                    <a class="icon-homeimg icon-select" href="javascript:;" id='_mail_replyfrm_popup_to_' onclick="MailManager.search_popupui('_mail_replyfrm_to_', '_mail_replyfrm_popup_to_');"></a>
                    <a class="icon-homeimg icon-clear" href="javascript:;" onclick="MailManager.clear_input('_mail_replyfrm_to_');" ></a>
                </td>
            </tr>
            <tr>
                <td  align="right">{'CC'|@getFixedLabel}:</td>
                <td>
                    <input type="text" name="cc" id="_mail_replyfrm_cc_" class="Tnputselect" style="width:47%;">

                    <a class="icon-homeimg icon-select" href="javascript:;" id='_mail_replyfrm_popup_cc_' onclick="MailManager.search_popupui('_mail_replyfrm_cc_', '_mail_replyfrm_popup_cc_');"></a>
                    <a class="icon-homeimg icon-clear" href="javascript:;" onclick="MailManager.clear_input('_mail_replyfrm_cc_');" ></a>
                </td>
            </tr>
            <tr>
                <td  align="right" >{'BCC'|@getFixedLabel}:</td>
                <td>
                    <input type="text" name="bcc" id="_mail_replyfrm_bcc_" class="Tnputselect" style="width:47%;"/>

                    <a class="icon-homeimg icon-select" href="javascript:;" id='_mail_replyfrm_popup_bcc_'  onclick="MailManager.search_popupui('_mail_replyfrm_bcc_', '_mail_replyfrm_popup_bcc_');"></a>
                    <a class="icon-homeimg icon-clear" href="javascript:;"  onclick="MailManager.clear_input('_mail_replyfrm_bcc_');" ></a>
                </td>
            </tr>
            <tr>
                <td align="right">{'Theme'|@getFixedLabel}:</td>
                <td>
                    <input type="text" name="subject" id="_mail_replyfrm_subject_" class="Tnputselect" style="width:47%;"/>
                </td>
            </tr>

            <tr>
                <td align="right">
                    {'Attachment'|getFixedLabel}
                </td>
                <td>
                    <div id="file-uploader"></div>
                    <div id="file_list"></div>
                    &nbsp;&nbsp;<input type="button" onclick="MailManager.getDocuments();" class="editauto" value="{'SELECT'|@getFixedLabel} {'Attachment'|@getFixedLabel}"/>
                </td>
                
            </tr>
            <tr>
                <td align="right">
                    {'Content'|getFixedLabel}
                </td>
                <td>
                    <script id="_mail_replyfrm_body_" name="body" style="width:730px;height:150px;"></script>
                </td>
            </tr>
            <tr>
                <td colspan="2" align="center">
                    <input type="button" class="editauto" onclick="MailManager.mail_reply_send(this.form);" value="{'SEND'|@getFixedLabel}"/>&nbsp;
                    <input type="button" class="editauto" onclick="MailManager.save_draft(this.form)" value="{'SAVE'|@getFixedLabel}"/>&nbsp;
                    <input type="button" class="editauto" onclick="window.open('index.php?module=MailManager&action=PopupMailManagerTemplate&subject_id=_mail_replyfrm_subject_&body_id=_mail_replyfrm_body_','emailtemplate','top=100,left=200,height=400,width=500,resizable=yes,scrollbars=yes,menubar=no,addressbar=no,status=yes');"
		                    value="{'SELECTEMAILTEMPLATE'|@getFixedLabel}"/>&nbsp;
                    <input type="button" class="editauto" onclick="MailManager.mail_reply_close();" value="{'CANCEL'|@getFixedLabel}"/>
                </td>
            </tr>
        </table>

    </form>
{/strip}
</div>

<div id="emailcontent"></div>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.config.js"></script>
    <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.all.js"></script>
<script>
{literal}
var bodyEditor = '';
/**
 * 该处初始化编辑器代码会执行两次，但并非刷新页面执行，很像是循环引入
 * 或者其他所以会加载编辑器两次，在IE浏览器下，会出现两个编辑器，但都
 * 不完整。此处添加一个isbodyeditor变量，并用问好表达式区分两次加载，
 * 防止重复赋值，在第二次加载的时候加载编辑器，则IE下编辑器加载正常
 * @author Tujt 2014-12-16
 */
var isbodyeditor = (isbodyeditor > 0)?isbodyeditor:0;
if(document.getElementById('_mail_replyfrm_body_')!=undefined){
	if(isbodyeditor == 1){
		bodyEditor = UE.getEditor('_mail_replyfrm_body_');
	}
	isbodyeditor ++;
}
    
{/literal}
</script>