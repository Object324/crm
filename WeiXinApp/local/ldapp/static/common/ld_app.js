//注册事件监听
function connectWebViewJavascriptBridge(callback) {
  if (window.WebViewJavascriptBridge) {
    callback(WebViewJavascriptBridge)
  }
  else {
     document.addEventListener(
    'WebViewJavascriptBridgeReady', function() {
      callback(WebViewJavascriptBridge)
    },false);
  }
}

var lingdangbridge='';
//注册回调函数，第一次连接时调用 初始化函数
connectWebViewJavascriptBridge(function(bridge) {
  lingdangbridge=bridge;
  lingdangbridge.init(function(message, responseCallback) {
    //bridgeLog('默认接收收到来自Java数据： ' + message);
    var responseData = '默认接收收到来自Java的数据，回传数据给你';
    responseCallback(responseData);
  });
})

lingdang.getLoginInfo=function (funobj){
  if(typeof window.WebViewJavascriptBridge==undefined){
    return;
  }
  setTimeout(function(){
    window.WebViewJavascriptBridge.callHandler("getLoginInfo", funobj, function(responseData) {
      //自动登录
      var json= JSON.parse(responseData);
      if(json.remember=='yes'){
        funobj(json);
      }
    });
  },200);
}

// 轨迹-选用户
lingdang.setChooseUserValueByApp=function(chooseuserarrstr){
  if(window.webkit){
    window.webkit.messageHandlers.setChooseUserValue.postMessage(chooseuserarrstr);
  }
  else if(window.WebViewJavascriptBridge){
    window.WebViewJavascriptBridge.callHandler("setChooseUserValue",chooseuserarrstr, function(responseData) {
      //param.success(responseData)
    });
  }
}

//获取android 手机品牌
lingdang.getAndroidbrand=function(param){
  if(window.webkit){
    window.webkit.messageHandlers.smsPhonePage.postMessage(phone);
  }
  else if(window.WebViewJavascriptBridge){
    window.WebViewJavascriptBridge.callHandler("getAndroidbrand","", function(responseData) {
      param.success(responseData)
    });
  }
}

lingdang.uploadbyloginfo=function(tmpinfo,params){
  if(window.WebViewJavascriptBridge){
    //上传指定的录音文件
    window.WebViewJavascriptBridge.callHandler("uploadbyloginfo",JSON.stringify(tmpinfo), function(responseData) {
      params.success()
    });
  }
}

lingdang.startuploadCallLog=function(){
  //开始上传录音文件，录音文件是否上传原生app有判断
  if(window.WebViewJavascriptBridge){
    window.WebViewJavascriptBridge.callHandler("startuploadCallLog","", function(responseData) {
    });
  }
}

lingdang.getListCallLog=function(param){
  if(window.webkit){
  }
  else if(window.WebViewJavascriptBridge){
    window.WebViewJavascriptBridge.callHandler("getListCallLog","", function(responseData) {
      param.success( JSON.parse(responseData));
    });
  }
}

lingdang.setMobileProfile=function(param){
  //获取android 手机品牌
  if(window.webkit){
  }
  else if(window.WebViewJavascriptBridge){
    if(param.type=='calllog'){
      window.WebViewJavascriptBridge.callHandler("getCallLogProfile","", function(responseData) {
      });
    }
    else if(param.type=='callphone'){
      window.WebViewJavascriptBridge.callHandler("getCallPhoneProfile","", function(responseData) {
      });
    }
    else if(param.type=='allfile'){
      window.WebViewJavascriptBridge.callHandler("getAllFileProfile","", function(responseData) {
      });
    }
    else if(param.type=='readwrite'){
      window.WebViewJavascriptBridge.callHandler("getFileReadWriteProfile","", function(responseData) {
      });
    }
  }
}

lingdang.getMobileProfile=function(param){
  //设置手机相关操作权限
  if(window.webkit){
  }
  else if(window.WebViewJavascriptBridge){
    if(param.type=='calllog'){
      window.WebViewJavascriptBridge.callHandler("getCheckCallPhoneRecordProfile","", function(responseData) {
        param.success(responseData)
      });
    }
    else if(param.type=='callphone'){
      window.WebViewJavascriptBridge.callHandler("getCheckCallPhoneProfile","", function(responseData) {
        param.success(responseData)
      });
    }
    else if(param.type=='allfile'){
      window.WebViewJavascriptBridge.callHandler("getCheckAllFileProfile","", function(responseData) {
        param.success(responseData)
      });
    }
    else if(param.type=='readwrite'){
      window.WebViewJavascriptBridge.callHandler("getCheckFileReadProfile","", function(responseData) {
        param.success(responseData)
      });
    }
  }
}

// 调用电话拨打界面
lingdang.smsPhonePageApp=function(phone){
  if(window.webkit){
    window.webkit.messageHandlers.smsPhonePage.postMessage(phone);
  }
  else if(window.WebViewJavascriptBridge){
    window.WebViewJavascriptBridge.callHandler("smsPhonePage", phone, function(responseData) {
    });
  }
}
lingdang.smsPhoneApp=function(phone){
  if(window.webkit){
    window.webkit.messageHandlers.smsPhone.postMessage(phone);
  }
  else{
    window.WebViewJavascriptBridge.callHandler("smsPhone", phone, function(responseData) {
    });
  }
}

lingdang.isMainPage=function(){
  setTimeout(function(){
    window.WebViewJavascriptBridge.callHandler("setisFirstPage", "", function(responseData) {
      //判断是否为crm的主界面
    });
  },250)
}

lingdang.LoginOff=function(){
  //在退出登录界面 有提示，询问是否真的退出
  if(window.webkit){
    wx_confirm = lingdang.weui.confirm("您确定要退出系统吗", {
      title: "提示",
      buttons: [{
          label:"取消",
          type: 'default',
          onClick: function () {}
        }, {
          label: "确定",
          type: 'primary',
          onClick: function () {
            window.webkit.messageHandlers.getLoginOff.postMessage("");
          }
        }
      ]
    });
  }
  else{
    window.WebViewJavascriptBridge.callHandler("getLoginOff", "", function(responseData) {
      //退出登录,设置登录界面信息
    });
  }
}

lingdang.ClickExitBtn=function(){
  //点击退出登录按钮
  if(window.webkit){
    window.webkit.messageHandlers.ClickExitBtn.postMessage("");
  }
  else{
    window.WebViewJavascriptBridge.callHandler("ClickExitBtn", "", function(responseData) {
    });
  }
}

lingdang.setIosisBackFun=function(str){
  //ios点击返回键
  if(lingdang.IosBackFun!=undefined){
    if(lingdang.IosBackFun()){
      window.webkit.messageHandlers.webViewGoBack.postMessage("");
      return 'yes';
    }
  }
  else{
    setTimeout(function(){
      if(lingdang.IosBackFun())  {
        window.webkit.messageHandlers.webViewGoBack.postMessage("");
        return 'yes';
      }
    },180)
  }
  return 'no';
}

lingdang.onHistoryBack=function(funobj){
  setTimeout(function(){
    //原生app调用js函数
    if(window.webkit){
      lingdang.IosBackFun =funobj;
      window.webkit.messageHandlers.IsjsHistoryFun.postMessage("");
     //window.webkit.messageHandlers.onHistoryBack.postMessage("");
    }
    else if(window.WebViewJavascriptBridge) {
      window.WebViewJavascriptBridge.callHandler("IsjsHistoryFun","",function(responseData){
      })
      lingdangbridge.registerHandler("onHistoryBack", function(data, responseCallback) {
        if(funobj()){
          responseCallback("");
        }
      });
    }
  },220)
}

lingdang.setIosLocationResult=function(responseData){
  var json= JSON.parse(responseData);
  if(json.code==1){
    lingdang.IosLocationFun.success({"latitude":json.latitude,'longitude':json.longitude})
  }
  else{
    lingdang.IosLocationFun.fail({"msg":"error"})
  }
}

lingdang.scanQRCode=function(param){
  if(window.webkit){
    lingdang.IosLocationFun=param;
    window.webkit.messageHandlers.startLocation.postMessage("");
  }
  else{
    window.WebViewJavascriptBridge.callHandler("scanQRCode", param, function(responseData) {
      var json= JSON.parse(responseData);
      if(json.code==1){
        param.success({"resultStr":json.qrcode})
      }
      else{
        param.fail({"msg":"error"})
      }
    });
  }
}

lingdang.getLocation=function(param){
  if(window.webkit){
    lingdang.IosLocationFun=param;
    window.webkit.messageHandlers.startLocation.postMessage("");
  }
  else{
    window.WebViewJavascriptBridge.callHandler("getLocation", param, function(responseData) {
      var json= JSON.parse(responseData);
      if(json.code==1){
        param.success({"latitude":json.latitude,'longitude':json.longitude})
      }
      else{
        param.fail({"msg":"error"})
      }
    });
  }
}

lingdang.setUserInfo=function(param){
  if(window.webkit){
    window.webkit.messageHandlers.setUserInfo.postMessage(param);
  }
  else{
    window.WebViewJavascriptBridge.callHandler("setUserInfo", param, function(responseData) {
    });
  }
}

lingdang.CreateMsg=function(crmurl,userid,version,websaaurl){
  if(window.webkit){
    window.webkit.messageHandlers.CreateMsg.postMessage({"crmurl":crmurl,'userid':userid,'version':version,'websaaurl':websaaurl});
  }
  else{
    window.WebViewJavascriptBridge.callHandler("CreateMsg", {"crmurl":crmurl,'userid':userid,'version':version,'websaaurl':websaaurl}, function(responseData) {
    });
  }
}

// 返回机器型号
lingdang.getMobileDeviceByApp=function(){
  if(window.webkit){
    return 'ios';
  }
  else{
    return 'android';
  }
}

lingdang.showMapTrack=function(){
  if(window.webkit){
    window.webkit.messageHandlers.showMapTrack.postMessage("");
  }
  else{
    window.WebViewJavascriptBridge.callHandler("showMapTrack","", function(responseData) {
    });
  }
}
// 设置标题
lingdang.setDocumentTitleApp=function(title){
  setTimeout(function(){
    if(typeof window.WebViewJavascriptBridge==undefined && typeof window.webkit==undefined){
      return;
    }
    //调用原生系统函数
    if(window.webkit){
      window.webkit.messageHandlers.setCRMTitle.postMessage(title);
    }
    else{
      window.WebViewJavascriptBridge.callHandler("setCRMTitle", title, function(responseData) {
      })
    }
  },250);
}

//打开地图
lingdang.mapViewApp=function (latitudeVal, longtitudeVal, signaddress, name, scale){
   /* lingdang.openLocation({
      latitude: parseFloat(data.result.list[1]), // 纬度，浮点数，范围为90 ~ -90//31.2537255481
      longitude: parseFloat(data.result.list[2]), // 经度，浮点数，范围为180 ~ -180。//121.55472159951
      name: self.arrFixedLabel.SINGINADDRESS, // 位置名
      address: address, // 地址详情说明
      scale: scale, // 地图缩放级别,整形值,范围从1~28。默认为最大
      infoUrl: '' // 在查看位置界面底部显示的超链接,可点击跳转
  });*/
  if(window.webkit){
    window.webkit.messageHandlers.openLocation.postMessage({
      latitude: parseFloat(latitudeVal), // 纬度，浮点数，范围为90 ~ -90//31.2537255481
      longitude: parseFloat(longtitudeVal), // 经度，浮点数，范围为180 ~ -180。//121.55472159951
       name: name, // 位置名
        address: signaddress, // 地址详情说明
        scale: scale, // 地图缩放级别,整形值,范围从1~28。默认为最大
        infoUrl: '' // 在查看位置界面底部显示的超链接,可点击跳转
    });
  }
  else{
    window.WebViewJavascriptBridge.callHandler("openLocation",{
      latitude: parseFloat(latitudeVal), // 纬度，浮点数，范围为90 ~ -90//31.2537255481
      longitude: parseFloat(longtitudeVal), // 经度，浮点数，范围为180 ~ -180。//121.55472159951
      name: name, // 位置名
        address: signaddress, // 地址详情说明
        scale: scale, // 地图缩放级别,整形值,范围从1~28。默认为最大
        infoUrl: '' // 在查看位置界面底部显示的超链接,可点击跳转
      }, 
    function(responseData) {
    });
  }
}