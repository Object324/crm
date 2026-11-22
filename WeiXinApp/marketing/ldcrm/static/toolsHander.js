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

/*判断sessionstorage中的userid和corpurl是否为空，如果为空则从请求参数中获取并存储在sessionstorage中*/
if (sessionStorage.getItem('userid') == null || sessionStorage.getItem('corpurl') == null) {
	if (getQueryStringByName('userid') && getQueryStringByName('corpurl')) {
		sessionStorage.setItem('userid', getQueryStringByName('userid'));
		sessionStorage.setItem('corpurl', getQueryStringByName('corpurl'));
		sessionStorage.setItem('isshare', getQueryStringByName('isshare'));
		sessionStorage.setItem('appid', getQueryStringByName('appid'));
	}
	else {
		alert('无法获取服务器信息');
	}
}
else{
	if(sessionStorage.getItem('corpurl') == null || sessionStorage.getItem('corpurl') == '') {
        alert('无法获取服务器信息');
    }
}

var Tools={};

// 标题更改
Tools.setDocumentTitle = function(title) {
	document.title = title;
}

// 拨号
Tools.phoneCall = function (phone) {
    window.location.href = 'tel://' + phone;
}

Tools.getQueryStringByName = function (name) {
	var queryString = location.href;
	if (queryString) {
		var result = queryString.match(new RegExp("[\?\&]" + name+ "=([^\&]+)","i"));
		if(result == null || result.length < 1){
			return "";
		}
		return result[1];
	}
}

//随机数字字符串
Tools.randomString = function(e) {
  e = e || 6;
  var t = "0123456789",
  a = t.length,
  n = "";
  for (i = 0; i < e; i++) n += t.charAt(Math.floor(Math.random() * a));
  return n;
}