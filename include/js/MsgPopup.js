//下拉框编辑弹出层
function MsgPopup() {
    this.getpopupMaxHeight=function(){
        return 0;
    }
    var parentshow=this.show;
    this.show=function(htmlcontent){
        parentshow.apply(this,[htmlcontent]);  //调用父类show()函数
    }
}

/**
 * 弹框提醒
 * @param $headtitle//标题
 * @param $cssWidth//宽度
 * @param $module//模块
 * @param $OkText//确定按钮名称，为空暂时默认为确定
 * @param $CancelText//取消按钮名称
 * @param $ContentText//内容
 * @return string
 */
function RemindsMsg(headtitle,cssWidth,module,OkText,CancelText,ContentText){
    if(!empty(CancelText)){
        //wym 形参headtitle并没有真正传递给default_warningRemindsMsg，加非空判断传递给它，否则弹窗无法设置标题
        if(!empty(headtitle)){
            default_warningRemindsMsg(ContentText,headtitle,'',cssWidth,OkText,CancelText)
        }
        else{
            default_warningRemindsMsg(ContentText,'','',cssWidth,OkText,CancelText)
        }
    }
    else{
        singlebtn_warningRemindsMsg(ContentText,cssWidth,OkText);
    }
}

function resultRemindsMsg(headtitle,cssWidth,module,OkText,CancelText,ContentText){
    if(headtitle == '') headtitle = arrJsPopLabel['WARMPROMPT'];//标题
    if(ContentText == '') ContentText=arrJsPopLabel['PLEASESELECTONEENTITY'];//内容
    if(OkText == 'yes' || OkText == '' || OkText == 'undefined') OkText = arrJsPopLabel['CONFIRMED'];//确定按钮名称，为空暂时默认为确定
    if(CancelText == 'yes') CancelText = arrJsPopLabel['CANCEL'];//取消按钮名称
    var content = '<div id="pop_remind_content" class="pop_remind_content">' 
        +'<div class="qui_dialog_body " style="background-color: #fff;max-height: 400px;overflow-y: auto;">'
        +ContentText
        +'</div>'
        +'</div>';
        
    var MsgPopupobj=MsgPopup.load(headtitle,msgConfirm,cssWidth,module,OkText,CancelText);
    MsgPopupobj.refreshpage='yes';
    
    MsgPopupobj.show(content); 
    var parentID = ld("input[tagclick='msgConfirm']").parent().parent().attr('id');
    ld("#"+parentID).css('background','#fff');
    ////edit:can 2020-11-16 43280: （61mis.com/kfbcrm）客户管理-客户-分配/共享/批量编辑；在客户单据列表，选择单据进行分配/共享/批量编辑操作，弹出操作成功弹窗；在该弹窗点击单据编号，进入详情，详情界面显示在了操作成功弹窗后面；
    ld("#"+parentID).css('z-index',CrmPopup.zIndex);
    ld('#'+parentID+' div[class$="_pbtn"]').addClass('ww_dialog_foot');
    ld('#layer').addClass("indextop_8");//遮罩层
    
    //给取消、关闭按钮增加时间(原因：z-index无法关闭)
    if(!empty(CancelText)){
        ld('#'+parentID+'_btnok').attr("onclick","msgConfirm()");
        ld('#'+parentID+'_btncancel').attr("onclick","msgConfirm()");
    }
}

function audioRemindsMsg(headtitle,cssWidth,module,OkText,CancelText,ContentText,messagetype){ //message_type: 消息提示类型，warning：警告，success;成功，message：普通提示，error：错误，为空默认为警告
    if(messagetype == '' || messagetype == undefined){
        timekeeping_messageRemindsMsg(ContentText,"warning");
    }
    else{
        timekeeping_messageRemindsMsg(ContentText,messagetype)
    }
}

function successaudioRemindsMsg(headtitle,cssWidth,module,OkText,CancelText,ContentText){
    timekeeping_messageRemindsMsg(ContentText,"success");
}

MsgPopup.load=function(headtitle,Okfun,cssWidth,module,OkText,CancelText)
{
    MsgPopup.prototype=new CrmPopup();  
    MsgPopup.prototype.constructor=MsgPopup;  
    
    var MsgPopupobj=new MsgPopup();
    MsgPopupobj.setParams(headtitle,Okfun,"",cssWidth,module,"",OkText,"",CancelText);
    MsgPopup.popupobj=MsgPopupobj;
    return MsgPopupobj;
}
 
function msgConfirm(){
    var popupobj=CrmPopup.getPopupObj("last");
    var parentID = ld("input[tagclick='msgConfirm']").parent().parent().attr('id');
    //点击确定后直接关闭弹出层
    ld('#layer').removeClass("indextop_8");//遮罩层
    try{
        popupobj.CancelEvent();
    }
    catch(error){
        ld('div[class="mask opacity"]').remove();
        ld('#'+parentID).remove();
    }
    return false;
}
msgConfirm.funname='msgConfirm';

var msgtimer;
function MessagePopup()
{
    var that = this;
    this.iconclassname = '';//函数用的时候用that.iconclassname
    this.content_alert = '';
    this.content_success = '';
    this.ContentText = '';

    this.getpopupMaxHeight=function(){
        return 0;
    }
    var parentshow=this.show;
    this.show=function(htmlcontent){
        parentshow.apply(this,[htmlcontent]);  //调用父类show()函数
    }
    var default_arr = {
            headtitle : '',
            headicon : '',
            tipsicon : '',
            Okfun : '',
            Cancelfun : '',
            cssWidth : '',
            module : '',
            OkText : 'no',
            CancelText : 'no',
            ContentText : '',
            setTime : 0,
    };
    this.CommonRemindsMsg = function(tmp_data_arr){
        var param_arr = ['headtitle','headicon','tipsicon', 'Okfun', 'Cancelfun', 'cssWidth', 'module', 'OkText', 'CancelText','ContentText','setTime'];
        // headtitle,headicon,tipsicon, Okfun, Cancelfun, cssWidth, module, OkText, CancelText,ContentText
        var tmp_key = '';
        var remindinfo_arr = default_arr;
        for(var i = 0;i<param_arr.length;i++){
            tmp_key = param_arr[i];
            if(tmp_data_arr[tmp_key] != undefined){
                remindinfo_arr[tmp_key] = tmp_data_arr[tmp_key];
            }
        }
        
        var data_arr = remindinfo_arr;
        var headtitle = data_arr.headtitle;
        this.headicon = data_arr.headicon;
        var tipsicon = data_arr.tipsicon; //图片分为操作成功图标和警告图标，分别参数对应'success'和'warning'，为空时默认为'warning'，消息提示还有'error'和'message',对应普通消息提示和错误提示
        var Okfun = data_arr.Okfun;
        var Cancelfun = data_arr.Cancelfun; //取消按钮触发事件，一般为空默认为取消事件，也可自定义触发函数
        var cssWidth = data_arr.cssWidth; //还是用LdPopWidth400px之类的，默认就为LdPopWidth400px，也可以自定义样式宽度
        var module = data_arr.module;
        var OkText = data_arr.OkText;
        var CancelText = data_arr.CancelText;
        that.ContentText = data_arr.ContentText;
        var setTime = data_arr.setTime; //消息提示的计时
        //一些默认参数的设定
        if(headtitle == 'warmprompt') headtitle = arrJsPopLabel['WARMPROMPT']; //标题，为空不显示，默认值有三个可用，"温馨提示"和"提示"
        else if(headtitle == 'tips' || headtitle == 'warning') headtitle = arrJsPopLabel['WARMPROMPT'];
        if(tipsicon == '' || tipsicon == undefined) tipsicon = 'warning';
        if(cssWidth == '' || cssWidth == undefined) cssWidth = 'LdPopWidth400px';
        if(Okfun == '') Okfun = msgConfirm; //确定按钮触发事件，一般为自定义函数，为空时默认为msgConfirm函数
        if(OkText == 'yes' || OkText == '' || OkText == undefined) OkText = arrJsPopLabel['CONFIRMED']; //确定按钮名称，为空或'yes'时默认为确定，为'no'时不显示
        if(CancelText == 'yes' || CancelText == '' || CancelText == undefined) CancelText = arrJsPopLabel['CANCEL']; //取消按钮名称，同确定按钮
        if(that.ContentText == '' || that.ContentText == undefined) that.ContentText=arrJsPopLabel['PLEASESELECTONEENTITY']; //内容，需要自定义，默认为“请至少选择一条记录！”
        if(setTime == '' || setTime == undefined) setTime = 2500;
        this.createcontenthtml();
        //确定和取消按钮都需要时
        if(OkText != 'no' && CancelText != 'no'){
            if(tipsicon == ''|| tipsicon == "warning"){
                var content = '<div id="null_remindercontent" class="pop_remind_content" style="max-height: 400px;border: none;">'+that.content_alert;
            }
            if(tipsicon == "success"){
                var content = '<div id="null_remindercontent" class="pop_remind_content" style="max-height: 400px;border: none;">'+that.content_success;
            }
            //var MsgPopupobj=MessagePopup.load(headtitle,msgConfirm,cssWidth,module,OkText,CancelText);
            this.setParams(headtitle,Okfun,"",cssWidth,module,"",OkText,"",CancelText);
            this.refreshpage='yes';
            this.type="remindmsg";
            this.show(content);
            //var parentID = ld("input[tagclick='msgConfirm']").parent().parent().attr('id');
            var popupobj = CrmPopup.getPopupObj('last')
            var parentID = popupobj.divid;
            ld("#"+parentID).css('background','#fff');
            ld("#"+parentID).css('z-index','110000');
            ld("#"+parentID).css('border','none');
            ld('#'+parentID+'_head').addClass('mar0');
            ld('#layer').addClass("indextop_8");//遮罩层

            // BUG20240708-06 一直点击确定会出多个提示弹窗
            var layer_divid = popupobj.crmpopuplayerobj.opopupblocknodeid;
            ld('#'+layer_divid).css('z-index','109999');
            
            //给取消、关闭按钮增加时间(原因：z-index无法关闭)
            ld('#'+parentID+'_btnok').attr("onclick","msgConfirm()");
            ld('#'+parentID+'_btncancel').attr("onclick","msgConfirm()");
            ld('#'+parentID+'_imgclose').attr("onclick","msgConfirm()");
            ld('#'+parentID+'_btncancel').attr("tagclick","msgConfirmCancel");
            ld('#'+parentID+'_imgclose').attr("tagclick","msgConfirmCancel");
        }
        //只需要确定按钮时
        if(OkText != 'no' && CancelText == 'no'){
            if(tipsicon == ''|| tipsicon == "warning"){
                var content = '<div id="null_remindercontent" class="pop_remind_content" style="max-height: 400px;border: none;">'+that.content_alert;
            }
            else if(tipsicon == "success"){
                var content = '<div id="null_remindercontent" class="pop_remind_content" style="max-height: 400px;border: none;">'+that.content_success;
            }
            //var MsgPopupobj=MessagePopup.load(headtitle,msgConfirm,cssWidth,module,OkText,CancelText);
            this.setParams(headtitle,Okfun,"",cssWidth,module,"",OkText,"",CancelText);
            this.refreshpage='yes';
            this.type="remindmsg";
            this.show(content); 
            // var parentID = ld("input[tagclick='msgConfirm']").parent().parent().attr('id');
            var popupobj = CrmPopup.getPopupObj('last');
            var parentID =popupobj.divid;
            ld("#"+parentID).css('background','#fff');
            ld("#"+parentID).css('z-index','110000');
            ld("#"+parentID).css('border','none');
            ld('#'+parentID+'_head').addClass('mar0');
            ld('#layer').addClass("indextop_8");//遮罩层

            // BUG20240708-06 一直点击确定会出多个提示弹窗
            var layer_divid = popupobj.crmpopuplayerobj.opopupblocknodeid;
            ld('#'+layer_divid).css('z-index','109999');
            
            //给取消、关闭按钮增加时间(原因：z-index无法关闭)
            ld('#'+parentID+'_btnok').attr("onclick","msgConfirm()");
            ld('#'+parentID+'_imgclose').attr("onclick","msgConfirm()");
        }
        //不需要按钮时，为计时弹出提示框
        if(OkText == 'no' && CancelText == 'no'){
            clearTimeout(msgtimer);
            if(tipsicon == ''|| tipsicon == "warning"){
                var content = '<div id="audioCloseConfirm" class="pop_remind_content ld-showWarning '+cssWidth+' ">'
                +'<div class="qui_dialog_body ld-dialog-bodyWarning" style="">'
                +'<div class="ld-msgDlg-top">'
                +'<div class="ld-commonImg ld-commonImg-Alert ld-msgDlg-top-icon" style="width: 16px;height: 16px;background-size:contain"></div>'
            }
            if(tipsicon == "success"){
                var content = '<div id="audioCloseConfirm" class="pop_remind_content ld-showSuccess '+cssWidth+'">'
                +'<div class="qui_dialog_body ld-dialog-bodySuccess" style="">'
                +'<div class="ld-msgDlg-top">'
                +'<div class="ld-commonImg ld-commonImg-Success ld-msgDlg-top-icon" style="width: 16px;height: 16px;background-size: contain"></div>'
            }
            if(tipsicon == "message"){
                var content = '<div id="audioCloseConfirm" class="pop_remind_content ld-showMessage '+cssWidth+'">'
                +'<div class="qui_dialog_body ld-dialog-bodyMessage" style="">'
                +'<div class="ld-msgDlg-top">'
                +'<div class="ld-commonImg ld-commonImg-Message ld-msgDlg-top-icon" style="width: 16px;height: 16px;background-size: contain"></div>'
            }
            if(tipsicon == "error"){
                var content = '<div id="audioCloseConfirm" class="pop_remind_content ld-showError '+cssWidth+'">'
                +'<div class="qui_dialog_body ld-dialog-bodyError" style="">'
                +'<div class="ld-msgDlg-top">'
                +'<div class="ld-commonImg ld-commonImg-Error ld-msgDlg-top-icon" style="width: 16px;height: 16px;background-size: contain"></div>'
            }

            content += '</div>'
                        +'<div class="ld-msgDlg-bottom">'   
                        +'<div class="ld-msgDlg-bottom-text linefeed" style="font-size:14px;">'+that.ContentText
                        +'</div>'
                        +'</div>'
                        +'</div>'
                        +'</div>';

            if(ld("#audioCloseConfirm").length > 0) ld("#audioCloseConfirm").remove();//存在提示层情况下，先删除 

            //是否弹出层判断，大于0是弹出层
            if(ld('div.dvpopupsroll').length > 0){
                //获取弹出层id
                var popupobj=CrmPopup.getPopupObj('last');
                
                // var pagerecordID =ld(tmpobj) .parent().attr('id');
                ld('#'+popupobj.divid).append(content);

            }
            else{
                var parentDiv = '<div id="audioCloseConfirm" style="height: auto;width: auto;position: fixed;left: 0px;top: 0px;z-index:10000;display: flex;justify-content: center;align-items: center;">'+content+'</div>';     
                if(module=='CooperativeWork'){
                    ld('div.Cbox').append(parentDiv);
                }
                else{
                    if(ld('div.List3Box').length != 0){
                        ld('div.List3Box').append(parentDiv);
                    }
                    else if(ld('section#pagecontent').length>0){
                        ld('section#pagecontent').append(parentDiv);
                    }
                    else {
                        ld('body').append(parentDiv);
                    }
                }

            }

            //2秒后，自动关闭提示弹出层
            msgtimer = setTimeout(function(){ 
                ld("#audioCloseConfirm").remove();
                return false;
            }, setTime); 
        }
    }
    this.HeadIcon_change = function (iconclassname){
        that.iconclassname = iconclassname;
    }
    this.createcontenthtml = function(){
        that.content_alert = '<div class="qui_dialog_body ld-dialog-Boxbody" style="max-height:400px;overflow:auto;background-color: #fff;">'
            +'<div class="ld-msgDlg-Boxtop">'
            +'<div class="ld-commonImg ld-commonImg-BoxAlert ld-msgDlg-top-icon"></div>'
            +'</div>'
            +'<div class="ld-msgDlg-Boxbottom">'
            +'<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:15px;padding-left: 0px;">'+that.ContentText
            +'</div>'
            +'</div>'
            +'</div>'
            +'</div>';
        that.content_success = '<div class="qui_dialog_body ld-dialog-Boxbody" style="max-height:400px;overflow:auto;background-color: #fff;">'
            +'<div class="ld-msgDlg-Boxtop">'
            +'<div class="ld-commonImg ld-commonImg-BoxSuccess ld-msgDlg-top-icon"></div>'
            +'</div>'
            +'<div class="ld-msgDlg-Boxbottom">'
            +'<div class="ld-msgDlg-bottom-Boxtext linefeed" style="font-size:15px;padding-left: 0px;">'+that.ContentText
            +'</div>'
            +'</div>'
            +'</div>'
            +'</div>';
    }
    this.createHeadHtml = function () {
        this.popupheadhtml = '<div class="ld-E-pop-tit" id="' + this.divid + '_head" style="cursor:move">';
        if(this.headicon == 'tips'){
            this.popupheadhtml += '<div class="ld-E-ptita ld-E-ptita-left-headicon-1 '+that.iconclassname+'">' + '</div>';
        }
        this.popupheadhtml += '<strong class="ld-E-ptita">' + this.headtitle + '</strong>';
       
        this.popupheadhtml += '<div class="ld-fonticon ld-fonticon-close" value="' + arrJsPopLabel['LBL_CLOSE'] + '" title="' + arrJsPopLabel['LBL_CLOSE'] + '" id="' + this.divid + '_imgclose"></div>';
        this.popupheadhtml += '</div>';
        this.popupheadhtml += '</div>';
    }
    this.createBottomHtml = function () {
        var ok_class = '';
        var buttonpositionstyle = "";
        if (this.buttonPosition == 'center') {
            //   buttonpositionstyle=" style='text-align:center;width:100%;position:absolute;bottom:0px'";
        } else if (this.buttonPosition == 'right') {
            buttonpositionstyle = " style='text-align:right;width:100%;position:absolute;bottom:0px'";

        }
        if (this.OkText != undefined && this.OkText != "no" && this.CancelText != "no" && this.CancelText != undefined) {
            this.popupbottomhtml = '<div class="ld-E-pbtn-bg" ' + buttonpositionstyle + ' id="' + this.divid + '_popupbottom"> ';  //2023-5-30 class="ld-E-pbtn-bg"为底部有背景色样式，ld-E-pbtn-nobg底部无背景色样式
            var funname = this.Okfun.funname;
            if (funname == undefined) {
                funname = this.Okfun.name;
            }
            this.popupbottomhtml += this.createTextBeforeSave();
            this.popupbottomhtml += '<input name="button" id="' + this.divid + '_btnok" class="E_pbtnok ld-button ld-button-primary' + ok_class + '" value="' + this.OkText + '" tagClick="' + funname + '"  type="button">';
            this.popupbottomhtml += '<input name="button" class="E_pbtncancel ld-button ld-button-cancel" value="' + this.CancelText + '" id="' + this.divid + '_btncancel" type="button">'

            this.popupbottomhtml += ' </div>';
            this.btnokid = this.divid + "_btnok";
            this.btncancelid = this.divid + "_btncancel";
        }
        else if (this.OkText != undefined && this.OkText != "no") {
            var funname = this.Okfun.funname;
            if (funname == undefined) {
                funname = this.Okfun.name;
            }
            this.popupbottomhtml = '<div class="ld-E-pbtn-bg" ' + buttonpositionstyle + ' id="' + this.divid + '_popupbottom"> ';
            this.popupbottomhtml += '<input name="button" id="' + this.divid + '_btnok" class="E_pbtnok ld-button ld-button-primary' + ok_class + '" value="' + this.OkText + '" tagClick="' + funname + '"  type="button">';

            this.popupbottomhtml += ' </div>';
            this.btnokid = this.divid + "_btnok";
        }
        else if (this.CancelText != "no" && this.CancelText != undefined) {
            this.popupbottomhtml += '<span>&nbsp;</span><input name="button" class="E_pbtncancel ld-button ld-button-cancel" value="' + this.CancelText + '" id="' + this.divid + '_btncancel" type="button">'
            this.popupbottomhtml += ' </div>';
            this.btnokid = this.divid + "_btnok";
            this.btncancelid = this.divid + "_btncancel";
        }
    }
}
MessagePopup.load=function(headtitle,Okfun,cssWidth,module,OkText,CancelText) {
    MessagePopup.prototype=new CrmPopup();  
    MessagePopup.prototype.constructor=MessagePopup;  
     
    var MsgPopupobj=new MessagePopup();
    MsgPopupobj.setParams(headtitle,Okfun,"",cssWidth,module,"",OkText,"",CancelText);
    MessagePopup.popupobj=MsgPopupobj;
    return MsgPopupobj;
}

/*外部js调用，函数名中Tip：提示框；Zero、One、Two为按钮个数；后缀代表提示框类型*/
/*无按钮，消息提示类型*/
MessagePopup.TipZero_warning=function(ContentText) //warning：警告，为空默认为警告提示
{
    timekeeping_messageRemindsMsg(ContentText,'warning','','')
}
MessagePopup.TipZero_success=function(ContentText) //success;成功
{
    timekeeping_messageRemindsMsg(ContentText,'success','','')
}
MessagePopup.TipZero_error=function(ContentText) //error：错误
{
    timekeeping_messageRemindsMsg(ContentText,'error','','')
}
MessagePopup.TipZero_info=function(ContentText) //message：普通提示
{
    timekeeping_messageRemindsMsg(ContentText,'message','','')
}
/*单按钮，弹出提示框*/
MessagePopup.TipOne_warning=function(ContentText)  //warning：警告，为空默认为警告提示
{
    singlebtn_warningRemindsMsg(ContentText,"","");
}
MessagePopup.TipOne_success=function(ContentText)  //success;成功
{
    singlebtn_successRemindsMsg(ContentText,"","");
}
/*双按钮，弹出提示框*/
MessagePopup.TipTwo_warning=function(ContentText)  //warning：警告，为空默认为警告提示
{
    default_warningRemindsMsg(ContentText,"","","",'yes','yes');
}
MessagePopup.TipTwo_success=function(ContentText)  //success;成功
{
    default_successRemindsMsg(ContentText,"","","",'yes','yes');
}

//本js内部调用
/**
 * 消息提示弹框提醒
 * @param $Content_Text//内容
 * @param $message_type//消息提示类型，warning：警告，success;成功，message：普通提示，error：错误，为空默认为警告提示
 * @param $css_Width//宽度
 * @return string
 */
function timekeeping_messageRemindsMsg(Content_Text,message_type,css_Width,set_Time){  //预制计时消息提示，警告/成功/普通/错误消息提示
    var Messageobj  = MessagePopup.load('','','','','','');
    if(css_Width == '' || css_Width == undefined){
        css_Width = 'auto';
    }
    if(set_Time == '' || set_Time == undefined) set_Time = 2500;
    var data_arr = {
        headtitle : '',
        headicon : '',
        tipsicon : message_type,
        Okfun : '',
        Cancelfun : '',
        cssWidth : css_Width,
        module : '',
        OkText : 'no',
        CancelText : 'no',
        ContentText : Content_Text,
        setTime : set_Time,
    };
    Messageobj.CommonRemindsMsg(data_arr)
}

/**
 * 弹框提醒
 * @param $css_Width//宽度
 * @param $Ok_text//确定按钮名称，为空暂时默认为确定
 * @param $Content_Text//内容
 * @return string
 */
function singlebtn_warningRemindsMsg(Content_Text,css_Width,Ok_text){  //预制单按钮弹出层，警告图标
    var Messageobj  = MessagePopup.load('','','','','','');
    var data_arr = {
        headtitle : 'warmprompt',
        headicon : 'tips',
        tipsicon : "warning",
        Okfun : msgConfirm,
        Cancelfun : '',
        cssWidth : css_Width,
        module : '',
        OkText : Ok_text,
        CancelText : 'no',
        ContentText : Content_Text,
        setTime : 0,
    };
    Messageobj.CommonRemindsMsg(data_arr)
}
function singlebtn_warningRemindsMsg_hastitle(Content_Text,title,css_Width,Ok_text){  //预制单按钮弹出层，警告图标
    var Messageobj  = MessagePopup.load('','','','','','');
    var data_arr = {
        headtitle : title,
        headicon : 'tips',
        tipsicon : "warning",
        Okfun : msgConfirm,
        Cancelfun : '',
        cssWidth : css_Width,
        module : '',
        OkText : Ok_text,
        CancelText : 'no',
        ContentText : Content_Text,
        setTime : 0,
    };
    Messageobj.CommonRemindsMsg(data_arr)
}
function singlebtn_successRemindsMsg(Content_Text,css_Width,Ok_text){  //预制单按钮弹出层，成功图标
    var Messageobj  = MessagePopup.load('','','','','','');
    var data_arr = {
        headtitle : 'tips',
        headicon : 'tips',
        tipsicon : "success",
        Okfun : msgConfirm,
        Cancelfun : '',
        cssWidth : css_Width,
        module : '',
        OkText : Ok_text,
        CancelText : 'no',
        ContentText : Content_Text,
        setTime : 0,
    };
    Messageobj.CommonRemindsMsg(data_arr)
}
/**
 * 弹框提醒
 * @param $Ok_fun//确定按钮方法函数
 * @param $head_title//标题
 * @param $css_Width//宽度
 * @param $Ok_text//确定按钮名称，为空暂时默认为确定
 * @param $Cancel_Text//取消按钮名称
 * @param $Content_Text//内容
 * @return string
 */
function default_warningRemindsMsg(Content_Text,head_title,Ok_fun,css_Width,Ok_text,Cancel_Text){  //预制双按钮弹出层，警告图标
    var Messageobj  = MessagePopup.load('','','','','','');
    if(head_title == '' || head_title == undefined){
        head_title = 'warmprompt';
    }
    var data_arr = {
        headtitle : head_title,
        headicon : 'tips',
        tipsicon : "warning",
        Okfun : Ok_fun,
        Cancelfun : '',
        cssWidth : css_Width,
        module : '',
        OkText : Ok_text,
        CancelText : Cancel_Text,
        ContentText : Content_Text,
        setTime : 0,
    };
    Messageobj.CommonRemindsMsg(data_arr);
}
function default_successRemindsMsg(Content_Text,head_title,Ok_fun,css_Width,Ok_text,Cancel_Text){  //预制双按钮弹出层，成功图标
    var Messageobj  = MessagePopup.load('','','','','','');
    if(head_title == '' || head_title == undefined){
        head_title = 'warmprompt';
    }
    var data_arr = {
        headtitle : head_title,
        headicon : 'tips',
        tipsicon : "success",
        Okfun : Ok_fun,
        Cancelfun : '',
        cssWidth : css_Width,
        module : '',
        OkText : Ok_text,
        CancelText : Cancel_Text,
        ContentText : Content_Text,
        setTime : 0,
    };
    Messageobj.CommonRemindsMsg(data_arr)
}