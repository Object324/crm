var fileCount = 1;
(function (ld, window) {
     
     
  
	function initWebUpload(item, options) {
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
		//edit: xll 2023/07/25 BUG0069776 kfbcrm-带产品分录的单据-产品管理-添加附件和添加图片列，把添加改为添加附件，去掉设置允许上传的文件格式式
		//edit: xll 2023/08/16 BUG0070625 kfbcrm-销售订单-产品管理-分录附件测试列，第一条单据需要有“设置允许上传的文件格式”的提示，后面的单据不需要
		if(options.uitype==1109&&options.isdetails == "yes"&&options.rowindex>1) {
			canSetUploadType = "no";
		}
		if (!WebUploader.Uploader.support()) {
            var error = "上传控件不支持您的浏览器！请尝试升级flash版本或者使用Chrome引擎的浏览器";
            if (window.console) {
                window.console.log(error);
            }
            $(item).text(error);
            return;
        }
       
		 //创建默认参数
        var defaults = {
            auto:true,	//自动上传
            onAllComplete: function (event) { },	//当所有file都上传后执行的回调函数
            onComplete: function (event) { },	//每上传一个file的回调函数
			// @edit:dong @date:2020/07/20 @reason: 数量修改为100 https://www.tapd.cn/20699121/prong/stories/view/1120699121001000921
            fileNumLimit: 100,	//验证文件总数量, 超出则不允许加入队列
            fileSizeLimit: 0,	//验证文件总大小是否超出限制, 超出则不允许加入队列。
            fileSingleSizeLimit: global_uploadfile_maxsize_mb,	//验证单个文件大小是否超出限制, 超出则不允许加入队列
            PostbackHold: false
        };

		var prevfixstr=options.inputFileName+"-";//列头
        var uitype=options.uitype;
        var that=this;
        that.popupobj = '';
        if(options.popupobj!=undefined){
            that.popupobj = options.popupobj;
        }
        var fieldname=options.inputFileName;
        this.filerand=parseInt(Math.random()*999999);
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
		var target = $(item);//容器

        var pickerid = (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);

		var uploaderStrdiv = '';
        
        var tipsText = '';//上传附件说明，如支持格式等
        if(opts.uitype==105){
            opts.fileNumLimit=1;
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
			//生成上传按钮
			if (opts.mode && opts.mode == 'importImage'){
				uploaderStrdiv += '<div style="display:none;">' ;
			}else {
				uploaderStrdiv += '<div >' ;
			}
			if(opts.allowedit!='no'){
				uploaderStrdiv +=
				'<span id="' + pickerid + '" style="display:inline-flex; vertical-align: middle;" class="b">'+'<a class="icon-attachment icon-attachments inpb-attachments"></a>'+arrJsPopLabel['ADDINGATTACHMENTS']+'</span>';
			}
			/*
                if(opts.uitype==69)
                {
                    //0031368:联系人新增编辑界面：添加照片后面的可以上传的文件格式应该只有管理员才能看到
					if(opts.admin == 'on') uploaderStrdiv += '<span style="vertical-align: middle;">jpg,jpeg,bmp,png.icon,gif,dwg,psd,ico</span>';
                }
                */
                //设置允许上传的文件格式
                //zkt 0049950: （https://81mis.com/kfbcrm [^]）合同订单等模块新建/编辑界面没有显示“设置允许上传的文件格式”功能
				//wyt 220706_XUQIU1000243_附件字段设置允许上传的文件格式新增模块控制
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
                    if(options.module == "Articles"){
                        opts.fileNumLimit = 1;
                    }
                    tipsText += '，'+arrJsPopLabel['fileformat']+arrJsPopLabel['PICTUREFORMAT'] ;
                    // zxm 2020-1104 获客文章封面图增加建议尺寸的提示
                    if(opts.module == "Articles"){
						tipsText += '，'+arrJsPopLabel['wxcovercontrol'];
					}
                }
				//ｚｘｍ　2021-0803 文章内容内容为附件的时候
				if(articles_type=="imageArticles"){
					tipsText = '只能上传单个图片,最大限制5M';
				}
				if(articles_type=="PDFArticles"){
					tipsText = '只能上传单个PDF,最大限制20M';
				}
                //zkt 产品管理“分享图片”,tip信息
                if(opts.uitype==1109&&opts.module=='Products'&&opts.inputFileName == 'appshareimage'){
                    tipsText='最多上传1个附件，文件格式：jpg，jpeg，bmp，png.icon，gif，dwg，psd，ico，建议图片尺寸比例宽*高：630*500';
                }

				if(opts.special_ins != undefined && opts.special_ins != ''){
					uploaderStrdiv += '<span id="limitmsg" class="E_red_txt" style="vertical-align: middle;">'+opts.special_ins+'</span>';
				}
                // ld("b[tag='attachmentHelp_"+opts.uitype+"'] #tip_info").text(tipsText);
                // ld("b[tag='attachmentHelp_"+opts.uitype+"']").addClass('tip-items-list');
                ld("[tag='attachmentHelp_"+opts.uitype+"']").attr('data-tip', tipsText);
                ld("[tag='attachmentHelp_"+opts.uitype+"']").attr('data-direction', 'top');
                ld("[tag='attachmentHelp_"+opts.uitype+"']").attr('data-type', 'position');
				//@edit:ljj,2023-08-03,reason:BUG0070472 kfbcrm-销售订单-单据列表界面点击小编辑附件字段，说明符号应有浮显
				// tooltip('.tip-items-list', {transition: true, time: 200});
				uploaderStrdiv +='</div>'+
				'<div name="Uploadthelist" class="uploader-list"></div>';
        } else {
		//手动上传
            uploaderStrdiv += 
				'<div  class="uploader-list"></div>' +
				'<div class="btns">' +
				'<div id="' + pickerid + '">'+arrJsPopLabel['BROWSETHEFILE']+'</div>' +
				'<button class="webuploadbtn">'+arrJsPopLabel['STARTUPLOADING']+'</button>' +
				'</div>';
        }
		uploaderStrdiv += '<div style="display:none" class="UploadhiddenInput" ><input type="hidden" value=""  name="'+prevfixstr+'file_num"></div>';
		//zkt 20240118 BUG0077408 kfbcrm-采购订单-新建-选择源单“采购询价单CGXJ7”，分录中图片字段引用的是询价单的表头图片字段，选择源单后带过了了五行（源单中只有三行分录）
		if(target.find('.UploadhiddenInput').length>0){

		}
		else{
			target.append(uploaderStrdiv);
		}
		//已有的附件列表
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
        var popupobj=CrmPopup.getPopupObj("last");
        if(that.popupobj == undefined || that.popupobj == ''){
            that.popupobj = popupobj;
        }
      	if(options.uitype==1109&&articles_type!=''){
      		//zxm  2021-0803 获客文章内容特殊判断
			var accept = {
				title: 'Images',
				extensions: 'jpg,jpeg,bmp,png,icon,gif,dwg,psd,ico',
				mimeTypes: 'image/*'
			};
			if(articles_type=="PDFArticles"){
				accept = {
					title: 'PDF',
					extensions: 'pdf',
					mimeTypes: 'application/pdf'
				};
			}
			if(iscompress)
			{


				var webuploaderoptions = ld.extend({
					swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
					server: global_flash_fileattachmentphp+'&frommodule='+popupobj.module+"&filerand="+that.filerand,	 // 文件接收服务端。
					deleteServer:global_flash_delfileattachmentphp+'&frommodule='+popupobj.module,	 // 文件删除服务端。
					pick: '#'+pickerid,	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
					resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
					id:0,
					chunked: true,	//是否要分片处理大文件上传
					chunkSize:2*1024*1024,	//分片大小，默认2M
					accept: accept
				},opts);
			}
			else
			{

				var webuploaderoptions = ld.extend({
					swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
					server: global_flash_fileattachmentphp+'&frommodule='+popupobj.module+"&filerand="+that.filerand,	 // 文件接收服务端。
					deleteServer:global_flash_delfileattachmentphp,	 // 文件删除服务端。
					pick: '#'+pickerid,	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
					resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
					compress:false,
					chunked: true,	//是否要分片处理大文件上传
					id:0,
					chunkSize:2*1024*1024,	//分片大小，默认2M
					accept: accept
				},opts);
			}
		}else
        if(options.uitype!=undefined&&(options.uitype==69||options.uitype==105))
        {
            
            if(iscompress)
            {
                
                
                var webuploaderoptions = ld.extend({
        				swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
        				server: global_flash_fileattachmentphp+'&frommodule='+popupobj.module+"&filerand="+that.filerand,	 // 文件接收服务端。
        				deleteServer:global_flash_delfileattachmentphp+'&frommodule='+popupobj.module,	 // 文件删除服务端。
        				pick: '#'+pickerid,	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
        				resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
                        id:0,
        				chunked: true,	//是否要分片处理大文件上传
        				chunkSize:2*1024*1024,	//分片大小，默认2M
                         accept: { // 只允许选择图片文件。
                            title: 'Images',
                            extensions: 'jpg,jpeg,bmp,png,icon,gif,dwg,psd,ico',
                            mimeTypes: 'image/*'
                        }
        			},opts);
            }
             else
             {
                
                    var webuploaderoptions = ld.extend({
    				swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
    				server: global_flash_fileattachmentphp+'&frommodule='+popupobj.module+"&filerand="+that.filerand,	 // 文件接收服务端。
    				deleteServer:global_flash_delfileattachmentphp,	 // 文件删除服务端。
    				pick: '#'+pickerid,	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
    				resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
                    compress:false,
    				chunked: true,	//是否要分片处理大文件上传
                    id:0,
    				chunkSize:2*1024*1024,	//分片大小，默认2M
                     accept: { // 只允许选择图片文件。
                        title: 'Images',
                        extensions: 'jpg,jpeg,bmp,png,icon,gif,dwg,psd,ico',
                        mimeTypes: 'image/*'
                    }
    			},opts);
             }
           
   
        }
        //产品管理增加“商城信息”区块增加预置字段“分享图片”,控制上传图片类型
        else if(options.uitype==1109&&options.module=='Products'&&opts.inputFileName == 'appshareimage'){
            var accept = {
				title: 'Images',
				extensions: 'jpg,jpeg,bmp,png,icon,gif,dwg,psd,ico',
				mimeTypes: 'image/*'
			};
			if(iscompress)
			{


				var webuploaderoptions = ld.extend({
					swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
					server: global_flash_fileattachmentphp+'&frommodule='+popupobj.module+"&filerand="+that.filerand,	 // 文件接收服务端。
					deleteServer:global_flash_delfileattachmentphp+'&frommodule='+popupobj.module,	 // 文件删除服务端。
					pick: '#'+pickerid,	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
					resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
					id:0,
					chunked: true,	//是否要分片处理大文件上传
					chunkSize:2*1024*1024,	//分片大小，默认2M
					accept: accept
				},opts);
			}
			else
			{

				var webuploaderoptions = ld.extend({
					swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
					server: global_flash_fileattachmentphp+'&frommodule='+popupobj.module+"&filerand="+that.filerand,	 // 文件接收服务端。
					deleteServer:global_flash_delfileattachmentphp,	 // 文件删除服务端。
					pick: '#'+pickerid,	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
					resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
					compress:false,
					chunked: true,	//是否要分片处理大文件上传
					id:0,
					chunkSize:2*1024*1024,	//分片大小，默认2M
					accept: accept
				},opts);
			}
        }
        else
        {
           

            if(iscompress)
            {
                
                    var webuploaderoptions = ld.extend({
    				swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
    				server: global_flash_fileattachmentphp+'&frommodule='+popupobj.module+"&filerand="+that.filerand,	 // 文件接收服务端。
    				deleteServer:global_flash_delfileattachmentphp,	 // 文件删除服务端。
    				pick: '#'+pickerid,	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
    				resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
                     
    				chunked: true,	//是否要分片处理大文件上传
    				chunkSize:2*1024*1024	//分片大小，默认2M
    			},opts);
            }
            else
            {
                var webuploaderoptions = ld.extend({
    				swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
    				server: global_flash_fileattachmentphp+'&frommodule='+popupobj.module+"&filerand="+that.filerand,	 // 文件接收服务端。
    				deleteServer:global_flash_delfileattachmentphp,	 // 文件删除服务端。
    				pick: '#'+pickerid,	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
    				resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
                    compress:false,
    				chunked: true,	//是否要分片处理大文件上传
    				chunkSize:2*1024*1024	//分片大小，默认2M
    			},opts);
            }

             
        }
        webuploaderoptions.duplicate=true;
		//创建WebUploader实例
		var uploader = WebUploader.create(webuploaderoptions);
        
		//队列事件
		if (opts.auto) {
            uploader.on('fileQueued', function (file) {
                file.filerowindex=list.find("[tag="+prevfixstr+"_upload]").length+1;
				var uploadurl = global_flash_fileattachmentphp+'&frommodule='+popupobj.module+"&filerand="+that.filerand
					+"&pagetype=" + options.pagetype;
				uploader.options.server =uploadurl;
				uploader.options.encryptyurl ='yes';
				// edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（新增编辑界面，新增附件时增加预览span框）
				list.append( '<div style="display:none"tag="'+prevfixstr+'_upload"></div> <div name="' +file.filerowindex + '" class="attachments-padL10" tag="'+file.id+'">' +'<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+
					'<span class="item" style="padding-left:5px">' +file.name +'</span>' +
					'<span class="state" style="padding-left:5px">'+arrJsPopLabel['BEINGUPLOADED']+'...</span><span' +
					' class="webuploadDelbtn" tag="" style="padding-left:5px"></span>' +
					'<span class="webuploadPrebtn" tag="" style="padding-left:5px"></span>' +
				'</div>' );
                uploader.upload();
            });
        } else {
            uploader.on('fileQueued', function (file) {
                file.filerowindex=setFileId();
				//zkt 20231012 XUQIU1001341 SQL注入
				uploadurl= cls_encryptyurl.Puyoung_EncryptyFileurl(global_flash_fileattachmentphp+'&frommodule='+popupobj.module+"&filerand="+that.filerand
					+"&pagetype=" + options.pagetype,'filename='+file.name);
				//edit: xll 2023/10/06 BUG0072908 客户管理（包括但不限于，比如报价单、销售订单等等）数据列表，无法通过快速编辑添加视频附件。
                uploader.options.server =uploadurl;
				uploader.options.encryptyurl ='yes';

				// edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（新增编辑界面，新增附件时增加预览div框）
                $list.append('<div name="' +$(item)[0].id + file.filerowindex + '" class="item" tag="'+file.id+'">' +
                    '<span class="webuploadinfo">' +prevfixstr+ file.name + '</span>' +
                    '<span class="webuploadstate">'+arrJsPopLabel['WAITINGFORUPLOADING']+'...</span>' +
                    '<div class="webuploadDelbtn">'+arrJsPopLabel['DELETE']+'</div>' +
					'<div class="webuploadPrebtn" tag="" style="padding-left:5px"></div>' +
					'</div>');
            });
        }

		//编辑  队列显示
		uploader.on('ready', function () {


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
						fileCount++;  
						fileSize += 2;
						obj.id = k;
                      
						obj.name=list['file_name'];  
						obj.type=list['file_type'];  
						obj.size=list['file_size'];  
						obj.path=list['file_path']; 
                        obj.newfile_name=list['newfile_name'] ;
                        obj.fileid=list['fileid'];
                        obj.cloud_path=list['cloud_path'];
                        obj.storage_location=list['storage_location'];
                        obj.imagefromtype=list['imagefromtype'];
                        obj.isEncrypt=list['isEncrypt'];
                        //obj.cloud_path
                        obj.filerowindex=k;
						obj.source=this;  
						obj.flog=true;  
						obj.status = 'complete',  
						obj.getStatus = function(){  
							return '';  
						}
						obj.version = WebUploader.Base.version;  
						obj.statusText = '';  
						obj.setStatus = function(){  
							var prevStatus = statusMap[ this.id ];
							typeof text !== 'undefined' && (this.statusText = text);
							if ( status !== prevStatus ) {
								statusMap[ this.id ] = status;
								this.trigger( 'statuschange', status, prevStatus );
							}
						}
						if(list['pre_button']){
							obj.pre_button = list['pre_button'];
						}
						//预览按钮
						if(opts.allowedit!='no')
							obj.editbtn_display='yes';
                        //添加附件显示
						addFile( obj , 'edit');
						uploader.trigger( '_fileQueued');
					});
				  
					target.find('[name='+prevfixstr+'file_num]').val(fileCount);
				}
			}
			//alert(fileCount);
			WebUploader.Base._idSuffix=fileCount;
		});

		// 文件上传过程中创建进度条实时显示。
		uploader.on( 'uploadProgress', function( file, percentage ) {
		   file.filerowindex=setFileId();
			var li = target.find("[name="+file.filerowindex+"]"),percent = li.find('.progress .progress-bar');
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
		});

		//当文件上传成功时触发file {File}File对象  response {Object}服务端返回的数据 
		uploader.on( 'uploadSuccess', function(file,response) {

			if (response.state == "error") {
                target.find("[name="+file.filerowindex+"]").find('span.state').text(response.message);
            } else {
				if (!empty(options.isdetails)){
				//item == #SalesOrder_pagerecord1100 tr[rowindex=3] [detailfieldname=sf8004] div[name=sf8004]
					$(item).find(" .webuploader-pick").html('<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+arrJsPopLabel['CONTINUEADDING']);//分录
				}else{
					ld('div[name='+fieldname+'] .webuploader-pick').html('<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+arrJsPopLabel['CONTINUEADDING']);//Liver 上传附件成功后，更改按钮名称为 继续添加
				}

				file.path= response.filePaht;
                file.newfile_name=response.newfile_name;
                file.fileid=response.fileid;
                file.cloud_path='';
                file.storage_location='local';
				file.isEncrypt = response.isEncrypt;
				file.imagefromtype='Computer';
                file.filerowindex=setFileId();
				file.pre_button = response.pre_button; //预览按钮
				addFile( file , 'create');
				setInputFileName(file.filerowindex);
				//社交推广图片上传后展示
				if(popupobj.module =='SocialPromotion'){
					showPicture(response);
				}
				if(popupobj.module == 'Settings' && popupobj.SettingsType == 'Templateprint'){
					TemplateprintList.uploadSuccessEvent();
				}
			}
		});

		//当文件上传出错时触发file {File}File对象  reason {String}出错的code 
		uploader.on( 'uploadError', function(file,reason) {
			target.find("[name="+file.filerowindex+"]").find('span.state').text('上传出错');
		});

		//不管成功或者失败，文件上传完成时触发 file {File}File对象
		uploader.on( 'uploadComplete', function( file ) {
			target.find("[name="+file.filerowindex+"]").find('.progress').fadeOut();
		});

		//出错 提示
		uploader.on("error",function ( type , num, file ){

			let confirm_str;
			(typeof num === "object" && num.id) && (file = num)
			if (type=="Q_TYPE_DENIED"){
				confirm_str = arrJsPopLabel['FORSECURITYREASONS'] +'\n'+file.name;
			}else if (type == 'Q_FILE_SZIE_EMPTY'){
				confirm_str = '"'+file.name+'"'+arrJsPopLabel['FILESIZEISEMPTYTIP'];
			}
			else if(type=="Q_EXCEED_SIZE_LIMIT"){	//总文件大小
				confirm_str = arrJsPopLabel['FILEALLSIZECANNOTEXCEED']+fileSizeLimit+'MB';
			}else if(type=="F_EXCEED_SIZE"){	//单文件大小
				confirm_str = arrJsPopLabel['FILESIZECANNOTEXCEED']+fileSingleSizeLimit+"MB";
			}else if(type == "Q_EXCEED_NUM_LIMIT"){		//上传文件队列数量
				if(opts.fileNumLimit == 1){
					confirm_str = arrJsPopLabel['ONLYSINGLEFILEUPLOAD'];
				}else{
					confirm_str = arrJsPopLabel['Addthenumberofattachmentsisnotallowedtoexceed']+opts.fileNumLimit;
				}
			}else if(type == "F_DUPLICATE"){	//当前附件已在队列中，不能重复上传
				confirm_str = arrJsPopLabel['THECURRENTATTACHMENT'];	
			}
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		});

		uploader.on('all', function (type) {
            if (type === 'startUpload') {
                state = 'uploading';
            } else if (type === 'stopUpload') {
                state = 'paused';
            } else if (type === 'uploadFinished') {
                state = 'done';
                that.filerand=parseInt(Math.random()*9999999);
               // uploader.server=global_flash_fileattachmentphp+'&frommodule='+popupobj.module+"&filerand="+that.filerand;
            }
            if (state === 'uploading') {
                btn.text('暂停上传');
            } else {
                btn.text('开始上传');
            }
        });

		//多文件点击上传的方法
        btn.on('click', function () {
            if (state === 'uploading') {
                uploader.stop();
            } else {
                uploader.upload();
            }
        });

		//删除时执行的方法
        uploader.on('fileDequeued', function (file) {

			removeFile(file.filerowindex);
		});
		function getFileId()
        {
            return target.find("[tag="+prevfixstr+"-newfile_name");
        }
        function setFileId(){
          
          return   target.find("[tag="+prevfixstr+"-newfile_name]").length+1;
            
        }
		//删除附件
		function removeFile( id ) {
		  
		      target.find("[name="+id+"]").remove();
              target.find("[name="+prevfixstr+"file_name_"+id+"]").remove();
              target.find("[name="+prevfixstr+"file_size_"+id+"]").remove();
              target.find("[name="+prevfixstr+"file_path_"+id+"]").remove();
              target.find("[name="+prevfixstr+"file_type_"+id+"]").remove();
		
			setInputFileName(id);
		}
		
		//添加获取附件名称inputFileName
		function setInputFileName(filenum){
		 
	      target.find('[name='+prevfixstr+'file_num]').val(filenum);
		  
		}
		//添加附件
		function addFile( file , flag) {
	 
		//alert(uploader.getFiles().length);
			var json_file = '';
			var json_file_hidden = '';
			var list = target.find('.uploader-list');
			var preview_button = file.pre_button != undefined?file.pre_button:'';

			if(flag == 'create'){
				var size = 0;
				if (file.size < 1024)
					size = file.size + ' B';
				else if (file.size > 1024 && file.size < 1048576)
					size = (file.size / 1024).toFixed(2) + ' KB';
				else if (file.size > 1048576)
					size = (file.size / (1024 * 1024)).toFixed(2) + ' MB';
				target.find("[name="+file.filerowindex+"]").find('span.state').html('<span style="color:#798699;">('+size+')</span>');
				// edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（新增编辑界面，新增附件时将预览按钮放入预览div/span框）
				target.find("[tag="+file.id+"]").find('span.webuploadPrebtn').html(preview_button);

				target.find("[name="+file.filerowindex+"]").find('span.webuploadDelbtn').html('<a href="javascript:void(0)">'+arrJsPopLabel['DELETE']+'</a>');//删除
				target.find("[name="+file.filerowindex+"]").find('span.webuploadDelbtn').attr("tag","create");
			}else{
			     //编辑
				// edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（编辑界面对原有的附件增加预览按钮）
				json_file += '<div style="display:none" tag="'+prevfixstr+'_upload"></div> <div name="' +file.filerowindex + '" class="attachments-padL10" tag="'+file.id+'">'
					+'<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'
					+'<span class="info" style="padding-left:5px">' + file.name + '</span><span style="color:#798699;padding-left:5px">('+file.size+')</span><span class="webuploadDelbtn" tag="create" style="padding-left:5px">';
				if(file.editbtn_display=='yes'){
					json_file +='<a href="javascript:void(0)" tag="deletefile" class="attachments-deleted" >'+arrJsPopLabel['DELETE']+'</a>'
				}
				json_file += '</span><span class="webuploadPrebtn" tag="" style="padding-left:5px">' +preview_button+'</span>' + '</div>';
				list.append(json_file);
			}
			var filename = file.name.replace(/\'/g,"");
			 filename = filename.replace(/\"/g,"");
			filename = filename.replace(/ /g,"_");
            var newfile_name=file.newfile_name;
          	 newfile_name = newfile_name.replace(/\"/g,"");
			newfile_name = newfile_name.replace(/ /g,"_");
			var imagefromtype = empty(file.imagefromtype)?'':file.imagefromtype;
			hiddenInput.append('<input type="text" id="'+prevfixstr+'file_size_' + file.filerowindex + '" name="'+prevfixstr+'file_size_' + file.filerowindex + '" class="hiddenInput" value="' + file.size + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'file_name_' + file.filerowindex + '"  name="'+prevfixstr+'file_name_' + file.filerowindex + '" class="hiddenInput" value="' + filename + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'file_path_' + file.filerowindex + '" name="'+prevfixstr+'file_path_' + file.filerowindex + '" class="hiddenInput" value="' + file.path + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'file_type_' + file.filerowindex + '" name="'+prevfixstr+'file_type_' + file.filerowindex + '" class="hiddenInput" value="' + file.type + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'newfile_name_' + file.filerowindex + '" tag="'+prevfixstr+'-newfile_name"    name="'+prevfixstr+'newfile_name_' + file.filerowindex + '" class="hiddenInput" value="' + newfile_name + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'fileid_' + file.filerowindex + '" name="'+prevfixstr+'fileid_' + file.filerowindex + '" class="hiddenInput" value="' + file.fileid + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'storage_location_' + file.filerowindex + '" name="'+prevfixstr+'storage_location_' + file.filerowindex + '" class="hiddenInput" value="' + file.storage_location + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'imagefromtype_' + file.filerowindex + '" name="'+prevfixstr+'imagefromtype_' + file.filerowindex + '" class="hiddenInput" value="' + imagefromtype + '" />');
            hiddenInput.append('<input type="text" id="'+prevfixstr+'cloud_path_' + file.filerowindex + '" name="'+prevfixstr+'cloud_path_' + file.filerowindex + '" class="hiddenInput" value="' + decodeURIComponent(file.cloud_path) + '" />');
			hiddenInput.append('<input type="text" id="'+prevfixstr+'isEncrypt_' + file.filerowindex + '" name="'+prevfixstr+'isEncrypt_' + file.filerowindex + '" class="hiddenInput" value="' + file.isEncrypt + '" />');
            
            //zkt 20230822 XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据
            // 设置popupobj的detailjsondata
            if(opts.popupobj!=undefined && opts.popupobj != '' && opts.popupobj.pagetype != undefined && opts.popupobj.pagetype == 'create_edit_modulepage'&&opts.isdetails != undefined && opts.isdetails == 'yes'){
                addDetailfiledata(opts.popupobj,item,opts,file,flag,filename,newfile_name);
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
				if(empty(newfile_name)){
					newfile_name=file.newfile_name;
					newfile_name = newfile_name.replace(/\"/g,"");
					newfile_name = newfile_name.replace(/ /g,"_");
				}
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
		}
		
		//删除事件

        list.on("click", ".webuploadDelbtn", function () {
			var id = ld(this).parent().attr("name");
			var tag=ld(this).parent().attr("tag");//是webuploader 创建的id

			var id = id.replace(ld(item)[0].id, "");


			// ljj 2024-11-8 XUQIU20241023-04 产品可以导入图片（郭良峰）
			if (opts.popupobj!=undefined && opts.popupobj != '' && opts.popupobj.popuptype != undefined &&  opts.popupobj.popuptype == 'importImage' && opts.mode == 'importImage'){
				delete opts.popupobj.importImageArr[id];
				removeFile(id);
				return false;
			}

			var flag = ld(this).attr("tag");
			var file = uploader.getFile(id);
			var fullName = target.find("[name="+prevfixstr+"file_name_" + id+"]").val();
			var filePath = target.find("[name="+prevfixstr+"file_path_" + id+"]").val();
            var newfile_name = target.find("[name="+prevfixstr+"newfile_name_" + id+"]").val();
            var popupobj=CrmPopup.getPopupObj("last");
            var fileid=target.find("[name="+prevfixstr+"fileid_" + id+"]").val();
            //选择单据  有布局规则,该单据的引用字段有布局规则  ,会导致附件丢失
            //清空 popupobj.filejsondata数据 edit:can 20230721 69668 费用报销单，审批人编辑单据或者复制创建一条新单据，清空原先客户
             popupobj.filejsondata[prevfixstr.substr(0,prevfixstr.length-1)]=[];
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
           else if(uitype==69||uitype==105)
           {
                if(popupobj.imagedelfileids==undefined)
                     popupobj.imagedelfileids=[];
                popupobj.imagedelfileids.push(target.find("[name="+prevfixstr+"fileid_" +id+"]").val());
           }

			if(!file||id!=tag){//多选一个符合格式要求文件和不符合格式要求的文件上传， 上传后再选择两个符合格式文件上传，然后删除文件，其中有一个文件无法删除，或者删除的文件不是点击删除按钮删除的文件
				console.log("lingdang_fileDequeued");
				removeFile(id);
				uploader.trigger( '_fileDequeued');
			}else{
				console.log("lingdanguploader.removeFile");
				console.log(file);
				uploader.removeFile(file);	
			}
            
            //zkt 20230822 XUQIU1001755 分录附件多了，导致保存变慢，第一步 先修改为id获取数据
            // 设置popupobj的jsondata
            if(that.popupobj!=undefined && that.popupobj != '' && that.popupobj.pagetype != undefined && that.popupobj.pagetype == 'create_edit_modulepage'&&opts.isdetails != undefined && opts.isdetails == 'yes'){
                delateDetailfiledata(that.popupobj,item,opts,id);
            }
			if (fullName!=null && filePath != null && flag == 'create') {
				ld.post(webuploaderoptions.deleteServer, { fileName: encodeURIComponent(newfile_name),filePath: filePath,flag:flag,fileid:fileid}, function (data) {
					//data  error  success
				})
			}
            // if(target.find('[name='+prevfixstr+'filename]').val()=='' || target.find('[name='+prevfixstr+'filename]').val()==null || target.find('[name='+prevfixstr+'filename]').val()=='undefined'){
			if(target.find(" .attachments-padL10").length == 0){ //BUG0069778 xxy 2023-7-20 添加附件时，添加了一个附件后，应该显示继续添加的字样提示
				if(target.find('.webuploader-pick').find("input").length < 1){
                	target.find('.webuploader-pick').html('<a class="icon-attachment icon-attachments inpb-attachments">'+'</a>'+arrJsPopLabel['ADDINGATTACHMENTS']);//Liver 删除附件后，若附件为空，则显示添加附件
				}
            }
			
        });

	}

    ld.fn.powerWebUpload = function (options) {
        var ele = this;
     // alert(typeof WebUploader);
        if (typeof WebUploader == 'undefined') {
           // var casspath_btn = "include/js/webuploader/css/webuploader.css";
           // ld("<link>").attr({ rel: "stylesheet", type: "text/css", href: casspath_btn }).appendTo("head");
			var casspath_loader = "include/js/webuploader/css/bootstrap.min.css";
            ld("<link>").attr({ rel: "stylesheet", type: "text/css", href: casspath_loader }).appendTo("head");
		//	getJsScript('include/js/webuploader/webuploader.js',function(){
				//获取附件支持的格式
				/*ld.get('modules/Attachment/attachments.txt').success(function(content){
					if(!content){
						options.fileSupportType = content;
					}
					initWebUpload(ele, options);
				}); */
               //41801: （61mis.com/kfbcrm）工作汇报>月计划：上传三个不一样的附件，结果显示都是第一个附件。（需要补丁）
				initWebUpload(ele, options);

			//});
        }
        else {

            initWebUpload(ele, options);
        }
    }
})(jQuery, window);

//35324: 合同订单-添加图片字段，uitype=69，发现上传图片的样式还是老样式并且上传后图片不能显示
function setFileUploadObj()
{
    if(PageRecordPopupobj.sinputfilename==undefined)
    {
        return ;
    }

     //该函数是在页面全部加载完毕后执行
     for(var k=0;k<PageRecordPopupobj.sinputfilename.length;k++)
     {
        
                 var sdata=PageRecordPopupobj.filedata[k];
                 var sinputfilename=PageRecordPopupobj.sinputfilename[k];

                 var uitype=PageRecordPopupobj.uitypes[k];
                	   //渲染容器
                	ld("[name="+sinputfilename+"]").powerWebUpload({ 
                		fileTypeDuplicate:'yes',	//附件类型判断
                		fileNameDuplicate:'yes',	//同名附件判断
                		mode:smode,	//当前单据 create or edit
                		module:smodule,	//当前模块
                		jsonData:sdata,	//edit data,编辑界面显示已上传的附件
                		record:srecord,	//单据单据id
                		admin:isadmin,//是否是管理员
                        uitype:uitype,
                		supportformat:ssupportformat,//支持格式
                		inputFileName:sinputfilename	//选择附件后赋值标签的name
                	},PageRecordPopupobj);
     }
      PageRecordPopupobj.sinputfilename=new Array();
    PageRecordPopupobj.filedata=new Array();
    PageRecordPopupobj.uitypes=new Array();
}   