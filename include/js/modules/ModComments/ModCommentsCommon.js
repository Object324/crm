/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
if (typeof(ModCommentsCommon) == 'undefined') {
	ModCommentsCommon = {
		modulename : '',
		addComment : function(domkeyid, parentid) {
			var popupobj = CrmPopup.getPopupObj('last');
			var textBoxFieldobj = ld("#"+popupobj.divid).find('#create_comment_'+domkeyid);
			var contentWrapDOM = ld('#'+popupobj.divid+' #contentwrap_'+domkeyid);
			//图片附件上传
			var param = {};
			var divid = 'comment_create_div'
			var img_params=ModCommentsCommon.getFileImgParams(divid,'image');
			var att_params=ModCommentsCommon.getFileImgParams(divid,'filename');
			var params = ld.extend(img_params,att_params);

			if (ld(textBoxFieldobj).val() == '') {
				MessagePopup.TipOne_warning(arrJsPopLabel['FILLINCOMMENTS']);
				return;
			}
            
			var url = 'index.php?module=ModComments&action=ModCommentsAjax&file=DetailViewAjax&ajax=true&Create=true&ajxaction=WIDGETADDCOMMENT&parentid='+encodeURIComponent(parentid);
			//获取用户名
            var str = "@";
            var newusernames = '';
            var reg = new RegExp(str);
            var commentcontent=ld(textBoxFieldobj).val();
            if(reg.test(commentcontent))
            {
                var objCommentContent = commentcontent.split("@");
                for(var i=1; i<objCommentContent.length; i++)
                {
                    newusernames += objCommentContent[i].substring(0,objCommentContent[i].indexOf(" "))+',';
                }
				//wym 240314 BUG20240308-17 kfbcrm-单据评论区，重复@成员，点击发布，评论内容显示为空（成员姓名问题，姓名带特殊符号的成员，不管是不是重复@都会显示为空）
                url += '&newusernames=' + encodeURIComponent(newusernames);
            }
            url += '&comment=' + encodeURIComponent(commentcontent);
			url += '&related_to_type=' + popupobj.module;
            var ccrangeuser = '';//抄送范围 用户
    		if(ld("#"+popupobj.divid+' #comment_ccrange ul.reader-bar-list li').length > 0){
    			ld("#"+popupobj.divid+' #comment_ccrange ul.reader-bar-list li').each(function(){
    				if(ld(this).attr('userid') != undefined && ld(this).attr('userid') > 0){
    					ccrangeuser += ld(this).attr('userid')+',';
    				}
    			});
    		}
            url += '&ccrangeuser='+ccrangeuser;
            ld('#'+popupobj.divid+' #'+divid).find('[name=addcomment]').css('pointer-events','none');
			$("status").style.display="inline";
            ldAjax(url,params,function(data){
					 $("status").style.display="none"; 
					puyoungJS_DialogBox.unblock();
					if (data.code == 1) {
                        //隐藏暂无内容
                        ld("#"+popupobj.divid +" #modcomment_nocomment_"+domkeyid).css('display','none');
						ld(textBoxFieldobj).val('');
                        if(!empty(data.result.content)){
							ld(contentWrapDOM).prepend(data.result.content)
                            // contentWrapDOM.innerHTML = data.result.content+contentWrapDOM.innerHTML;
							var imageobj = ld(contentWrapDOM).find('img[name=prevshow_img]');
							ld.each(imageobj,function (index,obj) {
								previewImage(ld(obj).get(0));
							});
                        }
                        ld("#"+popupobj.divid+" #contentwrap_"+recordid).find('textarea').not('.proName_note').autosize();
                        ld("#"+popupobj.divid +" #create_comment_"+domkeyid).css('height','65px');
                        setModcommentEvent();
						// 清除 图片内容
						ld('#'+popupobj.divid + ' #comment_create_div').find('[name=upload_image]').css('display','none');
						ld('#'+popupobj.divid + ' #comment_create_div').find('[name=upload_filename]').css('display','none');
						ld('#'+popupobj.divid + ' #comment_create_div').find('#ModCommentsUpLoad').remove();
						ld('#'+popupobj.divid + ' #comment_create_div').find('[name=UploadhiddenInput] input:not([tag=filenum])').remove();
					}else if(data.code == -1){
					    var confirm_str = data.msg;
                        ld(textBoxFieldobj).val('');
						MessagePopup.TipOne_warning(confirm_str);
					}else{
						MessagePopup.TipOne_warning(arrJsPopLabel['OPERATION_DENIED']);
					}
				DelProgressObjs();
				ld('#'+popupobj.divid+' #'+divid).find('[name=addcomment]').css('pointer-events','all');
				});
		},
		// 获取上传的图片附件数据
		getFileImgParams:function (divid,type) {
			var popupobj=CrmPopup.getPopupObj('last');
			if (popupobj.modcomment_fileImg_fieldobj == undefined){
				return false;
			}else {
				var modcomment_fileImg_fieldobj = popupobj.modcomment_fileImg_fieldobj;
			}
			if (!empty(modcomment_fileImg_fieldobj[type]) && !empty(modcomment_fileImg_fieldobj[type].fieldName)){
				var filename = modcomment_fileImg_fieldobj[type].fieldName;
			}else {
				return false;
			}
			var params={};
			if (CrmPopup.isExistsObj(divid,type+'-file_num')){
				var filenum=CrmPopup.getHtmlobjval(divid,type+'-file_num');
				if (filenum >0){
					var tmpfilenum = 0;
					for(var i=1;i<=220;i++){
						if (CrmPopup.isExistsObj(divid,type+'-file_name_'+i)){
							params[filename+'-file_name_'+i] = CrmPopup.getHtmlobjval(divid, filename + "-file_name_" + i);
							params[filename+'-file_type_'+i] = CrmPopup.getHtmlobjval(divid, filename + "-file_type_" + i);
							params[filename+'-file_size_'+i] = CrmPopup.getHtmlobjval(divid, filename + "-file_size_" + i);
							params[filename+'-file_path_'+i] = CrmPopup.getHtmlobjval(divid, filename + "-file_path_" + i);
							params[filename+'-newfile_name_'+i] =  CrmPopup.getHtmlobjval(divid, filename + "-newfile_name_" + i);
							var storage_location = CrmPopup.getHtmlobjval(divid, filename + "-storage_location_" + i);
							if (storage_location == 'cos') {
								params[filename+'-cloud_path_'+i] =  CrmPopup.getHtmlobjval(divid, filename + "-cloud_path_" + i);
							}
							params[filename+'-storage_location_'+i] =  CrmPopup.getHtmlobjval(divid, filename + "-storage_location_" + i);
							var imagefromtype = CrmPopup.getHtmlobjval(divid, filename + "-imagefromtype_" + i);
							imagefromtype = empty(imagefromtype)?'':imagefromtype;
							params[filename+'-imagefromtype_'+i] =  imagefromtype;
							params[filename+'-isEncrypt_'+i] =  CrmPopup.getHtmlobjval(divid, filename + "-isEncrypt_" + i);
							tmpfilenum ++;
						}
					}
					params[filename+'-file_num']=tmpfilenum;
				}
			}
			return params;
		},
		//ljj 20240401 XUQIU1001924 PC端+移动端：模块单据详情界面：评论内容增加图片、附件 加载回复图片附件上传插件
		setReplyFileImgEvent: function (replyobj,replyid){
			var uploadFileobj = new WebUploadFile();
			var divid = 'replycontent_'+replyid+'_div';
			globalModWebUploadType=uploadFileobj.uploadType();
			var popupobj=CrmPopup.getPopupObj('last');
			var modcomment_fileImg_fieldobj = popupobj.modcomment_fileImg_fieldobj;
			if (popupobj.modcomment_fileImg_fieldobj == undefined){
				return false;
			}else {
				var modcomment_fileImg_fieldobj = popupobj.modcomment_fileImg_fieldobj;
			}
			if(globalModWebUploadType=='cos') {
				getJsScript('include/js/webuploader/Speical_webUploaderCos.js', function () {
					if (!empty(modcomment_fileImg_fieldobj.image) && !empty(modcomment_fileImg_fieldobj.image.fieldName)) {
						ld(replyobj).find("[name=comment_image").special_powerWebUploadCos({
							fileTypeDuplicate:'yes',	//附件类型判断
							fileNameDuplicate:'yes',	//同名附件判断
							mode:'reply',
							replyid:replyid,
							module:'ModComments',	//当前模块
							parentdivid:divid,
							jsonData:'',	//edit data,编辑界面显示已上传的附件
							record:'',	//单据单据id
							admin:'',//是否是管理员
							uitype:'69',
							supportformat:'',//支持格式
							inputFileName:modcomment_fileImg_fieldobj.image.fieldName		//选择附件后赋值标签的name
						});
					}

					if (!empty(modcomment_fileImg_fieldobj.filename) && !empty(modcomment_fileImg_fieldobj.filename.fieldName)) {
						ld(replyobj).find("[name=comment_filename").special_powerWebUploadCos({
							fileTypeDuplicate:'yes',	//附件类型判断
							fileNameDuplicate:'yes',	//同名附件判断
							mode:'reply',
							replyid:replyid,
							module:'ModComments',	//当前模块
							parentdivid:divid,
							jsonData:'',	//edit data,编辑界面显示已上传的附件
							record:'',	//单据单据id
							admin:'',//是否是管理员
							uitype:'1108',
							supportformat:'',//支持格式
							inputFileName:modcomment_fileImg_fieldobj.filename.fieldName	//选择附件后赋值标签的name
						});
					}
				});
			} else {
				getJsScript('include/js/special_webuploader.js', function () {
					if (!empty(modcomment_fileImg_fieldobj.image) && !empty(modcomment_fileImg_fieldobj.image.fieldName)) {
						ld(replyobj).find("[name=comment_image").special_powerWebUpload({
							fileTypeDuplicate:'yes',	//附件类型判断
							fileNameDuplicate:'yes',	//同名附件判断
							mode:'reply',
							replyid:replyid,
							module:'ModComments',	//当前模块
							parentdivid:divid,
							jsonData:'',	//edit data,编辑界面显示已上传的附件
							record:'',	//单据单据id
							admin:'',//是否是管理员
							uitype:'69',
							supportformat:'',//支持格式
							inputFileName:modcomment_fileImg_fieldobj.image.fieldName	//选择附件后赋值标签的name
						});
					}

					if (!empty(modcomment_fileImg_fieldobj.filename) && !empty(modcomment_fileImg_fieldobj.filename.fieldName)) {
						ld(replyobj).find("[name=comment_filename").special_powerWebUpload({
							fileTypeDuplicate:'yes',	//附件类型判断
							fileNameDuplicate:'yes',	//同名附件判断
							mode:'reply',
							replyid:replyid,
							module:'ModComments',	//当前模块
							parentdivid:divid,
							jsonData:'',	//edit data,编辑界面显示已上传的附件
							record:'',	//单据单据id
							admin:'',//是否是管理员
							uitype:'1109',
							supportformat:'',//支持格式
							inputFileName:modcomment_fileImg_fieldobj.filename.fieldName	//选择附件后赋值标签的name
						});
					}
				});
			}
		},
		reloadContentWithFiltering : function(widget, parentid, criteria, targetdomid, indicator) {
			if($(indicator)) $(indicator).style.display="inline";
            var commentmode = ld("#commentMode").data('commentmode');
			
			var url = 'module=ModComments&action=ModCommentsAjax&file=ModCommentsWidgetHandler&ajax=true';
			url += '&widget=' + encodeURIComponent(widget) + '&parentid='+encodeURIComponent(parentid);
			url += '&criteria='+ encodeURIComponent(criteria);
            url += '&commentmode='+ encodeURIComponent(commentmode);
			
			new Ajax.Request('index.php',{
				queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
				onComplete: function(response) {
					if($(indicator)) $(indicator).style.display="none";
                    
					var results=response.responseText.split('###SUCCESS###');
                    result = results[0];
                    result = trim(result);
					 if($(targetdomid)) $(targetdomid).innerHTML = result;
				}}
			);
		},
		//1000066  评论功能优化（界面显示和评论内容，回复）--回复列表显示隐藏
        Replylistshowchange : function(commentid){
            var popupobj = CrmPopup.getPopupObj('last');
            var commentdivobj = ld("#"+popupobj.divid+" #modcomment_id_"+commentid);
            var showstatus = ld(commentdivobj).data("status");
            if(showstatus == 'show'){
                if(ld(commentdivobj).find("[id^=modcomment_replyid_]").length>0){
                    ld(commentdivobj).find("[id^=modcomment_replyid_]").css('display','none');
                }
                ld(commentdivobj).data("status",'hidden');
            }
            else{
                if(ld(commentdivobj).find("[id^=modcomment_replyid_]").length>0){
                    ld(commentdivobj).find("[id^=modcomment_replyid_]").css('display','');
                }
                ld(commentdivobj).data("status",'show');
            }
        },
		//1000066  评论功能优化（界面显示和评论内容，回复）--回复框
        showReplydiv : function(replyedid, parentid){
            var popupobj = CrmPopup.getPopupObj('last');
            var replydivobj = ld("#"+popupobj.divid).find('#replycontent_'+replyedid+'_div');
            var replydivdisplay = ld(replydivobj).css("display");
			if (popupobj.ModcommentReplyId[replyedid] != 'yes'){
				ModCommentsCommon.setReplyFileImgEvent(replydivobj,replyedid);
				popupobj.ModcommentReplyId[replyedid] = 'yes';
			}

            if(replyedid == parentid){
                ModCommentsCommon.Replylistshowchange(parentid);
            }
            if( replydivdisplay== 'none'){
                ld(replydivobj).css("display","");
            }
            else{
                ld(replydivobj).css("display","none");
            }
        },
        hiddenReplydiv : function(replyedid, parentid){
            var popupobj = CrmPopup.getPopupObj('last');
            var replydivobj = ld("#"+popupobj.divid).find('#replycontent_'+replyedid+'_div');
            ld(replydivobj).css("display","none");
            //zkt 20230112 BUG0060810明细界面评论回复取消按钮点击无法清除输入内容，并且会折叠评论有关回复
            if(ld("#"+popupobj.divid+' #create_reply_'+replyedid).length>0){
                ld("#"+popupobj.divid+' #create_reply_'+replyedid).val('');
            }
            if(replyedid == parentid){
                //ModCommentsCommon.Replylistshowchange(parentid);
            }
        },
		//1000066  评论功能优化（界面显示和评论内容，回复）--添加回复
        addReply: function(replyedid, parentid) {
			var popupobj = CrmPopup.getPopupObj('last');
			var textBoxFieldobj = ld("#"+popupobj.divid).find('#create_reply_'+replyedid);
			var contentWrapDOM = $('modcomment_id_'+parentid);
			var replydivid = 'replycontent_'+replyedid+'_div';
			var img_params=ModCommentsCommon.getFileImgParams(replydivid,'image');
			var att_params=ModCommentsCommon.getFileImgParams(replydivid,'filename');
			var params = ld.extend(img_params,att_params);
			if (ld(textBoxFieldobj).val() == '') {
				MessagePopup.TipOne_warning(arrJsPopLabel['FILLINCOMMENTS']);
				return;
			}
			var url = 'index.php?module=ModComments&action=ModCommentsAjax&file=DetailViewAjax&ajax=true&Create=true&ajxaction=WIDGETADDREPLY&parentid='+encodeURIComponent(parentid);
			url += '&replyedid='+replyedid;
            var commentcontent = ld(textBoxFieldobj).val();
            url += '&comment=' + encodeURIComponent(commentcontent);
			url += '&related_to_type=' + popupobj.module;
            url += '&related_to=' + popupobj.record;
            //获取用户名
            var str = "@";
            var newusernames = '';
            var reg = new RegExp(str);
            if(reg.test(commentcontent))
            {
                var objReplyContent = commentcontent.split("@"); 
                for(var i=1; i<objReplyContent.length; i++)
                {
                    newusernames += objReplyContent[i].substring(0,objReplyContent[i].indexOf(" "))+',';
                }
                url += '&newusernames=' + newusernames;
            }
			//puyoungJS_DialogBox.block();
			$("status").style.display="inline";
			ld('#'+popupobj.divid).find('#'+replydivid).css('pointer-events','none');
			ldAjax(url,params,function(data){
					 $("status").style.display="none"; 
					puyoungJS_DialogBox.unblock();
					if (data.code == 1) {
						ld(textBoxFieldobj).val('');
                        if(!empty(data.result.content)){
                            contentWrapDOM.outerHTML = data.result.content;
                        }
                        ld("#"+popupobj.divid+" #modcomment_id_"+parentid).find('textarea').not('.proName_note').autosize();
                        setModcommentEvent();
						// 清除 图片内容
						ld('#'+popupobj.divid+' #replycontent_'+replyedid+'_div').find('[name=upload_image]').css('display','none');
						ld('#'+popupobj.divid+' #replycontent_'+replyedid+'_div').find('[name=upload_filename]').css('display','none');
						ld('#'+popupobj.divid+' #replycontent_'+replyedid+'_div').find('#ModCommentsUpLoad').remove();
						ld('#'+popupobj.divid+' #replycontent_'+replyedid+'_div').find('[name=UploadhiddenInput_'+replyedid+'] input:not([tag=filenum])').remove();
						popupobj.ModcommentReplyId[replyedid] = 'no';
					}else if(data.code == -1){
						var confirm_str = data.msg;
                        ld(textBoxFieldobj).val('');
						RemindsMsg('','LdPopWidth400px','','yes','',confirm_str);
					}else{
						alert(arrJsPopLabel['OPERATION_DENIED']); 
					}
					ld('#'+popupobj.divid).find('#'+replydivid).css('pointer-events','all');
                    DelProgressObjs();
				
            });
		},
        //选择抄送范围
        selectCcrange: function(obj) {
            var popupobj = CrmPopup.getPopupObj('last');
            var selectUserid_arr = [];//默认选中的用户id
			var selectNum = 0;
            var ccrangedivobj = Tools.getParentobjByChild(obj,'div');
			ld(ccrangedivobj).find('ul.reader-bar-list li').each(function(){
				selectUserid_arr[selectUserid_arr.length] = ld(this).attr('userid');
				selectNum++;
			});
            selectUserid = selectUserid_arr.join(',');
			//选择抄送范围事件
			//setEventSelectUser('sendLogFoot > div[tag=ccrange]',selectNum,selectUserid.join(','));
            var div_tag = popupobj.divid+" #comment_ccrange";
            var module = 'ModComments';
        	var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module=ModComments&popup_inputtype=checkbox&checkprivilege=no';
        	//wym BUG0075532 kfbcrm-单据评论抄送范围-弹出层中应也有“显示离职成员”参数
			//wym BUG20240112-65 240119 kfbcrm-单据评论区，选择抄送范围，弹出层中“显示离职成员”“子部门默认收起”参数不能通过文字点击选中
            var popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+arrJsPopLabel['searchforcolleagues']+'\'><input id=\'viewuser_disableuser\' type="checkbox" ><label for="viewuser_disableuser">'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label><input id=\'viewuser_unfoldsubgroup\' class="marL10" type="checkbox"><label for="viewuser_unfoldsubgroup">'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
        	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
        		var scopepopupobj =  new ScopePopupObj(module);
        		scopepopupobj.popup_caption_value =arrJsPopLabel['LBL_SELECTUSER'];//标题
        		scopepopupobj.popup_searchvalue = arrJsPopLabel['searchforcolleagues'];//查询框默认值
        		scopepopupobj.popup_header = popup_header;
        		scopepopupobj.popup_searchTextDiv = '<div id=\'popup_search_div\' style=\'display: block;position: absolute;\'><div class=\'view-search\' ></div></div>';
        		scopepopupobj.popup_footer = '<div class="E_pbtn"><div>'+arrJsPopLabel['isselect']+'<span id="selectnum">0</span>/<span id="totalnum">77</span></div><div><input class="E_pbtnok" value="'+arrJsPopLabel['CONFIRME']+'" type="button"><span>&nbsp;</span>'+'<input class="E_pbtncancel" value="'+arrJsPopLabel['CANCEL']+'" type="button"></div></div>';
        		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
        			cls_ScopePopup.prop.popup_url = popup_url;//popup_url
        			cls_ScopePopup.prop.popup_module = module;//模块
        			cls_ScopePopup.prop.popup_value = selectUserid;
        			var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
        			ld('#'+cls_ScopePopup.popup_divid).css('z-index',"9999");
        			//加载用户总数和已选的用户数
        			scopepopupobj.setEventLoad=function(){
        				var selectUseridAll = [];//显示的全部用户数
        				var viewuser_nogroupuser = ld('#viewuser_nogroupuser').prop('checked');
        				ld('#'+cls_ScopePopup.popup_divid+' .filetree span').each(function(){
        					var record = ld(this).attr('record');
        					var recordarr = record.split('_');
        					//处理用户图标
        					if('user' == recordarr[0]){
        						var parentfilter = ld(this).attr('parent');
        						var parentarr = parentfilter.split('_');
        						if('Inactive' != parentarr[1] &&  'Inactive' != parentarr[2]){//因为停用用户不显示，所以在这不进行计算
        							if('nogroup' == parentarr[1]){
        							     selectUseridAll[selectUseridAll.length] = recordarr[1];
        							}else{
        								selectUseridAll[selectUseridAll.length] = recordarr[1];
        							}
        						}
        					}
        				});
        				var userAll = js_unique(selectUseridAll);
        				ld('#selectnum').html(selectNum);//已选
        				ld('#totalnum').html(userAll.length);//全部
        				ld('#viewuser_nogroupuser').unbind('click').on('click',function(){
        					cls_ScopePopups.noGroupUser('viewuser_nogroupuser');
        					if(!empty(cls_ScopePopup.return_obj.return_id)){
        						var userid = cls_ScopePopup.return_obj.return_id.split(',');
        						selectNum = userid.length;//已选
        					}else{
        						selectNum = 0;
        					}
        					scopepopupobj.setEventLoad();
        				});
        			}
        			//用户选择后的执行事件
        			scopepopupobj.setEventSelGroupByUsers=function(){
        				if(!empty(cls_ScopePopup.return_obj.return_id)){
        					var userid = cls_ScopePopup.return_obj.return_id.split(',');
        					ld('#selectnum').html(userid.length);//已选
        				}else{
        					ld('#selectnum').html(0);
        				}
        
        			}
        			//重写确认按钮事件
        			scopepopupobj.setEventBtnOk=function(){
        				ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){//231031 wym XUQIU1002054 点击确认,保存当前是否勾选显示离职成员并刷新首页下拉框
								if(ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser')){
									var displayinactiv=ld('#'+cls_ScopePopup.popup_divid+' #viewuser_disableuser').prop('checked');
									//wym 231115 BUG0075530 首页-数据简报穿透-取消勾选“显示离职成员” 与首页保持一致 关联需求:XUQIU1002054
									var tmpurlsting = 'index.php?module=Users&action=UsersAjax&file=viewInactiveusers&frommodule='+cls_ScopePopup.prop.popup_module+'&value='+displayinactiv;
									ldAjaxNoProgresssync(tmpurlsting,'',function(data){
									})
								}
        						//zkt 20230413 BUG0064750 kfbcrm-评论区-抄送范围可以不选择成员，但是点击抄送范围后，取消勾选抄送成员，会弹出至少选择一个成员的提示信息（直接把这个提示信息去掉） 
        						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
    							var userid = cls_ScopePopup.return_obj.return_id.split(',');
    							var username = cls_ScopePopup.return_obj.return_name.split(',');
    							//每次确认之前，先情况之前记录
    							ld('#'+div_tag+' ul.reader-bar-list').empty();
    							for(var i = 0; i < userid.length; i++){
    								//添加新的li
                                    if(!empty(userid[i])){
    								    ld('#'+div_tag+' ul.reader-bar-list').append('<li userid="'+userid[i]+'"><span class="item-name">'+username[i]+'</span><span class="remove-h">×</span></li>');
                                    }
                                    else{

                                    }
    								//绑定删除事件
    								ld('#'+div_tag+' ul.reader-bar-list li[userid='+userid[i]+'] .remove-h').unbind('click').click(function(){
    									var liuserid = ld(this).parent().attr('userid');
    									ld('#'+div_tag+' ul.reader-bar-list li[userid='+liuserid+']').remove();
    									return false;
    								});
    							}

								if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                                 {
                                            //通讯录(pc端企业微信)
                                            cls_wxOpenDataobj.bindAllOpenData();
                                 }

        				});
        			}
        		});
        	});
        }
	}
}