var global_ajaxobjs=[];

function ldAjaxHtmlNoProgress(url,param,callback){
    url += '&userid='+wx_userid;
    if(!empty(appusertoken)){
        url += '&appusertoken='+appusertoken;
    }
    url = url.replace('index.php',homefile);
    //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
    url= cls_encryptyurl.Puyoung_Encryptyurlhavephp(url,param);
    var ajaxobj=ld.ajax({
        url: url,
        type: 'POST',
        data:param,
        async: true,
        timeout: 70000,
        success: function(data){
            //隐藏进度
            if(data.code==DataCode.errorhtml){
            }
            if(data.code==DataCode.logincontrol){
                    Tools.Relogin();
            }
            if(data.code==DataCode.Urlillegal){
                return false;
            }
            callback(data);
		}
	});
    global_ajaxobjs.push(ajaxobj);
    return ajaxobj;
}

function ldAjaxHtml(url,param,callback){

    url += '&userid='+wx_userid;

    if(!empty(appusertoken)){
        url += '&appusertoken='+appusertoken;
    }
    url = url.replace('index.php',homefile);
    //显示进度
    if(CrmPopup.start_progressObjs.length<1){
	   ld('#rptContentLoading').show();
    }
    CrmPopup.start_progressObjs.push('');
    //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
    url= cls_encryptyurl.Puyoung_Encryptyurlhavephp(url,param);
    var ajaxobj=ld.ajax({
        url: url,
        type: 'POST',
        data:param,
        async: true,
        timeout: 70000,//edit:can 20200824 42480: 快速查找，查询数据量太大时会提示“加载超时”。预期结果：加大sql查询语句的加载时长
        success: function(data){
            //隐藏进度
            try{
                var tmparr= JSON.parse(data)||eval('('+data+')');
                //异地登录
                if(tmparr.code==DataCode.logincontrol){
                    Tools.Relogin();
                }
            }
            catch(ex)
            {
                
            }
            if(data.code==DataCode.errorhtml){
            }
            if(data.code==DataCode.Urlillegal){
                return false;
            }
            callback(data);
            if(CrmPopup.start_progressObjs.length<=0){
                ld('#rptContentLoading').hide();
            }
		}
	});
    global_ajaxobjs.push(ajaxobj);
}
function EmptyProgressObjs(){
    while(global_ajaxobjs.length>0){
        var tmpobj=global_ajaxobjs[global_ajaxobjs.length-1];
      
        if(tmpobj!=undefined&&tmpobj!=''){
            tmpobj.abort();
            delete tmpobj;
        }
        global_ajaxobjs.pop();
    }
    while(CrmPopup.start_progressObjs.length>0){
        DelProgressObjs();
    }
}
function DelProgressObjs(){
    if(CrmPopup.start_progressObjs.length>0){
        var tmpobj=CrmPopup.start_progressObjs[CrmPopup.start_progressObjs.length-1];
        
        tmpobj=undefined;
        CrmPopup.start_progressObjs.pop();
        if(CrmPopup.start_progressObjs.length<=0){
            ld('#rptContentLoading').hide();
        }
    }
}
function ldAjax(url,param,callback){

    url += '&userid='+wx_userid;
    if(!empty(appusertoken)){
        url += '&appusertoken='+appusertoken;
    }
    url = url.replace('index.php',homefile);
    //显示进度
    if(CrmPopup.start_progressObjs.length<1){
	    ld('#rptContentLoading').show();
    }
    CrmPopup.start_progressObjs.push('');
    //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
    url= cls_encryptyurl.Puyoung_Encryptyurlhavephp(url,param);
    var ajaxobj=ld.ajax({
        url: url,
        type: 'POST',
        data:param,
        dataType:'json',
        async: true,//
        timeout: 900000,//edit:can 20200824 42480: 快速查找，查询数据量太大时会提示“加载超时”。预期结果：加大sql查询语句的加载时长

        success: function(data)
        {
            //隐藏进度
           if(data.code==DataCode.errorhtml){
             //var crmPopupobj=CrmPopup.load("","",)
           }
			if(data.code==DataCode.logincontrol)
             {
               
                Tools.Relogin();
             }
            if(data.code==DataCode.Urlillegal){
                return false;
            }
            callback(data);
            if(CrmPopup.start_progressObjs.length<=0)
                ld('#rptContentLoading').hide();
		},
        error:function(jqXHR, textStatus, errorThrown)
        {
           console.log(url);
           console.log(textStatus);
        }
	})
    global_ajaxobjs.push(ajaxobj);
}
ldAjax.ajaxobj=undefined;
function ldAjaxNoProgress(url,param,callback){
    url += '&userid='+wx_userid;
    if(!empty(appusertoken)){
        url += '&appusertoken='+appusertoken;
    }
    url = url.replace('index.php',homefile);
    //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
    url= cls_encryptyurl.Puyoung_Encryptyurlhavephp(url,param);
    var ajaxobj= ld.ajax({
        url: url,
        type: 'POST',
        data:param,
        dataType:'json',
        async: true,//
        timeout: 70000,//edit:can 20200824 42480: 快速查找，查询数据量太大时会提示“加载超时”。预期结果：加大sql查询语句的加载时长
        success: function(data)
        {
            if(data.code==DataCode.logincontrol){
                    Tools.Relogin();
            }
            if(data.code==DataCode.Urlillegal){
                return false;
            }
            callback(data);
            
		}
	})
    global_ajaxobjs.push(ajaxobj);
    return ajaxobj ;
}
ldAjaxNoProgress.ajaxnoprogressobj=undefined;


function ldAjaxNoProgresssync(url,param,callback){
    url += '&userid='+wx_userid;
    if(!empty(appusertoken)){
        url += '&appusertoken='+appusertoken;
    }
    url = url.replace('index.php',homefile);
    //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
    url= cls_encryptyurl.Puyoung_Encryptyurlhavephp(url,param);
    var ajaxobj= ld.ajax({
        url: url,
        type: 'POST',
        data:param,
        dataType:'json',
        async: false,//
        timeout: 70000,//edit:can 20200824 42480: 快速查找，查询数据量太大时会提示“加载超时”。预期结果：加大sql查询语句的加载时长
        success: function(data)
        {
            if(data.code==DataCode.Urlillegal){
                return false;
            }
            callback(data);
		}
	})
    global_ajaxobjs.push(ajaxobj);
}
