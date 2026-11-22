

 

onmessage = function(event) {
    var strarr = (event.data);
    var crmurl=event.data.crmurl;
    var ajaxurl=event.data.ajaxurl;
    var selectuid=event.data.selectuid;
    //console.log(strarr.path);
    
     var ajax = new XMLHttpRequest();
     
        ajax.open("POST",crmurl+"?"+ajaxurl+"&selectuid="+selectuid,true);
  
    ajax.setRequestHeader("Content-type","application/x-www-form-urlencoded");
    ajax.send("name=zhangsan&age=18");
    ajax.onreadystatechange = function(){
        if(ajax.readyState == 4 && ajax.status == 200){
           // console.log(ajax.responseText);
             postMessage(ajax.responseText);
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