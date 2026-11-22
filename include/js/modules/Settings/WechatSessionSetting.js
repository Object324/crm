// ls  241031 XUQIU20240918-09 增加会话存档接口配置参数
function WechatSessionSetting()
{
    this.commonUrl = 'index.php?module=Settings&action=SettingsAjax&file=WechatSessionSetting';
    var that=this;

    //参数设置 编辑按钮
    this.edit = function () {
        ldAjax(that.commonUrl+'&mode=edit','',function (data) {
            if (data.code == 1){
                var popupobj = CrmPopup.load(data.result.title,that.save,'','LdPopWidth600px','Settings','',data.result.oktext,'',data.result.canceltext);
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(popupobj,data.result.content);

                //定义事件
                ld("#"+popupobj.divid+" [name=upload_way]").unbind("change").bind("change", function () {
                    var upload_way = ld(this).val();
                    if (upload_way == 'cos') {
                        ld('#'+popupobj.divid).find('[name=secretid]').closest('tr').css("display",'');
                        ld('#'+popupobj.divid).find('[name=secretkey]').closest('tr').css("display",'');
                        ld('#'+popupobj.divid).find('[name=bucketname]').closest('tr').css("display",'');
                        ld('#'+popupobj.divid).find('[name=region]').closest('tr').css("display",'');
                    }else{
                        ld('#'+popupobj.divid).find('[name=secretid]').closest('tr').css("display",'none');
                        ld('#'+popupobj.divid).find('[name=secretkey]').closest('tr').css("display",'none');
                        ld('#'+popupobj.divid).find('[name=bucketname]').closest('tr').css("display",'none');
                        ld('#'+popupobj.divid).find('[name=region]').closest('tr').css("display",'none');
                    }

                })
                ld("#"+popupobj.divid+" [name=upload_way]").change();

                ld("#"+popupobj.divid+" [name=enable_remind]").unbind("click").bind("click", function () {
                    if (ld(this).prop('checked')) {
                        ld('#'+popupobj.divid).find('[name=receiverids]').closest('tr').css("display",'');
                        ld('#'+popupobj.divid).find('[name=remind_content]').closest('tr').css("display",'');
                    }else{
                        ld('#'+popupobj.divid).find('[name=receiverids]').closest('tr').css("display",'none');
                        ld('#'+popupobj.divid).find('[name=remind_content]').closest('tr').css("display",'none');
                    }
                })

                // 需要去掉的给高度
                popupobj.reduceBodyHeight = 0;
                // 设置内容最大高度
                popupobj.setPopBodyMaxHeight("#"+popupobj.divid+'_scroll');
            }
            DelProgressObjs();
        })

    }

    this.getSessionRemindsUserIds = function () {
        getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function(){
            ScopePopup_Details.getInstance().wareHouseselectUser('receiverids','receiverids_name','approvestep');
        });
    }

    //参数设置 保存
    this.save = function () {
        var popupobj = CrmPopup.getPopupObj('last');
        var addurl = "";
        var secret = trim(ld("#"+popupobj.divid+" [name=secret]").val());
        var upload_way = trim(ld("#"+popupobj.divid+" [name=upload_way]").val());
        var enable_remind = "no";
        if (ld("#"+popupobj.divid+" [name=enable_remind]").prop("checked")) {
            enable_remind = 'yes';
        }

        if (empty(secret)) {
            MessagePopup.TipOne_warning(ld("#" + popupobj.divid + " [name=secret]").attr('label') + arrJsPopLabel['CANOTEMPTY']);
            // ld("#" + popupobj.divid + " [name=secret]").css('border-color','#FF5762');
            return false;
        }
        addurl += "&secret="+secret+"&upload_way="+upload_way+"&enable_remind="+enable_remind;
        if (upload_way == 'cos') {
            var secretid = trim(ld("#"+popupobj.divid+" [name=secretid]").val());
            var secretkey = trim(ld("#"+popupobj.divid+" [name=secretkey]").val());
            var bucketname = trim(ld("#"+popupobj.divid+" [name=bucketname]").val());
            var region = trim(ld("#"+popupobj.divid+" [name=region]").val());
            if (empty(secretid)) {
                MessagePopup.TipOne_warning(ld("#" + popupobj.divid + " [name=secretid]").attr('label') + arrJsPopLabel['CANOTEMPTY']);
                return false;
            }
            if (empty(secretkey)) {
                MessagePopup.TipOne_warning(ld("#" + popupobj.divid + " [name=secretkey]").attr('label') + arrJsPopLabel['CANOTEMPTY']);
                return false;
            }
            if (empty(bucketname)) {
                MessagePopup.TipOne_warning(ld("#" + popupobj.divid + " [name=bucketname]").attr('label') + arrJsPopLabel['CANOTEMPTY']);
                return false;
            }
            if (empty(region)) {
                MessagePopup.TipOne_warning(ld("#" + popupobj.divid + " [name=region]").attr('label') + arrJsPopLabel['CANOTEMPTY']);
                return false;
            }
            addurl += "&secretid="+secretid+"&secretkey="+secretkey+"&bucketname="+bucketname+"&region="+region;
        }

        var receiverids = trim(ld("#"+popupobj.divid+" [name=receiverids]").val());
        var remind_content = trim(ld("#"+popupobj.divid+" [name=remind_content]").val());
        if (enable_remind == 'yes') {
            if (empty(receiverids)) {
                MessagePopup.TipOne_warning(ld("#" + popupobj.divid + " [name=receiverids]").attr('label') + arrJsPopLabel['CANOTEMPTY']);
                return false;
            }
            if (empty(remind_content)) {
                MessagePopup.TipOne_warning(ld("#" + popupobj.divid + " [name=remind_content]").attr('label') + arrJsPopLabel['CANOTEMPTY']);
                return false;
            }
        }
        addurl += "&receiverids="+receiverids+"&remind_content="+encodeURIComponent(remind_content);

        ldAjax(that.commonUrl+'&mode=save'+addurl,"",function (data) {
            if (data.code == 1){
                popupobj.CancelEvent();
                ld('#SettingRightContent').html(data.result.content);
            }
            DelProgressObjs();
        });


    }


    //注销
    this.logout = function () {
        MessagePopup.TipTwo_warning(arrJsPopLabel['ClearWechatSessionSettingTip']);
        var messagepopupobj = CrmPopup.getPopupObj('last');
        ld('#'+messagepopupobj.divid).find('[tagclick=msgConfirm]').on('click',function (){
            var url = that.commonUrl;
            url += '&mode=logout';
            ldAjax(url,"",function (data) {
                if (data.code == 1){
                    ld('#SettingRightContent').html(data.result.content);
                }
                DelProgressObjs();
            });
        });

    }

}
WechatSessionSetting.getInstance=function(){
    if(WechatSessionSetting.curobj==undefined){
        WechatSessionSetting.curobj=new WechatSessionSetting();

    }
    return WechatSessionSetting.curobj;
}