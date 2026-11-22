//@edit:liushuai,2020-11-04,reason:ID1000713/企业微信会话存档(获取相关会话数据)
function WechatSession()
{
}

WechatSession.prototype.plays=function(obj){
    /*var player = new AmrPlayer('http://localhost:85/ldcrm/storage/wechatsession//2020/10/20/6656225916139175654_1604040463_external.amr');
    console.log(obj.value);
    // var player = new AmrPlayer(obj.value);
    player.play();*/
// console.log(obj.value);
    var amr = new BenzAMRRecorder();
    amr.initWithUrl(ld(obj).attr('value')).then(function() {  //远程cos存在跨域问题。
    // amr.initWithUrl('http://localhost:85/ldcrm/storage/wechatsession//2020/10/20/6656225916139175654_1604040463_external.amr').then(function() {
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

WechatSession.prototype.search=function(type, param){
    var popupobj=CrmPopup.getPopupObj('last');
    var search_val = ld("#"+popupobj.divid+" input[name=search]").val();
    // var record = ld("#"+popupobj.divid+" input[name=prerecord]").val();
    var record = popupobj.detailpage_record;

    var surl = 'index.php?module=Accounts&action=AccountsAjax&file=WeChatSession&frommodule='+ popupobj.headermodule +'&search='+encodeURIComponent(search_val)+'&record='+record;

    if (!empty(type) && type == 'paging'){ //上一页 下一页
        surl += "&page="+param;
    }

    ldAjax(surl,"",function(data){
        if(data.code == 1){
            ld("#chatdata").html(data.result.content);

            //上一页 下一页
            var page = data.result.page;//当前页
            var page_num = data.result.page_num;  //总页
            if(page_num <= 1){
                //上一条，下一条
                ld("#"+popupobj.divid+" #wechatsessionpagecontent [name=prevnextrecord]").css("display",'none');
            }
            else{
                ld("#"+popupobj.divid+" #wechatsessionpagecontent [name=prevnextrecord]").css("display",'');
            }
            //286CCC 蓝色  999灰色  prevrecord  nextrecord
            if(page >= page_num){
                ld("#"+popupobj.divid+" #wechatsessionpagecontent [tag=prevrecord]").css("color",'#999');
            }
            else{
                ld("#"+popupobj.divid+" #wechatsessionpagecontent [tag=prevrecord]").css("color",'#3B7CFF');
            }
            if(page <= 1){
                ld("#"+popupobj.divid+" #wechatsessionpagecontent [tag=nextrecord]").css("color",'#999');
            }
            else
            {
                ld("#"+popupobj.divid+" #wechatsessionpagecontent [tag=nextrecord]").css("color",'#3B7CFF');
            }


            ld("#" + popupobj.divid + " [name=page_num]").val(page_num);//总页数
            ld("#" + popupobj.divid + " [name=page]").val(page);        //当前第几页

            DelProgressObjs();
            return true;
        }else{
            // var confirm_str = alert_arr.ERROR_WHILE_EDITING;
            // RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            DelProgressObjs();
            return false;
        }
    })

}

//上一页  下一页
WechatSession.prototype.searchPrevNext = function (obj, type) {
    var popupobj=CrmPopup.getPopupObj('last');
    var tag = ld(obj).attr("tag");
    var pageobj = ld("#" + popupobj.divid + " [name=page]");  //当前页
    var page_num = ld("#" + popupobj.divid + " [name=page_num]").val();  //总页

    if(tag == 'prevrecord')
    {
        if (parseInt(pageobj.val()) >= page_num){ //第一頁
            return false;
        }
        this.search(type, parseInt(pageobj.val())+1); //消息倒序排序

    }else if(tag == 'nextrecord')
    {
        if (parseInt(pageobj.val()) <= 1){ //最後一頁
            return false;
        }
        this.search(type, parseInt(pageobj.val())-1);
    }

}

WechatSession.prototype.download=function(obj){
    var filepath = ld(obj).attr("filepath");
    var filename = ld(obj).attr("filename");
    var surl = 'index.php?module=Accounts&action=AccountsAjax&file=WeChatSession&type=download&filepath='+encodeURIComponent(filepath)+'&filename='+encodeURIComponent(filename);
    window.location.href = surl;
}

WechatSession.prototype.preview=function(obj){
    previewImage(obj);
    /*var msgid = ld(obj).attr("msgid");
    var sessionid = ld(obj).attr("sessionid");//ld_wechatsession 主键 id
    var surl = 'index.php?module=Accounts&action=AccountsAjax&file=WeChatSession&type=preview&msgid='+encodeURIComponent(msgid)+'&sessionid='+encodeURIComponent(sessionid);
    window.open(surl,"","");*/
}
