//@edit:liushuai,2020-11-04,reason:ID1000713/企业微信会话存档(获取相关会话数据)
function WechatSession()
{
    this.popupobj = CrmPopup.getPopupObj('last');
    // document.write('<script language="JavaScript" type="text/javascript" src="include/js/modules/WechatSession/ChatMemberList.js"></script>');
    this.ChatMemberListobj = new ChatMemberList();//成员搜索->左边块
    this.ChatSessionListobj = new ChatSessionList();//成员搜索->中间
    this.ChatDataListobj = new ChatDataList();//成员搜索->右边块
    this.startEvent = function () {
        this.ChatMemberListobj.setMemberListEvent();
    }

    //根据成员（客户）搜索
    this.showSearchType = function (obj, searchtype) {
        if (searchtype == 'member') {
            // ld("#" + this.popupobj.divid + " [name=searchbytype]").val("searchbymember"); //搜索类型：根据成员搜索
            // ld("#" + this.popupobj.divid + " #searchbymember").hide();

            var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=ListView&searchbytype=searchbymember";
            ldAjax(surl,"",function(data){
                if(data.code==1){
                    ld("#pagecontent .wrapper-panel-inner").html(data.result.content);
                    DelProgressObjs();
                    ld('.ld-ui-tabs-nav li').removeClass('ld-ui-tabs-active');
                    ld('.ld-ui-tabs-nav li[tag=1]').addClass('ld-ui-tabs-active');

                    if(typeof wechat_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                        wechat_wxOpenDataobj.bindAllOpenDataByPopupObj();
                }
            });

        }else{ //customer
            // ld("#" + this.popupobj.divid + " [name=searchbytype]").val("searchbycustomer");//搜索类型：根据客户搜索
            var surl = "index.php?module=WechatSession&action=WechatSessionAjax&file=ListView&searchbytype=searchbycustomer";
            ldAjax(surl,"",function(data){
                if(data.code==1){
                    ld("#pagecontent .wrapper-panel-inner").html(data.result.content);
                    DelProgressObjs();
                    ld('.ld-ui-tabs-nav li').removeClass('ld-ui-tabs-active');
                    ld('.ld-ui-tabs-nav li[tag=2]').addClass('ld-ui-tabs-active');
                }
            });

        }
    };

}

WechatSession.prototype.plays=function(obj){
    /*ld.ajaxSetup({
        headers: { 'Access-Control-Allow-Origin': '*' },
    });*/
    /*var player = new AmrPlayer('http://localhost:85/ldcrm/storage/wechatsession//2020/10/20/6656225916139175654_1604040463_external.amr');
    console.log(obj.value);
    // var player = new AmrPlayer(obj.value);
    player.play();*/
    var amr = new BenzAMRRecorder();
    amr.initWithUrl(ld(obj).attr('value')).then(function() {  //远程cos存在跨域问题。
        // amr.initWithUrl('http://localhost:85/ldcrm/storage/wechatsession//2020/10/20/6656225916139175654_1604040463_external.amr').then(function() {
        // window.location.href = window.URL.createObjectURL(amr.getBlob());
        if(amr.isPlaying()){
            amr.stop();
        } else {
            amr.play();
        }
    });
    amr.onEnded(function() {
        console.log("播放完毕");
    })
}

WechatSession.prototype.search=function(obj){
    var search_val = ld(" input[name=search]").val();
    var surl = 'index.php?module=WechatSession&action=WechatSessionAjax&file=ListView&search='+encodeURIComponent(search_val)+'&record=';
    ldAjax(surl,"",function(data){
        if(data.code == 1){
            ld("#chatdata").html(data.result.content);
            DelProgressObjs();
            return true;
        }
        else{
            DelProgressObjs();
            return false;
        }
    });
}

WechatSession.prototype.download=function(obj){
    var filepath = ld(obj).attr("filepath");
    var filename = ld(obj).attr("filename");
    var surl = 'index.php?module=WechatSession&action=WechatSessionAjax&file=MediaDataUtil&type=download&filepath='+encodeURIComponent(filepath)+'&filename='+encodeURIComponent(filename);
    window.location.href = surl;
}

WechatSession.prototype.preview=function(obj){
    var msgid = ld(obj).attr("msgid");
    var sessionid = ld(obj).attr("sessionid");//ld_wechatsession 主键 id
    var surl = 'index.php?module=WechatSession&action=WechatSessionAjax&file=MediaDataUtil&type=preview&msgid='+encodeURIComponent(msgid)+'&sessionid='+encodeURIComponent(sessionid);
    window.open(surl,"","");
}

WechatSession.prototype.setWechatSessionHeight=function(){
    var topheight=55;//快速查找所在div的高度55
    var con_mt_height=10;//头部和内容中间margin距离10
    var uitabsheight=90;//标签高度+上下间距
    var talkheadHeight=68;//表头高度
    var talkContentHeight = parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) - parseInt(uitabsheight) - parseInt(talkheadHeight) - parseInt(20);
    ld('.talk-wrapper-left .talk-wrapper-content #memberlist').css('height', talkContentHeight-40 + 'px');
    ld('.talk-wrapper-left .talk-wrapper-content #memberlist').css('overflow', 'auto');

    ld('.talk-wrapper-center .talk-wrapper-content #sessionlist').css('height', talkContentHeight-112 + 'px');
    ld('.talk-wrapper-center .talk-wrapper-content #sessionlist').css('overflow', 'auto');

    ld('.talk-wrapper-right .talk-wrapper-content #chatdatalist').css('height', talkContentHeight-72 + 'px');
    ld('.talk-wrapper-right .talk-wrapper-content #chatdatalist').css('overflow', 'auto');
}