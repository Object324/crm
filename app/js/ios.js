var iosObj={};
//获取版本号
iosObj.setAppVersion=function(){
	try {
        window.echo = cordova.exec(
           function(okParam){
           //alert('okParam' + okParam);
           },
           function(error) {
           //alert('error' + error);
           },'CDVDevice', 'setAppVersion',[]);
    }catch (e) {
        //alert('error:' + e.message);
    }
};
//获取IOS，唯一标示
iosObj.getDeviceInfo=function(){
    try {
        window.echo = cordova.exec(
        function(okParam){
            //alert('okParam' + okParam);
            GVObj.deviceID = okParam.uuid;
        },
        function(error) {
            //alert('error' + error);
        },'CDVDevice', 'getDeviceInfo',[]);
    }catch (e) {
        //alert('error:' + e.message);
    }    
};
//获取IOS反馈名片信息
iosObj.getCardInfo=function(){
    try {
        window.echo = cordova.exec(
        function(okParam){}, 
        function(err) {
            //alert('error' + error);
        }, 
        'CDVLDViewHandler', 'openView', ['card',1]);
    }catch (e) {
        //alert('error:' + e.message);
    }
};
//IOS——名片扫描结果，获取后需要调用联系人创建界面
function scanResultScript(result,listype){
    var cardinfo=result;
    GVObj.crmObj.quickcreateStatus='no';
    // 打开创建页
    ViewObj.switchView('crm-createedit-view','init',{
        view_name:'create',
        card:'cardios',
        'cardinfo':cardinfo
    });
}
//调用系统设置
function openView(){
      // 成功回调，错误回调，插件名称， 插件里面的方法， 参数
      window.echo = cordova.exec(function(okParam){
            //alert('ok' + okParam);
      }, function(err){
            //alert('error' + error);
      }, 'CDVLDViewHandler', 'openView', ['about']);
}
//IOS给Key赋值
function cacheData(key,value) {
    window.echo = cordova.exec(
        function(okParam) {
        //alert('ok' + okParam);
        }, function(err) {
        //alert('error' + error);
    }, 'CDVLDHelperPlugin', 'cacheData',[key,value]);
}
//隐藏底部
iosObj.hideMainBtn=function(){
    try {
        window.echo = cordova.exec(
        function(okParam){
            //alert('okParam' + okParam);
        },
        function(error) {
            //alert('error' + error);
        },'CDVDevice', 'HideBottomMenu',[]);
    }catch(e){
        //alert('error:' + e.message);
    }
};
//显示底部
iosObj.showMainBtn=function(){
    try {
        window.echo = cordova.exec(
        function(okParam){
            //alert('okParam' + okParam);
        },
        function(error) {
            //alert('error' + error);
        },'CDVDevice', 'ShowBottomMenu',[]);
    }catch(e){
        //alert('error:' + e.message);
    }
};
//更改底部信息
iosObj.updateMainBtn=function(){
    try {
        window.echo = cordova.exec(
        function(okParam){
            //alert('okParam' + okParam);
        },
        function(error) {
            //alert('error' + error);
        },'CDVDevice', 'showbadgeValue',[]);
    }catch(e){
        //alert('error:' + e.message);
    }
};
//提供头部状态栏信息
function iosReSetViewSize(){
    try {
        window.echo = cordova.exec(
           function(okParam){
           //alert('okParam' + okParam);
           },
           function(error) {
           //alert('error' + error);
           },'CDVDevice', 'reSetViewSize',[]);
    }catch (e) {
        //alert('error:' + e.message);
    }
}
//记录几个首页是否需要重新加载
iosObj.newsHomeLoaded=function(){
    cacheData('NewsRefresh','yes');    
};
iosObj.workHomeLoaded=function(){
    cacheData('WorkRefresh','yes');    
};
iosObj.crmHomeLoaded=function(){
    cacheData('CrmRefresh','yes');    
};
iosObj.applyHomeLoaded=function(){
    cacheData('ApplyRefresh','yes');    
};
iosObj.meHomeLoaded=function(){
    cacheData('MeRefresh','yes');    
};
iosObj.meCRMHomeLoaded=function(){
    cacheData('MeCrmRefresh','yes');    
};
//IOS上传轨迹
iosObj.onComfirmUpload=function(){
    try {
        PopPromptBox.show('轨迹上传中，请稍后');
        window.echo = cordova.exec(
        function(okParam){
            //alert('okParam' + okParam);
            //进度条
            //PopPromptBox.show('轨迹上传中，请稍后');
            var uploadStatus = okParam.retvalue;
            if(uploadStatus==='yes'){
                PopPromptBox.show('轨迹上传成功');
            }
            else{
                PopPromptBox.show('轨迹上传失败');
            }
        },
        function(error) {
            PopPromptBox.show('轨迹上传失败');
        },'CDVDevice', 'uploadTrack',[]);
    }catch (e) {
        PopPromptBox.show('轨迹上传失败');
    }  
};
//IOS判断是否有网络
iosObj.isOnline=function(){
    try {
        window.echo = cordova.exec(
           function(okParam){
                //alert('okParam' + okParam);
                var online = okParam.online;
           },
           function(error) {
                //alert('error' + error);
           },'CDVDevice', 'netWorkonLine',[]);
    }catch (e) {
        //alert('error:' + e.message);
    }
};
//IOS查看附件
iosObj.AttachmentPreview=function(img_id,img_path){
    try {
        window.echo = cordova.exec(
            function(okParam){
            //alert('okParam' + okParam);
            //var online = okParam.online;
            },
            function(error) {
            //alert('error' + error);
            },'CDVLDHelperPlugin', 'AttachmentPreview',[img_id,img_path]);
    }catch (e) {
        //alert('error:' + e.message);
    }
};