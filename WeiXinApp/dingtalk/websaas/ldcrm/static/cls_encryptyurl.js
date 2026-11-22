function cls_encryptyurl() {
    this.sorturlparamkey_arr = [];//url的paramkey的数组
    this.urlstring = '';//url字符串
    this.sorturlstring = '';//排序后的url字符串
    var that = this;
    this.Judgeparamkeys = [];
    this.origin_php = 'index.php';
    if(sessionStorage.getItem('mobileSource') == 'app'){
        this.origin_php = 'indexnative.php';
    }
    this.encrypturlkey = 'lingdangencryptyurl';
    this.encrypttimestampkey = 'lingdangtimestamp';
    this.lingdangencryptykey = 'lingdang';
    this.newencrypttimestampkey = 'ldtimestamp';
    this.newencrypturlkey = 'ldencryptyurl';
    this.urlparamkey_value_arr = {};//url的paramkey-value的数组
    //对url字符串进行加密，并返回加密后字符串
    this.lingdang_sorturlencrypt =  function()
    {
        var urlstring = that.sorturlstring;
        
        var timestamp = new Date().getTime();
        var encrypturl = '';
        //使用timestamp作为key进行加密
        code = CryptoJS.MD5(this.lingdangencryptykey+timestamp).toString()
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
    this.lingdang_urlarrencrypt = function (urlarr)
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
                tmpitem = tmpitem;
            }
            tmpurlstring +=tmpkey+'='+tmpitem;
        }
        if(tmpurlstring.length>0 && tmpurlstring[0] == '&'){
            tmpurlstring = tmpurlstring.substring(1);
        }
        that.sorturlstring = tmpurlstring;
        return that.lingdang_sorturlencrypt();
    }
    this.sorturlkeyarr=function(urlarr)
    {
        var sorturlparamkey_arr = Object.keys(urlarr).sort();
        return sorturlparamkey_arr;
    }
    //过滤url:去除this.origin_php
    this.lingdang_filterate = function(urlstring)
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
    this.lingdang_urlstringtoarr = function(urlstring,urlstring_keyvalue_arr)
    {
        //1、去除index。php
        urlstring = this.lingdang_filterate(urlstring);
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
    this.lingdang_urlstringtoencrypty = function(urlstring)
    {
        var urlstring_keyvalue_arr = this.urlparamkey_value_arr;
        var urlarr = that.lingdang_urlstringtoarr(urlstring,urlstring_keyvalue_arr);
        return that.lingdang_urlarrencrypt(urlarr);
    }
    //传入数据处理，先合为链接字符串
    this.Lingdang_Encryptydataprocess = function(urlstring,param){
        var tmpurl = urlstring;
        var urlstring_keyvalue_arr = {};
        if(param != undefined && param != ''){
            if(typeof param == 'object'){
                //param 为formdata 取值方法
                if( param instanceof FormData){
                    param = Object.fromEntries(param.entries());
                }
                $.each(param,function (tmpkey,tmpitem) {
                    if(tmpitem == undefined){
                        tmpitem = '';
                    }
                    if(typeof tmpitem == 'object'){
                        tmpitem = that.convertValues(tmpitem);
                        if(tmpitem == ''){
                            return true;
                        }
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
    this.Lingdang_Encryptyreturnallfirsturl = function(urlstring,param){
        //urlsting中若包含 this.encrypturlkey this.encrypttimestampkey 则需要过滤
        if(urlstring.indexOf(this.newencrypturlkey)>0||urlstring.indexOf(this.newencrypttimestampkey)>0){
            var tmpurlstringarr = that.lingdang_urlstringtoarr(urlstring,[]);
            urlstring = urlstring.replace('&'+this.newencrypturlkey+'='+tmpurlstringarr[this.newencrypturlkey],'');
            urlstring = urlstring.replace('&'+this.newencrypttimestampkey+'='+tmpurlstringarr[this.newencrypttimestampkey],'');
        }
        if(urlstring.indexOf(this.encrypturlkey)>0||urlstring.indexOf(this.encrypttimestampkey)>0){
            var tmpurlstringarr = that.lingdang_urlstringtoarr(urlstring,[]);
            urlstring = urlstring.replace('&'+this.encrypturlkey+'='+tmpurlstringarr[this.encrypturlkey],'');
            urlstring = urlstring.replace('&'+this.encrypttimestampkey+'='+tmpurlstringarr[this.encrypttimestampkey],'');
        }
        if(urlstring.indexOf(this.origin_php)>=0&&urlstring.indexOf(this.origin_php+'?')<0){
            urlstring += '?';
        }
        var tmpurl = that.Lingdang_Encryptydataprocess(urlstring,param);
        encrypttmpurl = that.lingdang_urlstringtoencrypty(tmpurl);

        if(urlstring.substr(-1) != '?'&&urlstring.substr(-1) != '&'){
            urlstring += '&';
        }
        urlstring += encrypttmpurl;
        return urlstring;
    }
    //zkt 拼接加密内容至第二个参数上并返回
    this.Lingdang_Encryptyreturnallsecondurl = function(urlstring,param){
        //urlsting中若包含 this.encrypturlkey this.encrypttimestampkey 则需要过滤

        if(urlstring.indexOf(this.newencrypturlkey)>0||urlstring.indexOf(this.newencrypttimestampkey)>0){
            var tmpurlstringarr = that.lingdang_urlstringtoarr(urlstring,[]);
            urlstring = urlstring.replace('&'+this.newencrypturlkey+'='+tmpurlstringarr[this.newencrypturlkey],'');
            urlstring = urlstring.replace('&'+this.newencrypttimestampkey+'='+tmpurlstringarr[this.newencrypttimestampkey],'');
        }
        if(urlstring.indexOf(this.encrypturlkey)>0||urlstring.indexOf(this.encrypttimestampkey)>0){
            var tmpurlstringarr = that.lingdang_urlstringtoarr(urlstring,[]);
            urlstring = urlstring.replace('&'+this.encrypturlkey+'='+tmpurlstringarr[this.encrypturlkey],'');
            urlstring = urlstring.replace('&'+this.encrypttimestampkey+'='+tmpurlstringarr[this.encrypttimestampkey],'');
        }
        if(urlstring.indexOf(this.origin_php)>=0&&urlstring.indexOf(this.origin_php+'?')<0){
            urlstring += '?';
        }
        var tmpurl = that.Lingdang_Encryptydataprocess(urlstring,param);
        encrypttmpurl = that.lingdang_urlstringtoencrypty(tmpurl);
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
                tmpitem = that.convertValues(data[tmpkey]);
                if(tmpitem == ''){
                    continue;
                }
            }
            else{

                tmpitem = that.safeDecodeURIComponent(data[tmpkey]);
            }
            returnstr += tmpkey+''+tmpitem;
        }
        return returnstr;
    }
}
/*
* zkt 20231018
* 根据URL,拼接加密内容至URL上并返回,加密内容拼接至第一个Url上面并返回
* */
cls_encryptyurl.Lingdang_Encryptyurlhavephp = function(urlstring,param){
    var cls_encryptyurlobj = new cls_encryptyurl();
    if((urlstring.indexOf('CustomReport/JsReport/index.php') >= 0) || (urlstring.indexOf('.php') > 0&&urlstring.indexOf('index.php') < 0)){
        var tmpindex = urlstring.indexOf(".php");
        cls_encryptyurlobj.origin_php = urlstring.substring(0, tmpindex)+'.php';
    }
    return cls_encryptyurlobj.Lingdang_Encryptyreturnallfirsturl(urlstring,param);
}
/*
* zkt 20231018
* 根据URL,拼接加密内容至URL上并返回,加密内容拼接至第一个Url上面并返回
* */
cls_encryptyurl.Lingdang_Encryptyurl = function(urlstring,param){
    var cls_encryptyurlobj = new cls_encryptyurl();
    return cls_encryptyurlobj.Lingdang_Encryptyreturnallfirsturl(urlstring,param);
}

/*
* zkt 20231018
* 根据URL,拼接加密内容至URL上并返回,加密内容拼接至第一个Url上面并返回——文件上传需过滤参数
* */
cls_encryptyurl.Lingdang_EncryptyFileurl = function(urlstring,param){
    var cls_encryptyurlobj = new cls_encryptyurl();
    cls_encryptyurlobj.Judgeparamkeys = ['module','action','frommodule','filerand','filename'];
    var Lingdang_EncryptyFileurl = urlstring;
    //param 为formdata 取值方法
    if(typeof param == 'object'&& param instanceof FormData){
        param = Object.fromEntries(param.entries());
        var newparam = {}; //创建一个新的临时数组，用以操作后不变更原数组
        $.each(param,function (tmpkey,tmpitem) {
            if(tmpkey == 'file'&& typeof tmpitem == 'object'){
                tmpkey = 'filename';
                tmpitem = tmpitem.name;
                newparam[tmpkey] = tmpitem;
            }
        })
        Lingdang_EncryptyFileurl =  cls_encryptyurlobj.Lingdang_Encryptyreturnallfirsturl(urlstring,newparam);
    }
    else{
        Lingdang_EncryptyFileurl =  cls_encryptyurlobj.Lingdang_Encryptyreturnallfirsturl(urlstring,param);
    }
    return Lingdang_EncryptyFileurl;
}