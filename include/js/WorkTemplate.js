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
	//ld(divobj).find('.pop_remind_content input[type=checkbox]').prop('checked',true);
	ld(divobj).find('.pop_remind_content select[name=defaultheight]').val(25);
	ld(divobj).find('.pop_remind_content input[name=is_activate]').prop('checked',true);
	ld(divobj).find('.pop_remind_content input[name=is_activate]').parent().parent().css('display','none');
}

WorkTemplate.showCreateDiv = function(){
	var divid = 'createworktpldiv';
	var divobj = createElementDivs(divid);
	ld(divobj).find('.E_pop_tit .E_ptita').html(userdefinedfields);
	ld(divobj).attr('class','E_pop_box LdPopWidth400px');
	var createhtml = '<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%" style="table-layout: fixed;">'+
					'<tbody><tr>'+
						'<td width="35%" align="right"><font color="red">*</font>'+lbl_fieldname+'</td>'+
						'<td>'+
							'<input type="text" value="" style="width:90%;box-sizing: border-box;" name="label" class="detailedViewTextBox btn-radius-system" record="">'+
						'</td></tr>';
	createhtml += '<tr><td width="35%" align="right">'+lbl_defaultvalue+
						'</td><td>'+
							'<textarea class="detailedViewTextBox btn-radius-system" style="width:90%;height: unset;line-height:normal;box-sizing: border-box; resize:none" name="defaultvalue" cols="2" ></textarea>'+
							// '<input type="text" value="" style="width:90%" name="defaultvalue" class="detailedViewTextBox" >'+

						'</td></tr>';
	createhtml += '<tr><td width="35%" align="right">'+
						'<font color="red">*</font>'+lbl_defaultheight+
						'</td><td >'+
							'<select style="width:90%;box-sizing: border-box;" name="defaultheight" class="detailedViewSelect bgwhite btn-radius-system">';
	createhtml += defheightopts+'</select></td></tr>';
	createhtml += '<tr><td width="35%" align="right">'+lbl_mandatoryfields+
						'</td><td align="left">'+
							'<input type="checkbox" class="second_switch" value="" name="is_mandatory" >'+
						'</td></tr>';
	createhtml += '<tr><td width="35%" align="right">'+lbl_activate+
						'</td><td align="left">'+
							'<input type="checkbox" class="second_switch" value="" name="is_activate" >'+
						'</td></tr>';
	createhtml += '</table>';
	ld('#createworktpldivcontent').css('border','none');
	ld('#createworktpldivcontent').css('overflow','auto');
	ld('#createworktpldivcontent').css('max-height','230');
	ld('#createworktpldivcontent').css('margin','0');
	ld('#createworktpldivcontent').html(createhtml);
	fnvshobj(this,'createworktpldiv');
	//绑定文本框键盘事件，enter右键提交表单
	ld(divobj).find('.pop_remind_content input[name]').unbind('keypress').on('keypress',function(event){
		var e = event || window.event;
		if(e.keyCode == '13'){//enter右键事件
			ld(divobj).find('.E_pbtn .E_pbtnok').click();
		}
	});
	//绑定保存按钮点击事件，保存工作协同模板
	ld(divobj).find('.E_pbtn .E_pbtnok').unbind('click').on('click',function(){
		if(1 != issubmit) return false;
		ld(divobj).find('.pop_remind_content input[name=label]').val(trim(ld(divobj).find('.pop_remind_content input[name=label]').val()));
		if(empty(ld(divobj).find('.pop_remind_content input[name=label]').val())){
		    var confirm_str = lbl_fieldname +' '+ arrJsPopLabel['CANOTEMPTY'];
		    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			ld(divobj).find('.pop_remind_content input[name=label]').focus();
			return false;
		}
		var ustring = 'module=Settings&action=SettingsAjax&file=WorkTemplate';
		ustring += '&setype=save';
		ustring += '&label='+ld(divobj).find('.pop_remind_content input[name=label]').val();
		ustring += '&defaultvalue='+ld(divobj).find('.pop_remind_content textarea[name=defaultvalue]').val();
		ustring += '&defaultheight='+ld(divobj).find('.pop_remind_content select[name=defaultheight]').val();
		ustring += '&is_mandatory='+ld(divobj).find('.pop_remind_content input[name=is_mandatory]').prop('checked');
		ustring += '&is_activate='+ld(divobj).find('.pop_remind_content input[name=is_activate]').prop('checked');
		ustring += '&entitytype='+ld('#entitytype').val();
		ustring += '&type='+ld('#type').val();
		if(ld(divobj).find('.pop_remind_content input[name=label]').attr('record') > 0){
			ustring += '&record='+ld(divobj).find('.pop_remind_content input[name=label]').attr('record');
		}
		issubmit = 2;
		RequestAjax(ustring,function(rest){
			issubmit = 1;
			ld(divobj).find('.E_pbtn .E_pbtncancel').click();
			DelProgressObjs();
			WorkTemplate.refresh();
		});
	});
	ld(divobj).find('.pop_remind_content input[name=label]').focus();
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
	var divobj = WorkTemplate.showCreateDiv();
	ld(divobj).find('.pop_remind_content input[name=label]').val(label);
	ld(divobj).find('.pop_remind_content input[name=label]').attr('record',record);
	if(0 == is_mandatory)
		ld(divobj).find('.pop_remind_content input[name=is_mandatory]').prop('checked',true);
	if(0 == is_activate)
		ld(divobj).find('.pop_remind_content input[name=is_activate]').prop('checked',true);
	ld(divobj).find('.pop_remind_content select[name=defaultheight]').val(defaultheight);
	ld(divobj).find('.pop_remind_content textarea[name=defaultvalue]').val(defaultvalue);
	if('worksummary' == fldname){//请填写今日工作总结，必须必填且必须开启
		ld(divobj).find('.pop_remind_content input[type=checkbox]').prop('checked',true);
		ld(divobj).find('.pop_remind_content input[type=checkbox]').attr('disabled',true);
		ld(divobj).find('.pop_remind_content input[type=checkbox]').on('click',function(){
			ld(this).prop('checked',true);
		});
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
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
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