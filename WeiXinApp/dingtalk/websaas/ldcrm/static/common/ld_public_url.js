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

if ((getQueryStringByName('ssotype') && getQueryStringByName('ssotype') != '') || (sessionStorage.getItem('mobileSource') != '' && sessionStorage.getItem('mobileSource') != null)) {
  if (sessionStorage.getItem('userid') == null) {
    if(getQueryStringByName('ssotype') == 'dingding'){//钉钉
      if (getQueryStringByName('corpurl') && getQueryStringByName('ssotype')) {
        sessionStorage.setItem('mobileSource', 'dingding');
        sessionStorage.setItem('userid', getQueryStringByName('userid'));
        sessionStorage.setItem('corpid', getQueryStringByName('corpid'));
        sessionStorage.setItem('corpurl', getQueryStringByName('corpurl'));
      }
      else {
        alert('无法获取服务器信息-钉钉');
      }
    }
    if(getQueryStringByName('ssotype') == 'yunzhijia'){//云之家
      if (getQueryStringByName('corpurl') && getQueryStringByName('ssotype')) {
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
    if(getQueryStringByName('ssotype') == 'fanwei'){//泛微
      if (getQueryStringByName('gonghao') && getQueryStringByName('corpurl')) {
        sessionStorage.setItem('mobileSource', 'fanwei');
        sessionStorage.setItem('userid', getQueryStringByName('userid'));
        sessionStorage.setItem('gonghao', getQueryStringByName('gonghao'));
        sessionStorage.setItem('corpurl', getQueryStringByName('corpurl'));
      }
      else {
        alert('无法获取服务器信息-泛微');
      }
    }
    if(getQueryStringByName('ssotype') == 'zhiyuan'){//致远
      if (getQueryStringByName('corpurl') && getQueryStringByName('ssotype')) {
        sessionStorage.setItem('mobileSource', 'zhiyuan');
        sessionStorage.setItem('userid', getQueryStringByName('userid'));
        sessionStorage.setItem('zhiyuan_ticket', getQueryStringByName('ticket'));
        sessionStorage.setItem('corpurl', getQueryStringByName('corpurl'));
      }
      else {
        alert('无法获取服务器信息-致远');
      }
    }
    if(getQueryStringByName('ssotype') == 'app'){//APP
      if (getQueryStringByName('corpurl') && getQueryStringByName('ssotype')) {
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
  }
  else{
    if(sessionStorage.getItem('corpurl') == null || sessionStorage.getItem('corpurl') == '') {
      alert('无法获取sso服务器信息');
    }
  }
}
else{
  if (sessionStorage.getItem('userid') == null || sessionStorage.getItem('corpurl') == null || sessionStorage.getItem('corpid') == null || sessionStorage.getItem('tamptimes') == null || sessionStorage.getItem('noncestr') == null || sessionStorage.getItem('signature') == null ) {
    if (getQueryStringByName('corpurl') && getQueryStringByName('corpid') && getQueryStringByName('tamptimes') && getQueryStringByName('noncestr') && getQueryStringByName('signature')) {
      sessionStorage.setItem('mobileSource', 'qiyeweixin');
      //自建应用
      sessionStorage.setItem('agentid', getQueryStringByName('agentid'));
      sessionStorage.setItem('userid', getQueryStringByName('userid'));
      sessionStorage.setItem('corpurl', getQueryStringByName('corpurl'));
      sessionStorage.setItem('corpindex', getQueryStringByName('corpindex'));
      sessionStorage.setItem('corpid', getQueryStringByName('corpid'));
      sessionStorage.setItem('tamptimes', getQueryStringByName('tamptimes'));
      sessionStorage.setItem('noncestr', getQueryStringByName('noncestr'));
      sessionStorage.setItem('signature', getQueryStringByName('signature'));
      sessionStorage.setItem('agent_signature', getQueryStringByName('agent_signature'));
      sessionStorage.setItem('deviceid', getQueryStringByName('deviceid'));

      sessionStorage.setItem('expired_time', getQueryStringByName('expired_time'));
      sessionStorage.setItem('expired_type', getQueryStringByName('expired_type'));

      // 企业微信侧边栏
      sessionStorage.setItem('WXPCCreationInfo', getQueryStringByName('WXPCCreationInfo'));//跳转新增
      sessionStorage.setItem('WXPCListInfo', getQueryStringByName('WXPCListInfo'));//跳转列表
      sessionStorage.setItem('WXPCShow', getQueryStringByName('WXPCShow'));//跳转详情
      sessionStorage.setItem('WXPCShowHome', getQueryStringByName('WXPCShowHome'));//侧边栏进入
      sessionStorage.setItem('WXPCExternalUserid', getQueryStringByName('weixin_external_userid'));

      //消息提醒进入的crm
      var fromlogintype=getQueryStringByName('fromlogintype');
      if(fromlogintype=='undefined'||fromlogintype==undefined){
        fromlogintype='';
      }
      if(fromlogintype.includes('remindsmsg')){
        fromlogintype = 'remindsmsg';
      }
      sessionStorage.setItem('fromlogintype', fromlogintype);
      sessionStorage.setItem('remindscode', getQueryStringByName('remindscode'));
    }
    else {
      alert('无法获取企微服务器信息');
    }
  }
  else{
    if(sessionStorage.getItem('corpurl') == null || sessionStorage.getItem('corpurl') == '') {
      alert('无法获取企微服务器信息');
    }
  }
}