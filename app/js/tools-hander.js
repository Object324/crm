var Tools={};
Tools.Number={
    //保留两位小数  
    //制保留2位小数，如：2，会在2后面补上00.即2.00 
    toDecimal : function(x,y) { 
        if(x == '' || x == null || x == undefined){x=0;}
        var f = parseFloat(x); 
        if (isNaN(f)) { 
            return false; 
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
            while (s.length <= rs + y) { 
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
Tools.formAtChartData = function(parma,ticket,callback){
    var temp = typeof parma === 'number' ? parma : parma.data;
    if(temp>10000) {
        return Math.ceil(temp/10000)+'w'; 
    }else {
        return temp;
    }
};
Tools.formAtChartDataVertical = function(parma,ticket,callback){
    var temp = typeof parma === 'number' ? parma : parma.data;
    var tempvalue = '';
    if(temp>10000) {
        temp = Math.ceil(temp/10000)+'w'; 
        temp = temp.toString();
        tempvalue = temp.split("").join("\n");
    }else {
        if(temp>1000){
            temp = temp.toString();
            tempvalue = temp.split("").join("\n");
        }
        else{
            tempvalue = temp;
        }
    }
    return tempvalue;
};
//普通字符转换成转意符
Tools.html2Escape = function(sHtml){
    return sHtml.replace(/[<>&"]/g,function(c){return {'<':'&lt;','>':'&gt;','&':'&amp;','"':'&quot;'}[c];});
};
//转意符换成普通字符
Tools.escape2Html = function(str){
    var arrEntities={'lt':'<','gt':'>','nbsp':' ','amp':'&','quot':'"'};
    return str.replace(/&(lt|gt|nbsp|amp|quot);/ig,function(all,t){return arrEntities[t];});
};
//去掉html标签，保留文本
Tools.delHtmlTag = function(str){
    return str.replace(/<[^>]+>/g,"");//去掉所有的html标记
};
//获取当前设备时间
Tools.CurentTime={
    //获取当前日期时间，中文
    timeZh : function() { 
        var datetime = new Date(),
            year = datetime.getFullYear(),
            month = datetime.getMonth()+1,
            day = datetime.getDate(),
            hour = datetime.getHours(),
            minute = datetime.getMinutes();
        datetime = '';
        datetime = year+'年';
        datetime += (month>9)?month:'0'+month;
        datetime +='月';
        datetime += (day>9)?day:'0'+day;
        datetime +='日 ';
        datetime += (hour>9)?hour:'0'+hour;
        datetime +=':';
        datetime += (minute>9)?minute:'0'+minute;
        return datetime;
    },
    //获取当前日期，中文
    dateZh : function() { 
        var datetime = new Date(),
            year = datetime.getFullYear(),
            month = datetime.getMonth()+1,
            day = datetime.getDate();
        datetime = '';
        datetime = year+'年';
        datetime += (month>9)?month:'0'+month;
        datetime +='月';
        datetime += (day>9)?day:'0'+day;
        datetime +='日';
        return datetime;
    },
    //获取当前日期时间，英文
    timeEn : function() { 
        var datetime = new Date(),
            year = datetime.getFullYear(),
            month = datetime.getMonth()+1,
            day = datetime.getDate(),
            hour = datetime.getHours(),
            minute = datetime.getMinutes();
        datetime = '';
        datetime = year+'-';
        datetime += (month>9)?month:'0'+month;
        datetime +='-';
        datetime += (day>9)?day:'0'+day;
        datetime +=' ';
        datetime += (hour>9)?hour:'0'+hour;
        datetime +=':';
        datetime += (minute>9)?minute:'0'+minute;
        return datetime;
    },
    //获取当前日期，英文
    dateEn : function() { 
        var datetime = new Date(),
            year = datetime.getFullYear(),
            month = datetime.getMonth()+1,
            day = datetime.getDate();
        datetime = '';
        datetime = year+'-';
        datetime += (month>9)?month:'0'+month;
        datetime +='-';
        datetime += (day>9)?day:'0'+day;
        return datetime;
    }
};
//获取服务器当前时间
Tools.ServerCurentTime={
    //获取当前日期
    getDateTime : function() { 
        var datetime = '',
            urlstring = 'module=Home&action=ListView&method=getCurentTime';
        WordReportAjaxNew(urlstring,function(rest){
            if(empty(rest)) return false;
            var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
            datetime = restobj.result.date;            
        },{async:false});
        return datetime;
    },
    //获取当前日期时间，中文
    timeZh : function() { 
        var getdatetime = Tools.ServerCurentTime.getDateTime();
        getdatetime = getdatetime.replace(/-/g,"/");
        var datetime = new Date(getdatetime),
            year = datetime.getFullYear(),
            month = datetime.getMonth()+1,
            day = datetime.getDate(),
            hour = datetime.getHours(),
            minute = datetime.getMinutes();
        datetime = '';
        datetime = year+'年';
        datetime += (month>9)?month:'0'+month;
        datetime +='月';
        datetime += (day>9)?day:'0'+day;
        datetime +='日 ';
        datetime += (hour>9)?hour:'0'+hour;
        datetime +=':';
        datetime += (minute>9)?minute:'0'+minute;
        return datetime;
    },
    //获取当前日期，中文
    dateZh : function() { 
        var getdatetime = Tools.ServerCurentTime.getDateTime();
        getdatetime = getdatetime.replace(/-/g,"/");
        var datetime = new Date(getdatetime),
            year = datetime.getFullYear(),
            month = datetime.getMonth()+1,
            day = datetime.getDate();
        datetime = '';
        datetime = year+'年';
        datetime += (month>9)?month:'0'+month;
        datetime +='月';
        datetime += (day>9)?day:'0'+day;
        datetime +='日';
        return datetime;
    },
    //获取当前日期时间，英文
    timesEn : function() { 
        var getdatetime = Tools.ServerCurentTime.getDateTime();
        getdatetime = getdatetime.replace(/-/g,"/");
        var datetime = new Date(getdatetime),
            year = datetime.getFullYear(),
            month = datetime.getMonth()+1,
            day = datetime.getDate(),
            hour = datetime.getHours(),
            minute = datetime.getMinutes();
            second = datetime.getSeconds();
        datetime = '';
        datetime = year+'-';
        datetime += (month>9)?month:'0'+month;
        datetime +='-';
        datetime += (day>9)?day:'0'+day;
        datetime +=' ';
        datetime += (hour>9)?hour:'0'+hour;
        datetime +=':';
        datetime += (minute>9)?minute:'0'+minute;
        datetime +=':';
        datetime += (second>9)?second:'0'+second;
        return datetime;
    },
    //获取当前日期时间，英文
    timeEn : function() { 
        var getdatetime = Tools.ServerCurentTime.getDateTime();
        getdatetime = getdatetime.replace(/-/g,"/");
        var datetime = new Date(getdatetime),
            year = datetime.getFullYear(),
            month = datetime.getMonth()+1,
            day = datetime.getDate(),
            hour = datetime.getHours(),
            minute = datetime.getMinutes();
        datetime = '';
        datetime = year+'-';
        datetime += (month>9)?month:'0'+month;
        datetime +='-';
        datetime += (day>9)?day:'0'+day;
        datetime +=' ';
        datetime += (hour>9)?hour:'0'+hour;
        datetime +=':';
        datetime += (minute>9)?minute:'0'+minute;
        return datetime;
    },
    //获取当前日期，英文
    dateEn : function() { 
        var getdatetime = Tools.ServerCurentTime.getDateTime();
        getdatetime = getdatetime.replace(/-/g,"/");
        var datetime = new Date(getdatetime),
            year = datetime.getFullYear(),
            month = datetime.getMonth()+1,
            day = datetime.getDate();
        datetime = '';
        datetime = year+'-';
        datetime += (month>9)?month:'0'+month;
        datetime +='-';
        datetime += (day>9)?day:'0'+day;
        return datetime;
    }
};
//仿php sprintf 方法
Tools.sprintf = function(){ 
    var arg = arguments,
    str = arg[0] || '',i, n;
    for (i = 1, n = arg.length; i < n; i++){
        str = str.replace(/%s/, arg[i]);
    }
    return str; 
};
//替换字符串
function strtr(str,node,to){
    var regS = new RegExp(""+node+"","g");
    return str.replace(regS,to);
}
//判断非空
function empty(v){
    switch (typeof v){
        case 'undefined' : return true;
        case 'string' : if(trim(v).length == 0) return true; break; 
        case 'boolean' : if(!v) return true; break; 
        case 'number' : if(0 === v) return true; break; 
        case 'object' : 
        if(null === v) return true; 
        if(undefined !== v.length && v.length==0) return true; 
        for(var k in v){return false;} return true; 
        break; 
    }
    return false; 
}
function trim(str){
    var r = /\s+/g;
    str = str.replace(r,'');    
    return str;
}
//打印数组
Tools.print_array=function(arr){  
    for(var key in arr){  
        if(typeof(arr[key])=='array'||typeof(arr[key])=='object'){//递归调用    
            Tools.print_array(arr[key]);  
        }else{  
            alert(key + ' = ' + arr[key] + '<br>');  
        }  
    }  
};
//根据经纬度计算两点距离
var EARTH_RADIUS = 6378137.0;    //单位M
var PI = Math.PI;
Tools.getRad=function(d){
    return d*PI/180.0;
}
Tools.getFlatternDistance=function(lat1,lng1,lat2,lng2){
    var f = Tools.getRad((lat1 + lat2)/2);
    var g = Tools.getRad((lat1 - lat2)/2);
    var l = Tools.getRad((lng1 - lng2)/2);

    var sg = Math.sin(g);
    var sl = Math.sin(l);
    var sf = Math.sin(f);

    var s,c,w,r,d,h1,h2;
    var a = EARTH_RADIUS;
    var fl = 1/298.257;

    sg = sg*sg;
    sl = sl*sl;
    sf = sf*sf;

    s = sg*(1-sl) + (1-sf)*sl;
    c = (1-sg)*(1-sl) + sf*sl;

    w = Math.atan(Math.sqrt(s/c));
    r = Math.sqrt(s*c)/w;
    d = 2*w*a;
    h1 = (3*r -1)/2/c;
    h2 = (3*r +1)/2/s;
    return d*(1 + fl*(h1*sf*(1-sg) - h2*(1-sf)*sg));
};
Tools.getGreatCircleDistance=function(lat1,lng1,lat2,lng2){
    var radLat1 = Tools.getRad(lat1);
    var radLat2 = Tools.getRad(lat2);

    var a = radLat1 - radLat2;
    var b = Tools.getRad(lng1) - Tools.getRad(lng2);

    var s = 2*Math.asin(Math.sqrt(Math.pow(Math.sin(a/2),2) + Math.cos(radLat1)*Math.cos(radLat2)*Math.pow(Math.sin(b/2),2)));
    s = s*EARTH_RADIUS;
    s = Math.round(s*10000)/10000.0;
            
    return s;
}
//获取后缀名
Tools.getAttImg =function(name){  
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
    } else if(ext == 'mp3' || ext == 'mp4' || ext == 'avi' || ext == 'rm' || ext == 'rmvb' || 
              ext == 'mov' || ext == 'wmv' || ext == 'asf' || ext == 'asf' || ext == 'dat'){
        img = 'video';
    } else if(ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'bmp' || 
              ext == 'gif' || ext == 'tiff' ){
        img = 'img';
    }
    return img;
};