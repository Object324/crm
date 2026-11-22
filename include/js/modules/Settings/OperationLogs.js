//系统操作日志
function OperationLogs(){
	var that=this;
	this.formobj = ld('form[name=OperationLogs]');
	this.logtype = this.formobj.find("[name='logtype']").val();
	this.surl = 'index.php?module=Settings&action=SettingsAjax&file=OperationLogs&logtype='+this.logtype;
	//设置日志存留时长
	this.setLogTime = function(){
		var surl = this.surl+'&mode=setlogtime';
		// surl += '&fieldid='+fieldid;

		var crmPopupobj = CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.saveLogTime,'',"LdPopWidth600px",'Settings','',data.result.oktext,"",data.result.canceltext);
				var popcontent = '<div class="ld-operationlog-setlogtime">';
				popcontent += '<div class="ld-form-item-label" style="font-size: 14px;text-align:right;">'+data.result.contentlabel+'</div>';
				popcontent += '<div class="ld-form-item-content">';
				popcontent += '<select name="selectduration" id="selectduration" class="ld-select-inner" style="width: 200px">';
				data.result.availabletimes.forEach(availabletime => {
					if(availabletime == data.result.savedtime){
						popcontent += '<option value="'+availabletime+'" selected="">'+availabletime+data.result.availabletimelabel+'</option>';
					}else{
						popcontent += '<option value="'+availabletime+'">'+availabletime+data.result.availabletimelabel+'</option>';
					}
				});
				popcontent += '<select></div></div>';
				CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,popcontent);

				crmPopupobj.center();
				crmPopupobj.savedtime = parseInt(data.result.savedtime);// 已保存的保留日志时长
			}
		})
	}

	//保存日志存留时长
	this.saveLogTime = function(){
		var popupobj = CrmPopup.getPopupObj("last");
		var savedtime = ld('#'+popupobj.divid).find('#selectduration').val();
		var surl = that.surl+'&mode=savelogtime';
		surl += '&savedtime='+savedtime;
		savedtime = parseInt(savedtime);

		if(savedtime < popupobj.savedtime){
			var confirm_str = arrJsPopLabel['WillDeleteLogWhetherContinue'];// 当前变更将会删除X个月前的日志留存，是否继续
			confirm_str = confirm_str.replace("{Var}", savedtime);
			MessagePopup.TipTwo_warning(confirm_str);
		
			var tmppopupobj = CrmPopup.getPopupObj("last");
			ld('#'+tmppopupobj.divid).find('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
				ldAjaxNoProgress(surl,"",function(data){
					if(data.code==1){
						popupobj.CancelEvent();
						var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
						MessagePopup.TipZero_success(confirm_str);
					}
				})
			})
		}else{
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					popupobj.CancelEvent();
					var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
					MessagePopup.TipZero_success(confirm_str);
				}
			})
		}
	}

	//切换模块，更新操作行为下拉框值
	this.changeModule = function (obj) {
		var selectmodule = ld(obj).val();
		var surl = this.surl + '&mode=changemodule';
		surl += '&selectmodule=' + selectmodule;
		var selectoperation = this.formobj.find('#selectoperation');
		var cur_value = selectoperation.val();

		ldAjaxNoProgress(surl, "", function (data) {
			if (data.code === 1) {
				selectoperation.empty(); // 清空现有选项
				var var_selected = false;
				ld.each(data.result.available_actions, function(action, actionlabel) {
					if(action == cur_value){
						var_selected = true;
					}else{
						var_selected = false;
					}
					selectoperation.append(ld('<option>', {
						value: action,
						text: actionlabel,
						selected:var_selected,
					}));
				});
				var cls_resetComboxHtmlobj=new cls_resetComboxHtml('selectoperation');
				cls_resetComboxHtmlobj.setComboxObjHtml();
				cls_resetComboxHtmlobj.setComboxObjHtmlByWidth('150');
			}
		})
	}

	//查询
	this.search = function(pagenum=''){
		var formobj = this.formobj;
		var selectmodule = formobj.find('#selectmodule').val();
		var actiontype = formobj.find('#selectoperation').val();
		var userids = formobj.find('#customscope_ids').val();
		var operationtime = formobj.find('#laydate_time_value').attr('data-value');
		if(operationtime == 'custom'){
			operationtime = formobj.find('#search_date_custom').val();
		}
		var mode = 'search';
		if(pagenum != ''){
			mode = 'changepage';
		}
		var surl = this.surl+'&mode='+mode;
		surl += '&selectmodule='+selectmodule+'&actiontype='+actiontype+'&userids='+userids+'&operationtime='+operationtime;
		surl += '&pagenum='+pagenum;
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				if(mode == 'search'){
					formobj.find("#ld-operationlog-mainlist").html(data.result.content);
				}else if(mode == 'changepage'){
					formobj.find("#ld-operationlog-list-table").html(data.result.content);
				}
				var widthbox = formobj.find('#ld-operationlog-list').width();
				formobj.find('div[name=operationlogs_header] table').css('width', widthbox);
				formobj.find('div[name=operationlogs_content] table').css('width', widthbox);
			}
		})
	}

	//绑定事件
	this.bindEvent = function(){
		this.formobj.find(" #set_logduration").unbind('click').on('click', function (event) {
			that.setLogTime();
		})
		this.formobj.find(" #searchlogs").unbind('click').on('click', function (event) {
			that.search();
		})
	}

	//切换页数
	this.changePage = function(pagenum){
		this.search(pagenum);
		var formobj = this.formobj;
		formobj.find("[name=operationlogs_content]").get(0).scrollTop = 0;// 滚动条回到最上方
	}

	//设置最大条数
	this.setMaxEntriesPerPage = function(pagecount){
		var surl = this.surl+'&mode=setMaxEntriesPerPage';
		surl += '&pagecount='+pagecount;

		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				that.search();
			}
		})
	}

	this.setScope_onchange = function(obj){
		var selectscope = ld(obj).val();
		if(selectscope == 'smowner_search_senior'){
			this.setScope('senior');
		}else{
			this.setScope('user');
		}
	}

	this.setScope = function(selectvalue){

		// var entry_Fields_Access = new Entry_Fields_Access();
		var module='Settings';
		var popupobj = 'ld-operationlog-chooseusers';
		var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';

		// console.log(ld('#'+popupobj+' #SmOwnerSearchScope option[value=smowner_search_senior]'));
		// if(ld('#'+popupobj+' #SmOwnerSearchScope option[value=smowner_search_senior]').length > 0){
		// 	ld('#'+popupobj+' #SmOwnerSearchScope option[value=smowner_search_senior]').prop('selected',true);
		// }
		// if(ld('#'+popupobj+' #cmb_span_optiontext_SmOwnerSearchScope').length > 0){
		// 	ld('#'+popupobj+' #cmb_span_optiontext_SmOwnerSearchScope').val(arrJsPopLabel['Senior']);
		// }



		if(selectvalue == 'senior')
		{
			selectvalue = 'user';
			getJsScript('include/js/ScopePopup/ScopePopupObj.js',function()
			{
				scopepopupobj =  new ScopePopupObj(module);
				scopepopupobj.popup_caption_value = arrJsPopLabel['Operator'];//标题title
				scopepopupobj.popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div><div id="selectUserCheck"><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
				scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容
				getJsScript('include/js/ScopePopup/ScopePopup.js',function()
				{
					cls_ScopePopup.popup_selecttype = selectvalue;
					cls_ScopePopup.prop.popup_module = module;//模块
			
					if(ld('#'+popupobj).find("#customscope_type").val() == selectvalue){
						cls_ScopePopup.prop.popup_value = ld('#'+popupobj).find("#customscope_ids").val();;
					}else{
						cls_ScopePopup.prop.popup_value = '';
					}
					
					cls_ScopePopup.prop.popup_url = popup_user_url
					scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label><input class="marL10" type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
			
					var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
					var parentsetEventBtnCancel=scopepopupobj.setEventBtnCancel;
					//重写确认按钮事件
					scopepopupobj.setEventBtnOk=function(){
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
							var selected_groupid = cls_ScopePopup.return_obj.return_id;
								if(empty(selected_groupid)){
									confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
									MessagePopup.TipOne_warning(confirm_str);
									return false;
								}
							var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
							var selected_array = cls_ScopePopup.return_obj.return_array;
							ld('#'+popupobj).find("#chooseusers").data('selectvalue',selectvalue);
							ld('#'+popupobj).find("#chooseusers").data('selected_user',selected_user);
							ld('#'+popupobj).find("#customscope_type").val(selectvalue);
							ld('#'+popupobj).find("#customscope_ids").val(selected_user);
							ld('#'+popupobj).find("#SmOwnerSearchScope").val('smowner_search_senior');
							ld('#'+popupobj).find("[name=cmb_span_optiontext_SmOwnerSearchScope]").val(arrJsPopLabel['Senior']);
							// var scopeoptions = ld('#'+popupobj).find("#SmOwnerSearchScope").find('option');
							// scopeoptions.each(function(){
							// 	if(ld(this).val() == 'smowner_search_senior'){
							// 		ld(this).prop('selected', true);
							// 	}
							// })
							msgConfirm();
							return false;
						});
						
					}
				});
			});
		}else if (selectvalue == 'user'){
			var selectval = ld('#'+popupobj).find("#SmOwnerSearchScope").val();
			ld('#'+popupobj).find("#customscope_ids").val(selectval);
		}
	}
}
OperationLogs.curobj = '';
OperationLogs.getInstance=function(){
	if(!empty(OperationLogs.curobj)){
	}else{
		OperationLogs.curobj=new OperationLogs();
	}
    return OperationLogs.curobj;
}
