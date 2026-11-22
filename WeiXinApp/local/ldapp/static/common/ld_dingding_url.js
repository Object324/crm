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
    sessionStorage.setItem('mobileSource', 'dingding');
    sessionStorage.setItem('userid', getQueryStringByName('userid'));
    sessionStorage.setItem('corpid', getQueryStringByName('corpid'));
    sessionStorage.setItem('corpurl', getQueryStringByName('corpurl'));

    //消息提醒进入的crm
    var fromlogintype=getQueryStringByName('fromlogintype');
    if(fromlogintype=='undefined'||fromlogintype==undefined){
      fromlogintype='';
    }
    if(fromlogintype.includes('remindsmsg')){
      fromlogintype = 'remindsmsg';
    }
    sessionStorage.setItem('fromlogintype', fromlogintype);
  }
  else {
    alert('无法获取服务器信息-钉钉');
  }
}
else{
  if(sessionStorage.getItem('corpurl') == null || sessionStorage.getItem('corpurl') == '') {
    alert('无法获取sso服务器信息-钉钉');
  }
}