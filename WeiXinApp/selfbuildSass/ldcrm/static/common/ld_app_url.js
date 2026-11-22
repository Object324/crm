function getQueryStringByName(name){
  var queryString = location.href;
  if (queryString) {
    var result = queryString.match(new RegExp("[\?\&]" + name+ "=([^\&]+)","i"));
    if(result == null || result.length < 1){
      return "";
    }
    return result[1];
  }
}

if (sessionStorage.getItem('userid') == null || sessionStorage.getItem('corpurl') == null  ) {
  if (getQueryStringByName('userid') && getQueryStringByName('corpurl')) {
    sessionStorage.setItem('mobileSource', 'app');
    sessionStorage.setItem('userid', getQueryStringByName('userid'));
    sessionStorage.setItem('appusertoken', getQueryStringByName('appusertoken'));
    sessionStorage.setItem('corpindex', getQueryStringByName('corpindex'));
    sessionStorage.setItem('corpid', getQueryStringByName('corpid'));
    sessionStorage.setItem('corpurl', getQueryStringByName('corpurl'));
    sessionStorage.setItem('deviceid', getQueryStringByName('deviceid'));

    sessionStorage.setItem('expired_time', getQueryStringByName('expired_time'));
    sessionStorage.setItem('expired_type', getQueryStringByName('expired_type'));
  }
  else {
    alert('无法获取服务器信息-APP');
  }
}
else{
  if(sessionStorage.getItem('corpurl') == null || sessionStorage.getItem('corpurl') == '') {
    alert('无法获取sso服务器信息-APP');
  }
}