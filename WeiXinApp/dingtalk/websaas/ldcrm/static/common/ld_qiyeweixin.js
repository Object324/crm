//配置微信JS-SDK
lingdang.getWxConfig = function (){
  let appId = sessionStorage.getItem('corpid'),
      timestamp = sessionStorage.getItem('tamptimes'),
      nonceStr = sessionStorage.getItem('noncestr'),
      signature = sessionStorage.getItem('signature');
  wx.config({
    beta: true,// 必须这么写，否则在微信插件有些jsapi会有问题 false
    debug: false,// 开启调试模式,调用的所有api的返回值会在客户端打印出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
    appId: appId,// 必填，企业微信的cropID
    timestamp: timestamp,// 必填，生成签名的时间戳
    nonceStr: nonceStr,// 必填，生成签名的随机串
    signature: signature,// 必填，签名，见附录1
    jsApiList: [// 必填，需要使用的JS接口列表，所有JS接口列表见附录2
      'checkJsApi',
      'hideMenuItems',
      'hideAllNonBaseMenuItem',
      'closeWindow',
      'shareAppMessage',//自定义转发到会话
      'shareWechatMessage',//自定义转发到微信
      'chooseImage',//图片相关
      'getLocalImgData',
      'previewImage',
      'uploadImage',
      'downloadImage',
      'previewFile',//预览文件接口
      'openLocation',//签到、地图相关
      'getLocation',
      'onHistoryBack',//监听页面返回事件
      'scanQRCode',//调起企业微信扫一扫接口
      'selectEnterpriseContact',//通讯录选人接口
      'openEnterpriseChat'//创建会话接口
    ]
  });
}

// agentConfig调用
lingdang.getAgentConfig= function (){
  if(sessionStorage.getItem('agentid') != ''){
    let corpid = sessionStorage.getItem('corpid'),
        agentid = sessionStorage.getItem('agentid'),
        timestamp = sessionStorage.getItem('tamptimes'),
        nonceStr = sessionStorage.getItem('noncestr'),
        signature = sessionStorage.getItem('agent_signature');

    wx.agentConfig({
      corpid: corpid, // 必填，企业微信的corpid，必须与当前登录的企业一致
      agentid: agentid, // 必填，企业微信的应用id （e.g. 1000247）
      timestamp: timestamp, // 必填，生成签名的时间戳
      nonceStr: nonceStr, // 必填，生成签名的随机串
      signature: signature,// 必填，签名，见附录-JS-SDK使用权限签名算法
      jsApiList: ['selectExternalContact','openEnterpriseChat'], //必填
      success: function(res) {
        // console.log('成功调用');
      },
      fail: function(res) {
        // console.log(res);
      }
    });
  }
}

//配置微信JS-SDK
lingdang.getExternalContactConfig = function (appId, tamptimes, noncestr, signature){
  wx.config({
    beta: true,// 必须这么写，否则在微信插件有些jsapi会有问题 false
    debug: false,// 开启调试模式,调用的所有api的返回值会在客户端打印出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
    appId: appId,// 必填，企业微信的cropID
    timestamp: tamptimes,// 必填，生成签名的时间戳
    nonceStr: noncestr,// 必填，生成签名的随机串
    signature: signature,// 必填，签名，见附录1
    jsApiList: [// 必填，需要使用的JS接口列表，所有JS接口列表见附录2
      'checkJsApi',
      'hideMenuItems',
      'hideAllNonBaseMenuItem',
      'selectExternalContact',//外部联系人选人接口
      'openEnterpriseChat'
    ]
  });
}

//转发到会话
lingdang.shareAppMessage = function(sharetitle,shareintroduction,shareurl,sharepicture){
  wx.invoke(
    "shareAppMessage", {
      title: sharetitle, // 分享标题
      desc: shareintroduction, // 分享描述
      link: shareurl, // 分享链接
      imgUrl: sharepicture // 分享封面
    }, function(res) {
      if (res.err_msg == "shareAppMessage:ok") {
      }
    }
  );
}

//转发到微信
lingdang.shareWechatMessage = function(sharetitle,shareintroduction,shareurl,sharepicture){
  wx.invoke(
    "shareWechatMessage", {
      title: sharetitle, // 分享标题
      desc: shareintroduction, // 分享描述
      link: shareurl, // 分享链接
      imgUrl: sharepicture // 分享封面
    }, function(res) {
      if (res.err_msg == "shareWechatMessage:ok") {
      }
    }
  );
}

//打开链接并显示菜单项
lingdang.gotoOpenMenuItems=function (){
  // 显示的菜单项
  wx.showMenuItems({
    menuList: [// 要显示的菜单项，所有menu项见附录3
      'menuItem:share:appMessage',//转发
      'menuItem:share:wechat'//微信
    ]
  });
}

//打开附件
lingdang.previewFileQiyeweixin=function (url, name, size){
  wx.previewFile({
    url: url, // 需要预览文件的地址(必填，可以使用相对路径)
    name: name, // 需要预览文件的文件名(不填的话取url的最后部分)
    size: size // 需要预览文件的字节大小(必填)
  });
}

//打开图片
lingdang.previewImageQiyeweixin=function (imgArr, open_url){
  wx.previewImage({
    current: open_url, // 当前显示图片的http链接
    urls: imgArr // 需要预览的图片http链接列表
  });
}

//打开URL
lingdang.gotoOpenUrlQiyeweixin=function (url){
  // 显示的菜单项
  wx.showMenuItems({
    menuList: [// 要显示的菜单项，所有menu项见附录3
      'menuItem:share:appMessage',//转发
      'menuItem:share:wechat'//微信
    ]
  });
  window.location.href = url;
}

//打开地图
lingdang.mapViewQiyeweixin=function (latitudeVal, longtitudeVal, signaddress, name, scale){
  wx.openLocation({
    latitude: parseFloat(latitudeVal), // 纬度，浮点数，范围为90 ~ -90//31.2537255481
    longitude: parseFloat(longtitudeVal), // 经度，浮点数，范围为180 ~ -180。//121.55472159951
    name: name, // 位置名
    address: signaddress, // 地址详情说明
    scale: scale, // 地图缩放级别,整形值,范围从1~28。默认为最大
    infoUrl: '' // 在查看位置界面底部显示的超链接,可点击跳转
  });
}