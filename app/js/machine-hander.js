var machineHanderObj={};
//获取版本号
machineHanderObj.setAppVersion=function(){
    if(phoneversion == 'ios'){
        iosObj.setAppVersion();
    }
    else if(phoneversion == 'android'){
        androidObj.setAppVersion();
    }
};
//隐藏底部
machineHanderObj.hideMainBtn=function(){
    if(phoneversion == 'ios'){
        iosObj.hideMainBtn();
    }
    else if(phoneversion == 'android'){
        androidObj.hideMainBtn();
    }
};
//显示底部
machineHanderObj.showMainBtn=function(){
    // 在me crm work news 首页是需要显示main底部标签
    var c_vid = ViewObj.getCurrentViewId(); 
    if( c_vid.indexOf('main') > -1  &&
        c_vid.indexOf(category) > -1 ){
        if(phoneversion == 'ios'){
            iosObj.showMainBtn();
        }else if(phoneversion == 'android'){
            androidObj.showMainBtn();
        }
    }
};
//更改底部信息
machineHanderObj.updateMainBtn=function(){
    if(phoneversion == 'ios'){
        iosObj.updateMainBtn();
    }
    else if(phoneversion == 'android'){
        androidObj.updateMainBtn();
    }
};
//拍照
machineHanderObj.getPictureNative=function(fromtype){
    var c_viewid =  ViewObj.getCurrentViewId();
    var p_module = '';
    if(category=='me' || (category=='work'&&c_viewid === 'all-userinfo-view')){p_module='';}
    if(ViewObj.rootScope.mode === 'relationcreate'){
        p_module = newmodule;
    }
    else{
        p_module = module;
    }
    if(p_module == 'Approve'){
        p_module = ViewObj.rootScope.approvemodule;
    }
    var nativetype = '';
    if(fromtype==='camera'){
        nativetype = 'camera';
    }
    if(phoneversion == 'ios'){
        window.echo = cordova.exec(
            function(okParam) {
           //alert('ok' + okParam);
           }, function(err) {
           //alert('error' + error);
           }, 'CDVLDHelperPlugin', 'createPhotoImage',["type",nativetype,"module",p_module]
        );
        imageTimeIntervalid= setInterval("getImageUrl()",5);
    }
    else{
        javatojs.createPhotoImage(nativetype,p_module);
        imageTimeIntervalid= setInterval("getImageUrl()",5);
    } 
};
//IOS获取上传图片后返回信息
function getImageUrl(){  
    if(phoneversion=='ios'){                           
        window.echo = cordova.exec(
            function(okParam) {
                if(okParam.imageurl!='')
                {
                    clearInterval(imageTimeIntervalid);
                    if(okParam.imageurl!='cancel'){
                        machineHanderObj.onSuccess(okParam.imageurl);    
                    }
                }
            }, function(err) {
                //alert('error' + error);
            }, 'CDVLDHelperPlugin', 'getPhotoImageUrl',[]
        );
    }
    else{
        var imageurl=javatojs.getPhotoImageUrl();
        if(imageurl!=""&&imageurl!=undefined)
        {
            clearInterval(imageTimeIntervalid);
            machineHanderObj.onSuccess(imageurl);   
        }
    }
}
//图片上传成功
machineHanderObj.onSuccess = function(returnmsg){
    datefieldarr = returnmsg.split("&&&&");//字符串转变成数组
    var imgpath = datefieldarr[0],
        c_viewid =  ViewObj.getCurrentViewId(),
        img_src = 'http://'+loginurl+'/'+imgpath,
        img_holder = null,
        img_num = 1,
        img_html = '';
    // 工作 ，发日志，发微博等 ，上传照片    
    if(category=='work'){
        if(ViewObj.rootScope.workphotopage=='onlyinfo' && c_viewid === 'all-userinfo-view'){
            imgid = datefieldarr[1];
            img_html = '<img alt="" src="'+img_src+'">';
            ld('#image_new').html('<img class="name-img" src="'+img_src+'">');
        }
        else{
            imgid += datefieldarr[1]+',';
            img_holder = ld('#sendLogUploadImg'),
            img_num = (ld('#sendLogUploadImg div[img-detail]').length+1);
            img_html = '<div img-detail > <img img_num="'+img_num+'" src="'+img_src+'" /></div>';
            ld(img_html).insertBefore(img_holder.find('div[tag="img-addbt"]'));
            if(ld('#sendLogUploadImg').is(':hidden')){
                img_holder.removeClass('ui-hide'); 
            }
            PicturePreviewObj.addPictrue(img_src); 
        }
    // apply 拍照、外勤签到 ，crm上传产品图片等
    }else if(category=='crm' || category=='apply'){
        // apply 拍照
        if(module=='PhotoGraph'){
            imgid = datefieldarr[1];
            ViewObj.rootScope.attachmentdetailid = datefieldarr[2];
            img_html = '<img src="'+img_src+'">';
            ld('#crm-photo-viewContent').html(img_html);   
            //控制上传图片的大小
            imgheight = ld(window).height()- 304;
            ld('#crm-photo-viewContent').css('height',imgheight+'px');
            ld('#crm-photo-footer div').attr('active','true').css({'backgroundColor':'#6f9dd1'});
        }
        else if(module=='Singin'){
            imgid += datefieldarr[1]+',';
            if(ViewObj.rootScope.imginfo==undefined){
                ViewObj.rootScope.imginfo = '';
            }
            ViewObj.rootScope.imginfo += ViewObj.rootScope.imagefrom+',';
            img_holder = ld('#signUploadImg'),
            img_num = (ld('#signUploadImg div[img-detail]').length+1);
            img_html = '<div img-detail > <img img_num="'+img_num+'" src="'+img_src+'" /></div>';
            ld(img_html).insertBefore(img_holder.find('div[tag="sign_addimg"]'));
            if(ld('#signUploadImg').is(':hidden')){
                img_holder.removeClass('ui-hide'); 
            }
            PicturePreviewObj.addPictrue(img_src);
        }
        else{
            var img_holder = ld('#imagemodule'),
                img_num = (ld('#imagemodule div[img-detail]').length+1),
                img_html = '<div img-detail >  <img  img_num="'+img_num+'" src="'+img_src+'" /></div>';
            var att_count = ld('#imagemodule div[img-detail]').length;
            att_count++;
            if(att_count>ViewObj.rootScope.att_maxcount){
                PopPromptBox.show('添加的附件数量不允许超出'+ ViewObj.rootScope.att_maxcount +'个');
                return;
            } 
            else{
                imgid += datefieldarr[1]+',';
                ld(img_html).insertBefore(img_holder.find('div[tag="img-addbt"]'));
                PicturePreviewObj.addPictrue(img_src);    
            }
        }
    }else if(category=='me'){
        if(c_viewid === 'all-userinfo-view'){
            imgid = datefieldarr[1];
            img_html = '<img alt="" src="'+img_src+'">';
            ld('#image_new').html('<img class="name-img" src="'+img_src+'">');
            ld('#image_new_home').html('<img tag="userimage" src="'+img_src+'">');
        }else if(c_viewid === 'me-feedback-view'){
            imgid += datefieldarr[1]+',';
            img_holder = ld('#feedback-imgholder'),
            img_num = (ld('#feedback-imgholder div[img-detail]').length+1);
            img_html = '<div img-detail > <img img_num="'+img_num+'" src="'+img_src+'" /></div>';
            ld(img_html).insertBefore(img_holder.find('div[tag="img-addbt"]'));            
            PicturePreviewObj.addPictrue(img_src);            
        }
    }else if(category=='news'){
        var img_holder = ld('#imagemodule'),
            img_num = (ld('#imagemodule div[img-detail]').length+1),
            img_html = '<div img-detail >  <img  img_num="'+img_num+'" src="'+img_src+'" /></div>';
        var att_count = ld('#imagemodule div[img-detail]').length;
        att_count++;
        if(att_count>ViewObj.rootScope.att_maxcount){
            PopPromptBox.show('添加的附件数量不允许超出'+ ViewObj.rootScope.att_maxcount +'个');
            return;
        } 
        else{
            imgid += datefieldarr[1]+',';
            ld(img_html).insertBefore(img_holder.find('div[tag="img-addbt"]'));
            PicturePreviewObj.addPictrue(img_src);    
        }
    }
};
//调用拍名片功能
machineHanderObj.getCardInfo = function(){
    if(phoneversion == 'ios'){
        iosObj.getCardInfo();
    }
    else if(phoneversion == 'android'){
        androidObj.getCardInfo();
    }
};
//记录几个首页是否需要重新加载
function NewsHomeLoaded(){
    if(phoneversion == 'ios'){
        iosObj.newsHomeLoaded();
    }
    else if(phoneversion == 'android'){
        androidObj.newsHomeLoaded();
    }
}
function WorkHomeLoaded(){
    if(phoneversion == 'ios'){
        iosObj.workHomeLoaded();
    }
    else if(phoneversion == 'android'){
        androidObj.workHomeLoaded();
    }
}
function CRMHomeLoaded(){
    if(phoneversion == 'ios'){
        iosObj.crmHomeLoaded();
    }
    else if(phoneversion == 'android'){
        androidObj.crmHomeLoaded();
    }
}
function ApplyHomeLoaded(){
    if(phoneversion == 'ios'){
        iosObj.applyHomeLoaded();
    }
    else if(phoneversion == 'android'){
        androidObj.applyHomeLoaded();
    }
}
function MeHomeLoaded(){
    if(phoneversion == 'ios'){
        iosObj.meHomeLoaded();
    }
    else if(phoneversion == 'android'){
        androidObj.meHomeLoaded();
    }
}
function MeCRMHomeLoaded(){
    if(phoneversion == 'ios'){
        iosObj.meCRMHomeLoaded();
    }
    else if(phoneversion == 'android'){
        androidObj.meCRMHomeLoaded();
    }
}
//调用选择附件功能
machineHanderObj.getAttNative = function(fromtype){
    if(phoneversion == 'android'){
        if(fromtype==='photo'){
            javatojs.OpenFileDialog("image","",module);
        }
        else if(fromtype==='video'){
            javatojs.OpenFileDialog("video","",module);
        }
        else if(fromtype==='fileatt'){
            javatojs.OpenFileDialog("file","",module);
        }
    }
};
//选择附件上传成功后，原生调用此方法，返回上传结果回来
function setFileAttachmentInfo(fileinfo){
    setFileAttachmentInfoAndroid(fileinfo);
}
//查看附件
machineHanderObj.AttachmentPreview=function(img_id,img_path){
    if(phoneversion == 'ios'){
        iosObj.AttachmentPreview(img_id,img_path);        
    }
    else if(phoneversion == 'android'){
        androidObj.AttachmentPreview(img_id,img_path);
    }
    else{
        alert('other:'+img_id+'---'+img_path);
    }
}