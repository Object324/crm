function CustomerChatMemberList(){
    var that=this;
    that.popupobj=CrmPopup.getPopupObj('last');

    this.setMemberListEvent=function(){
        //当前 搜索成员列表 文本框
        var searchmemberobj=ld("#"+that.popupobj.divid+" [name=searchmember]");
        ld(searchmemberobj).unbind("keyup").bind("keyup",function(event){
            var e = event ? event :(window.event ? window.event : null);
            if(e.keyCode==13){
                that.search();
            }
        });

        //成员列表点击成员
        var personobj=ld("#"+that.popupobj.divid+" #memberlist [block=member]");
        ld(personobj).unbind("click").bind("click",function(){
            ld("#" + that.popupobj.divid + " #memberlist [block=member]").removeClass("weui-cell-action");
            ld(this).addClass("weui-cell-action");//点击成员背景色

            var selectpersonobj = ld(this).find('[name=wx_userid]'); //成员列表 某一成员的对象
            ld("#"+that.popupobj.divid+" [name=member_wx_userid]").val(selectpersonobj.val());
            // ld("#"+that.popupobj.divid+" [name=member_last_name]").val(ld(this).text());

            // 先条件置空或默认值 再搜索人
            ld("#" + that.popupobj.divid + " [name=searchsession]").val("");//中间会话列表 搜索框
            ld("#" + that.popupobj.divid + " [name=session_type_event] li").removeClass("talktabsselected");//中间会话列表 会话类型
            ld("#" + that.popupobj.divid + " [name=session_type_event] li:first-child").addClass("talktabsselected");//中间会话列表 会话类型
            ld("#" + that.popupobj.divid + " [name=session_type]").val("external"); //根据客户搜索  默认单聊（外部）
            ld("#" + that.popupobj.divid + " [name=session_wx_userid]").val("");//中间会话列表 会话人
            ld("#" + that.popupobj.divid + " [name=session_roomid]").val("");//中间会话列表
            ld("#" + that.popupobj.divid + " [name=session_last_name]").val("");//中间会话列表 会话人

            ld("#" + that.popupobj.divid + " [name=searchcontent]").val("");//右边聊天记录 搜索框
            ld("#" + that.popupobj.divid + " [name=msgtype_event] li").removeClass("talktabsselected");//右边聊天记录 聊天内容的类型
            ld("#" + that.popupobj.divid + " [name=msgtype_event] li:first-child").addClass("talktabsselected");//右边聊天记录 聊天内容的类型
            ld("#" + that.popupobj.divid + " [name=msgtype]").val("all");
            ld("#" + that.popupobj.divid + " [name=begin_date]").val("");
            ld("#" + that.popupobj.divid + " [name=end_date]").val("");

            WechatSessionobj.CustomerChatSessionListobj.search();//点击成员列表的人
        });
    }

    //文本搜索框模糊搜索成员名称
    this.search = function () {
        var searchbytype = ld("#" + that.popupobj.divid + " [name=searchbytype]").val();//搜索类型
        var search = ld("#" + that.popupobj.divid + " [name=searchmember]").val();//可以为空
        var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=ListView&block=memberlist&ajax=true&search=" + encodeURIComponent(search)+"&searchbytype="+encodeURIComponent(searchbytype);
        ldAjax(surl, "", function (data) {
            if (data.code == 1) {
                ld("#" + that.popupobj.divid + " #memberlist").html(data.result.content);
                that.setMemberListEvent();  //重新绑定事件
                DelProgressObjs();
            }
        });
    }
}