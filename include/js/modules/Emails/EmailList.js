/*
收信
*/
function emailreceiveClick()
{
   getListMailFromMailServer();
}
function getListMailFromMailServer()
{
    initSwitchPop();
    var prepopupobj = CrmPopup.getPopupObj('last');
    var url = 'index.php?module=Emails&action=EmailsAjax&file=getUndownloadmail&account_id=' + email_account_id;
    var html = '';
    html += '<div id="dvUpdate" class="ld-pop-container">';
    html += '<div><div id="dv" style="float: left;"></div></div>';
    html += '<div style="float:left;background-color:#FFFFFF;width:100%;height:20px;border:1px solid #ddd;border-radius: 5px;overflow:hidden;">';
    html += '<div id="dvprogress" style="float:left;width:0;height:20px;background-color:#3B7CFF;overflow:hidden;"></div>';
    html += '</div>';
    html += '<div class="clear"></div>';
    html += '<div style="margin-top:10px;" id="dvc">' + arrJsPopLabel['GETTINGMAILINGLIST'] + '...</div>';
    html += '</div>';
    var popupobj = CrmPopup.load(arrJsPopLabel['GETMAIL'], '', '', 'LdPopWidth600px', 'Emails', '', '', '', '');
    popupobj.show(html);
    ldAjax(url, {"namename": "uname", "namenameage": 18}, function (data) {
        if (data.code == 1) {
            var divobj = ld('#'+popupobj.divid);

            var cur_t = 0;
            var total_len = 0;
            if (data.result.popusers != undefined && data.result.popusers.length > 0) {
                //获取需要下载的邮件总数量
                var popusers_length = data.result.popusers.length;
                for (var i = 0; i < popusers_length; i++) {
                    var popuser = data.result.popusers[i]['popuser'];
                    total_len = data.result[popuser].list.length + total_len;
                }

                for (var i = 0; i < popusers_length; i++) {
                    var popuser = data.result.popusers[i]['popuser'];
                    if (data.result[popuser].unreadcount > 0){
                        ld("#" + prepopupobj.divid + " [tag=emaillist_" + data.result.popusers[i]['account_id'] + "]").html("（" + data.result[popuser].unreadcount + "）");
                    }
                    var list_length = data.result[popuser].list.length;
                    if (list_length > 0) {
                        for (var j = 0; j < list_length; j++) {
                            cur_t++;
                            divobj.find('#dvprogress').css('width',(cur_t/total_len)*100 + "%");
                            divobj.find('#dvprogress').html(cur_t + "/" + total_len);
                            var seqno = data.result[popuser].list[j];
                            getUnDownLoadEmailContent(data.result.popusers[i]['account_id'], seqno);
                        }
                    }

                }


            }
            //zkt 20220930 BUG0057330邮件管理-标题不对应
            //获取邮件
            getmailistfromdb();
        }
        DelProgressObjs();
        divobj.find('#dvprogress').css('width', "100%");
        setTimeout(function (){
            popupobj.CancelEvent();
        },200)
    })
}

 /*
 获取邮件内容
 */
 function  getUnDownLoadEmailContent(account_id,emailseqno){
    var url ='index.php?module=Emails&action=EmailsAjax&file=getEmailContent&emailseqno='+emailseqno+"&account_id="+account_id+"&email_listdb_type="+email_listdb_type;
    ldAjax(url,{"namename": "uname", "namenameage": 18},function (data) {
        if(data.code==1)
        {

        }
    })
 }
 //获取未读邮件
 function getUnReadMailList()
 {
    //alert('ass');
   // initglobal_var();
    global_setunread=1;
    getmailistfromdb();
 }
 function getmailistfromdb()
 {
    var url ='index.php?module=Emails&action=EmailsAjax&file=getDbListMail&account_id='+email_account_id+"&pagestart="+email_page_start+"&SearchScope="+email_searchscope+"&searchtext="+encodeURIComponent(trim(email_search_content))+"&searchfield="+email_search_field+"&email_deleted="+email_deleted+"&listtype="+email_listtype;
    url+="&orderby="+email_orderby+"&ordertype="+email_ordertype+"&email_listdb_type="+email_listdb_type;
    url+="&setunread="+global_setunread;
    ldAjax(url,{"namename": "uname", "namenameage": 18},function (data){
        if(data.code==1)
        {
            selectallrecord='no';
            ld("#email_con").html(data.result.content);
            //获取可用高度，然后计算列表最大高度
            var h = ld('#emailContents').get(0).clientHeight-120;
            ld('#rssScroll').css('max-height',h+'px');

            ld("#dvUpdate").css("display",'none');
            ld("#layer").css("display",'none');
            if(email_listdb_type=='pop')
            {
                //email_listdb_type
            }
        }
        DelProgressObjs();
    })
 }
 /**
 获取已发送邮件
 **/
 function getsendlist(obj)
 {
   initSwitchPop();
  
   ld("#emailContents").css("display",'block');
    initglobal_var();
     email_listtype='smtp';
    email_listdb_type='smtp';
    setLeftChooseColor(obj);
    getmailistfromdb();
 }
 /*
 分页
 */
 function EmailPageList(module,pagestart)
 {
    email_page_start=pagestart;
    getmailistfromdb();
 }
 /*
 邮件账号点击事件
 */
function emailaccountClick(account_id,obj)
{
    //设置选择后的颜色
    setLeftChooseColor(obj);
    initglobal_var();//重新初始化变量
    email_account_id=account_id;
    getListMailFromMailServer();
    if(empty(popupobj) || popupobj.divid != "deskemail"){
        var popupobj=new Object();
        popupobj.divid="deskemail";
        popupobj.type='listemail';
        CrmPopup.global_listPopupObj.push(popupobj);
    }
    var h = ld('#emailContents').get(0).clientHeight-120;
    ld('#rssScroll').css('max-height',h+'px');
}
 
 function EmailContentClick(obj,mailrecordid)
 {
    initSwitchPop();
    ld("#EmailContentDetails").css("display",'block');
    //删除加粗
    if(obj!=undefined&&obj!="")
        obj.parent().removeClass("folder");
    
    
     var url="index.php?module=Emails&action=EmailsAjax&file=EmailContentDetail&mailrecordid="+mailrecordid+"&pagestart="+email_page_start;     
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
               ld("#EmailDetails").html(data.result.content);
               
            }
        }
       });
       
   
 }
 
 ///用户查询范围改变
//BY LD Can

function EmailSmOwnerSearchScopeChange (selectView,module,parenttab)
{
     var popupobj=CrmPopup.getPopupObj("last");
  	 email_searchscope = encodeURIComponent(selectView.options[selectView.options.selectedIndex].value);
    
	if('smowner_search_senior' == email_searchscope){//高级
		SmOwnerSearchSenior("Emails",email_searchscope);return false;
	}
     getmailistfromdb();
     
     
}
/*
列表查询
*/
function email_Searchfn()
{
    var popupobj=CrmPopup.getPopupObj("last");
    email_search_content=ld("#"+popupobj.divid+" [name=search_text]").val();
    var selectView=document.getElementById('search_field');
    
    email_search_field=encodeURIComponent(selectView.options[selectView.options.selectedIndex].value);
    getmailistfromdb();
}
function getdeletelist(obj)
{
    setLeftChooseColor(obj);
    initglobal_var();////重新初始化变量
   email_deleted=1;
   email_listtype='deleted';
   
   getmailistfromdb();
   
}
/**
星标邮件
*/
function getstarmaillist(obj)
{
      
  setLeftChooseColor(obj);
    
     initglobal_var();////重新初始化变量

   email_listtype='starmail';
   
   getmailistfromdb();
}
/*
设置左边树节点选择后的颜色
*/
function setLeftChooseColor(obj)
{
    //var popupobj = CrmPopup.getPopupObj("last");//edit:duan  reason:点击其他栏目后高亮不消失的问题。
    var objs=ld('.emailMidBar .email_menu_active');
    ld.each(objs,function(i){
        ld(this).removeClass('email_menu_active');
    }) ;
    ld(obj).addClass('email_menu_active');
}
function email_orderlist(orderby,ordertype)
{
    //wsh 2024-06-25 BUG20240618-82 邮件管理，收件箱显示了28条邮件，点按时间排序-或者点发件人排序，邮件数量变成34条邮件
     // initglobal_var();////重新初始化变量

   email_orderby=orderby;
   if(ordertype==''||ordertype=='asc')
   {
    email_ordertype='dsc';
   }
   else
   {
    email_ordertype='asc';
   }
   getmailistfromdb();
}
function setstarmail(record)
{
    popupobj.type='llistemail';
    popupobj.record=record;
    updateStarMail('');
}
function updateStarMail(starmail)
{
    var popupobj=CrmPopup.getPopupObj("last");
    var url ='index.php?module=Emails&action=EmailsAjax&file=updateStarMail&starmail='+starmail+"&selectallrecord="+selectallrecord;
    var idstring="";
     if(popupobj.type=='listemail')
     {
        var list_chkbox=ld("#"+popupobj.divid+" [name=mc_box]");
       
        ld.each(list_chkbox,function(i)
        {
            if(ld(this).is(':checked'))
            {
                idstring+=ld(this).attr("tag")+",";
            }
        });
        
        idstring="&idstring="+idstring;
        
     }
     else
     {
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
       
        success: function(data)
        {
           
            if(data.code==1)
            {
                if(popupobj.type=='llistemail')
                {
                    popupobj.type='listemail';
                    popupobj.record=0;
                }
                if(popupobj.type=='listemail')
                {
                   getmailistfromdb();
                }
                else//查看界面删除
                {
                    
                }
                
            }
        }
       });
}
function updateMailSeen(seen)
{
    var popupobj=CrmPopup.getPopupObj("last");
    var url ='index.php?module=Emails&action=EmailsAjax&file=updateMailSeen&mailseen='+seen+"&selectallrecord="+selectallrecord;
    var idstring="";
     if(popupobj.type=='listemail')
     {
        var list_chkbox=ld("#"+popupobj.divid+" [name=mc_box]");
       
        ld.each(list_chkbox,function(i)
        {
            if(ld(this).is(':checked'))
            {
                idstring+=ld(this).attr("tag")+",";
            }
        });
        
        idstring="&idstring="+idstring;
        
     }
     else
     {
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
       
        success: function(data)
        {
           
            if(data.code==1)
            {
            
                if(popupobj.type=='listemail')
                {
                   getmailistfromdb();
                }
                else//查看界面删除
                {
                    
                }
                
            }
        }
       });
}
//全选所有记录
function emailselectallrecord()
{
    var popupobj=CrmPopup.getPopupObj("last");
     ld("#email_span_detail_all").css("display",'none');
     ld("#email_span_detail_unall").css("display",'');
     selectallrecord='yes';
    ld("#"+popupobj.divid+" [name=selectall]").prop("checked", true);
    ld("#"+popupobj.divid+" [name=mc_box]").prop("checked", true);
}
function emailunselectallrecord()
{
    var popupobj=CrmPopup.getPopupObj("last");
    ld("#email_span_detail_unall").css("display",'none');
    ld("#email_span_detail_all").css("display",'');
     selectallrecord='no';
    ld("#"+popupobj.divid+" [name=selectall]").prop("checked", false);
    ld("#"+popupobj.divid+" [name=mc_box]").prop("checked", false);
}
/*
全选邮件
*/
function selectallmails(bol)
{
    var popupobj=CrmPopup.getPopupObj("last");
    if(bol)
    {
        ld("#"+popupobj.divid+" [name=mc_box]").prop("checked", true);
         ld("#email_tr_detail_all").css("display",'');
         ld("#email_span_detail_all").css("display",'');
    }
    else
    {
         ld("#"+popupobj.divid+" [name=mc_box]").prop("checked", false);
          ld("#email_tr_detail_all").css("display",'none');
          ld("#email_span_detail_unall").css("display",'none');
          ld("#email_span_detail_all").css("display",'none');
    }
   
}
/*
清空已删除邮件
*/
function cleardeletemail()
{
    //36417: 邮件管理-已删除：点击“清空”，给出提示信息“是否要清空此文件夹中的邮件？”
    var module='Emails';
    
    RemindsMsg("","LdPopWidth400px",module,"yes","yes",arrJsPopLabel['DELEMPTYMAIL']);
        //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        //已删除邮件列表-》删除按钮
    deleted=2;
    
    var url ='index.php?module=Emails&action=EmailsAjax&file=deleteemail&email_deleted=2&type=clear';
  

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
                //wsh 2024-06-24 BUG20240617-59 邮件管理，已删除点清空后，页面没有立即刷新掉清空的邮件
                if(popupobj.type === 'listemail' || popupobj.type === 'remindmsg')
                {
                   getmailistfromdb();
                }
                else//查看界面删除
                {
                    
                }
                
            }
        }
       });
     });
}

//wsh 2024-07-11 BUG20240624-54
//还原已删除邮件
function EmailReduction(){
    var popupObj = CrmPopup.getPopupObj('last');
    var url ='index.php?module=Emails&action=EmailsAjax&file=ReductionEmail&select_all_record='+selectallrecord;
    var ids = "";
    if(popupobj.type === 'listemail')
    {
        var list_chkbox=ld("#"+popupobj.divid+" [name=mc_box]");
        ld.each(list_chkbox,function(i)
        {
            if(ld(this).is(':checked'))
            {
                ids+=ld(this).attr("tag")+",";
            }
        });
    }
    else {
        ids = popupobj.record;
    }
    if (empty(ids)) {
        MessagePopup.TipOne_warning();
        return false;
    }
    url+="&idstring="+ids;
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
                if(popupobj.type=='listemail')
                {
                    getmailistfromdb();
                }
                else//查看界面删除
                {
                }
            }else{
                MessagePopup.TipZero_error(data.msg);
            }
        }
    });

}
 /**
 删除和彻底删除，1：删除，2：彻底删除
**/
 function EmailDelete(deleted)
 {
     var popupobj=CrmPopup.getPopupObj("last");
    if(email_deleted==1)
    {
        //已删除邮件列表-》删除按钮
        deleted=2;
    }
    var url ='index.php?module=Emails&action=EmailsAjax&file=deleteemail&email_deleted='+deleted+"&selectallrecord="+selectallrecord;
    var ids="";
     if(popupobj.type=='listemail')
     {
        var list_chkbox=ld("#"+popupobj.divid+" [name=mc_box]");
       
        ld.each(list_chkbox,function(i)
        {
            if(ld(this).is(':checked'))
            {
                ids+=ld(this).attr("tag")+",";
            }
        });
     }
     else
     {
         ids = popupobj.record;
     }
     //BUG0072203 ls 20230905 kfbcrm-邮件管理 删除功能异常
     if (empty(ids)) {
         MessagePopup.TipOne_warning();
         return false;
     }

     url+="&idstring="+ids;

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
            
                if(popupobj.type=='listemail')
                {
                   getmailistfromdb();
                }
                else//查看界面删除
                {
                    
                }
                
            }else{
                MessagePopup.TipZero_error(data.msg);
            }
        }
       });
 }