function OrganizationConfig(){
   var that=this;
   this.ue = '';
}

//公司信息恢复默认          
OrganizationConfig.restorethedefaultlogo = function() {
    var affirmrestorelogo = arrJsPopLabel['AFFIRMRESTORELOGO'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",affirmrestorelogo);
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        var surl = 'index.php?module=Settings&action=OrganizationConfig&parenttab=Settings&ReportHeader=dheader';
        surl +='&restorelogo=true';
        ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
            ld("[class='logo-pic logo-pic-normal'][tag=logo-pic]").attr("src",'dataCache/test/logo/'+data.result.logoname);
            ld("[class='logo-pic logo-pic-mini'][tag=logo-pic]").attr("src",'dataCache/test/logo/'+data.result.small_logoname);
        }
        DelProgressObjs();
	    })
	})
}
//登陆界面自定义设置恢复默认
OrganizationConfig.restorethedefaultlogo_login = function() {
    var affirmrestorelogo = arrJsPopLabel['AFFIRMRESTORELOGO'];
    
    RemindsMsg("","LdPopWidth400px","","yes","yes",affirmrestorelogo);
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        var surl = 'index.php?module=Settings&action=LoginSettings&parenttab=Settings&ReportHeader=dheader';
        surl +='&restorelogo_login=true';
        ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(" [name=SettingRightContent]").html(data.result.content);
            ld("[class='logo-pic logo-pic-normal'][tag=logo-pic]").attr("src",'dataCache/test/logo/'+data.result.logoname);
            ld("[class='logo-pic logo-pic-mini'][tag=logo-pic]").attr("src",'dataCache/test/logo/'+data.result.minilogoname);
            initRightContentHeight();
        }
        DelProgressObjs();
	    })
	})
}

//刷新
OrganizationConfig.refresh = function(){
	var surl = 'index.php?module=Settings&action=OrganizationConfig&parenttab=Settings&ReportHeader=dheader';
	ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
		}
        DelProgressObjs();
	})
}

//编辑
OrganizationConfig.edit = function(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=EditCompanyDetails';
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,OrganizationConfig.save,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
            var logo_type_array = ['big','small'];
			crmPopupobj.imgInfo = {};
            ld.each(logo_type_array, function(index, value) {
				crmPopupobj.imgInfo[value]={imgurl:"",imgname:""};
				tooltip('#'+crmPopupobj.divid+' .imgContainer.'+value,{transition:true,time:200});
                ld('#'+crmPopupobj.divid+' #overlay_Img_'+value).unbind('click').bind('click',function(){
					if(crmPopupobj.imgInfo[value]['imgname']==""){
						var prev_name = ld(this).data('prevname');
						crmPopupobj.imgInfo[value]['imgname']= prev_name;
					}
					var suggest_info =arrJsPopLabel[ld(this).data('suggest')] ;//专有提示
					//suggest_info += suggest_info+'<br>'+ '其他通用提示语'
				    var width =ld(this).data('width');
				    var height =ld(this).data('height');
                    var showbox = ld(this).data('showbox');
					var showname = ld(this).data('showname');
					var cutImgObj = new cutImg();
					cutImgObj.lastPrevPop = crmPopupobj;
					cutImgObj.label = value;
					cutImgObj.imgShowBox = showbox;
					cutImgObj.imgShowName = showname;
					cutImgObj.openPop(suggest_info,width,height);
				})
            });
		}
	})
}
OrganizationConfig.bind_evt = function (obj) {
	ld(obj).on('click',function() {

		var div_obj = ld(this).find('.brief_class');
		//显示textarea,隐藏div
		OrganizationConfig.editText(div_obj)
	});
	ld(obj.find('textarea')).on('blur', function() {
		var textarea_obj = ld(this);
		setTimeout(() => {
			OrganizationConfig.saveText(textarea_obj)
		}, 150);
	});
}
/***
 * zxm
 * 2020-0922
 * 灵当云小程序 需要的公司简介 关于我们 公司简介的编辑
 */
OrganizationConfig.aboutusedit = function(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=EditAboutUs';
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,OrganizationConfig.saveBrief,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.show(data.result.content);
			var popupobj = CrmPopup.getPopupObj('last');
			var divid = popupobj.divid;
			var drag_obj = ld("#"+divid+"").find('tbody').get(1);
			Sortable.create(drag_obj, {
				animation: 150,
				handle: ".drag-handle",
				onEnd: function (evt){
					OrganizationConfig.sort_brief(evt,drag_obj);
				}
			});
			tooltip('.tip-items-list',{transition:true,time:200});
			OrganizationConfig.bind_mouseenterleave(ld(drag_obj).find('tr[name=brief]'));
			var td_obj = ld("#"+divid+" .ld-table-container > table >tbody td[name=td_brief]");
			OrganizationConfig.bind_evt(td_obj);
		}
	})
}
/***
 * zxm
 * 2020-0922
 * 灵当云小程序 需要的公司产品简介 公司产品简介编辑
 */
OrganizationConfig.productedit = function(id){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=EditCompanyProduct';
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,{id:id},function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,OrganizationConfig.saveProduct,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.show(data.result.content);
			var popupobj = CrmPopup.getPopupObj('last');
			var divid = popupobj.divid;
			var drag_obj = ld("#"+divid+"").find('tbody').get(1);
			Sortable.create(drag_obj, {
				animation: 150,
				handle: ".drag-handle",
				onEnd: function (evt){
					OrganizationConfig.sort_brief(evt,drag_obj);
				}
			});
			tooltip('.tip-items-list',{transition:true,time:200});
			OrganizationConfig.bind_mouseenterleave(ld(drag_obj).find('tr[name=brief]'));
			var td_obj = ld("#"+divid+" .ld-table-container > table >tbody td[name=td_brief]");
			OrganizationConfig.bind_evt(td_obj);
		}
	})
}
/**
 * zxm
 * 2020-9-22
 * 公司产品简介信息删除
 */
//wsh 公司产品简介信息删除 240911
OrganizationConfig.productdel = function(id,obj){
	var tr_obj = ld(obj).parents("#" + id + "");
	var alert_str = arrJsPopLabel['SUREWANTDELETE'];
	RemindsMsg("","LdPopWidth400px","LinkModuleCustom","yes","yes",alert_str);
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=delCompanyProduct';
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
		ldAjaxNoProgress(surl,{id:id},function(data){
			if (data.code == 1){
				tr_obj.remove();
			}
		});
	});
}

//wsh 列表编辑 显示div,隐藏textarea 240911
OrganizationConfig.saveText = function (obj) {
	var textarea_obj = ld(obj);
	var textarea_val = textarea_obj.val();
	var div_obj = textarea_obj.prev();
	div_obj.text(textarea_val);
	div_obj.show();
	textarea_obj.hide();
}
//wsh 显示textarea,隐藏div
OrganizationConfig.editText = function (obj) {
	var div_obj = ld(obj);
	var textarea_obj = div_obj.next();
	textarea_obj.text(div_obj.text());
	div_obj.hide();
	textarea_obj.show();
	//自动计算textarea高度
	textarea_obj.each(function () {
		this.style.height = 'auto';
		this.setAttribute('style', 'height:' + (this.scrollHeight) + 'px;overflow-y:hidden;');
	}).on('input', function () {
		this.style.height = 'auto';
		this.style.height = (this.scrollHeight) + 'px';
	});
	textarea_obj.focus();
}
/**
 * zxm
 * 2020-9-22
 * 公司简介信息添加
 */

//简介信息增加 wsh 240911
OrganizationConfig.addabrief = function(obj) {
	var table = ld(obj).parent().prev();
	var tbody = table.find('tbody');
	//判断数据条数
	var length_obj = table.find('[name=td_brief]');
	var length = length_obj.length;
	let label_num = length + 1;
	//增加后简介数量变为5，则设置增加不显示
	if (label_num == 5) {
		obj.hide();
	}
	tbody.append(
		'                <tr id="tr_'+length+'" name="brief">\n' +
		'                    <td name="td_one">'+label_num+'</td>\n' +
		'                    <td name="td_brief" style="cursor: pointer;">\n' +
		'                        <div style="padding: 10px">\n' +
		'                            <div style="line-height: 24px; font-size: 13px;padding: 0 8px;" class="brief_class" name="brief[]"></div>\n' +
		'                            <textarea class="ld-textarea-inner" name="brief[]"></textarea>\n' +
		'                        </div>\n' +
		'                    </td>\n' +
		'                    <td class="sort_td">\n' +
		'                        <div class="displayflex flexcenter">\n' +
		'                            <a class="tip-items-list" href="javascript:void(0);" tag="delete" brief_id="' + length + '" onclick="OrganizationConfig.deleteabrief(this);" style="white-space:nowrap;margin-left:8px;" data-tip="{\'DELETE\'|@getFixedLabel}" data-direction="top" data-type="position">\n' +
		'                                <i class="ld-fonticon ld-fonticon-del"></i>\n' +
		'                            </a>\n' +
		'                            <a class="ld-category-icon ld-category-drag drag-handle tip-items-list" style="cursor: move;" data-tip="{\'drag\'|@getFixedLabel}" data-direction="right" data-type="position"></a>\n' +
		'                        </div>\n' +
		'                    </td>\n' +
		'                </tr>');
//删除后长度为1，隐藏删除按钮
	if (label_num == 2){
		tbody.find('[tag=delete]').first().show();
	}
	var td_obj = tbody.find('#tr_'+length+' [name=td_brief]');
	tooltip('.tip-items-list',{transition:true,time:200});
	OrganizationConfig.bind_mouseenterleave(ld(td_obj).parent());
	OrganizationConfig.bind_evt(td_obj);
	td_obj.find("textarea").focus();
}

//wsh 简介信息排序 240911
OrganizationConfig.sort_brief = function (evt, obj) {
	var drag_obj = evt.item;
	var moveRows = evt.newIndex - evt.oldIndex;
	var old_brief_id = ld(drag_obj).find('a[tag=delete]').attr('brief_id');
	var new_brief_id = moveRows + Number(old_brief_id);
	ld(drag_obj).find('[name=td_one]').text(new_brief_id + 1);
	ld(drag_obj).attr('id', 'tr_' + new_brief_id);
	ld(drag_obj).find('[brief_id]').each(function () {
		ld(this).attr('brief_id', new_brief_id);
	});
	var filteredRows;
	if (moveRows < 0){
		filteredRows = ld(obj).find("tr").slice(evt.newIndex + 1, evt.oldIndex + 1);
		filteredRows.each(function () {
			var this_brief_id = Number(ld(this).find('a[tag=delete]').attr('brief_id')) + 1;
			ld(this).find('[name=td_one]').text(Number(this_brief_id) + 1);
			ld(this).attr('id', 'tr_' + this_brief_id);
			ld(this).find('[brief_id]').each(function () {
				ld(this).attr('brief_id', this_brief_id);
			});
		})
	}else {
		filteredRows = ld(obj).find("tr").slice(evt.oldIndex, evt.newIndex);
		filteredRows.each(function () {
			var this_brief_id = Number(ld(this).find('a[tag=delete]').attr('brief_id')) - 1;
			ld(this).find('[name=td_one]').text(Number(this_brief_id) + 1);
			ld(this).attr('id', 'tr_' + this_brief_id);
			ld(this).find('[brief_id]').each(function () {
				ld(this).attr('brief_id', this_brief_id);
			});
		})
	}
}
//wsh 产品信息排序 240911
OrganizationConfig.sort_product = function (evt, obj) {
	var tr_objs = ld(obj).find('tr');
	var tr_id_arr = [];
	tr_objs.each(function (index, value) {
		tr_id_arr.push(ld(value).attr('id'))
	})
	var sort_string = tr_id_arr.join(',');
	var url = 'index.php?module=Settings&action=SettingsAjax&file=SaveCompanyProduct&sort_string=' + sort_string;
	ldAjaxNoProgress(url, '', function (data) {
	});

}
/**
 * zxm
 * 2020-9-22
 * 公司简介信息的删除
 */
//wsh 公司简介信息的删除 240911
OrganizationConfig.deleteabrief = function (obj) {
	MessagePopup.TipTwo_warning(arrJsPopLabel['COMFIRMTODELETE']);
	var msgpopupobj = CrmPopup.getPopupObj('last');
	ld("#" + msgpopupobj.divid).find("input[tagclick='msgConfirm']").unbind("click").bind("click", function () {
		var brief_id = ld(obj).attr('brief_id');
		var tr_obj = ld(obj).parents('#tr_'+ brief_id +'');
		let length_obj = ld('#editContent').find('[name=td_brief]');
		let length = length_obj.length;
		//当简介条目是5条时，增加字样不显示，删除后显示增加字样
		if (length == 5) {
			ld('#editContent').find('[tag=create]').show();
		}
		if (length == 2){
			tr_obj.siblings().find('[tag=delete]').first().hide();
		}
		var next_tr_all = tr_obj.nextAll('[name=brief]');
		next_tr_all.each(function () {
			var curobj_brief_id = ld(this).find('[brief_id]').first().attr('brief_id');
			var new_brief_id = curobj_brief_id - 1;
			ld(this).find('[name=td_one]').text(curobj_brief_id);
			ld(this).attr('id','tr_'+new_brief_id);
			ld(this).find('[brief_id]').each(function() {
				// 修改每个元素的 brief_id 属性值
				ld(this).attr('brief_id', new_brief_id);
			});
		})
		tr_obj.remove();
	});
}
/**
 * zxm
 * 2020-9-22
 * 公司简介信息图片链接 添加
 */
OrganizationConfig.addaimagelink = function(obj){
	let _parent = ld(obj).parent().parent();
	//判断数据条数
	let length_obj = ld('#editContent').find('input[name="image_link[]"]');
	let length = length_obj.length;
	if(length>=5){
		return ;
	}
	_parent.before('<tr>' +
		'<td align="right"></td>'+
		'<td align="left">'+
		'<input type="text" name="image_link[]" class="detailedViewTextBox btn-radius-system"/>'+
		'<div class="delete-button" onclick="OrganizationConfig.deleteaimagelink(this)">'+arrJsPopLabel['DELETE']+'</div>'+
		'</td>'+
		
		'</tr>');
}
/**
 * zxm
 * 2020-9-22
 * 公司简介信息图片链接删除
 */
OrganizationConfig.deleteaimagelink = function(obj){
	let _parent = ld(obj).parent().parent();
	let length_obj = ld('#editContent').find('textarea[name="brief[]"]');
    let length = length_obj.length;
    //当简介条目是5条时，增加字样不显示，删除后显示增加字样
    if(length>=5){
        ld('#editContent').find(".ld-button").parent().parent().eq(0).css('display','');
    }
	_parent.remove();
    let popupobj = CrmPopup.getPopupObj('last');
    popupobj.center();//弹出框居中
}
OrganizationConfig.bind_mouseenterleave = function (obj) {
	ld(obj).each(function () {
		var dragObj = ld(this).find('.ld-category-drag');
		dragObj.hide();
		ld(this).on('mouseenter', function () {
			dragObj.show();
		}).on('mouseleave', function () {
			dragObj.hide();
		})
	})
}
/***
 * zxm
 * 2020-0922
 * 灵当云小程序 需要的公司产品简介 公司产品简介查看
 */
OrganizationConfig.productview = function(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=ViewCompanyProduct';
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,"","","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.show(data.result.content);
			var popupobj = CrmPopup.getPopupObj('last');
			var divid = popupobj.divid;
			var drag_obj = ld("#"+divid+"").find('tbody').get(1);
			Sortable.create(drag_obj, {
				animation: 150,
				handle: ".drag-handle",
				onEnd: function (evt){
					OrganizationConfig.sort_product(evt,drag_obj);
				}
			});
			tooltip('.tip-items-list',{transition:true,time:200});
			OrganizationConfig.bind_mouseenterleave(ld(drag_obj).find('tr'));
            //zkt 0046604: （81mis.com/kfbcrm）普通成员登录，点击右上角头像下电子名片，显示有设置按钮，该设置应只有管理员显示
            //重写关闭事件，若标题为空则弹出提示框，不为空则标题保存
            crmPopupobj.CancelEvent=function(){
                var popupobj=CrmPopup.getPopupObj("last");
                var product_title = ld('#'+popupobj.divid).find(" [name=product_title]").val();
                if(product_title=="" || product_title == undefined){
                    let confirm_str = arrJsPopLabel['MAILTITLE'] +arrJsPopLabel['CANOTEMPTY'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str)
                    var newpopupobj=CrmPopup.getPopupObj("last");
                    //移除提醒框确定按钮点击事件，并设置新的onclick事件
                    ld("input[tagclick='msgConfirm']").removeAttr("tagclick");
                    ld("#"+newpopupobj.divid+"_btnok").attr("onclick","newtagclick()");
                    return ;
                    }
                OrganizationConfig.saveProductTitle();//保存标题
                if(this.crmpopuplayerobj==undefined)
                {
                    return ;
                }
                this.crmpopuplayerobj.unblock();
                CrmPopup.zIndex--;
                document.getElementById(this.divid).style.display="none";
                document.body.removeChild(document.getElementById(this.divid));
                var tmpobj=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1];
		
                CrmPopup.global_listPopupObj.pop();//把最后一个对象移除，移除当前弹出层的对象
                for(var i=0;i<CrmPopup.global_signleInstance.length;i++)
                {
                    if(CrmPopup.global_signleInstance[i].type==tmpobj.type)
                    {
					 
                        CrmPopup.global_signleInstance.splice(i,1);
                        break;
                    }
                }
                delete tmpobj;
                if(CrmPopup.global_listPopupObj.length>0)
                {
                    //判断上一个弹出层是否隐藏，如果隐藏了，则把他显示出来
                    var obj=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1];
                    if(obj.hide==true)
                    {
					
                        obj.reshow();
                    }
                }
            };
		}
	})
}
/**
 * zxm
 * 2020-9-22
 * 保存公司简介信息
 */
OrganizationConfig.saveBrief = function(){
	let popupobj=CrmPopup.getPopupObj("last");
	let data = new FormData(ld(".ajax_form")[0]);
	var title_name = data.get('title_name');
	var brief_title = data.get('brief_title');
	var brief_name = data.get('brief_name');
	var brief = data.getAll('brief[]');
	if (brief_title == "" || brief_title == undefined)
	{
		let confirm_str = title_name +arrJsPopLabel['CANOTEMPTY'];
		ld("#"+popupobj.divid+" [name=brief_title]").focus();
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	else if (brief_title.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
	{
		let confirm_str = title_name +arrJsPopLabel['CANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		ld("#"+popupobj.divid+" [name=brief_title]").focus();
		return false;
	}
	var allEmpty = true;
	if (brief.length > 0) {
		brief.forEach(item => {
			if (!!item) {
				allEmpty = false;
			}
		});
		if (allEmpty) {
			let confirm_str = brief_name + arrJsPopLabel['CANOTEMPTY'];
			ld("#" + popupobj.divid + " [name='brief[]']").focus();
			RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
			return false;
		}

	}
	ld('#rptContentLoading').show();
	ld.ajax({
		type: 'POST',
		dataType: 'json',
		processData: false, // 告诉jquery不要处理数据
		contentType: false, // 告诉jquery不要设置contentType
		data: data,
		url: 'index.php?module=Settings&action=SettingsAjax&file=SaveCompanyBrief',
		success: function(res) {
			ld('#rptContentLoading').hide();
			popupobj.CancelEvent();
            //zkt 0046600: （81mis.com/kfbcrm）打开系统设置任意界面，然后打开电子名片设置公司简介保存，界面自动跳转到公司信息界面
			//ld("[name=LBL_COMPANY_DETAILS]").click();
		},
		error: function(xhr, textStatus, errorThrown) {
			
		}
	})
}
/**
 * zxm
 * 2020-9-22
 * 保存公司简介信息
 */
OrganizationConfig.saveProduct = function(){
	let popupobj=CrmPopup.getPopupObj("last");
	let data = new FormData(ld(".ajax_form")[0]);
	var title_name = data.get('title_name');
	var brief_title = data.get('title');
	var brief_name = data.get('brief_name');
	var brief = data.getAll('brief[]');
	let image_name = data.get('image_name');
	let image_link = data.get('image_link');

	if (brief_title == "" || brief == undefined)
	{
		let confirm_str = title_name +arrJsPopLabel['CANOTEMPTY'];
		ld("#"+popupobj.divid+" [name=title]").focus();
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	else if (brief_title.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
	{
		let confirm_str = title_name +arrJsPopLabel['CANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		ld("#"+popupobj.divid+" [name=title]").focus();
		return false;
	}
	if (image_link == "" || image_link == undefined )
	{
		let confirm_str = image_name +arrJsPopLabel['CANOTEMPTY'];
		ld("#"+popupobj.divid+" [name='image_link']").focus();
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	var allEmpty = true;
	if (brief.length > 0) {
		brief.forEach(item => {
			if (!!item) {
				allEmpty = false;
			}
		});
		if (allEmpty) {
			let confirm_str = brief_name + arrJsPopLabel['CANOTEMPTY'];
			ld("#" + popupobj.divid + " [name='brief[]']").focus();
			RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
			return false;
		}

	}
	ld('#rptContentLoading').show();
	ld.ajax({
		type: 'POST',
		dataType: 'json',
		processData: false, // 告诉jquery不要处理数据
		contentType: false, // 告诉jquery不要设置contentType
		data: data,
		url: 'index.php?module=Settings&action=SettingsAjax&file=SaveCompanyProduct',
		success: function(res) {
			ld('#rptContentLoading').hide();
			popupobj.CancelEvent();
			//ld("[name=LBL_COMPANY_DETAILS]").click(); //进入系统设置->其他设置->公司信息界面
			let prevpopupobj=CrmPopup.getPopupObj("last");
			prevpopupobj.CancelEvent();
			OrganizationConfig.productview();

		},
		error: function(xhr, textStatus, errorThrown) {

		}
	})
}
/**
 * zxm
 * 2020-9-22
 * 保存公司产品介绍标题
 */
OrganizationConfig.saveProductTitle = function() {
	let organization_id = ld('#organization_id').val();
	let product_title = ld('#product_title').val();
	ld.ajax({
		type: 'POST',
		dataType: 'json',
		data: {organization_id:organization_id,product_title:product_title,is_brief:"no"},
		url: 'index.php?module=Settings&action=SettingsAjax&file=SaveCompanyBrief',
		success: function(res) {
			console.log("success");
		},
		error: function(xhr, textStatus, errorThrown) {

		}
	})
}
OrganizationConfig.save = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var organization_name = ld("#"+popupobj.divid+" [name=organization_name]").val();
    var company_name = ld("#"+popupobj.divid+" [name=companyname]").val();
	if (organization_name == "" )
	{
		var confirm_str = company_name +arrJsPopLabel['CANOTEMPTY'];
		ld("#"+popupobj.divid+" [name=organization_name]").focus();
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	else if (organization_name.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
	{
		var confirm_str = company_name +arrJsPopLabel['CANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		ld("#"+popupobj.divid+" [name=organization_name]").focus();
		return false;
	}
	else{
		var data = new FormData(ld(".ajax_form")[0]);
		var logo_type_array = ['big','small'];
		ld.each(logo_type_array, function(index, value) {
			var prev_file_name= ld('#'+popupobj.divid).find('#overlay_Img_'+value).data('prevname');
			data.append("prev_file_"+value,prev_file_name);
			data.append("imgurl_"+value,popupobj.imgInfo[value]["imgurl"]);
			data.append("imgname_"+value,popupobj.imgInfo[value]["imgname"]);
		});
		var popupobj=CrmPopup.getPopupObj("last");
		ld('#rptContentLoading').show();
		ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: data,
			url: 'index.php?module=Settings&action=SettingsAjax&file=add2db',
			success: function(data) {
				ld('#rptContentLoading').hide();
				popupobj.CancelEvent();
                ld("[name=LBL_COMPANY_DETAILS]").click();
                ld("[class='logo-pic logo-pic-normal'][tag=logo-pic]").attr("src",'dataCache/test/logo/'+data.result.logoname);
                ld("[class='logo-pic logo-pic-mini'][tag=logo-pic]").attr("src",'dataCache/test/logo/'+data.result.small_logoname);
			},
			error: function(xhr, textStatus, errorThrown) {

			}
		  })
	}

	return false;
}
OrganizationConfig.save.funname='OrganizationConfig.save';

//提示框click事件，点击确定后实现关闭提示框并将光标锁定到input框
newtagclick = function(){
    var newpopupobj=CrmPopup.getPopupObj("last");
    var prevpopupobj=CrmPopup.getPopupObj("lastprev");
     //点击确定后直接关闭弹出层
     ld('#layer').removeClass("indextop_8");//遮罩层
     try{
            newpopupobj.CancelEvent();
            ld("#"+prevpopupobj.divid).find("input[id=product_title]").focus();
     }catch(error){
            ld('div[class="mask opacity"]').remove();
            ld(this).remove();
            ld("#"+prevpopupobj.divid).find("input[id=product_title]").focus();
     }
     return false;
}
OrganizationConfig.showLOGO = function(obj,logoname_img){
	var popupobj=CrmPopup.getPopupObj('last');
	//获取文件数据
	var upfile = ld(obj).get(0).files[0];
	//生成文件URL
	var sr = window.URL.createObjectURL(upfile);
	//图片实时显示
	var img_obj = ld("#"+popupobj.divid).find("[name="+logoname_img+"]");
	img_obj.attr("src",sr);
}
