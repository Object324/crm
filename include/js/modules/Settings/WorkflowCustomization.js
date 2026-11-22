function WorkflowCustomization(){
   var that=this;
   this.ue = '';
}
//刷新
WorkflowCustomization.refresh = function(tabid){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationList&ajax=true&tabid='+tabid;
	ldAjax(surl,"",function(data){
		if(data.code==1){
			ld(' [name=workflow_content]').html(data.result.content);
		}
        DelProgressObjs();
	})
}
//选择模块
WorkflowCustomization.selmodule = function(obj){
	var tabid = ld(obj).val();
	WorkflowCustomization.refresh(tabid);
}
//新增
WorkflowCustomization.create = function(record){
	WorkflowCustomization.edit(record);
}
//接口参数设置
WorkflowCustomization.createApiConfig = function(){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationConfig';
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,WorkflowCustomization.saveApiConfig,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.show(data.result.content);

		}
	})
}
//接口参数
WorkflowCustomization.getConfig = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	//API URL
	var apiurl = ld("#"+popupobj.divid+" [name=apiurl]").val();
	if(empty(apiurl)){
		DelProgressObjs();
		RemindsMsg("","LdPopWidth400px",'',"yes","",'API URL'+arrJsPopLabel['CANOTEMPTY']);
		return false;
	}
	//应用ID
	var orgid = ld("#"+popupobj.divid+" [name=orgid]").val();
	if(empty(orgid)){
		//var confirm_str = ld("#"+popupobj.divid+" [name=orgid]").attr('tag');
		//DelProgressObjs();
		//RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str+arrJsPopLabel['CANOTEMPTY']);
		//return false;
	}
	//client_id
	var client_id = ld("#"+popupobj.divid+" [name=client_id]").val();
	if(empty(client_id)){
		DelProgressObjs();
		RemindsMsg("","LdPopWidth400px",'',"yes","",'client_id'+arrJsPopLabel['CANOTEMPTY']);
		return false;
	}
	//client_secret
	var client_secret = ld("#"+popupobj.divid+" [name=client_secret]").val();
	if(empty(client_secret)){
		DelProgressObjs();
		RemindsMsg("","LdPopWidth400px",'',"yes","",'client_secret'+arrJsPopLabel['CANOTEMPTY']);
		return false;
	}
	//登陆手机号码
	var username = ld("#"+popupobj.divid+" [name=username]").val();
	if(empty(username)){
		DelProgressObjs();
		RemindsMsg("","LdPopWidth400px",'',"yes","",'username'+arrJsPopLabel['CANOTEMPTY']);
		return false;
	}
	//登陆密码
	var password = ld("#"+popupobj.divid+" [name=password]").val();
	if(empty(password)){
		DelProgressObjs();
		RemindsMsg("","LdPopWidth400px",'',"yes","",'password'+arrJsPopLabel['CANOTEMPTY']);
		return false;
	}
	var urlstring = '';
	urlstring += '&apiurl='+encodeURIComponent(apiurl);
	urlstring += '&orgid='+encodeURIComponent(orgid);
	urlstring += '&client_id='+encodeURIComponent(client_id);
	urlstring += '&client_secret='+encodeURIComponent(client_secret);
	urlstring += '&username='+encodeURIComponent(username);
	urlstring += '&password='+encodeURIComponent(password);
	return urlstring;
}

//接口参数保存
WorkflowCustomization.saveApiConfig = function(){
	var config = WorkflowCustomization.getConfig();
	var popupobj=CrmPopup.getPopupObj("last");
	if(config){
		var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationConfig&mode=save'+config;
		var dbname = ld("#"+popupobj.divid+" [name=erp_dbname]").val();
		if(empty(dbname)){
			var confirm_str = ld("#"+popupobj.divid+" [name=erp_dbname]").attr('tag');
			RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str+arrJsPopLabel['CANOTEMPTY']);
			return false;
		}
		var dbname_desc = ld("#"+popupobj.divid+" [name=erp_dbname]").find("option:selected").text()
		urlstring += '&dbname='+encodeURIComponent(dbname)+"&dbname_desc="+encodeURIComponent(dbname_desc);
		ldAjax(urlstring,'',function(data){
			if(data.code==1){
				popupobj.CancelEvent();
				DelProgressObjs();
			}
		});
	}
	
}

var _config = 0;
//接口参数- 获取账套
WorkflowCustomization.getDBName = function(){
	if(_config == 1)return '';
	var popupobj=CrmPopup.getPopupObj("last");
	var config = WorkflowCustomization.getConfig();
	if(config){
		var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationConfig&mode=get'+config;
		ldAjax(urlstring,'',function(data){
			if(data.code==1){
				var _json = data.result.content;
				var select_db_arr = eval("("+_json+")")?eval("("+_json+")"):json.parse(_json);
				var db_name_select = ld("#"+popupobj.divid+" [name=erp_dbname]").get(0);
				db_name_select.length = 0;
				var option = new Option('无','');
				db_name_select.options.add(option);
				ld.each(select_db_arr,function(db,dbname){
					var option = new Option(dbname,db);
					db_name_select.options.add(option);
				});
				_config = 1;
				 ld("#"+popupobj.divid+" [name=orgid]").val(data.result.serviceid);
				DelProgressObjs();
			}
		});
	}
}
//列表：编辑 、 停用、 启用 、  删除
WorkflowCustomization.operateWorkflow = function(obj,event){
	var tag = ld(obj).attr('tag');
	var workflow_id = ld(obj).attr('workflow_id');
	var tabid = ld("#frommodule_tabid").val();
	if(tag == 'edit'){	//编辑
		WorkflowCustomization.edit(workflow_id);
	}else if(tag == 'delete'){	//删除
		var confirm_str = arrJsPopLabel['CANOTRESTOREDAFTERDELETIONDELETEOK'];
		MessagePopup.TipTwo_warning(confirm_str);
		//确认事件
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationList&ajax=true&tabid='+tabid+'&mode=delete&workflow_id='+workflow_id;
			ldAjax(surl,"",function(data){
				if(data.code==1){
					ld(' [name=workflow_content]').html(data.result.content);
				}
				DelProgressObjs();
			})
		});
	}else if(tag == 'status'){	//停用、启用
        if(ld(obj).prop('checked')){
            var _status = 'Inactive';
        }else{
            var _status = 'Active';
        }
		var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationList&ajax=true&tabid='+tabid+'&mode=status&workflow_id='+workflow_id+'&status='+_status;
		ldAjax(surl,"",function(data){
			if(data.code==1){
				ld(' [name=workflow_content]').html(data.result.content);
			}
			DelProgressObjs();
		})
	}
}
//编辑
WorkflowCustomization.edit = function(record){
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomization';
	var mode = 'create';
	var frommodule_tabid = ld("#frommodule_tabid").val();
	if(!empty(record)){
		mode = 'edit';
		surl += '&workflow_id='+record;
	}else{
		if(frommodule_tabid < 0){
			//RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['PLEASESELECTMODULE']);
			//return false;
		}
	}
	surl += '&mode='+mode;
	surl += '&frommodule_tabid='+frommodule_tabid;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,WorkflowCustomization.save,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");  
			crmPopupobj.createScrollDiv();//创建滚动条
			crmPopupobj.show(data.result.content);
			// 设置内容最大高度
			crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
            //edit:xll 20221220 BUG0060003 将选择模块select下拉框改为可输入搜索下拉框div
            var selecttypeobj=ld("#"+crmPopupobj.divid+" [fieldtype=selecttype]");
            if(selecttypeobj.length>0&&selecttypeobj!=undefined){
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selecttypeobj.attr("name"));
                cls_resetComboxHtmlobj.setPopupObj(crmPopupobj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selecttypeobj,150);
            }
			crmPopupobj.showvalues=data.result.showvalues;
			crmPopupobj.datetimestr=data.result.datetimestr;//基本查询
			crmPopupobj.viewnamelabel=data.result.viewnamelabel;
			crmPopupobj.modulelabel=data.result.modulelabel;

			var advancefilterobj = new cls_advanceFilter();
			var params = {};
			params.columnOptionHtml = data.result.columns_block;
			params.fLabels = data.result.flabels;
			params.datetimestr = data.result.datetimestr;
			params.advfilterhtml = data.result.foption;
			params.criteria_groups_arr = data.result.criteria_groups;
			params.module = 'Settings';
			params.source = 'WorkflowCustomizationList';
			// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
			params.advanceFields = data.result.advanceFields;
			advancefilterobj.showAdvanceFilter(crmPopupobj,params);

			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();
			WorkflowCustomization.createbing();
            WorkflowCustomization.setSort();//设置拖动
		}
		else{
			crmPopupobj.CancelEvent();
			DelProgressObjs();
			RemindsMsg("","LdPopWidth400px",'',"yes","",data.result.msg);
			var  popupobj=CrmPopup.getPopupObj('last');
			ld('#'+popupobj.divid+' .E_pbtnok').click(function() {
				WorkflowCustomization.createApiConfig();
			})
			return false;
		}
	})
}
WorkflowCustomization.setSort=function()
{
    
    var popupobj=CrmPopup.getPopupObj("last");
    
      var tableobj=ld("#"+popupobj.divid+" [name=table_workflow_actions]");
      if(ld(tableobj).find("tbody").find(" .drag-handle").length<=1)
      {
        ld(tableobj).find("tbody").find(" .drag-handle").css("display",'none')
      }
      var tbody=ld(tableobj).find("tbody").get(0);
     Sortable.create(tbody,{
		     draggable: ".dragtrrow",  // 允许拖拽的项目类名,否则会拖拽到小计行
		//	animation: 500,
			handle: '.drag-handle',
		
            onStart:function(evt){
                evt.preventDefault();
                evt.stopPropagation();
            },
		   onUpdate: function (/**Event*/evt) {
                                        // same properties as onEnd
             evt.preventDefault();
             },
			onEnd: function (evt) {	//移动行
               var workflowid=ld("#"+popupobj.divid+" [name=workflow_id]").val();
               if(workflowid>0)
                {
                    //ldAjax("index.php?module=Settings&action=SettingsAjax&file=WorkFlowActionSort&workflowid=")
                }
               ld.each(ld(tableobj).find("tbody").find('tr:not(:first)'),function(index,trobj){
               		ld(this).find('td:first').html(index+1);
			   });
			}
		}); 
}
WorkflowCustomization.edit.funanme = 'WorkflowCustomization.edit';
//新增界面事件绑定
WorkflowCustomization.createbing = function(){
	//触发点
	var popupobj=CrmPopup.getPopupObj("last");
	ld("#"+popupobj.divid+" [name=workflow_triggertime]").unbind('click').on('click',function(){
		var workflow_triggertime = ld(this).attr('value');
		ld("#"+popupobj.divid+" #workflow_add_action_list li").show();
		if(workflow_triggertime == 'Creation'){
			ld("#"+popupobj.divid+" [name=tr_RepeatMode]").hide();
			ld("#"+popupobj.divid+" [name=tr_ApprovalNode]").hide(); 
		}else if(workflow_triggertime == 'Updated' || workflow_triggertime == 'Advanced' || workflow_triggertime == 'Allocated' || workflow_triggertime == 'Shared'){
			ld("#"+popupobj.divid+" [name=tr_RepeatMode]").show();
			ld("#"+popupobj.divid+" [name=tr_ApprovalNode]").hide();
		}else if(workflow_triggertime == 'Approval'){
			ld("#"+popupobj.divid+" [name=tr_RepeatMode]").hide();
			ld("#"+popupobj.divid+" [name=tr_ApprovalNode]").show();
		}else if(workflow_triggertime == 'Deleted'){
			ld("#"+popupobj.divid+" [name=tr_RepeatMode]").hide();
			ld("#"+popupobj.divid+" [name=tr_ApprovalNode]").hide();
			//BUG0071991 ls 20230831 触发器中的触发点选择“删除”时，工作流操作中去掉“自动共享”和“更新字段”
			ld("#"+popupobj.divid+" #workflow_add_action_list li").each(function(){
				var tmp_actiontype = ld(this).data('actiontype');
				if (tmp_actiontype == 'auto_share' || tmp_actiontype == 'update_fields') {
					ld(this).hide();
				}
			});
		}

	});
    ld("#"+popupobj.divid+" [name=flowmodulelist]").unbind("change").on("change",function(){
        //选择模块
        ld("#"+popupobj.divid+" [name=tabid]").val(ld(this).val());
        ld("#"+popupobj.divid+" [name=workflowmodulelabel]").html(ld(this).find("option:selected").text());
		// ld("#"+popupobj.divid+" [name=flowmodulelist]").css("display",'none');
		ld("#"+popupobj.divid+" [name=table_workflow_actions]").find(".dragtrrow").remove();
        var scrolltop=ld("#"+popupobj.divid+"_scroll").scrollTop();
        ldAjax("index.php?module=Settings&action=SettingsAjax&file=WorkflowAdvSearch&tabid="+ld(this).val()+"&flowadv=yes",{},function(ajaxdata){
			popupobj.advanceFilterObj.columnOptionHtml = ajaxdata.result.columns_block;
			popupobj.advanceFilterObj.advfilterhtml = ajaxdata.result.foption;
			popupobj.advanceFilterObj.changeAdvanceCondition(ajaxdata.result.criteria_groups)
			var displaystatus = '';
			ld.each(ajaxdata.result.btnstatus,function(key,status){// 隐藏或显示审批推进等触发点中的选项
				displaystatus = status=='yes'?'':'none';
				ld("#"+popupobj.divid).find("#workflow_triggertime_"+key).css('display',displaystatus);
				ld("#"+popupobj.divid).find("#workflow_triggertime_"+key).next('label').css('display',displaystatus);
				if(displaystatus == 'none'){
					if(key == 'Approval'){
						ld("#"+popupobj.divid).find("tr[name=tr_ApprovalNode]").css('display',displaystatus);
					}else{
						ld("#"+popupobj.divid).find("tr[name=tr_RepeatMode]").css('display',displaystatus);
					}
					ld("#"+popupobj.divid).find("#workflow_triggertime_Creation").prop("checked",true);
				}
			});
			DelProgressObjs();
			//edit:can 20221125 kfbcrm新建工作流程定制--选择模块后，滚动条就到最下面了（详情见附件） 
			ld("#"+popupobj.divid+"_scroll").scrollTop(scrolltop);
        })
    })
	//添加操作
	/*ld("#"+popupobj.divid+" [name=workflow_add_action]").unbind('change').on('change',function(){
		//调用api
        var tabid=ld("#"+popupobj.divid+" [name=tabid]").val();
        if(tabid<=0)
       	{
       	     RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['PLEASESELECTMODULE']);
		    return false;
       	}
		if(this.value == 'api'){
			WorkflowCustomization.addAction(0);
		}else if(this.value == 'update_fields'){	//更新字段
			WorkflowCustomization.addActionForUpdateFields(0);
		}else if(this.value == 'excute_sql'){	//执行SQL
			WorkflowCustomization.addActionForExcuteSql(0);
		}else if(this.value == 'auto_share'){
			WorkflowCustomization.addActionForAutoShare(0);
		}
	});*/
	ld("#"+popupobj.divid+" [name=workflow_add_action]").unbind('click').on('click',function(){
		//调用api
		var tabid=ld("#"+popupobj.divid+" [name=tabid]").val();
		if(tabid<=0)
		{
			RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['PLEASESELECTMODULE']);
			return false;
		}
		if(ld("#"+popupobj.divid+" #workflow_add_action_list:visible").length > 0){
			ld("#"+popupobj.divid+" #workflow_add_action_list").hide();
		}else {
			ld("#"+popupobj.divid+" #workflow_add_action_list").show();
			if(ld("#"+popupobj.divid+" [name=table_workflow_actions]").get(0).offsetHeight < ld("#"+popupobj.divid+" #workflow_add_action_list").get(0).offsetHeight){
				ld("#"+popupobj.divid+" #workflow_add_action_list").css('top','-'+ld("#"+popupobj.divid+" #workflow_add_action_list").get(0).offsetHeight+'px');
			}else{
				ld("#"+popupobj.divid+" #workflow_add_action_list").css('top','30px');
			}
			ld("#"+popupobj.divid+" #workflow_add_action_list").focus();
			ld("#"+popupobj.divid+" #workflow_add_action_list").unbind('blur').bind('blur',function (){
				ld(this).hide();
			});

			ld("#"+popupobj.divid+" #workflow_add_action_list li").unbind('click').bind('click',function (){
				var tmp_actiontype = ld(this).data('actiontype');
				if(tmp_actiontype == 'api'){
					WorkflowCustomization.addAction(0);
				}else if(tmp_actiontype == 'link2erp'){
					WorkflowCustomization.addActionForLink2ERP(0);
				}else if(tmp_actiontype == 'update_fields'){	//更新字段
					WorkflowCustomization.addActionForUpdateFields(0);
				}else if(tmp_actiontype == 'excute_sql'){	//执行SQL
					WorkflowCustomization.addActionForExcuteSql(0);
				}else if(tmp_actiontype == 'auto_share'){
					WorkflowCustomization.addActionForAutoShare(0);
				}
				ld("#"+popupobj.divid+" #workflow_add_action_list").hide();
			});
		}
	});
	
}
//添加工作流  - 自动共享
WorkflowCustomization.addActionForAutoShare = function (workflow_actionid){
	var popupobj=CrmPopup.getPopupObj("last");
	var workflow_id = ld("#"+popupobj.divid+" [name=workflow_id]").val();
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForAutoShare&tabid='+ld("#"+popupobj.divid+" [name=tabid]").val()+'&workflow_actionid='+workflow_actionid+'&workflow_id='+workflow_id;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code == 1){
			ld("#"+popupobj.divid+" [name=workflow_add_action]").find("option[value=add_action]").prop("selected",true);
			crmPopupobj.setParams(data.result.title,WorkflowCustomization.saveAction,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.createScrollDiv();
			crmPopupobj.show(data.result.content);
			crmPopupobj.center();
			WorkflowCustomization.addActionForAutoShareBind();
		}
	});
}
//自动分享页面绑定事件
WorkflowCustomization.addActionForAutoShareBind = function () {
	var popupobj = CrmPopup.getPopupObj("last");
	//共享方式
	ld('#' + popupobj.divid + ' select[name=Action_autoshare_type]').unbind('change').bind('change', function () {
		var autoshare_type = ld(this).val();
		if(autoshare_type == 'User'){
			ld('#'+popupobj.divid+' [name=Action_autoshare_User]').show();
			ld('#'+popupobj.divid+' [name=Action_autoshare_UserField]').hide();
		}else if(autoshare_type == 'UserField'){
			ld('#'+popupobj.divid+' [name=Action_autoshare_User]').hide();
			ld('#'+popupobj.divid+' [name=Action_autoshare_UserField]').show();
		}
	});
	//多选用户
	ld('#'+popupobj.divid+' #Action_autoshare_User_select').unbind('click').bind('click',function(){
		var module = ld('#'+popupobj.divid+' #autoshare_module').val();

		var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user&checkprivilege=no';
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function()
		{
			scopepopupobj =  new ScopePopupObj(module);
			//wym BUG0076171 工作流程定制，新增->添加工作流操作->自动共享弹出层中，指定成员左上角弹窗中的标签显示undefined
			scopepopupobj.popup_caption_value = ld('#'+popupobj.divid+' [name=Action_autoshare_User]').data('selectlabel');//标题title
			scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容
			getJsScript('include/js/ScopePopup/ScopePopup.js',function()
			{
				cls_ScopePopup.prop.popup_module = module;//模块

				cls_ScopePopup.prop.popup_value = ld("#"+popupobj.divid+" #Action_autoshare_User_value").val();

				cls_ScopePopup.prop.popup_url = popup_user_url
				scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label><input class="marL10" type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';


				var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				var parentsetEventBtnCancel=scopepopupobj.setEventBtnCancel;
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
						var selected_array = cls_ScopePopup.return_obj.return_array;
						var selectes_label = [];
						ld.each(selected_array,function(index,tmpobj){
							selectes_label.push(tmpobj.name);
						});
						ld("#"+popupobj.divid+" #Action_autoshare_User_value").val(selected_user);
						ld("#"+popupobj.divid+" #Action_autoshare_User_div").html(selectes_label.toString());
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
					});
				}
			});
		});
	});
	//清除多选用户
	ld('#'+popupobj.divid+' #Action_autoshare_User_clear').unbind('click').bind('click',function(){
		ld("#"+popupobj.divid+" #Action_autoshare_User_value").val('');
		ld("#"+popupobj.divid+" #Action_autoshare_User_div").html('');
	});
}
//添加工作流  - 执行SQL
WorkflowCustomization.addActionForExcuteSql = function(workflow_actionid){
	var popupobj=CrmPopup.getPopupObj("last");
	var workflow_id = ld("#"+popupobj.divid+" [name=workflow_id]").val();
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForExcuteSql&tabid='+ld("#"+popupobj.divid+" [name=tabid]").val()+'&workflow_actionid='+workflow_actionid+'&workflow_id='+workflow_id;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			ld("#"+popupobj.divid+" [name=workflow_add_action]").find("option[value=add_action]").prop("selected",true); 
			crmPopupobj.setParams(data.result.title,WorkflowCustomization.saveAction,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.createScrollDiv();
			crmPopupobj.show(data.result.content);
			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();
		}
	});
};
//添加工作流  - 更新字段
WorkflowCustomization.addActionForUpdateFields = function(workflow_actionid){
	var popupobj=CrmPopup.getPopupObj("last");
	var workflow_id = ld("#"+popupobj.divid+" [name=workflow_id]").val();
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForUpdateFields&tabid='+ld("#"+popupobj.divid+" [name=tabid]").val()+'&workflow_actionid='+workflow_actionid+'&workflow_id='+workflow_id;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			ld("#"+popupobj.divid+" [name=workflow_add_action]").find("option[value=add_action]").prop("selected",true); 
			crmPopupobj.setParams(data.result.title,WorkflowCustomization.saveAction,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.createScrollDiv();
			crmPopupobj.show(data.result.content);
			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();
			WorkflowCustomization.addActionForUpdateFieldsBind();
			WorkflowCustomization.addActionForUpdateFieldsBind_AddTr();
			WorkflowCustomization.addActionForUpdateFieldsBind_SetFval();
			if(!empty(workflow_actionid)){
				ld("#"+crmPopupobj.divid+" [name=conditiongrouptable] tr").each(function(){
					var referencemodule_fields_uitype = ld(this).find(' [name="referencemodule_fields"]').find('option:selected').attr('uitype');
					if(referencemodule_fields_uitype == 33){	//多选框
						ld(this).find(' [id="fval"]').select2({closeOnSelect: false});
					}
					if(referencemodule_fields_uitype == 56){	//复选框
						var that=this;
						ld(this).find(' [tag=checkbox_fval]').unbind('click').on('click',function(){
							if(ld(this).prop('checked')){
								ld(that).find(' [name="select_value"]').val(1);
								ld(that).find(' [name="select_label"]').val(arrJsPopLabel['YES']);
							}else{
								ld(that).find(' [name="select_value"]').val(0);
								ld(that).find(' [name="select_label"]').val(arrJsPopLabel['NO']);
							}
						});
					}
				});
			}
		}
	});
}

//添加工作流  - 更新字段 - 页面事件绑定
WorkflowCustomization.addActionForUpdateFieldsBind = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	//选择模块
	ld("#"+popupobj.divid+" [tag=reference_module]").unbind('change').on('change',function(){
		var reference_module = ld(this).val();
		var rowid = ld(this).attr('rowid');
		var rowobj=ld("#"+popupobj.divid+" [name=conditiongrouptable]").find("tr[rowindex="+rowid+"]");
		var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForUpdateFields&sel_module='+reference_module+'&getModuleField=yes';
		ldAjaxNoProgress(urlstring,"",function(data){
			if(data.code==1){
				ld(rowobj).find(' [name="referencemodule_fields"]').html(data.result);
				//ld("#"+popupobj.divid+" [name=referencemodule_fields_"+rowid+"]").html(data.result);
			}
		});
		return false;
	});

	//选择字段
	ld("#"+popupobj.divid+" [tag=reference_module_fields]").unbind('change').on('change',function(){
		var rowid = ld(this).attr('rowid');
		var rowobj=ld("#"+popupobj.divid+" [name=conditiongrouptable]").find("tr[rowindex="+rowid+"]");
		var fieldname = ld(this).find("option:selected").attr('tag');
		var reference_module = ld(rowobj).find(' [name="referencemodule"]').val();
		var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForUpdateFields&sel_module='+reference_module+'&fieldname='+fieldname+'&selectfield=yes&rowid='+rowid;
		//alert(urlstring);
		ldAjaxNoProgress(urlstring,"",function(data){
			if(data.code==1){
				ld(rowobj).find(' [name="field_uitype"]').val(data.result.uitype);
				if(data.result.type == 'select'){	//下拉框  多选框
					ld(rowobj).find(' [name="td_fval"]').html(data.result.select_html);
					ld(rowobj).find(' [name="select_mode"]').val('Text');
					ld(rowobj).find(' [name="select_value"]').val(data.result.select_value);
					ld("#"+popupobj.divid+" [tag=select_fval]").unbind('click').on('click',function(){
						ld(rowobj).find(' [name="select_value"]').val(ld(this).val());
					});
					if(data.result.uitype == 33){
						ld(rowobj).find(' [id="fval"]').select2({closeOnSelect: false});
					}
					
				}else if(data.result.type == 'boolean'){	//复选框
					ld(rowobj).find(' [name="td_fval"]').html(data.result.select_html);
					ld(rowobj).find(' [name="select_mode"]').val('Text');
					ld(rowobj).find(' [name="select_value"]').val(0);
					ld(rowobj).find(' [name="select_label"]').val(arrJsPopLabel['NO']);
					ld("#"+popupobj.divid+" [tag=checkbox_fval]").unbind('click').on('click',function(){
						if(ld(this).prop('checked')){
							ld(rowobj).find(' [name="select_value"]').val(1);
							ld(rowobj).find(' [name="select_label"]').val(arrJsPopLabel['YES']);
						}else{
							ld(rowobj).find(' [name="select_value"]').val(0);
							ld(rowobj).find(' [name="select_label"]').val(arrJsPopLabel['NO']);
						}
					});
				}else if(data.result.type == 'user'){
					ld(rowobj).find(' [name="td_fval"]').html('<div type="text" style="width: 100%;color: #3B4859;font-size: 13px;padding-left: 5px;padding-top: 0;line-height: 20px;" class="ld-input-inner" name="fval" readonly="" value="" rowid="'+rowid+'" tag="fval"></div>');
					WorkflowCustomization.addActionForUpdateFieldsBind_SetFval();
				}else{
					ld(rowobj).find(' [name="td_fval"]').html('<input type="text" style="width: 100%;" class="ld-input-inner" name="fval" tag="fval" readonly="" rowid="'+rowid+'">');
					WorkflowCustomization.addActionForUpdateFieldsBind_SetFval();
				}
				
			}
		});
		return false;
	});

	//删除
	ld("#"+popupobj.divid+" [tag=fdeleted]").unbind('click').on('click',function(){
		var rowid = ld(this).attr('rowid');
		ld("#"+popupobj.divid+" [rowindex="+rowid+"]").remove();
	});
}
//添加工作流  - 更新字段 - 页面事件绑定 - 设定取值
WorkflowCustomization.addActionForUpdateFieldsBind_SetFval = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var prev_popupobj=CrmPopup.getPopupObj("lastprev");
	ld("#"+popupobj.divid+" [tag=fval]").unbind('click').on('click',function(){
		var tabid = ld("#"+prev_popupobj.divid+" [name=tabid]").val();
		var rowid = ld(this).attr('rowid');
		var rowobj=ld("#"+popupobj.divid+" [name=conditiongrouptable]").find("tr[rowindex="+rowid+"]");
		var referencemodule = ld(rowobj).find(' [name="referencemodule"]').val();
		//请选择模块
		if(referencemodule == ''){
			RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['PLEASESELECTMODULE']);
			return false;
		}
		//请选择字段
		var referencemodule_fields = ld(rowobj).find(' [name="referencemodule_fields"]').val();
		if(referencemodule_fields == ''){
			var please_selmodulefields = ld("#"+popupobj.divid+" [name=please_select_module_fields]").val();
			RemindsMsg("","LdPopWidth400px",'',"yes","",please_selmodulefields);
			return false;
		}
		var select_mode = ld(rowobj).find(' [name="select_mode"]').val();
		var select_value = ld(rowobj).find(' [name="select_value"]').val();
		var select_label = ld(rowobj).find(' [name="select_label"]').val();
		var field_uitype = ld(rowobj).find(' [name="field_uitype"]').val();
		var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForSetValue&tabid='+tabid+'&setValue=yes&rowid='+rowid+'&select_mode='+select_mode+"&select_value="+select_value+"&select_label="+select_label+"&field_uitype="+field_uitype;
		//alert(urlstring);
		//return false;
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(urlstring,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,WorkflowCustomization.saveSetFval,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.createScrollDiv();
				crmPopupobj.show(data.result.content);
				crmPopupobj.setScrollDivMaxHeight();
				crmPopupobj.center();
				WorkflowCustomization.addActionForSetValueBind(data);
			}
		});
	});
}
//添加工作流  - 更新字段 - 页面事件绑定 - 设定取值 - 保存
WorkflowCustomization.saveSetFval = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var prev_popupobj=CrmPopup.getPopupObj("lastprev");
	var rowid = ld("#"+popupobj.divid+" [name=rowid]").val();
	var select_mode = ld("#"+popupobj.divid+" [name=select_setmode]").val();
	var select_value = '';
	var select_label = '';
	//文本
	if(select_mode == 'Text'){
		select_value = ld("#"+popupobj.divid+" [name=text_setvalue]").val();
		if(empty(select_value)){
			RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['Text']+arrJsPopLabel['CONTENTCANOTEMPTY']);
			return false;
		}
	}else if(select_mode == 'Field'){	//字段
		select_value = ld("#"+popupobj.divid+" [name=select_module_field]").val();
		select_label = ld("#"+popupobj.divid+" [name=select_module_field]").find("option:selected").attr("tag");
		if(empty(select_value)){
			RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['PLEASESELECTFIELD']);
			return false;
		}
	}else if(select_mode == 'User_one'){
		select_value = ld("#"+popupobj.divid+" [name=workflow_action_updatefields_selectuser_one]").val();
		select_label = ld("#"+popupobj.divid+" [name=cmb_span_optiontext_workflow_action_updatefields_selectuser_one]").html();
		if(empty(select_value)){
			RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['PLEASESELECTFIELD']);
			return false;
		}
	}else if(select_mode == 'User_more'){
		select_value = ld("#"+popupobj.divid+" #workflow_action_updatefields_selectuser_more_value").val();
		select_label = ld("#"+popupobj.divid+" #workflow_action_updatefields_selectuser_more_div").html();
		if(empty(select_value)){
			RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['PLEASESELECTFIELD']);
			return false;
		}
	}
	var rowobj=ld("#"+prev_popupobj.divid+" [name=conditiongrouptable]").find("tr[rowindex="+rowid+"]");
	ld(rowobj).find(' [name="select_mode"]').val(select_mode);
	ld(rowobj).find(' [name="select_value"]').val(select_value);
	ld(rowobj).find(' [name="select_label"]').val(select_label);
	if(select_mode == 'Text'){
		ld(rowobj).find(' [name="fval"]').val(select_value);
	}else if(select_mode == 'Field'){
		ld(rowobj).find(' [name="fval"]').val(select_label);
		ld(rowobj).find(' [name="fval"]').html(select_label);
	}else if(select_mode == 'User_one' || select_mode == 'User_more'){
		ld(rowobj).find(' [name="fval"]').html(select_label);
	}
	popupobj.CancelEvent();
	DelProgressObjs();
	return false;
}
//添加工作流  - 更新字段 - 页面事件绑定 - 设定取值界面事件绑定
WorkflowCustomization.addActionForSetValueBind = function(data){
	var popupobj=CrmPopup.getPopupObj("last");
	//设定取值 类型
	if(ld('#'+popupobj.divid+' select[name=select_setmode]').val() == 'User_one' || ld('#'+popupobj.divid+' select[name=select_setmode]').val() == 'User_more'){
		ld('#'+popupobj.divid+' tr[name=tr_text_setvalue]').hide();
	}

	//多选用户绑定
	ld('#'+popupobj.divid+' #updatefields_selectuser_more').unbind('click').bind('click',function(){
		var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module=Settings&popup_inputtype=checkbox&popup_selecttype=user&checkprivilege=no';
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function()
		{
			scopepopupobj =  new ScopePopupObj('Settings');
			scopepopupobj.popup_caption_value = ld(this).data('selectlabel');//标题title
			scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容
			getJsScript('include/js/ScopePopup/ScopePopup.js',function()
			{
				cls_ScopePopup.prop.popup_module = 'Settings';//模块

				cls_ScopePopup.prop.popup_value = ld("#"+popupobj.divid+" #workflow_action_updatefields_selectuser_more_value").val();

				cls_ScopePopup.prop.popup_url = popup_user_url
				scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label><input class="marL10" type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';


				var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				var parentsetEventBtnCancel=scopepopupobj.setEventBtnCancel;
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
						var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
						var selected_array = cls_ScopePopup.return_obj.return_array;
						var selectes_label = [];
						ld.each(selected_array,function(index,tmpobj){
							selectes_label.push(tmpobj.name);
						});
						ld("#"+popupobj.divid+" #workflow_action_updatefields_selectuser_more_value").val(selected_user);
						ld("#"+popupobj.divid+" #workflow_action_updatefields_selectuser_more_div").html(selectes_label.toString());
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
					});
				}
			});
		});
	});

	//清除多选用户
	ld('#'+popupobj.divid+' #workflow_action_updatefields_selectuser_more_clear').unbind('click').bind('click',function(){
		ld("#"+popupobj.divid+" #workflow_action_updatefields_selectuser_more_value").val('');
		ld("#"+popupobj.divid+" #workflow_action_updatefields_selectuser_more_div").html('');
	});

	var userid_arr = data.result.USERS_ARR;
	var inputobj=ld('#'+popupobj.divid+' [name=workflow_action_updatefields_selectuser_one]');
	if(inputobj.length>0&&inputobj!=undefined) {
		var cls_resetComboxHtmlobj = new cls_resetComboxHtml(inputobj.attr("name"));
		cls_resetComboxHtmlobj.setPopupObj(popupobj);
		cls_resetComboxHtmlobj.searchhtmltype = 'html';
		cls_resetComboxHtmlobj.setPickListContent(userid_arr);
		cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(inputobj,150);
	}
	if(ld("#"+popupobj.divid+" [name=select_setmode]").val() != 'User_one'){
		ld('#'+popupobj.divid+' [name=dv_cmb_workflow_action_updatefields_selectuser_one]').hide();
	}

	ld("#"+popupobj.divid+" [name=select_setmode]").unbind('change').on('change',function(){
		var sevalue_type = ld(this).val();
		ld("#"+popupobj.divid+" [name=tr_text_setvalue]").show();
		if(sevalue_type == 'Text' || sevalue_type == 'Sql'){
			ld("#"+popupobj.divid+" [name=select_module_field]").hide();
			ld("#"+popupobj.divid+" [name=select_function]").hide();
			ld("#"+popupobj.divid+" [name=tr_text_setvalue]").val('');
			ld("#"+popupobj.divid+" [name=dv_cmb_workflow_action_updatefields_selectuser_one]").hide();
			ld("#"+popupobj.divid+" [name=workflow_action_updatefields_selectuser_more]").hide();
		}
		if(sevalue_type == 'Field'){
			ld("#"+popupobj.divid+" [name=select_module_field]").show();
			ld("#"+popupobj.divid+" [name=select_function]").hide();
			ld("#"+popupobj.divid+" [name=tr_text_setvalue]").hide();
			ld("#"+popupobj.divid+" [name=dv_cmb_workflow_action_updatefields_selectuser_one]").hide();
			ld("#"+popupobj.divid+" [name=workflow_action_updatefields_selectuser_more]").hide();
		}
		if(sevalue_type == 'User_one'){//单选用户
			ld("#"+popupobj.divid+" [name=dv_cmb_workflow_action_updatefields_selectuser_one]").show();
			ld("#"+popupobj.divid+" [name=workflow_action_updatefields_selectuser_more]").hide();
			ld("#"+popupobj.divid+" [name=select_module_field]").hide();
			ld('#'+popupobj.divid+' tr[name=tr_text_setvalue]').hide();
		}
		if(sevalue_type == 'User_more'){//多选用户
			ld("#"+popupobj.divid+" [name=workflow_action_updatefields_selectuser_more]").show();
			ld("#"+popupobj.divid+" [name=dv_cmb_workflow_action_updatefields_selectuser_one]").hide();
			ld("#"+popupobj.divid+" [name=select_module_field]").hide();
			ld('#'+popupobj.divid+' tr[name=tr_text_setvalue]').hide();
		}
		return false;
	});
}

//添加工作流  - 更新字段 - 页面事件绑定 - 添加行
WorkflowCustomization.addActionForUpdateFieldsBind_AddTr = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	//添加新字段
	ld("#"+popupobj.divid+" [name=addConditiongroup]").unbind('click').on('click',function(){
		var rowcnt = ld("#"+popupobj.divid+" [name=conditiongrouptable]").find("tr").length;
		var tr_row = rowcnt + 1;
		var rowindex = rowcnt-1;
		var please_selmodulefields = ld("#"+popupobj.divid+" [name=please_select_module_fields]").val();
		var referecemodule_json = ld("#"+popupobj.divid+" [name=referecemodule_json]").val();
		var referecemodule_array = eval('(' + referecemodule_json + ')') ? eval('(' + referecemodule_json + ')') : JSON.parse(referecemodule_json);
		var table_tr = '';
		table_tr += '<tr rowindex="'+tr_row+'">';
		table_tr += '<input type="hidden" value="" name="select_mode" />';
		table_tr += '<input type="hidden" value="" name="select_value" />';
		table_tr += '<input type="hidden" value="" name="select_label" />';
		table_tr += '<input type="hidden" value="" name="field_uitype" />';
		table_tr += '<td width="25%" align="left" class="padB16">';
		table_tr += '<select name="referencemodule" rowid="'+tr_row+'" tag="reference_module" class="ld-select-inner gwidth90" tagclick="WorkflowCustomization.addActionForUpdateFieldsBind">';
		table_tr += '<option value="">'+arrJsPopLabel['PLEASESELECTMODULE']+'</option>';
		ld.each(referecemodule_array, function (module, module_label) {
			table_tr += '<option value="'+module+'">'+module_label+'</option>';
		});
		table_tr += '</select>';
		table_tr += '</td>';

		table_tr += '<td width="20%" align="left" class="padB16">';
		table_tr += '<select name="referencemodule_fields" tag="reference_module_fields" rowid="'+tr_row+'" class="ld-select-inner gwidth90" >';
		table_tr += '<option value="">'+please_selmodulefields+'</option>';
		table_tr += '</select>';
		table_tr += '</td>';


		table_tr += '<td align="left" name="td_fval" class="padB16">';
		table_tr += '<input type="text" class="ld-input-inner gwidth90" readonly="" name="fval" tag="fval" rowid="'+tr_row+'">';
		table_tr += '</td>';

		table_tr += '<td width="100px" align="left" class="padB16"><a href="javascript:void(0);" name="fdeleted" rowid="'+tr_row+'" tag="fdeleted" title="'+arrJsPopLabel['DELETE']+'" >'+arrJsPopLabel['DELETE']+'</a></td>';

		table_tr += '</tr>';

		//BUG0071640 liushuai 20230824 工作流程定制，添加工作流操作 -> 更新字段弹出层中，删除第一行条件，点击“新条件”点不动
		var last_tr = ld("#"+popupobj.divid+" [name=conditiongrouptable] tbody>tr");
		if (last_tr.length<1) {
			ld("#"+popupobj.divid+" [name=conditiongrouptable] tbody").html(table_tr);
		}else{
			ld("#"+popupobj.divid+" [name=conditiongrouptable] > tbody > tr:eq("+eval(rowindex)+")").after(table_tr);
		}


		WorkflowCustomization.addActionForUpdateFieldsBind();
	});
}
//添加工作流
WorkflowCustomization.addAction = function(workflow_actionid){
	var popupobj=CrmPopup.getPopupObj("last");
	var workflow_id = ld("#"+popupobj.divid+" [name=workflow_id]").val();
	// var jdyisv = ld("#"+popupobj.divid+" [name=jdyisv]").val();
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForApi&tabid='+ld("#"+popupobj.divid+" [name=tabid]").val()+'&workflow_actionid='+workflow_actionid+'&workflow_id='+workflow_id/*+"&jdyisv="+jdyisv*/;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			ld("#"+popupobj.divid+" [name=workflow_add_action]").find("option[value=add_action]").prop("selected",true); 
			crmPopupobj.setParams(data.result.title,WorkflowCustomization.saveAction,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.createScrollDiv();
			crmPopupobj.show(data.result.content);
			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();
			// ld("#"+crmPopupobj.divid+" [value=json]").attr('checked', "checked");
			// ld("#"+crmPopupobj.divid+" [name=tr_json_module_field]").show();
			// ld("#"+crmPopupobj.divid+" [name=tr_json_body]").show();
			// ld("#"+crmPopupobj.divid+" [name=tr_json_data]").hide();
			//api接口参数
			if(!empty(data.result.work_api_parameter)){
				var work_api_parameter = data.result.work_api_parameter;
				ld.each(work_api_parameter,function(workflow_api_type,temp_workflow_info){
					if(workflow_api_type == 'post'){
						ld("#"+crmPopupobj.divid+" [name=post_tr_1]").remove();//删除tpl里预置的第一行tr
						ld("#"+crmPopupobj.divid+" [name=post_tr_2]").remove();//删除tpl里预置的第一行tr
						var post_tr_cnt = 0;
						ld.each(temp_workflow_info,function(sequence,info){
							var last_tr = ld("#post_table tbody>tr").eq(-1);
							var temp_table = WorkflowCustomization.getWorkflow_Table_For_Api('post',sequence);//输入参数下面的设置区块html
							if (last_tr.length<1) {//当没有tr时
								ld("#post_table tbody").html(temp_table);
							}else{
								last_tr.after(temp_table);
							}
							ld("#"+crmPopupobj.divid+" [name=post_"+sequence+"]").val(info.parameter_name);
							ld("#"+crmPopupobj.divid+" [name=post_type][tag_row="+sequence+"] option[value="+info.parameter_type+"]").attr('selected', true);

							if(info.parameter_type == 'manual'){
								ld("#"+crmPopupobj.divid+" [name=post_manual_"+sequence+"]").val(info.parameter_value);
							}else if(info.parameter_type == 'system_fields'){
								ld("#"+crmPopupobj.divid+" [name=post_manual_"+sequence+"]").hide();
								ld("#"+crmPopupobj.divid+" [name=post_module_fields_"+sequence+"]").hide();
								ld("#"+crmPopupobj.divid+" [name=post_system_fields_"+sequence+"]").show();
								ld("#"+crmPopupobj.divid+" [name=post_system_fields_"+sequence+"] option[value='"+info.parameter_value+"']").attr('selected', true);
							}else if(info.parameter_type == 'module_fields'){
								ld("#"+crmPopupobj.divid+" [name=post_manual_"+sequence+"]").hide();
								ld("#"+crmPopupobj.divid+" [name=post_module_fields_"+sequence+"]").show();
								ld("#"+crmPopupobj.divid+" [name=post_system_fields_"+sequence+"]").hide();
								ld("#"+crmPopupobj.divid+" [name=post_module_fields_"+sequence+"] option[value='"+info.parameter_value+"']").attr('selected', true);
							}
							ld("#"+crmPopupobj.divid+" [name=post_description_"+sequence+"]").val(info.parameter_description);

							ld("#"+crmPopupobj.divid+" [name=post_parameter_type_"+sequence+"]").val(info.parameter_type);
							
							post_tr_cnt++;
						});
						ld("#"+crmPopupobj.divid+" [name=post_tr_cnt]").val(post_tr_cnt);
					}
					else if(workflow_api_type == 'code'){
						ld("#"+crmPopupobj.divid+" [name=code_tr_1]").remove();//删除tpl里预置的第一行tr
						var code_tr_cnt = 0;
						ld.each(temp_workflow_info,function(sequence,info){
							var last_tr = ld("#code_table tbody>tr").eq(-1);
							var temp_table = WorkflowCustomization.getWorkflow_Table_For_Api('code',sequence);//输入参数下面的设置区块html
							if (last_tr.length<1) {//当没有tr时
								ld("#"+crmPopupobj.divid+" #code_table tbody").html(temp_table);
							}else{
								last_tr.after(temp_table);
							}
							ld("#"+crmPopupobj.divid+" [name=code_"+sequence+"]").val(info.parameter_name);

							ld("#"+crmPopupobj.divid+" [name=code_description_"+sequence+"]").val(info.parameter_value);

							code_tr_cnt++;
						});
						ld("#"+crmPopupobj.divid+" [name=code_tr_cnt]").val(code_tr_cnt);
					}
				});
			}
			
			WorkflowCustomization.addActionBind();

			tooltip('.tip-items-list', {transition: true, time: 200});
		}
	});
}

WorkflowCustomization.addActionForLink2ERP = function(workflow_actionid){
	var popupobj=CrmPopup.getPopupObj("last");
	var workflow_id = ld("#"+popupobj.divid+" [name=workflow_id]").val();
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForLink2ERP&tabid='+ld("#"+popupobj.divid+" [name=tabid]").val()+'&workflow_actionid='+workflow_actionid+'&workflow_id='+workflow_id;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,WorkflowCustomization.saveAction,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.createScrollDiv();
			crmPopupobj.show(data.result.content);
			crmPopupobj.setScrollDivMaxHeight();
			crmPopupobj.center();

			//api接口参数
			if(!empty(data.result.work_api_parameter)){
				var work_api_parameter = data.result.work_api_parameter;
				ld.each(work_api_parameter,function(workflow_api_type,temp_workflow_info){
					if(workflow_api_type == 'post'){
						ld("#"+crmPopupobj.divid+" [name=post_tr_1]").remove();//删除tpl里预置的第一行tr
						ld("#"+crmPopupobj.divid+" [name=post_tr_2]").remove();//删除tpl里预置的第一行tr
						var post_tr_cnt = 0;
						ld.each(temp_workflow_info,function(sequence,info){
							var last_tr = ld("#post_table tbody>tr").eq(-1);

							var temp_table = WorkflowCustomization.getWorkflow_Table_For_Api('post',sequence);//输入参数下面的设置区块html
							if (last_tr.length<1) {//当没有tr时
								ld("#post_table tbody").html(temp_table);
							}else{
								last_tr.after(temp_table);
							}
							ld("#"+crmPopupobj.divid+" [name=post_"+sequence+"]").val(info.parameter_name);
							ld("#"+crmPopupobj.divid+" [name=post_type][tag_row="+sequence+"] option[value="+info.parameter_type+"]").attr('selected', true);

							if(info.parameter_type == 'manual'){
								ld("#"+crmPopupobj.divid+" [name=post_manual_"+sequence+"]").val(info.parameter_value);
							}/*else if(info.parameter_type == 'system_fields'){
								ld("#"+crmPopupobj.divid+" [name=post_manual_"+sequence+"]").hide();
								ld("#"+crmPopupobj.divid+" [name=post_module_fields_"+sequence+"]").hide();
								ld("#"+crmPopupobj.divid+" [name=post_system_fields_"+sequence+"]").show();
								ld("#"+crmPopupobj.divid+" [name=post_system_fields_"+sequence+"] option[value='"+info.parameter_value+"']").attr('selected', true);
							}else if(info.parameter_type == 'module_fields'){
								ld("#"+crmPopupobj.divid+" [name=post_manual_"+sequence+"]").hide();
								ld("#"+crmPopupobj.divid+" [name=post_module_fields_"+sequence+"]").show();
								ld("#"+crmPopupobj.divid+" [name=post_system_fields_"+sequence+"]").hide();
								ld("#"+crmPopupobj.divid+" [name=post_module_fields_"+sequence+"] option[value='"+info.parameter_value+"']").attr('selected', true);
							}*/
							ld("#"+crmPopupobj.divid+" [name=post_description_"+sequence+"]").val(info.parameter_description);

							ld("#"+crmPopupobj.divid+" [name=post_parameter_type_"+sequence+"]").val(info.parameter_type);

							if (info.parameter_name == 'exch_key') {
								ld("#"+crmPopupobj.divid+" [name=post_"+sequence+"]").prop('readonly',true);
								ld("#"+crmPopupobj.divid+" [name=post_type][tag_row="+sequence+"]").prop('disabled',true);
								ld("#"+crmPopupobj.divid+" [name=post_description_"+sequence+"]").prop('readonly',true);
								ld("#"+crmPopupobj.divid+" [name=api_tr_del][tag_row="+sequence+"]").remove();
							}

							post_tr_cnt++;
						});
						ld("#"+crmPopupobj.divid+" [name=post_tr_cnt]").val(post_tr_cnt);
					}
				});
			}

			//实际上调用连接ERP不需要设置添加字段，故无需设置事件，而且固定的一行仅有exch_key
			// WorkflowCustomization.addActionBind();

			// tooltip('.tip-items-list', {transition: true, time: 200});
		}
	});
}

WorkflowCustomization.getWorkflow_Table_For_Api = function(api_type,rowid){
	var popupobj=CrmPopup.getPopupObj("last");
	var MAINFIELDSEL = ld("#"+popupobj.divid+" [name=MAINFIELDSEL]").val();
	var FIELDSEL = ld("#"+popupobj.divid+" [name=FIELDSEL]").val();
	var PLEASESELECTFIELD_label = ld("#"+popupobj.divid+" [name=PLEASESELECTFIELD_label]").val();
	var CURRENTDATE_label = ld("#"+popupobj.divid+" [name=CURRENTDATE_label]").val();
	var CurrentTime_label = ld("#"+popupobj.divid+" [name=CurrentTime_label]").val();
	var COMPANYADDRESS_label = ld("#"+popupobj.divid+" [name=COMPANYADDRESS_label]").val();
	var BIll_label = ld("#"+popupobj.divid+" [name=BIll_label]").val();
	var SystemVariables_label = ld("#"+popupobj.divid+" [name=SystemVariables_label]").val();
	var MANUALINPUT_label = ld("#"+popupobj.divid+" [name=MANUALINPUT_label]").val();
	var Docmodulefields_label = ld("#"+popupobj.divid+" [name=Docmodulefields_label]").val();
	var Currentmodule_label = ld("#"+popupobj.divid+" [name=Currentmodule_label]").val();
	var DocumentNumber = ld("#"+popupobj.divid+" [name=DocumentNumber]").val();
	var workflow_aciton_type = ld("#"+popupobj.divid+" [name=workflow_aciton_type]").val();
	if(api_type == 'post'){
		var temp_table = "<tr name='post_tr_"+rowid+"'>";
		temp_table += "<td class='padT16'><input class='ld-input-inner gwidth90' type='text' name='post_"+rowid+"' value='' placeholder='KEY' /></td>";

		temp_table += "<td class='padT16'><select class='ld-select-inner gwidth90 lfloat' name='post_type' tag_row='"+rowid+"' tag=\"post\" id=''><option value='manual'>"+MANUALINPUT_label+"</option><option value='module_fields'>"+Docmodulefields_label+"</option><option value='system_fields'>"+SystemVariables_label+"</option></select><input type=\"hidden\" name=\"post_parameter_type_"+rowid+"\" value=\"manual\"></td>";
		temp_table += "<td class='padT16'><input class=\"ld-input-inner gwidth90 marL8\" type=\"text\" name=\"post_manual_"+rowid+"\" value=\"\" placeholder=\""+arrJsPopLabel['pleaseenter']+"\" /><select class=\"ld-select-inner gwidth90 marL8\" name=\"post_module_fields_"+rowid+"\" style=\"display:none;\">"+MAINFIELDSEL+"</select><select class=\"ld-select-inner gwidth90 marL8\" name=\"post_system_fields_"+rowid+"\" style=\"display:none;\"><option>"+PLEASESELECTFIELD_label+"</option><option value=\"[sys.currentdate]\">"+CURRENTDATE_label+"</option><option value=\"[sys.currenttime]\">"+CurrentTime_label+"</option><option value=\"[sys.record]\">"+BIll_label+"</option></select></td>";

		temp_table += "<td class='padT16'><input class='ld-input-inner gwidth90' type='text' name='post_description_"+rowid+"' value='' placeholder=\""+arrJsPopLabel['ParametricDescription']+"\" /></td>";
		if(workflow_aciton_type =='Link2ERP'){
			temp_table += "<td class='padT16'><input type=\"hidden\" name=\"post_tr_display_"+rowid+"\" value=\"yes\"></td>";
		}else{
			temp_table += "<td class='padT16'>" +
				"<input type=\"hidden\" name=\"post_tr_display_"+rowid+"\" value=\"yes\"><i class=\"ld-fonticon ld-fonticon-del\" style=\"margin-left: 20px;\" name=\"api_tr_del\" tag=\"post\" tag_row=\""+rowid+"\" title=\""+arrJsPopLabel['DELETE']+"\"></i></td>";
		}
		temp_table += "</tr>";
	}
	else if(api_type == 'code'){
		var temp_table = "<tr name='code_tr_"+rowid+"'>";
		temp_table += "<td><input style='width:140px' class='ld-input-inner' type='number' name='code_"+rowid+"' value=\"-1\" placeholder='Status Code' /></td><td><input style=\"width:480px\" class=\"ld-input-inner\" type=\"text\" name=\"code_description_"+rowid+"\" value='' placeholder='"+arrJsPopLabel['pleaseenter']+"' /></td> <td> <input type=\"hidden\" name=\"code_tr_display_"+rowid+"\" value=\"yes\"> <a class=\"icon-homeimg icon-sdel\" style=\"cursor: pointer;margin-left: 20px;\" name=\"api_tr_del\" tag=\"code\" tag_row=\""+rowid+"\" title=\""+arrJsPopLabel['DELETE']+"\"></a></td>";
		temp_table += "</tr>";
	}

	return temp_table;
}
//Api自定义字段查询 	
WorkflowCustomization.getCustomField = function(obj,event){
	var popupobj=CrmPopup.getPopupObj("last");
	var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForCustomField&tabid='+ld("#"+popupobj.divid+" [name=tabid]").val();
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth1100px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			ld("#"+popupobj.divid+" [name=workflow_add_action]").find("option[value=add_action]").prop("selected",true); 
			crmPopupobj.setParams(data.result.title,'',"","LdPopWidth1100px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
			crmPopupobj.show(data.result.content);
		}
	});
}

//添加工作流操作事件绑定
WorkflowCustomization.addActionBind = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	ld("#"+popupobj.divid+" [name=field_variables]").unbind('change').on('change',function(){
		var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForApi&sel_tabid='+this.value+'&getModuleField=yes';
		ldAjaxNoProgress(urlstring,"",function(data){
			if(data.code==1){
				ld("#"+popupobj.divid+" [name=select_fieldsel]").html(data.result);

			}
		});
		return false;
	});

	ld("#"+popupobj.divid+" [name=select_fieldsel],[name=system_variables]").unbind('change').on('change',function(){
		var textObj = ld("#"+popupobj.divid+" [name=json_data]")[0];
		var textFeildValue = this.value;
		var reg = /[^\x00-\xff]/ig;
		if (reg.test(textFeildValue)) {
			return false;
		}
		if (document.all) {
            if (textObj.createTextRange && textObj.caretPos) {
                var caretPos = textObj.caretPos;
                caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == '' ? textFeildValue + '' : textFeildValue;
            } else {
                textObj.value = textFeildValue;
            }
        } else {
			if (textObj.setSelectionRange) {
				var rangeStart = textObj.selectionStart;
				var rangeEnd = textObj.selectionEnd;
				var tempStr1 = textObj.value.substring(0, rangeStart);
				var tempStr2 = textObj.value.substring(rangeEnd);
				textObj.value = tempStr1 + textFeildValue + tempStr2;
			}
        }
		return false;
	});

	ld("#"+popupobj.divid+" [name=post_type]").unbind('change').on('change',function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var tag_row = ld(this).attr('tag_row');
		ld("#"+popupobj.divid+" [name=post_parameter_type_"+tag_row+"]").val(this.value);
		if(this.value == 'manual'){
			ld("#"+popupobj.divid+" [name=post_manual_"+tag_row+"]").show();
			ld("#"+popupobj.divid+" [name=post_module_fields_"+tag_row+"]").hide();
			ld("#"+popupobj.divid+" [name=post_system_fields_"+tag_row+"]").hide();
		}else if(this.value == 'module_fields'){
			ld("#"+popupobj.divid+" [name=post_manual_"+tag_row+"]").hide();
			ld("#"+popupobj.divid+" [name=post_module_fields_"+tag_row+"]").show();
			ld("#"+popupobj.divid+" [name=post_system_fields_"+tag_row+"]").hide();
		}else if(this.value == 'system_fields'){
			ld("#"+popupobj.divid+" [name=post_manual_"+tag_row+"]").hide();
			ld("#"+popupobj.divid+" [name=post_module_fields_"+tag_row+"]").hide();
			ld("#"+popupobj.divid+" [name=post_system_fields_"+tag_row+"]").show();
		}
	});


	ld("#"+popupobj.divid+" [name=api_tr_del]").unbind('click').on('click',function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var api_tr_type = ld(this).attr('tag');
		var tag_row = ld(this).attr('tag_row');
		if(api_tr_type == 'post'){
			ld("#"+popupobj.divid+" [name=post_tr_"+tag_row+"]").hide();
			ld("#"+popupobj.divid+" [name=post_tr_display_"+tag_row+"]").val('no');
			// ld("#"+popupobj.divid+" [name=post_tr_"+tag_row+"]").remove();//如果删除，tr序号需要重置，麻烦
		}
		else if(api_tr_type == 'code'){
			ld("#"+popupobj.divid+" [name=code_tr_"+tag_row+"]").hide();
			ld("#"+popupobj.divid+" [name=code_tr_display_"+tag_row+"]").val('no');
		}

	});

	ld("#"+popupobj.divid+" [name=api_tr_add]").unbind('click').on('click',function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var api_tr_type = ld(this).attr('tag');
		var tag_row = ld(this).attr('tag_row');
		if(api_tr_type == 'post'){
			var table_len = ld("#"+popupobj.divid+" [name=post_table]").find("tbody>tr").length;
			var temp_row = table_len + 1;
			ld("#"+popupobj.divid+" [name=post_tr_cnt]").val(temp_row);

			var last_tr = ld("#post_table tbody>tr").eq(-1);
			var temp_table = WorkflowCustomization.getWorkflow_Table_For_Api('post',temp_row);
			if (last_tr.length<1) {//没有tr时
				ld("#post_table tbody").html(temp_table);
			}else{
				last_tr.after(temp_table);
			}
			WorkflowCustomization.addActionBind();
		}
		else if(api_tr_type == 'code'){
			var table_len = ld("#"+popupobj.divid+" [name=code_table]").find("tbody>tr").length;
			var temp_row = table_len + 1;
			ld("#"+popupobj.divid+" [name=code_tr_cnt]").val(temp_row);

			var last_tr = ld("#code_table tbody>tr").eq(-1);
			var temp_table = WorkflowCustomization.getWorkflow_Table_For_Api('code',temp_row);
			last_tr.after(temp_table);
			WorkflowCustomization.addActionBind();
		}

	});

	ld("#"+popupobj.divid+" [name=api_receive_msg]").unbind('click').on('click',function(){
		var popupobj=CrmPopup.getPopupObj("last");
		if(ld(this).prop('checked')){
			ld("#"+popupobj.divid+" [name=tr_code_table]").show();
		}else{
			ld("#"+popupobj.divid+" [name=tr_code_table]").hide();
		}

	});
	
}

//工作流操作  - 保存

WorkflowCustomization.saveAction = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var action_title = ld("#"+popupobj.divid+" [name=action_title]").val();
	var action_type = ld("#"+popupobj.divid+" [name=workflow_aciton_type]").val();

	if(action_type != 'Link2ERP' && empty(action_title)){
		var confirm_str =  ld("#"+popupobj.divid+" [name=action_title]").attr('tag');
		ld("#"+popupobj.divid+" [name=action_title]").focus();
		RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str+arrJsPopLabel['CANOTEMPTY']);
		return false;
	}
	var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForActionsSave&action_type='+action_type;
	//调用API
	if(action_type == 'API'){
		var api_url = ld("#"+popupobj.divid+" [name=api_url]").val();
		if(empty(api_url)){
			ld("#"+popupobj.divid+" [name=api_url]").focus();
			RemindsMsg("","LdPopWidth400px",'',"yes","","API URL"+arrJsPopLabel['CANOTEMPTY']);
			return false;
		}

		var selectfield_label =  ld("#"+popupobj.divid+" [name=PLEASESELECTFIELD_label]").val();
		var paramete_label =  ld("#"+popupobj.divid+" [name=Paramete_label]").val();

		var parametevalue = '';
		//post参数
		var table_len = ld("#"+popupobj.divid+" [name=post_table]").find("tbody>tr").length;

		for(var i = 1; i <= table_len ; i++){
			if (ld("#"+popupobj.divid+" [name=post_tr_"+i+"]").find(" [name=post_tr_display_"+i+"]").val() == 'no') {
				continue;//已删除的不用检查
			}

			var parametename = ld("#"+popupobj.divid+" [name=post_"+i+"]").val();
			var post_header_type = ld("#"+popupobj.divid+" [name=post_type][tag=post][tag_row="+i+"]").val();
			if(post_header_type == 'manual'){
				var parametevalue = ld("#"+popupobj.divid+" [name=post_manual_"+i+"]").val();
			}else if(post_header_type == 'module_fields'){
				var parametevalue = ld("#"+popupobj.divid+" [name=post_module_fields_"+i+"]").val();
			}else if(post_header_type == 'system_fields'){
				var parametevalue = ld("#"+popupobj.divid+" [name=post_system_fields_"+i+"]").val();
			}

			if((!empty(parametename) && (parametevalue == selectfield_label || parametevalue == '')) || (empty(parametename) && parametevalue != selectfield_label && parametevalue != '')){
				RemindsMsg("","LdPopWidth400px",'',"yes","",'Post'+paramete_label+arrJsPopLabel['ERRORPLEASESETTRUENUM']);
				return false;
			}
		}


		if (ld("#"+popupobj.divid+" [name=api_receive_msg]").prop('checked')) {//设置不接收返回状态和提示时不用检查
			//code 参数
			var table_len = ld("#"+popupobj.divid+" [name=code_table]").find("tbody>tr").length;
			var hadcode_arr = [];
			for(var i = 1; i <= table_len ; i++){
				if (ld("#"+popupobj.divid+" [name=code_tr_"+i+"]").find(" [name=code_tr_display_"+i+"]").val() == 'no') {
					continue;
				}
				var parametename = ld("#"+popupobj.divid+" [name=code_"+i+"]").val();
				var parametevalue = ld("#"+popupobj.divid+" [name=code_description_"+i+"]").val() || '';

				//状态码不能为空、不能重复 且 文本不能为空
				if (parametename === "") {
					RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['StatusCode']+arrJsPopLabel['CANOTEMPTY']);
					return false;
				}
				if (ld.inArray(parametename, hadcode_arr) > -1) {
					RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['StatusCode']+parametename+'，'+arrJsPopLabel['ALREADYEXISTSREENTRY']);
					return false;
				}
				if(parametevalue.length<1){
					RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['StatusCode']+parametename+'，'+arrJsPopLabel['StatusDescription']+arrJsPopLabel['ERRORPLEASESETTRUENUM']);
					return false;
				}
				hadcode_arr.push(parametename);
			}
		}

		var formdata=ld("#"+popupobj.divid+' [name=workflow_actions]').serialize();
		var api_receive_msg = ld("#"+popupobj.divid+" [name=api_receive_msg]").prop('checked')?'yes':'no';
		formdata += '&api_receive_msg='+api_receive_msg;

	}
	else if(action_type == 'Link2ERP'){
		var api_url = ld("#"+popupobj.divid+" [name=api_url]").val();
		if(empty(api_url)){
			ld("#"+popupobj.divid+" [name=api_url]").focus();
			var confirm_str =  ld("#"+popupobj.divid+" [name=api_url]").attr('tag');
			RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str+arrJsPopLabel['CANOTEMPTY']);
			return false;
		}

		var selectfield_label =  ld("#"+popupobj.divid+" [name=PLEASESELECTFIELD_label]").val();//非手动录入时需重选

		var paramete_label =  ld("#"+popupobj.divid+" [name=Paramete_label]").val();

		var parametevalue = '';
		//post参数
		var table_len = ld("#"+popupobj.divid+" [name=post_table]").find("tbody>tr").length;

		var hadpost_arr = [];//参数定义不能重复
		for(var i = 1; i <= table_len ; i++){
			if (ld("#"+popupobj.divid+" [name=post_tr_"+i+"]").find(" [name=post_tr_display_"+i+"]").val() == 'no') {
				continue;//已删除的不用检查
			}

			var parametename = ld("#"+popupobj.divid+" [name=post_"+i+"]").val();
			var post_header_type = ld("#"+popupobj.divid+" [name=post_type][tag=post][tag_row="+i+"]").val();
			if(post_header_type == 'manual'){
				var parametevalue = ld("#"+popupobj.divid+" [name=post_manual_"+i+"]").val().trim();
			}else if(post_header_type == 'module_fields'){
				var parametevalue = ld("#"+popupobj.divid+" [name=post_module_fields_"+i+"]").val();
			}else if(post_header_type == 'system_fields'){
				var parametevalue = ld("#"+popupobj.divid+" [name=post_system_fields_"+i+"]").val();
			}

			if (ld.inArray(parametename, hadpost_arr) > -1) {
				RemindsMsg("","LdPopWidth400px",'',"yes","",paramete_label+parametename+'，'+arrJsPopLabel['ALREADYEXISTSREENTRY']);
				return false;
			}

			if((!empty(parametename) && (parametevalue == selectfield_label || parametevalue == '')) || (empty(parametename) && parametevalue != selectfield_label && parametevalue != '')){
				RemindsMsg("","LdPopWidth400px",'',"yes","",paramete_label+arrJsPopLabel['ERRORPLEASESETTRUENUM']);
				return false;
			}

			hadpost_arr.push(parametename);
		}

		var formdata=ld("#"+popupobj.divid+' [name=workflow_actions]').serialize();
		var api_receive_msg = ld("#"+popupobj.divid+" [name=api_receive_msg]").prop('checked')?'yes':'no';
		formdata += '&api_receive_msg='+api_receive_msg;

	}
	else if(action_type == 'UpdateFields'){	//	更新字段
		var formdata = {};
		var trdata_array = [];
		ld("#"+popupobj.divid+" [name=conditiongrouptable] tr").each(function(){
			var tr_data = [];
			var rowindex = ld(this).attr('rowindex');
			var referencemodule = ld(this).find(' [name="referencemodule"]').val();
			var referencemodule_fields = ld(this).find(' [name="referencemodule_fields"]').val();
			if(!empty(referencemodule) && !empty(referencemodule_fields)){
				var referencemodule_fields_uitype = ld(this).find(' [name="referencemodule_fields"]').find('option:selected').attr('uitype');
				var select_mode = ld(this).find(' [name="select_mode"]').val();
				var select_value = ld(this).find(' [name="select_value"]').val();
				if(referencemodule_fields_uitype == 33){
					select_value = getMultiPickListSelectValue("fval[]");
					ld(this).find(' [name="select_value"]').val(select_value);
					select_value = encodeURIComponent(select_value);
				}else if(referencemodule_fields_uitype == 15){
					//ls 20221220 BUG0059524 设置报价单模块  审批通过后 报价单状态为已审批，保存后再次打开 还是显示已创建
					select_value = ld(this).find(' [name="fval"]').val();
					select_value = encodeURIComponent(select_value);
				}else if(referencemodule_fields == 'pool_id' || referencemodule_fields == 'publicaccount'){
					//客户模块的所属公海和公海状态字段
					select_value = ld(this).find(' [name="fval"]').val();
					select_value = encodeURIComponent(select_value);
				}
				tr_data.push(referencemodule);
				tr_data.push(referencemodule_fields);
				tr_data.push(select_mode);
				tr_data.push(select_value);
				tr_data.push(referencemodule_fields_uitype);
				trdata_array.push(JSON.stringify(tr_data));
			}
			
		});
		if(trdata_array.length <= 0 ){
			var confirm_str =  ld("#"+popupobj.divid+" [name=action_title]").attr('tag');
			RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['Pleaseselectthefieldtobeupdated']);
			return false;
		}
		urlstring += '&action_title='+encodeURIComponent(action_title)+'&mode=save';
		urlstring += '&updatefields_json_data='+JSON.stringify(trdata_array);
		urlstring += '&tabid='+ld("#"+popupobj.divid+" [name=tabid]").val();
		urlstring += '&workflow_id='+ld("#"+popupobj.divid+" [name=workflow_id]").val();
		urlstring += '&workflow_actionsid='+ld("#"+popupobj.divid+" [name=workflow_actionid]").val();
		
		//var rowobj=ld("#"+prev_popupobj.divid+" [name=conditiongrouptable]").find("tr[rowindex="+rowid+"]");
		//ld(rowobj).find(' [name="select_mode"]').val(select_mode);
	}
	else if(action_type == 'ExcuteSql'){	//执行SQL
		var excute_sql_content = ld("#"+popupobj.divid+" [id=excute_sql_content]").val();
		if(empty(excute_sql_content)){
			var confirm_str =  ld("#"+popupobj.divid+" [name=excute_sql_content]").attr('tag');
			ld("#"+popupobj.divid+" [name=excute_sql_content]").focus();
			RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str+arrJsPopLabel['CANOTEMPTY']);
			return false;
		}

		var excute_sql_content_encry = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(excute_sql_content,false,"");

		formdata = 'excute_sql_content='+encodeURIComponent(excute_sql_content_encry);
		urlstring += '&action_title='+encodeURIComponent(action_title)+'&mode=save';
		urlstring += '&tabid='+ld("#"+popupobj.divid+" [name=tabid]").val();
		urlstring += '&workflow_id='+ld("#"+popupobj.divid+" [name=workflow_id]").val();
		urlstring += '&workflow_actionsid='+ld("#"+popupobj.divid+" [name=workflow_actionid]").val();
	}
	else if(action_type == 'AutoShare'){
		urlstring += '&action_title='+encodeURIComponent(action_title)+'&mode=save';
		urlstring += '&workflow_id='+ld("#"+popupobj.divid+" [name=workflow_id]").val();
		var autoshare_type =  ld('#'+popupobj.divid+' [name=Action_autoshare_type]').val();
		urlstring += '&workflow_actionsid='+ld("#"+popupobj.divid+" [name=workflow_actionid]").val();
		urlstring += '&autoshare_setmode='+autoshare_type;
		if(autoshare_type == 'User'){
			if(empty(ld('#'+popupobj.divid+' #Action_autoshare_User_value').val())){
				RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['PLEASESELECTSHARER']);
				return false;
			}
			urlstring += '&autoshare_setvalue='+ld('#'+popupobj.divid+' #Action_autoshare_User_value').val();
		}else if(autoshare_type == 'UserField'){
			if(empty(ld('#'+popupobj.divid+' [name=Action_autoshare_UserField]').val())){
				RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['PLEASESELECTSHARER']);
				return false;
			}
			urlstring += '&autoshare_setvalue='+ld('#'+popupobj.divid+' [name=Action_autoshare_UserField]').val();
		}
	}
	//alert(urlstring);
	ldAjax(urlstring,formdata,function(data){
		if(data.code==1){
			var prevpopupobj=CrmPopup.getPopupObj("lastprev");
			ld("#"+prevpopupobj.divid+" [name=workflow_id]").val(data.result.workflow_id);
			ld("#"+prevpopupobj.divid+" [name=table_workflow_actions] tr:not(:first)").remove();
			ld("#"+prevpopupobj.divid+" [name=table_workflow_actions] > tbody").append(data.result.content);
			
			popupobj.CancelEvent();
			DelProgressObjs();
            WorkflowCustomization.setSort();
		}else{
			RemindsMsg("","LdPopWidth400px",'',"yes","",'JSON'+arrJsPopLabel['FORMATERROR']);
			return false;
		}
	});
}
WorkflowCustomization.saveAction.funname='WorkflowCustomization.saveAction';
//工作流操作 - 编辑、删除、停用、启用
WorkflowCustomization.operateActions = function(obj,event){
	var operate_type = ld(obj).attr('tag');
	var workflow_actionid = ld(obj).attr('workflow_actionid');
	var action_type = ld(obj).attr('action_type');
	if(operate_type == 'edit'){
		if(action_type == 'API'){
			WorkflowCustomization.addAction(workflow_actionid);
		}else if(action_type == 'Link2ERP'){
			WorkflowCustomization.addActionForLink2ERP(workflow_actionid);
		}else if(action_type == 'UpdateFields'){
			WorkflowCustomization.addActionForUpdateFields(workflow_actionid);
		}else if(action_type == 'ExcuteSql'){
			WorkflowCustomization.addActionForExcuteSql(workflow_actionid);
		} else if(action_type == 'AutoShare'){
			WorkflowCustomization.addActionForAutoShare(workflow_actionid);
		}
	}else if(operate_type == 'delete'){
		var popupobj=CrmPopup.getPopupObj("last");
		var workflow_id = ld("#"+popupobj.divid+" [name=workflow_id]").val();
		var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForActionsSave&mode=delete&workflow_actionid='+workflow_actionid+'&workflow_id='+workflow_id;
		var confirm_str = arrJsPopLabel['CANOTRESTOREDAFTERDELETIONDELETEOK'];
		MessagePopup.TipTwo_warning(confirm_str);
		//确认事件
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			ldAjax(urlstring,'',function(data){
				if(data.code==1){
					ld("#"+popupobj.divid+" [name=table_workflow_actions] tr:not(:first)").remove();
					ld("#"+popupobj.divid+" [name=table_workflow_actions] > tbody").append(data.result.content);
					console.log('data.result.content: ', data.result.content);
					DelProgressObjs();
                    WorkflowCustomization.setSort();
				}
			});
		});
	}else if(operate_type == 'status'){
		var popupobj=CrmPopup.getPopupObj("last");
		//var _status = ld(obj).attr('type');
		if(ld(obj).prop('checked')){
            var _status = 'Inactive';
        }else{
            var _status = 'Active';
        }
		var workflow_id = ld("#"+popupobj.divid+" [name=workflow_id]").val();
		var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationForActionsSave&mode=status&workflow_actionid='+workflow_actionid+'&workflow_id='+workflow_id+'&status='+_status;
		ldAjax(urlstring,'',function(data){
			if(data.code==1){
				ld("#"+popupobj.divid+" [name=table_workflow_actions] tr:not(:first)").remove();
				ld("#"+popupobj.divid+" [name=table_workflow_actions] > tbody").append(data.result.content);
				DelProgressObjs();
			}
		});
	}
}
//工作流程 - 保存
WorkflowCustomization.save = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	if(popupobj.advanceFilterObj.checkAdvancedFilter()==false)
	{
			return false;
	}
	var workflow_name = ld("#"+popupobj.divid+" [name=workflow_name]").val();	//流程名称
	if(empty(workflow_name)){
		var confirm_str =  ld("#"+popupobj.divid+" [name=workflow_name]").attr('tag');
		ld("#"+popupobj.divid+" [name=workflow_name]").focus();
		RemindsMsg("","LdPopWidth400px",'',"yes","",confirm_str+arrJsPopLabel['CANOTEMPTY']);
		return false;
	}
	var advft_criteria = popupobj.advanceFilterObj.advft_criteria;
	var advft_criteria_groups = popupobj.advanceFilterObj.advft_criteria_groups;
	var workflow_status = ld("#"+popupobj.divid+" [name=workflow_status]").val();	//状态
	var workflow_description = ld("#"+popupobj.divid+" [name=workflow_description]").val();	//备注
	var workflow_triggertime = ld("#"+popupobj.divid+" [name=workflow_triggertime]:checked").val();	//触发点
	var tabid = ld("#frommodule_tabid").val();
	if(workflow_triggertime == 'Approval'){
		var approvestatus = [];
		ld('input[name="workflow_approvetime[]"]:checked').each(function(){
			approvestatus.push(this.value);
		});
		//至少得选择一个审批节点！
		if(approvestatus.length <= 0){
			RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['Atleastoneapprovalnodemustbeselected']);
			return false;
			
		}
	}
	//请添加工作流操作！
    var trobjs=ld("#"+popupobj.divid+" [name=table_workflow_actions] > tbody ").children("tr");
    var trobjs_firstadd=ld("#"+popupobj.divid+" [name=table_workflow_actions] > tbody ").children("tr").eq(0).attr('workflow_actionid');//230413 wyt BUG0058823  kfbcrm 工作流程定制---新建时不添加工作流操作---保存时没有提示

	if(trobjs_firstadd == undefined || ld(trobjs).length == 0 ){
		RemindsMsg("","LdPopWidth400px",'',"yes","",arrJsPopLabel['Pleaseaddworkflowoperation']);
		return false;
	}
    var workflowaction_arr=[];
    ld.each(trobjs,function(){
        if(ld(this).attr('workflow_actionid')>0)
        workflowaction_arr.push(ld(this).attr('workflow_actionid'));
        
    })
	var formdata=ld("#"+popupobj.divid+' [name=workflow]').serialize();
	var params = {'advft_criteria':advft_criteria,'advft_criteria_groups':advft_criteria_groups};
	//return false;
	formdata+="&workflowactionids="+workflowaction_arr.join(",");
    
	ldAjax('index.php?'+formdata,params,function(data){
		
		if(data.code==1){
			popupobj.CancelEvent();
			DelProgressObjs();
			WorkflowCustomization.refresh(tabid);
		}
	});
	return false;
}

// //工作流程 - 分页
// WorkflowCustomization.setPage = function(obj,event){
// 	var page_type = ld(obj).attr('tag');
// 	var tabid = ld("#frommodule_tabid").val();
// 	var page = ld("#curPage").val();
// 	if(page_type == 'prev'){
// 		page = page - 1;
// 	}else if(page_type == 'next'){
// 		page = page + 1;
// 	}
// 	var surl = 'index.php?module=Settings&action=SettingsAjax&file=WorkflowCustomizationList&ajax=true&tabid='+tabid+"&page="+page;
// 	ldAjax(surl,"",function(data){
// 		if(data.code==1){
// 			ld(' [name=workflow_content]').html(data.result.content);
// 		}
//         DelProgressObjs();
// 	})
// }