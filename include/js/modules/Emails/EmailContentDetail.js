/***邮件明细***********/


/**回复*****/
    function Email_Reply(mailrecordid)
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
        var url="index.php?module=Emails&action=EmailsAjax&file=WriteEmail&mailrecordid="+mailrecordid+"&type=reply";
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
                ld("select[name=from_email] option").each(function() {//更新发件人选项为所回复邮件的收件人
                    if (ld(this).text() == data.result.current_sender) {
                        ld(this).prop('selected', true);
                        return false;
                    }
                });
            }
        }
       });
       // window.open("index.php?module=Emails&action=WriteEmail&mailrecordid="+mailrecordid+"&type=reply");
    }


/**回复*****/
function Email_Reply_All(mailrecordid)
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
    var url="index.php?module=Emails&action=EmailsAjax&file=WriteEmail&mailrecordid="+mailrecordid+"&type=replyAll";
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
                ld("select[name=from_email] option").each(function() {//更新发件人选项为所回复邮件的收件人
                    if (ld(this).text() == data.result.current_sender) {
                        ld(this).prop('selected', true);
                        return false;
                    }
                });
            }
        }
    });
    // window.open("index.php?module=Emails&action=WriteEmail&mailrecordid="+mailrecordid+"&type=reply");
}
    /***转发***/
    function Email_Transfer(mailrecordid)
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
        //edit:can 2021-01-08 44180: （https://61mis.com/kfbcrm [^]）邮件管理-收件箱，选择一封邮件，点击回复之后页面显示空白
        var url="index.php?module=Emails&action=EmailsAjax&file=WriteEmail&mailrecordid="+mailrecordid+"&type=transfer";
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
       
      //  window.open("index.php?module=Emails&action=WriteEmail&mailrecordid="+mailrecordid+"&type=transfer");
    }
  
    function getNexEmail(pagestart,mailrecordid)
    {
        var url="index.php?module=Emails&action=EmailsAjax&file=getNextPrevRecorid&type=next&mailrecordid="+mailrecordid;
        ld.ajax({
            url: url,
            type: 'POST',
            data:{"namename": "uname", "namenameage": 18},
           dataType:'json',
            async: true,//
            timeout: 10000,
           
            success: function(data)
            {
                if(data.code==1)
                {
                    email_page_start=pagestart;
                   
                         //  var url= "index.php?module=Emails&action=EmailContentDetail&mailrecordid="+data.result.mailrecordid+"&pagestart="+pagestart;     
                      //  window.location=url;
                      EmailContentClick("",data.result.mailrecordid);
                    
                }
            }
           });
      
    }
    function getPrevEmail(pagestart,mailrecordid)
    {
        var url="index.php?module=Emails&action=EmailsAjax&file=getNextPrevRecorid&type=prev&mailrecordid="+mailrecordid+"&pagestart="+pagestart;
        
        ld.ajax({
            url: url,
            type: 'POST',
            data:{"namename": "uname", "namenameage": 18},
           dataType:'json',
            async: true,//
            timeout: 10000,
           
            success: function(data)
            {
                if(data.code==1)
                {
                   //var url= "index.php?module=Emails&action=EmailContentDetail&mailrecordid="+data.result.mailrecordid+"&pagestart="+pagestart;     
                   //window.location=url;
                    email_page_start=pagestart;
                    EmailContentClick("",data.result.mailrecordid);
                }
            }
           });
    }
    
    
    function EmailContent_Back()
    {
        initSwitchPop();
        getmailistfromdb();
        console.log(11)
        ld("#emailContents").css("display",'block');
        
    }