// @edit:liushuai,2021-05-26,reason:【ID1001533】呼叫中心接口设置，增加接口类型“灵当语音盒”
var isAutoDial = "no";////是否为灵当语音盒自动拨号，默认不是自动拨号
var YiweiTools = (function(){
    var webSocket;
    var timer;
    // var isconnect;
    var devicename;    //设备名称

    var userid;
    //列表去电匹配手机号和模块
    var frommodule='';
    var fromid = '';
    var detailrecordid = '';
    //参数：传递给单例的一个参数集合
    function Yiwei() {
        this.name = 'YiweiTools';
        this.isconnect = true;
    }

    Yiwei.prototype.InitWs = function() {
        var that = this; //这个this对象就是Yiwei
        webSocket = new WebSocket('ws://127.0.0.1:8555/api');
        //webSocket= new WebSocket('ws://192.168.2.213:8555');

        webSocket.onerror = function (event) {
            ld("#OnOpenDevice").css('display','none');
            ld("#OnCloseDevice").css('display','none');

            that.isconnect = false;
            if (isCallErrorRemind == 'yes') {
                audioRemindsMsg("","","","","","请先启动电话助手客户端");
            }
            console.log('webSocket.onerror: 未启动电话助手客户端');
        };
        webSocket.onclose = function (event) {
            that.isconnect = false;
            clearInterval(timer);//断开连接时清除心跳定时器（客户端退出、断开设备等）
            // console.log('与服务器断开连接');
        };
        //与WebSocket建立连接
        webSocket.onopen = function (event) {
            ld("#OnOpenDevice").css('display','block');
            ld("#OnCloseDevice").css('display','block');
            timer = setInterval(HeartBeatCheck, 60000);
            // console.log('与服务器端建立连接');

            Yiwei.prototype.OnOpenDevice();
        };


        function HeartBeatCheck() {
            webSocket.send('HeartBeatData');    //心跳检测
        }


        //处理服务器返回的信息
        webSocket.onmessage = function (event) {
            console.log(event.data);
            var msgJsonData = jQuery.parseJSON(event.data);
            var msg = msgJsonData.message;

            if (msgJsonData.type == "RealTimeState") {//通话状态
                // console.log('通话状态: '+msgJsonData.dynamicdata.realtimestate);
                //来电  去电
                if (msgJsonData.dynamicdata.realtimestate == 'incoming' || msgJsonData.dynamicdata.realtimestate == 'outgoing') {
                    // if (isAutoDial == 'no') {//自动拨号不弹屏、不跳转
                    Yiwei.prototype.CallPopUp(msgJsonData); //通话弹屏
                    // }
                }
                //来电接通   去电接通  开始录音
                if (msgJsonData.dynamicdata.realtimestate == 'inconnected' || msgJsonData.dynamicdata.realtimestate == 'outconnected'){
                    // console.log('开始录音');
                    Yiwei.prototype.OnStartRecord();
                }
                //挂断  结束录音
                if (msgJsonData.dynamicdata.realtimestate == 'hangup'){
                    // console.log('结束录音');
                    Yiwei.prototype.OnStopRecord();
                }

            } else if (msgJsonData.type == "CallRecord") {  //通话记录（通话结束后上报，无论是否接通）   挂断电话时，会先返回通话记录，再返回结束录音的值
                //1、上传通话记录
                Yiwei.prototype.SaveCallRecord(msgJsonData);
            }
            else {
                if (msg != null) {
                    // console.log('messages: '+msg);
                }
                if (msgJsonData.data != null) {
                    if (msgJsonData.data.invoke_command.toLowerCase() == "opendevice_multi") {
                        Yiwei.prototype.OnShowMenu();
                    }
                    if (msgJsonData.data.invoke_command.toLowerCase() == "getccid_multi") {//GetCCID_Multi
                        if (msgJsonData.dynamicdata.ccid == ''){
                            that.isconnect = false;
                            console.log('未插入SIM卡');
                            ld("#callnumber_yiwei").parent().parent().parent('li').css('display','none');
                            // ljj 20231030 XUQIU1002019 客户和联系人模块的“自动拨号”增加显示控制（刘素）,和"拨号"显示逻辑相同
                            ld(" [tag=ContinuousDialing]").hide();
                            if (isCallErrorRemind == 'yes') {
                                audioRemindsMsg("","","","","","未插入SIM卡");
                            }
                        }else{
                            ld("#callnumber_yiwei").parent().parent().parent('li').css('display','block');
                            // ljj 20231030 XUQIU1002019 客户和联系人模块的“自动拨号”增加显示控制（刘素）,和"拨号"显示逻辑相同
                            ld(" [tag=ContinuousDialing]").show();
                        }
                    }else if (msgJsonData.data.invoke_command.toLowerCase() == "getconnectedstate_multi")   //获取已连接设备
                    {
                        //解析已连接设备序列号
                        var devicelist = msgJsonData.dynamicdata.devicelist;
                        if (devicelist !== "") {
                            devicename = devicelist.split(",")[0];
                            // 获取设备信息（检查usb数据线是否连接（设备未连接））
                            // Yiwei.prototype.OnGetDeviceInfo();

                            //获取CCID（检查ccid判断是否插入SIM卡）
                            Yiwei.prototype.OnGetCCID();
                        }else{
                            that.isconnect = false;
                            console.log('设备未连接');
                            if (isCallErrorRemind == 'yes') {
                                audioRemindsMsg("","","","","","设备未连接");//USB数据线没连接
                            }
                        }
                    } else if (msgJsonData.data.invoke_command.toLowerCase() == "stoprecord_multi" && msgJsonData.data.state === true) {//结束录音(正常结束录音(接通)：state：true)  上传文件
                        //2、录音文件上传服务器（local、cos）
                        setTimeout(function(){Yiwei.prototype.OnUploadFile(msgJsonData)}, 2000);//先上传通话记录再上传语音文件,上传文件时，通话记录还没有返回值，所以需要延时2s
                    } else if (msgJsonData.data.invoke_command.toLowerCase() == "uploadfile") {
                        if (msgJsonData.data.state) {
                            // console.log('录音文件上传成功');
                        }else{
                            // console.log('录音文件上传失败');
                        }
                    } else if (msgJsonData.data.invoke_command.toLowerCase() == "closedevice_multi") {
                        that.isconnect = false;
                        if (isCallErrorRemind == 'yes') {
                            audioRemindsMsg("","","","","","设备已断开");
                        }
                    } /*else if (msgJsonData.data.invoke_command.toLowerCase() == "readsms") {
                        var a = msgJsonData.dynamicdata;
                        console.log('messageContent: '+'时间：' + a.time + '\n电话：' + a.phone + '\n内容：' + a.content);
                    } else if (msgJsonData.data.invoke_command.toLowerCase() == "getspeechrecognenbale") {
                        if (msgJsonData.data.state) {
                            console.log('speechrecognenable: 打开');
                        } else {
                            console.log('speechrecognenable: 关闭');
                        }
                    }*/
                }
            }

        };
    }

    // 隐藏客户端菜单，设置空则不隐藏
    //主页0，号码1，常规设置2，设备管理3，SIM 4, 辅助设备5, 系统设置6，AI设置7，联系人8，短信管理9，通话详情10，报表,11，自助修复12，帮助13
    /*Yiwei.prototype.OnHideMenu = function() {
        var hidemenu = "0,1,7,8,9,10,11,13";
        webSocket.send('{"command":"HideMenu","arguments":{"content":"'+hidemenu+'"}}');
    }*/

    //显示客户端菜单，设置空则全部隐藏
    //主页0，号码1，常规设置2，设备管理3，SIM 4, 辅助设备5, 系统设置6，AI设置7，联系人8，短信管理9，通话详情10，报表,11，自助修复12，帮助13
    Yiwei.prototype.OnShowMenu = function() {
        var showmenu = "2,3,4,5,6,12,13";
        webSocket.send('{"command":"ShowMenu","arguments":{"content":"'+showmenu+'"}}');
    }

    //连接设备
    Yiwei.prototype.OnOpenDevice = function() {
        webSocket.send('{"command":"OpenDevice_Multi"}');
        setTimeout(Yiwei.prototype.OnGetConnectedState, 3000);
    }

    //获取设备连接状态
    Yiwei.prototype.OnGetConnectedState = function() {
        webSocket.send('{"command":"GetConnectedState_Multi"}');
    }

    //获取设备信息
    /*Yiwei.prototype.OnGetDeviceInfo = function() {console.log(devicename);
        webSocket.send('{"command":"GetDeviceInfo_Multi","arguments":{"devicename":"' + devicename + '"}}');
    }*/

    //获取CCID
    Yiwei.prototype.OnGetCCID = function() {
        webSocket.send('{"command":"GetCCID_Multi","arguments":{"devicename":"' + devicename + '"}}');
    }

    //头部拨号
    Yiwei.prototype.HeaderOnDailout = function() {
        var number = document.getElementById('callnumber_yiwei').value;
        if (!empty(number)) {
            Yiwei.prototype.OnDailout(number);
        }
    }

    //列表及详情页拨号
    /*
    * modulename       模块名称
    * record           模块列表的id
    * tablename        关联的号码详情表
    * detailrecordid   关联的号码详情表id
    * */
    Yiwei.prototype.ListOnDailout = function(number,modulename,record,tablename,tmp_detailrecordid) {
        frommodule = modulename;
        fromid = record;
        detailrecordid = tmp_detailrecordid;
        Yiwei.prototype.OnDailout(number);
    }

    //拨号
    Yiwei.prototype.OnDailout = function(number) {
        webSocket.send('{"command":"Dial_Multi","arguments":{"phone":"' + ld.trim(number) + '","devicename":"' + devicename + '"}}');
    }
    //接听
    Yiwei.prototype.OnAnswer = function() {
        webSocket.send('{"command":"Answer_Multi","arguments":{"devicename":"' + devicename + '"}}');
    }
    //挂断
    Yiwei.prototype.OnHungUp = function() {
        webSocket.send('{"command":"HangUp_Multi","arguments":{"devicename":"' + devicename + '"}}');
    }

    //开始录音
    Yiwei.prototype.OnStartRecord = function() {
        webSocket.send('{"command":"StartRecord_Multi","arguments":{"devicename":"' + devicename + '"}}');
    }
    //结束录音
    Yiwei.prototype.OnStopRecord = function() {
        webSocket.send('{"command":"StopRecord_Multi","arguments":{"devicename":"' + devicename + '","isconverttomp3":"true"}}');
    }
    //断开设备
    Yiwei.prototype.OnCloseDevice = function() {
        webSocket.send('{"command":"CloseDevice_Multi","arguments":{"devicename":"' + devicename + '"}}');
    }
    //弹屏
    Yiwei.prototype.CallPopUp = function(msgJsonData) {
        if (msgJsonData.dynamicdata.realtimestate == 'incoming') {  //呼入弹屏  来电 0
            var calltype = '0';// msgJsonData.dynamicdata.type ==  'in'
        }else{  //1  去电/外拨/呼出;   去电跳转到跟进记录页面
            var calltype = '1';
        }

        var surl = "index.php?module=Users&action=UsersAjax&file=CallYiwei&callid="+encodeURIComponent(msgJsonData.dynamicdata.number)+"&calltype="+calltype+"&talkid="+encodeURIComponent(msgJsonData.dynamicdata.talkid)+"&frommodule="+frommodule+"&fromid="+fromid; //列表或详情页通过电话小图标去电时才有值

        ld.ajax({
            url: surl,
            type: 'POST',
            data: '',
            dataType:'json',
            timeout:20000,
            success:function(data){
                //console.log(data);
                if(data.code==1)
                {
                    if (data.result.num_rows == 1) {
                        window.open(data.result.href);
                    }else{
                        var popupobj = CrmPopup.load("","","","LdPopWidth1100px",'Users',"","","");
                        popupobj.prevshow();

                        popupobj.setParams(data.result.title,"","","LdPopWidth1100px",'Users',"","","","");
                        popupobj.show(data.result.html);
                    }

                }
            }
        });

    }

    //保存通话记录 (挂断时)
    Yiwei.prototype.SaveCallRecord = function(msgJsonData) {
        var calltype = msgJsonData.dynamicdata.type; //接通类型：0 外拨（去电） 1 来电  注：客户端返回的类型和crm定义的类型相反
        if (calltype == 1) {
            calltype = 0;
        }else{
            calltype = 1;
        }

        var phone = msgJsonData.dynamicdata.number;//手机号码
        var begintime = msgJsonData.dynamicdata.answertime;//接听时间  // 未接通时begintime为空
        var endtime = msgJsonData.dynamicdata.endtime;//结束时间
        var talkid = msgJsonData.dynamicdata.talkid;//通话id

        var status = msgJsonData.dynamicdata.state;//应答状态  0：呼出 ，对方未振铃，可能是空号 1：外拨（对方未接听）  2：接通  3：来电（未接来电）
        if (status == 2) {
            status = '接通';
        }else{
            status = '未接通';
            begintime = endtime;
        }

        var surl = "index.php?module=Users&action=UsersAjax&file=CallYiwei&mode=savecallyiwei&callid="+encodeURIComponent(phone)+"&talkid="+encodeURIComponent(talkid)+"&calltype="+calltype+"&status="+encodeURIComponent(status)+"&begintime="+encodeURIComponent(begintime)+"&endtime="+encodeURIComponent(endtime)+"&frommodule="+frommodule+"&fromid="+fromid+"&detailrecordid="+detailrecordid;//列表或详情页通过电话小图标去电时才有值

        ld.ajax({
            url: surl,
            type: 'POST',
            data: '',
            dataType:'json',
            timeout:20000,
            success:function(data){
                //console.log(data);
                if(data.code==1)
                {
                    userid = data.result.userid;
                }

                frommodule = fromid = detailrecordid = ''; //防止通过电话小图标拨打后，再从头部拨号造成全局变量污染。

                //@edit:liushuai,2021-07-05,reason:【ID1001745】灵当语音盒，增加“自动拨号”功能(需要考虑到拨号列表页签存在的同时，从列表拨号的情况)
                if (typeof cls_AutoDial != "undefined" && isAutoDial == 'yes' && cls_AutoDial.currowobj != "undefined" && Object.keys(cls_AutoDial.currowobj).length != 0) {
                    cls_AutoDial.currowobj.find("td[name=dialstatus]").html("已拨打");
                    cls_AutoDial.currowobj.attr("dialstatus",'2');
                    cls_AutoDial.StartDialing();
                }

            }
        });

    }

    //上传文件到本地 （挂断电话时）
    Yiwei.prototype.OnUploadFile = function(msgJsonData) {
        var recordpath = msgJsonData.dynamicdata.recordpath; //语音文件地址  默认不需要管返回值地址是否为相对路径   返回什么就是什么
        var talkid = msgJsonData.dynamicdata.talkid;//通话id

        var url = Yiwei.prototype.currentURL();
        url += 'uploadRecordFile.php';
        //CURRENT_USER_ID  全局变量LeftMenu.tpl
        var sendJson = '{"command":"UploadFile","arguments":{"url":"' + url + '","file":"' + recordpath + '","diykey":"talkid,userid","diyvalue":"'+talkid+','+CURRENT_USER_ID+'"}}';
        console.log(sendJson);
        webSocket.send(sendJson);
    }

    //获取通话状态
    // Yiwei.prototype.OnGetCallState = function() {
    //     webSocket.send('{"command":"GetCallState_Multi","arguments":{"devicename":"' + devicename + '"}}');
    // }


    //获取当前地址栏url
    Yiwei.prototype.currentURL = function(url) {
        url =  url|| '';
        if (typeof(url) !== "string" || url.match(/^https?:\/\//i) || url.match(/^\//)) {
            return url;
        }

        var currentURL = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ":" + window.location.port : "");

        var indexSlash = window.location.pathname.lastIndexOf("/");
        if (indexSlash <= 0) {
            var path = "/";
        } else {
            var path = window.location.pathname.substr(0, indexSlash) + "/";
        }

        return currentURL + path + url;

    };

    //右上角连接服务时，才去设备错误提醒
    Yiwei.prototype.InitWsAndRemind = function() {
        isCallErrorRemind = 'yes';
        Yiwei.prototype.InitWs();
    }


    //实例容器
    var instance;

    var _static = {
        name: 'YiweiTools',

        //获取实例的方法
        getInstance: function () {
            if (instance === undefined) {
                instance = new Yiwei();
            }
            return instance;

        }
    };
    return _static;
})();


YiweiTools.getInstance().InitWs();
