//获取设备信息
lingdang.getDeviceid=function (){
  var qingString = navigator.userAgent;
  // var qingString = 'Android 9;Xiaomi;deviceId:OAID;deviceName:Xiaomi MIX;';
  var deviceId = '';
  if(qingString){
    let arr1 = qingString.split('deviceId:');
    if(arr1){
      if(arr1[1]){
        let arr2 = arr1[1].split(';');
        deviceId = arr2[0];
      }
      else{
        deviceId = '';
      }
    }
    else{
      deviceId = '';
    }
  }
  else{
    deviceId = '';
  }
  sessionStorage.setItem('deviceid', deviceId);
}

//打开地图
lingdang.mapViewYunzhijia=function (latitudeVal, longtitudeVal, signaddress, name, scale){
  qing.call('selectLocation', {
    'latitude': latitudeVal,
    'longitude': longtitudeVal,
    'isLocation': false,
    'isFullMap': true,
    'success': function(result){}
  });
}

//打开图片
lingdang.previewImageYunzhijia=function (imgArr, open_url){
  qing.call('previewImage', {
    'current': open_url,
    'urls': imgArr,
    'success': function (result) {}
  });
}