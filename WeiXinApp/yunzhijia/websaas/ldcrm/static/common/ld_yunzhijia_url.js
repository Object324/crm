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

if (sessionStorage.getItem('corpid') == null || sessionStorage.getItem('corpurl') == null) {
  if (getQueryStringByName('corpid') && getQueryStringByName('corpurl')) {
    sessionStorage.setItem('mobileSource', 'yunzhijia');
    sessionStorage.setItem('userid', getQueryStringByName('userid'));
    sessionStorage.setItem('corpid', getQueryStringByName('corpid'));
    var corpurl = getQueryStringByName('corpurl');
    var corpurl_last = corpurl.substr(corpurl.length-1,1)
    if(corpurl_last != '/'){
      corpurl = corpurl + '/';
    }
    sessionStorage.setItem('corpurl', corpurl);
  }
  else {
    alert('无法获取服务器信息-云之家');
  }
}
else{
  if(sessionStorage.getItem('corpurl') == null || sessionStorage.getItem('corpurl') == '') {
    alert('无法获取sso服务器信息-云之家');
  }
}