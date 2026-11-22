// @edit:liushuai,2021-07-05,reason:【ID1001745】灵当语音盒，增加“自动拨号”功能
function AutoDial(module){
    this.module = module;
    this.selectidstring = '';//选择的record集合，全选为all
    this.selectcount = 0;//选择总数
    // this.selectidarr = [];//实际待处理的record集合
    this.selectvalidcount = 0;//实际有效的选择总数

    this.havedail = 0;//已拨打
    this.haveskip = 0;//已跳过
    this.havedelete = 0;//已删除

    // this.isAutoDial = 'yes';//是否为灵当语音盒自动拨号
    this.isStartAutoDial = 'no';//是否开始自动拨号

    this.dialStatus = ["未拨打","正在拨打","已拨打","已跳过，没有手机号"];
    this.currentDialRecord = 0;//当前处理的列表id
    this.currowobj = {};//当前行的对象

    var that = this;

    // this.timeId = 0;

    this.InitAutoDial = function () {
        that.getSelectIds();
    }

    //1、获取所有选择行
    this.getSelectIds = function () {
        List_CheckBox_Ids.getIds(module);
        var excludedRecords = $('excludedRecords').value;
        var idstring = List_CheckBox_Ids.ids;//选择的ids，全选为all
        var rows_num = List_CheckBox_Ids.num_rows;
        //判断至少选择一条单据
        if(rows_num < 1) {
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
            return false;
        }
        //判断是否超过上限
        if (parseInt(rows_num) > parseInt(getMaxMassOperationLimit())) {
            var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', rows_num, getMaxMassOperationLimit(), '');
            if (confirm(confirm_str)) {
            } else {
                return false;
            }
        }

        // that.selectidstring = idstring;
        // that.selectcount = rows_num;//选择总数

        //跳转新页签（自动拨号列表）
        var tmpurl = "&idstring="+encodeURIComponent(idstring)+"&excludedRecords="+encodeURIComponent(excludedRecords)+"&selectcount="+rows_num;
        window.open('index.php?module=Users&action=UsersAjax&file=AutoDial&mode=autodiallist&frommodule='+ module + tmpurl);

    }

    ///2、开始拨号
    this.StartDialing = function () {
        if (that.currentDialRecord == 0) {//刚开始拨打
            //第一列 当前列
            that.currowobj = ld("div[name=autodiallist]").find('tr').eq(1);
        }else{
            that.currowobj = that.currowobj.next();
        }

        //下一个对象还有值，表示还没拨打完
        if (isAutoDial == 'yes' && that.isStartAutoDial == 'yes' && that.currowobj.attr("record") != undefined) {
            //从列表获取手机号，1、客户模块，返回手机号和首要联系人的contactid(如果设置)。2、联系人模块，返回手机号

            var record = that.currowobj.attr("record");
            that.currentDialRecord = record;
            if (record > 0) {
                var mobile = that.currowobj.attr("mobile");
                if (mobile != '' && mobile != undefined) {
                    // var IDX = parseInt(that.currowobj.attr("index"))+1;
                    // console.log('正在拨打第'+IDX+"个，手机号为："+mobile);

                    that.currowobj.find("td[name=dialstatus]").html("正在拨打");
                    that.currowobj.attr("dialstatus",'1');

                    if (module == 'Accounts') {
                        var detailrecordid = that.currowobj.find('[name="contactid"]').val();
                    } else if (module == 'Contacts') {
                        var detailrecordid = '';
                    }

                    console.log([mobile, module, record, '', detailrecordid]);

                    that.havedail++;

                    /*if (that.timeId == 0) {//用定时器测试自动拨号
                        that.timeId = setInterval(function () {
                            that.currowobj.find("td[name=dialstatus]").html("已拨打");
                            that.currowobj.attr("dialstatus",'2');
                            that.StartDialing();

                        }, 3000);
                    }*/


                    // YiweiTools.getInstance().ListOnDailout(mobile,module,record,'',detailrecordid);
                    //ls 20221221 BUG0060065 数据行和语音文件错位(连续拨号时，由于录音文件需要压缩处理再上传，此时对应关系错位（当前通话的talkid标识以改变，导致talkid和录音文件没对上），先等待10s)
                    setTimeout(function(){YiweiTools.getInstance().ListOnDailout(mobile,module,record,'',detailrecordid);}, 10000);

                    return;
                } else {
                    that.haveskip++;
                    that.currowobj.find("td[name=dialstatus]").html("已跳过，没有手机号");
                    that.currowobj.attr("dialstatus",'3');
                    //如果没有获取到手机号，就跳过（其他异常情况也继续拨打下一个）
                    console.log('没有获取到手机号，跳过第' + eval(parseInt(that.currowobj.attr("index"))+1)+"个");

                    // audioRemindsMsg("","","","","","没有手机号，跳过第" + eval(parseInt(that.currowobj.attr("index"))+1)+"个");
                    // that.StartDialing();
                    setTimeout(function(){that.StartDialing();}, 1000);
                }

            } else {
                //异常情况，基本不会发生，除非后台数据处理错误。
                console.log('异常情况');
                that.StartDialing();
            }
        }else if (isAutoDial == 'yes' && that.isStartAutoDial == 'no' && that.currowobj.attr("record") != undefined) {//暂停状态
            // clearInterval(that.timeId);
            // that.timeId = 0;

            if (that.currentDialRecord > 0) {//非第一行的暂停
                that.currowobj = that.currowobj.prev();
            }
        }else if(isAutoDial == 'yes'){
            audioRemindsMsg("","","","","","自动拨号已完成");

            that.selectcount = ld("input[name=selectcount]").val();//选择单据总数
            that.selectvalidcount = ld("input[name=selectvalidcount]").val();//有效单据总数
            console.log("共选择了"+that.selectcount+",有效选择"+that.selectvalidcount+",已拨打"+that.havedail+",已跳过"+that.haveskip+",已删除"+that.havedelete);

            // console.log(that.timeId);
            // clearInterval(that.timeId);
            // that.timeId = 0;

            ld("#actionstatus").val(arrJsPopLabel['FINISHED']);//完成
            ld("#actionstatus").attr("actionstatus",'finished');

            return false;
        }
    }

    // 删除当前行
    this.removeTr = function (obj) {
        ld(obj).parents("tr").eq(0).remove();//删除第一个父tr标签
        that.havedelete++;
    }

    //切换拨打、暂停状态
    this.changeActionStatus  = function () {
        if (ld("#actionstatus").attr("actionstatus") == 'start'){ //拨打完成时actionstatus为finished

            if (YiweiTools.getInstance().isconnect === false) {
                console.log("自动拨号语音盒连接失败");
                audioRemindsMsg("","","","","","请检查设备是否连接成功");
                return false;
            }
            ld("#actionstatus").val(arrJsPopLabel['PauseDial']);
            ld("#actionstatus").attr("actionstatus",'pause');

            that.isStartAutoDial = 'yes';

            that.StartDialing();
        }else if (ld("#actionstatus").attr("actionstatus") == 'pause'){
            that.isStartAutoDial = 'no';

            ld("#actionstatus").val(arrJsPopLabel['StartDial']);
            ld("#actionstatus").attr("actionstatus",'start');

            audioRemindsMsg("","","","","","已暂停");
        }else{
            audioRemindsMsg("","","","","","已经全部拨打完成");
        }
    }

}


AutoDial.test = function(){
    alert('test');
}

//提示
function audioRemindsMsg(headtitle,cssWidth,module,OkText,CancelText,ContentText){
    if(ContentText == '') ContentText=arrJsPopLabel['PLEASESELECTONEENTITY'];//内容
    var content = '<div id="audioCloseConfirm" class="pop_remind_content showError">'
        +'<div class="qui_dialog_body ww_dialog_body" style="background-color: #fff;">'
        +'<div class="msgDlg_left">'
        +'<div class="ww_commonImg ww_commonImg_Alert msgDlg_left_icon"></div>'
        +'</div>'
        +'<div class="msgDlg_right">'
        +'<div class="msgDlg_right_text" style="font-size:13px;padding-left: 4px;">'+ContentText
        +'</div>'
        +'</div>'
        +'</div>'
        +'</div>';
    if(ld("#audioCloseConfirm").length > 0) ld("#audioCloseConfirm").remove();//存在提示层情况下，先删除

    //是否弹出层判断，大于0是弹出层
    if(ld('div[class="dvpopupsroll"]').length > 0){
        //获取弹出层id
        // var popupobj=CrmPopup.getPopupObj('last');
        // ld('#'+popupobj.divid).append(content);

        ld('div[class="dvpopupsroll"]').append(content);
    }

    //2秒后，自动关闭提示弹出层
    setTimeout(function(){
        ld("#audioCloseConfirm").remove();
        return false;
    }, 2000);
}