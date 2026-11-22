// 钉钉JSAPI鉴权
lingdang.dingtalk_config=function (){
  let _config = JSON.parse(sessionStorage.getItem('_config'));
  if(_config){
    dd.config({
      agentId: _config.agentId,
      corpId: _config.corpId,
      timeStamp: _config.timeStamp,
      nonceStr: _config.nonceStr,
      signature: _config.signature,
      jsApiList: [
        'biz.cspace.chooseSpaceDir',//选取钉盘目录，必须
        'biz.cspace.saveFile',//保存钉盘文件，必须
        'biz.cspace.preview',//预览钉盘文件，必须
        'biz.util.uploadAttachment',//上传附件到钉盘文件/从钉盘选择文件，必须
        'device.geolocation.get',//获取当前地理位置信息(单次定位)，必须
        'biz.map.view',//展示位置，必须
        'biz.clipboardData.setData',
        'device.base.getUUID'//获取UUID，必须
      ]
    });
  }
  else{
    lingdang.dingtalk_get_config();
  }
}

// 获取钉钉JSAPI鉴权
lingdang.dingtalk_get_config=function (){
  // 获取鉴权信息
  var corpurl =  sessionStorage.getItem('corpurl');
  var url = corpurl + 'WeiXinApp/dingtalk/event.php';
  var params = {
    action: 'isvConfig',
    corpurl: encodeURIComponent(corpurl),
    // corpurl_new: 'selfbuildSass',
    diony: Tools.randomString(8)
  };
  $.ajaxSettings.async = false;
  lingdangAjax(url, params, function(data){
    $.ajaxSettings.async = true;
    if(data.code == 1){
      var _config = Object();
      _config.agentId = data.result.agentId;
      _config.corpId = data.result.corpId;
      _config.timeStamp = data.result.timeStamp;
      _config.nonceStr = data.result.nonceStr;
      _config.signature = data.result.signature;
      sessionStorage.setItem('_config',JSON.stringify(_config));

      //钉钉JSAPI鉴权
      lingdang.dingtalk_config();
      // 查看鉴权错误信息
      dd.error(function(err) {
        alert('dd error3: ' + JSON.stringify(err));
      });
    }
    else{
      alert(data.msg);//弹出框提示
      return;
    }
  });
}

// 设置标题
lingdang.setDocumentTitleDingding=function(title){
  if (dd.env.platform !== "notInDingTalk") {
    dd.ready(function () {
      dd.biz.navigation.setTitle({title : title});//设置导航栏标题
    });
  }
}

//关闭应用
lingdang.closeWindowsDingding=function (){
  if (dd.env.platform !== "notInDingTalk") {
    dd.ready(function () {
      dd.biz.navigation.close();
    });
  }
}

//打开附件
lingdang.previewFileDingding=function (url, name, size){
  if (dd.env.platform !== "notInDingTalk") {
    dd.ready(function () {
      dd.biz.cspace.saveFile({
        corpId: sessionStorage.getItem('corpid'),// 文件在第三方服务器地址， 也可为通过服务端接口上传文件得到的media_id，详见参数说明
        url: url,
        name: name,
        onSuccess: function (data) {
          var file_data = data['data'][0];
          dd.biz.cspace.preview({
            corpId: sessionStorage.getItem('corpid'),
            spaceId: file_data['spaceId'],
            fileId: file_data['fileId'],
            fileName: file_data['fileName'],
            fileSize: file_data['fileSize'],
            fileType: file_data['fileType'],
            onSuccess: function () {
              //无，直接在native显示文件详细信息
            },
            onFail: function (err) {
              // 无，直接在native页面显示具体的错误
            }
          });
        },
        onFail: function (err) {
          // alert(JSON.stringify(err));
        }
      });
    });
  }
}

//打开图片
lingdang.previewImageDingding=function (imgArr, open_url){
  if (dd.env.platform !== "notInDingTalk") {
    dd.ready(function () {
      dd.biz.util.previewImage({
        urls: imgArr,//图片地址列表
        current: open_url,//当前显示的图片链接
        onSuccess: function (result) {},
        onFail: function (err) {}
      });
    });
  }
}

//打开地图
lingdang.mapViewDingding=function (latitudeVal, longtitudeVal, signaddress, name, scale){
  if (dd.env.platform !== "notInDingTalk") {
    dd.ready(function () {
      dd.biz.map.view({
        latitude: latitudeVal, // 纬度
        longitude: longtitudeVal, // 经度
        title: signaddress // 地址/POI名称
      });
    });
  }
}

// 复制
lingdang.clipboardDataDingding=function(copycontent){
  if (dd.env.platform !== "notInDingTalk") {
    dd.ready(function () {
      dd.biz.clipboardData.setData({
        text: copycontent, //要复制粘贴板的内容   
        onSuccess : function(result) {
        },
        onFail : function() {
        }
      });
    });
  }
}