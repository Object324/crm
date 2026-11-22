/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
//16222: 评论>新增,关于选择相关对象的问题
function setAccountInfo(account_id, account_name)
{
    
    document.getElementById('related_to').value=account_id;
    document.getElementById('related_to_name').value=account_name;
}

function set_return(id, name) {
    //相关评论
 var popupobj=CrmPopup.getPopupObj('last');
 popupobj.CancelEvent();
 popupobj=CrmPopup.getPopupObj('last');
 ld("#"+popupobj.divid+" [name=parent_comments]").val(id);
 ld("#"+popupobj.divid+" [name=parent_comments_display]").val(name);
}
//详情评论区块显示隐藏状态加载
function ModcommentblockRightload(Popupobj,frommodule){
    //给展开收起图标绑定事件
    var dividobj = ld('#'+Popupobj.divid);
    if(dividobj.find("#modcommentblock_Expanddiv").length>0){
        var modcommentblock_Expanddivobj = dividobj.find("#modcommentblock_Expanddiv");
        modcommentblock_Expanddivobj.unbind("click").bind("click",function(){
            var popupobj = CrmPopup.getPopupObj('last');
            var dividobj = ld('#'+popupobj.divid);
            var productDivObj = dividobj.find("[name=productDiv]");
            //BUG0066487 查看详情界面---当分录较多时---评论区块显示不出来
            if (productDivObj.length > 0){
                productDivObj.css('overflow','hidden');
            }
            var tmpfrommodule = ld(this).data('frommodule');
            var tmprecord = ld(this).data('record');
            var tmpmodcommentshow = ld(this).data('status');//获取展开收起状态
            if(empty(tmpfrommodule)||empty(tmpmodcommentshow)){
                return ;
            }
            //切换展开收起
            var iconobj = dividobj.find('#modcommenttag_icon');
            var modcommenttagobj = dividobj.find('#modcommentblock_parenttd #modcommentdiv');
            var changeiconobj = ld(this).find('[name=change_icon]')
            if(tmpmodcommentshow == 'yes'){
                //展开变收起
                tmpmodcommentshow = 'no';
                iconobj.css('display','');
                modcommenttagobj.css('display','none');
                ld(this).removeClass('ld-shadow-first');
                changeiconobj.removeClass('ld-fonticon-toright');
                changeiconobj.addClass('ld-fonticon-toleft');
                changeiconobj.attr("data-tip",arrJsPopLabel['EXPANSION']);
                ld('#modcommentblock_parenttd').css('width','60px');
            }
            else{
                //收起变展开
                tmpmodcommentshow = 'yes';
                iconobj.css('display','none');
                modcommenttagobj.css('display','');
                ld(this).addClass('ld-shadow-first');
                changeiconobj.removeClass('ld-fonticon-toleft');
                changeiconobj.addClass('ld-fonticon-toright');
                changeiconobj.attr("data-tip",arrJsPopLabel['COLLAPSE']);
                ld('#modcommentblock_parenttd').css('width','375px');
            }
            ld(this).data('status',tmpmodcommentshow);
            //界面宽度重新加载
            setProductDivWidth(popupobj);
            //记住展开收起状态
            localStorage.setItem(tmpfrommodule+'_right_modcommentshow',tmpmodcommentshow);
        });


        //本地缓存的评论展开状态显示
        var module_right_modcommentshow = 'no';
        if(localStorage.getItem(frommodule+'_right_modcommentshow') && localStorage.getItem(frommodule+'_right_modcommentshow') != ''){
            module_right_modcommentshow = localStorage.getItem(frommodule+'_right_modcommentshow');
        };
        var status = modcommentblock_Expanddivobj.data('status');
        if (status != module_right_modcommentshow){
            modcommentblock_Expanddivobj.click();
        }
    }
    //标签
    if(dividobj.find("#modcommenttag_tag_icon").length>0){
        dividobj.find("#modcommenttag_tag_icon").unbind('click').bind('click',function () {
            dividobj.find("#modcommentblock_Expanddiv").click();
        })
    }
    //评论
    if(dividobj.find("#modcommenttag_modcomment_icon").length>0){
        dividobj.find("#modcommenttag_modcomment_icon").unbind('click').bind('click',function () {
            dividobj.find("#modcommentblock_Expanddiv").click();
            var top = dividobj.find("#modcommentdiv #modcomment_srollto").offset().top;
            var relatelisttab_top = dividobj.find("[name=relatelisttab]").offset().top;
            var relatelisttab_height = dividobj.find("[name=relatelisttab]").height();
            var scrollobj=dividobj.find(" .DivCTable");
            var scrolltop = scrollobj.scrollTop();
            var height = top - relatelisttab_top - relatelisttab_height  + scrolltop;
            scrollobj.animate({scrollTop:height},100);
            var pagerecord = Popupobj.pagerecord;
            dividobj.find('#create_comment_'+pagerecord).focus();

        })
    }
    if (ld('#'+Popupobj.divid+' #modcommentblock_icon').length > 0){
        tooltip(ld('#'+Popupobj.divid+' #modcommentblock_icon').find('[tag=modcommentblock_icon]'), {transition: true, time: 200});
    }
}

//ljj 20240401 XUQIU1001924 PC端+移动端：模块单据详情界面：评论内容增加图片、附件 渲染图片附件插件
function setModcommentFileUploaderEvent() {
    var uploadFileobj = new WebUploadFile();
    globalModWebUploadType=uploadFileobj.uploadType();
    var popupobj=CrmPopup.getPopupObj('last');
    popupobj.ModcommentReplyId = {};
    if (popupobj.modcomment_fileImg_fieldobj == undefined){
        return false;
    }
    else {
        var modcomment_fileImg_fieldobj = popupobj.modcomment_fileImg_fieldobj;
    }
    var commentobj=ld("#"+popupobj.divid+" #comment_create_div");
    if(globalModWebUploadType=='cos') {
        getJsScript('include/js/webuploader/Speical_webUploaderCos.js', function () {
            if (!empty(modcomment_fileImg_fieldobj.image) && !empty(modcomment_fileImg_fieldobj.image.fieldName)){
                commentobj.find("[name=comment_image").special_powerWebUploadCos({
                    fileTypeDuplicate:'yes',	//附件类型判断
                    fileNameDuplicate:'yes',	//同名附件判断
                    mode:'',	//当前单据 create or edit
                    module:'ModComments',	//当前模块
                    parentdivid:'comment_create_div',
                    jsonData:'',	//edit data,编辑界面显示已上传的附件
                    record:'',	//单据单据id
                    admin:'',//是否是管理员
                    uitype:'69',
                    supportformat:'',//支持格式
                    inputFileName:modcomment_fileImg_fieldobj.image.fieldName		//选择附件后赋值标签的name
                });
            }

            if (!empty(modcomment_fileImg_fieldobj.filename) && !empty(modcomment_fileImg_fieldobj.filename.fieldName)){
                commentobj.find("[name=comment_filename").special_powerWebUploadCos({
                    fileTypeDuplicate:'yes',	//附件类型判断
                    fileNameDuplicate:'yes',	//同名附件判断
                    mode:'',	//当前单据 create or edit
                    module:'ModComments',	//当前模块
                    parentdivid:'comment_create_div',
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
            if (!empty(modcomment_fileImg_fieldobj.image) && !empty(modcomment_fileImg_fieldobj.image.fieldName)){
                commentobj.find("[name=comment_image").special_powerWebUpload({
                    fileTypeDuplicate:'yes',	//附件类型判断
                    fileNameDuplicate:'yes',	//同名附件判断
                    mode:'',	//当前单据 create or edit
                    module:'ModComments',	//当前模块
                    parentdivid:'comment_create_div',
                    jsonData:'',	//edit data,编辑界面显示已上传的附件
                    record:'',	//单据单据id
                    admin:'',//是否是管理员
                    uitype:'69',
                    supportformat:'',//支持格式
                    inputFileName:modcomment_fileImg_fieldobj.image.fieldName	//选择附件后赋值标签的name
                });
            }
            //渲染容器
            if (!empty(modcomment_fileImg_fieldobj.filename) && !empty(modcomment_fileImg_fieldobj.filename.fieldName)) {
                commentobj.find("[name=comment_filename").special_powerWebUpload({
                    fileTypeDuplicate:'yes',	//附件类型判断
                    fileNameDuplicate:'yes',	//同名附件判断
                    mode:'',	//当前单据 create or edit
                    module:'ModComments',	//当前模块
                    parentdivid:'comment_create_div',
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

}

//设置评论@功能
function setModcommentEvent(){
    var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj == undefined || popupobj.type != 'detailviewpage' || (ld("#"+popupobj.divid+" #modcommentdiv #ModCommentUsersDiv").length<=0)){
        return ;
    }
    //遮罩层点击事件
    ld("#"+popupobj.divid+" .ui-mask").unbind('click').on('click', function (){
		 ld(this).css({'display':'none','backgroundColor':'#fff'});
		 ld("#"+popupobj.divid+' .ui-popup-close').each(function(){
		 	if(!ld(this).is(':hidden')){
		 		ld(this).click();
		 	}
		 });
	});
    ld("#"+popupobj.divid+" #modcommentdiv ").find(" [data-tag=addtouch_at_btn]").unbind('click').on('click',function(event){
        //添加透明背景遮罩
		ld("#"+popupobj.divid+" .ui-mask").css({'display':'block','backgroundColor':'transparent'});
        obj=ld(this);
    	var ModCommentUsersobj = ld("#"+popupobj.divid+" #modcommentdiv #ModCommentUsersDiv");
        var type = ld(this).data('type');
		//再次点击时，清空文本框内的值
		ld(ModCommentUsersobj).find('#searchColleagueText').val('');
		CommentUserPopupInit(popupobj,obj,event,function(){
		    var replycontentdivobj = ld(obj).parent().parent();
            var modcommentid = ld(obj).data('modcommentid');
			if('' != ld("#"+popupobj.divid+' #modcommentdiv  #ColleagueDiv').html()){
				//用户弹出框样式绑定
				ld("#"+popupobj.divid+' #modcommentdiv  #ColleagueDiv > div').unbind('click').click(function(){
				    if(iskehu001=='yes'){
				        ld(replycontentdivobj).find(' #create_'+type+'_'+modcommentid).val(
    						ld(replycontentdivobj).find(' #create_'+type+'_'+modcommentid).val() + '@'	+
    						ld(this).attr('realname')+' '
    					);
				    }
                    else{
                        ld(replycontentdivobj).find(' #create_'+type+'_'+modcommentid).val(
    						ld(replycontentdivobj).find(' #create_'+type+'_'+modcommentid).val() + '@'	+
    						ld(this).find('span').html()+' '
    					);
                    }
                    //zkt 20230406 BUG0063546 kfbcrm 评论区选中需要@的人后 弹出框应该直接关闭 
                    ld("#"+popupobj.divid+" .ui-mask").click();
                    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                    {
                        //通讯录(pc端企业微信)
                        cls_wxOpenDataobj.bindAllOpenData();
                    }
				});
			}
			ld("#"+popupobj.divid+' #modcommentdiv #ColleagueDiv').css('display','');
			ld("#"+popupobj.divid+' #modcommentdiv #searchColleagueText').css('display','none');//隐藏搜索框
			//用户搜索框placeholder属性赋值
			ld("#"+popupobj.divid+' #modcommentdiv #searchColleagueText').css('display','');//显示搜索框
			ld("#"+popupobj.divid+' #modcommentdiv #searchColleagueText').attr('placeholder','搜索同事');
			ld("#"+popupobj.divid+' #modcommentdiv #searchColleagueText').attr('tag',3);//
            ld("#"+popupobj.divid+' #searchColleagueText').data('modcommentid',modcommentid);
            ld("#"+popupobj.divid+' #searchColleagueText').data('modcommenttype',type);
            setTimeout(function(){
                ld("#"+popupobj.divid+' #modcommentdiv #searchColleagueText').focus();
            },50);
		});
	});
    
    //zkt 20230324 BUG0063533 发表评论时的问题：选择抄送范围默认当前用户没问题，但是不能删除 
    ld('#'+popupobj.divid+' #modcommentdiv #comment_ccrange ul.reader-bar-list  .remove-h').unbind('click').click(function(){
		ld(this).parent().remove();
		return false;
	});
    //获取 抄送范围
    ld("#"+popupobj.divid+" #modcommentdiv ").find(" [data-tag=modcommenttip]").unbind('click').on('click',function(event){
        var remindusers = ld(this).data('remindusers');
        var obj = ld(this);
        var urlstring = 'index.php?module=ModComments&action=ModCommentsAjax&file=DetailViewAjax';
		urlstring += '&ajxaction=getRemindUserList&remindusers='+remindusers;
        //$("status").style.display="inline";
		ldAjaxNoProgress(urlstring,"",function(data){
		     //$("status").style.display="none";
             var dataObj=data.result;
             var strhtml="";
             //zkt 20230424 BUG0065187 kfbcrm 评论--点击回复中的抄送同事---弹出框应该紧挨着回复框 
			 var parentdivobj = Tools.getParentobjByChild(ld(obj),'div');
             var modcommentid = ld(obj).data('modcommentid');//评论或回复id
             
             if(ld("#"+popupobj.divid+' #modcommentdiv #modcommentcc-tip-'+modcommentid).length<=0){
                 var modcommenttiphtml = '<div class="fs-tip" id="modcommentcc-tip-'+modcommentid+'"  style="display: none; position: absolute; top: 1062px;">'
        	     modcommenttiphtml +='<span class="close">×</span>';
                 modcommenttiphtml +='<div class="share-group-tpl">';
                 modcommenttiphtml +='<div class="share-group-warp">';
                 modcommenttiphtml +='</div>';
                 modcommenttiphtml +='<div class="share-group-countman">';
                 modcommenttiphtml +='共<span class="num">12</span>人';
                 modcommenttiphtml +='</div>';
                 modcommenttiphtml +='</div>';
                 modcommenttiphtml +='<div class="arrows-wrapper arrows-t">';
                 modcommenttiphtml +='<div class="arrows-inner"></div>';
                 modcommenttiphtml +='</div>';
                 modcommenttiphtml +='</div>';
                 ld(parentdivobj).append(modcommenttiphtml);
             }
             var modcommenttipobj = ld("#"+popupobj.divid+' #modcommentdiv #modcommentcc-tip-'+modcommentid);
             ld(modcommenttipobj).find(' .share-group-tpl .share-group-warp').html("");
             if(dataObj.list){
            	for(var i=0;i<dataObj.list.length;i++){
	                strhtml+='<div class="share-group-items pubclear"> ';
	                strhtml+='<a class="profileimage" href="javascript:;"> ';
	                strhtml+=' <img src="';
	                strhtml+=dataObj.list[i].userimage;
	                strhtml+=' "/> ';
	                strhtml+=' </a>  <span class="name fontblue">';
	                strhtml+=dataObj.list[i].username;
	                strhtml+='</span> <span class="infotype"></span></div>';
	            }
            }
             //zkt 20240403 BUG20240403-05  客户单据查看详情界面，评论抄送发布后，抄送范围下拉选项中没有显示具体成员
            ld(modcommenttipobj).find(' .share-group-tpl .share-group-warp').html(strhtml);
            ld(modcommenttipobj).find(' .share-group-countman .num').html(dataObj.usercount);
            var tagName = getId('modcommentcc-tip-'+modcommentid);
            
            CommentUsersDivFindEvent(popupobj,obj,tagName,event);
            if(dataObj.usercount > 0){
                tagName.style.zIndex = ld(popupobj).get(0).oWin.style.zIndex+1;
            	tagName.style.display="block";
            }
            else{
            	tagName.style.display="none";
            }
            
            ld(modcommenttipobj).click(function(e) { 
				e?e.stopPropagation():event.cancelBubble = true; 
			});
			ld(document).click(function() {
				ld(modcommenttipobj).fadeOut();
			});
            ld(modcommenttipobj).find(' .close').on('click',function(){
                ld(modcommenttipobj).css('display','none');
                var Publisherobj = ld(obj).parent().parent().parent().parent();//获取点击a所在头部
                ld(Publisherobj).css('overflow','hidden');
            });
        })
    })
}
function CommentUserPopupInit(popupobj,obj,event,callback){
	var ModCommentUsersobj = ld("#"+popupobj.divid+" #modcommentdiv #ModCommentUsersDiv");
    tagName = ModCommentUsersobj.get(0);
	if(typeof tagName == 'undefined') return false;

	ld("#"+popupobj.divid+' #modcommentdiv #ModCommentUsersDiv').find('.ui-popup-close').unbind('click').click(function(){//隐藏
		ld('#ModCommentUsersDiv').css('display','none');
		ld(".ui-mask").css('display','none');
	});
 	var userColleagueArray=Array();
	CommentUsersDivFindEvent(popupobj,obj,tagName,event);
	var urlstring = 'module=ModComments&action=ModCommentsAjax&file=WorkReportIndex';
	urlstring += '&method=getUsers';
	RequestAjax(urlstring,function(rest){
		if('' == rest) return false;
		var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
		var userhtml = '';
		if('' != restobj.Colleague){
			var i = 0;
			ld.each(restobj.Colleague,function(userkey,userobj){
				userhtml += '<div userid="'+userobj.userid.value+'" realname="'+userobj.realname.value+'"><img src="'+userobj.userimgpath.value+'"><span>'+userobj.lastname.value+'</span></div>';
				userColleagueArray[i] = new Array();
				userColleagueArray[i]['userid'] =userobj.userid.value;
				userColleagueArray[i]['userimgpath'] = userobj.userimgpath.value;
				userColleagueArray[i]['lastname'] = userobj.lastname.value;
                userColleagueArray[i]['realname'] = userobj.realname.value;
				i++;
			});
            popupobj.modcomment = {'userColleagueArray':userColleagueArray};
		}

        ld("#"+popupobj.divid+' #modcommentdiv #ColleagueDiv').html(userhtml);
         
         if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
         {
                    //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
         }
		callback();
		tagName.style.display = '';
		DelProgressObjs();
	});
}

function CommentUsersDivFindEvent(popupobj,obj,tagName,event){
    if(popupobj == undefined){
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj == undefined || popupobj.type != 'detailviewpage' || (ld("#"+popupobj.divid+" #modcommentdiv #ModCommentUsersDiv").length<=0)){
            return ;
        }
    }
    var tmpobj = Tools.getParentobjByChild(ld(obj),'td');
    var topSide = findPosY(obj.get(0));
    var leftSide = findPosX(obj.get(0));
    var cur_left = ld(popupobj).get(0).oWin.offsetLeft;
    var cur_top = ld(popupobj).get(0).oWin.offsetTop;
    var modcommentblock_parenttdobj = ld("#"+popupobj.divid+" #modcommentblock_parenttd");
    var modcommentblock_paddingtdobj = ld("#"+popupobj.divid+" #modcommentblock_paddingtd");
    if(ld(obj).data('tag') == 'addtouch_at_btn'){
        var ModCommentUsersobj = ld("#"+popupobj.divid+" #modcommentdiv #ModCommentUsersDiv");
        if(ld(document).height()-(topSide-cur_top+obj.get(0).offsetHeight) < 280){
            ld(ModCommentUsersobj).css('bottom', ld(document).height()-topSide+cur_top+'px').css('top', 'auto').css('left', obj.get(0).offsetLeft+'px');
        }else{
            ld(ModCommentUsersobj).css('top', topSide-cur_top+obj.get(0).offsetHeight+'px').css('bottom', 'auto').css('left', obj.get(0).offsetLeft+'px');
        }
	}
    if(ld(obj).data('tag') == 'modcommenttip'){
        var Publisherobj = ld(obj).parent().parent().parent().parent();//获取点击a所在头部
        var Publisherheight = ld(Publisherobj).get(0).offsetHeight;
        ld(Publisherobj).css('overflow','inherit');
        //基础高度：评论或回复区块开始的高度，防止添加高度之后变矮了 
        var headerheight = 52;
        if(ld(obj).data('type') == 'reply'){
            headerheight = 44;
        }
        ld(Publisherobj).css('height',Publisherheight>headerheight?Publisherheight:headerheight+'px');
        //40 左侧图片宽度   left值
       cur_left = obj.get(0).offsetLeft-40+(obj.get(0).offsetWidth/2)-tagName.offsetWidth+ld(tagName).find(' .arrows-wrapper').offsetWidth;
       ld(tagName).css('top', Publisherheight+'px').css('left', cur_left+'px');
       ld(tagName).find(' .arrows-wrapper').css('left',(obj.get(0).offsetLeft-40)+'px');
	}
}
//给选择用户层加载拖动事件
function CommentWinPopup(popupobj,idstring){
    if(popupobj == undefined){
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj == undefined || popupobj.type != 'detailviewpage' || (ld("#"+popupobj.divid+" #modcommentdiv #ModCommentUsersDiv").length<=0)){
            return ;
        }
    }
	var box = ld("#"+popupobj.divid+" #modcommentdiv #"+idstring).get(0);
    if(box == undefined){
        return ;
    }
    //var box = document.getElementById(idstring);
	var inputs = box.getElementsByTagName('*');
	var inputlen = inputs.length;    
    var pointer = 'ui-popup-cursor';
	var close = 'ui-popup-close';    
	var header;var aClass = [];var dClass = [];
	var reClass = new RegExp("(^| )" + pointer + "( |$)");
	var closeCls = new RegExp("(^| )" + close + "( |$)");
	for(var i=0; i<inputlen; i++){
		reClass.test(inputs[i].className) && aClass.push(inputs[i]);
		closeCls.test(inputs[i].className) && dClass.push(inputs[i]);
	}
    var clslen = 0;
	if(aClass && aClass.length > 0){
	   clslen = aClass.length;
	}
	var scrollHeight = window.screen.availHeight,
	scrollWidth = window.screen.availWidth;
    if(clslen > 0){
        for(var i=0; i<clslen; i++){
            aClass[i].style.cursor = 'move';
            aClass[i].onmousedown = function(event){//鼠标按钮被按下
                box.style.opacity = 0.5;
                box.style.filter = "alpha(opacity=50)";
		    			var event = window.event || event;
		    			var mouseX = event.clientX,
		    			mouseY = event.clientY;
		    			var boxtop,boxleft;
		    			if(box.style.top) boxtop = box.style.top;
		    			else boxtop = box.offsetTop+document.body.scrollTop;
		    			if(box.style.left) boxleft = box.style.left;
		    			else boxleft = box.offsetLeft;
		    			objY = parseInt(boxtop),
		    			objX = parseInt(boxleft);
		    			document.onmousemove = function(event){
		    				var event = window.event || event;
		    				box.style.top = event.clientY - mouseY + objY + "px",
		    				box.style.left =event.clientX - mouseX + objX + "px";
		    			}
		               
		    			document.onmouseup = function(){//鼠标按键松开
		    				box.style.opacity = 1;
		    				box.style.filter = "alpha(opacity=100)";
		    				document.onmousemove = null;
		    			}
		    			return false;
	    			}
	    		}       
    }
	if(!dClass || !dClass.length) return false;
	clslen = dClass.length;var cls,clslock
	for(var i=0; i<clslen; i++){
		cls = dClass[i];
		dClass[i].onclick = function(){
			if('' != cls.getAttribute('lock')){
				clslock = cls.getAttribute('lock');
				if('lock' == clslock){
					puyoungJS_DialogBox.unblock();
				}else if(document.getElementById(clslock) != undefined){
					document.getElementById(clslock).style.display = 'none';
				}
			}
			box.style.display = 'none';
            ld(".ui-mask").css('display','none');
		};
	}
}
//搜索同事、部门
function CommentclickSelectControl(obj,event){
    var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj == undefined || popupobj.type != 'detailviewpage' || (ld("#"+popupobj.divid+" #modcommentdiv #ModCommentUsersDiv").length<=0)){
        return ;
    }
    if(ld('#'+popupobj.divid+' #searchColleagueText').attr('tag') != undefined){
        var searchColleagueText = ld('#'+popupobj.divid+' #searchColleagueText').attr('tag');
		var searchpinyin = new Array();//匹配值
		var searchPin = '';//匹配值的拼音
		var seacrchValue = '';//搜索的值
		var isSel=0;
		var userhtml = '';
		var grouphtml = '';
        var userColleagueArray =popupobj.modcomment.userColleagueArray;
		if(userColleagueArray.length > 0){
            if(iskehu001=='yes'){
                EmptyProgressObjs();//清空
                if('' == obj.value){
                    ld.each(userColleagueArray,function(key,userobj){
                        userhtml += '<div userid="'+userobj.userid+'" realname="'+userobj.realname.value+'"><img src="'+userobj.userimgpath+'"><span>'+userobj.lastname+'</span></div>';
                    });
                    ld('#'+popupobj.divid+' #ColleagueDiv').html(userhtml);	
                    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                    {
                        //通讯录(pc端企业微信)
                        cls_wxOpenDataobj.bindAllOpenData();
                    }
                    CommentCoorSearchResult();
                        return ;
                }
		        ldAjaxNoProgress("index.php?module=Users&action=UsersAjax&file=searchUserByKehu001&iskehu001="+iskehu001,{'searchvalue':obj.value},function(data){
                    if(data.result.list.length>0){
                        ld.each(userColleagueArray,function(key,userobj){
                            if(ld.inArray(userobj.userid,data.result.list)>=0){
                                userhtml += '<div userid="'+userobj.userid+'" realname="'+userobj.realname.value+'"><img src="'+userobj.userimgpath+'"><span>'+userobj.lastname+'</span></div>';
                            }
                        });
                        ld('#'+popupobj.divid+' #ColleagueDiv').html(userhtml);	
                        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                        {
                            //通讯录(pc端企业微信)
                            cls_wxOpenDataobj.bindAllOpenData();
                        }
                        CommentCoorSearchResult();
                    }
                    
                });
    		}
            else{
                getJsScript('include/js/multipingyin.js',function(){
                    ld.each(userColleagueArray,function(key,userobj){
                        if('' != obj.value){
                            seacrchValue = userobj.lastname.indexOf(obj.value);
                            searchpinyin = makePy(userobj.lastname);
                            searchPin = searchpinyin.join("").toLowerCase();
                            var selP = searchPin.indexOf(obj.value);
                            if(seacrchValue >=0 || selP >= 0){
                                userhtml += '<div userid="'+userobj.userid+'" realname="'+userobj.realname.value+'"><img src="'+userobj.userimgpath+'"><span>'+userobj.lastname+'</span></div>';
            				}
                        }
                        else{
                            userhtml += '<div userid="'+userobj.userid+'" realname="'+userobj.realname.value+'"><img src="'+userobj.userimgpath+'"><span>'+userobj.lastname+'</span></div>';
            			}
                    });
                    ld('#'+popupobj.divid+' #ColleagueDiv').html(userhtml);	
                    CommentCoorSearchResult();
               });
            }
		}
	}
}
function CommentCoorSearchResult()
{   
    var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj == undefined || popupobj.type != 'detailviewpage' || (ld("#"+popupobj.divid+" #modcommentdiv #ModCommentUsersDiv").length<=0)){
        return ;
    }
    var searchColleagueText = ld('#'+popupobj.divid+' #searchColleagueText').attr('tag');
	if(searchColleagueText == 3){//@
		var modcommentid =  ld('#'+popupobj.divid+' #searchColleagueText').data('modcommentid');//评论id
        var type = ld('#'+popupobj.divid+' #searchColleagueText').data('modcommenttype');//评论type
		var objs = ld('#'+popupobj.divid+' #create_'+type+'_'+modcommentid);
		if('' != ld('#'+popupobj.divid+' #ColleagueDiv').html()){
			//用户弹出框样式绑定
			ld('#'+popupobj.divid+' #ColleagueDiv > div').unbind('click').click(function(){
			     if(iskehu001=='yes'){
			         ld(objs).val(
    					ld(objs).val() + '@'	+
    					ld(this).attr('realname')+' '
    				);
			     }
                 else{
    				ld(objs).val(
    					ld(objs).val() + '@'	+
    					ld(this).find('span').html()+' '
    				);
                }
                ld("#"+popupobj.divid+" .ui-mask").click();
                 if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                {
                                //通讯录(pc端企业微信)
                                
                        cls_wxOpenDataobj.bindAllOpenData();
                } 
			});
		}
	}
}

function changeMode(obj){
    var popupobj = CrmPopup.getPopupObj('last');
    var record = popupobj.record;
    var modulename = popupobj.module;
    var mode = ld(obj).data('commentmode');
    if(mode=='advanced'){
        mode = 'concise';
    }else{
        mode = 'advanced';
    }
    var urlstring = 'index.php?module=Users&action=UsersAjax&file=getDetailBlock&modulename='+modulename+'&commentmode='+mode+'&recordid='+record+'&modechange=yes&setype=ModComments';
    
    ldAjax(urlstring,'',function(data) {
        if(data.code == 1){
            ld("#" + popupobj.divid + " #modcommentdiv").html('');
            ld("#" + popupobj.divid + " #modcommentdiv").html(data.result.content);
            DelProgressObjs();

            if(mode == 'advanced'){
                getJsScript('include/js/modules/ModComments/ModComments.js',function(){
                    CommentWinPopup(popupobj,"ModCommentUsersDiv");
                    setModcommentEvent();
                })
            }
            // tooltip('.tip-items-list',{transition: true, time: 200});
        }
        //ld(obj).data('commentmode',mode);
        //ld("#modcommentdiv").html().show;
    });
}
