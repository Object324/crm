

<script type="text/javascript" src="{$JSURL}include/js/modules/Products/multifile.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script src="{$JSURL}include/js/general.js" type="text/javascript"></script>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.config.js"></script>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.all.js"></script>


{literal}
<form name="EditView" method="POST" ENCTYPE="multipart/form-data" action="index.php">
{/literal}
    <input type="hidden" id="viewname" value="{$VIEWID}"/>
    <input type="hidden" id="is_admin" value="{$IS_ADMIN}"/>
    <input type="hidden" name="send_mail">
    <input type="hidden" name="module" value="{$MODULE}">
    <input type="hidden" name="action" value=''>
    <input type="hidden" name="return_module" value="{$RETURN_MODULE}"/>
   
    <input type="hidden" name="parenttab" id="parenttab" value="{$PARENTTAB}" />
    <input type="hidden" name="accountid_chose" id="accountid_chose" value=""/>
    <input type="hidden" name="row_of_checkbox_account_groupemail" id="row_of_checkbox_account_groupemail" value="{$num_rows}"/>
    <input type="hidden" name="" id="" value=""/>
	 <input type="hidden" name="curmodule" id="curmodule" value="{$MODULE}">
   
    <div class="E_sms" id="ListViewContents">
        
        <div class="clear"></div>
        
        <!--主题内容开始-->
        <div class="E_emailCotent">
            <div class="E_usage_tips">
                <div class="top_tit">
                    <span>{'Usage_Tips'|@getFixedLabel}</span>
                </div>
                <ul class="E_ut_area">
                    
                    <li>{'Email_standard_format_recipient'|@getFixedLabel}<br />
                    <span>Mrzhang@126.com&lt;张先生&gt; 或Mrzhang@126.com</span></li>
                   
                    <li>{'Bulk_mail_newline_interval_such_as'|@getFixedLabel}<br /><br />
                    <span>Mrli@126.com&lt;李先生&gt;</span> <br /><span>Mrwang@126.com</span></li>
                    
                    <li>{'click_group_button'|@getFixedLabel}</li>
                    <li>{'send_yourself_test'|@getFixedLabel}</li>  
                </ul>
            </div>	                
            <div class="E_send_email">
                <div class="top_tit" >
                    <span>{'Recipient_Email'|@getFixedLabel}</span>
                    <i style="display:none">
                        <select class="E_sel_pro btn-radius-system" name="parent_type">
                            <option value="Contacts">{'Contacts'|@getTranstab}</option>
                            <option value="Accounts">{'Accounts'|@getTranstab}</option>
                            <option value="Users">{'LBL_USERS'|@getFixedLabel}</option>
                        </select> 
                        <a href="javascript:;" class="icon-homeimg icon-add" onclick="selectEmail()"></a>
                    </i>
                </div>
                <div class="E_se_area">
                    <input type="hidden" id="isjson" name="isjson" value="{$ISJSON}" />
                    <textarea id="parent_name" class="E_txt_area" name="parent_name" style="resize: none;">{$MTO}</textarea>
                </div>
            </div>
            <div class="E_info_editor">
                <div class="top_tit">
                    <span>{'EMAIL'|@getFixedLabel}{'Content'|@getFixedLabel}</span>
                    <!--<input class="E_editauto E_fr" onclick="window.open('index.php?module=Users&action=lookupemailtemplates','emailtemplate','top=100,left=200,height=400,width=500,resizable=yes,scrollbars=yes,menubar=no,addressbar=no,status=yes')" type="button" name="button" value="{'SELECTEMAILTEMPLATE'|@getFixedLabel}"/>
                    <input class="E_editauto E_fr" onclick="openEmailTemplates(this);" type="button" name="button" value="{'SELECTEMAILTEMPLATE'|@getFixedLabel}"/>-->
                </div>
                <div class="E_ie_area" style="background-color:#FFF">
                    <ul>
                        <li>
                            <label>{'Sender'|@getFixedLabel}:</label>
                            <i>
                                <select name="from_email" class="E_sendname">
                                    {foreach key=labelval item=selectval from=$MAILACCOUNT}
                                    {if $selectval.account_id eq $SELECTMAILACCOUNTID}
                                       
                                        
                                            {assign var=selectmodule value="selected"}
                                    {else}
                                            {assign var=selectmodule value=""}
                                    {/if}
                                              
                                        <option value="{$selectval.account_id}" {$selectmodule}>{$selectval.popuser}</option>
                                    {/foreach}
                                </select>
                            </i>
                        </li>
                        <li>
                            <label>{'Theme'|@getFixedLabel}:</label>
                            <i><input class="input_text" name="subject" value="{$SUBJECT}" type="text" id="subject"/></i>
                        </li>
                        <li>
                            <label>{'Attachment'|@getFixedLabel}:</label>
                            <i>
                                <div name="multiple_att" class="wu-example"></div>
                            </i>
                        </li>
						<li>
                            <label>{'EMAIL'|@getFixedLabel}{'Content'|@getFixedLabel}:</label>
                            <i>
								<select class="E_mes_sel btn-radius-system"  style="margin-top: -2px;float:unset;" onchange="submittemplate(this)" name="receivetem">
									<option value="0">— —{'EMAILTEMPLATES'|@getFixedLabel}— —</option>
									{foreach item=emailtemplate key=templateid from=$EMAILTEPLATE}
										<option value="{$templateid}">
											{$emailtemplate}
										</option>
									{/foreach}  
								</select>
							</i>
                        </li>
                    </ul>
                    <script id="description1" name="description1" type="text/plain" class="edui-default" style="background-color:#E8E8E8; height:148px; width: 100%;">
                   {$CONTENT} {$MBODY}
                    </script>
                    <script type="text/javascript">
                    var descriptionEditor = UE.getEditor('description1');
                    
                    </script>
                    
                    <div style=" padding-top:8px">
                        <span style="color:gray;">
                        * {'WILDCARDCUSTNAME'|@getFixedLabel}{ldelim}comname{rdelim};{'CONTACTNAME'|@getFixedLabel}{ldelim}name{rdelim};{'CONTACTAPPELLATION'|@getFixedLabel}{ldelim}app{rdelim}
                        </span>
                        <input class="E_saveauto" style="float:right;" type="button" value="{'MASSSEND'|@getFixedLabel}" onclick="return email_validate(this.form,'send');"/>
                    </div>
                </div>
            </div>
            <div class="clear"></div>
        </div>
        <!--主题内容结束-->	       
    </div>
	<!-- 数据分类排序 -->
	<div id="sortview" class="D_pop_box LdPopWidth300px" style="display:none;">
	<div id="sortview_form_div"></div>
	</div>
</form>
</div>

<!--邮件模板，弹出框-->
<div id="emailTemplatesDiv" class="D_pop_box LdPopWidth600px" style="display:none;">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'EMAILTEMPLATES'|@getFixedLabel}</strong>
        <a href="javascript:hideOptions('emailTemplatesDiv');puyoungJS_DialogBox.unblock();" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    <div id="div_emailTemplate" style="width: 100%;height:200px;overflow-y:auto;">

    </div>
</div>

<script type="text/javascript">


var special_ins = "{'Up_to_six_the_number_of_files'|@getFixedLabel}";//附件最多上传文件数量标签

var attachmentinfo='{$ATTACHMENTINFO}';
{literal}
global_flash_fileattachmentphp='index.php?module=Emails&action=EmailsAjax&file=File_Upload';
global_flash_delfileattachmentphp='index.php?module=Emails&action=EmailsAjax&file=File_DelUpload';
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
var  emailpopupobj=new CrmPopup();
emailpopupobj.frommodule='Emails';

emailpopupobj.divid='ListViewContents';
CrmPopup.global_listPopupObj.push(emailpopupobj);


function email_validate(oform,mode){
    
    if(trim(mode) == '')
	{
		return false;
	}
    if(document.EditView.from_email.value==''){
        var confirm_str = arrJsPopLabel['SENDERCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
	if(oform.parent_name.value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
	{
        var confirm_str = arrJsPopLabel['THERECOPIENTEMAILCANNOTBEEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
  
	//oform.mode.value=mode;//设置邮件是否保存还是发送
    var toemail="";//接收人
    var email_regex = /^[a-zA-Z0-9]+([\_\-\.]*[a-zA-Z0-9]+[\_\-]?)*@[a-zA-Z0-9]+([\_\-]?[a-zA-Z0-9]+)*\.+([\_\-]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)*$/;
    if(document.EditView.parent_name != null){
        if(document.EditView.parent_name.value.length >= 1){
			var str = document.EditView.parent_name.value;                     
            arr = new Array();
            arr = str.split("\n");      
            var tmp;
	    	for(var i=0; i<=arr.length-1; i++){
	            tmp = arr[i];
	            if(tmp.match('<') && tmp.match('>')) {
	                if(!findAngleBracket(arr[i])) {
                        var confirm_str = mail_err_msg+": "+arr[i];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                    }
            	}
				else if(trim(arr[i]) != "" && !(email_regex.test(trim(arr[i]))))
	            {
                        var confirm_str = arrJsPopLabel['YOUREMAILADDRESSISNOTCORRECT']+": "+arr[i];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
	                    return false;
	            }
               toemail+=tmp+",";
               
			}
		}
	}
    
	//发送

    var content=descriptionEditor.getContent();//发送内容
    var subject=document.EditView.subject.value;//主题
    
    var mailaccountid=document.EditView.from_email.options[document.EditView.from_email.selectedIndex].value;//发件人邮箱账号id
    
    var url="index.php?module=Emails&action=EmailsAjax&file=savewritemail&subject="+encodeURIComponent(subject)+"&toemail="+toemail+"&mailaccountid="+mailaccountid;
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
    //zkt 20231012 XUQIU1001341 SQL注入
    ldAjaxNoProgress(url,{"content": content, "namenameage": 18},function(data)
    {

        if(data.code==1)
        {
            RemindsMsg("","LdPopWidth400px","","yes","","发送成功");

            //window.location.reload();
        }
        else
        {
            alert(data.result.msg);
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
    //zkt 20231012 XUQIU1001341 SQL注入
    ldAjaxNoProgress('index.php?module=Users&action=UsersAjax&file=lookupemailtemplates','',function(data)
    {
        if(data.code==1)
        {
            crmPopupobj.setParams(data.result.title,'',"","LdPopWidth950px",'Emails',"","","","");
            crmPopupobj.quickcreatehtml=data.result.content;
            crmPopupobj.show(data.result.content);
        }
    });
	return false;
}
function submittemplate(obj)
{    
  
	var templateid = obj.value;
	if(templateid > 0){
        //zkt 20231012 XUQIU1001341 SQL注入
        ldAjaxHtmlNoProgress('index.php?',"module=Users&action=UsersAjax&file=TemplateMerge&templateid="+templateid,function(response) {

            if(response.indexOf('###SUCCESS###') > -1){
                var results=response.split('###SUCCESS###');

                //	document.getElementById('description1').value = results[1];
                descriptionEditor.setContent(results[1]);
                //		javascript:hideOptions('emailTemplatesDiv');
                cancelCrmPopup();
            }
        });
	}
}



{/literal}


</script> 