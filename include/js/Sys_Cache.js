function Sys_Cache()
{
    
}
Sys_Cache.istartcache='no';
Sys_Cache.showPopup=function(){
    ld("#pageleft .menu-thumbnail-box").hide();
    var crmPopupobj=CrmPopup.load(arrJsPopLabel['ClearCache'] ,"","","600",'Cache',"","","","");
    crmPopupobj.prevshow();
    crmPopupobj.setParams(arrJsPopLabel['ClearCache'],Sys_Cache.start_Cache,Sys_Cache.Cancel,"600",'Settings',"",arrJsPopLabel['CONFIRMED'],"",arrJsPopLabel['CANCEL']);
    var content="";
	crmPopupobj.show("<div class='select-input' style='padding:10px 20px'><div style='line-height:40px;height:40px'><input name='sysset' checked type='checkbox' id='sysset_1'><label for='sysset_1'>"+arrJsPopLabel['ClearCache']+"("+arrJsPopLabel['SystemSettingsCacheDesc']+")</label></div><div style='line-height:40px;height:40px'><input name='opcache' type='checkbox' id='sysset_2'><label for='sysset_2'>Opcache("+arrJsPopLabel['OpcacheCacheDesc']+"）</label></div></div>");

    //绑定右上角关闭事件  zxm 20230201
    ld('#' + crmPopupobj.divid + ' .E_pop_tit .E_ptitc').unbind('click').on('click', function () {
        // console.log('右上角关闭事件');
        ld('#rptContentLoading').hide();
        Sys_Cache.istartcache='no';
        _flag = 'yes';
        return false;
    });
}
Sys_Cache.Cancel=function()
{
    ld('#rptContentLoading').hide();
    Sys_Cache.istartcache='no';
    _flag = 'yes';
}
Sys_Cache.start_Cache=function()
{
    if(Sys_Cache.istartcache=='yes')
        return ;
    var popupobj=CrmPopup.getPopupObj('last');
    Sys_Cache.istartcache='yes';
    
     var cachetype='sys';
     if(ld("#"+popupobj.divid+" [name=opcache]").prop("checked"))
     {
        cachetype='opcache';
     }
     ldAjaxHtml('index.php?','module=Cache&file=index&ajax=true&action=CacheAjax&cachetype='+cachetype,function(response) {
         if(response.indexOf('SUCCESS')>0){
             if(cachetype=='opcache')
                 Sys_Cache.startWork();
             else
             {
                 Sys_Cache.startSys_Work();
             }


             return;
         }
     })
}
Sys_Cache.startSys_Work=function(){
    
    //系统参数重新创建Fields;
     var worker = new Worker("include/js/CacheWork.js");
      var url_arr=window.location.href.split("?");
   	var confirm_str = arrJsPopLabel['CLEARSUCCESS'];
    worker.postMessage({'module':"Fields","url":url_arr[0]});
      worker.onmessage = function(event) {
        setTimeout(function(){
            _flag = 'yes';
             var popupobj=CrmPopup.getPopupObj('last');
             popupobj.CancelEvent();
             Sys_Cache.istartcache='no';
             ld('#rptContentLoading').hide();
            // RemindsMsg("","LdPopWidth400px","","yes","",confirm_str)
            MessagePopup.TipOne_success(confirm_str);
         },500)
         worker.terminate();
         
    }
    
    var worker1 = new Worker("include/js/CacheWork.js");
    
    worker1.postMessage({'module':"ProductFields","url":url_arr[0]});
    
    worker1.onmessage = function(event) {
     worker1.terminate();
     
    }
    
}
Sys_Cache.startWork=function(){
    
    
    
     var worker = new Worker("include/js/CacheWork.js");
    var url_arr=window.location.href.split("?");
   	var confirm_str = arrJsPopLabel['CLEARSUCCESS'];
    worker.postMessage({'module':"Accounts","url":url_arr[0]});
   
    worker.onmessage = function(event) {
        setTimeout(function(){
            _flag = 'yes';
             var popupobj=CrmPopup.getPopupObj('last');
             popupobj.CancelEvent();
             Sys_Cache.istartcache='no';
             ld('#rptContentLoading').hide();
            // RemindsMsg("","LdPopWidth400px","","yes","",confirm_str)
            MessagePopup.TipOne_success(confirm_str);
         },500)
         worker.terminate();
         
    }
    var worker1 = new Worker("include/js/CacheWork.js");
    
    worker1.postMessage({'module':"SalesOrder","url":url_arr[0]});
    
    worker1.onmessage = function(event) {
     worker1.terminate();
     
    }
   var worker2 = new Worker("include/js/CacheWork.js");
   
   worker2.postMessage({'module':"Expense","url":url_arr[0]});
   
    worker2.onmessage = function(event) {
       
         worker2.terminate();
    }
    var worker3 = new Worker("include/js/CacheWork.js");
   
    worker3.postMessage({'module':"Contacts","url":url_arr[0]});
   
    worker3.onmessage = function(event) {
          worker3.terminate();
    }
    var worker4 = new Worker("include/js/CacheWork.js");
   
    worker4.postMessage({'module':"Users","url":url_arr[0]});
   
    worker4.onmessage = function(event) {
          worker4.terminate();
    }
}


