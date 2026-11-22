//登录策略
function LoginPolicy(){
	var that=this;
	// this.scopetype_value = '';
	// this.scopeids_value = '';
	var crmPopupobj = CrmPopup.getPopupObj("last");
	this.sortableInstance;
}
//刷新
LoginPolicy.refresh = function(){
	var surl = "index.php?module=Settings&action=SettingsAjax&file=loginpolicy";
	ldAjaxNoProgress(surl, "", function (data) {
		if (data.code == 1) {
			ld("#pagecontent .wrapper-panel-inner").html(data.result.content);
		}
	})
}
//创建
LoginPolicy.create = function(ruleid,mode){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginPolicyPop&mode='+mode;
	if(ruleid > 0){
		surl += '&ruleid='+ruleid;
	}
	var Popupwidth = "LdPopWidth600px";
	var crmPopupobj=CrmPopup.load("","","",Popupwidth,'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjax(surl,"",function(data){
		if(data.code==1){
			if(ruleid > 0 && mode != 'allocate'){
				crmPopupobj.setParams(data.result.title,LoginPolicy.save,'',"LdPopWidth800px",'Settings',['edit',ruleid],data.result.oktext,"",data.result.canceltext);
			}else if(ruleid > 0 && mode == 'allocate'){//分配
				crmPopupobj.setParams(data.result.title,LoginPolicy.save,'',"LdPopWidth600px",'Settings',['allocate',ruleid],data.result.oktext,"",data.result.canceltext);
			}else{
				crmPopupobj.setParams(data.result.title,LoginPolicy.save,'',"LdPopWidth800px",'Settings',['create',ruleid],data.result.oktext,"",data.result.canceltext);
			}
			crmPopupobj.show(data.result.content);
			// 设置内容最大高度
			crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
			crmPopupobj.center();
			if(ruleid == 0){
				ld("#"+crmPopupobj.divid+' input[name="enablestatus"]').prop("checked", 'checked'); //新建时启用按钮默认启用
			}
			LoginPolicy.crmPopupobj = crmPopupobj;

			//选择所在城市
			if(mode != 'allocate'){
				crmPopupobj.sourcevalue = data.result.sourcevalue;
				crmPopupobj.region_arr = data.result.region_arr;
				sourcevalue = crmPopupobj.sourcevalue;
				region_arr = crmPopupobj.region_arr;

				region_html = '<select class="ld-select-inner width150 status_sel_0">'
				region_html +='<option class="status_opt_0" value="" ></option>'
				for(i=0;i<sourcevalue.length;i++){
					region_html +='<option class="status_opt_0" value="'+sourcevalue[i]+'" >'+sourcevalue[i]+'</option>'
				}
				region_html += '</select>';
				city_html = '<select class="ld-select-inner width150 marL10 city_sel_0">'
				city_html += '</select>';
				//新建时插入html，编辑时不插入
				var region_len = ld("#"+crmPopupobj.divid+" .Region_option_0").find(".status_sel_0").length;
				if(ruleid == 0||region_len==0){
					ld("#"+crmPopupobj.divid+" .Region_option_0").children("td.region_sel").append(region_html);
					ld("#"+crmPopupobj.divid+" .Region_option_0").children("td.region_sel").append(city_html);
					var delStr = '<a class="padL10 regiondelete_0" title="'+arrJsPopLabel["DELETE"]+'" onclick="LoginPolicy.deleteregionRow(0)">'+arrJsPopLabel["DELETE"]+'</a>';
					ld("#"+crmPopupobj.divid+" .Region_option_0").children("td.region_sel").append(delStr);
				}
				// id = tableobj.find("tr[rowdeleted='no']").length;
				// tmpid = id - 1;
				//循环绑定下拉框点击事件
				var tableobj = ld("#"+crmPopupobj.divid+" #ruletypeTable");
				ld.each(tableobj.find("tr[rowdeleted='no']"),function(i){
					var selectobjs = ld("#"+crmPopupobj.divid+" .status_sel_"+i);
					selectobjs.unbind('click').bind('click',function(){
						LoginPolicy.state_change(this,i,crmPopupobj);
					})
				})
				
				// statusvalue = ld(".status_sel").val();
				// var deletefield = arrJsPopLabel["DELETE"];
				// regiondelete_html = '<td class="regiondelete_0" title="'+deletefield+'" onclick="LoginPolicy.deleteregionRow(0)">'+deletefield+'</td>';
				// ld(".Region_option_0").append(regiondelete_html);

				//IP地址回车生成标签
				var tagContainer = ld("#"+crmPopupobj.divid+' #tagContainer');
				var tagInput = ld("#"+crmPopupobj.divid+' #tagInput').get(0);
				tagInput.addEventListener('keydown', function (event) {
					if (event.key === 'Enter') {
						var tagText = tagInput.value.trim();
						if (tagText !== '') {
							LoginPolicy.createIPTag(tagText);
							tagInput.value = '';
						}
					}
				});
			}
			
			tooltip('.tip-items-list', {transition: true, time: 200});
		}
		DelProgressObjs();
	})
}
//新建，创建和删除IP标签
LoginPolicy.createIPTag = function(text) {
	var istagexist = 'no';
	ld('#tagContainer').find('span').each(function(){
		var tmptag = ld(this).text();
		tmptag = tmptag.replace(/\n/g,"").replace("[A-Za-z]", "").replace("×","");
		tmptag = tmptag.trim();
		if(tmptag == text){
			var contenttext = arrJsPopLabel["ALREADYADDEDTHEIP"];
			MessagePopup.TipZero_warning(contenttext)
			istagexist = 'yes';
		}
	})
	if(istagexist == 'no'){
		delBtntitle = arrJsPopLabel["DELETE"];
		var tag_html = '<span class="tag" style="border-left-color: ;" value="'+text+'">'+text+''
						+'<button class="tag_delbtn" onclick="LoginPolicy.deleteIPTag(this)" title="'+delBtntitle+'">×</button><span>'
		ld("#tagInput").before(tag_html);
	}
}
//编辑，删除已保存的IP标签
LoginPolicy.deleteIPTag = function(obj) {
	ld(obj).parent().remove();
}
//添加当前IP地址
LoginPolicy.addcurrentIP = function() {
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=LoginPolicyPop';
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			var myip = data.result.myip;
			LoginPolicy.createIPTag(myip);
		}
	})
}
//所在城市选择
LoginPolicy.state_change = function(obj,id,crmPopupobj){
	var statusvalue = ld(obj).val();
	if(statusvalue != ''){
		region_arr = crmPopupobj.region_arr;
		city_html = '<select class="city_sel_'+id+'" style="width: 200px;height: 30px;padding: 5px;">'
		for(j=0;j<region_arr[statusvalue].length;j++){
			city_html +='<option value="'+region_arr[statusvalue][j]+'" >'+region_arr[statusvalue][j]+'</option>'
		}
		city_html += '</select>';
		ld("#"+crmPopupobj.divid).find(".city_sel_"+id).html(city_html);
	}
}
//新增行
LoginPolicy.addregionRow = function(){
	var tableobj = ld("#ruletypeTable");
	var id = tableobj.find("tr[rowdeleted='no']:last").attr("rowindex");
	if(id==NaN||id==''||id==undefined){ //没有行时从0计数，有行时在前一行上+1
		id = 0;
	}else{
		id++;
	}
	region_html = '<tr rowindex="'+id+'" rowdeleted="no" class="Region_option_'+id+'">'
	region_html += '<td class="ld-form-item-label"><font color="red">*</font>所在城市</td>'
	region_html += '<td class="ld-form-item-content region_sel" colspan="3">'
	region_html += '<select class="ld-select-inner status_sel_'+id+'" style="width: 200px;">'
	region_html +='<option class="status_opt_'+id+'" value="" ></option>'
	city_html = '<select class="ld-select-inner city_sel_'+id+'" style="width: 200px;margin-left: 10px;">'
	city_html += '</select>';
	for(i=0;i<sourcevalue.length;i++){
		region_html +='<option class="status_opt_'+id+'" value="'+sourcevalue[i]+'" >'+sourcevalue[i]+'</option>'
	}
	var deletefield = arrJsPopLabel["DELETE"];
	region_html += '</select>';
	region_html += '<a class="padL10 regiondelete_'+id+'" title="'+deletefield+'" onclick="LoginPolicy.deleteregionRow('+id+')">'+deletefield+'</a>';
	region_html += '</td></tr>';
	// ld(".Region_option_"+id).append(regiondelete_html);

	tmpid = id-1;
	if(ld(".Region_option_"+tmpid).attr("rowindex") != undefined){
		ld(".Region_option_"+tmpid).after(region_html);
	}
	else{
		ld(".ruletype").after(region_html);
	}
	var currentid = ld(".Region_option_"+id).attr("rowindex")//读取所选下拉框的当前id
	if(currentid != undefined){
		var selectobjs =  ld(".status_sel_"+currentid);
	}
	else{
		var selectobjs =  ld(".status_sel_0");
	}
	ld.each(selectobjs,function(){
		ld(this).unbind('click').bind('click',function(){
			LoginPolicy.state_change(this,currentid,LoginPolicy.crmPopupobj);
		})
	})
	selectobjs.after(city_html);
}
//删除新增行
LoginPolicy.deleteregionRow = function(id){
	ld(".Region_option_"+id).remove();
}
//保存
LoginPolicy.save = function(mode,ruleid){
	var url='index.php?module=Settings&action=SettingsAjax&file=LoginPolicySave&isDuplicate=true';
	if(mode != 'allocate'){
		var popupobj=CrmPopup.getPopupObj('last');
		if(trim(document.forms['LoginPolicyform'].rulename.value)=="")
		{
			//模板名称不能为空！
			confirm_str = arrJsPopLabel['RULENAMECANNOTBEEMPTY'];
			MessagePopup.TipZero_warning(confirm_str);
			document.forms['LoginPolicyform'].rulename.focus();
			return false;
		}
		var rulename=encodeURIComponent(document.forms['LoginPolicyform'].rulename.value);
		var enablestatus=ld("#"+popupobj.divid).find("input[name='enablestatus']").is(':checked');
		var description=encodeURIComponent(document.forms['LoginPolicyform'].description.value);
		var ruletype=encodeURIComponent(document.forms['LoginPolicyform'].ruletype.value);
		var controlmode=encodeURIComponent(document.forms['LoginPolicyform'].controlmode.value);
		if(ruletype == "Geographicalregion"){
			//所在城市不能为空
			var isrowexist = ld("#"+popupobj.divid+" #ruletypeTable").find("tr[rowdeleted='no']:last").attr("rowindex");
			if(isrowexist==''||isrowexist==undefined||isrowexist==null){
				confirm_str = arrJsPopLabel['PLEASECREATEONECITY'];
				MessagePopup.TipOne_warning(confirm_str);
				return false;
			}
			//读取所选省份
			var status_arr = [];
			try {
				ld("#"+popupobj.divid+' .region_sel').find("select:first").each(function(){
					var tmpstatus = ld(this).val();
					if(tmpstatus == ''||tmpstatus == undefined||tmpstatus == null){
						confirm_str = arrJsPopLabel['CITYSELECTIONCANOTEMPTY'];
						MessagePopup.TipZero_warning(confirm_str);
						throw new Error();
					}else{
						status_arr.push(tmpstatus);
					}
				})
			} catch (error) {
				return false;
			}
			//读取所选城市
			var city_arr = [];
			ld("#"+popupobj.divid+' .region_sel').find("select:last").each(function(){
				var tmpcity = ld(this).val();
				city_arr.push(tmpcity);
			})
		}
		if(ruletype == "IPaddress"){
			//请至少创建一条IP地址
			var isIPtagexist = ld("#"+popupobj.divid+' #tagContainer').find('span').length;
			if(isIPtagexist == 0){
				confirm_str = arrJsPopLabel['PLEASECREATEONEIP'];
				MessagePopup.TipOne_warning(confirm_str);
				return false;
			}
			//读取添加的IP地址
			var IPtag_arr = [];
			ld("#"+popupobj.divid+' #tagContainer').find('span').each(function(){
				//读不到value，读了text
				var tmptag = ld(this).text();
				tmptag = tmptag.replace(/\n/g,"").replace("[A-Za-z]", "").replace("×","");
				tmptag = tmptag.trim();
				if(tmptag!=''||tmptag!=undefined){
					IPtag_arr.push(tmptag);
				}
			})
		}
		url=url+"&rulename="+rulename+"&enablestatus="+enablestatus+"&description="+description+"&ruletype="+ruletype+"&controlmode="+controlmode+"&mode="+mode+"&IPaddress="+IPtag_arr
		+"&statusvalue="+status_arr+"&cityvalue="+city_arr;
	}
	//读取适用范围
	// var scopetype_value = LoginPolicy.scopetype_value; //范围类型
	// var scopeids_value = LoginPolicy.scopeids_value;
	var scopetype_value = ld("#"+LoginPolicy.crmPopupobj.divid+" #view_scope").data('selectvalue');
	var scopeids_value = ld("#"+LoginPolicy.crmPopupobj.divid+" #view_scope").data('selected_user');

	if(ld("#"+LoginPolicy.crmPopupobj.divid+" #ALLTHEUSERS").is(':checked')){
		scopetype_value = '0';
		scopeids_value = '-1';
	}


	if(scopetype_value!=undefined)
	{
		url=url+"&scopetype="+scopetype_value;
	}
	if(scopeids_value!=undefined)
	{
		url=url+"&scopeids="+scopeids_value;
	}
	if(ruleid!=undefined)
	{
		url=url+"&ruleid="+ruleid;
	}
	ldAjaxNoProgress(url,"",function(data){
		if(data.code == 1){
			var data_form = new FormData(ld(".ajax_form")[0]);
			if (data_form.get('enablestatus') == 'on' || data_form.get('enablestatus') == 'yes'){
				data_form.set('enablestatus','yes');
			}else{
				data_form.set('enablestatus','no');
			}
			var popupobj=CrmPopup.getPopupObj("last");

			popupobj.CancelEvent();
			LoginPolicy.refresh();
			if(ruleid == 0) contenttext = arrJsPopLabel["SUCCESSFULLYSAVED"];
			else contenttext = arrJsPopLabel["SUCCESSFULLYMODIFIED"];
			MessagePopup.TipZero_success(contenttext);
		}else{
			MessagePopup.TipOne_warning(data.msg);
		}
		return false;
	})
}
//编辑
LoginPolicy.edit = function(ruleid){
	/*var popupobj=CrmPopup.getPopupObj('last');
	if(popupobj!=undefined)
		popupobj.CancelEvent();*/
		// if(ruleid != 1){
			LoginPolicy.create(ruleid,'edit');
		// }
		// else{
		// 	var content = "默认策略无法编辑";
		// 	MessagePopup.TipOne_warning(content);
		// }
}
//列表中启用按钮点击事件
LoginPolicy.changeListBtn = function(obj,ruleid){
	// if(ruleid != 1){
		var tmpruleid = ruleid;
		var isbtnchecked = ld(obj).is(':checked');
		if(isbtnchecked == true){
			enablestatus = 'yes';
		}
		else{
			enablestatus = 'no'
		}
		var update_url = 'index.php?module=Settings&action=SettingsAjax&file=LoginPolicySave&ruleid='+ruleid+'&enablestatus=' + enablestatus + '&mode=updateenable';
		ldAjax(update_url, '', function (data) {
			if (data.code == 1) {
				contenttext = arrJsPopLabel["SUCCESSFULOPERATION"];
				MessagePopup.TipZero_success(contenttext);
				// MessagePopup.TipOne_success(contenttext);
				DelProgressObjs();
			}else{
				MessagePopup.TipOne_warning(data.msg);
				ld(obj).prop('checked','checked');
			}
		})
	// }
	// else{
	// 	ld(obj).prop("checked", 'checked');
	// 	var content = "默认策略无法关闭";
	// 	MessagePopup.TipOne_warning(content);
	// }
}
//取消确认
LoginPolicy.cancel = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	popupobj.CancelEvent();
	// ld("table[name=table_loginpolicy]").sortable("refresh");
	// LoginPolicy.sortableInstance.destroy();
	// LoginPolicy.movetable();
	// LoginPolicy.sortableInstance = Sortable.create(ld("table[name=table_loginpolicy]").find("tbody").get(0));
}
//删除规则
LoginPolicy.delete = function(ruleid)
{
	if(ruleid != 1){
		var content = arrJsPopLabel['CONFIRMWANTDELETERULE'];
		MessagePopup.TipTwo_warning(content);
		var popupobj=CrmPopup.getPopupObj('last');
		ld('#'+popupobj.divid+' input[tagclick="msgConfirm"]').on('click', function () {
			LoginPolicy.deleteinfo(ruleid);
		});
	}
	else{
		MessagePopup.TipOne_warning(arrJsPopLabel['SYSTEMTEMPLATECANOTDELETE']);
	}
}
LoginPolicy.deleteinfo = function(ruleid){
	var surl = "index.php?module=Settings&action=SettingsAjax&file=LoginPolicyDelete&ruleid="+ruleid;
	ldAjax(surl,"",function(data){
		if(data.code == 1){
			LoginPolicy.refresh();
			MessagePopup.TipZero_success(data.result.msg);
		}
		DelProgressObjs();
	})
	msgConfirm();
}
//拖拽改变规则优先级
LoginPolicy.movetable = function(){
	ld('table[name=table_loginpolicy]').find("tr").hover(function() {
		ld('.ld-dragicon').hide();
		ld(this).find('.ld-dragicon').show();
	});
	var dragobj = ld("table[name=table_loginpolicy]").find("tbody").get(0);
	// ld.each(dragobj,function(index,obj){
		Sortable.create(dragobj, {
		group: 'LoginPolicy',
		animation: 150,
		draggable:".ld-category-draggable",
		handle:".drag-handle",
		onEnd: function (evt){
			var sortfield_arr='';
			tableobj = ld('table[name=table_loginpolicy]').find("tr");
			tableobj.attr('onmouseover','');
			tableobj.attr('onmouseout','');
			tableobj.removeClass('lvtColData');
			tableobj.removeClass('lvtColDataBj');
			tableobj.removeClass('lvtColDataHover');
			ld.each(tableobj,function(index,tmpobj){
				if(index>0){
					if(index%2==0){
						ld(tmpobj).addClass('lvtColDataBj');
						ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
						ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
						ld(tmpobj.childNodes[0]).html(index);
						ld(tmpobj.childNodes[2]).html(index);
						fieldid=ld(tmpobj).attr('ruleid');
						sortfield_arr+=fieldid+";";
					}else{
						ld(tmpobj).addClass('lvtColData');
						ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
						ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
						ld(tmpobj.childNodes[0]).html(index);
						ld(tmpobj.childNodes[2]).html(index);
						fieldid=ld(tmpobj).attr('ruleid');
						sortfield_arr+=fieldid+";";
					}
				}
			});
			if(sortfield_arr !=''){
				var update_url='index.php?module=Settings&action=SettingsAjax&file=LoginPolicySave&isDuplicate=true&priorityupdate='+sortfield_arr+'&mode=updatesort';
				ldAjax(update_url,'',function(data){
					if(data.code==1){
						DelProgressObjs();
					}
				})
			}
		}
		});
	// })
}
// LoginPolicy.movetable();
//规则类型转换
LoginPolicy.ruletype_change = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var ruletype_chosen = ld("#"+popupobj.divid+" [name=ruletype]").val();
	if(ruletype_chosen == 'Geographicalregion'){
		ld("#"+popupobj.divid+" tr[rowdeleted='no']").show();
		ld("#"+popupobj.divid+" #groupfooter_1").show();
	}
	else{
		ld("#"+popupobj.divid+" tr[rowdeleted='no']").hide();
		ld("#"+popupobj.divid+" #groupfooter_1").hide();
	}
	if(ruletype_chosen == 'IPaddress'){
		ld("#"+popupobj.divid+" .IPaddress_option").show();
	}
	else{
		ld("#"+popupobj.divid+" .IPaddress_option").hide();
	}
}
//分配
LoginPolicy.allocate = function(ruleid){
	LoginPolicy.create(ruleid,'allocate');
}
//适用范围
LoginPolicy.setScopeFields_Access = function(selectvalue,ruleid){
	// var entry_Fields_Access = new Entry_Fields_Access();
	var module='Settings';
	var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
	var popup_groups_url ='module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module='+module+'&selecttype=group&popup_inputtype=checkbox&popup_selecttype=group';
	var popup_role_url ='module=Users&action=UsersAjax&file=viewprofileinfo&view=private&fld_module='+module+'&popup_selecttype=profile&popup_inputtype=checkbox';
	
	if(selectvalue=='user'||selectvalue=='group'||selectvalue=='role')
	{
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function()
		{
			scopepopupobj =  new ScopePopupObj(module);
			scopepopupobj.popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];//标题title
			scopepopupobj.popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div><div id="selectUserCheck"><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
			scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容
			getJsScript('include/js/ScopePopup/ScopePopup.js',function()
			{
				cls_ScopePopup.popup_selecttype = selectvalue;
				cls_ScopePopup.prop.popup_module = module;//模块
				
						if(ld("#"+LoginPolicy.crmPopupobj.divid+" #customscope_type").val() == selectvalue){
							cls_ScopePopup.prop.popup_value = ld("#"+LoginPolicy.crmPopupobj.divid+" #customscope_ids").val();;
						}else{
							cls_ScopePopup.prop.popup_value = '';
						}
		
				
				if(selectvalue=='user')
				{
					cls_ScopePopup.prop.popup_url = popup_user_url
					scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label><input class="marL10" type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
				}
				else if(selectvalue=='group')
				{
					scopepopupobj.popup_searchvalue=arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
					cls_ScopePopup.prop.popup_url = popup_groups_url
					scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
				}
				else
				{
					cls_ScopePopup.prop.popup_url = popup_role_url
					scopepopupobj.popup_searchvalue=arrJsPopLabel['pleaseenterprofile'];
					scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div>';
				}
				var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				var parentsetEventBtnCancel=scopepopupobj.setEventBtnCancel;
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						var selected_groupid = cls_ScopePopup.return_obj.return_id;
                            if(empty(selected_groupid)){
                                if(selectvalue == 'group'){
                                    confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
									MessagePopup.TipOne_warning(confirm_str);
                                    return false;
                                }else{
                                    confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
									MessagePopup.TipOne_warning(confirm_str);
                                    return false;
                                }
                            }
						var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
						var selected_array = cls_ScopePopup.return_obj.return_array;
						ld("#"+LoginPolicy.crmPopupobj.divid+" #view_scope").data('selectvalue',selectvalue);
						ld("#"+LoginPolicy.crmPopupobj.divid+" #view_scope").data('selected_user',selected_user);
						ld("#"+LoginPolicy.crmPopupobj.divid+" #customscope_type").val(selectvalue);
						ld("#"+LoginPolicy.crmPopupobj.divid+" #customscope_ids").val(selected_user);
						// scopetype_value.val(selectvalue);
						// scopeids_value.val(selected_user);
						// LoginPolicy.scopetype_value = selectvalue;
						// LoginPolicy.scopeids_value = selected_user;
						msgConfirm();
						return false;
					});
					
				}
			});
		});
	}
}
