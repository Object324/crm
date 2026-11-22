var Tools={};
Tools.letters=new Array('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','w','x','y','z'
,'A','B','C','D','E','F','G','H','I','G','K','L','M','N','O','P','Q','R','S', 'T','U','V','W','X','Y','Z');
Tools.Number={
    //保留两位小数
    //制保留2位小数，如：2，会在2后面补上00.即2.00
    toDecimal : function(x,y) {
        var f = parseFloat(x);
        if (isNaN(f)) {
            return false;
        }
        y=parseInt(y);
        if (isNaN(parseInt(y))) {
            y = 2;
        }
        var digitStr = '1';
        for(var i=0;i<y;i++){
            digitStr += '0';
        }
        digitStr = parseInt(digitStr);
        var f = Math.round(x*digitStr)/digitStr;
        var s = f.toString();
        var rs = s.indexOf('.');
        if (rs < 0) {
            rs = s.length;
            if(y>0){
                s += '.';
            }
        }
        if(y>0){
            var tmp=parseInt(rs) + parseInt(y);
            while (s.length <= tmp) {
                s += '0';
            }
        }
        return s;
    },
    //整数，四舍五入
    toInt : function(x) {
        return Math.round(x);
    }
};
// 打印数组
Tools.print_array=function(arr){
    for(var key in arr){
        if(typeof(arr[key])=='array'||typeof(arr[key])=='object'){//递归调用
            Tools.print_array(arr[key]);
        }else{
            alert(key + ' = ' + arr[key] + '<br>');
        }
    }
};
Tools.trim = function(str){
    var r = /\s+/g;
    str = str.replace(r,'');
    return str;
};
// 普通字符转换成转意符
Tools.html2Escape = function(sHtml){
    return sHtml.replace(/[<>&"]/g,function(c){return {'<':'&lt;','>':'&gt;','&':'&amp;','"':'&quot;'}[c];});
};
// 转意符换成普通字符
Tools.escape2Html = function(str){
    var arrEntities={'lt':'<','gt':'>','nbsp':' ','amp':'&','quot':'"'};
    return str.replace(/&(lt|gt|nbsp|amp|quot);/ig,function(all,t){return arrEntities[t];});
};
// 去掉html标签，保留文本
Tools.delHtmlTag = function(str){
    return str.replace(/<[^>]+>/g,"");//去掉所有的html标记
};
// 获取附件后缀名
Tools.getAttSuffixName =function(name){
    var img = 'other',
        ext = '',
        att_name = name,
        att_name_arr = new Array();
    att_name_arr = att_name.split(".");
    ext = att_name_arr[att_name_arr.length-1];
    ext = ext.toLowerCase();
    if(ext == 'txt'){
        img = 'txt';
    } else if(ext == 'doc' || ext == 'docx'){
        img = 'doc';
    } else if(ext == 'xls' || ext == 'xlsx' || ext == 'mpp'){
        img = 'excle';
    } else if(ext == 'html'){
        img = 'html';
    } else if(ext == 'pdf'){
        img = 'pdf';
    } else if(ext == 'mp3' || ext == 'mp4' || ext == 'avi' || ext == 'rm' || ext == 'rmvb' ||
              ext == 'mov' || ext == 'wmv' || ext == 'asf' || ext == 'asf' || ext == 'dat'){
        img = 'video';
    } else if(ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'bmp' ||
              ext == 'gif' || ext == 'tiff' ){
        img = 'img';
    }
    return img;
};
// 服务合同截止日期为当前日期+1年，并且减去1天
Tools.changeDatekk = function(str){
    str = new Date(str);
    str = +str - 1000*60*60*24;
    str = new Date(str);

    var changeDate_Year = str.getFullYear()+1; //年
    var changeDate_Month = str.getMonth()+1;   //月
    if(changeDate_Month < 10){
        changeDate_Month = '0'+changeDate_Month;
    }
    var changeDate_Date = str.getDate(); //日
    if(changeDate_Date < 10){
        changeDate_Date = '0'+changeDate_Date;
    }
    //格式化
    return changeDate_Year+"-"+changeDate_Month+"-"+changeDate_Date;
};
//获取当前年、月、日、时、分
Tools.CurentTime = {
    p : function(s) {
        return s < 10 ? '0' + s: s;
    },
    timeNow : function(type) {
        var myDate = new Date();
        //获取当前年
        var year=myDate.getFullYear();
        //获取当前月
        var month=myDate.getMonth()+1;
        //获取当前日
        var day=myDate.getDate();
        var hours=myDate.getHours();       //获取当前小时数(0-23)
        var minutes=myDate.getMinutes();     //获取当前分钟数(0-59)
        var seconds=myDate.getSeconds();

        if(type == 'date'){
            return year+'-'+Tools.CurentTime.p(month)+"-"+Tools.CurentTime.p(day);
        }
        if(type == 'dateempty'){
            return year+Tools.CurentTime.p(month)+Tools.CurentTime.p(day);
        }
        if(type == 'prevyear'){
            return year-1;
        }
        if(type == 'year'){
            return year;
        }
        if(type == 'nextyear'){
            return year+1;
        }
        if(type == 'month'){
            return month;
        }
        if(type == 'day'){
            return day;
        }
        if(type == 'hours'){
            return hours;
        }
        if(type == 'minutes'){
            return minutes;
        }
        if(type == 'seconds'){
            return seconds;
        }
        if(type == 'all'){
            // return year+'-'+Tools.CurentTime.p(month)+"-"+Tools.CurentTime.p(day)+" "+Tools.CurentTime.p(hours)+':'+Tools.CurentTime.p(minutes)+":"+Tools.CurentTime.p(s);
            return year+'-'+Tools.CurentTime.p(month)+"-"+Tools.CurentTime.p(day)+" "+Tools.CurentTime.p(hours)+':'+Tools.CurentTime.p(minutes);
        }
        if(type == 'useforid'){
            return year+Tools.CurentTime.p(month)+Tools.CurentTime.p(day)+Tools.CurentTime.p(hours)+Tools.CurentTime.p(minutes)+Tools.CurentTime.p(seconds);
        }
        if(type == 'chinayearmonth'){
            return year+'年'+Tools.CurentTime.p(month)+'月';
        }
    }
};
//获取两个日期之间的日期
Date.prototype.format=function (){
    var s='';
    s+=this.getFullYear()+'-';          // 获取年份。
    s+=(Tools.CurentTime.p(this.getMonth()+1))+"-";         // 获取月份。
    s+= Tools.CurentTime.p(this.getDate());                 // 获取日。
    return(s);                          // 返回日期。
};
Tools.GetAllDate = function(begin, end) {
    var options = new Array();
    var ab = begin.split("-");
    var ae = end.split("-");
    var db = new Date();
    db.setUTCFullYear(ab[0], ab[1]-1, ab[2]);
    var de = new Date();
    de.setUTCFullYear(ae[0], ae[1]-1, ae[2]);
    var unixDb=db.getTime();
    var unixDe=de.getTime();
    for(var k=unixDb;k<=unixDe;){
        var date = (new Date(parseInt(k))).format();
        var arr = new Array();
        arr['value'] = date;
        options.push(arr);
        k=k+24*60*60*1000;
    }
    return options;
};
var dynamicJsScript = {};
//同步加载js文件，然后执行方法
Tools.getScriptBack = function(JsFile,callback){
  if(dynamicJsScript != undefined && 1 == dynamicJsScript[JsFile]){
     if(callback!=undefined)
        callback();//不加载第二次
  }else{//同步加载
      $.ajax({
          url: JsFile,
          dataType: 'script',
          async: false,
          success: function(rest){
              eval(rest);
              dynamicJsScript[JsFile] = 1;
              if(callback!=undefined)
                  callback();
          }
      });
  }
}
//去掉重复值
Tools.getRepeat = function(str) {
    var strArr = str.split(",");
    // 遍历数组，把元素分别放入tmp数组(不存在才放)
    var tmp = new Array();
    for(var i in strArr){
      //该元素在tmp内部不存在才允许追加
      if(tmp.indexOf(strArr[i])==-1){
        tmp.push(strArr[i]);
      }
    }
    strArr = tmp;
    str = strArr.join(",");
    return str;
}
//点击定位地址，打开地图
Tools.browserMap = function(latitude, longitude, address) {
    var scale = 14;
    if ($.device['os'] == "android") {
      scale = 16;
    }
    wx.openLocation({
      latitude: parseFloat(latitude), // 纬度，浮点数，范围为90 ~ -90//31.2537255481
      longitude: parseFloat(longitude), // 经度，浮点数，范围为180 ~ -180。//121.55472159951
      name: '签到地址', // 位置名
      address: address, // 地址详情说明
      scale: scale, // 地图缩放级别,整形值,范围从1~28。默认为最大
      infoUrl: '' // 在查看位置界面底部显示的超链接,可点击跳转
    });
}
//去掉最后一个逗号
Tools.getRemoveLastDouhao = function(str) {
    if(str.slice(0,1) == ','){
      str = str.slice(1,str.length);
    }
    return str;
}
//追加字符串
Tools.getAppendString = function(a, b) {
    if(a!=''){
      a += ','+b;
    }
    else{
      a = b;
    }
    return a;
}

//获取上一个月
Tools.getPreMonth = function(date, count) {
  var arr = date.split('-');
  var year = arr[0]; //获取当前日期的年份
  var month = arr[1]; //获取当前日期的月份
  var day = arr[2]; //获取当前日期的日
  var days = new Date(year, month, 0);
  days = days.getDate(); //获取当前日期中月的天数
  var year2 = year;
  var month2 = parseInt(month) - parseInt(count);
  if (month2 == 0) {
    year2 = parseInt(year2) - 1;
    month2 = 12;
  }
  var day2 = day;
  var days2 = new Date(year2, month2, 0);
  days2 = days2.getDate();
  if (day2 > days2) {
    day2 = days2;
  }
  if (month2 < 10) {
    month2 = '0' + month2;
  }
  var t2 = year2 + '-' + month2 + '-' + day2;
  return t2;
}

// 获取下一个月
Tools.getNextMonth = function(date, count) {
  var arr = date.split('-');
  var year = arr[0]; //获取当前日期的年份
  var month = arr[1]; //获取当前日期的月份
  var day = arr[2]; //获取当前日期的日
  var days = new Date(year, month, 0);
  days = days.getDate(); //获取当前日期中的月的天数
  var year2 = year;
  var month2 = parseInt(month) + parseInt(count);
  if (month2 == 13) {
    year2 = parseInt(year2) + 1;
    month2 = 1;
  }
  var day2 = day;
  var days2 = new Date(year2, month2, 0);
  days2 = days2.getDate();
  if (day2 > days2) {
    day2 = days2;
  }
  if (month2 < 10) {
    month2 = '0' + month2;
  }

  var t2 = year2 + '-' + month2 + '-' + day2;
  return t2;
}

//文件大小换算
Tools.bytesToSize = function(bytes) {
    if (bytes === 0) return '0 B';
    let k = 1024;
    let sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    let i = Math.floor(Math.log(bytes) / Math.log(k));
    let num = bytes / Math.pow(k, i);
    return num.toPrecision(3) + ' ' + sizes[i];
    //return (bytes / Math.pow(k, i)) + ' ' + sizes[i];
    //toPrecision(3) 后面保留一位小数，如1.0GB //return (bytes / Math.pow(k, i)).toPrecision(3) + ' ' + sizes[i];
}

// 浏览器追加参数
Tools.updateQueryStringParameter = function(uri, key, value) {
  if(!value) { return uri }
  var re = new RegExp("([?&])" + key + "=.*?(&|$)", "i");
  var separator = uri.indexOf('?') !== -1 ? "&" : "?";
  if (uri.match(re)) {
    return uri.replace(re, '$1' + key + "=" + value + '$2');
  }
  else {
    return uri + separator + key + "=" + value;
  }
}

//随机字符串
Tools.randomString = function(e) {
  e = e || 32;
  var t = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
  a = t.length,
  n = "";
  for (i = 0; i < e; i++) n += t.charAt(Math.floor(Math.random() * a));
  return n;
}

// 新增、编辑、详情界面图片、附件字段显示
Tools.getImgUrl=function (item){
  let ext = '';
  if(item.newfile_name){
    ext = Tools.getAttSuffixName(item.newfile_name);
  }
  else{
    ext = Tools.getAttSuffixName(item.filename);
  }
  let imgStr = sessionStorage.getItem('corpurl') + "app/images/"+ext+".png";
  if(ext == 'img'){
    if(item.storage_location == 'cos'){
      if(item.cloud_path){
        if(item.cloud_path.indexOf('http') >= 0){
          imgStr = item.cloud_path;
        }
        else{
          imgStr = 'http://'+item.cloud_path;
        }
      }else {
        imgStr = item.httppath;
      }
    }
    else{
      if(item.httppath && item.httppath != ''){
        imgStr = sessionStorage.getItem('corpurl') + item.httppath;
      }else if(item.filepath){
        imgStr = sessionStorage.getItem('corpurl') + item.filepath + item.newfile_name;
      }else{
        imgStr = sessionStorage.getItem('corpurl') + item.path + item.newfile_name;
      }
    }
  }
  return imgStr;
}

// 图片字段显示
Tools.getModuleImg=function (data){
  if(data.active_icon_cdn){
    return data.active_icon_cdn;
  }
  else if(data.active_icon){
    return sessionStorage.getItem("corpurl") + data.active_icon;
  }
  else if(data.report_icon){
    return img_url + data.report_icon;
  }
  else{
    let isSimpletype = sessionStorage.getItem('isSimpletype');
    let url = img_url + ((isSimpletype == 'yes') ? "crm2022_2/" : "crm2022/");
    if (data.module.indexOf('CustomForm') > -1) {
      return url + "crm_CustomForm.png";
    }
    else if (data.tab_tablename == 'ld_linkmodulecustom') {
      return url + "crm_Links.png";
    }
    else {
      return url + "crm_" + data.module + ".png";
    }
  }
}
Tools.getModuleImg2=function (data){
  if(data.indexOf('cos') > -1){
    return data;
  }
  else{
    return sessionStorage.getItem("corpurl") + data;
  }
}

// 增加参数
Tools.addUrlParams=function (){
  let newUrl = '';
  let mobileSource = sessionStorage.getItem('mobileSource');
  if(mobileSource == 'dingding'){
    if(sessionStorage.getItem("corpid")!='' && sessionStorage.getItem("corpid")!=null && sessionStorage.getItem("corpid") !='undefined'){
      newUrl += '&corpid='+sessionStorage.getItem("corpid");
    }
    if(sessionStorage.getItem("corpurl")!='' && sessionStorage.getItem("corpurl")!=null && sessionStorage.getItem("corpurl") !='undefined'){
      newUrl += '&corpurl='+sessionStorage.getItem("corpurl");
    }
  }
  else if(mobileSource == 'yunzhijia'){
    if(sessionStorage.getItem("userid")!='' && sessionStorage.getItem("userid")!=null && sessionStorage.getItem("userid") !='undefined'){
      newUrl += '&userid='+sessionStorage.getItem("userid");
    }
    if(sessionStorage.getItem("corpid")!='' && sessionStorage.getItem("corpid")!=null && sessionStorage.getItem("corpid") !='undefined'){
      newUrl += '&corpid='+sessionStorage.getItem("corpid");
    }
    if(sessionStorage.getItem("corpurl")!='' && sessionStorage.getItem("corpurl")!=null && sessionStorage.getItem("corpurl") !='undefined'){
      newUrl += '&corpurl='+sessionStorage.getItem("corpurl");
    }
  }
  else if(mobileSource == 'fanwei'){
    if(sessionStorage.getItem("userid")!='' && sessionStorage.getItem("userid")!=null && sessionStorage.getItem("userid") !='undefined'){
      newUrl += '&userid='+sessionStorage.getItem("userid");
    }
    if(sessionStorage.getItem("gonghao")!='' && sessionStorage.getItem("gonghao")!=null && sessionStorage.getItem("gonghao") !='undefined'){
      newUrl += '&gonghao='+sessionStorage.getItem("gonghao");
    }
    if(sessionStorage.getItem("corpurl")!='' && sessionStorage.getItem("corpurl")!=null && sessionStorage.getItem("corpurl") !='undefined'){
      newUrl += '&corpurl='+sessionStorage.getItem("corpurl");
    }
  }
  else if(mobileSource == 'zhiyuan'){
    if(sessionStorage.getItem("userid")!='' && sessionStorage.getItem("userid")!=null && sessionStorage.getItem("userid") !='undefined'){
      newUrl += '&userid='+sessionStorage.getItem("userid");
    }
    if(sessionStorage.getItem("zhiyuan_ticket")!='' && sessionStorage.getItem("zhiyuan_ticket")!=null && sessionStorage.getItem("zhiyuan_ticket") !='undefined'){
      newUrl += '&zhiyuan_ticket='+sessionStorage.getItem("zhiyuan_ticket");
    }
    if(sessionStorage.getItem("corpurl")!='' && sessionStorage.getItem("corpurl")!=null && sessionStorage.getItem("corpurl") !='undefined'){
      newUrl += '&corpurl='+sessionStorage.getItem("corpurl");
    }
  }
  else if(mobileSource == 'app'){
    if(sessionStorage.getItem("userid")!='' && sessionStorage.getItem("userid")!=null && sessionStorage.getItem("userid") !='undefined'){
      newUrl += '&userid='+sessionStorage.getItem("userid");
    }
    if(sessionStorage.getItem("corpurl")!='' && sessionStorage.getItem("corpurl")!=null && sessionStorage.getItem("corpurl") !='undefined'){
      newUrl += '&corpurl='+sessionStorage.getItem("corpurl");
    }
    if(sessionStorage.getItem("appusertoken")!='' && sessionStorage.getItem("appusertoken")!=null && sessionStorage.getItem("appusertoken") !='undefined'){
      newUrl += '&appusertoken='+sessionStorage.getItem("appusertoken");
    }
    if(sessionStorage.getItem("corpindex")!='' && sessionStorage.getItem("corpindex")!=null && sessionStorage.getItem("corpindex") !='undefined'){
      newUrl += '&corpindex='+sessionStorage.getItem("corpindex");
    }
    if(sessionStorage.getItem("corpid")!='' && sessionStorage.getItem("corpid")!=null && sessionStorage.getItem("corpid") !='undefined'){
      newUrl += '&corpid='+sessionStorage.getItem("corpid");
    }
    if(sessionStorage.getItem("deviceid")!='' && sessionStorage.getItem("deviceid")!=null && sessionStorage.getItem("deviceid") !='undefined'){
      newUrl += '&deviceid='+sessionStorage.getItem("deviceid");
    }
    if(sessionStorage.getItem("expired_time")!='' && sessionStorage.getItem("expired_time")!=null && sessionStorage.getItem("expired_time") !='undefined'){
      newUrl += '&expired_time='+sessionStorage.getItem("expired_time");
    }
    if(sessionStorage.getItem("expired_type")!='' && sessionStorage.getItem("expired_type")!=null && sessionStorage.getItem("expired_type") !='undefined'){
      newUrl += '&expired_type='+sessionStorage.getItem("expired_type");
    }
  }
  else{
    if(sessionStorage.getItem("userid")!='' && sessionStorage.getItem("userid")!=null && sessionStorage.getItem("userid") !='undefined'){
      newUrl += '&userid='+sessionStorage.getItem("userid");
    }
    if(sessionStorage.getItem("corpurl")!='' && sessionStorage.getItem("corpurl")!=null && sessionStorage.getItem("corpurl") !='undefined'){
      newUrl += '&corpurl='+sessionStorage.getItem("corpurl");
    }
    if(sessionStorage.getItem("deviceid")!='' && sessionStorage.getItem("deviceid")!=null && sessionStorage.getItem("deviceid") !='undefined'){
      newUrl += '&deviceid='+sessionStorage.getItem("deviceid");
    }
    if(sessionStorage.getItem("corpindex")!='' && sessionStorage.getItem("corpindex")!=null && sessionStorage.getItem("corpindex") !='undefined'){
      newUrl += '&corpindex='+sessionStorage.getItem("corpindex");
    }
    if(sessionStorage.getItem("corpid")!='' && sessionStorage.getItem("corpid")!=null && sessionStorage.getItem("corpid") !='undefined'){
      newUrl += '&corpid='+sessionStorage.getItem("corpid");
    }
    if(sessionStorage.getItem("agentid")!='' && sessionStorage.getItem("agentid")!=null && sessionStorage.getItem("agentid") !='undefined'){
      newUrl += '&agentid='+sessionStorage.getItem("agentid");
    }
    if(sessionStorage.getItem("tamptimes")!='' && sessionStorage.getItem("tamptimes")!=null && sessionStorage.getItem("tamptimes") !='undefined'){
      newUrl += '&tamptimes='+sessionStorage.getItem("tamptimes");
    }
    if(sessionStorage.getItem("noncestr")!='' && sessionStorage.getItem("noncestr")!=null && sessionStorage.getItem("noncestr") !='undefined'){
      newUrl += '&noncestr='+sessionStorage.getItem("noncestr");
    }
    if(sessionStorage.getItem("signature")!='' && sessionStorage.getItem("signature")!=null && sessionStorage.getItem("signature") !='undefined'){
      newUrl += '&signature='+sessionStorage.getItem("signature");
    }
    if(sessionStorage.getItem("agent_signature")!='' && sessionStorage.getItem("agent_signature")!=null && sessionStorage.getItem("agent_signature") !='undefined'){
      newUrl += '&agent_signature='+sessionStorage.getItem("agent_signature");
    }
    if(sessionStorage.getItem("expired_type")!='' && sessionStorage.getItem("expired_type")!=null && sessionStorage.getItem("expired_type") !='undefined'){
      newUrl += '&expired_type='+sessionStorage.getItem("expired_type");
    } 
  }
  return newUrl;
}