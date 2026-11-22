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
        ldAjaxNoProgresssync('index.php?module=Users&action=UsersAjax&file=qcloudEvent&second_action=get_temp_keys&ldencrypt=yes','',function(data){
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
        var articles_type = '';
        var canSetUploadType = "yes";//能否设置上传格式
        //ｚｘｍ　2021-0803 文章内容内容为附件的时候
        if(options.uitype==1109&&options.module == "Articles"&&options.inputFileName=="content_file") {
            canSetUploadType = "no";
            var popobj = CrmPopup.getPopupObj('last');
            var divid = popobj.divid;
            //ｚｘｍ　2021-0803 文章内容内容为附件的时候
            options.fileNumLimit = 1;
            articles_type = ld('#' + divid).find('input[name="articles_type"]').val();
            if(articles_type=="PDFArticles"){
                global_uploadfile_maxsize_mb = 20;
            }
        }
        //edit: xll 2023/07/25 BUG0069776 kfbcrm-带产品分录的单据-产品管理-添加附件和添加图片列，把添加改为添加附件，去掉设置允许上传的文件格式
        //edit: xll 2023/08/16 BUG0070625 kfbcrm-销售订单-产品管理-分录附件测试列，第一条单据需要有“设置允许上传的文件格式”的提示，后面的单据不需要
        if(options.uitype==1109&&options.isdetails == "yes"&&options.rowindex>1) {
            canSetUploadType = "no";
        }
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
        that.popupobj = '';
        if(options.popupobj!=undefined){
            that.popupobj = options.popupobj;
        }
        else{
            that.popupobj = CrmPopup.getPopupObj('last');
        }
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

        var pickerid = (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);

        var uploaderStrdiv = '';

        var tipsText = '';//上传附件说明，如支持格式等
        if(opts.uitype==105){
            opts.fileNumLimit = 1;
        }
        //产品管理增加“商城信息”区块增加预置字段“分享图片”,控制附件数量
        if(opts.uitype==1109&&opts.module=='Products'&&opts.inputFileName == 'appshareimage'){
            opts.fileNumLimit=1;
        }
        //自动上传
        if (opts.auto) {
            var attachments_tips = '';

            //相关信息 - 选择导入 opts.admin 等于 undeifined
            if(opts.fileNumLimit != undefined){
                attachments_tips = arrJsPopLabel['uploaduptoattachments'];
                if(!empty(attachments_tips)){
                    attachments_tips=attachments_tips.replace('{Num}',opts.fileNumLimit);
                }
            }else{
                opts.fileNumLimit = 1;
            }
            var choosefiletype='';
            
            if(opts.uitype==69 || opts.uitype==105||(opts.uitype==1109&&opts.module=='Products'&&opts.inputFileName == 'appshareimage'))
            {
                //edit:can 20210201 044439: （61mis.com/kfbtest）客户管理-联系人-新增/编辑；联系人模块的照片字段，添加图片附件时，可以选择txt、doc其他格式的文件；应只可选择图片格式的
                choosefiletype='accept="image/*"';
            }
            var multiple = 'multiple="multiple"';
            if(opts.module == "Articles"&&opts.uitype==1109){
                //zxm 2021-0803 获客文章 图片内容与pdf内容限制
                multiple = '';
                if(opts.articlesType=="image"){
                    choosefiletype='accept="image/*"';
                }else if(opts.articlesType=="PDF"){
                    choosefiletype='accept="application/pdf"';
                }
            }
            if (opts.mode && opts.mode == 'importImage'){
                uploaderStrdiv += '<div style="display: none">' ;
            }else {
                uploaderStrdiv += '<div class="">' ;
            }
            if(opts.allowedit!='no'){
                uploaderStrdiv += '<span id="' + pickerid + '" style="display:inline-flex;vertical-align:middle;" class="">'+
                '<div class="webuploader-pick">' +
                '<a class="icon-attachment icon-attachments inpb-attachments"></a>'+arrJsPopLabel['ADDINGATTACHMENTS']+'</div>' ;
            }
            //duan BUG20240109-86 20240110 将div的高度置为0,否则在小编辑,分录中,会出现添加按钮被遮挡的情况,原样式 height: 20px;
            uploaderStrdiv +=
                '<div id="rt_rt_1e1to47g01tqb17an119q1jhf1beb1" style="position: absolute; top: 0px; left: 0px; width: 57px; height: 0px; overflow: hidden; bottom: auto; right: auto;"><input type="file" name="file" '+choosefiletype+' class="webuploader-element-invisible" '+multiple+'><label style="opacity: 0; width: 100%; height: 100%; display: block; cursor: pointer; background: rgb(255, 255, 255);"></label></div>' ;

            if(opts.allowedit!='no'){
                uploaderStrdiv += '</span> ';
            }


            //zkt 0049950: （https://81mis.com/kfbcrm [^]）合同订单等模块新建/编辑界面没有显示“设置允许上传的文件格式”功能
            if(opts.uitype !=69&&opts.uitype!=105&&canSetUploadType=="yes"&&(!(opts.uitype==1109&&opts.module=='Products'&&opts.inputFileName == 'appshareimage')))
            {
                if(opts.admin == 'on' && opts.allowedit!='no'){
                    uploaderStrdiv += '<a style="vertical-align: middle;" href="javascript:void(0);" onclick="setAttachFileType(\'set\',\''+options.module+'\')">'+arrJsPopLabel['setthefileformat']+'</a>';
                }else if(opts.admin == 'off'){
                    uploaderStrdiv += '<a style="vertical-align: middle;" href="javascript:void(0);" onclick="setAttachFileType(\'view\',\''+options.module+'\')">'+arrJsPopLabel['viewthefileformat']+'</a>';
                }
            }

            if(!empty(attachments_tips)){
                tipsText = attachments_tips +'，'+arrJsPopLabel['MAXUPLOADSIZE'] + global_uploadfile_maxsize_mb +'MB';
            }else{
                tipsText = arrJsPopLabel['MAXUPLOADSIZE'] + global_uploadfile_maxsize_mb +'MB';
            }

            if(opts.uitype==69||opts.uitype==1108){
                tipsText += '，'+arrJsPopLabel['fileformat']+arrJsPopLabel['PICTUREFORMAT'];
                // zxm 2020-1104 获客文章封面图增加建议尺寸的提示
                if(opts.module == "Articles"){
                    tipsText += '，'+arrJsPopLabel['wxcovercontrol'];
                }
            }
            if(articles_type=="imageArticles"){
                tipsText = '只能上传单个图片,最大限制5M';
            }
            if(articles_type=="PDFArticles"){
                tipsText = '只能上传单个PDF,最大限制20M';
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
        uploaderStrdiv += '<div style="display:none" class="UploadhiddenInput" ><input type="hidden" value=""  name="'+prevfixstr+'file_num"></div>';
        if(target.find('.UploadhiddenInput').length>0){

        }
        else{
            target.append(uploaderStrdiv);
        }
        var list = target.find('.uploader-list'),
            btn = target.find('.webuploadbtn'),//手动上传按钮备用
            state = 'pending',
            hiddenInput = target.find('.UploadhiddenInput'),
            uploader;
        var jsonData = {
            fileList: []
        };
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

            // ljj 2024-11-8 XUQIU20241023-04 产品可以导入图片（郭良峰）
            if (opts.popupobj!=undefined && opts.popupobj != '' && opts.popupobj.popuptype != undefined &&  opts.popupobj.popuptype == 'importImage' && opts.mode == 'importImage'){
                delete opts.popupobj.importImageArr[id];
                removeFile(id);
                return false;
            }

            var popupobj=CrmPopup.getPopupObj("last");
            if(uitype==1109)
            {
                if(popupobj.delfileids==undefined)
                    popupobj.delfileids=[];
                popupobj.delfileids.push(target.find("[name="+prevfixstr+"fileid_" +id+"]").val());
            }
            else if(uitype==1108)//附件管理模块
            {
                if(popupobj.attachmentdelfileids==undefined)
                    popupobj.attachmentdelfileids=[];
                popupobj.attachmentdelfileids.push(target.find("[name="+prevfixstr+"fileid_" +id+"]").val());
            }
            else if(uitype==69)
            {
                if(popupobj.imagedelfileids==undefined)
                    popupobj.imagedelfileids=[];
                popupobj.imagedelfileids.push(target.find("[name="+prevfixstr+"fileid_" +id+"]").val());
            }
            removeFile(id);
            //zkt 20230822 XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据
            // 设置popupobj的jsondata
            if(that.popupobj!=undefined && that.popupobj != '' && that.popupobj.pagetype != undefined && that.popupobj.pagetype == 'create_edit_modulepage'&&opts.isdetails != undefined && opts.isdetails == 'yes'){
                delateDetailfiledata(that.popupobj,item,opts,id)
            }
        });
        var fileInputObj;
        if (!empty(options.isdetails)) {//分录
            fileInputObj = ld(item).find(' input[name=file]');
        }else{
            fileInputObj = ld('div[name='+options.inputFileName+'] input[name="file"]');
        }
        //删除附件
        var removeFile = function ( id ) {
            var popupobj=CrmPopup.getPopupObj("last");
            target = ld("#"+popupobj.divid+ ' [name='+options.inputFileName+']');
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
            if(!empty(opts.jsonData)){

                if(ld.isArray(opts.jsonData))
                {
                    var dataobj =opts.jsonData;//编辑或创建弹出层
                }
                else
                    var dataobj = eval('('+ opts.jsonData +')')?eval('('+ opts.jsonData +')'):JSON.parse(opts.jsonData);
                var k = 0;
                var fileSize = 0;
                if(dataobj != null){
                    ld.each(dataobj,function(i,list){
                        k = i + 1;
                        var obj ={};
                        statusMap = {};
                        idSuffix++;
                        fileSize += 2;
                        obj.id = k;
                        obj.name=list['file_name'];
                        obj.type=list['file_type'];
                        obj.size=list['file_size'];
                        obj.path=list['file_path'];
                        obj.newfile_name=list['newfile_name'] ;
                        obj.fileid=list['fileid'];
                        obj.filerowindex=k;
                        obj.storage_location=list['storage_location'];
                        obj.imagefromtype=list['imagefromtype'];
                        obj.upload_from=list['upload_from'];
                        obj.cloud_path=list['cloud_path'];
                        obj.isEncrypt=list['isEncrypt'];
                        obj.pre_button = list['pre_button'];    //预览按钮
                        if(opts.allowedit!='no')
                            obj.editbtn_display='yes';
                        //obj.source=this;
                        obj.flog=true;
                        /*obj.status = 'complete',
                            obj.getStatus = function(){
                                return '';
                            }
                        obj.statusText = '';
                        obj.setStatus = function(){
                            var prevStatus = statusMap[ this.id ];
                            typeof text !== 'undefined' && (this.statusText = text);
                            if ( status !== prevStatus ) {
                                statusMap[ this.id ] = status;
                                this.trigger( 'statuschange', status, prevStatus );
                            }
                        }*/
                        //添加附件显示
                        addFile( obj , 'edit');
                        //uploader.trigger( '_fileQueued');
                    });
                    target.find('[name='+prevfixstr+'file_num]').val(idSuffix);
                }
            }
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
            var popupobj=CrmPopup.getPopupObj('last');
            if (!empty(options.isdetails)){//分录
                // var  obj_arr = ld(item).find(" [name=Uploadthelist]").find(" .attachments-padL10");
                var  obj_arr = target.find(" [name=Uploadthelist]").find(" .attachments-padL10");
            }else{
                var  obj_arr=ld("#"+popupobj.divid+" [name="+fieldname+"]").find( " [name=Uploadthelist]").find(" .attachments-padL10");
            }
           //edit:can 20220126,界面有两个附件字段，第一个字段上传两个附件，第二字段没有附件，编辑 第一个字段再上传附件 ，无法保存成功
           // 49806: （http://xiaoshou360.com/KH/yingzhan [^] ）（苏州英展电子有限公司）在请款单（JK3480）和借款申请（ZDYBD07-9）中编辑单据上传附件之后点击保存，附件没有上传成功
           
           ld.each(obj_arr,function(){
            
              var id=parseInt(ld(this).attr("name"));
              if(id>=idSuffix)
              {
                idSuffix=id;
              }
           })
            idSuffix++;
            return idSuffix;
        };
        //添加附件
        var addFile = function(file,flag) {
            var json_file = '';
            var json_file_hidden = '';
            var list = target.find('.uploader-list');
            var pre_button = file.pre_button;
            if(flag == 'create'){
                var size = 0;
                if (file.size < 1024)
                    size = file.size + ' B';
                else if (file.size > 1024 && file.size < 1048576)
                    size = (file.size / 1024).toFixed(2) + ' KB';
                else if (file.size > 1048576)
                    size = (file.size / (1024 * 1024)).toFixed(2) + ' MB';
                target.find("[name="+file.id+"]").find('span.state').html('<span style="color:#798699;">('+size+')</span>');
                target.find("[name="+file.id+"]").find('span.webuploadDelbtn').html('<a href="javascript:void(0)">'+arrJsPopLabel['DELETE']+'</a>');//新增
                target.find("[name="+file.id+"]").find('span.webuploadDelbtn').attr("tag","create");

                // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（cos: 将按钮放入div中）
                target.find("[name="+file.id+"]").find('span.webuploadPrebtn').html(pre_button);
            }else{
                //编辑
                json_file += '<div name="' +file.id + '" class="attachments-padL10">'+
                    '<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+
                    '<span class="info" style="padding-left:5px">' + file.name + '</span>' +
                    '<span style="color:#798699;padding-left:5px">('+file.size+')</span>' +
                    '<span class="webuploadDelbtn" style="padding-left:5px">';
                if(file.editbtn_display=='yes'){
                    json_file +='<a href="javascript:void(0)" tag="deletefile" class="attachments-deleted" >'+arrJsPopLabel['DELETE']+'</a>'
                }
                json_file += '</span>' + '<span class="webuploadPrebtn" style="padding-left:5px">'+ pre_button + '</span>' + '</div>';
                list.append(json_file);
            }
			//chj 2020/12/21 43778: （https://61mis.com/WX/kh40954 [^]）（重庆维普资讯）点击合同订单（SO386）-相关信息中的附件管理，页面会一直转圈圈。
            var filename = file.name.replace(/\'/g,"");
            filename = filename.replace(/\"/g,"");
            filename = filename.replace(/ /g,"_");
			filename=filename.replace("+",'_');
			var specialstr='·—+·&%#@——={}【】?？';
			for(var i=0;i<specialstr.length;i++)
			{
				var ch=specialstr.substr(i,1);
				filename=filename.replace(ch,'_');
				
			}
            var imagefromtype = empty(file.imagefromtype)?'':file.imagefromtype;
            hiddenInput.append(
                '<input type="text" id="'+prevfixstr+'storage_location_' + file.id + '" name="'+prevfixstr+'storage_location_' + file.id + '" class="hiddenInput" value="' + file.storage_location + '" />' +
                '<input type="text" id="'+prevfixstr+'imagefromtype_' + file.id + '" name="'+prevfixstr+'imagefromtype_' + file.id + '" class="hiddenInput" value="' + imagefromtype + '" />' +
                '<input type="text" id="'+prevfixstr+'upload_from_' + file.id + '" name="'+prevfixstr+'upload_from_' + file.id + '" class="hiddenInput" value="' + file.upload_from + '" />' +
                '<input type="text" id="'+prevfixstr+'file_size_' + file.id + '" name="'+prevfixstr+'file_size_' + file.id + '" class="hiddenInput" value="' + file.size + '" />' +
                '<input type="text" id="'+prevfixstr+'file_name_' + file.id + '" name="'+prevfixstr+'file_name_' + file.id + '" class="hiddenInput" value="' + filename + '" />' +
                '<input type="text" id="'+prevfixstr+'file_path_' + file.id + '" name="'+prevfixstr+'file_path_' + file.id + '" class="hiddenInput" value="' +(file.path)  + '" />' +
                '<input type="text" id="'+prevfixstr+'cloud_path_' + file.id + '" name="'+prevfixstr+'cloud_path_' + file.id + '" class="hiddenInput" value="' + decodeURIComponent(file.cloud_path) + '" />' +
                '<input type="text" id="'+prevfixstr+'newfile_name_' + file.id + '" name="'+prevfixstr+'newfile_name_' + file.id + '" class="hiddenInput" value="' + file.newfile_name + '" />' +
                '<input type="text" id="'+prevfixstr+'file_type_' + file.id + '" name="'+prevfixstr+'file_type_' + file.id + '" class="hiddenInput" value="' + file.type + '" />' +
                '<input type="text" id="'+prevfixstr+'isEncrypt_' + file.id + '" name="'+prevfixstr+'isEncrypt_' + file.id + '" class="hiddenInput" value="' + file.isEncrypt + '" />'
            );
            hiddenInput.append('<input type="text" id="'+prevfixstr+'fileid_' + file.id + '" name="'+prevfixstr+'fileid_' + file.id + '" class="hiddenInput" value="' + file.fileid + '" />');
            
            //zkt 20230822 XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据
            // 设置popupobj的detailjsondata
            if(opts.popupobj!=undefined && opts.popupobj != '' && opts.popupobj.pagetype != undefined && opts.popupobj.pagetype == 'create_edit_modulepage'&&opts.isdetails != undefined && opts.isdetails == 'yes'){
                addDetailfiledata(opts.popupobj,item,opts,file,flag,filename,file.newfile_name);
            }else if (opts.popupobj!=undefined && opts.popupobj != '' && opts.popupobj.popuptype != undefined &&  opts.popupobj.popuptype == 'importImage' && opts.mode == 'importImage'){
                if (opts.popupobj.importImageArr == undefined){
                    opts.popupobj.importImageArr = {};
                    opts.popupobj.importImageAllArr = {};
                }
                if(empty(filename)){
                    filename = file.name.replace(/\'/g,"");
                    filename = filename.replace(/\"/g,"");
                    filename = filename.replace(/ /g,"_");
                }
                var newfile_name=file.newfile_name;
                newfile_name = newfile_name.replace(/\"/g,"");
                newfile_name = newfile_name.replace(/ /g,"_");
                var tmpupload_from = (file.upload_from!=undefined)?file.upload_from:'';
                var imagefromtype = (file.imagefromtype!=undefined)?file.imagefromtype:'';
                var tmpadddata = {
                    'filerowindex':file.filerowindex,
                    'pre_button':options.pre_button,
                    'file_name':filename,
                    'file_size':file.size,
                    'file_type':file.type,
                    'file_path':file.path,
                    'newfile_name':newfile_name,
                    'cloud_path':decodeURIComponent(file.cloud_path),
                    'fileid':file.fileid,
                    'storage_location':file.storage_location,
                    'imagefromtype':imagefromtype,
                    'upload_from':tmpupload_from,
                    'isEncrypt':file.isEncrypt
                };
                opts.popupobj.importImageArr[file.filerowindex] = tmpadddata;
                opts.popupobj.importImageAllArr[file.filerowindex] = tmpadddata;
            }
        };
        //【异步】将上传到COS的文件信息，保存进CRM临时文件表
        var saveIntoTempTable = function(rFile){
            ldAjax('index.php?module=Users&action=UsersAjax&file=qcloudEvent&second_action=save_into_temptable&fileinfo='+JSON.stringify(rFile),'',function (data) {
                DelProgressObjs();
                if (data.code == 1) {
                    //var credentials = data.result.key.credentials;
                }
            });
        };
        //上传进度条
        var uploadProgress  = function( file, percentage ) {

            var li = target.find("[name="+file.id+"]");
            var percent = li.find('.progress .progress-bar');
            // 避免重复创建
            if ( !percent.length ) {
                percent = ld('<div class="progress progress-striped active"><span class="text"></span>' +
                    '<div class="progress-bar" role="progressbar" style="width: 0%">' +
                    '</div>' +
                    '</div>').appendTo( li ).find('.progress-bar');
            }
            li.find('span.state').text('上传中');
            li.find(".text").text(Math.round(percentage * 100) + '%');
            percent.css( 'width', percentage * 100 + '%' );
        };
        //开始上传文件
        var fileQueued = function(file){
            // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（cos: 增加预览div框）
            list.append( '<div name="' +file.id + '" class="attachments-padL10">' +'<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+
                '<span class="item" style="padding-left:5px">' +file.name +'</span>' +
                '<span class="state" style="padding-left:5px">'+arrJsPopLabel['BEINGUPLOADED']+'...</span><span class="webuploadDelbtn" tag="" style="padding-left:5px"></span>' +
                '<span class="webuploadPrebtn" tag="" style="padding-left:5px"></span>' +
                '</div>' );
        };
        //不管成功或者失败，文件上传完成时触发 file {File}File对象
        var uploadComplete = function(file){
            target.find("[name="+file.id+"]").find('.progress').fadeOut();
        };
        //文件上传change事件
        var fileChange = function (that) {
            //@edit:liushuai,2020-12-25,reason:【ID1001220】附件管理等可以添加多附件
            ld.each(that.files, function(j, item) {
                   
                 var sizemb= item.size/1000/1000;
                 if(sizemb>global_uploadfile_maxsize_mb)
                 {
                    //edit:can 20210812 47432: (https://51mis.com/hy/0719yym/ [^])演示账号中，附件上传上限显示的是5M，实际上传23M的文件依旧可以上传
                    confirm_str = arrJsPopLabel['FILEALLSIZECANNOTEXCEED']+global_uploadfile_maxsize_mb+'MB';
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    return true;
                 }
                // var file = that.files[0];
                var file = item;
                if (!file) return;
                var popupobj=CrmPopup.getPopupObj('last');
        
                if(uitype==105&&(ld("#"+popupobj.divid+" [name=Uploadthelist]").children().length>0||j>=opts.fileNumLimit))
                {

                    RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['ONLYSINGLEFILEUPLOAD']);
                    return false;
                }
                //0049838: （https://81mis.com/kfbtest/index.php [^]）产品信息》新建》商城信息区块的附件字段，可选多个不同类型附件，应控制只可上传图片、且只能选一张；
                if((opts.uitype==1109&&opts.module=='Products'&&opts.inputFileName == 'appshareimage')&&(ld("#"+popupobj.divid+" [name=appshareimage] [name=Uploadthelist]").children().length>0||j>=opts.fileNumLimit))
                {

                    RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['ONLYSINGLEFILEUPLOAD']);
                    return false;
                }
                // var cos = new COS({
//                getAuthorization: getAuthorization,
//            });
//             file.name = file.name.replace(/——/g, "");
                //超过1M就执行分块上传
                //if (file.size > 1024 * 1024) {
                /* var filename=file.name.replace("+",'_');
                 filename=file.name.replace("—",'_');
                 filename=file.name.replace("·",'_');*/
                //43170: （本地crm）附件管理-附件-预览；版本8.2.9；图片带字符‘“·&%#无法预览；带或者不带特殊字符的doc，xlsx，xls的文件都无法预览；下载正常 带中文符号……的文件，预览丢失。
                var filename=file.name.replace("+",'_');
                var specialstr='·—+·&%#@——={}【】?？';
                for(var i=0;i<specialstr.length;i++)
                {
                    var ch=specialstr.substr(i,1);
                    filename=filename.replace(ch,'_');

                }
                filename=filename.replace(/\s+/g,"_");//替换空格
                var fileNameArr =filename.split('.');// file.name.split('.');
                //edit:can 2020-11-02 兖矿集团有限公司煤液化及煤化工国家重点实验室2020.11.10-2021.11.9期刊+经纶合作协议.docx
                var subfilename=fileNameArr[fileNameArr.length-1];//文件后缀名称

                var newFileName = fileNameArr[0]+'_'+Date.parse(new Date())+'_'+Math.ceil(Math.random()*1000)+'.'+subfilename;
                //edit: xll 2023/08/16 BUG0070631 入库单“附件”字段设置允许上传的文件格式为doc后，没有生效，仍然可以上传xls文件
                ldAjaxHtmlNoProgress("index.php?module=Users&action=UsersAjax&file=File_SetName&filename="+encodeURIComponent(file.name)+'&formmodule='+opts.module+'&uitype='+opts.uitype,{},function(result){
                    var dataobj = eval('('+ result +')')?eval('('+ result +')'):JSON.parse(result);
                    if(dataobj.type == 3 ){
                        //41487: （61mis.com/kfbcrm）单据新建/编辑界面，附件字段设置允许上传的文件格式添加附件时，其他格式也可以上传（附件管理模块测试）
                        var confirm_str = arrJsPopLabel['FORSECURITYREASONS'] +'\n'+file.name;
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        return false;
                    }
                  
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
                            // console.log('onHashProgress', JSON.stringify(progressData));
                        },
                        onProgress: function (progressData) {
                            //console.log(JSON.stringify(progressData));
                            //console.log('onProgress', JSON.stringify(progressData));
                            uploadProgress(file,progressData.percent)
                        },
                    }, function (err, data) {
                        //console.dir(err || data);
                        if(data.statusCode === 200){
                            var locationArr = data.Location.split(encodeURIComponent(newFileName));
                            file.path =cosConfig.DirName;// locationArr[0];
                            file.cloud_path=data.Location;

                            file.newfile_name = newFileName;
                            file.storage_location = 'cos';
                            file.upload_from = 'pc';
                            //给特殊input赋值
                            setInputFileName(file.id);
                            //保存进临时表
                            saveIntoTempTable(data);
                            //上传完成隐藏进度条
                            uploadComplete(file);
                            //添加文件信息

                            //addFile(file,'create');
                            //加密
                            encrypt(file);
                            // @edit:dong @date:2020/07/13 @reason: 社交推广新建编辑页面第三步处理上传的图片
                            var popupobj = CrmPopup.getPopupObj('last');
                            if(popupobj.module == 'SocialPromotion'){
                                showPicture(data);
                            }
                        }
                    });

                })
            })

        }
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
                file.imagefromtype = 'Computer';
                file.filerowindex=file.id;
                file.pre_button = response.pre_button;  //预览按钮
                file.pre_button = response.pre_button;  //预览按钮
                addFile(file,'create');
            })
        };
        //```````定义内部函数``结束
        //```````在页面DOM加载完毕后，自动执行下面的代码
        //文件序号
        idSuffix = 1;
        //给隐藏的input[name="file"]增加change事件
        if (!empty(options.isdetails)) {//分录
            ld(item).find(' input[name=file]').on('change',function (e) {
                //重新给target赋值，否则联系人附件和图片两个字段会互相干扰
                target = ld(item);
                fileChange(this);
            });
        }else{
            ld('div[name='+options.inputFileName+'] input[name="file"]').on('change',function (e) {
                //重新给target赋值，否则联系人附件和图片两个字段会互相干扰
                target = ld('div[name='+options.inputFileName+']');
                fileChange(this);
            });
        }

        if (opts.dnd  && opts.popupobj){
            var dndobj = ld('#'+opts.popupobj.divid +' '+opts.dnd);
            // 阻止默认行为
            dndobj.off('dragenter dragover').on('dragenter dragover', function (e) {
                e.preventDefault();
                e.stopPropagation();
            });

            dndobj.off('dragleave').on('dragleave', function (e) {
                e.preventDefault();
                e.stopPropagation();
            });

            // 处理文件拖拽
            dndobj.off('drop').on('drop', function (e) {
                e.preventDefault();
                e.stopPropagation();
                var files = e.originalEvent.dataTransfer.files;
                fileChange({'files':files});
            });
        }

        //显示已有的附件
       
          cos = new COS({
                getAuthorization: getAuthorization,
            });
        uploadReady();
        
    };
    ld.fn.powerWebUploadCos = function (options) {
        var ele = this;
        //引入PC端控件样式
        var popupobj=CrmPopup.getPopupObj('last');
    //    alert(ld("#"+popupobj.divid+ ' [name='+options.inputFileName+']').length);
        var casspath_btn = "include/js/webuploader/css/webuploader.css";
        ld("<link>").attr({ rel: "stylesheet", type: "text/css", href: casspath_btn }).appendTo("head");
        var casspath_loader = "include/js/webuploader/css/bootstrap.min.css";
        ld("<link>").attr({ rel: "stylesheet", type: "text/css", href: casspath_loader }).appendTo("head");
        initWebUpload(ele,options);
        if (!empty(options.isdetails)){//分录
            ld(ele).find('.webuploader-pick').first().on('click',function(){
                ld(ele).find(' input[name="file"]').trigger('click');
            });
        }else if (options.inputFileName != 'ImportImage' && options.mode != 'ImportImage'){
            ld("#"+popupobj.divid+ ' [name='+options.inputFileName+']').find('.webuploader-pick').first().on('click',function(){

                ld("#"+popupobj.divid+ ' [name='+options.inputFileName+'] input[name="file"]').trigger('click');
            });
        }
    };
})(ld, window);
