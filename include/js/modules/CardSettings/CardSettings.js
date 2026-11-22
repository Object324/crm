function CardSettings()
{
    var that=this;

	//名片信息设置
	this.CardInfoEdit = function (){
		var surl = 'index.php?module=CardSettings&action=CardSettingsAjax&file=CardinfoSettings&mode=edit';
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'CardSettings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.CardInfoSave,"","LdPopWidth800px",'CardSettings',"",data.result.oktext,"",data.result.canceltext);
				CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
			}
		})
	}
	//名片信息设置保存
	this.CardInfoSave = function (){
		var popupobj=CrmPopup.getPopupObj("last");

		var surl = "index.php?module=CardSettings&action=CardSettingsAjax&file=CardinfoSettings&mode=save";
		// var formValues = ld('#' + popupobj.divid + ' [name=CardInfoEdit]').serialize();

		// var formData = new FormData(document.getElementById("CardInfoEdit"));
		var formData = new FormData();
		if(ld('#'+popupobj.divid+' input[name=background]').get(0).files.length>0)
		{
			formData.append('background', ld('#'+popupobj.divid+' input[name=background]').get(0).files[0]);
		}
		if(ld('#'+popupobj.divid+' input[name=avatar]').get(0).files.length>0)
		{
			formData.append('avatar', ld('#'+popupobj.divid+' input[name=avatar]').get(0).files[0]);
		}

		if (ld('#'+popupobj.divid+' input[name=display_level]').is(":checked")) {
			formData.append('display_level','yes');
		}else{
			formData.append('display_level','no');
		}
		if (ld('#'+popupobj.divid+' input[name=display_company_name]').is(":checked")) {
			formData.append('display_company_name','yes');
		}else{
			formData.append('display_company_name','no');
		}
		if (ld('#'+popupobj.divid+' input[name=display_phone_mobile]').is(":checked")) {
			formData.append('display_phone_mobile','yes');
		}else{
			formData.append('display_phone_mobile','no');
		}
		if (ld('#'+popupobj.divid+' input[name=display_email]').is(":checked")) {
			formData.append('display_email','yes');
		}else{
			formData.append('display_email','no');
		}
		if (ld('#'+popupobj.divid+' input[name=display_company_phone]').is(":checked")) {
			formData.append('display_company_phone','yes');
		}else{
			formData.append('display_company_phone','no');
		}
		if (ld('#'+popupobj.divid+' input[name=display_company_address]').is(":checked")) {
			formData.append('display_company_address','yes');
		}else{
			formData.append('display_company_address','no');
		}

		ld('#rptContentLoading').show();
		ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: formData,
			url: surl,
			success: function(data) {
				popupobj.CancelEvent();
				if (data.code == 1) {
					that.refreshCardInfoHtml();
				}else{
					RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
				}
				// DelProgressObjs();
				return false;
			},
			error: function(xhr, textStatus, errorThrown) {
				//alert(2);
			}
		})

	}
	//名片信息设置保存后刷新页面
	this.refreshCardInfoHtml = function () {
		var url = 'index.php?module=CardSettings&action=CardSettingsAjax&file=CardinfoSettings';
		ldAjax(url, '', function (data) {
			if (data.code == 1){
				ld(" [name=SettingRightContent]").html(data.result.content);
				initRightContentHeight();//加载右侧内容中菜单和详细内容高度
			}
			DelProgressObjs();
		})
	}
	//上传图片文件检查文件名
	this.validateFilename = function (form_ele) {
		if (form_ele.value == '') return true;

		var value = getFileNameOnlys(form_ele.value);

		// Color highlighting logic
		var err_bg_color = "#FFAA22";

		if (typeof(form_ele.bgcolor) == "undefined") {
			form_ele.bgcolor = form_ele.style.backgroundColor;
		}
		// Validation starts here
		var valid = true;

		if (value!=undefined&&value.length > 255) {
			var confirm_str = arrJsPopLabel['FILENAMESCANOTEXCEED255CHAR'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			valid = false;
		}
		if(!/\.(gif|jpg|jpeg|png|bmp|ico|GIF|JPG|JPEG|PNG|BMP|ICO)$/.test(value))
		{
			var confirm_str = value+arrJsPopLabel['CANNOTUOLOAD']+','+arrJsPopLabel['THEALLOWEDTYPES']+'jpg、jpeg、gif、png、bmp、ico;';
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			form_ele.value = '';
			return false;
		}
		if (!valid) {
			form_ele.style.backgroundColor = err_bg_color;
			return false;
		}
		form_ele.style.backgroundColor = form_ele.bgcolor;



		var popupobj=CrmPopup.getPopupObj('last');
		if (popupobj != undefined){
			ld("#"+popupobj.divid+" [name=span_"+form_ele.name+"]").text(value);
		}else{
			ld(" [name=span_"+form_ele.name+"]").text(value);
		}
		return true;
	}

	//营销按钮设置 - 编辑显示input框
	this.MarketingShowEditInput = function (obj,mode,id,name) {
		if (mode == 'edit') {
			ld(' div[name=cur_btn_image' + id + ']').hide();
			ld(' div[name=div_btn_image' + id + ']').show();

			ld(' div[name=cur_btn_label' + id + ']').hide();
			ld(' div[name=div_btn_label' + id + ']').show();

			
            ld(' div[name=cur_link_url' + id + ']').hide();
            ld(' div[name=div_link_url' + id + ']').show();
            
		} else if(mode == 'cancel') {
			ld(' div[name=cur_btn_image' + id + ']').show();
			ld(' div[name=div_btn_image' + id + ']').hide();
			ld(' input[name=btn_image' + id + ']').val("");//取消选择的文件
			ld(' span[name=span_btn_image' + id + ']').text("");//清除显示的文件名

			ld(' div[name=cur_btn_label' + id + ']').show();
			ld(' div[name=div_btn_label' + id + ']').hide();
			ld(' input[name=btn_label' + id + ']').val(ld(' div[name=cur_btn_label' + id + ']').text());//还原按钮名称

			ld(' div[name=cur_link_url' + id + ']').show();
            ld(' div[name=div_link_url' + id + ']').hide();
			//仅“我要体验”设置链接
            if(name == 'experience'){
                ld(' input[name=link_url' + id + ']').val(ld(' div[name=cur_link_url' + id + ']').text());//还原体验链接
            }
		}
	};
	this.MarketingEditSave = function (obj,id,name) {
		// var btn_image = ld('#MarketingSettings [name=btn_image'+id+']').val();console.log(btn_image);
		// var btn_name = ld('#MarketingSettings [name=btn_name'+id+']').val();console.log(btn_name);
		// var link_url = ld('#MarketingSettings [name=link_url'+id+']').val();console.log(link_url);
		var surl = 'index.php?module=CardSettings&action=CardSettingsAjax&file=MarketingSettings&mode=save&id='+id;
		var formData = new FormData();
		if(ld('#MarketingSettings input[name=btn_image'+id+']').get(0).files.length>0)
		{
			formData.append('btn_image', ld(' input[name=btn_image'+id+']').get(0).files[0]);
		}
		formData.append('btn_label', ld(' input[name=btn_label'+id+']').val());
        var link_url = '';
        if(name == 'experience'){
            link_url = ld('#MarketingSettings [name=link_url'+id+']').val();
        }
		formData.append('link_url', ld(' input[name=link_url'+id+']').val());

		ld('#rptContentLoading').show();
		ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: formData,
			url: surl,
			success: function(data) {
				if (data.code == 1) {
					// ld(" [name=listcontent]").html(data.result.content);
					that.refreshMarketingHtml();
				}else {
					RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
				}
				DelProgressObjs();
				return false;
			},
			error: function(xhr, textStatus, errorThrown) {
				//alert(2);
			}
		})
	};
	//营销按钮设置 - 行操作 - 删除、启用、停用、上移、下移
	this.MarketingOperate = function (obj,mode,id) {
		var surl = 'index.php?module=CardSettings&action=CardSettingsAjax&file=MarketingSettings&mode='+mode+'&id='+id;
		ldAjax(surl,'',function(data){
			if(data.code==1){
				// ld(" [name=SettingRightContent]").html(data.result.content);
				// ld(" [name=listcontent]").html(data.result.content);
				that.refreshMarketingHtml();
				DelProgressObjs();
			}else{
				RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
				DelProgressObjs();
				return false;
			}
		})
	};

	//营销按钮右侧列表刷新
	this.refreshMarketingHtml = function () {
		var url = 'index.php?module=CardSettings&action=CardSettingsAjax&file=MarketingSettings&ajax=yes';
		ldAjax(url, '', function (data) {
			if (data.code == 1){
				ld(" [name=listcontent]").html(data.result.content);
				initRightContentHeight();//加载右侧内容中菜单和详细内容高度
			}
			DelProgressObjs();
		})
	}


    //公司简介设置
	this.CompanyProfileEdit = function () {
		var surl = 'index.php?module=CardSettings&action=CardSettingsAjax&file=CompanyProfileSettings&mode=edit';
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth1100px",'CardSettings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.CompanyProfileSave,"","LdPopWidth1100px",'CardSettings',"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.show(data.result.content);
                crmPopupobj.center();

				//富文本编辑框
					that.ue = UE.getEditor('brief');
					// that.ue.focus();
					that.ue.ready(function() {
						var id = ld('#brief').children("div:first-child").attr("id");
						ld('#'+id).css('z-index','99999');
						// crmPopupobj.center();
					},2);
					// UE.getEditor('recovery_endremarks').getContent();
					// UE.getEditor('recovery_endremarks').focus();
			}
		})
	}
    
    
    //公司简介设置保存
	this.CompanyProfileSave = function () {
		var popupobj=CrmPopup.getPopupObj("last");
		var organization_id = ld("#"+popupobj.divid+" [name=organization_id]").val();
		var brief_title = ld("#"+popupobj.divid+" [name=brief_title]").val();
		var brief = ld("#"+popupobj.divid+" [name=brief]").val();
        var video_link = ld("#"+popupobj.divid+" [name=video_link]").val();
		// console.log(brief);console.log(that.ue.getContent());return false;
		if (brief_title == "" )
		{
			var confirm_str = '标题' +arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			ld("#"+popupobj.divid+" [name=brief_title]").focus();
			return false;
		}
		else if (brief.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
		{
			var confirm_str = arrJsPopLabel['ABOUTUS'] +arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			ld("#"+popupobj.divid+" [name=brief]").focus();
			return false;
		}
        var urlstring ='index.php?module=CardSettings&action=CardSettingsAjax&file=CompanyProfileSettings&mode=save';
        var formData = new FormData();
        if(ld('#'+popupobj.divid+' input[name=brief_image]').get(0).files.length>0)
		{
			formData.append('image_main', ld('#'+popupobj.divid+' input[name=brief_image]').get(0).files[0]);
		}
        if(ld('#'+popupobj.divid+' input[name=video_cover]').get(0).files.length>0)
		{
			formData.append('video_cover', ld('#'+popupobj.divid+' input[name=video_cover]').get(0).files[0]);
		}
//        formData.append('organization_id', organization_id);
//        formData.append('brief_title', brief_title);
//        formData.append('brief', encodeURIComponent(brief));
//        formData.append('video_link', video_link);
        urlstring +='&organization_id='+organization_id+'&brief_title='+brief_title+'&brief='+encodeURIComponent(brief)+'&video_link='+video_link;
		
        ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: formData,
			url: urlstring,
			success: function(data) {
				popupobj.CancelEvent();
				if (data.code == 1) {
					that.refreshCompanyProfileHtml();
				}else{
					RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
				}
				// DelProgressObjs();
				return false;
			},
			error: function(xhr, textStatus, errorThrown) {
				//alert(2);
			}
		})

		return false;
	};
    //公司简介设置保存后刷新页面
	this.refreshCompanyProfileHtml = function () {
		var url = 'index.php?module=CardSettings&action=CardSettingsAjax&file=CompanyProfileSettings';
		ldAjax(url, '', function (data) {
			if (data.code == 1){
				ld(" [name=SettingRightContent]").html(data.result.content);
				initRightContentHeight();//加载右侧内容中菜单和详细内容高度
			}
			DelProgressObjs();
		})
	}
    
    //选择专题更新产品列表页面
    this.getTopicBlockLists = function (obj) {
        var topicid = ld(obj).val();
        var url = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings&ajax=yes&topicid='+topicid;
        ldAjax(url,"",function(data){
            if(data.code == 1){
                ld("[name=topicblocklist]").html(data.result.content);
                DelProgressObjs();
            }
        })
    }
    
    //专题板块设置——专题设置
	this.topicSet = function () {
		
        var crmPopupobj = CrmPopup.load("","","","350",'CardSettings',"","","","");
        crmPopupobj.prevshow();

        var url = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings&type=topicset&mode=gettopic';
        ldAjax(url, '', function (data) {
            if (data.code == 1) {
                crmPopupobj.setParams(data.result.title,that.saveTopicSet,"","350","CardSettings","",data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.show(data.result.content);
            }

        })
	};
    
    //启用(默认)、停用专题
    this.presenceTopic = function (obj) {
        if(ld(obj).hasClass('redFont')) {//该类会显示成红色（停用）
            ld(obj).removeClass('redFont');
            ld(obj).text('启用');
            ld(obj).attr('presence','no');
        } else {
            ld(obj).addClass('redFont');
            ld(obj).text('停用');
            ld(obj).attr('presence','yes');
        }
    };
    
    //保存专题
    this.saveTopicSet = function () {
        var url = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings&type=topicset&mode=savetopic';

        var popupobj = CrmPopup.getPopupObj("last");
        var trobjs = ld("#"+popupobj.divid+" [name=topic_table]").find("tr").not(":first");//不要第一个
        var topic_obj = '';
        var topic_array = new Array();
        var is_empty = false;
        ld.each(trobjs,function(tmpindex,tmptrobj){
            var topicid = ld(tmptrobj).attr("topicid");
            var topiclabel = ld(tmptrobj).find('input[name=topicid_'+topicid+']').val().trim();
            if (empty(topiclabel)) {
                is_empty = true;
                return false;//退出循环
            }
            var presence = ld(tmptrobj).find('a[name=presenceTopic]').attr("presence");
            topic_obj = new Object();
            topic_obj.topicid = topicid;
            topic_obj.topiclabel = topiclabel;
            topic_obj.presence = presence;
            topic_array.push(topic_obj);
        });

        if (is_empty) {
            RemindsMsg("","LdPopWidth400px","","yes","yes","专题名称不能为空");
            return false;
        }
        url += "&topiclists="+encodeURIComponent(JSON.stringify(topic_array));
        ldAjax(url, "", function (data) {
            popupobj.CancelEvent();
            if (data.code == 1) {
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['SUCCESSFULLYSAVED']);
                //确定按钮
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    that.refreshTopicBlockHtml();
                });
                DelProgressObjs();

            } else {
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['Savefailed']);
                DelProgressObjs();
                return false;
            }
        })

    };
    
    //刷新专题区块整个页面
    this.refreshTopicBlockHtml = function () {
        var url = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings';
        ldAjax(url, '', function (data) {
            if (data.code == 1){
                ld(" [name=SettingRightContent]").html(data.result.content);

                var selectobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=select]");
                if(selectobj.length>0&&selectobj!=undefined){
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
                    CrmPopup.global_listPopupObj=[];
                    var obj=new Object();
                    obj.divid="SettingRightContent";
                    CrmPopup.global_listPopupObj.push(obj);
                    obj.CancelEvent=function(){
                        return false;
                    }
                    cls_resetComboxHtmlobj.setPopupObj(obj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,150);
                    ld(' .grid-view-title').css('width', ld(' .grid-view-title').width()+20+'px');
                    ld(' .chzn-container').css('margin-top', '17px');
                    ld(' .chzn-drop').css('margin-left', '10px');
                }
                initRightContentHeight();//加载右侧内容中菜单和详细内容高度
            }
            DelProgressObjs();
        })
    }
    
    //选择默认图标事件
    this.getDefaultIcon = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var topicid = popupobj.topicid;
        var selectdiv=ld('#selectDefaultIcondiv').html();
        var crmPopupobj = CrmPopup.load("","","","600",'CardSettings',"","","","");
        crmPopupobj.prevshow();
        var url = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings&type=addblock&mode=getdefaulticon';
        url += '&topicid='+topicid;
        ldAjax(url, '', function (data) {
            if (data.code == 1) {
                crmPopupobj.setParams(data.result.title,that.chooseDefaultIcon,"","600","CardSettings","",data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.show(data.result.content);
                crmPopupobj.topicid = data.result.topicid;
                that.clickSelecticon();
            }
            DelProgressObjs();
        })
    }
    //点击图标选项查看图标事件
    this.clickSelecticon = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var sourceavailListObj = document.getElementById('defaultIconlistList');
        for (i=0;i<sourceavailListObj.length;i++)
        {
            if (sourceavailListObj.options[i].selected==true)
            {
                var newimage = sourceavailListObj.options[i].value;
                var newimageurl = ld(sourceavailListObj.options[i]).attr('tag');
                popupobj.selectedicon = newimage;
                popupobj.selectedicontext = sourceavailListObj.options[i].text;
                var imghtml = '<img src="'+newimageurl+'" style="width: 80px;height: 80px;"  border="0"/>';
                ld("#"+popupobj.divid+" div[name=defaultpreview]").html(imghtml);
                break;
            }
        }
        return ;
    }
    this.chooseDefaultIcon = function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var value = popupobj.selectedicontext;
        var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        prevpopupobj.selectedicon = popupobj.selectedicon;
        if (prevpopupobj != undefined){
			ld("#"+prevpopupobj.divid+" [name=span_defaultIconname]").text(value);
		}else{
			ld(" [name=span_defaultIconname]").text(value);
		}
        popupobj.CancelEvent();
    }
    
    //添加区块事件
    this.AddtopicBlock = function(obj,topicid){
        var titlename = ld("input[name = titlename]").val();
        if(titlename=='')
        {
            RemindsMsg("","LdPopWidth400px","","yes","",'请先设置标题名称');
            return false;
        }
        return false;
        var url = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings&type=addblock&mode=getaddblock';
        url += '&topicid='+topicid;
        
        var crmPopupobj = CrmPopup.load("","","","600",'CardSettings',"","","","");
        crmPopupobj.prevshow();
        ldAjax(url, '', function (data) {
            if (data.code == 1) {
                crmPopupobj.setParams(data.result.title,that.saveAddBlock,"","600","CardSettings","",data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.show(data.result.content);
                crmPopupobj.topicid = data.result.topicid;
                ld("#"+crmPopupobj.divid+" defaultIcon").attr("checked","checked");
            }
        })
    }
    //保存新建区块
    this.saveAddBlock = function(){
        var surl = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings&type=addblock&mode=saveblock';
        var popupobj = CrmPopup.getPopupObj('last');
        if(ld("#"+popupobj.divid).find(" input[name=topicid]")!=undefined||ld("#"+popupobj.divid).find(" input[name=topicid]").val()!=''){
            var topicid = ld("#"+popupobj.divid).find(" input[name=topicid]").val();
        }
        else {
            RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['Savefailed']);
            //确定按钮
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                popupobj.CancelEvent();
                var selectobj = ld("select[name=pick_topic]");
                that.getTopicBlockLists(selectobj);
            });
            return false;
        }
        
        var formData = new FormData();
        formData.append('topicid', topicid);
        var iconselect = ld("#"+popupobj.divid+" input[name='iconselect']:checked").val();
        if(iconselect=='defaultIcon'){
            if(popupobj.selectedicon!=''&&popupobj.selectedicon!=undefined)
    		{
    			formData.append('defaultIconname', popupobj.selectedicon);
                formData.append('defaultIcon', 'true');
    		}
            else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",'图标不能为空');
                return false;
            }
        }
        else if(iconselect=='localIcon'){
            if(ld('#'+popupobj.divid+' input[name=blockimagename]').get(0).files.length>0)
    		{
    			formData.append('blockimagename', ld('#'+popupobj.divid+' input[name=blockimagename]').get(0).files[0]);
    		}
            else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",'图标不能为空');
                return false;
            }
        }
        
        formData.append('blockname', ld('#'+popupobj.divid+' input[name=blockname]').val());
        formData.append('blockcontent', ld('#'+popupobj.divid+' input[name=blockcontent]').val());
        
        ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: formData,
			url: surl,
			success: function(data) {
				popupobj.CancelEvent();
				if (data.code == 1) {
					var selectobj = ld("select[name=pick_topic]");
                    that.getTopicBlockLists(selectobj);
				}else{
					RemindsMsg("","LdPopWidth400px","","yes","yes",msg);
                    return false;
				}
				// DelProgressObjs();
				return false;
			},
			error: function(xhr, textStatus, errorThrown) {
				//alert(2);
			}
		});
        return false;
    }
    //专题区块设置 - 行操作 - 删除、启用、停用
	this.TopicBlockOperate = function (obj,mode,id) {
		var surl = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings&type=blockoperate&mode='+mode+'&blockid='+id;
		ldAjax(surl,'',function(data){
			if(data.code==1){
				var selectobj = ld("select[name=pick_topic]");
                that.getTopicBlockLists(selectobj);
				DelProgressObjs();
			}else{
				RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
				DelProgressObjs();
				return false;
			}
		})
	};
    //输入框onchange事件
    this.topicinputSet=function(obj,mode){
        var url = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings&type=inputset&mode='+mode;
        var inputname = ld(obj).attr('name');
        var inputvaule = ld(obj).val();
        url += '&inputname='+inputname+'&inputvalue='+inputvaule;
        if(inputname == 'titlename' && inputvaule == '')
        {
            var oldtitlename = ld('input[name=oldtitlename]').val();
            ld(obj).val(oldtitlename);
            RemindsMsg("","LdPopWidth400px","","yes","yes",'标题名称不能为空');
            
            return false;
        }
        else{
            var titlename = ld("input[name = titlename]").val();
            if(titlename=='')
            {
                ld(obj).val('');
                RemindsMsg("","LdPopWidth400px","","yes","",'标题名称不能为空,请先设置标题名称');
                return false;
            }
        }
        if(mode == 'title'){
            var topicid = ld(obj).attr('tag');
            url += '&topicid='+topicid;
        }
        else if(mode == 'block'){
            var blockid = ld(obj).attr('tag');
            url += '&blockid='+blockid;
        }
        ldAjax(url, '', function (data) {
            if (data.code == 1) {
                
            }
            DelProgressObjs();
        })
    }
    //删除产品介绍图片
    this.Deleteproductimage = function(titleimageid){
        var surl = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings&type=titleimage&mode=delete&titleimageid='+titleimageid;
        ldAjax(surl, '', function (data) {
            if (data.code == 1) {
                var selectobj = ld("select[name=pick_topic]");
                that.getTopicBlockLists(selectobj);
            }
            DelProgressObjs();
        })
        return true;
    }
    //专题内上传图片
    this.Topicuploadimage = function(form_ele){
        if (form_ele.value == '') return true;

		var value = getFileNameOnlys(form_ele.value);
		var err_bg_color = "#FFAA22";

		if (typeof(form_ele.bgcolor) == "undefined") {
			form_ele.bgcolor = form_ele.style.backgroundColor;
		}
		var valid = true;
		if (value!=undefined&&value.length > 255) {
			var confirm_str = arrJsPopLabel['FILENAMESCANOTEXCEED255CHAR'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			valid = false;
		}
		if(!/\.(gif|jpg|jpeg|png|bmp|ico|GIF|JPG|JPEG|PNG|BMP|ICO)$/.test(value))
		{
			var confirm_str = value+arrJsPopLabel['CANNOTUOLOAD']+','+arrJsPopLabel['THEALLOWEDTYPES']+'jpg、jpeg、gif、png、bmp、ico;';
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			form_ele.value = '';
			return false;
		}
        
        var uploadtype = ld(form_ele).attr('tag');
        var formData = new FormData();
        if(uploadtype == 'block'){
            var surl = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings&type=blockoperate&mode=changeimage';
            var inputname = ld(form_ele).attr('name');
            var divobj = Tools.getParentobjByChild(form_ele,'div');
            var blockid = ld(divobj).attr('record');
            formData.append('blockid', blockid);
            if(ld(' input[name='+inputname+']').get(0).files.length>0)
    		{
    			formData.append('blockimagename', ld(' input[name='+inputname+']').get(0).files[0]);
    		}
            else{
                return false;
            }
        }
        else if(uploadtype == 'title'){
            var surl = 'index.php?module=CardSettings&action=CardSettingsAjax&file=TopicBlockSettings&type=titleimage&mode=add';
            var divobj = Tools.getParentobjByChild(form_ele,'div');
            var topicid = ld(divobj).attr('record');
            formData.append('topicid', topicid);
            if(ld('input[name=titleimagename]').get(0).files.length>0)
    		{
    			formData.append('titleimagename', ld('input[name=titleimagename]').get(0).files[0]);
    		}

            else{
                return false;
            }
        }
        else{
            return false;
        }
        
        ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: formData,
			url: surl,
			success: function(data) {
				if (data.code == 1) {
					var selectobj = ld("select[name=pick_topic]");
                    that.getTopicBlockLists(selectobj);
				}else{
					RemindsMsg("","LdPopWidth400px","","yes","yes",msg);
                    return false;
				}
				// DelProgressObjs();
				return false;
			},
			error: function(xhr, textStatus, errorThrown) {
				//alert(2);
			}
		});
		return true;
    }
}


function cardsettings_iconselectonclick(event){
    var popupobj = CrmPopup.getPopupObj('last');
    var iconselect = ld("#"+popupobj.divid+" input[name='iconselect']:checked").val();
    if(iconselect=='defaultIcon'){
        ld("#"+popupobj.divid+' div[name=localIcondiv]').hide();
        ld("#"+popupobj.divid+' div[name=defaultIcondiv]').show();
    }
    else if(iconselect=='localIcon'){
        ld("#"+popupobj.divid+' div[name=localIcondiv]').show();
        ld("#"+popupobj.divid+' div[name=defaultIcondiv]').hide();
    }
}
