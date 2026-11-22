var androidObj={};
//获取版本号
androidObj.setAppVersion=function(){
    javatojs.setAppVersion(mobileVersion);
};
//安卓手机返回键
var B_TIME_INTERVAL = 800, // 两次点击间隔时间毫秒数
    B_start_time = 0,
    B_end_time = 0;
function backForAndroid(){
    // 两次点击间隔时间必须大于指定毫秒数
    B_end_time = (new Date()).valueOf() ;
    if( (B_end_time - B_start_time) < B_TIME_INTERVAL ){
        B_start_time = B_end_time;
        return;
    }
    B_start_time = B_end_time;

    // 正在切换页面时，点击无效
    if(ViewObj.getInfo('transform_state') === 'transforming') return;
    //console.log('点击安卓返回键！注意页面是否显示正确～');
    var c_vid = ViewObj.getCurrentViewId();
    // 当不存在页面时，安卓返回键无效
    if(!c_vid) return;
    // 当有弹出页的时候先关闭弹出页
    var popuboxs = ld('[popubox]:visible'); 
    if( popuboxs.length ){
        popuboxs.each(function(index,el){
            var _this = ld(this),
                _class = _this.attr('class'),
                _id = _this.attr('id');
            // 关闭操作
            if( _this.hasClass('orderdiv') ){
                OperationObj.triggerCilckEvent(ld('#layerMask'));
            // 关闭工作主页，发布选项页
            }else if(_this.hasClass('pop-workadd')){
                workHandleObj.workAddtion();
            // 关闭图片预览页
            }else if(_id && _id === 'picture-preview-holder'){
                PicturePreviewObj.getBack();
            // 关闭提示框
            }else if(_id && _id === 'pop-prompt-box'){                
                PopPromptBox.hide();
            // 关闭头部下拉框
            }else if(_id && _id === 'pulldown_menu'){
                logicHanderObj.headerDataClassify();
            }
        });
        // 关闭弹出页后，判断是否在首页，在首页需要显示底部按钮
        if(c_vid.indexOf('main') > -1){
            ViewObj.switchFooter('cwnm-main-footer','display');
        }
        return;
    // 时间控件 返回键
    }else if(ld('.mbsc-sense-ui.dw-modal').length){
        ld('.dwbw.dwb-c div').click();
        return;
    }
    // 在crm,news,work,me首页时，返回键无效
    if(c_vid.indexOf('main') > -1){
		javatojs.ExitSystem();
        return ;
    }
    OperationObj.triggerCilckEvent(null,'header',{target_id:'head_left'});
}
//调用拍名片功能
androidObj.getCardInfo=function(){
    javatojs.createContactsInfoByCard('2');
};
//安卓——名片扫描结果，获取后需要调用联系人创建界面
function setContactsInfoByCard(){
    var cardinfo=javatojs.getContactsInfo();
    GVObj.crmObj.quickcreateStatus='no';
    // 跳转到创建页
    ViewObj.switchView('crm-createedit-view','init',{
        view_name:'create',
        card:'cardandroid',
        'cardinfo':cardinfo
    });
}
//隐藏底部
androidObj.hideMainBtn=function(){
    javatojs.HideBottomMenu();
};
//显示底部
androidObj.showMainBtn=function(){
    javatojs.ShowBottomMenu();
};
//更改底部信息
androidObj.updateMainBtn=function(){
    javatojs.showbadgeValue();
};
//提供头部状态栏信息
function androidReSetViewSize(){
    javatojs.reSetViewSize();
}
//记录几个首页是否需要重新加载
androidObj.newsHomeLoaded=function(){
    javatojs.NewsRefresh();
};
androidObj.workHomeLoaded=function(){
    javatojs.WorkRefresh();
};
androidObj.crmHomeLoaded=function(){
    javatojs.CrmRefresh();
};
androidObj.applyHomeLoaded=function(){
    javatojs.ApplyRefresh();
};
androidObj.meHomeLoaded=function(){
    javatojs.MeRefresh();
};
androidObj.meCRMHomeLoaded=function(){
    javatojs.MeCrmRefresh();
};
//安卓发短信
androidObj.smsPhone=function(smsphone){
    javatojs.smsPhone(smsphone);
};
//安卓打电话
androidObj.callPhone=function(callphone){
    javatojs.callPhone(callphone);
};
//安卓上传轨迹
androidObj.onComfirmUpload=function(){
    return javatojs.uploadTrack();
};
//安卓判断是否有网络
androidObj.isOnline=function(){
    return javatojs.isOnline();
};
//安卓查看附件
androidObj.AttachmentPreview=function(img_id,img_path){
    javatojs.AttachmentPreview(img_id,img_path);
};