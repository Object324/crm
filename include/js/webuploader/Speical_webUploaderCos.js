//editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/21 13:43
(function (ld, window) {
    var target;
    //getScriptBackWithURL('include/js/webuploader/cos-js-sdk-v5.js',null);
    AjaxJSPage('cos-js-sdk-v5_js','include/js/webuploader/cos-js-sdk-v5.js');
    var cosConfig = {
        Bucket: globalWebUploadParam.Bucket,
        Region: globalWebUploadParam.Region,
        DirName:cosDirName
    };
    var getAuthorization = function (options, callback) {

        // 格式一、（推荐）后端通过获取临时密钥给到前端，前端计算签名
        // 服务端 JS 和 PHP 例子：https://github.com/tencentyun/cos-js-sdk-v5/blob/master/server/
        // 服务端其他语言参考 COS STS SDK ：https://github.com/tencentyun/qcloud-cos-sts-sdk
        // var url = '../server/sts.php'; // 如果起的是 php server 用这个
        //var url = '/sts'; // 如果是 npm run sts.js 起的 nodejs server，使用这个

        //zkt 20231012 XUQIU1001341 SQL注入
        ldAjaxNoProgresssync('index.php?module=Users&action=UsersAjax&file=qcloudEvent&second_action=get_temp_keys&ldencrypt=yes','',function (data) {
            if (data.code == 1) {
                var credentials = data.result.content.credentials;
                if(credentials.encrypt_key_arr){
                    credentials = cls_AESencryptionbykey.Puyoung_Dncryptyvaluearrbyoperation(credentials,true,credentials.encrypt_key_arr);
                }
                //  cosConfig.DirName = data.result.content.dir_name;
                callback({
                    TmpSecretId: credentials.tmpSecretId,
                    TmpSecretKey: credentials.tmpSecretKey,
                    XCosSecurityToken: credentials.sessionToken,
                    StartTime: data.result.content.startTime, // 密钥申请时服务器时间
                    ExpiredTime: data.result.content.expiredTime, // SDK 在 ExpiredTime 时间前，不会再次调用 getAuthorization
                });
            }
        });
    };

    var initWebUpload = function (item, options) {
        //创建默认参数
        var defaults = {
            auto:true,	//自动上传
            onAllComplete: function (event) { },	//当所有file都上传后执行的回调函数
            onComplete: function (event) { },	//每上传一个file的回调函数
            fileNumLimit: 20,	//验证文件总数量, 超出则不允许加入队列
            fileSizeLimit: 0,	//验证文件总大小是否超出限制, 超出则不允许加入队列。
            fileSingleSizeLimit: global_uploadfile_maxsize_mb,	//验证单个文件大小是否超出限制, 超出则不允许加入队列
            PostbackHold: false
        };
        var prevfixstr=options.inputFileName+"-";
        var uitype=options.uitype;
        var that=this;
        var fieldname=options.inputFileName;
        var cos;
        var opts = ld.extend(defaults, options);
        var fileSingleSizeLimit = 0;
        var fileSizeLimit = 0;
        if(opts.fileSingleSizeLimit > 0){
            fileSingleSizeLimit = opts.fileSingleSizeLimit;
            opts.fileSingleSizeLimit = fileSingleSizeLimit * 1024 * 1024;	//MB
        }
        if(opts.fileSizeLimit > 0){
            fileSizeLimit = opts.fileSizeLimit;
            opts.fileSizeLimit = fileSizeLimit * 1024 * 1024;	//MB
        }
        target = ld(item);//容器
        var popupobj = CrmPopup.getPopupObj('last');

        var pickerid = (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);

        var uploaderStrdiv = '';

        var tipsText = '';//上传附件说明，如支持格式等
        if(options.uitype==105){
            options.fileNumLimit = 1;
        }
        
        //自动上传
        if (opts.auto) {
            var attachments_tips = '';

            //相关信息 - 选择导入 opts.admin 等于 undeifined
            if(opts.admin != undefined){
                attachments_tips = arrJsPopLabel['uploaduptoattachments'];
                if(!empty(attachments_tips)){
                    attachments_tips=attachments_tips.replace('{Num}',opts.fileNumLimit);
                }
            }else{
                opts.fileNumLimit = 1;
            }
			 var choosefiletype='';
			if(opts.uitype==69 || opts.uitype==105)
            {
                //edit:can 20210201 044439: （61mis.com/kfbtest）客户管理-联系人-新增/编辑；联系人模块的照片字段，添加图片附件时，可以选择txt、doc其他格式的文件；应只可选择图片格式的
                choosefiletype='accept="image/*"';
            }
            uploaderStrdiv +=
               
                '<span id="' + pickerid + '" style="display:inline-flex;vertical-align:middle;" class="">'+
                '<div class="webuploader-pick" style="min-width:40px">' +
                '</div>' +
                '<input type="file" name="file"  '+choosefiletype+'  class="webuploader-element-invisible" multiple="multiple"><label style="opacity: 0; width: 100%; height: 100%; display: block; cursor: pointer; background: rgb(255, 255, 255);"></label>' +
                '</span> ';
            if(opts.uitype !=69&&opts.uitype!=105)
            {
                if(opts.admin == 'on'){
                    uploaderStrdiv += '<a style="vertical-align: middle;" href="javascript:void(0);" onclick="setAttachFileType(\'set\',\'\')">'+arrJsPopLabel['setthefileformat']+'</a>';
                }else if(opts.admin == 'off'){
                    uploaderStrdiv += '<a style="vertical-align: middle;" href="javascript:void(0);" onclick="setAttachFileType(\'view\',\'\')">'+arrJsPopLabel['viewthefileformat']+'</a>';
                }
            }

            if(!empty(attachments_tips)){
                tipsText = attachments_tips +'，'+arrJsPopLabel['MAXUPLOADSIZE'] + global_uploadfile_maxsize_mb +'MB';
            }else{
                tipsText = arrJsPopLabel['MAXUPLOADSIZE'] + global_uploadfile_maxsize_mb +'MB';
            }

           
            if(opts.special_ins != undefined && opts.special_ins != ''){
                uploaderStrdiv += '<span id="limitmsg" class="E_red_txt">'+opts.special_ins+'</span>';
            }
            // ld("b[tag='attachmentHelp_"+opts.uitype+"'] #tip_info").text(tipsText);
            // ld("b[tag='attachmentHelp_"+opts.uitype+"']").addClass('tip-items-list');
            ld("[tag='attachmentHelp_"+opts.uitype+"']").attr('data-tip', tipsText);
            ld("[tag='attachmentHelp_"+opts.uitype+"']").attr('data-direction', 'top');
            ld("[tag='attachmentHelp_"+opts.uitype+"']").attr('data-type', 'position');
            // ljj 2023-08-17 BUG0070653 kfbtest-销售机会-单据详情页，销售阶段推进任务中的附件设置浮显
            // tooltip('.tip-items-list', {transition: true, time: 200});
            uploaderStrdiv +='</div>'+
                '<div name="Uploadthelist" class="uploader-list"></div>';
        } else
            {
            //手动上传
            uploaderStrdiv +=
                '<div  class="uploader-list"></div>' +
                '<div class="btns">' +
                '<div id="' + pickerid + '">'+arrJsPopLabel['BROWSETHEFILE']+'</div>' +
                '<button class="webuploadbtn">'+arrJsPopLabel['STARTUPLOADING']+'</button>' +
                '</div>';
        }
        if (options.module == 'ModComments' && options.mode == 'reply') {
            uploaderStrdiv += '<div style="display:none" class="UploadhiddenInput" name="UploadhiddenInput_'+options.replyid+'"><input type="hidden" value=""  name="'+prevfixstr+'file_num"></div>';
        }else {
            uploaderStrdiv += '<div style="display:none" class="UploadhiddenInput" name="UploadhiddenInput"><input type="hidden" value=""  name="'+prevfixstr+'file_num"></div>';
        }
        target.append(uploaderStrdiv);
        var list = target.find('.uploader-list'),
            btn = target.find('.webuploadbtn'),//手动上传按钮备用
            state = 'pending',
            hiddenInput = target.find('.UploadhiddenInput'),
            uploader;
        var jsonData = {
            fileList: []
        };
        if (options.module == 'ModComments' && options.mode == 'reply'){
            hiddenInput = target.find('[name=UploadhiddenInput_'+options.replyid+']');
        }
        //PC端-增加系统参数“设置网页端上传图片时是否压缩”
        var iscompress=true;////设置网页端上传图片时是否压缩,0:压缩
        if(imagecompress==0)
        {
            iscompress=true;
        }
        else
        {
            iscompress=false;
        }
        //```````定义内部函数``开始
        list.on("click", ".webuploadDelbtn", function () {
            var id = ld(this).parent().attr("name");
            var id = id.replace(ld(item)[0].id, "");
           
             if(uitype==1108)
            {
                if(uploadFileobj.attachmentdelfileids==undefined)
                    uploadFileobj.attachmentdelfileids=[];
                uploadFileobj.attachmentdelfileids.push(target.find("[name="+prevfixstr+"fileid_" +id+"]").val());
            }
            else if(uitype==69)
            {
                if(uploadFileobj.imagedelfileids==undefined)
                    uploadFileobj.imagedelfileids=[];
                uploadFileobj.imagedelfileids.push(target.find("[name="+prevfixstr+"fileid_" +id+"]").val());
            }
            removeFile(id);
        });
        var fileInputObj;
        if (options.module == 'ModComments' || (options.module == 'Settings' && options.mode == 'loginswiper')){
            fileInputObj = target.find('input[name="file"]');
        }else {
            fileInputObj = ld('div[name='+options.inputFileName+'] input[name="file"]');
        }
        //删除附件
        var removeFile = function ( id ) {

            target.find("[name="+id+"]").remove();
            target.find("[name="+prevfixstr+"file_name_"+id+"]").remove();
            target.find("[name="+prevfixstr+"file_size_"+id+"]").remove();
            target.find("[name="+prevfixstr+"file_path_"+id+"]").remove();
            target.find("[name="+prevfixstr+"file_type_"+id+"]").remove();
            setInputFileName(id);
            // 清空fileInput对象的值，否则重复上传不触发change事件
            fileInputObj.val('');
        };


        //编辑界面，显示已有的附件
        var uploadReady = function () {
            
        };
        //给附件数量赋值
        function setInputFileName(filenum){
            target.find('[name='+prevfixstr+'file_num]').val(filenum);
        }
        /*var setInputFileName = function (filenum){
            target.find('[name='+prevfixstr+'file_num]').val(filenum);
        };*/
        //获取文件序号
        var getFileId = function () {
            idSuffix++;
            return idSuffix;
        };
    
        //【异步】将上传到COS的文件信息，保存进CRM临时文件表
        var saveIntoTempTable = function(rFile){
            //zkt 20231012 XUQIU1001341 SQL注入
            ldAjax('index.php?module=Users&action=UsersAjax&file=qcloudEvent&second_action=save_into_temptable&fileinfo='+JSON.stringify(rFile),'',function (data) {
                DelProgressObjs();
                if (data.code == 1) {
                    //var credentials = data.result.key.credentials;
                }
            });
        };
        //上传进度条
        var uploadProgress  = function( file, percentage ) {

           
        };
        //开始上传文件
        var fileQueued = function(file){
            list.append( '<div name="' +file.id + '" class="attachments-padL10">' +'<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+
                '<span class="item" style="padding-left:5px">' +file.name +'</span>' +
                '<span class="state" style="padding-left:5px">'+arrJsPopLabel['BEINGUPLOADED']+'...</span><span class="webuploadDelbtn" tag="" style="padding-left:5px"></span>' +
                '</div>' );
        };
        //不管成功或者失败，文件上传完成时触发 file {File}File对象
        var uploadComplete = function(){
            
            //上传完成隐藏进度条
             ld('#homeprogressbar').hide();
             ld('#progressbar').css('width',Math.round(0 * 100)+'%');
        };
        //文件上传change事件
        var fileChange = function (that) {
            
           
            ld.each(that.files, function(j, item) {
                  
                // var file = that.files[0];
                var file = item;
                if (!file) return;
                if (file.name.indexOf('.php') > 0){
                    var confirm_str = arrJsPopLabel['FORSECURITYREASONS'] + '<br/>' + file.name;
                    MessagePopup.TipOne_warning(confirm_str);
                    return;
                }
                ld('#homeprogressbar').show();
                //43170: （本地crm）附件管理-附件-预览；版本8.2.9；图片带字符‘“·&%#无法预览；带或者不带特殊字符的doc，xlsx，xls的文件都无法预览；下载正常 带中文符号……的文件，预览丢失。
                var filename=file.name.replace("+",'_');
                var specialstr='·—+·&%#@——={}【】?？';
                for(var i=0;i<specialstr.length;i++)
                {
                    var ch=specialstr.substr(i,1);
                    filename=filename.replace(ch,'_');

                }
                
                var fileNameArr =filename.split('.');// file.name.split('.');
                //edit:can 2020-11-02 兖矿集团有限公司煤液化及煤化工国家重点实验室2020.11.10-2021.11.9期刊+经纶合作协议.docx
                var subfilename=fileNameArr[fileNameArr.length-1];//文件后缀名称

                var newFileName = fileNameArr[0]+'_'+Date.parse(new Date())+'_'+Math.ceil(Math.random()*1000)+'.'+subfilename;
              //  ldAjaxHtmlNoProgress("index.php?module=Users&action=UsersAjax&file=File_SetName&filename="+encodeURIComponent(file.name),{},function(result){
                    /*var dataobj = eval('('+ result +')')?eval('('+ result +')'):JSON.parse(result);
                    if(dataobj.type == 3 ){
                        //41487: （61mis.com/kfbcrm）单据新建/编辑界面，附件字段设置允许上传的文件格式添加附件时，其他格式也可以上传（附件管理模块测试）
                        var confirm_str = arrJsPopLabel['FORSECURITYREASONS'] +'\n'+file.name;
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        return false;
                    }*/
                    
                    cos.sliceUploadFile({
                        Bucket: cosConfig.Bucket, // Bucket 格式：test-1250000000
                        Region: cosConfig.Region,
                        Key: cosConfig.DirName+newFileName,
                        Body: file,
                        SliceSize: 2 * 1024 * 1024,
                        onTaskReady: function (tid) {
                            TaskId = tid;
                            file.id = getFileId();
                            fileQueued(file);
                        },
                        onHashProgress: function (progressData) {
                            //console.log(JSON.stringify(progressData));
                             //console.log('onHashProgress', JSON.stringify(progressData));
                        },
                        onProgress: function (progressData) {
                            
                            
                            ld('#progressbar').css('width',Math.round(progressData.percent * 100)+'%');
                            /*if(Math.round(progressData.percent * 100)>=100)
                            {
                                 uploadComplete();
                            }*/
                            
                        },
                    }, function (err, data) {
                        //console.dir(err || data);
                        if(data.statusCode === 200){
                            var locationArr = data.Location.split(encodeURIComponent(newFileName));
                            file.path =cosConfig.DirName;// locationArr[0];
                            file.cloud_path=data.Location;
                            
                            file.newfile_name = newFileName;
                            file.storage_location = 'cos';
                            file.imagefromtype = 'Computer';
                            file.upload_from = 'pc';
                            //给特殊input赋值
                            setInputFileName(file.id);
                            //保存进临时表
                            saveIntoTempTable(data);
                          if (opts.module == 'ModComments'){
                              encrypt(file);
                          }
                          else if(options.module == 'Settings' && options.mode == 'loginswiper'){
                              addFile(file,'create',options);
                          }
                          else {
                              if(options.uitype==69)
                                  ldAjaxNoProgress("index.php?module=Users&action=UsersAjax&file=cos_CooperativeWork",{newfile_name:newFileName,path:(file.path),cloud_path:"https://"+decodeURIComponent(data.Location),name:file.name,type:'image','size':file.size},function(ajaxdata){
                                      file.record=ajaxdata.result.record;
                                      addFile(file,'create',options);
                                  })
                              else{

                                  ldAjaxNoProgress("index.php?module=Users&action=UsersAjax&file=cos_CooperativeWork",{newfile_name:newFileName,path:(file.path),cloud_path:"https://"+decodeURIComponent(data.Location),name:file.name,type:'att','size':file.size},function(ajaxdata){
                                      file.record=ajaxdata.result.record;
                                      addFile(file,'create',options);
                                  })
                              }
                          }
                            
                            
                        }
                    });

                //})
            })
            

        }
        //```````定义内部函数``结束
        //```````在页面DOM加载完毕后，自动执行下面的代码
        //文件序号
        idSuffix = 0;
        //给隐藏的input[name="file"]增加change事件

        if (options.module == 'ModComments' || (options.module == 'Settings' && options.mode == 'loginswiper')){
            target.find('input[name="file"]').on('input',function (e) {
                //重新给target赋值，否则联系人附件和图片两个字段会互相干扰
                // target = ld('#'+options.parentdivid+' [name=comment_'+options.inputFileName+']');
                fileChange(this);
            });
        }else {
            ld('div[name='+options.inputFileName+'] input[name="file"]').on('input',function (e) {
                //重新给target赋值，否则联系人附件和图片两个字段会互相干扰
                // target = ld('div[name='+options.inputFileName+']');
                fileChange(this);
            });
        }
        //显示已有的附件
       
          cos = new COS({
                getAuthorization: getAuthorization,
            });
        uploadReady();

        var encrypt = function(file){
            var url = "index.php?module=Users&action=UsersAjax&file=File_Encrypt";
            var file_url = '';
            file_url += "&newfile_name=" + file.newfile_name;
            file_url += "&path=" + file.path;
            file_url += "&cloud_path=" + file.cloud_path;
            file_url += "&id=" + file.id;
            file_url += "&name=" + file.name;
            file_url += "&type=" + file.type;
            //edit: xll 2023/10/06 BUG0072908 客户管理（包括但不限于，比如报价单、销售订单等等）数据列表，无法通过快速编辑添加视频附件。
            file_url += "&pagetype=" + options.pagetype;
            ldAjaxNoProgress(url,file_url,function(result){
                var response = result.result;
                file.newfile_name = response.newfile_name;
                file.path = response.path;
                file.cloud_path = response.cloud_path;
                file.isEncrypt = response.isEncrypt;
                file.filerowindex=file.id;
                file.pre_button = response.pre_button;  //预览按钮
                addFile(file,'create',options);
            })
        };
        function addFile(file,type,options){

            var  restobj=file;

            ld('#homeprogressbar').hide();
            if(options.attach_server != undefined && !empty(options.attach_server)){
                ld('#upload_file_name').attr('path',restobj.path);
                ld('#upload_file_name').attr('file',restobj.name);
                var filename = '<span class="upload-file-name"><span class="item-name">'+ld('#upload_file_name').attr('file')+
                    '</span><span class="remove-h">×</span></span>';
                ld('#upload_file_name').html(filename);
                ld('.upload-file-name .remove-h').on('click',function(){//删除
                    ld('#upload_file_name').attr('path','');
                    ld('#upload_file_name').attr('file','');
                    ld('#upload_file_name').html('');
                });
                uploader.reset();
            }else{
                if (options.module == 'ModComments') {
                    addModCommentsFile(file, options.inputFileName);
                }
                else if(options.mode == 'loginswiper'){//登录页轮播图
                    addloginswiperimage(file);
                }
                else {
                    if(options.uitype == 69){
                        var tag = 'sendLog';
                        var tmppopupobjdivid = options.popupobj?'#'+options.popupobj.divid+' ':' ';
                        ld(tmppopupobjdivid+'#'+tag+'UploadImg ul').append('<li record="'+restobj.record+'"><span class="item-name"><img class="name-img" alt="" src="https://'+restobj.cloud_path+'"></span><span class="remove-h">×</span></li>');
                        ld(tmppopupobjdivid+'#'+tag+'UploadImg').css('display','');
                        //绑定移入显示删除标志事件
                        ld(tmppopupobjdivid+'#'+tag+'UploadImg ul li').on('mouseenter',function(){
                            //alert('here 1');
                            ld(this).find('span.remove-h').css('display','inline');
                        });
                        //绑定移出隐藏删除标志事件
                        ld(tmppopupobjdivid+'#'+tag+'UploadImg ul li').on('mouseleave',function(){
                            ld(this).find('span.remove-h').css('display','none');
                        });
                        //绑定图片删除事件
                        ld(tmppopupobjdivid+'#'+tag+'UploadImg ul li span.remove-h').on('click',function(){
                            var record = ld(this).parent().attr('record');
                            ld(tmppopupobjdivid+'#'+tag+'UploadImg ul li[record='+record+']').remove();
                            if(0 == ld('#'+tag+'UploadImg ul li').length){
                                ld(tmppopupobjdivid+'#'+tag+'UploadImg').css('display','none');
                            }
                            return false;
                        });
                    }else{
                        var tag = 'sendLog';
                        var tmppopupobjdivid = options.popupobj?'#'+options.popupobj.divid+' ':' ';
                        ld(tmppopupobjdivid+'#'+tag+'UploadAtt ul').append('<li record="'+restobj.record+'"><img alt="'+restobj.name+'" src="themes/softed/images/file.png"><span class="upload-attname">'+restobj.name.substring(0,30)+'<br/><span class="remove-h"> 取消</span></span></li>');
                        ld(tmppopupobjdivid+'#'+tag+'UploadAtt').css('display','');
                        //绑定移入显示删除标志事件
                        ld(tmppopupobjdivid+'#'+tag+'UploadAtt ul li').on('mouseenter',function(){
                            //alert('here 1');
                            ld(this).find('span.remove-h').css('display','inline');
                        });
                        //绑定移出隐藏删除标志事件
                        ld(tmppopupobjdivid+'#'+tag+'UploadAtt ul li').on('mouseleave',function(){
                            ld(this).find('span.remove-h').css('display','none');
                        });
                        //绑定附件删除事件
                        ld(tmppopupobjdivid+'#'+tag+'UploadAtt ul li span.remove-h').on('click',function(){
                            var record = ld(this).parent().parent().attr('record');
                            ld(tmppopupobjdivid+'#'+tag+'UploadAtt ul li[record='+record+']').remove();
                            if(0 == ld(tmppopupobjdivid+'#'+tag+'UploadAtt ul li').length){
                                ld(tmppopupobjdivid+'#'+tag+'UploadAtt').css('display','none');
                            }
                        });
                    }
                }

            }
            //uploader.reset();
            ld('.uploader-list').html('');

        }
        function addModCommentsFile(file,type) {
            // type 图片:image 附件：filename
            var uploadobj=ld('#'+popupobj.divid+' #'+options.parentdivid).find('[name=upload_'+type+']');
            var size = file.size;
            if (size < 1024)
                size = size + ' B';
            else if (size > 1024 && size < 1048576)
                size = (size / 1024).toFixed(2) + ' KB';
            else if (size > 1048576)
                size = (size / (1024 * 1024)).toFixed(2) + ' MB';
            file.size=size;
            var html = '<div name="ModCommentsUpLoad" id="ModCommentsUpLoad" class="comment-uoloader-list-row" fileid="'+file.id+'">';
            var isPreviewEnable = ld('#'+popupobj.divid+' #'+options.parentdivid).find('[name=isPreviewEnable]').val();
            if (type == 'image'){
                if (isPreviewEnable == 'yes'){
                    html += '<div class="el-image"><img name="prevshow_img" tag="'+file.id+'" src="https://'+file.cloud_path+'"></div>';
                }
            }else {
                html += '<a class="att-img"></a>'
            }
            html += '<span class="item">'+file.name+'</span>';
            html += '<span>('+size+')</span>';
            html += '<span class="webuploadDelbtn" tag="create" style="padding-left:10px"><a href="javascript:void(0)" tag="delete"  fileid="'+file.id+'">'+arrJsPopLabel['DELETE']+'</a></span>';
            html += '<span class="webuploadDelbtn" style="padding-left:10px" name="preview_button" tag="'+file.id+'">';
            if (isPreviewEnable == 'yes'){
                if (type == 'image'){
                    var pre_button=file.pre_button.replace('uploader-list','comment-uoloader-list-row')
                    html += pre_button;
                }else {
                    html += '<a href="javascript:;" onclick="Pre_Attachment(this)" '+
                        'file_fileid="'+file.id+'_" file_isencrypt="'+file.isEncrypt+'" file_size="'+size+'" file_filename="'+file.name+'" file_path="'+file.path+'" '+
                        'file_newfile_name="'+file.newfile_name+'" file_cloud_path="'+file.cloud_path+'" file_storage_location="'+file.storage_location+'" file_type="'+file.type+'"><span>'+arrJsPopLabel['PREVIEW']+'</span>';
                    html += '</a>';
                }
            }
            html += '</span>';
            html += '</div>';
            uploadobj.append(html);
            if (type == 'image' && isPreviewEnable == 'yes'){
                var src = uploadobj.find('[name=preview_button][tag='+file.id+']').find('img').attr('src');
                uploadobj.find('img[name=prevshow_img][tag='+file.id+']').attr('src',src);
                previewImage(uploadobj.find('img[name=prevshow_img][tag='+file.id+']').get(0));
            }
            uploadobj.css('display','');
            uploadobj.find('[name=ModCommentsUpLoad]').find('a[fileid='+file.id+']').bind('click',function () {
                deleteFile(this,type);
            });

            var filename = file.name.replace(/\'/g,"");
            filename = filename.replace(/\"/g,"");
            filename = filename.replace(/ /g,"_");
            var newfile_name=file.newfile_name;
            newfile_name = newfile_name.replace(/\"/g,"");
            newfile_name = newfile_name.replace(/ /g,"_");
            var imagefromtype = empty(file.imagefromtype)?'':file.imagefromtype;
            hiddenInput.append('<input type="text" id="'+prevfixstr+'file_size_' + file.id + '" name="'+prevfixstr+'file_size_' + file.id + '" class="hiddenInput" value="' + size + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'file_name_' + file.id + '"  name="'+prevfixstr+'file_name_' + file.id + '" class="hiddenInput" value="' + filename + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'file_path_' + file.id + '" name="'+prevfixstr+'file_path_' + file.id + '" class="hiddenInput" value="' + file.path + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'file_type_' + file.id + '" name="'+prevfixstr+'file_type_' + file.id + '" class="hiddenInput" value="' + file.type + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'newfile_name_' + file.id + '" tag="'+prevfixstr+'newfile_name"    name="'+prevfixstr+'newfile_name_' + file.id + '" class="hiddenInput" value="' + newfile_name + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'fileid_' + file.id + '" name="'+prevfixstr+'fileid_' + file.id + '" class="hiddenInput" value="' + file.id + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'storage_location_' + file.id + '" name="'+prevfixstr+'storage_location_' + file.id + '" class="hiddenInput" value="' + file.storage_location + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'imagefromtype_' + file.id + '" name="'+prevfixstr+'imagefromtype_' + file.id + '" class="hiddenInput" value="' + imagefromtype + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'cloud_path_' + file.id + '" name="'+prevfixstr+'cloud_path_' + file.id + '" class="hiddenInput" value="' + decodeURIComponent(file.cloud_path) + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'isEncrypt_' + file.id + '" name="'+prevfixstr+'isEncrypt_' + file.id + '" class="hiddenInput" value="' + file.isEncrypt + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'upload_from_' + file.id + '" name="'+prevfixstr+'upload_from_' + file.id + '" class="hiddenInput" value="' + file.upload_from + '" />');
            hiddenInput.find('[name='+prevfixstr+'file_num]').val(file.id);
        }
        //登录页轮播图
        function addloginswiperimage(file){
            var uploadobj=ld('#'+popupobj.divid);
            var cloud_path = "https://"+file.cloud_path;
            var html = '<input type="hidden" id="loginswipercontent" value="'+cloud_path+'"/>';
            uploadobj.find('[name=loginswiperchooseimgfilename]').html(html);
            uploadobj.find('[name=loginswiper_img]').attr('src',cloud_path);
            uploadobj.find('[name=loginswiper_img_div]').show();
            popupobj.center();
        }

        function deleteFile(obj,type){
            var fileid = ld(obj).attr('fileid');
            var uploadobj=ld('#'+popupobj.divid+' #'+options.parentdivid).find('[name=upload_'+type+']');
            uploadobj.find('[name=ModCommentsUpLoad][fileid='+fileid+']').remove();
            hiddenInput.find('#'+prevfixstr+'file_size_'+fileid).remove();
            hiddenInput.find('#'+prevfixstr+'file_name_'+fileid).remove();
            hiddenInput.find('#'+prevfixstr+'file_path_'+fileid).remove();
            hiddenInput.find('#'+prevfixstr+'file_type_'+fileid).remove();
            hiddenInput.find('#'+prevfixstr+'newfile_name_'+fileid).remove();
            hiddenInput.find('#'+prevfixstr+'fileid_'+fileid).remove();
            hiddenInput.find('#'+prevfixstr+'storage_location_'+fileid).remove();
            hiddenInput.find('#'+prevfixstr+'cloud_path_'+fileid).remove();
            hiddenInput.find('#'+prevfixstr+'isEncrypt_'+fileid).remove();
            hiddenInput.find('#'+prevfixstr+'upload_from_'+fileid).remove();
            var newfilenum = hiddenInput.find("[tag="+prevfixstr+"newfile_name]").length;
            hiddenInput.find('[name='+prevfixstr+'file_num]').val(newfilenum);
            idSuffix--;
            if (parseInt(newfilenum) == 0){
                uploadobj.css('display','none');
            }

        }
        
    };

    ld.fn.special_powerWebUploadCos = function (options) {
        var ele = this;
        //引入PC端控件样式
        //    alert(ld("#"+popupobj.divid+ ' [name='+options.inputFileName+']').length);
        var casspath_btn = "include/js/webuploader/css/webuploader.css";
        ld("<link>").attr({ rel: "stylesheet", type: "text/css", href: casspath_btn }).appendTo("head");
        var casspath_loader = "include/js/webuploader/css/bootstrap.min.css";
        ld("<link>").attr({ rel: "stylesheet", type: "text/css", href: casspath_loader }).appendTo("head");
        initWebUpload(ele,options);

        if (options.module == 'ModComments' || (options.module == 'Settings' && options.mode == 'loginswiper')){
            var popupobj = CrmPopup.getPopupObj('last');
            if(options.module == 'Settings' && options.mode == 'loginswiper'){
                ld(ele).find('.webuploader-pick').css('min-width','70px').text(arrJsPopLabel['Choosepictures']);
            }
            ld(ele).find('.webuploader-pick').unbind("click").bind('click',function(){
                ld(this).parent().find('input[name="file"]').trigger('click');
            });
        }
        else {
            ld('[name='+options.inputFileName+']').find('.webuploader-pick').unbind("click").bind('click',function(){
                ld('[name='+options.inputFileName+'] input[name="file"]').trigger('click');
            });
        }
        return false;

    };
})(jQuery, window);
