function cls_encryptyurl() {
    this.urlparamkey_value_arr = [];//url的paramkey-value的数组
    this.sorturlparamkey_arr = [];//url的paramkey的数组
    this.urlstring = '';//url字符串
    this.sorturlstring = '';//排序后的url字符串
    var that = this;
    this.Judgeparamkeys = [];
    this.origin_php = 'index.php';
    this.encrypturlkey = 'ldencryptyurl';
    this.encrypttimestampkey = 'ldtimestamp';
    this.encryptykey = 'ling####dang';
    this.urlparamkey_value_arr = {};//url的paramkey-value的数组
    this.getencryptykey = function (){
        var encryptykey = this.encryptykey;
        encryptykey = encryptykey.replace(/####/g,'');
        return encryptykey;
    }
    //对url字符串进行加密，并返回加密后字符串
    this.puyoung_sorturlencrypt =  function()
    {
        var urlstring = that.sorturlstring;
        //urlstring过滤
        //1、去除index。php
     
     
        var timestamp = new Date().getTime();
        var encrypturl = '';
        //使用timestamp作为key进行加密
        var encryptykey = this.getencryptykey();
        code = CryptoJS.MD5(encryptykey+timestamp).toString()
        var iv = CryptoJS.enc.Utf8.parse(code.substring(0, 16))
        var key = CryptoJS.enc.Utf8.parse(code.substring(16))
        encrypturl = CryptoJS.AES.encrypt(urlstring, key, {
            iv: iv,
            mode: CryptoJS.mode.CBC,
            padding: CryptoJS.pad.Pkcs7
        }).toString();
        //使用md5加密
        encrypturl = CryptoJS.MD5(encrypturl).toString();
        return this.encrypturlkey+'='+encodeURIComponent(encrypturl)+'&'+this.encrypttimestampkey+'='+timestamp;
    }
    //对url字符串进行加密，并返回加密后字符串
    this.puyoung_urlarrencrypt = function (urlarr)
    {
        var tmpurlstring = '';
        var sortparamkey_arr = that.sorturlkeyarr(urlarr);
        var keylength = sortparamkey_arr.length;

        for(i=0;i<keylength;i++){
            var tmpkey = sortparamkey_arr[i];
            //如果设置了判断的参数名，则只获取对应的参数名
            if(that.Judgeparamkeys != undefined && that.Judgeparamkeys.length>0&&that.Judgeparamkeys.indexOf(tmpkey)<0){
                continue;
            }
            var tmpitem = urlarr[tmpkey];
            if(typeof tmpitem == 'object'){
                tmpitem = that.convertValues(tmpitem);
            }
            else{
                //应只decode一次，不然 %20=》encode %2520 => decode %20=>decode ' '(空格)
                //tmpitem = that.safeDecodeURIComponent(tmpitem);
            }
            tmpurlstring +=tmpkey+'='+tmpitem;
        }
        if(tmpurlstring.length>0 && tmpurlstring[0] == '&'){
            tmpurlstring = tmpurlstring.substring(1);
        }
        that.sorturlstring = tmpurlstring;
        return that.puyoung_sorturlencrypt();
    }
    this.sorturlkeyarr=function(urlarr)
    {
        var sorturlparamkey_arr = Object.keys(urlarr).sort();
        return sorturlparamkey_arr;
    }
    //过滤url:去除this.origin_php
    this.urlstring_filterate = function(urlstring)
    {
        //1、去除index。php
        if(urlstring.indexOf(this.origin_php) >= 0){
            if(urlstring.indexOf(this.origin_php+'?') >= 0){
                var tmpindex = urlstring.indexOf(this.origin_php+'?');
                urlstring = urlstring.replace(urlstring.substring(0, tmpindex)+this.origin_php+'?','');
            }
            else if(urlstring.indexOf(this.origin_php) >= 0){
                var tmpindex = urlstring.indexOf(this.origin_php);
                urlstring = urlstring.replace(urlstring.substring(0, tmpindex)+this.origin_php,'');
            }
        }
      
        return urlstring;
    }
    //将url转为 param-value的数组
    this.encrypturl_urlstringtoarr = function(urlstring,urlstring_keyvalue_arr)
    {
        //1、去除index。php
        urlstring = this.urlstring_filterate(urlstring);
        var arrkey = [];//传参为[]类型数据在此处链接
        urlstring.split('&').filter(param => param).forEach(param => {
            //从第一个=符号分隔
            var idx = param.indexOf('=');
            var key = idx === -1 ? param : param.substring(0, idx);
            var value = idx === -1 ? '' : param.substring(idx + 1);
            key = that.safeDecodeURIComponent(key);
            value = that.safeDecodeURIComponent(value);
            //decode
            if(key.substr(-2) == '[]'){
                //处理传参 []到后台是数组问题,sql报表保存.
                key = key.substring(0, key.length - 2);
                if(urlstring_keyvalue_arr[key]== undefined){
                    urlstring_keyvalue_arr[key] = [];
                }
                urlstring_keyvalue_arr[key].push(value);
                arrkey.push(key);
            }
            else{
                urlstring_keyvalue_arr[key] = value;
            }
        });
        if(arrkey.length>0){
            for(var i=0;i<arrkey.length;i++){
                var tmpkey = arrkey[i];
                var tmpitem = urlstring_keyvalue_arr[tmpkey];
                if(typeof tmpitem == 'object'){
                    urlstring_keyvalue_arr[tmpkey] = that.convertValues(tmpitem);
                }
            }
        }
        return urlstring_keyvalue_arr;
    }
    //将url转为 param-value的数组，排序，并进行加密，获取加密后url
    this.puyoung_urlstringtoencrypty = function(urlstring)
    {
        var urlstring_keyvalue_arr = this.urlparamkey_value_arr;
        var urlarr = that.encrypturl_urlstringtoarr(urlstring,urlstring_keyvalue_arr);
        return that.puyoung_urlarrencrypt(urlarr);
    }
    //传入数据处理，先合为链接字符串
    this.Puyoung_Encryptydataprocess = function(urlstring,param){
        var tmpurl = urlstring;
        var urlstring_keyvalue_arr ={};
        if(param != undefined && param != ''){
            if(typeof param == 'object'){
                //param 为formdata 取值方法
                if( param instanceof FormData){
                    //zkt 20231107 BUG0075073  	升级最新版本后 销售机会模块，并发审批的步骤，用户通过时页面转圈圈，无法审批，见下图 （批量审批可以通过）
                    var tmpentries = param.entries();
                    try {
                        // 尝试使用Object.fromEntries()
                        param = Object.fromEntries(tmpentries);
                    } catch (e) {
                        // 如果出现错误，则使用备选方案
                        param = Array.from(tmpentries).reduce((acc, [key, value]) => {
                            acc[key] = value;
                            return acc;
                        }, {});
                    }
                }
                ld.each(param,function (tmpkey,tmpitem) {
                    if(tmpitem == undefined){
                        return true;
                    }
                    if(typeof tmpitem == 'object'){
                        tmpitem = that.convertValues(tmpitem);
                    }
                    urlstring_keyvalue_arr[tmpkey] = tmpitem;
                })
                this.urlparamkey_value_arr = urlstring_keyvalue_arr;
            }
            else{
                tmpurl+= '&'+param;
            }
        }
        return tmpurl;
    }
    //zkt 拼接加密内容至第一个参数上并返回
    this.Puyoung_Encryptyreturnallfirsturl = function(urlstring,param){
        //urlsting中若包含 this.encrypturlkey this.encrypttimestampkey 则需要过滤
        if(urlstring.indexOf(this.encrypturlkey)>0||urlstring.indexOf(this.encrypttimestampkey)>0){
            var tmpurlstringarr = that.encrypturl_urlstringtoarr(urlstring,[]);
            urlstring = urlstring.replace('&'+this.encrypturlkey+'='+tmpurlstringarr[this.encrypturlkey],'');
            urlstring = urlstring.replace('&'+this.encrypttimestampkey+'='+tmpurlstringarr[this.encrypttimestampkey],'');
        }
        if(urlstring.indexOf(this.origin_php)>=0&&urlstring.indexOf(this.origin_php+'?')<0){
            urlstring += '?';
        }
        var tmpurl = that.Puyoung_Encryptydataprocess(urlstring,param);
        encrypttmpurl = that.puyoung_urlstringtoencrypty(tmpurl);

        if(urlstring != this.origin_php+'?'&&urlstring != this.origin_php&&urlstring.substr(-1) != '?'&&urlstring.substr(-1) != '&'){
            urlstring += '&';
        }
        urlstring += encrypttmpurl;
        return urlstring;
    }
    //zkt 拼接加密内容至第二个参数上并返回
    this.Puyoung_Encryptyreturnallsecondurl = function(urlstring,param){
        //urlsting中若包含 this.encrypturlkey this.encrypttimestampkey 则需要过滤
        if(urlstring.indexOf(this.encrypturlkey)>0||urlstring.indexOf(this.encrypttimestampkey)>0){
            var tmpurlstringarr = that.encrypturl_urlstringtoarr(urlstring,[]);
            urlstring = urlstring.replace('&'+this.encrypturlkey+'='+tmpurlstringarr[this.encrypturlkey],'');
            urlstring = urlstring.replace('&'+this.encrypttimestampkey+'='+tmpurlstringarr[this.encrypttimestampkey],'');
        }
        if(urlstring.indexOf(this.origin_php)>=0&&urlstring.indexOf(this.origin_php+'?')<0){
            urlstring += '?';
        }
        var tmpurl = that.Puyoung_Encryptydataprocess(urlstring,param);
        encrypttmpurl = that.puyoung_urlstringtoencrypty(tmpurl);
        if(typeof param == 'object'){
            encrypttmpurl.split('&').filter(tmpparam => tmpparam).forEach(tmpparam => {
                //从第一个=符号分隔
                var idx = tmpparam.indexOf('=');
                var key = idx === -1 ? tmpparam : tmpparam.substring(0, idx);
                var value = idx === -1 ? '' : tmpparam.substring(idx + 1);
                //param 为formdata 取值方法
                if( param instanceof FormData){
                    param.append(key,value);
                }
                else{
                    //decode
                    param[key] = value;
                }
            });
        }
        else{
            if(param.substr(-1) != '?'&&param.substr(-1) != '&'){
                param += '&';
            }
            param += encrypttmpurl;
        }
        return param;
    }

    //防止decode报错
    this.safeDecodeURIComponent = function(str){
        try {
            return decodeURIComponent(str);
        } catch (e) {
            return str;
        }
    }

    //将数组、对象，循环拼接为字符串。
    this.convertValues = function (data) {
        var returnstr = '';
        var sortparamkey_arr = Object.keys(data).sort();
        var keylength = sortparamkey_arr.length;
        for(var i=0;i<keylength;i++){
            var tmpkey = sortparamkey_arr[i];
            var tmpitem = '';
            if(data[tmpkey] == null){
                data[tmpkey] = '';
            }
            if(typeof data[tmpkey] == 'object'){
                tmpitem = that.convertValues(data[tmpkey]); ;
            }
            else{
                var tmpvalue = data[tmpkey];
                if(tmpvalue === false){
                    tmpvalue = '';
                }
                if(tmpvalue === true){
                    tmpvalue = '1';
                }
                tmpitem = that.safeDecodeURIComponent(tmpvalue);
            }
            returnstr += tmpkey+''+tmpitem;
        }
        return returnstr;
    }
}
/*
* zkt 20231009
* 根据URL,拼接加密内容至URL上并返回,加密内容拼接至第一个Url上面并返回
* */
cls_encryptyurl.Puyoung_Encryptyurlhavephp = function(urlstring,param){
    var cls_encryptyurlobj = new cls_encryptyurl();
    if((urlstring.indexOf('CustomReport/JsReport/index.php') >= 0) ||(urlstring.indexOf('axiosindex.php') >= 0) || (urlstring.indexOf('.php') > 0&&urlstring.indexOf('index.php') < 0)){
        var tmpindex = urlstring.indexOf(".php");
        cls_encryptyurlobj.origin_php = urlstring.substring(0, tmpindex)+'.php';
    }
    return cls_encryptyurlobj.Puyoung_Encryptyreturnallfirsturl(urlstring,param);
}
/*
* zkt 20241107
* 根据URL,拼接加密内容至URL上并返回,加密内容拼接至第一个Url上面并返回
* */
cls_encryptyurl.Puyoung_Encryptyurltoparamhavephp = function(urlstring,param){
    var cls_encryptyurlobj = new cls_encryptyurl();
    if((urlstring.indexOf('CustomReport/JsReport/index.php') >= 0) ||(urlstring.indexOf('axiosindex.php') >= 0) || (urlstring.indexOf('.php') > 0&&urlstring.indexOf('index.php') < 0)){
        var tmpindex = urlstring.indexOf(".php");
        cls_encryptyurlobj.origin_php = urlstring.substring(0, tmpindex)+'.php';
    }
    return cls_encryptyurlobj.Puyoung_Encryptyreturnallsecondurl(urlstring,param);
}
/*
* zkt 20231009
* 根据URL,拼接加密内容至URL上并返回,加密内容拼接至第一个Url上面并返回
* */
cls_encryptyurl.Puyoung_Encryptyurl = function(urlstring,param){
    var cls_encryptyurlobj = new cls_encryptyurl();
    return cls_encryptyurlobj.Puyoung_Encryptyreturnallfirsturl(urlstring,param);
}

/*
* zkt 20231009
* 根据URL,拼接加密内容至URL上并返回,加密内容拼接至第一个Url上面并返回——文件上传需过滤参数
* */
cls_encryptyurl.Puyoung_EncryptyFileurl = function(urlstring,param){
    var cls_encryptyurlobj = new cls_encryptyurl();
    cls_encryptyurlobj.Judgeparamkeys = ['module','action','frommodule','filerand','filename'];
    var Puyoung_EncryptyFileurl = urlstring;
    //param 为formdata 取值方法
    if(typeof param == 'object'&& param instanceof FormData){
        var tmpentries = param.entries();
        try {
            // 尝试使用Object.fromEntries()
            param = Object.fromEntries(tmpentries);
        } catch (e) {
            // 如果出现错误，则使用备选方案
            param = Array.from(tmpentries).reduce((acc, [key, value]) => {
                acc[key] = value;
                return acc;
            }, {});
        }
        var newparam = {}; //创建一个新的临时数组，用以操作后不变更原数组
        ld.each(param,function (tmpkey,tmpitem) {
            if(tmpkey == 'file'&& typeof tmpitem == 'object'){
                tmpkey = 'filename';
                tmpitem = tmpitem.name;
                newparam[tmpkey] = tmpitem;
            }
            else if(cls_encryptyurlobj.Judgeparamkeys.indexOf(tmpkey)>=0){
                newparam[tmpkey] = tmpitem;
            }
        })
        Puyoung_EncryptyFileurl =  cls_encryptyurlobj.Puyoung_Encryptyreturnallfirsturl(urlstring,newparam);
    }
    else{
        Puyoung_EncryptyFileurl =  cls_encryptyurlobj.Puyoung_Encryptyreturnallfirsturl(urlstring,param);
    }
    return Puyoung_EncryptyFileurl;
}

/*
* zkt 20241107
* 根据URL,拼接加密内容至param上并返回
* */
cls_encryptyurl.Puyoung_EncryptyurlhavephpByoriginphp = function(urlstring,param,originphp){
    var cls_encryptyurlobj = new cls_encryptyurl();
    if((urlstring.indexOf(originphp) >= 0)){
        var tmpindex = urlstring.indexOf(".php");
        cls_encryptyurlobj.origin_php = urlstring.substring(0, tmpindex)+'.php';
    }
    return cls_encryptyurlobj.Puyoung_Encryptyreturnallfirsturl(urlstring,param);
}
/*
* zkt 20241107
* 根据URL,拼接加密内容至param上并返回
* */
cls_encryptyurl.Puyoung_EncryptyurltoparamhavephpByoriginphp = function(urlstring,param,originphp){
    var cls_encryptyurlobj = new cls_encryptyurl();
    if((urlstring.indexOf(originphp) >= 0)){
        var tmpindex = urlstring.indexOf(".php");
        cls_encryptyurlobj.origin_php = urlstring.substring(0, tmpindex)+'.php';
    }
    return cls_encryptyurlobj.Puyoung_Encryptyreturnallsecondurl(urlstring,param);
}