function ChatMemberList(){
    var that=this;
    that.popupobj=CrmPopup.getPopupObj('last');
    // that.WechatSessionobj = WechatSessionobj;

    this.setMemberListEvent=function()
    {
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
            ld("#" + that.popupobj.divid + " #memberlist [block=member]").parent().parent().removeClass("weui-cell-action");
            ld(this).parent().parent().addClass("weui-cell-action");//点击成员背景色

            var selectpersonobj = ld(this).find('[name=wx_userid]'); //成员列表 某一成员的对象
            ld("#"+that.popupobj.divid+" [name=member_wx_userid]").val(selectpersonobj.val());

            ld('#searchbymember #sessionlist').scrollTop(0);//中间会话列表滚动条重置

            // 先条件置空或默认值 再搜索
            ld("#" + that.popupobj.divid + " [name=searchsession]").val("");//中间会话列表 搜索框
            ld("#" + that.popupobj.divid + " [name=session_type_event] li").removeClass("talktabsselected");//中间会话列表 会话类型
            ld("#" + that.popupobj.divid + " [name=session_type_event] li:first-child").addClass("talktabsselected");;//中间会话列表 会话类型
            ld("#" + that.popupobj.divid + " [name=session_type]").val("internal");
            ld("#" + that.popupobj.divid + " [name=session_wx_userid]").val("");//中间会话列表 会话人
            ld("#" + that.popupobj.divid + " [name=session_roomid]").val("");//中间会话列表
            ld("#" + that.popupobj.divid + " [name=session_last_name]").val("");//中间会话列表 会话人
            WechatSessionobj.ChatSessionListobj.search();//点击成员列表的人

            ld("#" + that.popupobj.divid + " [name=searchcontent]").val("");//右边聊天记录 搜索框
            ld("#" + that.popupobj.divid + " [name=msgtype_event] li").removeClass("talktabsselected");//右边聊天记录 聊天内容的类型
            ld("#" + that.popupobj.divid + " [name=msgtype_event] li:first-child").addClass("talktabsselected");//右边聊天记录 聊天内容的类型
            ld("#" + that.popupobj.divid + " [name=msgtype]").val("all");
            ld("#" + that.popupobj.divid + " [name=begin_date]").val("");
            ld("#" + that.popupobj.divid + " [name=end_date]").val("");
            WechatSessionobj.ChatDataListobj.rightPrescrollHeight = 0;
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

                if(wechat_wxOpenDataobj!=undefined&&typeof wechat_wxOpenDataobj!="undefined"){
                    var tmpobj = new Object();
                    tmpobj.divid = "memberlist";
                    wechat_wxOpenDataobj.bindAllOpenDataByPopupObj(tmpobj);
                    // wechat_wxOpenDataobj.bindAllOpenDataByPopupObj(that.popupobj);
                }
            }
            else{
                MessagePopup.TipZero_info(data.result.msg);
            }
        });
    }

    //清除接口缓存数据
    this.clearApiCache=function(){
        var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=Operation&operationtype=clearapicache";
        ldAjax(surl, "", function (data) {
            if (data.code == 1) {
                DelProgressObjs();
                window.location.reload();
                // WechatSessionobj.ChatMemberListobj.search();//点击成员列表的人
            }
        });
    }

    //编辑成员，备注姓名，已备成员离职后显示姓名
    this.editMemberlastname=function(obj,convertuserid){
        if(!empty(convertuserid)){
            var crmPopupobj=CrmPopup.load("","","","350",'WechatSession',"","","","");
            crmPopupobj.prevshow();

            var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=Operation&operationtype=editmemberpop&convertuserid="+convertuserid;
            ldAjax(surl,"",function(data){
                if(data.code==1){
                    crmPopupobj.setParams(data.result.title,that.saveMemberlastname,"","350",'WechatSession',[convertuserid],data.result.oktext,"",data.result.canceltext,"");
                    crmPopupobj.Okfun.funname = 'this.saveMemberlastname';
                    crmPopupobj.show(data.result.content);
                }
                DelProgressObjs();
            })
        }
    }

    //保存成员姓名
    this.saveMemberlastname=function(convertuserid){
        var crmPopupobj = CrmPopup.getPopupObj('last');
        var lastname = ld("#"+crmPopupobj.divid+" [name=memberlastname]").val().trim();
        if (empty(lastname)){
            RemindsMsg("","LdPopWidth400px","","yes","","姓名"+arrJsPopLabel['CANOTEMPTY']);
            return false;
        }

        var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=Operation&operationtype=savememberlastname&convertuserid="+convertuserid+"&lastname="+lastname;
        ldAjax(surl,"",function(data){
            if(data.code==1){
                crmPopupobj.CancelEvent();
            }
            DelProgressObjs();
        })
    }
    //that.saveMemberlastname.funname = "this.saveMemberlastname";

    this.showEdit=function(obj){
        ld(obj).find("[name=user_group]").show();
        //ld(obj).find("[name=user_group]").css("display","inline-block");
    }
    this.hideEdit=function(obj){
        ld(obj).find("[name=user_group]").hide();
    }
}