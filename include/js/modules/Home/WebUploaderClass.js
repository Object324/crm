function WebUploadClass() {
    if (!WebUploader.Uploader.support()) {
        var error = "上传控件不支持您的浏览器！请尝试升级flash版本或者使用Chrome引擎的浏览器";
        if (window.console) {
            window.console.log(error);
        }
        ld(item).text(error);
        return;
    }
    var that = this;
    that.defaults = {
        auto:true,	//自动上传
        onAllComplete: function (event) { },	//当所有file都上传后执行的回调函数
        onComplete: function (event) { },	//每上传一个file的回调函数
        fileNumLimit: 100,	//验证文件总数量, 超出则不允许加入队列
        fileSizeLimit: 0,	//验证文件总大小是否超出限制, 超出则不允许加入队列。
        fileSingleSizeLimit: global_uploadfile_maxsize_mb,	//验证单个文件大小是否超出限制, 超出则不允许加入队列
        PostbackHold: false
    };
    that.filerand = Math.floor(Math.random()*999999);
    that.server = global_flash_fileattachmentphp+"&filerand="+that.filerand;
    that.getDefaultOpt = function () {
        return {
            swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
            //edit: xll BUG0064357 周计划、任务中图片无法正常显示
            server: that.server,	 // 文件接收服务端。
            deleteServer:'',	 // 文件删除服务端。
            pick: {
                id: '#'+that.pickerId,
                multiple:false,
            },	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
            resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
            //compress:false,
            chunked: true,	//是否要分片处理大文件上传
            chunkSize:2*1024*1024,	//分片大小，默认2M
            accept: { // 只允许选择图片文件。
                title: 'Images',
                extensions: 'jpg,jpeg,bmp,png,icon,gif,dwg,psd,ico',
                mimeTypes: 'image/*'
            }
        }
    }
    that.getUploaderStrdiv = function () {
        return '<div class="addfu">' +
                    '<span id="' + that.pickerId + '" style="display: inline-flex; vertical-align: middle;" class="aa">'+
                        '<a class="icon-attachment icon-attachments inpb-attachments"></a>' +
                    '</span>' +
                '</div>' +
                '<div name="Uploadthelist" class="uploader-list"></div>' +
                '<div style="display:none" class="UploadhiddenInput" name="UploadhiddenInput">' +
                    '<input type="hidden" value="" tag="filenum"  name="'+that.prevfixstr+'file_num">' +
                '</div>';
    };
    that._init = function (item, options) {
        //创建默认参数
        that.prevfixstr = options.inputFileName+"-";
        var target = that.target = ld(item);//容器
        var opts = ld.extend(that.defaults, options);
        if(opts.fileSingleSizeLimit > 0){
            opts.fileSingleSizeLimit = opts.fileSingleSizeLimit * 1024 * 1024;	//MB
        }
        if(opts.fileSizeLimit > 0){
            opts.fileSizeLimit = opts.fileSizeLimit * 1024 * 1024;	//MB
        }
        that.pickerId = (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);

        //自动上传
        target.append(that.getUploaderStrdiv());
        that.list = target.find('.uploader-list');
        that.btn = target.find('.webuploadbtn');//手动上传按钮备用
        that.state = 'pending';
        that.server += '&frommodule='+options.module+"&uitype=69&isEncrypt=no";

        var webOpts = ld.extend(that.getDefaultOpt(),opts);
        //创建WebUploader实例
        that.uploader = WebUploader.create(webOpts);
        that.opts = opts;
    }
    that.init = function (item, options) {
        //初始化
        that._init(item, options);

        //队列事件
        that.uploader.on('fileQueued', that.fileQueued);

        //编辑  队列显示
        that.uploader.on('ready', that.ready);

        // 文件上传过程中创建进度条实时显示。
        that.uploader.on( 'uploadProgress', that.uploadProgress);

        //当文件上传成功时触发file {File}File对象  response {Object}服务端返回的数据
        that.uploader.on( 'uploadSuccess', that.uploadSuccess);

        //当文件上传出错时触发file {File}File对象  reason {String}出错的code
        that.uploader.on( 'uploadError', that.uploadError);

        //不管成功或者失败，文件上传完成时触发 file {File}File对象
        that.uploader.on( 'uploadComplete', that.uploadComplete);

        //出错 提示
        that.uploader.on("error",that.error);

        that.uploader.on('all', that.all);

        //多文件点击上传的方法
        that.btn.on('click', function () {
            if (that.state === 'uploading') {
                that.uploader.stop();
            } else {
                that.uploader.upload();
            }
        });
    }

    that.ready = function () {
        var fileCount = 1;
        if(!empty(that.opts.jsonData)){
            var fileArr;
            if(ld.isArray(that.opts.jsonData))
                fileArr = that.opts.jsonData;//编辑或创建弹出层
            else
                fileArr = eval('('+ that.opts.jsonData +')')?eval('('+ that.opts.jsonData +')'):JSON.parse(that.opts.jsonData);
            var k = 0;
            var fileSize = 0;
            if(fileArr != null){
                ld.each(fileArr,function(i,fileInfo){
                    k = i + 1;
                    fileCount++;
                    fileSize += 2;
                    var statusMap = {};
                    var obj = {
                        filerowindex : k,
                        name : fileInfo['name'],
                        newfile_name : fileInfo['newfile_name'],
                        type : fileInfo['type'],
                        size : fileInfo['size'],
                        path : fileInfo['path'],
                        imagefromtype : fileInfo['imagefromtype'],
                        source : this,
                        flog : true,
                        status : 'complete',
                        getStatus : function(){
                            return '';
                        },
                        version : WebUploader.Base.version,
                        statusText : '',
                        setStatus : function(){
                            var prevStatus = statusMap[ this.id ];
                            typeof text !== 'undefined' && (this.statusText = text);
                            if ( status !== prevStatus ) {
                                statusMap[ this.id ] = status;
                                this.trigger( 'statuschange', status, prevStatus );
                            }
                        },
                    };
                    if(typeof that.addFile === "function") {
                        that.addFile(obj,'edit');
                    }
                    that.uploader.trigger( '_fileQueued');
                });

                that.target.find('[name='+that.prevfixstr+'file_num]').val(fileCount);
            }
        }
        WebUploader.Base._idSuffix=fileCount;
    }
    that.fileQueued = function (file) {
        that.uploader.options.encryptyurl ='yes';
        var list = that.target.find('.uploader-list')
        list.append( '<div name="' +file.id + '" class="attachments-padL10">' +
            '<span class="item" style="padding-left:5px">' +file.name +'</span>' +
            '<span class="state" style="padding-left:5px"></span>' +
            '<span class="webuploadDelbtn" style="padding-left:5px"></span>' +
            '</div>' );
        that.uploader.upload();
    }
    that.uploadProgress = function (file, percentage) {
        ld('#homeprogressbar').show();
        ld('#progressbar').css('width',Math.round(percentage * 100)+'%');
    }
    /**
     * 公共
     * @param file
     * @param response
     */
    that.uploadSuccess = function (file,response) {
        if (file.ext !== undefined && file.ext === 'php'){
            var confirm_str = arrJsPopLabel['FORSECURITYREASONS'] + '<br/>' + file.name;
            MessagePopup.TipOne_warning(confirm_str);
            return;
        }
        file.path = response.filePaht;
        file.newfile_name = response.newfile_name;
        file.fileid = that.target.find("[tag="+that.prevfixstr+"newfile_name]").length+1;
        file.cloud_path = '';
        file.storage_location = 'local';
        file.isEncrypt = response.isEncrypt;
        file.imagefromtype = 'Computer';
        file.filerowindex = that.target.find("[tag="+that.prevfixstr+"newfile_name]").length+1;
        file.pre_button = response.pre_button; //预览按钮
        file.upload_from = 'PC'; //预览按钮
        that.addFile(file,'create')
    }
    that.uploadError = function (file, reason) {
        that.target.find("[name="+file.id+"]").find('span.state').text('上传出错');
    }
    that.uploadComplete = function (file) {
        that.target.find("[name="+file.id+"]").find('.progress').fadeOut();
    }
    /**
     * 错误触发函数
     * @param {'Q_TYPE_DENIED'|'Q_EXCEED_SIZE_LIMIT'|'F_EXCEED_SIZE'|'Q_EXCEED_NUM_LIMIT'|'F_DUPLICATE'} type 错误类型
     * @param num
     * @param file 文件对象
     * @return {boolean}
     */
    that.error = function (type , num, file) {
        (typeof num === "object" && num.id) && (file = num)
        var confirm_str;
        if (type === "Q_TYPE_DENIED"){
            confirm_str = arrJsPopLabel['FORSECURITYREASONS'] +'\n'+file.name;
        }else if(type === "Q_EXCEED_SIZE_LIMIT"){	//总文件大小
            confirm_str = arrJsPopLabel['FILEALLSIZECANNOTEXCEED']+that.opts.fileSizeLimit+'MB';
        }else if(type === "F_EXCEED_SIZE"){	//单文件大小
            confirm_str = arrJsPopLabel['FILESIZECANNOTEXCEED']+that.opts.fileSingleSizeLimit+"MB";
        }else if(type === "Q_EXCEED_NUM_LIMIT"){		//上传文件队列数量
            if(that.opts.fileNumLimit === 1){
                confirm_str = arrJsPopLabel['ONLYSINGLEFILEUPLOAD'];
            }else{
                confirm_str = arrJsPopLabel['Addthenumberofattachmentsisnotallowedtoexceed']+that.opts.fileNumLimit;
            }
        }else if(type === "F_DUPLICATE"){	//当前附件已在队列中，不能重复上传
            confirm_str = arrJsPopLabel['THECURRENTATTACHMENT'];
        }
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    that.all = function (type) {
        that.filerand = Math.floor(Math.random()*9999999);
        if (type === 'startUpload') {
            that.state = 'uploading';
        } else if (type === 'stopUpload') {
            that.state = 'paused';
        } else if (type === 'uploadFinished') {
            that.state = 'done';
        }
        if (that.state === 'uploading') {
            that.btn.text('暂停上传');
        } else {
            that.btn.text('开始上传');
        }
    }

    /**
     * 特殊，子类私有
     * @param file
     * @param type
     * @private
     */
    that._addFile = function (file, type) {

    }
    /**
     * 公共
     * @param file
     * @param type
     */
    that.addFile = function (file, type) {
        that._addFile(file, type)
    }

    that.webUpload = function (jqObj, options) {
        if (typeof WebUploader === 'undefined') {
            ld("<link>").attr({
                rel: "stylesheet",
                type: "text/css",
                href: "include/js/webuploader/css/bootstrap.min.css"
            }).appendTo("head");
        }
        that.init(jqObj.get(0),options)
    }
    that.setPopupJqObj = function (popupJqObj) {
        that.popupJqObj = popupJqObj
    }
    
    that.deleteFile = function (jsObj) {
        var id = ld(jsObj).data("id").toString(),
            file = that.uploader.getFile(id);
        if(id !== null && id !== "undefined") {
            if(file.id) {
                that.uploader.cancelFile(file)
                that.uploader.removeFile(file)
            }
            else {
                that.uploader.trigger( '_fileDequeued')
            }
        }
    }
}
function InitWebUpload_Carousel() {
    WebUploadClass.call(this);
    var that = this;

    that._addFile = function (file, type ) {
        if(typeof file.name === "undefined") {
            file.name = file.path.split('/').pop();
        }
        var imgInfoObj = that.popupJqObj.find('#carouselImgInfo'),
            path = (typeof file.newfile_name === "undefined") ? file.path : file.path + file.newfile_name;
        var html = `<div id="carouselImgInfoRow" class="uploader-list-row" filerowindex="${file.filerowindex}">`+
                        `<div class="el-image"><img src="${path}" alt="${file.source.title}"></div>` +
                        `<span class="item">${file.name}</span>` +
                        `<span class="webuploadDelbtn" tag="delete" style="padding-left:10px">` +
                            `<a href="javascript:void(0)" tag="delete"  filerowindex="${file.filerowindex}" data-id="${file.id}">${arrJsPopLabel['DELETE']}</a>` +
                        '</span>'+
                        '<span class="webuploadPrebtn" style="padding-left:10px">' +
                            `<a href="javascript:void(0);" onclick="ld(this).parents('#carouselImgInfo').find('img').click();">` +
                            `<span>${arrJsPopLabel['PREVIEW']}</span>` +
                        '</span>' +
                    '</div>';
        imgInfoObj.html(html);
        var popupObj = CrmPopup.getPopupObj('last');
        popupObj.carouselImgInfo.path = path;
        imgInfoObj.find('a[tag="delete"]').bind('click',function () {
            that.deleteFile(this);
            imgInfoObj.html('');
            popupObj.carouselImgInfo.path = '';
        });

        previewImage(imgInfoObj.find('.el-image img').get(0));
        imgInfoObj.css('display','');
    }
}
InitWebUpload_Carousel.prototype = Object.create(WebUploadClass.prototype);
InitWebUpload_Carousel.prototype.constructor = InitWebUpload_Carousel;