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
<div id="ListViewContents">
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ckeditor/ckeditor.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/Products/multifile.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script>
<table align="center" border="0" cellpadding="0" cellspacing="0" width="99%">
<div id="detialnationview" class="D_pop_box" style="display:none;width:750px;">
<div id="detialnationview_div"></div>
<tr>
<td>
{*{include file='Buttons_List.tpl'}*}
<div class="clear"></div>
<input type="hidden" name="accountid_chose" id="accountid_chose" value=""/>
<input type="hidden" name="row_of_checkbox_account" id="row_of_checkbox_account" value="{$num_rows}"/>

<!--
更新操作
edit:cdw
date:20131119
reason:客户序时簿界面群发短信功能改进
-->


<div id="SMSedit" class="D_pop_box LdPopWidth300px" style="position: absolute; z-index:9999; width: 300px; left: 169px; top: 179px;display:none;">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'PLEASESELECTPHONE'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('SMSedit');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    <!--0026808: 群发短信：当客户模块中手机字段过多时，群发短信切换数据分类，弹出层看不到保存按钮，无法继续操作-->
    <div style="width:100%;max-height:400px;overflow:auto">		
    <table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr>
        <td>
        {'PCWYWTSTMTMP'|@getFixedLabel}                   
        </td>
      </tr>
       {$html_accounttype_SMS}
    </table>
    </div>    
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SELECT'|@getFixedLabel}" id="chose_checkbox" onclick="chosebox_select_btn_MassSMS('MassSMS');replace_wildcard();puyoungJS_DialogBox.unblock();"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('SMSedit');" />   
    </div>
</div>

                        
<div id="searchingUI" style="display:none;text-algin:center;">
    <img src="{'searching.gif'|@lingdang_imageurl:$THEME}" alt="{$APP.LBL_SEARCHING}"  title="{$APP.LBL_SEARCHING}">
</div>            

{*<!-- Contents -->*}

<form id="sendSMS" name="sendSMS" method="post" onsubmit="puyoungJS_DialogBox.block()" ENCTYPE="multipart/form-data" action="index.php" style="margin:0px">
    <input type='hidden' name="module" value="MassSMS" id="curmodule"/>
    <input type='hidden' name="action" value="index"/>
    <input type="hidden" id="viewname" value="{$VIEWID}"/>
    <input type="hidden" name="groupemail" id="groupemail" value="groupsms"/>
    <input type="hidden" name="hidden_toid" id="hidden_toid">
    <input type="hidden" name="allowedit" value="{$ALLOWEDIT}"/>
    <!--
    更新操作
    edit：cdw
    date：20131205
    reason：替换通配符
    -->
    <input type="hidden" name="account_wildcard_id" id="account_wildcard_id" value=""/>
    <input type="hidden" name="account_wildcard_tabid_fieldlabel" id="account_wildcard_tabid_fieldlabel" value=""/>
    <input type="hidden" name="contact_btn_MassSMS_wildcard_id" id="contact_btn_MassSMS_wildcard_id" value=""/>
    <input type="hidden" name="contact_btn_MassSMS_wildcard_tabid_fieldlabel" id="contact_btn_MassSMS_wildcard_tabid_fieldlabel" value=""/>
    <input type="hidden" name="account_btn_MassSMS_wildcard_id" id="account_btn_MassSMS_wildcard_id" value=""/>
    <input type="hidden" name="account_btn_MassSMS_wildcard_tabid_fieldlabel" id="account_btn_MassSMS_wildcard_tabid_fieldlabel" value=""/>
    <!--
    跟新操作
    edit：cdw
    20131209
    reason：替换通配符，客户序时簿，详细群发短信
    -->
    <input type="hidden" name="sms_account_listview_tabid_fieldlabel" id="sms_account_listview_tabid_fieldlabel" value="{$sms_account_listview_tabid_fieldlabel}"/>
    <input type="hidden" name="sms_account_listview_allids" id="sms_account_listview_allids" value="{$sms_account_listview_allids}"/>
    <input type="hidden" name="sms_contact_listview_tabid_fieldlabel" id="sms_contact_listview_tabid_fieldlabel" value="{$sms_contact_listview_tabid_fieldlabel}"/>
    <input type="hidden" name="sms_contact_listview_allids" id="sms_contact_listview_allids" value="{$sms_contact_listview_allids}"/>
    
    <div class="E_sms">   
        <div class="Category">
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td valign="middle" class="L" width="60">
                        <div class="Title" style="width:60px;"><span style="margin-top: 0;">{'Grouping'|@getFixedLabel}:</span></div>
                    </td>
                    <td valign="middle" class="C">
                        <ul>
                            {$CUSTOMVIEW_HTML}
                        </ul>
                    </td>                    
                    <td valign="middle" class="R">
                        <div class="Xl">
                            <a class="Xl_a" id="viewoperate" onclick="return false;" onmouseout="fnHideDrop('selectviewoperate');" onmouseover="ViewfnDropDown(this,'selectviewoperate');" href="javascript:void(0);">{'CREATEGROUPS'|@getFixedLabel }</a>
                            <ul onmouseover="fnShowDrop('selectviewoperate')" onmouseout="fnHideDrop('selectviewoperate')"  id="selectviewoperate">                                           
                                <li>
                                    <a href="index.php?module=Accounts&action=CustomView&parenttab=Marketing&groupEmail=MassSMS">{'CREATEGROUPS'|@getFixedLabel }</a>		
                                </li>
                                {if $CV_EDIT_PERMIT eq 'yes'}
                                    {assign var="display" value="block"}
                                {else}
                                    {assign var="display" value="none"}
                                {/if}
                                <li style="display:{$display};">
                                    <a id="EditFezu" href="javascript:editFenzu('Accounts','Marketing',1)">{'EDIT'|@getFixedLabel}</a>
                                </li>                                
                                {if $CV_DELETE_PERMIT eq 'yes' && $VIEWNAME neq 'All'}
                                    {assign var="display" value="block"}
                                {else}
                                    {assign var="display" value="none"}
                                {/if}
                                <li id="DeleteFezu_li" style="display:{$display};">
                                    <a id="DeleteFezu" href="javascript:;" onclick="deleteFenzu('Accounts','Marketing',1);">{'DELETE'|@getFixedLabel}</a>
                                </li>
                                <li>
                                    <a id="CopyFezu" href="index.php?module=Accounts&action=CustomView&record={$VIEWID}&viewcopy=true&groupEmail=MassSMS&parenttab=Marketing" >{'COPY'|@getFixedLabel}</a>
                                </li>
                                <li style="display:{if $IS_ADMIN} block {else} none {/if};">                       
                                    <a id="SORTFezu" href="javascript:void(0);" onclick="ShowSortView(this,'sortview','{$MODULE}')" >{'SORT'|@getFixedLabel}</a>
                                </li>                                                                     
                            </ul>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
        <div class="clear"></div>
        
        <div class="E_emailCotent">
            <div class="E_usage_tips">
                <div class="top_tit">
                    <span>{'Usage_Tips'|@getFixedLabel}</span>
                </div>
                <ul class="E_ut_area">
                    <li>{'settingscommunicationsaccountthemselves'|@getFixedLabel}</li>
                    <li>{'Standard_format_number'|@getFixedLabel}：<br/><span>13166331111&lt;张先生&gt; {'OR'|@getFixedLabel} 13761640836</span></li>
                    <li>{'GroupsWhensendingtextmessages'|@getFixedLabel}<br/>{'FOREXAMPLE'|@getFixedLabel}<br /><span>13166336666&lt;王先生&gt;</span><br/><span>13166338888&lt;李先生&gt;</span></li>
                    <li>{'notfilloutspecialcharacters'|@getFixedLabel}</li>
                    <li>{'Acaswaw'|@getFixedLabel}</li>
                    <li>{'notlessthan20seconds'|@getFixedLabel}</li>
                    <li>{'SELECTGROUNPADDCUSTOMERSPHONE'|@getFixedLabel}</li>
                    <li>{'IFNOTCREATEGROUP'|@getFixedLabel}</li>
                    <li>{'INPUTTEXTMESSAGEPLEASETONOTENTERTHEFOLLOWKEYWORDS:TESTING'|@getFixedLabel}</li>
                </ul>
            </div>
            <div class="E_send_email">
                <div class="top_tit">
                    <span>{'Recipient_phone'|@getFixedLabel}</span>
                    <i>
                        <select class="E_sel_pro btn-radius-system" name="parent_type" id="parent_type">
                            <option value="Contacts">{'Contacts'|getTranstab}</option>
                            <option value="Accounts">{'Accounts'|getTranstab}</option>
                            <option value="Users">{'LBL_USERS'|@getFixedLabel}</option>
                        </select>
                        <a href="javascript:;" class="icon-homeimg icon-add" onclick="selectEmail()" ></a>
                        <input style="width:70px" type="button" id="btn_import" value="{'IMPORT'|@getFixedLabel}"/>
                    </i>
                </div>
                <div class="E_se_area">
                    <input type="hidden" id="hddMobileValue" name="hddMobileValue" value="{$HDDMOBILEVALUE}{$SMS_MOBILE_TEXT}">
                    {if $ALLOWEDIT eq 'yes'}
                        <textarea class="E_txt_area" style="resize: none;"  wrap="physical" id="parent_name" name="receivephone" cols="" rows="">{$ACCEPTER}{$allinfo}</textarea>
                    {else}
                        <textarea class="E_txt_area" style="resize: none;"  wrap="physical" id="parent_name" name="receivephone" cols="" rows="" readonly="true">{$ACCEPTER}{$allinfo}</textarea>
                    {/if}
                    <textarea class="E_txt_area" style="display:none;resize: none;" wrap="physical" name="receivephonehidden" id="receivephonehidden" cols="" rows="">{$HIDDENACCEPTER}</textarea>
                </div>
            </div>
            
            <div class="E_info_editor">
                <div class="top_tit">
                    <span>{'SMS_content'|@getFixedLabel}</span>
                    {if $accountautograph neq ''} 
                        {assign var="accountautograph" value="【$accountautograph】"}
                    {/if}
                    <select class="E_mes_sel btn-radius-system"  style="margin-top: 3px;" onchange="addSMSTemplate('{$accountautograph}');" name="receivetem" id="receivetem">
                        <option value="-1">— —{'SMS_templates'|@getFixedLabel}— —</option>
                        {foreach name=emailtemplate item=template from=$TEMPLATES}
                            <option value="{$template.TemplateID}">
                                {$template.TemplateName}
                            </option>
                        {/foreach}	
                    </select>
                </div>
                <div class="E_ie_area E_mes_con">
                    <textarea id="receivecontent" class="E_txt_area E_mes_txtarea" style="resize: none;"  wrap="physical" name="receivecontent" cols="" rows="" 
                        onkeydown="countChar('receivecontent','now_counter','signature_counter','all_counter','{$accountautograph}');" 
                        onkeyup="countChar('receivecontent','now_counter','signature_counter','all_counter','{$accountautograph}');" 
                        onpaste="countChar('receivecontent','now_counter','signature_counter','all_counter','{$accountautograph}')"></textarea>
                    <div style=" padding-top:8px; padding-left:10px;color:#ED7403;">
                        {'Currentinput'|@getFixedLabel}<span id="now_counter">0</span>{'Word'|@getFixedLabel}<span id="signature_counter">0</span>{'Word2'|@getFixedLabel}{'Totalcontentofthemessage'|@getFixedLabel}<span id="all_counter">0</span>{'Word2'|@getFixedLabel}。
                    </div>
                    <script language="javascript" type="text/javascript">
                    {literal}
                        //即时提醒群发短信内容字数
                        function countChar(receivecontent,now_counter,signature_counter,all_counter,accountautograph){
                        //在鼠标粘贴事件之后获取内容，所以在500毫秒之后执行
                        setTimeout(function(){
                        var valLength = document.getElementById(receivecontent).value.length;
                        var SignatureLength = accountautograph.length;
                        var allLength = valLength + SignatureLength;
                        document.getElementById(now_counter).innerHTML = valLength;//当前内容字数
                        document.getElementById(signature_counter).innerHTML = SignatureLength;//签名内容字数
                        document.getElementById(all_counter).innerHTML = allLength;//总共内容字数
                        },500);
                        
                        }
                    {/literal}
                    </script>
                
                    <div style=" padding-top:8px; padding-left:10px">
                        <span style="color:gray;">
							{'WILDCARDCUSTNAME'|@getFixedLabel}{ldelim}comname{rdelim}；{'CONTACTNAME'|@getFixedLabel}{ldelim}name{rdelim}；{'CONTACTAPPELLATION'|@getFixedLabel}{ldelim}app{rdelim}
                        </span>
                    </div>
                    <ul class="E_note_p">
                        <li>1.{'SMS_Signature'|@getFixedLabel}：{$accountautograph}</li>
                        <li>2.{'CURRENT_ACCOUNT_BALANCE'|@getFixedLabel}：{$accountbalance}{'YUAN'|@getFixedLabel}
                            {if $accountbalance <= 100}
                            <span class="E_red_txt">{'PLASERECHARGE'|@getFixedLabel}！</span>
                            {/if}
                        </li>
                        <li>3.{'MESSCATEGORY'|@getFixedLabel}：{'SMS_Marketing'|@getFixedLabel}
                        <!--
                        <select name="messcategory" id="messcategory">
                        <option value="yingx" selected="selected">{'SMS_Marketing'|@getFixedLabel}</option>
                        <option value="zhuf">{'SMS_Blessing'|@getFixedLabel}</option>
                        <option value="tongz">{'SMS_Notification'|@getFixedLabel}</option>
                        </select>
                        -->
                        </li>
                    </ul>
                    <div>
                        <input class="save" style="float:right;margin-top:10px;width:70px;" name="button" type="button" onclick="return Mass_formValidate();"  value="{'MASSSEND'|@getFixedLabel}" />
                    </div>
                </div>
                <input id="accountid" name="accountid" type="hidden" value="{$accountaccountid}" />
                <input id="accountname" name="accountname" type="hidden" value="{$accountaccountname}" />
                <input id="accountflag" name="accountflag" type="hidden" value="{$accountflag}" />
                <input id="accountautograph" name="accountautograph" type="hidden" value="{$accountautograph}" />
                <input id="accountbalance" name="accountbalance" type="hidden" value="{$accountbalance}" />
            </div>
            <div class="clear"></div>
        </div>
    </div>
</form>

</td>
</tr>
</table>
</div>
<!--数据分类排序-->
<div id="sortview" class="D_pop_box LdPopWidth300px" style="display:none;">
<div id="sortview_form_div"></div>
</div>
<div id="dv_import_sms" class="D_pop_box LdPopWidth400px" style="display:none;position:absolute;z-index:9999">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'IMPORTRECIPIENTPHONE'|@getFixedLabel}</strong>
        <a class="D_ptitc" href="javascript:fninvshnew('dv_import_sms');">
            <img title="{'CLOSE'|@getFixedLabel}" alt="{'CLOSE'|@getFixedLabel}" src="themes/icon/pop_close.png" style="margin:5px 0px 0px 4px;padding:0px;">
        </a>
    </div>
    <div class="ld-public-content padTB10">
        <textarea id="txtarea_import_sms" class="ld-textarea-inner"></textarea>
    </div>
    <div class="D_pbtn">
        <input class="D_pbtnok" type="button" value="{'CONFIRMED'|@getFixedLabel}" id="btn_add_sms"/> <span>&nbsp;</span>
    	<input type="button" onclick="fninvshnew('dv_import_sms');" value="{'CANCEL'|@getFixedLabel}" class="D_pbtncancel"/>
    </div>    
</div>
<script language="JavaScript" type="text/javascript" src="include/js/MassSMS.js"></script>
<script type="text/javascript">
var signtureofsms='{$accountautograph}';
{literal}
	var  massmspopupobj=new CrmPopup();
	massmspopupobj.divid='ListViewContents';
	CrmPopup.global_listPopupObj.push(massmspopupobj);
    /*window.onload = function(){
    	ld('textarea').autosize();//textarea根据内容自动调整大小
    }*/
    var reg=/(1[0-9]{10})<(.+)>/g;
    var digit=/^1\d{10}$/g;
    var btn_import=document.getElementById("btn_import");
	function selectEmail(){
		var parent_type = document.sendSMS.parent_type.value;
		var surl = "module="+parent_type+"&action=Popup&html=Popup_picker&form=HelpDeskEditView&popuptype=set_return_groupmasssms&select=enable&popup=yes&page_popup=yes";
		CrmPopupWindow('MassSMS',surl,parent_type);
	}

    btn_import.onclick=function(event)
    {
        
        var e=event||window.event;
        var cur_obj=e.srcElement||e.target;
        
        fnvshobj(cur_obj,"dv_import_sms");
    }
    var btn_add_sms=document.getElementById("btn_add_sms");
    btn_add_sms.onclick=function(event)
    {
        
        var e=event||window.event;
        var cur_obj=e.srcElement||e.target;
        if(document.getElementById("txtarea_import_sms").value!="")
        {
            var phones=document.getElementById("txtarea_import_sms").value.split("\n");
            
            var phone="";
            var hiddenphone="";
            for(var i=0; i<phones.length;i++)
            {
                var key=phones[i];
               
                var r=key.match(reg);
                if(r!=null)
                {
                    r=key.split("<");
                   
                    hiddenphone+=Base64.encode(r[0])+"\n";
                    phone+=key+"\n";
                }
                else if(key.match(digit))
                {
                   
                    phone+=key+"\n";
                    hiddenphone+=Base64.encode(key)+"\n";
                }
            }
            if(phone!="")
            {
                document.getElementById("parent_name").value+=phone;
                document.getElementById("receivephonehidden").value+=hiddenphone;
            }
            
        }
        
        fninvshnew("dv_import_sms");
        document.getElementById("txtarea_import_sms").value="";
    }
  //Liver 20170413 bug0027875: 群发短信界面：刚进入界面时，签名包含0个字，没有把签名计算进去  
  countChar('receivecontent','now_counter','signature_counter','all_counter',signtureofsms);  
    
{/literal}
</script> 