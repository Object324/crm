function ChatDataList() {
    var that = this;
    that.popupobj = CrmPopup.getPopupObj('last');
    that.rightPrescrollHeight = 0;
    that.loading = false;

    ld('#searchbymember #chatdatalist').scroll(function () {
        if (ld('#searchbymember #chatdatalist').scrollTop() == 0) {
            if(that.loading){
                return false;
            }
            //BUG20240422-61 ls 240422 会话数据上翻页显示不全，无法再滚动
            var cur_page = parseInt(ld("#" + that.popupobj.divid + " [name=page]").val());//当前页
            var page_num = parseInt(ld("#" + that.popupobj.divid + " [name=page_num]").val());//总页
            if(page_num > cur_page){
                var scrollableDiv = ld("#searchbymember #chatdatalist");
                that.rightPrescrollHeight = scrollableDiv[0].scrollHeight;
                that.search('paging', parseInt(cur_page)+1);
            }
        }
    });

    //右边聊天内容定义事件
    this.setChatDataEvent=function(){
        //当前 搜索会话内容列表（聊天内容） 文本框   绑定change事件
        var searchcontentobj = ld("#" + that.popupobj.divid + " [name=searchcontent]");
        ld(searchcontentobj).unbind("keyup").bind("keyup", function (event) {
            var e = event ? event :(window.event ? window.event : null);
            if(e.keyCode==13){
                that.search("count");//显示搜索结果相关条数及  查看上下文按钮
            }
        });

        //选择查询日期范围
        /*var begin_date_obj = ld("#" + that.popupobj.divid + " [name=begin_date]");
        ld(begin_date_obj).unbind("change").bind("change", function () {
            // that.search();
        });
        var end_date_obj = ld("#" + that.popupobj.divid + " [name=end_date]");
        ld(end_date_obj).unbind("change").bind("change", function () {
            // that.search();
        });*/

        //聊天记录类型（全部、文件、图片/视频、语音）  绑定click事件
        var msgtype_event_obj = ld("#" + that.popupobj.divid + " [name=msgtype_event] li");
        ld(msgtype_event_obj).unbind("click").bind("click", function () {
            ld("#" + that.popupobj.divid + " [name=msgtype_event] li").removeClass("talktabsselected");
            ld(this).addClass("talktabsselected");//点击会话类型字体色
            ld("#"+that.popupobj.divid+" [name=searchcontent]").val(''); //右边列表点击类型，清空搜索框，两者不能同时作为条件
            ld("#" + that.popupobj.divid + " [name=msgtype]").val(ld(this).attr("value"));
            that.search();
        });
    }

    this.search=function(type, param){
        var member_wx_userid = ld("#"+that.popupobj.divid+" [name=member_wx_userid]").val();//左边成员列表的值
        if (empty(member_wx_userid)){
            alert("请先选择一个成员！");
            return false;
        }
        that.loading = true;
        var session_type = ld("#"+that.popupobj.divid+" [name=session_type]").val();//中间会话类型的值
        var session_wx_userid = ld("#"+that.popupobj.divid+" [name=session_wx_userid]").val();//中间会话列表的值   ld_wechatsession：tolist或者roomid
        var session_roomid = ld("#"+that.popupobj.divid+" [name=session_roomid]").val();
        var search = ld("#"+that.popupobj.divid+" [name=searchcontent]").val();//右边搜索框的值
        var msgtype = '';
        if (empty(search)){//若有搜索框条件搜索，则不根据消息类型搜索
            msgtype = ld("#"+that.popupobj.divid+" [name=msgtype]").val();//右边搜索文件类型的值
        }
        else {
            ld("#" + that.popupobj.divid + " [name=msgtype_event] li").css("color", "");
        }
        var begin_date = ld("#" + that.popupobj.divid + " [name=begin_date]").val();
        var end_date = ld("#" + that.popupobj.divid + " [name=end_date]").val();
        var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=ListView&searchbytype=searchbymember&block=chatdatalist&ajax=true&member_wx_userid="+encodeURIComponent(member_wx_userid)+"&session_type="+encodeURIComponent(session_type)+"&session_wx_userid="+encodeURIComponent(session_wx_userid)+"&session_roomid="+encodeURIComponent(session_roomid)+"&search="+encodeURIComponent(search)+"&msgtype="+encodeURIComponent(msgtype)+"&begin_date="+encodeURIComponent(begin_date)+"&end_date="+encodeURIComponent(end_date);
        if (!empty(type) && type == 'count'){ //搜索后 统计相关数量
            surl += "&count=true";
        }
        if (!empty(type) && type == 'context'){ //搜索后 查看上下文
            surl += "&context=true&search=&seq="+ld("#" + that.popupobj.divid + " [name=seq]").val();
        }
        if (!empty(type) && type == 'paging'){ //上一页 下一页
            surl += "&page="+param;
        }
        ldAjax(surl,"",function(data){
            if(data.code==1){
                //上一页 下一页
                if (!empty(type) && type == 'paging'){
                    ld("#"+that.popupobj.divid+" #chatdatalist").prepend(data.result.content);
                }
                else{
                    ld("#"+that.popupobj.divid+" #chatdatalist").html(data.result.content);
                    that.setChatDataEvent();  //重新绑定聊天记录列表事件
                }
                
                //标题
                var title = data.result.title;
                if (!empty(title) && title.length > 21){
                    title = title.substr(0,21)+'...';
                }
                ld("#" + that.popupobj.divid + " [name=chatdata_personnel]").html(title);//右边 显示谁和谁会话  或者群名称
                ld("#" + that.popupobj.divid + " [name=page_num]").val(data.result.page_num);//总页数
                ld("#" + that.popupobj.divid + " [name=page]").val(data.result.page);//当前第几页
                //搜索框模糊搜索后，给搜索结果绑定事件
                if (!empty(search)) {
                    ld("#" + that.popupobj.divid + " #chatdatalist [name=contextWrap]").unbind('mouseover mouseout').on('mouseover mouseout',function (event) {
                        if(event.type == "mouseover"){
                            //鼠标悬浮 显示“查看上下文”按钮
                            if (ld(this).find('[name=contextcontent]')) {
                                ld(this).find('[name=contextcontent]').css('display','block');
                            }
                        }
                        else if(event.type == "mouseout"){
                            //鼠标离开
                            if (ld(this).find('[name=contextcontent]')) {
                                ld(this).find('[name=contextcontent]').css('display','none');
                            }
                        }
                    });
                }

                // 将滚动条位置滚动到加载前高度
                var scrollableDiv = ld("#searchbymember #chatdatalist");
                scrollableDiv.scrollTop(parseInt(scrollableDiv[0].scrollHeight)-parseInt(that.rightPrescrollHeight));
                DelProgressObjs();

                if(wechat_wxOpenDataobj!=undefined&&typeof wechat_wxOpenDataobj!="undefined"){
                    var tmpobj = new Object();
                    tmpobj.divid = "chatdatalist";
                    wechat_wxOpenDataobj.bindAllOpenDataByPopupObj(tmpobj);
                    // wechat_wxOpenDataobj.bindAllOpenDataByPopupObj(that.popupobj);
                }
            }
            that.loading = false;
        });
    }

    //预览
    this.preview = function (obj) {
        previewImage(obj);
    }
}