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
 <!--修改编码格式:统一编码：UTF-8-->
-->*}
{if $VERSION_ACCOUNT eq 'langjie'}
    <link rel="stylesheet" href="{$CSSURL}themes/softed/langjieEmail.css" type="text/css" />
{/if}
<div class="clear"></div>
<div id="sendEmailDetail" style="height: 760px;">

    <div class="emailBtnlist send_ListViewContents" id="send_ListViewContents">
        <div class="emailBtn"">
        <ul class="ulbtn" style="margin-right: 15px;">
            <li>
                <span class="ld-button ld-button-primary" onclick="{if $EMAILPAGETYPE eq 'pop' }window.close(); {else}EmailContent_Back(){/if}">返回</span>
            </li>
            <li>
                <span class="ld-button ld-button-primary" onclick="openEmailTemplates(this)">选择邮件模板</span>
            </li>

            <li>
                <span class="ld-button ld-button-primary" onclick="email_validate(this.form,'send')">发送</span>
            </li>
        </ul>
    </div>
</div>
<div class="clear"></div>
<div class="emialList" style="margin-top: -1px !important;border-top: 1px solid #ddeaf7;">
    <div class="emailDetailDiv">
        <table cellspacing="0" border="0" cellpadding="0" width="100%" class="listEntries fir-center emailsendtable">
            <tr>
                <td height="24" valign="middle" align="right" class="sendlableleft">
                    发件人
                </td>
                <td height="24" valign="middle" style="word-break:break-all;background-color: #eff5fb;">
                    <div class="emailuserbtn">
                        <select name="from_email" class="ld-select-inner width200" >
                            {foreach key=labelval item=selectval from=$MAILACCOUNT}
                                {if $selectval.popuser eq $MFROM}
                                    {assign var=selectmodule value="selected"}
                                {else}
                                    {assign var=selectmodule value=""}
                                {/if}

                                <option value="{$selectval.account_id}" {$selectmodule}>{$selectval.popuser}</option>
                            {/foreach}
                        </select>
                    </div>
                </td>
            </tr>
            <tr>
                <td height="24" valign="middle" align="right" class="sendlableleft">
                    收件人
                </td>
                {*  //朗捷记住email地址*}
                {if $VERSION_ACCOUNT eq 'langjie' and $fromModule eq 'CustomForm22'}
                    <td height="24" valign="middle"  id="mtoTd" style="word-break:break-all;background-color: #eff5fb;" >
                        <input type="text" name="mto" class="ld-input-inner" value="{$EMAILADDRESS}">
                    </td>
                {else}
                    <td height="24" valign="middle" style="word-break:break-all;background-color: #eff5fb;" >
                        <input type="text" name="mto" class="ld-input-inner" value="{$MTO}">
                        <i style="display:none">
                            <select class="E_sel_pro btn-radius-system" name="parent_type">
                                <option value="Contacts">联系人</option>
                                <option value="Accounts">客户</option>
                                <option value="Users">成员管理</option>
                            </select>
                            <a href="javascript:;" class="icon-homeimg icon-add"></a>
                            <a href="javascript:;" class="icon-homeimg icon-clear inpb-reset" style="padding-bottom: 4px;"></a>
                        </i>
                    </td>
                {/if}
            </tr>
            <tr>
                <td height="24" valign="middle" align="right" class="sendlableleft">
                    抄送
                </td>
                <td height="24" valign="middle" style="word-break:break-all;background-color: #eff5fb;">
                    <input type="text" name="mcc" value="{$MCC}" class="ld-input-inner">
                    <i style="display:none">
                        <select class="E_sel_pro btn-radius-system"  name="parent_type">
                            <option value="Contacts">联系人</option>
                            <option value="Accounts">客户</option>
                            <option value="Users">成员管理</option>
                        </select>
                        <a href="javascript:;" class="icon-homeimg icon-add"></a>
                        <a href="javascript:;" class="icon-homeimg icon-clear inpb-reset" style="padding-bottom: 4px;"></a>
                    </i>
                </td>
            </tr>
            <tr style="display:none">
                <td height="24" valign="middle" align="right" class="sendlableleft">
                    密送
                </td>
                <td height="24" valign="middle" style="word-break:break-all;background-color: #eff5fb;">
                    <input type="text" name="" class="ld-input-inner">
                </td>
            </tr>
            <tr>
                <td height="24" valign="middle" align="right" class="sendlableleft">
                    主题
                </td>
                <td height="24" valign="middle" style="word-break:break-all;background-color: #eff5fb;">
                    <input type="text" name="subject" value="{$SUBJECT}" class="ld-input-inner">
                </td>
            </tr>
            <tr>
                <td height="24" valign="middle" align="right"class="sendlableleft">
                    附件

                </td>
                <td height="24" valign="middle" style="word-break:break-all;background-color: #eff5fb;">
                    <div name="multiple_att" class="wu-example"></div>
                </td>
            </tr>
            <tr>
                <td height="24" valign="middle" align="right" class="sendlableleft">
                    正文
                </td>
                <td height="24" valign="middle" style="word-break:break-all;background-color: #eff5fb;">
                    <script id="description1" name="description1" type="text/plain" class="edui-default" style="background-color:#E8E8E8; height:350px; width: 100%;">
    
                                 {$CONTENT} {$MBODY}
                            </script>
                    <script type="text/javascript">
                        var descriptionEditor = UE.getEditor('description1');
                    </script>

                </td>
            </tr>
        </table>
    </div>
</div>
</div>


</div>

<script type="text/javascript">
    AjaxJSPage('webuploader_js','include/js/webuploader.js');
    var special_ins = "{'Up_to_six_the_number_of_files'|@getFixedLabel}";//附件最多上传文件数量标签
    var emailpagetype='{$EMAILPAGETYPE}';
    var attachmentinfo='{$ATTACHMENTINFO}';

    {literal}
    global_flash_fileattachmentphp='index.php?module=Emails&action=EmailsAjax&file=File_Upload';
    global_flash_delfileattachmentphp='index.php?module=Emails&action=EmailsAjax&file=File_DelUpload';
    // @edit:dong @date:2020/7/8 @reason: 调用上传需要先创建弹出层对象 否则获取不到module  divid报错
    var  emailpopupobj=new CrmPopup();
    emailpopupobj.frommodule='Emails';
    emailpopupobj.divid='sendEmailDetail';
    CrmPopup.global_listPopupObj.push(emailpopupobj);
    emailpopupobj.filejsondata = [];

    ld("#sendEmailDetail").parent("div").parent("section").parent("section").parent("section").closest('body').css("overflow","hidden");//BUG0069322 xxy 2023-7-14 邮件管理界面，无法上下滑动界面
    ld("#sendEmailDetail").parent("div").parent("section").parent("section").parent("section").closest('body').css("cursor","default");
    ld("#sendEmailDetail").parent("div").css("overflow","auto");

    ld(function () {
        //渲染容器
        ld("[name=multiple_att").powerWebUpload({
            fileTypeDuplicate:'yes',	//附件类型判断
            fileNameDuplicate:'yes',	//同名附件判断
            mode:'',	//当前单据 create or edit
            module:'',	//当前模块
            jsonData:attachmentinfo,	//edit data,编辑界面显示已上传的附件
            record:'',	//单据单据id
            admin:'',//是否是管理员
            uitype:'',
            supportformat:'',//支持格式
            inputFileName:'groupemail',	//选择附件后赋值标签的name
            fileNumLimit:1000,
            special_ins:''
        });
    })

    // <!--将select的值赋给input框-->
    function mtoSelectChange(obj) {
        var selectValue=ld(obj).val();
        ld("#mto").val(selectValue)
    }

    function email_validate(oform,mode){

        if(trim(mode) == '')
        {
            return false;
        }
        if(ld("[name=from_email]").val()<=0){
            var confirm_str = arrJsPopLabel['SENDERCANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
        //oform.mode.value=mode;//设置邮件是否保存还是发送
        var toemail=ld("[name=mto]").val();//接收人

        if(toemail.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
        {
            var confirm_str = arrJsPopLabel['THERECOPIENTEMAILCANNOTBEEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }

        //发送
        var content=descriptionEditor.getContent();//发送内容
        var subject=ld("[name=subject]").val();//主题
        var mcc=ld("[name=mcc]").val();//抄送
        var mailaccountid=ld("[name=from_email]").val();//发件人邮箱账号id

        var url="index.php?module=Emails&action=EmailsAjax&file=savewritemail&subject="+encodeURIComponent(subject)+"&toemail="+toemail+"&mailaccountid="+mailaccountid+"&mcc="+mcc;
        var divid=emailpopupobj.divid;
        var fieldname='groupemail';
        var tmpfilenum=0;

        for(var k=1;k<60;k++)
        {
            if(CrmPopup.isExistsObj(divid,fieldname+"-file_name_"+k))
            {
                url+="&"+fieldname+"-file_name_"+k+"="+encodeURIComponent(CrmPopup.getHtmlobjval(divid,fieldname+"-file_name_"+k));
                url+="&"+fieldname+"-file_type_"+k+"="+CrmPopup.getHtmlobjval(divid,fieldname+"-file_type_"+k);
                url+="&"+fieldname+"-file_size_"+k+"="+CrmPopup.getHtmlobjval(divid,fieldname+"-file_size_"+k);
                url+="&"+fieldname+"-file_path_"+k+"="+CrmPopup.getHtmlobjval(divid,fieldname+"-file_path_"+k);
                tmpfilenum++;
            }

        }
        url+="&"+fieldname+"-file_num="+tmpfilenum;
        ld.ajax({
            url: url,
            type: 'POST',
            data:{"content": content, "namenameage": 18},
            dataType:'json',
            async: false,//
            timeout: 10000,

            success: function(data)
            {
                if(data.code==1)
                {

                    if(emailpagetype=='pop')
                    {
                        // @edit:dong @date:2020/08/27 @reason: 发送成功后 弹出提示框
                        MessagePopup.TipOne_success (arrJsPopLabel['SENDSUCCESSFULLY']);
                        //确定按钮
                        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                            window.close();
                        })

                    }
                    else
                    {
                        MessagePopup.TipOne_success (arrJsPopLabel['SENDSUCCESSFULLY']);
                        getsendlist(document.getElementById("leftsend"));
                    }

                }
                else
                {
                    alert(data.result.msg);
                }
            }
        });

    }
    function findAngleBracket(mailadd)
    {
        var strlen = mailadd.length;
        if (mailadd.indexOf('<')>0)
        {
            var num =mailadd.indexOf("<")
            ret = mailadd.substr(0, num);
        }
        else
        {
            ret = mailadd;
        }
        var filter  = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        if (filter.test(ret))
        {

            return true;
        }
        else
        {
            return false;
        }
    }





    function openEmailTemplates(obj){

        var crmPopupobj=CreatePagePopup.load("","","","LdPopWidth950px",'Emails',"","","","");
        crmPopupobj.prevshow();
        ld.ajax({
            url: 'index.php?module=Users&action=UsersAjax&file=lookupemailtemplates',
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,//
            timeout: 5000,
            success: function(data)
            {
                if(data.code==1)
                {
                    crmPopupobj.setParams(data.result.title,'',"","LdPopWidth950px",'Emails',"","","","");
                    crmPopupobj.quickcreatehtml=data.result.content;
                    crmPopupobj.show(data.result.content);
                }
            }
        })
        return false;
    }
    function submittemplate(templateid)
    {


        if(templateid > 0){
            ldAjaxNoProgress("index.php?module=Users&action=UsersAjax&file=TemplateMerge&templateid="+templateid,{},function(data){
                //edit:can 20210422 45446: （https://61mis.com/kfbcrm [^]）在邮件管理中发送邮件时选择邮件模板，选择完之后页面没有跳转依旧会停留在选择的页面
                // document.getElementById('description1').value = data.result.content;
                descriptionEditor.setContent(data.result.content);
                //  javascript:hideOptions('emailTemplatesDiv');
                cancelCrmPopup();
            })
            /*new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                method: 'post',
                postBody:"module=Users&action=UsersAjax&file=TemplateMerge&templateid="+templateid,
                onComplete: function(response) {

                    if(response.responseText.indexOf('###SUCCESS###') > -1){
                        var results=response.responseText.split('###SUCCESS###');

                    ///	document.getElementById('description1').value = results[1];
                        descriptionEditor.setContent(results[1]);
                    //	javascript:hideOptions('emailTemplatesDiv');
                        cancelCrmPopup();
                    }
                }
            });*/

        }
    }

    {/literal}


</script> 