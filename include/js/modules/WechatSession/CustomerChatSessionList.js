function CustomerChatSessionList() {
    var that = this;
    that.popupobj = CrmPopup.getPopupObj('last');


    this.setSessonListEvent=function()
    {
        //当前 搜索成员列表 文本框   绑定change事件
        var personobj = ld("#" + that.popupobj.divid + " [name=searchsession]");
        ld(personobj).unbind("keyup").bind("keyup", function (event) {
            var e = event ? event :(window.event ? window.event : null);
            if(e.keyCode==13){
                that.search();
            }
        });

        //会话类型（单聊、群聊）  绑定click事件
        var session_type_event = ld("#" + that.popupobj.divid + " [name=session_type_event] li");
        ld(session_type_event).unbind("click").bind("click", function () {
            ld("#" + that.popupobj.divid + " [name=session_type_event] li").css("color", "");
            ld(this).css("color", "#0070ba");//点击会话类型字体色

            ld("#" + that.popupobj.divid + " [name=session_type]").val(ld(this).attr("value"));
            that.search();
        })


        //会话列表点击会话成员
        var personobj = ld("#" + that.popupobj.divid + " #sessionlist [block=session]");
        ld(personobj).unbind("click").bind("click", function () {
            ld("#" + that.popupobj.divid + " #sessionlist [block=session]").removeClass("weui-cell-action");
            ld(this).addClass("weui-cell-action");//点击成员背景色

            var searchsessionobj = ld(this).find('[name=wx_userid]'); //联系人 tolist
            if (empty(searchsessionobj)) {
                searchsessionobj = ld(this).find('[name=roomid]');//群聊 roomid
                ld("#" + that.popupobj.divid + " [name=session_roomid]").val(searchsessionobj.val());
                ld("#" + that.popupobj.divid + " [name=session_wx_userid]").val("");
            }else{
                ld("#" + that.popupobj.divid + " [name=session_wx_userid]").val(searchsessionobj.val());
                ld("#" + that.popupobj.divid + " [name=session_roomid]").val("");
            }

            WechatSessionobj.CustomerChatDataListobj.search();//点击会话列表的人
        })
    }


    /*
    * 中间 会话列表搜索
    * */
    this.search=function()
    {
        var member_wx_userid = ld("#"+that.popupobj.divid+" [name=member_wx_userid]").val();//左边成员列表的值
        if (empty(member_wx_userid)){
            alert("请先选择一个成员！");
            console.log("成员列表没有选择成员。。");
            return false;
        }

        // var search = "";
        var search = ld("#"+that.popupobj.divid+" [name=searchsession]").val();//中间搜索框的值
        var session_type = ld("#"+that.popupobj.divid+" [name=session_type]").val();//中间会话类型的值
        

        var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=ListView&searchbytype=searchbycustomer&block=sessionlist&ajax=true&member_wx_userid="+encodeURIComponent(member_wx_userid)+"&search="+encodeURIComponent(search)+"&session_type="+encodeURIComponent(session_type);
        ldAjax(surl,"",function(data){
            if(data.code==1){
                ld("#"+that.popupobj.divid+" #sessionlist").html(data.result.content);
                that.setSessonListEvent();  //重新绑定会话列表事件

                ld("#" + that.popupobj.divid + " #sessionlist [block=session]:first-child").addClass("weui-cell-action");//搜索完默认选中第一个会话人
                if (session_type == 'groupchat') {
                    ld("#" + that.popupobj.divid + " [name=session_roomid]").val(ld("#" + that.popupobj.divid + " #sessionlist [block=session]:first-child input").val());//中间会话列表 群
                    ld("#" + that.popupobj.divid + " [name=session_wx_userid]").val("");
                }else{
                    ld("#" + that.popupobj.divid + " [name=session_wx_userid]").val(ld("#" + that.popupobj.divid + " #sessionlist [block=session]:first-child input").val());//中间会话列表 会话人
                    ld("#" + that.popupobj.divid + " [name=session_roomid]").val("");
                }

                WechatSessionobj.CustomerChatDataListobj.search();//中间和右边的一同显示
                DelProgressObjs();
            }
        })
    }
}