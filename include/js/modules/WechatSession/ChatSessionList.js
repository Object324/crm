function ChatSessionList() {
    var that = this;
    that.popupobj = CrmPopup.getPopupObj('last');
    that.loading = false;//防止滚动条来回滚动多次加载

    ld('#searchbymember #sessionlist').scroll(function () {
        if(that.loading){
            return false;
        }
        var scrollableDiv = ld("#searchbymember #sessionlist");
        if (ld('#searchbymember #sessionlist').scrollTop() + ld('#searchbymember #sessionlist').height() >= scrollableDiv[0].scrollHeight) {
            that.nextPage();
        }
    });

    this.setSessonListEvent=function(){
        //当前 搜索成员列表 文本框   绑定change事件
        var personobj = ld("#" + that.popupobj.divid + " [name=searchsession]");
        ld(personobj).unbind("keyup").bind("keyup", function (event) {
            var e = event ? event :(window.event ? window.event : null);
            if(e.keyCode==13){
                that.search();
            }
        });

        //会话类型（内部、外部、群聊）  绑定click事件
        var session_type_event = ld("#" + that.popupobj.divid + " [name=session_type_event] li");
        ld(session_type_event).unbind("click").bind("click", function () {
            ld("#" + that.popupobj.divid + " [name=session_type_event] li").removeClass("talktabsselected");
            ld(this).addClass("talktabsselected");
            ld("#" + that.popupobj.divid + " [name=session_type]").val(ld(this).attr("value"));
            that.search();
        })


        //会话列表点击会话成员
        var personobj = ld("#" + that.popupobj.divid + " #sessionlist [block=session]");
        ld(personobj).unbind("click").bind("click", function () {
            ld("#" + that.popupobj.divid + " #sessionlist [block=session]").removeClass("weui-cell-action");
            ld(this).addClass("weui-cell-action");//点击成员背景色

            ld("#" + that.popupobj.divid + " [name=searchcontent]").val("");//右边聊天记录 搜索框
            ld("#" + that.popupobj.divid + " [name=msgtype_event] li").removeClass("talktabsselected");//右边聊天记录 聊天内容的类型
            ld("#" + that.popupobj.divid + " [name=msgtype_event] li:first-child").addClass("talktabsselected");//右边聊天记录 聊天内容的类型
            ld("#" + that.popupobj.divid + " [name=msgtype]").val("all");
            ld("#" + that.popupobj.divid + " [name=begin_date]").val("");
            ld("#" + that.popupobj.divid + " [name=end_date]").val("");

            var searchsessionobj = ld(this).find('[name=wx_userid]'); //联系人 tolist
            if (empty(searchsessionobj)) {
                searchsessionobj = ld(this).find('[name=roomid]');//群聊 roomid
                ld("#" + that.popupobj.divid + " [name=session_roomid]").val(searchsessionobj.val());
                ld("#" + that.popupobj.divid + " [name=session_wx_userid]").val("");
            }
            else{//单聊
                ld("#" + that.popupobj.divid + " [name=session_wx_userid]").val(searchsessionobj.val());
                ld("#" + that.popupobj.divid + " [name=session_roomid]").val("");
            }

            // ld("#" + that.popupobj.divid + " [name=session_last_name]").val(ld(this).text());
            WechatSessionobj.ChatDataListobj.search();//点击会话列表的人
        })
    }


    /*
    * 中间 会话列表搜索
    * */
    this.search=function(){
        var member_wx_userid = ld("#"+that.popupobj.divid+" [name=member_wx_userid]").val();//左边成员列表的值
        if (empty(member_wx_userid)){
            alert("请先选择一个成员！");
            return false;
        }

        var search = ld("#"+that.popupobj.divid+" [name=searchsession]").val();//中间搜索框的值
        var session_type = ld("#"+that.popupobj.divid+" [name=session_type]").val();//中间会话类型的值
        var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=ListView&searchbytype=searchbymember&block=sessionlist&ajax=true&member_wx_userid="+encodeURIComponent(member_wx_userid)+"&search="+encodeURIComponent(search)+"&session_type="+encodeURIComponent(session_type);
        ldAjax(surl,"",function(data){
            if(data.code==1){
                ld("#"+that.popupobj.divid+" #sessionlist").html(data.result.content);
                that.setSessonListEvent();  //重新绑定会话列表事件

                ld("#" + that.popupobj.divid + " #sessionlist [block=session]:first-child").addClass("weui-cell-action");//搜索完默认选中第一个会话人
                if (session_type == 'groupchat') {
                    ld("#" + that.popupobj.divid + " [name=session_roomid]").val(ld("#" + that.popupobj.divid + " #sessionlist [block=session]:first-child input").val());//中间会话列表 群
                    ld("#" + that.popupobj.divid + " [name=session_wx_userid]").val("");
                }
                else{
                    var page = data.result.page;//当前页
                    var page_num = data.result.page_num;//总页
                    ld("#"+that.popupobj.divid+" #sessionlist").data('page',page);
                    ld("#"+that.popupobj.divid+" #sessionlist").data('page_num',page_num);
                    ld("#" + that.popupobj.divid + " [name=session_wx_userid]").val(ld("#" + that.popupobj.divid + " #sessionlist [block=session]:first-child input").val());//中间会话列表 会话人
                    ld("#" + that.popupobj.divid + " [name=session_roomid]").val("");
                }
                // 循环给头像栏赋值高度，方便头像栏向上对齐
                ld("#"+that.popupobj.divid+" #sessionlist .weui-cells .weui-cell").each(function(){
                    let bdHeight = ld(this).find('.weui-cell__bd').height();
                    if(parseInt(bdHeight) > 40){
                        ld(this).find('.weui-cell__hd').css('height', bdHeight+'px');
                    }
                });
                WechatSessionobj.ChatDataListobj.search();//中间和右边的一同显示
                DelProgressObjs();

                if(wechat_wxOpenDataobj!=undefined&&typeof wechat_wxOpenDataobj!="undefined"){
                    var tmpobj = new Object();
                    tmpobj.divid = "sessionlist";
                    wechat_wxOpenDataobj.bindAllOpenDataByPopupObj(tmpobj);
                    // wechat_wxOpenDataobj.bindAllOpenDataByPopupObj(that.popupobj);
                }
            }
            that.loading = false;
        })
    }

    this.nextPage = function () {
        var page = parseInt(ld("#"+that.popupobj.divid+" #sessionlist").data('page'));
        var page_num = parseInt(ld("#"+that.popupobj.divid+" #sessionlist").data('page_num'));

        if (page >= page_num){
            return false;
        }
        that.loading = true;

        var member_wx_userid = ld("#"+that.popupobj.divid+" [name=member_wx_userid]").val();//左边成员列表的值
        var search = ld("#"+that.popupobj.divid+" [name=searchsession]").val();//中间搜索框的值
        var session_type = ld("#"+that.popupobj.divid+" [name=session_type]").val();//中间会话类型的值
        var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=ListView&searchbytype=searchbymember&block=sessionlist&ajax=true&member_wx_userid="+encodeURIComponent(member_wx_userid)+"&search="+encodeURIComponent(search)+"&session_type="+encodeURIComponent(session_type);
        surl += "&page="+(page+1);
        ldAjax(surl,"",function(data){
            if(data.code==1){
                ld("#"+that.popupobj.divid+" #sessionlist").append(data.result.content);
                that.setSessonListEvent();  //重新绑定会话列表事件

                var page = data.result.page;//当前页
                var page_num = data.result.page_num;//总页
                ld("#"+that.popupobj.divid+" #sessionlist").data('page',page);
                ld("#"+that.popupobj.divid+" #sessionlist").data('page_num',page_num);

                // 循环给头像栏赋值高度，方便头像栏向上对齐
                ld("#"+that.popupobj.divid+" #sessionlist .weui-cells .weui-cell").each(function(){
                    let bdHeight = ld(this).find('.weui-cell__bd').height();
                    if(parseInt(bdHeight) > 40){
                        ld(this).find('.weui-cell__hd').css('height', bdHeight+'px');
                    }
                });
                //WechatSessionobj.ChatDataListobj.search();//中间和右边的一同显示
                DelProgressObjs();

                if(wechat_wxOpenDataobj!=undefined&&typeof wechat_wxOpenDataobj!="undefined"){
                    var tmpobj = new Object();
                    tmpobj.divid = "sessionlist";
                    wechat_wxOpenDataobj.bindAllOpenDataByPopupObj(tmpobj);
                    // wechat_wxOpenDataobj.bindAllOpenDataByPopupObj(that.popupobj);
                }
            }
            that.loading = false;
        })
    }

    //同步联系人姓名/群名
    this.syncContactNameAndGroupName = function(){
        var crmPopupobj=CrmPopup.load("","","","450",'WechatSession',"","","","");
        crmPopupobj.prevshow();

        var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=syncName";
        ldAjax(surl,"",function(data){
            if(data.code==1){
                crmPopupobj.setParams(data.result.title,that.saveSyncContactNameAndGroupName,"","450",'WechatSession',"",data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.Okfun.funname = 'saveSyncContactNameAndGroupName';
                crmPopupobj.show(data.result.content);
            }
            DelProgressObjs();
        })
    }

    //保存
    this.saveSyncContactNameAndGroupName = function(){
        var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=syncName&mode=save";
        var popupobj = CrmPopup.getPopupObj("last");
        if (ld("#"+popupobj.divid+" [name=sync_group_name]").prop("checked") || ld("#"+popupobj.divid+" [name=isAppMarket]").val() == 'false') {  //1、勾选了同步群名称，则不管是否为应用市场安装  都需要填写secret，2、非应用市场安装需要填写secret
            var secret = ld("#"+popupobj.divid+" [name=secret]").val().trim();
            if (empty(secret)){
                RemindsMsg("","LdPopWidth400px","","yes","",'secret '+arrJsPopLabel['CANOTEMPTY']);
                return false;
            }
            surl += "&secret="+secret;
        }

        var sync_external_contact = ld("#"+popupobj.divid+" [name=sync_external_contact]").prop('checked');
        var sync_group_name = ld("#"+popupobj.divid+" [name=sync_group_name]").prop('checked');
        var import_external_contact = ld("#"+popupobj.divid+" [name=import_external_contact]").prop('checked');
        that.start_import_external_contact(surl, import_external_contact, sync_external_contact, sync_group_name);
    }
    this.start_import_external_contact = function (surl, import_external_contact, sync_external_contact, sync_group_name) {
        if(import_external_contact){
            var param_wechatsession = {
            'obj':that,
            'surl':surl,
            'import_external_contact':import_external_contact,
            'sync_external_contact':sync_external_contact,
            'sync_group_name':sync_group_name
            };
            //导入外部联系人进度条
            var url = 'index.php?module=Settings&action=SettingsAjax&file=ExternalContact&parenttab=Settings&second_action=import_contact';
            var ajaxobj=ld.ajax({
                url: url,
                type: 'POST',
                data: "",
                dataType:'json',
                async: true,//
                timeout: 900000,
                success: function(data){
                    if(data.code==2){
                        var param = {};
                        getJsScript('include/js/modules/Settings/Settings.js',function (){
                            external_contact_list_progress('Settings',0,param,param_wechatsession);
                        });
                    }  
                }
            });
        }
        else{
            ldAjax(surl+"&import_external_contact="+import_external_contact,"",function(data){
                if (data.code == 1){ //继续下一个
                    //同步会话存档的外部联系人
                    that.start_sync_external_contact(surl, import_external_contact, sync_external_contact, sync_group_name);
                }
            })
        }
    }

    this.start_sync_external_contact = function (surl, import_external_contact, sync_external_contact, sync_group_name) {
        //同步会话存档的外部联系人
        ld.ajax({
            url: surl+"&sync_external_contact="+sync_external_contact,
            type: 'POST',
            dataType:'json',
            timeout: 900000,
            success:function(data){
                if (data.code == 2){ //继续当前
                    var tmppopupobjobj;
                    if(data.result.start == 0){
                        tmppopupobjobj=ProgressPopup.load(data.result.title,"","",500,'WechatSession',"","","","");
                        tmppopupobjobj.show();
                    }
                    else{
                        tmppopupobjobj=CrmPopup.getPopupObj('last');
                    }

                    tmppopupobjobj.setPercentWidth(data.result.percent);
                    tmppopupobjobj.setTotalNum(data.result.total);
                    tmppopupobjobj.setCurNum(data.result.end);
                    
                    that.start_sync_external_contact(surl, import_external_contact, sync_external_contact, sync_group_name);
                }
                else{//继续下一个
                    that.start_sync_group_name(surl, import_external_contact, sync_external_contact, sync_group_name);
                }
            }
        });
    }

    this.start_sync_group_name = function (surl, import_external_contact, sync_external_contact, sync_group_name) {
        ld.ajax({
            url: surl+"&sync_group_name="+sync_group_name,
            type: 'POST',
            dataType:'json',
            timeout: 900000,
            success:function(data){
                if (data.code == 2){ //不能继续当前  弹窗 导入群名称，可能不是同时勾选
                    var tmppopupobjobj;
                    if(data.result.start == 0){
                        tmppopupobjobj=ProgressPopup.load(data.result.title,"","",500,'WechatSession',"","","","");
                        tmppopupobjobj.show();
                    }
                    else{
                        tmppopupobjobj=CrmPopup.getPopupObj('last');
                    }

                    tmppopupobjobj.setPercentWidth(data.result.percent);
                    tmppopupobjobj.setTotalNum(data.result.total);
                    tmppopupobjobj.setCurNum(data.result.end);

                    that.start_sync_group_name(surl, import_external_contact, sync_external_contact, sync_group_name);
                }
                else{//结束
                    DelProgressObjs();
                    if (data.code == 1){ //完成
                        if (sync_external_contact) {
                            CrmPopup.getPopupObj("last").CancelEvent();
                        }
                        if (sync_group_name) {//同步会话存档的联系人完成
                            CrmPopup.getPopupObj("last").CancelEvent();//关闭进度条
                        }
                    }

                    CrmPopup.getPopupObj("last").CancelEvent();//关闭同步联系人弹出框
                    //edit:can 20210519 45993: 会话存档->会话列表，同步“同步联系人姓名/群名”的时候，导入之后建议自动刷新界面
                    // that.search();
                }
            }
        });
    }

    this.syncNameEvent = function (obj) {
        var popupobj = CrmPopup.getPopupObj("last");
        if (ld("#"+popupobj.divid+" [name=isAppMarket]").val() == 'true') { //应用市场安装才会有显示与隐藏
            ld("#"+popupobj.divid+" [name=secret]").parents('tr').toggle();//secret 显示与隐藏
        }
    }
}