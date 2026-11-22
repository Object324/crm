
 /*******邮件账号相关操作******/
 
/*新建/编辑邮箱配置*/
function createmailboxSetup(){
    mailaccount_id=0;
    mailboxSetup();
}
function mailboxSetup(obj){
    var url ='index.php?module=Emails&action=EmailsAjax&file=mailboxsetup&mailaccountid='+mailaccount_id;
    ld.ajax({
        url: url,
        type: 'POST',
        data:{"namename": "uname", "namenameage": 18},
        dataType:'json',
        async: false,//
        timeout: 10000,
        success: function(data){
            if(data.code==1){
                var popupobj=CrmPopup.load(data.result.title,Savemailboxsetup,"", "LdPopWidth600px","Emails","",data.result.oktext,"",data.result.canceltext);
                popupobj.show(data.result.content);
                if(mailaccount_id>0){
                    ld("#"+popupobj.divid+" [name=mail_username]").attr("readonly",true);
                }
            }
        }
    });
}
function EditmailboxSetup(account_id){
    mailaccount_id=account_id;
    mailboxSetup();
}
function Savemailboxsetup(){
    var module='Emails';
    var popupobj=CrmPopup.getPopupObj('last');
    var url ='index.php?module=Emails&action=EmailsAjax&file=savemailboxsetup';
    var mailpwd=ld("#"+popupobj.divid+" [name=mail_pwd]").val();
    var mail_username=ld("#"+popupobj.divid+" [name=mail_username]").val();
    var mailaccountname=ld("#"+popupobj.divid+" [name=mailaccountname]").val();
    var chk_pop3_ssl=ld("#"+popupobj.divid+" [name=chk_pop3_ssl]").prop('checked'); 
    var mailreceivetype=ld("#"+popupobj.divid+" [name=mailreceivetype]").val();
    var pop3_ssl_port=ld("#"+popupobj.divid+" [name=pop3_ssl_port]").val();
    var smtp_ssl_port=ld("#"+popupobj.divid+" [name=smtp_ssl_port]").val();
    var chk_smtp_ssl=ld("#"+popupobj.divid+" [name=chk_smtp_ssl]").prop('checked');
    var smtp_mailaccountname=ld("#"+popupobj.divid+" [name=smtp_mailaccountname]").val();
    if(chk_pop3_ssl){
        chk_pop3_ssl='yes';
    }
    else{
        chk_pop3_ssl='no';
    }
    if(chk_smtp_ssl){
        chk_smtp_ssl='yes';
    }
    else{
        chk_smtp_ssl='no';
    }
    if(trim(mail_username)==''){
        RemindsMsg("","LdPopWidth400px",module,"yes","","邮箱账号不能为空！");
        return false;
    }
    if(trim(mailpwd)==""){
        RemindsMsg("","LdPopWidth400px",module,"yes","","密码不能为空！");
        return false;
    }
    if(trim(mailaccountname)==''){
        RemindsMsg("","LdPopWidth400px",module,"yes","","POP服务器不能为空！");
        return false;
    }
    if(trim(smtp_mailaccountname)==""){
        RemindsMsg("","LdPopWidth400px",module,"yes","","SMTP服务器不能为空！");
        return false;
    }
    //edit:can 20211018 48284: （81mis.com/kfbcrm）（客户问题）营销》邮件管理，新建邮件，绑定阿里云邮箱时，提示服务器连不上
    url+="&mailpwd="+encodeURIComponent(mailpwd)+"&mail_username="+mail_username+"&mailaccountname="+mailaccountname+"&chk_pop3_ssl="+chk_pop3_ssl+"&mailreceivetype="+mailreceivetype+"&pop3_ssl_port="+pop3_ssl_port;
    url+="&mailaccount_id="+mailaccount_id+"&chk_smtp_ssl="+chk_smtp_ssl+"&smtp_ssl_port="+smtp_ssl_port+"&smtp_mailaccountname="+smtp_mailaccountname;
    
    ld.ajax({
        url: url,
        type: 'POST',
        data:{"namename": "uname", "namenameage": 18},
        dataType:'json',
        async: false,//
        timeout: 10000,
        success: function(data){
            if(data.code==1){
                if(data.result.type=='create'){
                    ld("#li_email_account_list").append('<a title="'+data.result.popuser+'" class="emailuserlist useraddr_active" onclick="javascript:emailaccountClick('+data.result.id+',this)">'+data.result.popuser+'<span tag="emaillist_'+data.result.id+'"></span></a>');
                }       
                else{
                   
                }
                popupobj.CancelEvent();
                mailboxList(ld("#"+popupobj.divid+" [name=mailboxset_name]"));
            }
            else{
                // alert(data.msg);
                RemindsMsg("","LdPopWidth400px",module,"yes","",data.msg);
                return false;
            }
        }
    });
}
Savemailboxsetup.funname="Savemailboxsetup";
function mailboxList(obj){
    initSwitchPop();
    ld("#emailContents").css("display",'block');
    //邮件账户列表
    var objs=ld('#'+popupobj.divid).find('.email_menu_active');
    ld.each(objs,function(i){
        ld(this).removeClass('email_menu_active');
    });
    ld(obj).parent().addClass('email_menu_active');
    var url ='index.php?module=Emails&action=EmailsAjax&file=getmailboxlist';
    ld.ajax({
        url: url,
        type: 'POST',
        data:{"namename": "uname", "namenameage": 18},
        dataType:'json',
        async: false,//
        timeout: 10000,
        success: function(data){
            if(data.code==1){
                ld("#email_con").html(data.result.content);
            }
            else{
                // alert(data.msg);
                RemindsMsg("","LdPopWidth400px",module,"yes","",data.msg);
                return false;
            }
        }
    });
}

function email_chkclick(event){
    /*var e=event||window.event;
    window.event? window.event.cancelBubble = true : e.stopPropagation();
    return false;*/
}
/*
邮件账户全选
*/
function selectallmailbox(bol){
    var popupobj=CrmPopup.getPopupObj("last");
    if(bol){
        ld("#"+popupobj.divid+" [name=emailbox]").prop("checked", true);
    }
    else{
        ld("#"+popupobj.divid+" [name=emailbox]").prop("checked", false);
    }
}
function delMailBox(){
    //ls 2021-11-12 0048724: （https://81mis.com/kfbcrm/index.php [^]）邮箱管理》邮箱设置，先编辑邮箱，然后选中任意邮箱，操作删除没有反应
    var popupobj=CrmPopup.getPopupObj("last");
    //删除邮箱账号
    var url ='index.php?module=Emails&action=EmailsAjax&file=DelMailBox';
    var idstring="";
    if(popupobj.type=='listemail'){
        var list_chkbox=ld("#"+popupobj.divid+" [name=emailbox]");
        ld.each(list_chkbox,function(i){
            if(ld(this).is(':checked')){
                idstring+=ld(this).attr("tag")+",";
            }
        });
        idstring="&idstring="+idstring;
    }
    else{
        idstring="&idstring="+popupobj.record;
    }
    url+=idstring;
    ld.ajax({
        url: url,
        type: 'POST',
        data:{"namename": "uname", "namenameage": 18},
        dataType:'json',
        async: false,//
        timeout: 10000,
        success: function(data){
            if(data.code==1){
                for(var i=0;i<data.result.ids.length;i++){
                    ld("#li_email_account_list").find('[tag=emaillist_'+data.result.ids[i]+']').parent().remove();
                }
                mailboxList(ld("#"+popupobj.divid+" [name=mailboxset_name]"));
            }
            else{
                // alert(data.msg);
                RemindsMsg("","LdPopWidth400px",module,"yes","",data.msg);
                return false;
            }
        }
    });
}
function sslPort(){
    var popupobj=CrmPopup.getPopupObj("last");
    if(ld("#"+popupobj.divid+" [name=chk_pop3_ssl]").is(':checked')){
        ld("#"+popupobj.divid+" [name=pop3_ssl_port]").val(995);
    }
    else{
        // ld("#"+popupobj.divid+" [name=pop3_ssl_port]").attr("readonly",false);
        ld("#"+popupobj.divid+" [name=pop3_ssl_port]").val(110);
    }
}
function smtp_sslPort(){
    var popupobj=CrmPopup.getPopupObj("last");
    if(ld("#"+popupobj.divid+" [name=chk_smtp_ssl]").is(':checked')){
        ld("#"+popupobj.divid+" [name=smtp_ssl_port]").val(465);
    }
    else{
        // ld("#"+popupobj.divid+" [name=chk_smtp_ssl]").attr("readonly",false);
        ld("#"+popupobj.divid+" [name=smtp_ssl_port]").val(25);
    }
}