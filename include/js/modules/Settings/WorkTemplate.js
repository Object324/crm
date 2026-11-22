function WorkTemplate(){
   var that=this;
}
//刷新
WorkTemplate.refresh = function(){
	var _type = ld('#type').val();
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkTemplate&parenttab=Settings&type='+_type;
	ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=SettingRightContent]').html(data.result.content);
		}
        DelProgressObjs();
        //将选择模块select下拉框设置为不显示，并在其后插入输入下拉框div
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
            var selectdivobj  =Tools.getParentobjByChild(selectobj,'div');
            ld(selectdivobj).css('width', ld(selectdivobj).width()+20+'px');
            ld(selectdivobj).find('.chzn-container').css('margin-top', '17px');
            ld(selectdivobj).find('.chzn-drop').css('margin-left', '10px');
        }

		//按钮显示控制
		var WorkTemplate_create_obj = ld('[name=WorkTemplate_create]');
		var WorkTemplate_rulesettings_obj = ld('[name=WorkTemplate_rulesettings]');
		if (_type == 'weibo' || _type == 'cocmd'){
			WorkTemplate_create_obj.css('display','none');
			WorkTemplate_rulesettings_obj.css('display','none');
		}else {
			WorkTemplate_create_obj.css('display','');
			WorkTemplate_rulesettings_obj.css('display','');
		}
		initRightContentHeight();
	})
}

//工作汇报模板定制 - 切换日志类型
WorkTemplate.selectChange = function(obj){
	WorkTemplate.refresh();
}

/**
 * 创建工作协同模板
 * @project 工作协同模板
 * @author Tujt 2015-05-05
 */
WorkTemplate.create = function(){
	var divobj = WorkTemplate.showCreateDiv();
	//ld(divobj).find('  input[type=checkbox]').prop('checked',true);
	// ljj 20231116 XUQIU1002166 工作汇报模板定制增加“自动引用工作内容”（宋清华）
	WorkTemplate.getRelatedHtml('create','');
	ld(divobj).find('  select[name=defaultheight]').val(25);
	ld(divobj).find('  input[name=is_activate]').prop('checked',true);
	ld(divobj).find('  input[name=is_activate]').parent().parent().css('display','none');

}
//BUG0065611 2023428 fengxh 将可拖动的方法单独包装function
WorkTemplate.showCreateDiv = function(is_mandatory='',is_activate=''){
	var crmpopuObj = CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
	crmpopuObj.prevshow();
	var divid = crmpopuObj.divid;
	var divobj = ld("#"+divid);
	var _type = ld('#type').val();

	var createhtml = '<table class="ld-public-content-small " name="worktemplate_table" border="0" cellpadding="0" cellspacing="0" width="100%" ">'+
					'<tbody>';
	if (_type == 'weibo' || _type == 'cocmd'){
		createhtml += '<tr style="display: none">'
	}else {
		createhtml += '<tr>'
	}
	createhtml +=
		'<td class="ld-form-item-label"><font color="red">*</font>'+lbl_fieldname+'</td>'+
		'<td class="ld-form-item-content">'+
		'<input type="text" value="" name="label" class="ld-input-inner" record="">'+
		'</td></tr>';
	createhtml += '<tr><td class="ld-form-item-label">'+lbl_defaultvalue+
		'</td><td class="ld-form-item-content">'+
		'<textarea class="ld-textarea-inner" height: unset;line-height:normal;box-sizing: border-box; resize: none" name="defaultvalue" cols="2"></textarea>'+
		// '<input type="text" value="" style="width:90%" name="defaultvalue" class="detailedViewTextBox" >'+

		'</td></tr>';
	createhtml += '<tr><td class="ld-form-item-label">'+
						'<font color="red">*</font>'+lbl_defaultheight+
						'</td><td class="ld-form-item-content">'+
							'<select  name="defaultheight" class="ld-select-inner">';
	createhtml += defheightopts+'</select></td></tr>';
	createhtml += '<tr><td class="ld-form-item-label">'+lbl_mandatoryfields+'</td><td class="ld-form-item-content">';
	//wym BUG0072596 kfbtest-后台设置-模板设置-工作汇报模板定制-点击编辑-是否必填跟启用按钮会有一个动态的滑动
	var is_mandatory_status = '';
	if (_type == 'weibo' || _type == 'cocmd'){
		is_mandatory_status = 'disabled checked';
	}else if(!empty(is_mandatory)&&is_mandatory==0){
		is_mandatory_status = 'checked';
	}
	createhtml += '<input type="checkbox" class="second_switch" value="" '+is_mandatory_status+' name="is_mandatory" >';

	createhtml +='</td></tr>';
	createhtml +='<tr><td class="ld-form-item-label">'+lbl_activate+ '</td><td class="ld-form-item-content">';
	var is_activate_status = '';
	if (_type == 'weibo' || _type == 'cocmd'){
		is_activate_status = 'disabled checked';
	}else if(!empty(is_activate)&&is_activate==0){
		is_activate_status = 'checked';
	}
	createhtml += '<input type="checkbox" class="second_switch" value="" '+is_activate_status+' name="is_activate" >';
	createhtml +='</td></tr></table>';
	//ld('#createworktpldivcontent').css('border','none');
	//ld('#createworktpldivcontent').css('overflow','auto');
	//ld('#createworktpldivcontent').css('max-height','230');
	//ld('#createworktpldivcontent').css('margin','0');
	//ld('#createworktpldivcontent').html(createhtml);
	//fnvshobj(this,'createworktpldiv');
	//绑定文本框键盘事件，enter右键提交表单
	ld(divobj).find('  input[name]').unbind('keypress').on('keypress',function(event){
		var e = event || window.event;
		if(e.keyCode == '13'){//enter右键事件
			ld(divobj).find('.E_pbtn .E_pbtnok').click();
		}
	});
	var SaveWorkTemplate=function(){
		if(1 != issubmit) return false;
		ld(divobj).find('  input[name=label]').val(trim(ld(divobj).find('  input[name=label]').val()));
		var _type = ld('#type').val();

		if(empty(ld(divobj).find('  input[name=label]').val()) && _type != 'weibo' && _type != 'cocmd'){
			var confirm_str = lbl_fieldname +' '+ arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			ld(divobj).find('  input[name=label]').focus();
			return false;
		}
		var ustring = 'module=Settings&action=SettingsAjax&file=WorkTemplate';
		ustring += '&setype=save';
		if (_type != 'weibo' && _type != 'cocmd'){
			ustring += '&label='+ld(divobj).find('  input[name=label]').val();
		}
		ustring +='&defaultheight='+ld(divobj).find('  select[name=defaultheight]').val();
		ustring += '&is_mandatory='+ld(divobj).find('  input[name=is_mandatory]').prop('checked');
		ustring += '&is_activate='+ld(divobj).find('  input[name=is_activate]').prop('checked');
		ustring += '&entitytype='+ld('#entitytype').val();
		ustring += '&type='+ld('#type').val();
		if(ld(divobj).find('  input[name=label]').attr('record') > 0){
			ustring += '&record='+ld(divobj).find('  input[name=label]').attr('record');
		}

		var defaultvalue_val=ld(divobj).find('  textarea[name=defaultvalue]').val();
		var param = {'defaultvalue':defaultvalue_val};

		// ljj 20231116 XUQIU1002166 工作汇报模板定制增加“自动引用工作内容”（宋清华）
		var fldname=ld(divobj).find('[name=label]').attr('value');
		if (fldname != 'signaddress' && _type != 'weibo' && _type != 'cocmd'){//签到不保存
			ustring += '&issignaddress=no';
			var relatedmodulefield=ld(divobj).find('[name=relatedmodulefield]').prop('checked');
			//"自动引用工作内容"是否开启
			relatedmodulefield=relatedmodulefield==true?'yes':'no';
			ustring += '&relatedmodulefield='+relatedmodulefield;
			//引用时间
			var related_time=ld(divobj).find('[name=related_time] option:selected').val();
			ustring += '&related_time='+related_time;
			//引用字段
			var data=ld(divobj).find('[name=related_fieldid]').select2('data');//获取多选框选中数据
			var fieldid_arr= new Array();
			ld.each(data,function (index,value){
				fieldid_arr.push(value.id);
			});
			var fieldid=fieldid_arr.join(',');
			ustring += '&related_fieldid='+fieldid;
		}

		issubmit = 2;
		//zkt 20221021 BUG0057763系统设置>工作汇报模板定制：设置好格式之后保存没有生效
		ldAjaxHtml('index.php?'+ustring,param,function(data){
			issubmit = 1;
			//ld(divobj).find('.E_pbtn .E_pbtncancel').click();
			msgConfirm();
			DelProgressObjs();
			WorkTemplate.refresh();
		})
	}
	//绑定保存按钮点击事件，保存工作协同模板
	crmpopuObj.setParams(userdefinedfields,SaveWorkTemplate,"","LdPopWidth600px",'Settings',"", arrJsPopLabel["CONFIRME"],"",arrJsPopLabel["CANCEL"]);
	CrmPopup.setPopupobjHtmlContent_scroll(crmpopuObj,createhtml);

	// 设置内容最大高度
	crmpopuObj.setPopBodyMaxHeight('.dvpopupsroll')

	ld(divobj).find('  input[name=label]').focus();
	return divobj;
}

/**
 * 编辑工作协同模板
 * @project 工作协同模板
 * @author Tujt 2015-05-05
 */
WorkTemplate.editworktpl_click = function (obj){
    var record = ld(obj).parent().parent().attr('record');
	var fldname = ld(obj).parent().parent().attr('fldname');
	var label = ld(obj).parent().parent().find('td[fld=label]').attr('val');
	var is_mandatory = ld(obj).parent().parent().find('td[fld=is_mandatory]').attr('val');
	var defaultheight = ld(obj).parent().parent().find('td[fld=defaultheight]').attr('val');
	var defaultvalue = ld(obj).parent().parent().find('td[fld=defaultvalue]').attr('val');
	var is_activate = ld(obj).parent().parent().find('td[fld=is_activate]').attr('val');
	ld(divobj).find(obj).parent().parent().css('display','none');
	//wym BUG0072596 kfbtest-后台设置-模板设置-工作汇报模板定制-点击编辑-是否必填跟启用按钮会有一个动态的滑动
	var divobj = WorkTemplate.showCreateDiv(is_mandatory,is_activate);
	// ljj 20231116 XUQIU1002166 工作汇报模板定制增加“自动引用工作内容”（宋清华）
	WorkTemplate.getRelatedHtml('edit',obj);
	ld(divobj).find('  input[name=label]').val(label);
	ld(divobj).find('  input[name=label]').attr('record',record);
	ld(divobj).find('  input[name=label]').attr('value',fldname);
/*	if(0 == is_mandatory)
		ld(divobj).find('  input[name=is_mandatory]').prop('checked',true);
	if(0 == is_activate)
		ld(divobj).find('  input[name=is_activate]').prop('checked',true);*/
	ld(divobj).find('  select[name=defaultheight]').val(defaultheight);
	ld(divobj).find('  textarea[name=defaultvalue]').val(defaultvalue);
	if('worksummary' == fldname){//请填写今日工作总结，必须必填且必须开启
		// ld(divobj).find('  input[type=checkbox]').prop('checked',true);
		// ld(divobj).find('  input[type=checkbox]').attr('disabled',true);
		// ld(divobj).find('  input[type=checkbox]').on('click',function(){
		// 	ld(this).prop('checked',true);
		// });
		ld(divobj).find('  input[name=is_activate]').prop('checked',true);
		ld(divobj).find('  input[name=is_activate]').attr('disabled',true);
	}
}

/**
 * 删除工作协同模板
 * @project 工作协同模板
 * @author Tujt 2015-05-05
 */
WorkTemplate.delworktpl_click=function(obj){
    var record = ld(obj).parent().parent().attr('record');
	var fldname = ld(obj).parent().parent().attr('fldname');
	if('worksummary' == fldname || 'workplan' == fldname || 'workexperience' == fldname){//该模板为系统预置，不允许删除！
		var confirm_str = arrJsPopLabel['SYSTEMTEMPLATECANOTDELETE'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}

    var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		var ustring = 'module=Settings&action=SettingsAjax&file=WorkTemplate';
		ustring += '&setype=del&record='+record;
		issubmit = 2;//防止重复点击
		RequestAjax(ustring,function(rest){
			DelProgressObjs();
			issubmit = 1;WorkTemplate.refresh();
		});
    });
}

/**
 * 上移下移
 * @project 工作协同模板
 * @author Tujt 2015-05-05
 */
WorkTemplate.moveworktpl_click=function(obj,setype){
    var record = ld(obj).parent().parent().attr('record');
	var ustring = 'module=Settings&action=SettingsAjax&file=WorkTemplate';
	ustring += '&entitytype='+ld('#entitytype').val();
	ustring += '&type='+ld('#type').val();
	ustring += '&setype=moveupdate&movetype='+setype+'&workid='+record;
	issubmit = 2;//防止重复点击
	RequestAjax(ustring,function(rest){
		DelProgressObjs();
		issubmit = 1;WorkTemplate.refresh();
	});
}

/*
* editor:ljj
* time:20231117
* reason:XUQIU1002166
* content:工作汇报模板定制增加“自动引用工作内容”（宋清华）
* node:获取“自动引用工作内容”设置部分
* */
WorkTemplate.getRelatedHtml=function (mode,obj){
	var popupobj=CrmPopup.getPopupObj('last');
	var urlstring='index.php?module=Settings&action=SettingsAjax&file=WorkTemplate&parenttab=Settings';
	urlstring += '&setype=getrelatedhtml';
	urlstring += '&mode='+mode;
	if (mode == 'edit'){
		var record = ld(obj).parent().parent('tr').attr('record');
		var fldname = ld(obj).parent().parent('tr').attr('fldname');
		urlstring +='&record='+record;
		//签到没有“自动引用工作内容”部分
		var _type = ld('#type').val();
		if (fldname == 'signaddress' || _type == 'weibo' || _type == 'cocmd'){
			return false;
		}
	}
	ldAjaxNoProgress(urlstring,"",function (data){
		if (data.code == 1){
			var popupobj=CrmPopup.getPopupObj('last');
			var relatedmodulefield=ld('#'+popupobj.divid+ " [name=worktemplate_table]");
			relatedmodulefield.append(data.result.content);
			popupobj.center();//弹窗居中
			ld('#'+popupobj.divid+' #related_fieldid').select2({//多选框加载
				closeOnSelect: false
			});
			var related_fieldid=data.result.related_fieldid;
			ld('#'+popupobj.divid+' #related_fieldid').val(related_fieldid).select2();//设置多选框选中值
			//启动显示（不启动不显示） "自动引用工作内容"显示引用时间、引用对象、引用字段部分
			ld('#'+popupobj.divid+' [name=relatedmodulefield]').unbind('click').bind('click',function (){
				if (ld(this).prop('checked') == true){
					ld('#'+popupobj.divid+' [name=related_time_tr]').css('display','');
					ld('#'+popupobj.divid+' [name=related_type_tr]').css('display','');
					ld('#'+popupobj.divid+' [name=related_fieldid_tr]').css('display','');
				}else {
					ld('#'+popupobj.divid+' [name=related_time_tr]').css('display','none');
					ld('#'+popupobj.divid+' [name=related_type_tr]').css('display','none');
					ld('#'+popupobj.divid+' [name=related_fieldid_tr]').css('display','none');
				}
				// 设置内容最大高度
				popupobj.setPopBodyMaxHeight('.dvpopupsroll')
			});
			//选择引用类型后刷新多选框对应引用字段
			var related_type=ld('#'+popupobj.divid+" [name=related_type]");
			// ljj 20231215 BUG0077303 option绑定click事件谷歌浏览器会失效（旧版不兼容）,使用change事件绑定select
			related_type.unbind('change').on('change',function(){
				var type=ld(this).find('option:selected').attr('relatedtype');
				var url='index.php?module=Settings&action=SettingsAjax&file=WorkTemplate&parenttab=Settings';
				url += '&setype=getrelatedhtml';
				url += '&type='+type;
				url += '&mode=getrelatedfield';
				ldAjaxNoProgress(url,"",function (data){
					if (data.code == 1){
						var popupobj=CrmPopup.getPopupObj('last');
						var relatedmodulefield=ld('#'+popupobj.divid+ " [name=related_fieldid_tr]");
						relatedmodulefield.replaceWith(data.result.content);
						//多选框加载
						ld('#'+popupobj.divid+' #related_fieldid').select2({
							closeOnSelect: false
						});
					}
				});
			})
		}

	});
}

//下拉框右侧启用设置
WorkTemplate.setWorkReportShow = function ()
{
	var url = 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=setShowPopup&type=settings';
	var popupobj=CrmPopup.load('',"","",'LdPopWidth600px',"WorkTemplate","","","","");
	popupobj.prevshow();
	ldAjax(url,'',function (data) {
		if (data.code == 1){
			DelProgressObjs();
			popupobj.setParams(data.result.title,WorkTemplate.saveWorkReportShow,"",'LdPopWidth600px',"WorkTemplate","",data.result.oktext,"",data.result.canceltext);
			popupobj.show(data.result.content);

			// 设置内容最大高度
			popupobj.setPopBodyMaxHeight(".divPopOverflow");
		}
	});
}
//下拉框右侧启用设置保存
WorkTemplate.saveWorkReportShow = function () {
	var popupobj = CrmPopup.getPopupObj('last');
	var reportobj = ld('#'+popupobj.divid).find('[tag=reportsettings]');
	var params={};
	var presence_num = 0 ;
	ld.each(reportobj,function (index,obj) {
		var reporttype = ld(obj).attr('reporttype');
		var zh_fieldlabel = ld(obj).find('[tag=zh_fieldlabel]').val();
		var en_fieldlabel = ld(obj).find('[tag=en_fieldlabel]').val();
		var checked = ld(obj).find('[tag=presence]').prop('checked');
		var presence = checked == true?'yes':'no';
		if (presence == 'yes'){
			presence_num ++ ;
		}
		params[reporttype] = {'zh_fieldlabel':zh_fieldlabel,'en_fieldlabel':en_fieldlabel,'presence':presence};
	});
	if (presence_num == 0){
		MessagePopup.TipOne_warning(arrJsPopLabel['ENABLEATONE']);
		return false;
	}
	var url = 'index.php?module=CooperativeWork&action=CooperativeWorkAjax&file=saveReportShow&mode=savetypeandshow';
	ldAjax(url, {'data':params},function (data) {
		if (data.code == 1){
			var select_option = data.result.select_option;
			//重新加载下拉框
			var selectobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=select][name=type]");
			var selected_value = selectobj.find('option:selected').val();

			selectobj.empty();
			var option_html = '';
			ld.each(select_option,function (value,label) {
				option_html += '<option value="'+value+'"';
				if (value == selected_value){
					option_html += ' selected ';
				}
				option_html += '>'+label+'</option>'
			});
			selectobj.append(option_html);
			if (empty(select_option[selected_value])){
				WorkTemplate.selectChange(selectobj[0]);
			}


			if(selectobj.length>0&&selectobj!=undefined) {
				var cls_resetComboxHtmlobj = new cls_resetComboxHtml('type');
				CrmPopup.global_listPopupObj = [];
				var obj = new Object();
				obj.divid = "SettingRightContent";
				CrmPopup.global_listPopupObj.push(obj);
				obj.CancelEvent = function () {
					return false;
				}
				cls_resetComboxHtmlobj.setPopupObj(obj);
				cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj, 150);
				ld(' .grid-view-title').css('width', ld(' .grid-view-title').width() + 20 + 'px');
				ld(' .chzn-container').css('margin-top', '17px');
				ld(' .chzn-drop').css('margin-left', '10px');
			}
			DelProgressObjs();
			popupobj.CancelEvent();
		}
	});
}

//规则设置按钮显示列表弹窗
WorkTemplate.showWorkReportRule = function (){
	var selectobj = ld('#SettingRightContent').find('[fieldtype=select][name=type]');
	var reporttype = selectobj.val();
	var url='index.php?module=Settings&action=SettingsAjax&file=WorkTemplate';
	url += '&setype=WorkTemplateRule';
	url += '&option=getRuleList';
	url += '&reporttype='+reporttype;
	var popupobj=CrmPopup.load('',"","",'LdPopWidth800px',"WorkTemplateRule","",arrJsPopLabel['CONFIRMED'],"",arrJsPopLabel['LBL_CLOSE']);
	popupobj.prevshow();
	ldAjax(url,'',function (data) {
		if (data.code == 1){
			popupobj.setParams(data.result.title,popupobj.CancelEvent,"",'LdPopWidth800px',"WorkTemplateRule","",data.result.canceltext,"","")
			popupobj.show(data.result.content);

			// 需要去掉的给高度
			popupobj.reduceBodyHeight = 72;
			// 设置内容最大高度
			popupobj.setPopBodyMaxHeight(".divPopOverflow");

			popupobj.reporttype = reporttype;
			getJsScript('include/js/modules/Settings/WorkTemplateRule.js',function(){
				WorkTemplateRule.getInstance().moveTable();
			});
		}

	})
}

