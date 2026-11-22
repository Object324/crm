<!--修改编码格式:统一编码：UTF-8-->
{*{include file='Buttons_List.tpl'}*}
<div id="ListViewContents">
{if $smarty.request.ajax neq ''}
&#&#&#{$ERROR}&#&#&#
{/if}

<script type="text/javascript" src="{$JSURL}include/js/modules/Products/multifile.js"></script>

<script type="text/javascript" src="{$CRMCOMMONURL}include/js/GroupEmail.js"></script>

{*    // @edit:liushuai @date:2020-07-09 @reason: 0041912/群发邮件模块/（0041871点击左上角“全部”按钮，界面卡死）*}
{*老版本email分组弹窗*}
{*<div id="SMSedit" class="E_pop_box LdPopWidth300px" style="position: absolute; z-index:9999; width: 300px; left: 169px; top: 179px;display:none;">
    <div class="E_pop_tit">
    	<strong class="E_ptita">{'PLEASESELECTEMAIL'|@getFixedLabel}</strong>
        <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('SMSedit');"></button>
    </div>	
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
       <tr>
        <td>
        {'PCWYWTSETE'|@getFixedLabel}                   
        </td>
      </tr>
       {$html_accounttype_SMS}
    </table>
    <div class="E_pbtn">
    	<input type="button" class="E_pbtnok" value="{'SELECT'|@getFixedLabel}" id="chose_checkbox" onclick="chosebox_select_btn_MassSMS('Email');puyoungJS_DialogBox.unblock();" /><span>&nbsp;</span>
        <input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('SMSedit');"/>   
    </div>
</div>*}
{literal}
<form name="EditView" method="POST" ENCTYPE="multipart/form-data" action="index.php" class="ajax_form"">
{/literal}
    <input type="hidden" id="viewname" value="{$VIEWID}"/>
    <input type="hidden" id="is_admin" value="{$IS_ADMIN}"/>
    <input type="hidden" name="send_mail">
    <input type="hidden" name="module" value="{$MODULE}">
    <input type="hidden" name="action" value=''>
    <input type="hidden" name="return_module" value="{$RETURN_MODULE}"/>
    <input type="hidden" name="return_action" value="GroupEmail"/>
    <input type="hidden" name="hidden_toid" id="hidden_toid">
    <input type="hidden" name="groupemail" id="groupemail" value="groupemail"/>
    <input type="hidden" name="parenttab" id="parenttab" value="{$PARENTTAB}" />
    <input type="hidden" name="accountid_chose" id="accountid_chose" value=""/>
    <input type="hidden" name="row_of_checkbox_account_groupemail" id="row_of_checkbox_account_groupemail" value="{$num_rows}"/>
    <input type="hidden" name="" id="" value=""/>
	 <input type="hidden" name="curmodule" id="curmodule" value="{$MODULE}">
    <input type="hidden" name="account_wildcard_email_id" id="account_wildcard_email_id" value=""/>
    <input type="hidden" name="account_wildcard_tabid_fieldlabel_email" id="account_wildcard_tabid_fieldlabel_email" value=""/>
    <input type="hidden" name="contact_btn_email_wildcard_id" id="contact_btn_email_wildcard_id" value=""/>
    <input type="hidden" name="contact_btn_email_wildcard_tabid_fieldlabel" id="contact_btn_email_wildcard_tabid_fieldlabel" value=""/>
    <input type="hidden" name="account_btn_email_wildcard_id" id="account_btn_email_wildcard_id" value=""/>
    <input type="hidden" name="account_btn_email_wildcard_tabid_fieldlabel" id="account_btn_email_wildcard_tabid_fieldlabel" value=""/>
    <!---
    更新操作
    edit：cdw
    date：20131209
    reason：替换通配符的值，客户
    -->
    <input type="hidden" name="tabid_fieldlabel_listview_email" id="tabid_fieldlabel_listview_email" value="{$tabid_fieldlabel_listview_email}"/>
    <input type="hidden" name="accountid_listview_email" id="accountid_listview_email" value="{$accountid_listview_email}"/>
    <!--下拉框和界面-->
    <input type="hidden" name="tabid_fieldlabel_btn_listview_email" id="tabid_fieldlabel_btn_listview_email" value=""/>
    <input type="hidden" name="accountid_btn_listview_email" id="accountid_btn_listview_email" value=""/>
    <input type="hidden" name="contact_email_tabid_fieldlabel" id="contact_email_tabid_fieldlabel" value="{$contact_email_tabid_fieldlabel}"/>
    <input type="hidden" name="contactid" id="contactid" value="{$contactid}"/>
    <!--下拉框-->
    <input type="hidden" name="contact_email_btn_tabid_fieldlabel" id="contact_email_tabid_fieldlabel" value="{$contact_email_tabid_fieldlabel}"/>
    <input type="hidden" name="contactid_btn" id="contactid_btn" value="{$contactid}"/>
    
    <div class="">
        <div class="Category">
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td valign="middle" class="L" width="60">
                        <div class="Title" style="width:60px;"><span style="margin-top: 0;">{'Grouping'|@getFixedLabel}:</span></div>
                    </td>
                    <td valign="middle" class="C" name="customviewhtml">
                        <ul>
                            {$CUSTOMVIEW_HTML}
                        </ul>
                    </td>
                    <td valign="middle" class="R">
                        <div class="Xl">
                            <a class="Xl_a" id="viewoperate" onclick="return false;" onmouseout="fnHideDrop('selectviewoperate');" onmouseover="ViewfnDropDown(this,'selectviewoperate');" href="javascript:void(0);">{'CREATEGROUPS'|@getFixedLabel}<span class="icon-bluetriangle"></span></a>
                            <ul onmouseover="fnShowDrop('selectviewoperate')" onmouseout="fnHideDrop('selectviewoperate')"  id="selectviewoperate" style="display:none;">
                                <li>
{*                                    @edit:ls @date:2020-7-9 @reason: 0041912/群发邮件模块高级查找*}
{*                                    <a href="index.php?module=Accounts&action=CustomView&parenttab=Marketing&groupEmail=Emails">{'CREATEGROUPS'|@getFixedLabel }</a>*}
                                    <a id="CreateFezu" href="javascript:createFenzu('Accounts','Marketing',0)">{'CREATEGROUPS'|@getFixedLabel }</a>
                                </li>
                                {if $CV_EDIT_PERMIT eq 'yes'}
                                    {assign var="display" value="block"}
                                {else}
                                    {assign var="display" value="none"}
                                {/if}                       
                                <li style="display:{$display};">
                                    <a id="EditFezu" href="javascript:editFenzu('Accounts','Marketing',0)">{'EDIT'|@getFixedLabel}</a>
                                </li>
                                {if $CV_DELETE_PERMIT eq 'yes' && $VIEWNAME neq 'All'}
                                    {assign var="display" value="block"}
                                {else}
                                    {assign var="display" value="none"}
                                {/if}
                                <li style="display:{$display};">
                                    <a id="DeleteFezu" href="javascript:deleteFenzu('Accounts','Marketing',0)">{'DELETE'|@getFixedLabel}</a>
                                </li>
								<li>
{*									<a href="index.php?module=Accounts&action=CustomView&record={$VIEWID}&viewcopy=true&groupEmail=Emails" >{'COPY'|@getFixedLabel}</a>*}
                                    <a id="CopyFezu" href="javascript:copyFenzu('Accounts',0)">{'COPY'|@getFixedLabel }</a>
								</li>
								{if $IS_ADMIN}
									<li>
{*										<a href="javascript:void(0);" onClick="ShowSortView(this,'sortview','{$MODULE}')">{'SORT'|@getFixedLabel}</a>*}
										<a href="javascript:sortViewFenzu(this,'sortview','{$MODULE}')">{'SORT'|@getFixedLabel}</a>
									</li>
								{/if}
                            </ul>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
        <div class="clear"></div>
        <!--主题内容开始-->
        <div class="E_emailCotent">
            <div class="E_usage_tips">
                <div class="top_tit">
                    <span>{'Usage_Tips'|@getFixedLabel}</span>
                </div>
                <ul class="E_ut_area">
                    <li>{'Before_sending_please_go_to_SMTP'|@getFixedLabel}</li>
                    <li>{'Email_standard_format_recipient'|@getFixedLabel}<br />
                    <span>Mrzhang@126.com&lt;张先生&gt;</span></li>
                    <li>{'If_no_packet_you_need'|@getFixedLabel}</li>
                    <li>{'Bulk_mail_newline_interval_such_as'|@getFixedLabel}<br />
                    <span>Mrli@126.com&lt;李先生&gt;</span> <br /><span>Mrwang@126.com&lt;王先生&gt;</span></li>
                    <li>{'Select_Add_you_can_find_add_customers'|@getFixedLabel}</li>
                    <li>{'click_group_button'|@getFixedLabel}</li>
                    <li>{'send_yourself_test'|@getFixedLabel}</li>  
                </ul>
            </div>	                
            <div class="E_send_email">
                <div class="top_tit">
                    <span>{'Recipient_Email'|@getFixedLabel}</span>
                    <i>
                        <select class="E_sel_pro btn-radius-system" name="parent_type">
                            <option value="Contacts">{'Contacts'|@getTranstab}</option>
                            <option value="Accounts">{'Accounts'|@getTranstab}</option>
                            {if $iskehu001 == 'no'}
                                <option value="Users">{'Users'|@getTranstab}</option>
                            {/if}
                        </select>
                        <a href="javascript:;" class="icon-homeimg icon-add" onclick="GroupEmail.selectEmail()"></a>
                    </i>
                </div>
                <div class="E_se_area">
                    <input type="hidden" id="isjson" name="isjson" value="{$ISJSON}" />
                    <textarea id="parent_name" class="E_txt_area" name="parent_name" style="resize: none;">{$RTOEMAIL}{$TOEMAIL}{$request_email}{$contact_detail}</textarea>
                    <!-- <div id="parent_name" class="E_txt_area" name="parent_name" style="resize: none;border: 1px solid #dadada;text-align: left;overflow: auto;" name="receivephone" contenteditable="true">
                        {$RTOEMAIL}{$TOEMAIL}{$request_email}{$contact_detail}
                    </div> -->
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
                                    {foreach key=labelval item=selectval from=$FROMALLMAIL}
                                    {if $RECORDID > 0}
                                        {if $labelval eq $FROMEMAIL}
                                            {assign var=selectmodule value="selected"}
                                        {else}
                                            {assign var=selectmodule value=""}
                                        {/if}
                                    {else}
                                        {if $selectval eq selected}
                                            {assign var=selectmodule value="selected"}
                                        {else}
                                            {assign var=selectmodule value=""}
                                        {/if}
                                    {/if}            
                                        <option value="{$labelval}" {$selectmodule}>{$labelval}</option>
                                    {/foreach}
                                </select>
                            </i>
                        </li>
                        <li>
                            <label>{'Theme'|@getFixedLabel}:</label>
                            <i><input class="input_text" name="subject" type="text" id="subject"/></i>
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
								<select class="E_mes_sel btn-radius-system"  style="margin-top: -2px;float:unset;" onchange="GroupEmail.submittemplate(this)" name="receivetem">
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
                    <script id="description1" name="description1" type="text/plain" class="edui-default" style="background-color:#E8E8E8; height:100px; width: 100%;"></script>
                    
                    <div style=" padding-top:8px">
                        <span style="color:gray;">
                        * {'WILDCARDCUSTNAME'|@getFixedLabel}{ldelim}comname{rdelim};{'CONTACTNAME'|@getFixedLabel}{ldelim}name{rdelim};{'CONTACTAPPELLATION'|@getFixedLabel}{ldelim}app{rdelim}
                        </span>
                        <input class="ld-button ld-button-primary" style="float:right;" type="button" value="{'MASSSEND'|@getFixedLabel}" onclick="return GroupEmail.email_validate(this.form,'send');"/>
                    </div>
                </div>
            </div>
            <div class="clear"></div>
        </div>
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
{literal}
var  emailpopupobj=new CrmPopup();
emailpopupobj.module='Emails';

emailpopupobj.divid='ListViewContents';
CrmPopup.global_listPopupObj.push(emailpopupobj);
var myJSONtext = document.getElementById('isjson').value;
if(myJSONtext != null &&  myJSONtext != '')
{
    document.getElementById('parent_name').value = eval('(' + myJSONtext + ')');
}
function selectEmail(){
	var parent_type = document.EditView.parent_type.value;
	var surl = "module="+parent_type+"&action=Popup&html=Popup_picker&form=HelpDeskEditView&popuptype=set_return_groupemails&select=enable&popup=yes&page_popup=yes";
	CrmPopupWindow('Emails',surl,parent_type);
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
            document.EditView.hidden_toid.value=document.EditView.hidden_toid.value+ret+',';
            return true;
        } 
        else
        {
            return false;
        }
}
/***
更新操作
edit：cdw
date：20131205
reason：替换通配符
        群发邮件分组
        
***/
function replace_wildcard_email()
{
    //获取所有的选择的客户id
    var accountid = document.getElementById('accountid_chose').value;
    //获取所有的选择的条目
    var num_rows = document.getElementById("row_of_checkbox_account").value;
        var tabid_fieldlabel ="";
        for(var i=0;i<num_rows;i++)
        {   
            var id = i+'_checkbox_MassSMS_SMS';
            var id_check = document.getElementById(id);
            //选中的项目进行处理
            if(id_check.checked==true)
            {
                var tabid_fieldlabel = tabid_fieldlabel + document.getElementById(id).value+"_";
            }       
        }
        //赋值到对应的hidden，用来获取list
        document.getElementById('account_wildcard_email_id').value = accountid;
        document.getElementById('account_wildcard_tabid_fieldlabel_email').value = tabid_fieldlabel;
        alert(document.getElementById('account_wildcard_email_id').value);
        alert(document.getElementById('account_wildcard_tabid_fieldlabel_email').value);
        return false;
}





function openEmailTemplates(obj){
    
    var crmPopupobj=CreatePagePopup.load("","","","LdPopWidth950px",'Emails',"","","","");
	crmPopupobj.prevshow();
	ld.ajax({
		url: 'index.php?module=Users&action=lookupemailtemplates',
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


{/literal}
</script> 