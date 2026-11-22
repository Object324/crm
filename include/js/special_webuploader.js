(function (ld, window) {

	function initWebUpload(item, options) {
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
		var prevfixstr=options.inputFileName+"-";
		this.filerand=parseInt(Math.random()*999999);
		var that = this;
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
		var popupobj = CrmPopup.getPopupObj('last');
		var target = $(item);//容器

		var pickerid = (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);

		var uploaderStrdiv = '';

		var tipsText = '';//上传附件说明，如支持格式等
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
			if(options.attach_server != undefined && !empty(options.attach_server)){
				uploaderStrdiv +=
					'<div class="addfu">' +
					'<span id="' + pickerid + '" style="display: inline-flex; vertical-align: middle;" class="a">'+'<a class="icon-attachment icon-attachments inpb-attachments"></a>'+arrJsPopLabel['ADDINGATTACHMENTS']+'</span>';
			}else{
				uploaderStrdiv +=
					'<div class="addfu">' +
					'<span id="' + pickerid + '" style="display: inline-flex; vertical-align: middle;" class="aa">'+'<a class="icon-attachment icon-attachments inpb-attachments"></a></span>';
			}
			/*
            if(opts.uitype==69)
            {
                //0031368:联系人新增编辑界面：添加照片后面的可以上传的文件格式应该只有管理员才能看到
                if(opts.admin == 'on') uploaderStrdiv += '<span style="vertical-align: middle;">jpg,jpeg,bmp,png.icon,gif,dwg,psd,ico</span>';
            }
            */
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

			if(opts.uitype==69||opts.uitype==1108){
				tipsText += '，'+arrJsPopLabel['fileformat']+arrJsPopLabel['PICTUREFORMAT'];
			}
			// ld("b[tag='attachmentHelp_"+opts.uitype+"'] #tip_info").text(tipsText);
			// ld("b[tag='attachmentHelp_"+opts.uitype+"']").addClass('tip-items-list');
			ld("b[tag='attachmentHelp_"+opts.uitype+"']").attr('data-tip', tipsText);
			ld("b[tag='attachmentHelp_"+opts.uitype+"']").attr('data-direction', 'top');
			ld("b[tag='attachmentHelp_"+opts.uitype+"']").attr('data-type', 'position');
			// ljj 2023-08-17 BUG0070653 kfbtest-销售机会-单据详情页，销售阶段推进任务中的附件设置浮显
			// tooltip('.tip-items-list', {transition: true, time: 200});
			uploaderStrdiv +='</div>'+
				'<div name="Uploadthelist" class="uploader-list"></div>';
		}
		else {
			//手动上传
			uploaderStrdiv +=
				'<div  class="uploader-list"></div>' +
				'<div class="btns">' +
				'<div id="' + pickerid + '">'+arrJsPopLabel['BROWSETHEFILE']+'</div>' +
				'<button class="webuploadbtn">'+arrJsPopLabel['STARTUPLOADING']+'</button>' +
				'</div>';
		}
		if (options.module == 'ModComments' && options.mode == 'reply'){
			uploaderStrdiv += '<div style="display:none" class="UploadhiddenInput" name="UploadhiddenInput_'+options.replyid+'"><input type="hidden" value="" tag="filenum"  name="'+prevfixstr+'file_num"></div>';
		}else {
			uploaderStrdiv += '<div style="display:none" class="UploadhiddenInput" name="UploadhiddenInput"><input type="hidden" value="" tag="filenum"  name="'+prevfixstr+'file_num"></div>';
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
		if (options.module == 'ModComments'){
			var server_url = global_flash_fileattachmentphp+'&frommodule='+options.module+'&pagetype=create_edit_modulepage';
			if (options.mode == 'reply'){
				hiddenInput = target.find('[name=UploadhiddenInput_'+options.replyid+']');
			}else {
				hiddenInput = target.find('[name=UploadhiddenInput]');
			}
		}else if (options.module == 'Settings' && options.mode == 'watermark'){
			var server_url = global_flash_fileattachmentphp+'&frommodule=Settings';
		}else {
			var server_url = global_flash_fileattachmentphp+'&CooperativeWork=yes';
		}
		if(options.attach_server != undefined && !empty(options.attach_server)){
			server_url = options.attach_server;
		}

		if(options.uitype!=undefined&&options.uitype==69)
		{
			if (options.module == 'Settings' && (options.mode == 'watermark' || options.mode == 'loginswiper')){
				var webuploaderoptions = ld.extend({
					swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
					//edit: xll BUG0064357 周计划、任务中图片无法正常显示
					server: server_url+"&uitype=69&isEncrypt=no&filerand="+that.filerand,	 // 文件接收服务端。
					deleteServer:'',	 // 文件删除服务端。
					pick: {
						id:'#'+pickerid,
						multiple:false,
						label: '点击选择图片'
					},	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
					resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
					//compress:false,
					chunked: true,	//是否要分片处理大文件上传
					chunkSize:2*1024*1024,	//分片大小，默认2M
					accept: { // 只允许选择图片文件。
						title: 'Images',
						extensions: 'jpg,jpeg,bmp,png,icon,psd,ico',
						mimeTypes: 'image/*'
					}
				},opts);
			}
			else {
				var webuploaderoptions = ld.extend({
					swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
					//edit: xll BUG0064357 周计划、任务中图片无法正常显示
					server: server_url+"&uitype=69&isEncrypt=no&filerand="+that.filerand,	 // 文件接收服务端。
					deleteServer:'',	 // 文件删除服务端。
					pick: '#'+pickerid,	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
					resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
					//compress:false,
					chunked: true,	//是否要分片处理大文件上传
					chunkSize:2*1024*1024,	//分片大小，默认2M
					accept: { // 只允许选择图片文件。
						title: 'Images',
						extensions: 'jpg,jpeg,bmp,png,icon,gif,dwg,psd,ico',
						mimeTypes: 'image/*'
					}
				},opts);
			}
		}
		else
		{
			var webuploaderoptions = ld.extend({
				swf: 'include/js/webuploader/Uploader.swf',	//swf文件路径
				server: server_url+"&uitype="+options.uitype+'&filerand='+that.filerand,	 // 文件接收服务端。
				deleteServer:'',	 // 文件删除服务端。
				pick: '#'+pickerid,	//选择文件的按钮。可选。 内部根据当前运行是创建，可能是input元素，也可能是flash.
				resize: false,	////不压缩image, 默认如果是jpeg，文件上传前会压缩一把再上传！
				// compress:false,
				chunked: true,	//是否要分片处理大文件上传
				chunkSize:2*1024*1024	//分片大小，默认2M
			},opts);
		}

		//创建WebUploader实例
		var uploader = WebUploader.create(webuploaderoptions);
		target.prop('WebUploaderInstance',uploader)
		//队列事件
		if (opts.auto) {
			uploader.on('fileQueued', function (file) {
				uploader.options.encryptyurl ='yes';
				list.append( '<div name="' +file.id + '" class="attachments-padL10">' +
					'<span class="item" style="padding-left:5px">' +file.name +'</span>' +
					'<span class="state" style="padding-left:5px"></span><span class="webuploadDelbtn" tag="" style="padding-left:5px"></span>' +
					'</div>' );
				uploader.upload();
			});
		} else {
			uploader.on('fileQueued', function (file) {
				uploader.options.encryptyurl ='yes';
				list.append('<div name="' +$(item)[0].id + file.id + '" class="item">' +
					'<span class="webuploadinfo">' +prevfixstr+ file.name + '</span>' +
					'<span class="webuploadstate">'+arrJsPopLabel['WAITINGFORUPLOADING']+'...</span>' +
					'<div class="webuploadDelbtn">'+arrJsPopLabel['DELETE']+'</div>' +
					'</div>');
			});
		}

		//编辑  队列显示
		uploader.on('ready', function () {
			var fileCount = 1;

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
						obj.filerowindex = k;
						obj.name=list['file_name'];
						obj.newfile_name=list['newfile_name'];
						obj.type=list['file_type'];
						obj.size=list['file_size'];
						obj.path=list['file_path'];
						obj.imagefromtype=list['imagefromtype'];
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
						if (options.module == 'Settings' && options.mode == 'watermark'){
							obj.settingid = list['settingid'];
							obj.filerowindex = 1;
							addWaterMarkImage(obj,'edit');
						}
						uploader.trigger( '_fileQueued');
					});

					target.find('[name='+prevfixstr+'file_num]').val(fileCount);
				}
			}
			WebUploader.Base._idSuffix=fileCount;
		});

		// 文件上传过程中创建进度条实时显示。
		uploader.on( 'uploadProgress', function( file, percentage ) {
			//var li = target.find("[name="+file.id+"]"),percent = li.find('.progress .progress-bar');
			// 避免重复创建
			/*if ( !percent.length ) {
				percent = ld('<div class="progress progress-striped active"><span class="text"></span>' +
				  '<div class="progress-bar" role="progressbar" style="width: 0%">' +
				  '</div>' +
				'</div>').appendTo( li ).find('.progress-bar');
			}*/
			//li.find('span.state').text('上传中');
			//li.find(".text").text(Math.round(percentage * 100) + '%');
			ld('#homeprogressbar').show();
			//var processbar = ld('.processbar').val();
			ld('#progressbar').css('width',Math.round(percentage * 100)+'%');
		});

		//当文件上传成功时触发file {File}File对象  response {Object}服务端返回的数据
		uploader.on( 'uploadSuccess', function(file,response) {
			if (file.ext != undefined && file.ext == 'php'){
				var confirm_str = arrJsPopLabel['FORSECURITYREASONS'] + '<br/>' + file.name;
				MessagePopup.TipOne_warning(confirm_str);
				return;
			}
			var restobj = response;
			ld('#homeprogressbar').hide();
			if(options.attach_server != undefined && !empty(options.attach_server)){
				ld('#upload_file_name').attr('path',restobj.path);
				ld('#upload_file_name').attr('file',restobj.name);
				var filename = '<span class="upload-file-name"><span class="item-name">'+ld('#upload_file_name').attr('file')+
					`</span><span class="remove-h" data-id="${file.id}">×</span></span>`;
				ld('#upload_file_name').html(filename);
				ld('.upload-file-name .remove-h').on('click',function(){//删除
					ld('#upload_file_name').attr('path','');
					ld('#upload_file_name').attr('file','');
					ld('#upload_file_name').html('');
					uploader._deleteFile(this)
				});
				uploader.reset();
			}else{
				if (options.module == 'ModComments' ||(options.module == 'Settings' && (options.mode == 'watermark' || options.mode == 'loginswiper'))) {
					file.path = response.filePaht;
					file.newfile_name = response.newfile_name;
					file.fileid = target.find("[tag="+prevfixstr+"newfile_name]").length+1;
					file.cloud_path = '';
					file.storage_location = 'local';
					file.isEncrypt = response.isEncrypt;
					file.imagefromtype = 'Computer';
					file.filerowindex = target.find("[tag="+prevfixstr+"newfile_name]").length+1;
					file.pre_button = response.pre_button; //预览按钮
					file.upload_from = 'PC'; //预览按钮
					if (options.module == 'ModComments'){
						addModCommentsFile(file, options.inputFileName);
					}else if (options.module == 'Settings' && options.mode == 'watermark'){
						file.filerowindex = 1 ;
						addWaterMarkImage(file,'create');
					}else if(options.module == 'Settings' && options.mode == 'loginswiper'){
						addloginswiperimage(file);
					}
				}else {
					var tag = 'sendLog';
					var tmppopupobjdivid = options.popupobj?'#'+options.popupobj.divid+' ':' ';
					var download_permit = ld(tmppopupobjdivid+'#download_permit').val();
					var preview_permit = ld(tmppopupobjdivid+'#preview_permit').val();
					var liObj ;
					var filesize = uploader.getFileSize(restobj.fileSize);
					var record = restobj.record;
					var fileid = file.id;
					if(options.uitype == 69){//图片
						liObj = '<li record="'+record+'" style="display: flex;align-items: center;width: 100%">';
						liObj += '<span class="item-name">';
						liObj += '<img class="name-img" id="img_'+fileid+'" src="'+restobj.filePaht+restobj.newfile_name+'">';
						liObj += '</span>';
						liObj += '<span style="padding-left:10px;max-width: 50%" class="overflow-space">'+restobj.oldName+'</span>';
						liObj += '<span class="state" style="padding-left:5px"><span style="color:#798699;">('+filesize+')</span></span>';
						liObj += '<span class="webuploadDelbtn" style="padding-left:10px"><a href="javascript:void(0)" name="delete_'+fileid+'" data-id="'+fileid+'">'+arrJsPopLabel['DELETE']+'</a></span>';
						if (preview_permit == 'yes'){
							liObj += '<span class="webuploadPrebtn" style="padding-left:10px">';
							liObj += restobj.pre_button;
							liObj += '</a></span>';
						}
						liObj += '</li>';

						var ulobj = ld(tmppopupobjdivid+'#'+tag+'UploadImg ul');
						var uploadimgobj = ld(tmppopupobjdivid+'#'+tag+'UploadImg');
						ulobj.append(liObj);
						uploadimgobj.css('display','');
						//绑定图片删除事件
						ulobj.find('li[record='+record+']').find('[name=delete_'+fileid+']').off('click').on('click',function(){
							ulobj.find('li[record='+record+']').remove();
							if(ulobj.find('li').length == 0){
								uploadimgobj.css('display','none');
							}
							uploader._deleteFile(this)
						});
					}else{//附件
						liObj = '<li record="'+record+'" style="display: flex;align-items: center;width: 100%">';
						liObj += '<span class="item-name">';
						liObj += '<img alt="'+restobj.oldName+'" src="themes/softed/images/file.png">';
						liObj += '</span>';
						liObj += '<span class="item" style="padding-left:10px;max-width: 50%" class="overflow-space">'+restobj.oldName+'</span>';
						liObj += '<span class="state" style="padding-left:5px"><span style="color:#798699;">('+filesize+')</span></span>';
						liObj += '<span class="webuploadDelbtn" style="padding-left:10px"><a href="javascript:void(0)" id="delete_'+fileid+'" name="delete_'+fileid+'" data-id="'+fileid+'">'+arrJsPopLabel['DELETE']+'</a></span>';
						if (preview_permit == 'yes'){
							liObj += '<span class="webuploadPrebtn" style="padding-left:10px">';
							liObj += restobj.pre_button;
							liObj += '</span>';
						}
						liObj += '</li>';


						ld(tmppopupobjdivid+'#'+tag+'UploadAtt ul').append(liObj);
						ld(tmppopupobjdivid+'#'+tag+'UploadAtt').css('display','');
						//绑定附件删除事件
						ld(tmppopupobjdivid+'#'+tag+'UploadAtt ul li ').find('#delete_'+fileid).on('click',function(){
							ld(tmppopupobjdivid+'#'+tag+'UploadAtt ul li[record='+record+']').remove();
							if( ld(tmppopupobjdivid+'#'+tag+'UploadAtt ul li').length == 0){
								ld(tmppopupobjdivid+'#'+tag+'UploadAtt').css('display','none');
							}
							uploader._deleteFile(this)
						});
					}
				}
			}
			//uploader.reset();
			// ld('.uploader-list').html('');
		});

		function addModCommentsFile(file,type) {
			// type 图片:image 附件：filename
			var uploadobj=ld('#'+popupobj.divid+' #'+options.parentdivid).find('[name=upload_'+type+']');
			file.size = uploader.getFileSize(file.size);
			var html = '<div name="ModCommentsUpLoad" id="ModCommentsUpLoad" class="comment-uoloader-list-row" filerowindex="'+file.filerowindex+'">';
			var isPreviewEnable = ld('#'+popupobj.divid+' #'+options.parentdivid).find('[name=isPreviewEnable]').val();
			if (type == 'image'){
				if (isPreviewEnable == 'yes'){
					html += '<div class="el-image"><img name="prevshow_img" src="'+file.path+file.newfile_name+'"></div>';
				}
			}else {
				html += '<a class="att-img"></a>'
			}
			html += '<span class="item">'+file.name+'</span>';
			html += '<span>('+file.size+')</span>';
			html += '<span class="webuploadDelbtn" tag="create" style="padding-left:10px">' +
						`<a href="javascript:void(0)" tag="delete"  filerowindex="${file.filerowindex}" data-id="${file.id}" >${arrJsPopLabel['DELETE']}</a>`+
					`</span>`;
			html += '<span class="webuploadDelbtn" style="padding-left:10px">';
			if (isPreviewEnable == 'yes'){
				if (type == 'image'){
					var pre_button=file.pre_button.replace('uploader-list','comment-uoloader-list-row')
					html += pre_button;
				}else {
					html += '<a href="javascript:;" onclick="Pre_Attachment(this)" '+
						'file_fileid="'+file.fileid+'_" file_isencrypt="'+file.isEncrypt+'" file_size="'+file.size+'" file_filename="'+file.name+'" file_path="'+file.path+'" '+
						'file_newfile_name="'+file.newfile_name+'" file_cloud_path="'+file.cloud_path+'" file_storage_location="'+file.storage_location+'" file_type="'+file.type+'"><span>'+arrJsPopLabel['PREVIEW']+'</span>';
					html += '</a>';
				}
			}
			html += '</span>';
			html += '</div>';
			uploadobj.append(html);
			if (type == 'image' && isPreviewEnable == 'yes'){
				previewImage(uploadobj.find('img[name=prevshow_img]').get(0));
			}
			uploadobj.css('display','');
			uploadobj.find('[name=ModCommentsUpLoad]').find('a[filerowindex='+file.filerowindex+']').bind('click',function () {
				deleteFile(this,type);
			});

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
			hiddenInput.append('<input type="text" id="'+prevfixstr+'newfile_name_' + file.filerowindex + '" tag="'+prevfixstr+'newfile_name"    name="'+prevfixstr+'newfile_name_' + file.filerowindex + '" class="hiddenInput" value="' + newfile_name + '" />');
			hiddenInput.append('<input type="text" id="'+prevfixstr+'fileid_' + file.filerowindex + '" name="'+prevfixstr+'fileid_' + file.filerowindex + '" class="hiddenInput" value="' + file.fileid + '" />');
			hiddenInput.append('<input type="text" id="'+prevfixstr+'storage_location_' + file.filerowindex + '" name="'+prevfixstr+'storage_location_' + file.filerowindex + '" class="hiddenInput" value="' + file.storage_location + '" />');
			hiddenInput.append('<input type="text" id="'+prevfixstr+'imagefromtype_' + file.filerowindex + '" name="'+prevfixstr+'imagefromtype_' + file.filerowindex + '" class="hiddenInput" value="' + imagefromtype + '" />');
			hiddenInput.append('<input type="text" id="'+prevfixstr+'cloud_path_' + file.filerowindex + '" name="'+prevfixstr+'cloud_path_' + file.filerowindex + '" class="hiddenInput" value="' + decodeURIComponent(file.cloud_path) + '" />');
			hiddenInput.append('<input type="text" id="'+prevfixstr+'isEncrypt_' + file.filerowindex + '" name="'+prevfixstr+'isEncrypt_' + file.filerowindex + '" class="hiddenInput" value="' + file.isEncrypt + '" />');
			hiddenInput.append('<input type="text" id="'+prevfixstr+'upload_from_' + file.filerowindex + '" name="'+prevfixstr+'upload_from_' + file.filerowindex + '" class="hiddenInput" value="' + file.upload_from + '" />');
			target.find('[name='+prevfixstr+'file_num]').val(file.filerowindex);
		}
		function deleteFile(obj,type){
			var filerowindex = ld(obj).attr('filerowindex');
			if (options.module == 'Settings' && options.mode == 'watermark'){
				var uploadobj=ld('#'+popupobj.divid+' #'+options.parentdivid);
				uploadobj.find('[name=WaterMarkUpLoad][filerowindex='+filerowindex+']').remove();
			}else {
				var uploadobj=ld('#'+popupobj.divid+' #'+options.parentdivid).find('[name=upload_'+type+']');
				uploadobj.find('[name=ModCommentsUpLoad][filerowindex='+filerowindex+']').remove();
			}
			hiddenInput.find('#'+prevfixstr+'file_size_'+filerowindex).remove();
			hiddenInput.find('#'+prevfixstr+'file_name_'+filerowindex).remove();
			hiddenInput.find('#'+prevfixstr+'file_path_'+filerowindex).remove();
			hiddenInput.find('#'+prevfixstr+'file_type_'+filerowindex).remove();
			hiddenInput.find('#'+prevfixstr+'newfile_name_'+filerowindex).remove();
			hiddenInput.find('#'+prevfixstr+'fileid_'+filerowindex).remove();
			hiddenInput.find('#'+prevfixstr+'storage_location_'+filerowindex).remove();
			hiddenInput.find('#'+prevfixstr+'imagefromtype_'+filerowindex).remove();
			hiddenInput.find('#'+prevfixstr+'cloud_path_'+filerowindex).remove();
			hiddenInput.find('#'+prevfixstr+'isEncrypt_'+filerowindex).remove();
			hiddenInput.find('#'+prevfixstr+'upload_from_'+filerowindex).remove();
			var newfilenum = hiddenInput.find("[tag="+prevfixstr+"newfile_name]").length;
			hiddenInput.find('[name='+prevfixstr+'file_num]').val(newfilenum);
			if (parseInt(newfilenum) == 0){
				uploadobj.css('display','none');
			}

			uploader._deleteFile(this);
		}

		function addWaterMarkImage(file,type) {
			var uploadobj=ld('#'+popupobj.divid+' #'+options.parentdivid);
			if (type == 'create'){
				var pre_button=file.pre_button.replace('uploader-list','uploader-list-row')
				var html = '<div name="WaterMarkUpLoad" id="WaterMarkUpLoad" class="uploader-list-row" filerowindex="'+file.filerowindex+'">'+
					'<div class="el-image"><img name="prevshow_img" src="'+file.path+file.newfile_name+'"></div>'+
					'<span class="item">'+file.name+'</span>'+
					'<span class="webuploadDelbtn" tag="create" style="padding-left:10px">' +
					`<a href="javascript:void(0)" tag="delete"  filerowindex="${file.filerowindex}" data-id="${file.id}"">${arrJsPopLabel['DELETE']}</a>` +
					'</span>'+
					'<span class="webuploadDelbtn" style="padding-left:10px">' +
					'<img style="display:none" src="'+file.path+file.newfile_name+'">' +
					'<a href="javascript:void(0);" onclick="previewImage(ld(this).prev().get(0));ld(this).parent().find(\'img\').click();">' +
					'<span>'+arrJsPopLabel['PREVIEW']+'</span>' +
					'</span>' + '</div>';
			}else {
				var html = '<div name="WaterMarkUpLoad" id="WaterMarkUpLoad" class="uploader-list-row" filerowindex="'+file.filerowindex+'">'+
					'<div class="el-image"><img name="prevshow_img" src="'+file.path+file.newfile_name+'"></div>'+
					'<span class="item">'+file.name+'</span>'+
					'<span class="webuploadDelbtn" tag="create" style="padding-left:10px">' +
					'<a href="javascript:void(0)" tag="delete"  filerowindex="'+file.filerowindex+'">'+arrJsPopLabel['DELETE']+'</a></span>'+
					'<span class="webuploadDelbtn" style="padding-left:10px"><a tag="download" href="index.php?module=Settings&action=SettingsAjax&file=FileWaterMarkSetting&option=download&settingid='+file.settingid+'">'+arrJsPopLabel['DOWNLOAD']+'</a></span>'+
					'<span class="webuploadDelbtn" style="padding-left:10px">' +
					'<img style="display:none" src="'+file.path+file.newfile_name+'">' +
					'<a href="javascript:void(0);" onclick="previewImage(ld(this).prev().get(0));ld(this).parent().find(\'img\').click();">' +
					'<span>'+arrJsPopLabel['PREVIEW']+'</span>' +
					'</span>' + '</div>';
			}
			uploadobj.html(html);
			previewImage(uploadobj.find('img[name=prevshow_img]').get(0));
			uploadobj.css('display','');
			uploadobj.find('[name=WaterMarkUpLoad]').find('a[filerowindex='+file.filerowindex+']').bind('click',function () {
				deleteFile(this,'image');
			});
			var filename = file.name.replace(/\'/g,"");
			filename = filename.replace(/\"/g,"");
			filename = filename.replace(/ /g,"_");
			var newfile_name=file.newfile_name;
			newfile_name = newfile_name.replace(/\"/g,"");
			newfile_name = newfile_name.replace(/ /g,"_");
			hiddenInput.html('<input type="hidden" value="1" tag="filenum"  name="'+prevfixstr+'file_num">'+
				'<input type="text" id="'+prevfixstr+'file_name_' + file.filerowindex + '"  name="'+prevfixstr+'file_name_' + file.filerowindex + '" class="hiddenInput" value="' + filename + '" />'+
				'<input type="text" id="'+prevfixstr+'file_path_' + file.filerowindex + '" name="'+prevfixstr+'file_path_' + file.filerowindex + '" class="hiddenInput" value="' + file.path + '" />'+
				'<input type="text" id="'+prevfixstr+'newfile_name_' + file.filerowindex + '" tag="'+prevfixstr+'newfile_name"    name="'+prevfixstr+'newfile_name_' + file.filerowindex + '" class="hiddenInput" value="' + newfile_name + '" />');
		}
		//登录页轮播图
		function addloginswiperimage(file){
			var uploadobj=ld('#'+popupobj.divid);
			var html = '<input type="hidden" id="loginswipercontent" value="'+file.path+file.newfile_name+'"/>';
			uploadobj.find('[name=loginswiperchooseimgfilename]').html(html);
			uploadobj.find('[name=loginswiper_img]').attr('src',file.path+file.newfile_name);
			uploadobj.find('[name=loginswiper_img_div]').show();
			popupobj.center();
		}

		//edit: xll 2024/08/12 文件上传后删除，再次上传提示文件重复无法上传的问题
		uploader._deleteFile = function (jsObj) {
			var id = ld(jsObj).data("id").toString(),
				file = uploader.getFile(id);
			if(id !== null && typeof id !== "undefined" && id !== "undefined") {
				if(file.id) {
					uploader.cancelFile(file)
					uploader.removeFile(file)
				}
				else {
					uploader.trigger( '_fileDequeued')
				}
			}
		}

		uploader.getFileSize = function (size){
			size = parseInt(size);
			if (size < 1024)
				size = size + ' B';
			else if (size > 1024 && size < 1048576)
				size = (size / 1024).toFixed(2) + ' KB';
			else if (file.size > 1048576)
				size = (size / (1024 * 1024)).toFixed(2) + ' MB';
			return size;
		}

		//当文件上传出错时触发file {File}File对象  reason {String}出错的code
		uploader.on( 'uploadError', function(file,reason) {
			target.find("[name="+file.id+"]").find('span.state').text('上传出错');
		});

		//不管成功或者失败，文件上传完成时触发 file {File}File对象
		uploader.on( 'uploadComplete', function( file ) {
			target.find("[name="+file.id+"]").find('.progress').fadeOut();
		});

		//出错 提示
		uploader.on("error",function ( type , num, file ){
			let confirm_str;
			(typeof num === "object" && num.id) && (file = num)
			if (type=="Q_TYPE_DENIED"){
				confirm_str = arrJsPopLabel['FORSECURITYREASONS'] +'\n'+file.name;
			}else if(type=="Q_EXCEED_SIZE_LIMIT"){	//总文件大小
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
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		});

		uploader.on('all', function (type) {
			that.filerand=parseInt(Math.random()*9999999);
			if (type === 'startUpload') {
				state = 'uploading';
			} else if (type === 'stopUpload') {
				state = 'paused';
			} else if (type === 'uploadFinished') {
				state = 'done';
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
	}

	ld.fn.special_powerWebUpload = function (options) {
		var ele = this;
		// alert(typeof WebUploader);
		if (typeof WebUploader == 'undefined') {
			// var casspath_btn = "include/js/webuploader/css/webuploader.css";
			//  ld("<link>").attr({ rel: "stylesheet", type: "text/css", href: casspath_btn }).appendTo("head");
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
			//alert('22')
			//41801: （61mis.com/kfbcrm）工作汇报>月计划：上传三个不一样的附件，结果显示都是第一个附件。（需要补丁）
			initWebUpload(ele, options);

			//	});
		}
		else {
			initWebUpload(ele, options);
		}
	}
})(jQuery, window);