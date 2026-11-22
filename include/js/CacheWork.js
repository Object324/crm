

 

onmessage = function(event) {
    var strarr = (event.data);
    //console.log(strarr.path);
     var module=strarr.module;
    var url=strarr.url;
     var ajax = new XMLHttpRequest();
     if(module=='Users')
     {
         url=url+"?module=Users&action=UsersAjax&file=getParentTabList&cachemodule="+module;
     }
     else if(module=="Fields")
     {
         url=url+"?module=Cache&action=CacheAjax&file=CreateAllFieldCache";
     }
     else if(module=="ProductFields")
     {
         url=url+"?module=Cache&action=CacheAjax&file=CreateProductFieldCache";
     }
     else if(module=='Settings')
     {
         url=url+"?module=Cache&action=CacheAjax&file=CreateFieldCache&fieldmodule="+strarr.fieldmodule;
     }
     else{
         url=url+"?module=Cache&action=CacheAjax&file=CreateCacheCode&cachemodule="+module;
     }
     //zkt 20231108 增加SQL验证
    importScripts('cls_encryptyurl.js'); // 导入其他脚本中的函数
    importScripts('crypto-js.min.js'); // 导入其他脚本中的函数
    var tmpbody = "name=zhangsan&age=18";
    url = cls_encryptyurl.Puyoung_Encryptyurl(url,tmpbody);

    ajax.open("POST",url,true);
    ajax.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    ajax.send(tmpbody);
    ajax.onreadystatechange = function(){
        if(ajax.readyState == 4 && ajax.status == 200){
             postMessage('aaa');
        }
    } 
    
   
    
/*
    var result = 0;
    for (var i = 0; i < num; i++) {
        result += i;
        console.log(result);
    }
 
    // 向线程创建源送回消息
    postMessage(result);
    */
}