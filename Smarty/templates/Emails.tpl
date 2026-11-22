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
{*{include file='Buttons_List.tpl'}*}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Emails/Emails.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/modules/Emails/EmailList.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Emails/EmailContentDetail.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Emails/EmailAccount.js"></script>
<script>
{literal}




/**
 * 回车搜索
 * @author Tujt 2015-03-25
 */
function searchmail_keyup(event){
    var e = event || window.event;
    if(13 == e.keyCode){
        email_Searchfn();
    }
}


{/literal}
</script>
<div id="mailconfchk" class="small" style="position:absolute;display:none;left:350px;top:160px;height:27px;white-space:nowrap;z-index:10000007px;"><font color='red'><b>{'LBL_CONFIGURE_MAIL_SETTINGS'|@getFixedLabel}.<br> {$APP.LBL_PLEASE_CLICK} <a href="index.php?module=Users&action=AddMailAccount&record={$USERID}&return_module=Webmails&return_action=index">{$APP.LBL_HERE}</a> {$APP.LBL_TO_CONFIGURE}</b></font></div>
<!-- Shadow starts here -->
<div class="EmailDiv EmailDivbg">
<div style="padding:0px 3px;height: 100%;" id="deskemail">
    <!--<div name="listreadprogress" >5/10</div>-->
    <form name="massdelete" method="POST" onsubmit="puyoungJS_DialogBox.block();">
   
    <!--菜单开始-->
    <table class="EamiltableMain" cellspacing="0" border="0" cellpadding="0" width="100%" height="100%">
    <tr>
        <td valign="top" width="179px">
            <div class="menuContentsR">
                <div>
                    <ul>
                        <li>
                            <a href="javascript:void(0);" onclick="WriteEmail()">{'WRITELETTERS'|@getFixedLabel}</a>
                            <input type="button" disabled="" style="background: url(themes/softed/images/mail.png) 0 -1px no-repeat;">
                        </li>
                        <li>
                            <a href="javascript:void(0);" onclick="javascript:emailreceiveClick(this)">{'RECEIVELETTERS'|@getFixedLabel}</a>
                            <input type="button" disabled="" style="background: url(themes/softed/images/mail.png) 0 -33px no-repeat;">
                        </li>
                        <li>
                            <a href="javascript:void(0);" name="mailboxset_name" onclick="mailboxList(this);">{'MAILBOXSETTINGS'|@getFixedLabel}</a>
                            <input type="button" disabled="" style="background: url(themes/softed/images/mail.png) 0 -63px no-repeat;">
                        </li>
                    </ul>
                </div>
            </div>
                <div class="emailMidBar">
                <div>
                    <ul>
                        <li id="li_email_account_list">
                            <a href="javascript:void(0);" class="email_menu email_menu_active" onclick="javascript:emailaccountClick(0,this)">{'INBOX'|@getFixedLabel}</a>
                            {foreach from=$MAILACCOUNTS item=mailaccount}
                            <a class="emailuserlist useraddr_active" tag="emaillistinfo_{$mailaccount.account_id}"  title="{$mailaccount.popuser}" onclick="javascript:emailaccountClick('{$mailaccount.account_id}',this)"><span class="mail-popuser">
                                {$mailaccount.popuser}
                            </span><span tag="emaillist_{$mailaccount.account_id}" class="mail-num"></span></a>
                            {/foreach}
                        </li>
                        <li>
                            <a href="javascript:void(0);" onclick="getstarmaillist(this)">{'STARMAIL'|@getFixedLabel}<input class="star-icon star_icon_yes" type="button" hidefocus=""></a>

                        </li>
                        <li style="display:none">
                            <a href="javascript:void(0);">{'Drafts'|@getFixedLabel}</a>
                        </li>
                        <li>
                            <a href="javascript:void(0);" id="leftsend" onclick="getsendlist(this)">{'LBL_SENT_MAILS'|@getFixedLabel}</a>
                        </li>
                        <li>
                            <a href="javascript:void(0);" onclick="getdeletelist(this)" >{'DELETED'|@getFixedLabel}<span style="float:right;" onclick="cleardeletemail()">[{'EMPTY'|@getFixedLabel}]</span></a>
                        </li>
                        <li>
                            <a href="javascript:void(0);" style="display:none">{'DUSTBIN'|@getFixedLabel}</a>
                        </li>
                    </ul>
                </div>
            </div>
        </td>
    <!--菜单结束-->
    <td>
    <div class="EmailListL EmailsMainFrame" id="send_email_Frame">
        <div class="emailContents" id="send_email">
        
        </div>
    </div>
    <div class="EmailListL EmailsMainFrame" id="EmailContentDetails" style="overflow-y: auto;display: none;"><!--邮件明细-->
        <div class="emailContents" id="EmailDetails">
       
        </div>
    </div>
    <!---邮件列表--->
    <div class="EmailListL EmailsMainFrame" id="emailContents" style="display: none;">
        <div class="emailContents" id="email_con">
        {include file="EmailContents.tpl"}
        </div>
    </div>
    <div class="EmailListL EmailsMainFrame" id="EmailSettings" style="display: none;">
        <div class="allEmail"><span id="mail_fldrname">{'MAILBOXSETTINGS'|@getFixedLabel}</div>
        <div class="emailContents" >
        {include file="mailboxSetup.tpl"}
        </div>
    </div>
   
    </td>
    </tr>
</table>
</form>

</div>
</div>

	<div id="dvUpdate" class="E_pop_box LdPopWidth600px" style="margin-top:-50px;display: none;position: absolute; z-index: 9999; visibility: visible;">
        <div class="E_pop_tit">
            <strong class="E_ptita">{'GETMAIL'|@getFixedLabel}</strong>
            <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('dvUpdate');"></button>
        </div>
        <table class="settingPopTable lasttdbordernon pad2010" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td>
                    <div><div id="dv" style="float: left;"></div></div>
                    <div style="float:left;background-color:#FFFFFF;width:410px;height:20px;border:1px solid #ddd;border-radius: 5px;overflow:hidden;">
                        <div id="dvprogress" style="float:left;width:0;height:20px;background-color:#3B7CFF;overflow:hidden;">&nbsp;</div>
                    </div>
                    <div class="clear"></div>
                    <div style="margin-top:10px;" id="dvc">{'GETTINGMAILINGLIST'|@getFixedLabel}</div>
                </td>
            </tr>
        </table>
     </div> 
     <div id="layer" style=" display:none;height: 100%; width: 100%; position: fixed; left: 0px; top: 0px; background-color: rgb(128, 128, 128); z-index: 9998; opacity: 0.6;"></div> 
<script>

{literal}
var popupobj=new Object();
var email_account_id=0;
var email_page_start=1;
var email_searchscope='SmOwner_Search_All';
var email_search_content='';
var email_search_field="";
var email_listtype='receive';
var email_deleted=0;
var email_orderby='';
var email_ordertype='';
var email_listdb_type='';
var mailaccount_id=0;
var selectallrecord='no';
popupobj.divid="deskemail";
popupobj.type='listemail';
CrmPopup.global_listPopupObj.push(popupobj);
var global_setunread=0;
function initglobal_var()
{
      email_account_id=0;
     email_page_start=1;
     email_searchscope='SmOwner_Search_All';
     email_search_content='';
     email_search_field="";
     email_deleted=0;
     email_listtype='receive';
     email_orderby='';
     email_ordertype='';
     email_listdb_type='';
     global_setunread=0;
     selectallrecord='no';
     
      
}
function initSwitchPop()
{
    ld("#EmailContentDetails").css("display",'none');
    ld("#emailContents").css("display",'none');
    ld("#EmailSettings").css('display','none');
    ld("#send_email_Frame").css('display','none');
    
}
getListMailFromMailServer();

//写邮件
function WriteEmail()
{       
        initSwitchPop();
        ld("#send_email_Frame").css('display','block');
        
       var mailaccountid=0;
       var accounttag= ld("#"+popupobj.divid).find(".email_menu_active").attr("tag");
      
        if(accounttag!=undefined&&accounttag.indexOf("emaillistinfo")>=0)
        {
            accounttags=accounttag.split("_");
            mailaccountid=accounttags[1];
            
        }
        var url="index.php?module=Emails&action=EmailsAjax&file=WriteEmail&mailaccountid="+mailaccountid;
        ld.ajax({
        url: url,
        type: 'POST',
        data:{"namename": "uname", "namenameage": 18},
       dataType:'json',
        async: false,//
        timeout: 10000,
       
        success: function(data)
        {
           
            if(data.code==1)
            {
            
               ld("#send_email").html(data.result.content);
                
            }
        }
       });

     
      //  window.open("index.php?module=Emails&action=WriteEmail&mailaccountid="+mailaccountid);
}

{/literal}

</script>